#A quick and dirty attempt to load BitMap and convert'm to MSX screen 5 files
#Shadow@Fuzzylogic
#20240304-20240304

[CmdletBinding()]
param
(	$path="C:\Users\rvand\GIT\Usas2\grapx\tilesheets\KarniMata.tiles.bmp"
)


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
<#
@(	[pscustomobject]@{order=0;mandatory=$true;name="BitMapFileHeader";offset=0x00;size=14};
	[pscustomobject]@{order=1;mandatory=$true;name="DibHeader";offset=0x0E;size=-1};
	[pscustomobject]@{order=2;mandatory=$false;name="ExtraBitMasks";offset=-1;size=-1};
	[pscustomobject]@{order=3;mandatory=$false;name="ColorTable";offset=-1;size=-1};
	[pscustomobject]@{order=4;mandatory=$false;name="Gap1";offset=-1;size=-1};
	[pscustomobject]@{order=5;mandatory=$true;name="PixelArray";offset=-1;size=-1};
	[pscustomobject]@{order=6;mandatory=$false;name="Gap2";offset=-1;size=-1};
	[pscustomobject]@{order=7;mandatory=$false;name="IccColorProfile";offset=-1;size=-1};
)#>
$BitMapFileHeaderStructure=
@(	[pscustomobject]@{order=0;mandatory=$true;name="Signature";offset=0x00;size=2};
	[pscustomobject]@{order=1;mandatory=$true;name="FileSize";offset=0x02;size=4};
	[pscustomobject]@{order=2;mandatory=$true;name="Reserved1";offset=0x06;size=2};
	[pscustomobject]@{order=3;mandatory=$true;name="Reserved2";offset=0x08;size=2};
	[pscustomobject]@{order=4;mandatory=$true;name="PixelArrayOffset";offset=0x0A;size=4};
)

$dibBITMAPCOREHEADER=
@(	[pscustomobject]@{offset=0x00;size=4;label="HeaderSize"};
	[pscustomobject]@{offset=0x04;size=2;label="Width"};
	[pscustomobject]@{offset=0x06;size=2;label="Height"};
	[pscustomobject]@{offset=0x08;size=2;label="NumColorPlanes"};
	[pscustomobject]@{offset=0x0A;size=2;label="NumBitsPerPixel"};
)

$dibBITMAPINFOHEADER=
@(	[pscustomobject]@{offset=0x00;size=4;label="HeaderSize"};
	[pscustomobject]@{offset=0x04;size=4;label="Width"};
	[pscustomobject]@{offset=0x08;size=4;label="Height"};
	[pscustomobject]@{offset=0x0C;size=2;label="NumColorPlanes"};
	[pscustomobject]@{offset=0x0E;size=2;label="NumBitsPerPixel"};
	[pscustomobject]@{offset=0x10;size=4;label="CompressionMethod"};
	[pscustomobject]@{offset=0x14;size=4;label="ImageSize"};
	[pscustomobject]@{offset=0x18;size=4;label="HorizontalResolution"};
	[pscustomobject]@{offset=0x1C;size=4;label="VerticalResolution"};
	[pscustomobject]@{offset=0x20;size=4;label="NumColors"};
	[pscustomobject]@{offset=0x24;size=4;label="NumImportantColors"};
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

$global:BmpFileStructure=$BmpFileStructure
$global:dibheaders=$dibheaders
$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}


##### Includes #####


##### Functions #####


##### Main: #####

#Open file
#exit
if (-not ($bmpfile=resolve-path $path)) {exit}
write-verbose "Source file: $bmpfile"
if (-not ($fs=[io.file]::OpenRead($bmpfile))) {exit}
write-verbose "Size: $("{0:X8}" -f $fs.length)"
write-verbose "Reading file"
$rawData=[byte[]]::new($fs.length) #($BitMapFileHeader.size)
[void]$fs.read($rawdata,0,$rawdata.length)
$fs.close()	

#Verbose header information
foreach ($record in $BitMapFileHeaderStructure|sort order)
{	$value=0;0..($record.size-1)|%{$value+=[uint32]$rawdata[$record.offset+$_] -shl ($_*8)}
	#write-verbose $record
	write-verbose "$($record.name): $("{0:X$($record.size*2)}" -f $value)"
}

#Determine DibHeader, and create an object with values
$record=$DibfileHeader=$BmpFileStructure.DibHeader
$DibHeaderSize=0;0..3|%{$DibHeaderSize+=[uint32]$rawdata[$record.offset+$_] -shl ($_*8)}
$DibHeader=($DibHeaders|where{$_.size -eq $DibHeaderSize}).psobject.copy()
write-verbose $Dibheader
#Add values to headerArray
foreach ($record in $DibHeader.structure|sort offset)
{	$value=0;0..($record.size-1)|%{$value+=[uint32]$rawdata[$record.offset+14+$_] -shl ($_*8)}
	write-verbose "$($record.label): $("{0:X$($record.size*2)}" -f $value)"
	$record|Add-Member -MemberType NoteProperty -Name 'value' -Value $value
}
$global:dibheader=$dibheader
$bitsperpixel=($dibheader.structure|where{$_.label -eq "numbitsperpixel"}).value
$width=($dibheader.structure|where{$_.label -eq "width"}).value
$height=($dibheader.structure|where{$_.label -eq "height"}).value
$RowSize=[math]::ceiling($bitsperpixel*$width/32)*4
write-verbose "Rowsize: $rowsize"

#$RowIndex=14+40+($rowsize*255)
#$rawdata[$rowindex..($rowindex+$bitsperpixel*$width)] -join(",")

#create ColorIndexTable
if (-not $colortable)
{	$ColorTable=@{}
	#$height=1
	for ($y=0;$y -lt $height;$y++)
	{	$RowIndex=14+40+($rowsize*$y)
		for ($x=0;$x -lt $width;$x++)
		{	$rgb=0;0..2|%{$rgb+=[uint32]$rawdata[$rowindex+($x*3)+$_] -shl ($_*8)}
			$ColorTable[$rgb]=$true
		}
	}
	$colortable.keys|%{'{0:x6}' -f $_}
	$global:colortable=$ColorTable
}

$Destination=[pscustomobject]@{screen=5;width=256;height=256;bytesPerPixel=0.5}
$OutputData=[byte[]]::new($destination.width*$destination.height*$destination.bytesPerPixel)
write-verbose "Destination size: $($outputData.length) bytes"

exit