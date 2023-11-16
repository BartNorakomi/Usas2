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

function new-WorldMapMatrixRecord
{	
	return $WmMatrixRecord=@{block=0;address=0;engineType=1;tileSet=0;palette=0}
	#+00 ROM block
	#+01 ROM address
	#+03 engineType. 1=regularRoom (38x27), 2=specialRoom (32x27)
	#+04 tiledata (gfx id)
	#+05 palette (pal id)
}

#Print the worldmap on screen with ruinIds
function print-worldmap
{	param ($wmmatrix,$ruinIdFilter)
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

##### Main: #####
$WorldmapSource=get-content $masterWorldMapFile
$usas2GlobalsCsv=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
$global:usas2Globals=convert-CsvToObject -objname usas2 -csv $usas2GlobalsCsv
$global:dms=new-dms -name U2WorldMapMatrix -BlockSize 16KB -numBlocks 8 -SegmentSize 512

$global:WmMatrix=get-roomMatrix -mapsource $WorldMapSource
#print-worldMap -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
$roomfiles=get-WorldMapRooms -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
$datalist=$dms|add-DmsDataList -name WorldMapIndex
$index=@()
foreach ($this in $roomfiles)
{	$alloc=$dms|add-dmsfile -datalistname WorldMapIndex -path "..\maps\$($this.filename)"
	$index+=($this.x*256+$this.y),$alloc.block,($alloc.segment*$dms.segmentsize)
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
