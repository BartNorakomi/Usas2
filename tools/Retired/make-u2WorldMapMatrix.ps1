# Create DSM index from files
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231114-20231114

[CmdletBinding()]
param
(	$name="",
	$masterWorldMapFile="..\Usas2-WorldMap.csv",
	$usas2PropertiesFile="..\usas2-properties.csv",
	$index
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1

##### Functions #####

# 20231123: Temp function for matrix file, which we're gonna replace later 
function new-WorldMapMatrixRecordObject
{	
	return $WmMatrixRecord=@{block=0;address=0;engineType=1;tileSet=0;palette=0}
}

# MATRIX - not after 20231123
# 20231123: Temp function for matrix file, which we're gonna replace later 
function new-WorldMapMatrixRecordBytes
{	
	return [byte[]](0,0,0,1,0,0)
	#+00 01 ROM block
	#+01 02 ROM address
	#+03 01 engineType. 1=regularRoom (38x27), 2=specialRoom (32x27)
	#+04 01 tiledata (gfx id)
	#+05 01 palette (pal id)
}

# MATRIX - not after 20231123
# Get roomMapFileNames
# in:	WorldMapMatrix
# out:	array of objects (x,y,filename)
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

# MATRIX - not after 20231123
# Create a WorldMapMatrix binairy structure, equal to the "WorldMapDatCopiedToRam.asm" file.
# This is a one-time, temp file as intermediate migration setup
# in:	an existing DSM object, the worldmapmatrix, and optional a filter for which ruinrooms
# out:	a byte array of 50x50x6 bytes with matrix data
function get-WorldMapBinMatrix
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,
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
				$alloc=$DSM|add-DSMfile -datalistname WorldMapIndex -path $path -updateFileSpace -addlength $numObjects.length #add one more byte for numobjects
				$null=$DSM|write-DSMFileSpace -data ([byte]$numObjects) #number of objects
				$address=$alloc.segment*$DSM.segmentsize+0x8000
				[byte]$engineType=1
				[byte]$tileSet=0
				[byte]$palette=0
				$newRecord=([byte]$alloc.block,[byte]($address -band 255),[byte]($address -shr 8),$engineType,$tileset,$palette)
				write-verbose ($newrecord -join(","))
			} else
			{	$newRecord=[byte]0,[byte]0,[byte]0,[byte]1,[byte]0,[byte]0 #new-WorldMapMatrixRecordBytes
			}
			$BinMatrix+=$newrecord
			$x++
		}
		$y++
	}
	return $BinMatrix
}


# ROOM MAP FILE INDEX
# return an index of the files in a datalist as byte array of records (id(xxyy)[16],block[8],segment[8]) 
function get-RoomMapIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName=".*"
	)
	$IndexRecordLength=4
	$numIndexRecords=$datalist.allocations.count
	if	($datalist=$dsm.datalist|where{$_.name -match $datalistname}) #.allocations.name)
	{	$indexRecords=[byte[]]::new(0) #::new($numIndexRecords*$IndexRecordLength)
		foreach ($this in $datalist.allocations)
		{	write-verbose $this.name
			$location=get-roomLocation $this.name.substring(0,4)
			[uint32]$id=$location.x*256+$location.y
			[byte]$block=$this.block
			[byte]$segment=$this.segment
			write-verbose "ID:$id, block:$block, seg:$segment"
			$indexRecords+=[byte]$location.x,[byte]$location.y,$block,$segment
		}
	}
	return $indexRecords
}


##### Main: #####
$WorldmapSource=get-content $masterWorldMapFile
#$usas2GlobalsCsv=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
#$global:usas2Globals=convert-CsvToObject -objname usas2 -csv $usas2GlobalsCsv

write-host "Index: $index"

if	($index -eq "maps")
{	# MAPS index
	$dsmName="U2WorldMap"
	$dataListName="WorldMapIndex"
	if	(test-path "$dsmname.dsm")
	{	$dsm=load-dsm -path "$dsmname"
	}	else
	{	$global:DSM=new-DSM -name $dsmName -BlockSize 16KB -numBlocks 4 -SegmentSize 128
	}
	$datalist=$DSM|add-DSMDataList -name $dataListName
	$global:indexRecords=get-RoomMapIndex -dsm $dsm -datalistname $dataListName
	$indexRecords|format-hex
	$null=Set-Content -Value $indexRecords -Path "$(resolve-path ".\")\$($DSMname).$dsmIndexFilenameExtention" -Encoding Byte
}


# WorldMapMatrix (one time, temp)
if	($index -eq "wmmatrix")
{	$global:DSM=new-DSM -name U2WorldMapMatrix -BlockSize 16KB -numBlocks 4 -SegmentSize 128
	$datalist=$DSM|add-DSMDataList -name WorldMapIndex
	$fileSpace=$DSM|create-DSMFileSpace
	$global:WmMatrix=get-u2roomMatrix -mapsource $WorldMapSource
	#print-worldMapMatrix -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
	$null=$DSM|open-DSMFileSpace
	$global:binMatrix=get-WorldMapBinMatrix -DSM $DSM -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
	$null=$DSM|close-DSMFileSpace 
	#$binMatrix -join(",")
	#$binmatrix.count
	$null=Set-Content -Value $binMatrix -Path "$(resolve-path ".\")\$($DSM.name).$dsmIndexFilenameExtention" -Encoding Byte
	$DSM|save-DSM
}

exit

$roomfiles=get-WorldMapRooms -wmmatrix $wmmatrix -ruinIdFilter "^(6)$"
#Create an Index
$index=[byte[]]::new(0) #@()
foreach ($this in $roomfiles)
{	$alloc=$DSM|add-DSMfile -datalistname WorldMapIndex -path "..\maps\$($this.filename)"
	$index+=$this.x,$this.y,$alloc.block,$alloc.segment#($alloc.segment*$DSM.segmentsize)
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
