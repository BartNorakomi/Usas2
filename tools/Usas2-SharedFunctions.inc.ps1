# Usas2 shared functions
# shadow@fuzzylogic 20231024-20241206

[CmdletBinding()]
param
(	[switch]$getglobals
)

#20240729
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



#20240106
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
	(	[Parameter(ParameterSetName='identity')]$identity="*",$fileType="*"
	)
	$fileManifest=$usas2.file|where{$_.identity -like $identity -and $_.fileTypeId -like $fileType}
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



# ROOM MAP FILE INDEX 20231201
# return a WorldMap index of the files in a datalist as byte array of records (id(xxyy)[16],block[8],segment[8]) 
function get-U2WorldMapRomIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName="WorldMap"
	)

	#ROM:roomindex
	$index=$usas2.index|where{$_.identity -eq "rooms"}
	$indexNumRec=[uint32]$index.numrec;$indexRecLen=[uint32]$index.reclen;$indexSize=$indexNumRec*$indexRecLen;$indexDefaultId=0xff
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

# BITMAP GFX INDEX 20231207
# return an index with tilesets
function get-U2TilesetRomIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName="TileSet"
	)

	#ROM:tilesetindex
	$indexManifest=$usas2.index|where{$_.identity -eq "tileset"}
	$indexNumRec=[uint32]$indexManifest.numrec;$indexRecLen=[uint32]$indexManifest.reclen;$indexSize=$indexNumRec*$indexRecLen;$indexDefaultId=0xff
	# $indexIdOffset=0;$indexBlockOffset=2;$indexSegmentOffset=3

	$datalist=get-dsmdatalist -dsm $dsm -name $datalistName
	# [System.Collections.Generic.List[byte]]
	$indexPointerTable=[byte[]]::new($indexSize)
	$indexRecords=[System.Collections.Generic.List[byte]]::new()
	[byte[]]$emptyIndexRecord=0,0

	for ($index=0;$index -lt $indexNumRec;$index++)
	{	$L=$indexRecords.count -band 255
		$H=$indexRecords.count -shr 8
		$indexPointerTable[$index*2]=$l
		$indexPointerTable[$index*2+1]=$h
		$tileset=get-u2TileSet -id $index # $usas2.tileset|where{$_.id -eq $index}
		$sc5File=(get-u2File -identity $tileset.file).path #($usas2.file|where{$_.identity -eq $tileset.file}).path
		if ($sc5File)
		{	$claims=$datalist.allocations|where{$_.name -eq (split-path -path $sc5file -leaf)}|sort part
			$parts=$claims.count
			write-verbose "[get-U2TilesetRomIndex] $($tileset.identity), index:$index, $($tileset.file)=$sc5file, Parts: $parts"
			$indexRecords.add(0)	#palette
			$indexRecords.add($parts)	#parts
			foreach ($claim in $claims)
			{	write-verbose "[get-U2TilesetRomIndex] Block: $($claim.block), segment:$($claim.segment)"
				$indexRecords.add($claim.block)
				$indexRecords.add($claim.segment)
			}
		} else
		{	$indexRecords.AddRange($emptyIndexRecord)			
		}
	}
	# return [pscustomobject]@{indexPointerTable=$indexPointerTable.toarray();index=$indexRecords.toarray()}
	return [pscustomobject]@{indexPointerTable=$indexPointerTable;index=$indexRecords.toarray()}
}


# #RuinPropertiesTable
# #Get Ruin Properties record by ruinId or idenity (name)
# function get-U2ruinProperties
# {	param
# 	(	[Parameter(ParameterSetName='identity',Mandatory)]$identity,
# 		[Parameter(ParameterSetName='ruinid',Mandatory)]$ruinid
# 	)
# 	if ($identity) {$ruins=$usas2.ruin|where{$_.identity -like $identity}}
# 	elseif ($ruinid) {$ruins=$usas2.ruin|where{$_.ruinid -like $ruinid}}
# 	foreach ($ruin in $ruins)
# 	{	#$ruin|select tileset,palette,music,name
# 		if (-not ($tilesetUid=($usas2.tileset|where{$_.identity -eq $ruin.tileset}).id)) {$tilesetUid=-1}
# 		if (-not ($paletteUid=($usas2.palette|where{$_.identity -eq $ruin.palette}).id)) {$paletteUid=-1}
# 		if (-not ($musicUid=($usas2.music|where{$_.identity -eq $ruin.music}).id)) {$musicUid=-1}
# 		[pscustomobject]@{id=[byte]$ruin.ruinid;name=[string]$ruin.name;tileset=[byte]$tilesetUid;palette=[byte]$paletteUid;music=[byte]$musicUid}
# 	}
# }


if ($getglobals) {$usas2=get-Usas2Globals -verbose -force}

 exit
#test
$global:usas2=$usas2

#update maps with tiledTileset





<#
#RuinPropertiesTable to code
foreach ($this in (get-U2ruinProperties -identity "karnimata"|sort id))
{	write "	DB	$($this.tileset),$($this.palette),$($this.music),`"$(($this.name+"             ").substring(0,13))`""
}
#>

<#
#bitmapIndex
$datalist=$dsm|add-DSMDataList -name BitMapGfx
$dsm|add-dsmfile -path "..\grapx\tilesheets\KarniMataTiles.sc5" -datalistname bitmapgfx
#$datalist.allocations|ft
$BitmapGfxIndex=get-U2TilesetRomIndex -dsm $dsm -Verbose
$BitmapGfxIndex.indexPointerTable -join(",")
$BitmapGfxIndex.index -join(",")
#>


