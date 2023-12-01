# Create DSM index from files
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231114-20231128

[CmdletBinding()]
param
(	$name="",
	$dsmName="Usas2.Rom.dsm",
	$masterWorldMapFile, #="..\Usas2-WorldMap.csv",
	$usas2PropertiesFile="..\usas2-properties.csv",
	[Parameter(Mandatory)]$indexType
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1


##### Global properties #####
$global:usas2=get-Usas2Globals
if (-not $masterWorldMapFile) {$masterWorldMapFile="..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile}


##### Functions #####

# 20231123: Temp function for matrix file, which we're gonna replace later 
function new-WorldMapMatrixRecordObject
{	
	return $WmMatrixRecord=@{block=0;address=0;engineType=1;tileSet=0;palette=0}
}


# ROOM MAP FILE INDEX
# return a WorldMap index of the files in a datalist as byte array of records (id(xxyy)[16],block[8],segment[8]) 
function get-WorldMapRoomIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName=".*"
	)
	$IndexRecordLength=4
	$datalist=get-dsmdatalist -dsm $dsm -name $datalistName
	#$numIndexRecords=$datalist.allocations.count
	if ($datalist.allocations)
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
write-verbose $dsmname
write-verbose "IndexType: $indexType"
exit

if	(-not ($dsm=load-dsm -path "$dsmname" -ErrorAction SilentlyContinue))
{	$DSM=new-DSM -name $dsmName -BlockSize 16KB -numBlocks 8 -SegmentSize 128
}


switch ($indexType)
{	maps
	{	# MAPS index
		$dataListName="WorldMap"
		$datalist=$DSM|add-DSMDataList -name $dataListName
		$global:indexRecords=get-WorldMapRoomIndex -dsm $dsm -datalistname $dataListName
		#$indexRecords|format-hex
		$null=Set-Content -Value $indexRecords -Path "$(resolve-path ".\")\$($DSMname).$datalistname.$dsmIndexFilenameExtention" -Encoding Byte
	}
}

#save-dsm $dsm
#$global:dsm=$dsm
exit



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


<#
brainstew

-get a list of roommap files
-put/replace in dsm, datalist, and filestore
-make index, save

#>