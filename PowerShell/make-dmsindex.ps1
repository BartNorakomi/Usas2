# Create DMS index from files
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231114-20231114

[CmdletBinding()]
param
(	$name="",
	$masterWorldMapFile="..\Usas2-WorldMap.csv",
	$usas2PropertiesFile="..\usas2-properties.csv"
)

##### Includes #####
#. .\tiled-functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1
. .\dms.ps1

##### Functions #####

function new-WorldMapMatrixRecordObject
{	
	return $WmMatrixRecord=@{block=0;address=0;engineType=1;tileSet=0;palette=0}
}

function new-WorldMapMatrixRecordBytes
{	
	return [byte[]](0,0,0,1,0,0)
	#+00 01 ROM block
	#+01 02 ROM address
	#+03 01 engineType. 1=regularRoom (38x27), 2=specialRoom (32x27)
	#+04 01 tiledata (gfx id)
	#+05 01 palette (pal id)
}

#Print the worldmap on screen with ruinIds
function print-worldmapMatrix
{	param ($wmmatrix,$ruinIdFilter=".*")
	$y=0
	foreach ($row in $wmMatrix)
	{	$x=0;$rowData=""
		foreach ($column in $row)
		{	$data="$($WmMatrix[$y][$x])"
			if (-not ($data -match $ruinIdFilter)) {$data=""}
			if ($data.length -eq 0) {$data="  "}
			if ($data.length -eq 1) {$data="0$data"}
			$rowData+="$data "
			$x++
		}
		$rowdata
		$y++
	}
}


#Get roomMapFileNames
function get-WorldMapRooms
{	param ($wmmatrix,$ruinIdFilter)
	$y=0
	foreach ($row in $wmMatrix)
	{	$x=0;$rowData=""
		foreach ($column in $row)
		{	$data="$($WmMatrix[$y][$x])"
			if ($data -match $ruinIdFilter)
			{	$name=get-roomName -x $x -y $y
				[pscustomobject]@{x=$x;y=$y;filename="$name.map.pck"}
			}
			$x++
		}
		$y++
	}
}


#Create a WorldMapMatrix binairy structure, equal to the "WorldMapDatCopiedToRam.asm" file.
#This is a one-time, temp file as intermediate migration setup
#in:	an existing DMS object, the worldmapmatrix, and optional a filter for which ruinrooms
#out:	a byte array of 50x50x6 bytes with matrix data
function get-WorldMapBinMatrix
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$Dms,
		$wmmatrix,$ruinIdFilter=".*"
	)
	$BinMatrix=[byte[]]::new(0)
	$y=0
	foreach ($row in $wmMatrix)
	{	$x=0;
		foreach ($column in $row)
		{	$data="$($WmMatrix[$y][$x])"
			$ruinId=$data-band0x1f;$roomType=$data-band0xe0
			if ($ruinId -match $ruinIdFilter)
			{	$name=get-roomName -x $x -y $y
				$path="..\maps\$name.map.pck"
				$numObject=0
				$alloc=$dms|add-dmsfile -datalistname WorldMapIndex -path $path -updateFileSpace -addlength $numObjects.length #add one more byte for numobjects
				$null=$dms|write-DmsFileSpace -data ([byte]$numObjects) #number of objects
				$address=$alloc.segment*$dms.segmentsize+0x8000
				$engineType=1
				$tileSet=0
				$palette=0
				$newRecord=($alloc.block,($address -band 255),($address -shr 8),$engineType,$tileset,$palette)
			} else
			{	$newRecord=new-WorldMapMatrixRecordBytes
			}
			$BinMatrix+=$newrecord
			$x++
		}
		$y++
	}
	return $BinMatrix
}


#$BinMatrix=[byte[]]:new(50*50*6)
#foreach ($this in $roomfiles)
#{	$alloc=$dms|add-dmsfile -datalistname WorldMapIndex -path "..\maps\$($this.filename)"#
#	$index+=$this.x,$this.y,$alloc.block,$alloc.segment#($alloc.segment*$dms.segmentsize#)
#}


##### Main: #####
$WorldmapSource=get-content $masterWorldMapFile
$usas2GlobalsCsv=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
$global:usas2Globals=convert-CsvToObject -objname usas2 -csv $usas2GlobalsCsv

$global:dms=new-dms -name U2WorldMapMatrix -BlockSize 16KB -numBlocks 4 -SegmentSize 128
$datalist=$dms|add-DmsDataList -name WorldMapIndex
$fileSpace=$dms|create-DmsFileSpace

$global:WmMatrix=get-roomMatrix -mapsource $WorldMapSource
#print-worldMapMatrix -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
$null=$dms|open-DmsFileSpace
$binMatrix=get-WorldMapBinMatrix -dms $dms -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
$null=$dms|close-DmsFileSpace 
#$binMatrix -join(",")
#$binmatrix.count
$null=Set-Content -Value $rawdata -Path "..\engine\WorldMapMatrix.dat" -Encoding Byte
$dms|save-dms

exit

$roomfiles=get-WorldMapRooms -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
#Create an Index
$index=[byte[]]::new(0) #@()
foreach ($this in $roomfiles)
{	$alloc=$dms|add-dmsfile -datalistname WorldMapIndex -path "..\maps\$($this.filename)"
	$index+=$this.x,$this.y,$alloc.block,$alloc.segment#($alloc.segment*$dms.segmentsize)
}
$index -join(",")
#$datalist.allocations



exit
##### Tests #####
$filename=".\filelist.txt"
$rawData=[byte[]]::new(16KB)
$file=get-item $filename
$stream=$file.openRead()
$stream.seek(0,0)
$stream.Read($rawData,0,32)
$stream.close()

;get methods
[io.file].GetMethods()|select name
#$rawData=[byte[]]::new(32)
#$rawData=[byte[]]@(0,1,2,3,4)
$string="jemoeder"
$bytesArr = [System.Text.Encoding]::UTF8.GetBytes($string)
$fs=[io.file]::create("C:\Users\rvand\GIT\Usas2\PowerShell\jemoeder.txt")
$fs.Write($bytesArr,0,$bytesArr.Length)
$fs.Write($rawdata,0,32)
$fs.close()
https://shellgeek.com/powershell-convert-string-to-byte-array/
https://learn.microsoft.com/en-us/dotnet/api/system.io.file.create?view=net-7.0


#Read the current WorldMapMatrix from the usas2.rom file, and save this as a .dat file
$romfile="..\Engine\Usas2.rom"
$datfile="C:\Users\rvand\GIT\Usas2\Engine\WmMatrix.dat"
$block=0xa3
$fs=[io.file]::OpenRead((resolve-path $romfile))
$rawData=[byte[]]::new(16KB)
$fs.seek($block*16KB,0)
$fs.read($rawdata,0,16KB)
$fs.close()

$fs=[io.file]::create($DatFile)
$fs.Write($RawData,0,$RawData.Length)
$fs.close()


#open existing for write
#[System.IO.File]::Open($Item,'Open','Write')
