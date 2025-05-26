#Shadow@Fuzzylogic
#20250525-20250524


[CmdletBinding()]
param
(	$bmpPath="C:\Users\rvand\SynologyDrive\Usas2\Graphics\Diversen\u2fonts8x8.4bpp.bmp", #"C:\Users\rvand\SynologyDrive\Usas2\Graphics\Diversen\u2fonts8x12.4bpp.bmp",
	[switch]$exportAsfonFile,[switch]$exportAsCh8File,$exportPath,
	$canvasX=0,$canvasY=0,
	$frameWidth=8,$frameHeight=8,$totalFramesX=32,$totalFramesY=3,
	$startFramesX=0,$startFramesY=0,$numFramesX=$totalFramesX,$numFramesY=$totalFramesY,
	$transparentColor=0,$proportional=$true,$numBpp=1
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\bmpfile-functions.inc.ps1


#Convert one frame (char) to a byte stream in 1bpp format
function convert-PixelArrayTo1bpp
{   param
	(   $pixels,$width,$height,$transparentColor=0
	)
	$data=[byte[]]::new((($width-1 -shr 3)+1) *$height)
	$dstIndex=0;$numBytesWidth=[int]($width -shr 1)
	for ($y=0;$y -lt $height;$y++)
	{   [byte]$a=0
		for ($x=0;$x -lt $width; $x++)
		{   $a=$a -shl 1
			$srcIndex=[int]($y*$numBytesWidth+[int]($x -shr 1))
			$byte=$pixels[$srcIndex]
			if ($x -band 1) {$bits=$byte -band 0x0f} else {$bits=($byte -band 0xf0) -shr 4}
			if ($bits -ne $transparentColor) {$a=$a -bor 1}
		}
		$data[$dstIndex]=$a;$dstIndex++
	}
	return ,$data
}

#Get the maximum width of a char (1 byte sequence)
function get-1bppCharWidth
{   param ($data)
	$charWidth=8;[byte]$a=0;
	foreach ($byte in $data){$a=$a -bor $byte} #Aggregate all bytes
	for ($b=8;$b -ne 0;$b--) #scan byte from right to left
	{   if (-not ($a -band 1)) {$charWidth--;}
		$a=$a -shr 1
	}
	return $charwidth
}


#Font File structures
$fonFileStruct=
@{	header=[pscustomobject]@{offset=0x00;size=8;label="Header";default=0};
	data=[pscustomobject]@{offset=0x08;size=-1;label="GlyphData";default=0};
}
$fonHeaderStruct=
@(	[pscustomobject]@{offset=0x00;size=1;label="ATR";default=0};
	[pscustomobject]@{offset=0x01;size=1;label="NUM";default=0};
	[pscustomobject]@{offset=0x02;size=1;label="WID";default=0};
	[pscustomobject]@{offset=0x03;size=1;label="HEI";default=0};
	[pscustomobject]@{offset=0x04;size=2;label="SIZ";default=0};
	[pscustomobject]@{offset=0x06;size=2;label="USR";default=0};
)


##### Main #####
$frameWidth=[byte]$frameWidth+1 -band 0xfe #make sure to use even width
if ($numBpp -notmatch "(1|4)") {write-error "Number of bits per pixel -nbpp can only be 1 or 4";exit}
if (-not ($global:bmpfile=$bmpfile=import-bmpFile -path $bmpPath)) {exit}
$numFrames=$numFramesX*$numFramesY
$frameSize=$numbpp/8*$frameWidth*$frameHeight+([int]$proportional)
write-verbose "Number of frames:$numFrames. FrameWidth:$framewidth. FrameHeight:$frameheight. Frame size:$framesize"
write-verbose "Bits per pixel:$numbpp. proportional:$([boolean]$proportional)."

$fonHeader=new-StructInstance -struct $fonHeaderStruct -name Header
$fonHeader.num=$numFrames;$fonHeader.wid=$framewidth;$fonHeader.hei=$frameheight;$fonHeader.siz=$frameSize;
if ($numbpp -eq "4") {$fonHeader.atr=$fonHeader.atr -bor 1}
if ($proportional) {$fonHeader.atr=$fonHeader.atr -bor 2}

$glyphsData=@()
for ($frameY=$startFramesY;$frameY -lt $startFramesY+$numFramesY;$frameY++)
{   for ($frameX=$startFramesX;$frameX -lt $startFramesX+$numFramesX;$frameX++)
	{   write-verbose "frame: $framex,$frameY"
		$x=$frameX*$frameWidth+$canvasX
		$y=$frameY*$frameHeight+$canvasY
		$pixels=get-pixelArray -bmpfile $bmpfile -x $x -y $y -width $frameWidth -height $frameHeight
		$charData=convert-PixelArrayTo1bpp -pixels $pixels -width $frameWidth -height $frameHeight -transparentColor $transparentColor
		if ($proportional) {$glyphsData=$glyphsData+(get-1bppCharWidth -data $chardata)}
		$glyphsData=$glyphsData+$chardata
	}
}
$fonFileHeaderData=[byte[]]::new($fonFileStruct.header.size)
write-structData -byteArray $fonFileHeaderData -struct $fonHeaderStruct -offset 0 -data $fonHeader
$fonFile=[byte[]]$fonFileHeaderData+[byte[]]$glyphsData
Write-verbose "File size:$($fonfile.length)"

if ($exportAsCh8File -and (-not $proportional) -and ($numframes -eq 96))
{   if (-not $exportpath) {$exportPath=".\$(split-path $bmppath -leaf).ch8"}
	write-verbose "Exporting .CH8 file to: $exportPath"
	$glyphsData|Set-Content -Path $exportpath -Encoding byte
} elseif ($exportAsfonFile)
{	if (-not $exportpath) {$exportPath=".\$(split-path $bmppath -leaf).fon"}
	write-verbose "Exporting .FON file to: $exportPath"
	$fonfile|Set-Content -Path $exportpath -Encoding byte
} else
{	$fonfile|Format-Hex
}

<#
.\convert-BmpToFont.ps1 -canvasX 0 -canvasY 0 -transparentColor 11 -exportPath C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\sidonia.ch8
.\convert-BmpToFont.ps1 -canvasX 0 -canvasY 24 -transparentColor 11 -exportPath C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\sidoniab.ch8
.\convert-BmpToFont.ps1 -bmppath "C:\Users\rvand\SynologyDrive\Usas2\Graphics\Diversen\u2fonts8x12.4bpp.bmp" -canvasX 0 -canvasY 0 -frameWidth 8 -frameHeight 11 -transparentColor 15 -exportPath C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\shiroki.ch8 -verbose
.\convert-BmpToFont.ps1 -bmppath "C:\Users\rvand\SynologyDrive\Usas2\Graphics\Diversen\u2fonts8x8.4bpp.bmp" -totalFramesX 32 -totalFramesY 3 -transparentColor 11 -numBpp 1 -proportional:$true -exportPath C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\sidonia.fon  -exportAsfonFile -verbose

#>