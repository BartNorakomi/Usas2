#Some BMP file functions operating on byte level #hardcore
#Shadow@Fuzzylogic
# 20240304-20241106

<#
BmpFile Object props
.type="BmpFile"
.name="string"
.bmpFileheader=object version of fileheader
.dibHeader=object version of dibHeader
.colorTable=rawData
.pixelarrayOffset=start index of pixels in .rawdata
.numBitsPerPixel=number of bits per pixel
.width=image width
.height=image height
.rowSize=length of one pixel row in bytes
.pixelArraySize=image size in bytes
.colorTableOffset
.rawdata=the whole bmp file as byte array
#>

[CmdletBinding()]


##### Globals #####
#source: https://en.wikipedia.org/wiki/BMP_file_format#Bitmap_file_header
$BmpFileStructure=[pscustomobject]`
@{	BitMapFileHeader=[pscustomobject]@{order=0;mandatory=$true;name="BitMapFileHeader";offset=0x00;size=14};
	DibHeader=[pscustomobject]@{order=1;mandatory=$true;name="DibHeader";offset=0x0E;size=-1};
	ExtraBitMasks=[pscustomobject]@{order=2;mandatory=$false;name="ExtraBitMasks";offset=-1;size=-1};
	ColorTable=[pscustomobject]@{order=3;mandatory=$false;name="ColorTable";offset=-1;size=-1};
	Gap1=[pscustomobject]@{order=4;mandatory=$false;name="Gap1";offset=-1;size=-1};
	PixelArray=[pscustomobject]@{order=5;mandatory=$true;name="PixelArray";offset=-1;size=-1};
	Gap2=[pscustomobject]@{order=6;mandatory=$false;name="Gap2";offset=-1;size=-1};
	IccColorProfile=[pscustomobject]@{order=7;mandatory=$false;name="IccColorProfile";offset=-1;size=-1};
}

$BitMapFileHeaderStructure=
@(	[pscustomobject]@{order=0;mandatory=$true;label="Signature";offset=0x00;size=2;default=0x4d42};
	[pscustomobject]@{order=1;mandatory=$true;label="FileSize";offset=0x02;size=4;default=0};
	[pscustomobject]@{order=2;mandatory=$true;label="Reserved1";offset=0x06;size=2;default=0};
	[pscustomobject]@{order=3;mandatory=$true;label="Reserved2";offset=0x08;size=2;default=0};
	[pscustomobject]@{order=4;mandatory=$true;label="PixelArrayOffset";offset=0x0A;size=4;default=54};
)

$dibBITMAPCOREHEADER=
@(	[pscustomobject]@{offset=0x00;size=4;label="HeaderSize"};
	[pscustomobject]@{offset=0x04;size=2;label="Width"};
	[pscustomobject]@{offset=0x06;size=2;label="Height"};
	[pscustomobject]@{offset=0x08;size=2;label="NumColorPlanes"};
	[pscustomobject]@{offset=0x0A;size=2;label="NumBitsPerPixel"};
)

$dibBITMAPINFOHEADER=
@(	[pscustomobject]@{offset=0x00;size=4;label="HeaderSize";default=40};
	[pscustomobject]@{offset=0x04;size=4;label="Width";default=0};
	[pscustomobject]@{offset=0x08;size=4;label="Height";default=0};
	[pscustomobject]@{offset=0x0C;size=2;label="NumColorPlanes";default=1};
	[pscustomobject]@{offset=0x0E;size=2;label="NumBitsPerPixel";default=24};
	[pscustomobject]@{offset=0x10;size=4;label="CompressionMethod";default=0};
	[pscustomobject]@{offset=0x14;size=4;label="ImageSize";default=0};
	[pscustomobject]@{offset=0x18;size=4;label="HorizontalResolution";default=2849};
	[pscustomobject]@{offset=0x1C;size=4;label="VerticalResolution";default=2849};
	[pscustomobject]@{offset=0x20;size=4;label="NumColors";default=0};
	[pscustomobject]@{offset=0x24;size=4;label="NumImportantColors";default=0};
)

$DibHeaders=
@(	[pscustomobject]@{type=0;name="BITMAPCOREHEADER";size=12;structure=$dibBITMAPCOREHEADER};
	[pscustomobject]@{type=1;name="OS22XBITMAPHEADER";size=64};
	[pscustomobject]@{type=2;name="OS22XBITMAPHEADER";size=16};
	[pscustomobject]@{type=3;name="BITMAPCOREHEADER";size=12};
	[pscustomobject]@{type=4;name="BITMAPCOREHEADER";size=12};
	[pscustomobject]@{type=5;name="BITMAPINFOHEADER";size=40;structure=$dibBITMAPINFOHEADER};
	[pscustomobject]@{type=6;name="BITMAPV2INFOHEADER";size=52};
	[pscustomobject]@{type=7;name="BITMAPV3INFOHEADER";size=56};
	[pscustomobject]@{type=8;name="BITMAPV4HEADER";size=108};
	[pscustomobject]@{type=9;name="BITMAPV5HEADER";size=124};
)

##### Globals #####
#$global:BmpFileStructure=$BmpFileStructure
#$global:dibheaders=$dibheaders
$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}


##### Includes #####


##### Functions #####

#[bmpObject]
function new-bmpFileObject
{	param ($name,$numBitsPerPixel=24,$width=0,$height=0)
	$imageSize=($numBitsPerPixel/8*$width*$height)
	$bmpFile=[pscustomobject]`
	@{	Type="bmpFile";
		Name=$name;
		BitMapFileheader=new-bmpFileHeader
		DibHeader=new-dibheader
		colorTable=$null;
		pixelArray=[byte[]]::new($imageSize);
		numBitsPerpixel=[uint16]$numBitsPerPixel;
		width=[uint32]$width;
		height=[uint32]$height;
		rowsize=[uint32][math]::ceiling($numbitsperpixel*$width/32)*4;
		pixelArraysize=[uint32]$imagesize;
		colorTableOffset=[uint16]0;
		NumColors=[uint16]0;
		colorTableSize=[uint16]0;
		rawData=$Null #[byte[]]::new($filesize);
		colorTableAsObject=[pscustomobject]
	}
	if ($numBitsPerPixel -le 8)
	{	$bmpfile.colorTableOffset=$BmpFileStructure.BitMapFileHeader.size+$bmpfile.DibHeader.headersize
	}
	$bmpfile.dibHeader.width=$width
	$bmpfile.dibHeader.height=$height
	$bmpfile.dibHeader.numbitsperpixel=$numBitsPerPixel
	$bmpfile.dibHeader.ImageSize=$imagesize

	# #Give this object a unique typename
	# $bmpfile.PSObject.TypeNames.Insert(0,'bmpfile.explode')
	# #Configure a default display set
	# $defaultDisplaySet = 'name','width','height','numcolors'
	# #Create the default property display set
	# $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
	# $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
	# $bmpfile|Add-Member MemberSet PSStandardMembers $PSStandardMembers

	return ,$bmpFile
}

#[bmpObject]
function export-bmpfile
{	param ($bmpfile,$path)

	$colorTableSize=4*$bmpfile.dibheader.NumColors
	$pixelArrayOffset=$bmpfile.bitMapFileHeader.pixelarrayOffset+=$bmpfile.colorTableOffset+$colorTableSize
	$fileSize=$pixelArrayOffset+$bmpfile.pixelArraysize
	$bmpfile.bitmapFileHeader.filesize=$filesize

	#Create file data
	$bmpfile.rawData=[byte[]]::new($filesize);
	#copy header
	write-structData -byteArray $bmpfile.rawdata -struct $BitMapFileHeaderStructure -offset $BmpFileStructure.bitmapFileHeader.offset -data $bmpfile.BitMapFileheader
	#copy dibheader
	write-structData -byteArray $bmpfile.rawdata -struct $dibBITMAPINFOHEADER -offset $BmpFileStructure.dibheader.offset -data $bmpfile.dibheader
	#copy colortable
	if ($bmpfile.dibheader.numBitsPerPixel -le 8)
	{	for($i=0;$i -lt $bmpfile.colortable.length;$i++){$bmpfile.rawdata[$bmpfile.colorTableOffset+$i]=$bmpfile.colortable[$i]}
	}
	#copy pixelarray
	for($i=0;$i -lt $bmpfile.pixelarray.length;$i++){$bmpfile.rawdata[$pixelarrayOffset+$i]=$bmpfile.pixelarray[$i]}

	$bmpfile.rawdata|Set-Content -Path $path -Encoding byte
	return $bmpfile
}


#[bmpObject]
#Import BMP file into a dedicated object.
#out: $bmpFile object
function import-bmpFile
{	param ($path)
	#Open the file
	if (-not ($bmpfile=resolve-path $path)) {exit}
	write-verbose "Opening source file: $bmpfile"
	if (-not ($fs=[io.file]::OpenRead($bmpfile))) {exit}
	write-verbose "file Size: 0x$("{0:X8}" -f $fs.length)"

	#get fileheader
	$len=$BmpFileStructure.BitMapFileHeader.size
	write-verbose "Retrieve bitmapfileheader ($len bytes)"
	$rawData=[byte[]]::new($len)
	[void]$fs.read($rawdata,0,$rawdata.length)
	$BitmapFileHeader=get-bmpFileHeader -byteArray $rawdata

	#get rest of data untill pixelarray
	$len=$BitmapFileHeader.pixelarrayOffset-$BmpFileStructure.BitMapFileHeader.size
	write-verbose "Retrieve dibheader and optional colortable ($len bytes)"
	$rawData=[byte[]]::new($len)
	[void]$fs.read($rawdata,0,$rawdata.length)
	$dibheader=get-bmpDibHeader -byteArray $rawdata -offset 0
	$numbitsperpixel=$dibheader.numbitsperpixel
	$width=[int32]$dibheader.width
	$height=[int32]$dibheader.height
	$bmpFile=new-BmpFileObject -name $bmpfile -numBitsPerPixel $numbitsperpixel -width $width -height $height
	$bmpfile.bitmapFileHeader=$BitmapFileHeader
	$bmpfile.dibheader=$dibheader
	
	#colorTable
	if ($numBitsPerPixel -le 8)
	{	if (($bmpfile.numColors=$dibheader.NumColors) -eq 0) {$bmpfile.numColors=[Math]::Pow(2,$numbitsperpixel)}
		$colorTableSize=4*$bmpfile.NumColors;
		$bmpfile.colorTableSize=$colorTableSize
		$colorTable=[byte[]]::new($colorTableSize)
		$bmpfile.colorTableOffset=$BmpFileStructure.BitMapFileHeader.size+$bmpfile.DibHeader.headersize
		for($i=0;$i -lt $colorTableSize;$i++){$colorTable[$i]=$rawdata[$DibHeader.headersize+$i]}
		$bmpfile.colortable=$colortable
		$colorTableAsObject=[pscustomobject]@{numColors=$bmpfile.numcolors;size=$colorTableSize;raw=$colortable;rgb=(convert-ColorIndexTable -colortable $colortable)}
		$bmpfile.colortableAsObject=$colortableAsObject
	}
	
	#Get the pixelarray
	$len=$fs.length-$BitmapFileHeader.pixelarrayOffset
	write-verbose "Retrieving pixel array ($len bytes)"
	$rawData=[byte[]]::new($len)
	[void]$fs.read($rawdata,0,$rawdata.length)
	$bmpfile.pixelArray=$rawdata

	$fs.close()
	return $bmpfile
}

#[bmpObject]
#return .bmp header block as object
function new-bmpFileHeader
{	$data=get-defaultStruct -name "bitmapFileHeader" -struct $BitMapFileHeaderStructure
	return $data
}

#[bmpObject]
#return .bmp default dibheader
function new-dibheader
{	$data=get-defaultStruct -name "BITMAPINFOHEADER" -struct $dibBITMAPINFOHEADER
	return $data
}

#[bmpObject]
#Get .bmp file header (fixed size and position) from file data
function get-bmpFileHeader
{	param ($byteArray)
	$bmpFileHeader=read-structData -byteArray $byteArray -offset $BmpFileStructure.BitMapFileHeader.offset -struct $BitMapFileHeaderStructure -name "bitmapFileHeader"
	return $bmpFileHeader
}

#[bmpObject]
#Resolve .bmp DibHeader, and return it with values
function get-bmpDibHeader
{	param ($byteArray,$offset=$BmpFileStructure.DibHeader.offset)
	$DibHeaderSize=read-fromByteArray -data $byteArray -offset $offset -size 4
	$DibHeaderStructure=($DibHeaders|where{$_.size -eq $DibHeaderSize}).structure
	$DibHeader=read-structData -byteArray $byteArray -offset $offset -struct $DibHeaderStructure -name "DipHeader"
	return $dibHeader
}

#[bmpObject]
#Return a block of pixels from bmpFileObject
function get-pixelArray
{	param ($bmpfile,$x,$y,$width,$height)
	if ($x+$width -gt $bmpfile.width)
	{	write-error "x+width=$($x+$width) exceeds pixelarray boundaries $($bmpfile.width)"
		return
	}
	if ($y+$height -gt $bmpfile.height)
	{	write-error "$y+$height exceeds pixelarray boundaries"
		return
	}
	$size=$bmpfile.numBitsPerPixel/8*$width*$height
	$rawData=[byte[]]::new($size)
	$index=0
	$y=$bmpfile.height-1-$y-$height #image start at the bottom, so adjust Y
	$widthBytes=($bmpfile.numBitsPerPixel/8*$width)
	$startOffset=($bmpfile.numBitsPerPixel/8*$x)+($bmpfile.rowsize*$y)
	for ($row=0;$row -lt $height;$row++)
	{	$rowOffset=($row*$bmpfile.rowsize)
		for ($colm=0;$colm -lt $widthBytes;$colm++)
		{	$rawdata[$index]=$bmpfile.pixelArray[$startOffset+$rowOffset+$colm]
			$index++
		}
	}
	return $rawData
}

#convert raw RBB to hastable
#return an array of objects with (index,r,g,b)
function convert-ColorIndexTable
{	param ($colorTable)
	for ($i=0;$i -lt ($colortable.length/4);$I++)
	{   $r=$colorTable[$i*4]
		$g=$colorTable[$i*4+1]
		$b=$colorTable[$i*4+2]
		[pscustomobject]@{index=$i;r=$r;g=$g;b=$b}
	}
}


#return a data struct with default values
function get-defaultStruct
{	param ($struct,$name)
	$data=[pscustomobject]@{Name=$name}
	foreach ($record in $struct)
	{	$data|Add-Member -MemberType NoteProperty -Name $record.label -Value $record.default
	}
	return $data
}

function read-structData
{	param ($byteArray,$struct,$name,$offset)
	$data=[pscustomobject]@{Name=$name}
	foreach ($record in $struct|sort offset)
	{	$value=read-fromByteArray -data $byteArray -offset ($offset+$record.offset) -size $record.size
		$data|Add-Member -MemberType NoteProperty -Name $record.label -Value $value
	}
	return $data
}

function write-structData
{	param ($byteArray,$struct,$offset,$data,[switch]$defaults)
	foreach ($record in $struct|sort offset)
	{	$value=$data.($record.label)
		if (-not $value -and $defaults) {$value=$record.default}
		if ($value)
		{	#write-verbose "$($offset+$record.offset), $($record.label) = $value"
			write-toByteArray -data $byteArray -offset ($offset+$record.offset) -size $record.size -value $value
		}
	}
}

function read-fromByteArray
{	param ($offset,$size,$data)
	$value=0;0..($size-1)|%{$value+=[uint32]$data[$offset+$_] -shl ($_*8)}
	return $value
}

function write-toByteArray
{	param ($offset,$size,$data,$value)
	0..($size-1)|%{$data[$offset+$_]=$value -shr ($_*8) -band 0xff}
}


# #convert 24bitsRGBa to 9bitsRGB for MSX
function convert-rgb24toRgb9
{	param ($bmpfile)
	$rgb=$bmpfile.colorTableAsObject.rgb
	for ($i=0;$i -lt $bmpfile.NumColors;$I++)
	{  [pscustomobject]@{index=$i;r=[math]::Round($rgb[$i].r/255*7);g=[math]::Round($rgb[$i].g/255*7);b=[math]::Round($rgb[$i].b/255*7)}
	}
}

 exit
$path="..\grapx\tilesheets\Konark.Tiles.bmp"
$global:bmpfile=$bmpfile=import-bmpFile -path $path -verbose




# $bmpfile #.colorIndexTable
convert-rgb24toRgb9 -bmpfile $bmpfile

exit
#TEST: dump one full frame to a .dat file (raw sc5)
$transparentColor=0
$global:msxcoltab=$msxcoltab=get-MsxPaletteFromFile -path "C:\Users\rvand\GIT\Usas2\grapx\tilesheets\Konark.tiles.PL"
$global:ColorConversionTable=get-colorConversionTable -bmpfile $bmpfile -msxColTab $msxcoltab

$path="C:\Users\rvand\GIT\Usas2\grapx\BossDemon\frames.indexedColors.bmp"
if (-not ($global:bmpfile=$bmpfile=import-bmpFile -path $path)) {exit}
$sf2object=new-sf2object -name "BossDemonIdle" -imageWidth $bmpfile.width -imageHeight $bmpfile.height -canvasX 0 -canvasY 0 -canvasWidth 256 -canvasHeight (6*136) -subjectX 80 -subjectWidth 88 -subjectY 40 -subjectHeight (136-40)

$framePixels=[byte[]]::new(16KB) #max 16KB for MSX pixels
$width=$sf2object.frame.width
$height=$sf2object.subject.height
$widthBytes=($bmpfile.numBitsPerPixel/8*$width)
$frame=0
$framePos=get-Sf2FramePosition -sf2object $sf2object -frame $frame
$pixelArrayOffset=($bmpfile.height-1 -$frame.y -$sf2object.subject.y)*$bmpfile.rowsize
$index=0
for ($y=0;$y -lt $height;$y++)
{	$rowOffset=$pixelArrayOffset - ($y*$bmpfile.rowsize)
	for ($x=0;$x -lt $widthBytes;$x++)
	{	$pixelByte=get-msxpixel -pixelColor $bmpfile.pixelarray[$rowOffset+$x]
		 if ($pixelbyte -eq $false){$pixelbyte=0x0}
		 $framePixels[$index]=$pixelbyte
		$index++
	}
}
$framePixels|Set-Content -Path C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\frame0.dat -Encoding byte
exit


	
# #copy a part (1 frame) of it to a new file
# 	# $frame=7
# 	# $framePos=get-Sf2FramePosition -sf2object $sf2object -frame $frame
# 	# $global:newbmpfile=$NewBmpfile=new-bmpFileObject -name "NewBmpFile.bmp" -numBitsPerPixel $bmpfile.DibHeader.NumBitsPerPixel -width $sf2object.subject.width -height $sf2object.subject.height
# 	# $newBmpfile.pixelArray=get-pixelArray -bmpfile $bmpfile -x ($framePos.x+$sf2object.subject.x) -y ($framePos.y+$sf2object.subject.y) -width $sf2object.subject.width -height $sf2object.subject.height
# 	# $NewBmpfile.dibheader.NumColors=$bmpfile.dibheader.numcolors
# 	# $NewBmpfile.colorTable=$bmpfile.colortable
# 	# write-verbose "$($sf2object.name).frame$frame"
# #	$Newbmpfile=export-bmpfile -bmpfile $newbmpfile -path .\jemoeder.bmp
# #	$NewBmpfile



<#
$colortable=$null
#create ColorIndexTable for 24bpp
if (-not $colortable)
{	$ColorTable=@{}
	for ($y=0;$y -lt $bmpfile.height;$y++)
	{	$RowIndex=$bmpfile.bmpfileheader.PixelArrayOffset+($bmpfile.rowsize*$y)
		for ($x=0;$x -lt $bmpfile.width;$x++)
		{	#$rgb=0;0..2|%{$rgb+=[uint32]$bmpfile.rawdata[$rowindex+($x*3)+$_] -shl ($_*8)}
			$rgb=read-fromByteArray -data $bmpfile.rawdata -offset ($rowindex+$x*3) -size 3	
			if (-not $ColorTable[$rgb]) {$ColorTable[$rgb]=$true}
		}
	}
	$colortable.keys|%{'{0:x6}' -f $_}
	$global:colortable=$ColorTable
}

$Destination=[pscustomobject]@{screen=5;width=($dibheader.structure|where{$_.label -eq "width"}).value;height=($dibheader.structure|where{$_.label -eq "height"}).value;bytesPerPixel=0.5}
$OutputData=[byte[]]::new($destination.width*$destination.height*$destination.bytesPerPixel)
write-verbose "Destination size: $($outputData.length) bytes"
#>

exit
