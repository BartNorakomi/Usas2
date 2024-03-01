#concat two .sc5 files into one file
#for testing
[CmdletBinding()]
param
(	$file1="..\grapx\tilesheets\sKarniMata.SC5",
	$file2="..\grapx\tilesheets\sKarniMataBottom48Lines.SC5",
	$dstFile="$(resolve-path ".\")\KarniMataTiles.sc5"
)

$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}

<#
screen5 bitmap files with a 7 bytes header and pallette attached
  incbin "..\grapx\tilesheets\sKarniMata.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sKarniMataBottom48Lines.SC5",7,48 * 128 ;48 lines
#>
$headerSeek=0;$headerLength=7
$bitmapSeek=0+$headerLength;$bitmapLength=256*128
$paletteSeek=0x7680;$paletteLength=16*2


#Resolve-path but without test-path (making non existing paths possible)
#https://blog.danskingdom.com/Resolve-PowerShell-paths-that-do-not-exist/
function resolve-NewPath
{	param (	$path)
	return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)	
}


$fsDst=[io.file]::create((resolve-NewPath -path $dstfile))					#create destination file (eagerly)
$fsDst
#$rawData=[byte[]]::new($headerLength+$bitmapLength+$paletteLength)				#hdr, bitmap, pal
#$fsDst.write($rawdata,0,$rawdata.length)

#File 1 hdr+bitmap
$fs=[io.file]::OpenRead((resolve-path $file1))		#open file to read
#$header=[byte[]]::new($headerLength)				#header
#$fs.read($header,0,$header.length)		
#$fsDst.seek($headerSeek,0)
#$fsDst.write($header,0,$header.length)
$null=$fs.seek($bitmapSeek,0)
$rawData=[byte[]]::new(208*128)						#bitmap
$fs.read($rawdata,0,$rawdata.length)
$fsDst.write($rawdata,0,$rawdata.length)
$fs.close()

#file 2 bitmap
$fs=[io.file]::OpenRead((resolve-path $file2))		#open file to read
$null=$fs.seek($bitmapSeek,0)
$rawData=[byte[]]::new(48*128)
$fs.read($rawdata,0,$rawdata.length)
$fsDst.write($rawdata,0,$rawdata.length)

#file 2 pal
#$fs.seek(237*128,0)
#$rawData=[byte[]]::new($paletteLength)
#$fs.read($rawdata,0,$rawdata.length)
#$fsDst.write($rawdata,0,$rawdata.length)
$fs.close()

$fsDst.close()

