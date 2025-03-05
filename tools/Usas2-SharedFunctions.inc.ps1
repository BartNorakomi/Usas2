# Usas2 shared functions
# shadow@fuzzylogic
# 20231024-20250225

[CmdletBinding()]
param
(	[switch]$getglobals,[switch]$test2
)

##### Includes #####
. .\DSM.ps1


# 20240729
# #Resolve/convert a path to a new file
# function resolve-newPath
# {	param ($path)
# 	return join-path -path (convert-path (split-path -Path $path -Parent)) -ChildPath (split-path -path $path -leaf)
# }
#Resolve-path but without test-path (making non existing paths possible)
#https://blog.danskingdom.com/Resolve-PowerShell-paths-that-do-not-exist/
function resolve-NewPath
{	param (	$path)
	return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)	
}

#fill every array index with value $value
function fill-array
{	param ($array,$value)
	for ($i=0;$i -lt $array.length;$i++){$array[$i]=$value}
}



# 20240106
# Write verbose if global parameter $verboseMore=$true
function write-verboseMore
{	param ([Parameter(Mandatory, Position=0,ValueFromPipeline)]$message)
	if ($verboseMore) {write-verbose $message}
}

# 20231101
# Create and return an Object (with empty properties)
function new-CustomObject
{	param ($name,$propertyNames)
	$o=[PSCustomObject]@{ObjectName=$name}
	$propertyNames|%{$o|add-member NoteProperty $_ $null}
	return $o
}

# 20231101
# Return a hash table of property=value from CSV records (e.g. globalProperties)
function new-CsvHash
{	param ($CsvRecord)
	$hash=@{};$CsvRecord|%{$hash+=@{$_.propertyname=$_.propertyvalue}}
	return $Hash
}

# 20231101
# Return an object created out of CSV records (e.g. globalproperties)
#the CSV should have "name","identiy","propertyname","propertyvalue" records
function convert-CsvToObject
{	param ($objname="Default",$csv)

	#Create root object
	$names=$csv.name|select -Unique
	$rootObj=new-CustomObject -propertyNames $names -name $objname

	#Create child objects
	foreach ($name in $names)
	{	$nameRecords=$csv|where{$_.name -eq $name}
		$nameIdentities=$nameRecords.identity.tolower()|where{$_ -notmatch "(\*|\(|\)|\||\\)"}|select -Unique
		$rootObj.$name=@()
		foreach ($identity in $nameIdentities)
		{ 
			$identityRecords=$nameRecords|where{$Identity -match "^"+$_.identity+"$"}
			#$identityRecords=$nameRecords|where{$Identity -match $_.identity}
			$identityHash=new-CsvHash -CsvRecord $identityRecords
			$identityHash+=@{Identity=$identity}
			$rootObj.$name+=[pscustomobject]$identityHash
		}
	}
	return $rootObj
}




##### USAS2 specific Functions #####
$WorldMapColumnNames="AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ" -split(" ")

#20250225
#Create Usas2 registry path
function new-U2RegistryPath
{	$path="registry::HKEY_CURRENT_USER\SOFTWARE\TeamNxt\Usas2"
	#remove-item -path $path
	if (-not (Test-Path -Path $path)) {$null=new-item -Path $path -ItemType Directory -Force}
	return $path
}

#20250225
#Add an item to the Usas2 registry
function new-U2RegistryItem
{	param ($name,$value)
	$path=new-U2RegistryPath
	set-ItemProperty -path $path -Name $name -value $value
}
	
#20250225
#Get an item from the Usas2 registry
function get-U2RegistryItem
{	param ($name)
	$path=new-U2RegistryPath
	(Get-ItemProperty -Path $path -name $name -ErrorAction SilentlyContinue).$name
}

function set-U2TiledMapLocation
{	param ($path)
	new-U2RegistryItem -name TiledMapLocation -Value $path 
}
function get-U2TiledMapLocation
{	$path=get-U2RegistryItem -name TiledMapLocation 
	if (-not $path) {$path="."}
	return $path
}


# Manifest
function get-Usas2Globals
{	param ([string]$usas2PropertiesFile="..\usas2-properties.csv", [switch]$force)
	if (-not ($usas2.objectname -eq "usas2") -or $force)
	{	write-verbose "Loading globals"
		$usas2Properties=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
		$global:usas2=convert-CsvToObject -objname usas2 -csv $usas2Properties
	}
return $usas2
}


# Manifest
#Get a file manifest
function get-U2file
{	param
	(	[Parameter(ParameterSetName='identity')]$identity,
		[Parameter(ParameterSetName='path')]$path,
		$fileType="*"
	)

	if ($identity) {$fileManifest=$usas2.file|where{$_.identity -like $identity -and $_.dataTypeId -like $fileType}}
	elseif ($path) {$fileManifest=$usas2.file|where{$_.path -like $path -and $_.dataTypeId -like $fileType}}

	return $fileManifest
}


# Manifest
#Get a tileset manifest
function get-U2Tileset
{	param
	(	[Parameter(ParameterSetName='identity')]$identity,
		[Parameter(ParameterSetName='id')]$id
	)
	if ($identity -ne $null) {$Manifest=$usas2.tileset|where{$_.identity -match $identity}}
	elseif ($id -ne $null) {$Manifest=$usas2.tileset|where{$_.Id -eq $id}}
	return $Manifest
}


# Manifest
#Get a ruin manifest
function get-U2Ruin
{	param
	(	[Parameter(ParameterSetName='identity')]$identity,
		[Parameter(ParameterSetName='id')]$id,
		[Parameter(ParameterSetName='name')]$name
	)
	if ($identity -ne $null) {$Manifest=$usas2.ruin|where{$_.identity -match $identity}}
	elseif ($id -ne $null) {$Manifest=$usas2.ruin|where{$_.ruinId -match $id}}
	elseif ($name -ne $null) {$Manifest=$usas2.ruin|where{$_.name -match $name}}

	return $Manifest
}

# Manifest
#Get a room manifest
function get-U2Room
{	param
	(	[Parameter(ParameterSetName='identity')]$identity,
		[Parameter(ParameterSetName='id')]$id,
		[Parameter(ParameterSetName='name')]$name
	)
	if ($identity -ne $null) {$Manifest=$usas2.room|where{$_.identity -match $identity}}
	elseif ($id -ne $null) {$Manifest=$usas2.room|where{$_.roomType -eq $id}}
	elseif ($name -ne $null) {$Manifest=$usas2.room|where{$_.name -match $name}}
	return $Manifest
}


# Worldmap Room
# return roomName located at(x,y)
function get-roomName
{	param ($x,$y)
	$Y++
	return $WorldMapColumnNames[$x]+([string]$Y).PadLeft(2,"0")
}

# Worldmap Room
# return the coordinates of a room by its name
# in:	roomName (filename base)
#out:	object (x,y)
function get-roomLocation
{	param ($name)
	#write-verbose "get-roomlocation for $name"
	$x=$WorldMapColumnNames.IndexOf($name.substring(0,2).toupper())
	$y=[uint32]$name.substring(2,2)-1
	return [pscustomobject]@{x=$x;y=$y}
}

#[Worldmap]
#Get a worldmap (from source file)
function get-u2WorldMap
{	param ($identity="global")
	$WorldMapSource=get-content ("..\"+($usas2.worldmap|where{$_.identity -eq $identity}).sourcefile)
	return $WorldMapSource
}


# WorldMap
#Return the WorldMap (CSV data) as a matrix[y][x]=roomType/RuinId
function get-U2roomMatrix
{	param ($mapsource)
	$roomMatrix=$mapsource;$index=0
	foreach ($row in $mapSource)
	{	$roomMatrix[$index]=$roomMatrix[$index].split("`t")
		$index++
	}
	return $roomMatrix
}

# WorldMap
#Return the WorldMap (CSV data) as a hashTable Index [filename]=roomType/RuinId
function get-roomHashTable
{	param ($mapsource,$sourceOffsetX=0,$sourceOffsetY=0)
	$y=-$sourceOffsetY
	foreach ($row in $mapSource)
	{	$x=-$sourceOffsetX
		forEach ($column in $row.split("`t"))
		{	#write-host $column
			if ($column)
			{	$roomname=get-roomName -x $x -y $y
				@{$roomName=$column} #[pscustomobject]@{ruinId=$column-band0x1f;roomType=$colum-band0xe0;x=$x;y=$y}}
			}
			$x++
		}
		$y++
	}
}

# WorldMap
# Return the WorldMap (CSV data) as a array of map objects
# in:	mapsource=CSV input data
#		optional: X/Y offsets if the CSV matrix data doesn't start at 0,0
# out:	Array of object (roomname,ruinId,roomType,XposWorldmap,YposWorldmap)
function get-roomMaps
{	param ($mapsource,$sourceOffsetX=0,$sourceOffsetY=0)
	$y=-$sourceOffsetY
	foreach ($row in $mapSource)
	{	$x=-$sourceOffsetX
		forEach ($column in $row.split("`t"))
		{	#write-verbose $column
			if ($column)
			{	$roomname=get-roomName -x $x -y $y
				[pscustomobject]@{name=$roomname;ruinId=$column-band0x1f;roomType=$column-band0xe0;x=$x;y=$y}
			}
			$x++
		}
		$y++
	}
}

# WorldMap
# Get WorldMapRooms > same as above, but with some presets and a filter on ruin and room
function get-U2WorldMapRooms
{	param ($ruinId=".*",$roomTypeId=".*",$roomName=".*")
	$WorldMapSource=get-u2WorldMap
	$roomMaps=get-roommaps -mapsource $WorldMapSource
	$roomMaps|where{($_.ruinId -match $ruinId) -and ($_.roomType -match $roomTypeId) -and ($_.name -match $roomName)}
}



# ROOM MAP FILE INDEX FOR ROM 20231201
# return a WorldMap index of the files in a datalist as byte array of records (id(xxyy)[16],block[8],segment[8]) 
function get-U2WorldMapRomIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName="WorldMap"
	)

	#ROM:roomindex
	$indexManifest=$usas2.index|where{$_.identity -eq "rooms"}
	$indexNumRec=[uint32]$indexManifest.numrec;$indexRecLen=[uint32]$indexManifest.reclen;$indexSize=$indexNumRec*$indexRecLen;$indexDefaultId=0xff
	$indexIdOffset=0;$indexBlockOffset=2;$indexSegmentOffset=3

	$datalist=get-dsmdatalist -dsm $dsm -name $datalistName
	if ($datalist.allocations)
	{	$indexRecords=[byte[]]::new($indexSize);fill-array -array $indexRecords -value $indexDefaultId
		$index=0
		foreach ($this in $datalist.allocations)
		{	$location=get-roomLocation $this.name.substring(0,4)
			$indexRecords[$index+$indexIdOffset+0]=[byte]$location.x
			$indexRecords[$index+$indexIdOffset+1]=[byte]$location.y
			$indexRecords[$index+$indexBlockOffset+0]=[byte]$this.block
			$indexRecords[$index+$indexSegmentOffset+0]=[byte]$this.segment
			$index+=$indexRecLen
		}
	}
	return ,$indexRecords #.toarray()
}


#Return the file claims for a given file
#20241208
#in: DSM, fileIdentity
function get-u2FileClaim
{	param ([Parameter(Mandatory,ValueFromPipeline)]$DSM,$fileIdentity)
	if ($file=get-u2file -identity $fileIdentity)
	{	$dataType=$usas2.datatype|where{$_.id -eq $file.dataTypeId}
		$datalist=get-dsmdatalist -dsm $dsm -name $dataType.dsmDataList
		$claims=$datalist.allocations|where{$_.name -eq (split-path -path $file.path -leaf)}
		#write-verbose "[get-u2FileClaim] $fileIdentity $claims"
	}
	return ,$claims
}


#create a ROM FileIndex from collection of items (like TileSet)
#20241208
function new-U2RomFileIndex
{	param	([Parameter(Mandatory,ValueFromPipeline)]$DSM,$collection
			)

	$indexNumRec=($collection|measure -Maximum -Property id).maximum + 1
	$fileIndexPointerTable=[byte[]]::new($indexNumRec*2) #pointers are 2bytes (16bit)
	$fileIndexPartsTable=[System.Collections.Generic.List[byte]]::new()
	write-verbose "Index number of entries: $indexNumRec"

	for ($index=0;$index -lt $indexNumRec;$index++)
	{	#Update the index pointer table by adding the current recordAddress+pointerTableLength(=offset to data)
		$pointer=$fileIndexPointerTable.Length+$fileIndexPartsTable.count
		$fileIndexPointerTable[$index*2]=$pointer -band 255	#L
		$fileIndexPointerTable[$index*2+1]=$pointer -shr 8	#H

		#Add file claims to the index table, if any
		$this=$collection|where{$_.id -eq $index}
		$claims=$null;$claims=get-u2FileClaim -dsm $dsm -fileIdentity $this.file
		$parts=($claims|measure).count
		# write-verbose "$index $($this.file) has $parts part(s) / index $h$l"
		$fileIndexPartsTable.add($parts) #write first byte=parts
		foreach ($claim in $claims|sort part)
		{	
			$fileIndexPartsTable.add($claim.block)
			$fileIndexPartsTable.add($claim.segment)
			$fileIndexPartsTable.add($claim.length)
		}
	}
	
	return [pscustomobject]@{indexPointerTable=$fileIndexPointerTable;indexPartsTable=$fileIndexPartsTable.toarray()}
}

#return the MasterIndexArray for other indexes (2bytes per record, 32 records)
function new-u2RomMasterFileIndex
{	$datalist=get-DSMDataList -dsm $dsm -name "index"
	
	$collection=$usas2.datatype
	$indexNumRec=($collection|measure -Maximum -Property id).maximum + 1
	
	$wordTable=[byte[]]::new($indexNumRec*2)
	
	for ($index=0;$index -lt $indexNumRec;$index++)
	{	
		$dataType=$collection|where{$_.id -eq $index}
		write-verbose "$datatype"
		if (-not $datatype.dsmdatalist)
		{	$alloc=[pscustomobject]@{block=0;segment=0;}
		} else
		{	$alloc=get-DsmDataListAllocation -dataList $datalist -name $datatype.dsmDatalist
		}
		$wordTable[$index*2]=$alloc.block
		$wordTable[$index*2+1]=$alloc.segment
	}
	return ,$wordtable
}


if ($getglobals) {$usas2=get-Usas2Globals -verbose -force}
if (-not $test2) {Exit}
(new-u2RomMasterFileIndex) -join (",")
exit

#test:indexes
$datalistName="index"
$datalist=add-DSMDataList -dsm $dsm -name $datalistname

$collectionName="tileset"
# $collectionName="areasign"
$fileIndex=new-U2RomFileIndex -DSM $dsm -collection $usas2.$collectionName
# $global:fileindex=$fileindex
# write-verbose ($fileindex.indexPointerTable -join(","));
# write-verbose ($fileindex.indexPartsTable -join(","));
$data=$fileindex.indexPointerTable+$fileindex.indexPartsTable
write-verbose ($data -join(","));
exit
# $data -join (",")
# #replace existing allocation and datalist record
remove-dsmdata -dsm $dsm -datalist $datalist -name $collectionName
$alloc=add-DSMData -dsm $dsm -dataList $datalist -name $collectionName -part 0 -data $data

$masterIndex=new-u2RomMasterFileIndex
$masterIndex -join(",")


	exit


