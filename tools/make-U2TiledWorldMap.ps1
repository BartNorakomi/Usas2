# Create a Tiled.worldmap files and optional its maps
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231015-20250305

<#
required manifest properties:
 ruin.<identity>.name
 ruin.<identity>.ruinId
 ruin.<identity>.TiledTileset
 worldmap.global.sourcefile
 room.*
 tiledTileSet.<identity>.path
#>

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruinid')]$ruinId,	#ruin.UID ()
	[Parameter(ParameterSetName='ruinname')]$ruinName,	#ruin.name
	[Parameter(ParameterSetName='ruinIdentity')]$ruinIdentity, #IdentifierString
	$worldMapname,
	$marginX=8,
	$marginY=8,
	$sourceOffsetX=0,
	$sourceOffsetY=0,
	$mapWidth=38,
	$mapHeight=27,
	$TiledMapsLocation, #="C:\Users\$($env:username)\OneDrive\Usas2\maps",
	$targetLocation, #="$TiledMapsLocation\",
	$exportToPath,
	[switch]$createRoom,
	[switch]$openWorldMap=$false,
	[switch]$printWorldMap=$false,
	[switch]$forceOverWrite,
	[switch]$resetGlobals=$false,
	$masterMap, #="..\Usas2-WorldMap.csv",
	$usas2PropertiesFile="..\usas2-properties.csv"
)




##### Includes #####
. .\tiled-functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1

##### Global properties #####
if ($resetGlobals) {$global:usas2=$null}
$global:usas2=get-Usas2Globals
if (-not $mastermap) {$mastermap="..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile}
#write-verbose "input file: $masterMap"
if ($worldMapname) {write-verbose "output file: $worldMapFile"}
if (-not $tiledmapsLocation) {$tiledmapsLocation=get-U2TiledMapLocation} else {set-U2TiledMapLocation -path $TiledMapsLocation}
write-verbose "Tiled maps location: $tiledmapsLocation"
if (-not $targetLocation) {$targetLocation=$tiledmapsLocation}
$worldMapFile=$targetLocation.TrimEnd("\")+"\"+$worldMapname+".world"

##### Functions #####

# Return the worldmap as printable data
# Just a test function, to see if the map is still correct
# in:	WmMatrix=WorldMatrix data (get-u2roommatrix output)
#		$ruinIdFilter=optional filter for ruins. Default is no filter.
function print-worldmapMatrix
{	param ($wmmatrix,$ruinIdFilter=".*")
	$y=0
	foreach ($row in $wmMatrix)
	{	$x=0;$rowData=""
		foreach ($column in $row)
		{	$data="$($WmMatrix[$y][$x])" -band 0x1f #we'll skip roomtype here to make prettier print
			if (-not (($data -band 0x1f) -match $ruinIdFilter)) {$data=""}
			if ($data.length -eq 0 -or $data -eq 0) {$data="  "} else {$data="$data".PadLeft(2,"0")}
			$rowData+="$data "
			$x++
		}
		$rowdata
		$y++
	}
}

# Create a new Tiled map file
function new-Usas2RoomTiledMapFile
{	[CmdletBinding()]
	param
	(	$ruinId,$RoomType,$path	
	)
	$ruinManifest=get-u2ruin -id "^$ruinid$" #$usas2.ruin|where{$_.ruinid -eq $ruinId}
	$roomManifest=get-u2room -id $roomType #$usas2.room|where{$_.roomType -eq $roomType}
	$width=$roomManifest.width 
	$height=$roomManifest.height
	$tileSet=$ruinManifest.TiledTileset
	if (-not ($width -and $height -and $tileSet))
	{	write-error "[new-Usas2RoomTiledMapFile] Room manifest not (fully) defined for $($roomManifest.identity), cannot create room"
	} else
	{	write-verbose "[new-Usas2RoomTiledMapFile] Creating $path, width=$width, height=$height"
		$xml=new-TiledMap -width $width -height $height
		#Attach a TiledTileSet to the map
		$TileSetProps=$usas2.tiledtileset|where{$tileset -match $_.identity}
		$tileSetPath=$TileSetProps.path
		#Tileset overwrite for this roomType (like teleport room)?
		$hasSet=($usas2.TiledtileSet|where{$_.identity -eq $roomManifest.identity}).path
		if ($hasSet) {$tileSetPath=$hasSet}
		if (-not $tileSetPath)
		{	write-warning "[new-Usas2RoomTiledMapFile] No Tiled-TileSet defined for ruin $($ruinManifest.identity)-or room $($roomManifest.identity)"
		}	else
		{	write-verbose "[new-Usas2RoomTiledMapFile] Tiled-Tileset $tilesetPath"
			$xml=add-TiledMapTileset -map $xml -source $tileSetPath -firstgid 1
		}
		#add the default TileLayers
		$xml=add-TiledMapTileLayer -map $xml -name "bgShadow"
		$xml=add-TiledMapTileLayer -map $xml -name "bg"
		$xml=add-TiledMapTileLayer -map $xml -name "bgOrna"
		$xml=add-TiledMapTileLayer -map $xml -name "fg"
		#and write the file
		set-TiledMap -map $xml -path $path #   set-content -Value $xml.OuterXml -Path $path
	}
}

# Convert input data from the U2Worldmap.csv to tiled worldmap locations
# return an array of worldmap map objects ()
function convert-Usas2WorldMapToTiledWorldMap
{	param
	(	$WorldMapSource,$roomMatch=".*"
	)

	$global:roomMaps=get-roomMaps -mapsource $WorldMapSource #Return the masterMap as a array of map objects (all rooms)
	foreach ($roomMap in $roomMaps|where{$_.ruinId -match $roomMatch})
	{	$filename=$roomMap.name+".tmx"
		write-verbose "[convert-Usas2WorldMapToTiledWorldMap] name=$($roomMap.name), ruinId=$($roomMap.ruinid), roomId=$($roomMap.roomtype), filename=$filename"
		$ruinManifest=get-u2ruin -id "^$($roomMap.ruinid)$" #$usas2.ruin|where{$_.ruinid -eq $roomMap.ruinId}
		$roomManifest=get-u2room -id $roomMap.roomType #$usas2.room|where{$_.roomType -eq $roomMap.roomType}
		write-verbose "[convert-Usas2WorldMapToTiledWorldMap] Ruin name: $($ruinManifest.Name), Room name: $filename, Room name: $($roomManifest.identity)"
		$fileExist=test-path "$TiledMapsLocation\$filename"
		write-verbose "[convert-Usas2WorldMapToTiledWorldMap] File $TiledMapsLocation\$filename exist? $fileexist"
		if ($forceOverWrite -or (-not $fileExist -and $createRoom))
		{	new-Usas2RoomTiledMapFile -ruinId $roomMap.ruinId -roomType $roomMap.roomType -path "$TiledMapsLocation\$filename"
		}
		if (-not (test-path "$TiledMapsLocation\$filename"))	# test it again, in case it has just been created
		{	write-verbose "[convert-Usas2WorldMapToTiledWorldMap] $filename does not exist - skipping"
		} else
		{	write-verbose "[convert-Usas2WorldMapToTiledWorldMap] Adding room"
			new-TiledWorldMapMap -filename $filename -width ($mapWidth*8) -height ($mapHeight*8) -x ($roomMap.x*($mapWidth*8+$marginX)) -y ($roomMap.y*($mapHeight*8+$marginY))
		}
	}
}


##### main: #####

# If parameter "ruinName" was used, then resolve the ruinID
if ($ruinName) {$ruinId=($usas2.ruin|where{$_.name -match ("^("+($ruinname -join ("|"))+")$")}).ruinid}

#get the ruin manifest(s)
if ($ruinname)
{   if ($ruinName.gettype().IsArray) {$name=("^("+($ruinname -join ("|"))+")$")} else {$name="^$ruinname`$"}
    $ruinManifest=get-U2Ruin -name $name
}
elseif ($ruinId)
{   if ($ruinId.gettype().IsArray) {$id=("^("+($ruinId -join ("|"))+")$")} else {$id="^$ruinId`$"}
    $ruinManifest=get-U2Ruin -id $Id
}
elseif ($ruinIdentity)
{   if ($ruinIdentity.gettype().IsArray) {$identity=("^("+($ruinIdentity -join ("|"))+")$")} else {$identity="^$ruinIdentity`$"}
    $ruinManifest=get-U2Ruin -identity $identity
}
if (-not $mastermap) {write-error "Mastermap file not defined";exit}
write-verbose "RuinId: $($ruinManifest.ruinid). Mastermap: $mastermap"

$WorldMapSource=get-content $masterMap
$global:WorldMapSource=$WorldMapSource

# optionally, print the map to host
if ($printWorldMap)
{	$global:WmMatrix=get-U2roomMatrix -mapsource $WorldMapSource
	print-worldMapMatrix -wmmatrix $wmmatrix -ruinIdFilter ("^("+($ruinManifest.ruinId -join ("|"))+")$")
}
# Converting csv to tiled objects
$global:maps=convert-Usas2WorldMapToTiledWorldMap -WorldmapSource $WorldMapSource -roomMatch ("^("+($ruinManifest.ruinId -join ("|"))+")$")

# Create tiled.worldmap
if (-not $worldMapname)
{	write-verbose "No name defined, couldn't create worldmap."
}	else
{	write-verbose "Creating worldmap file $worldmapfile"
	$worldmap=new-TiledWorldMap -name $worldMapname -DefaultMapWidth=$mapWidth -DefaultMapHeight=$mapHeight
	$worldmap.maps=$maps
	$worldmap|convertto-json|set-content $worldMapFile
	if ($openWorldMap) {& $worldmapfile}
}

#Export all files to a specific location
if ($exportToPath)
{	$exportToPath=$exportToPath.TrimEnd("\")
	$dstPath=resolve-newPath -path $exportToPath
	if (-not (Test-path -path $dstPath))
	{	write-verbose "create export path $dstPath"
		New-Item -Path $dstPath -ItemType Directory
	}
	foreach ($map in $maps)
	{	$SrcFile="$TiledMapsLocation\$($map.fileName)"
		$dstFile="$dstPath\$($map.fileName)"
		copy-item $srcFile $dstfile
	}

}

<#
$p=(invoke-expression "write $($usas2.TiledWorldMap.defaultlocation[0])")
# DIR all files in maps object
$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps"
$maps.filename|%{gci $TiledMapsLocation"\"$_}
#$maps.filename|%{remove-item $TiledMapsLocation"\"$_}

#Fix invalid tilesets
.\make-worldmap.ps1 -ruin 6
foreach ($worldmapMap in $maps)
{	write "$tmxLocation\$($WorldMapMap.filename)"
	$map=get-TiledMap "$tmxLocation\$($WorldMapMap.filename)"
	$map|Get-TiledMapTileset|where{$_.firstgid -ne 1}|%{$_|remove-tiledMaptileset}
	$map|set-TiledMap -path "$tmxLocation\$($WorldMapMap.filename)"
}

%{$map=get-TiledMap $tmxLocation\$_;$map|Get-TiledMapTileset|where{$_.firstgid -ne 1}|%{$_|remove-tiledMaptileset};$map|set-tiledmap  $tmxLocation\$_}

# create specific sections
 .\make-U2TiledWorldMap.ps1 -ruinId 1,2,3,4,5,7,12 -masterMap ..\Usas2-Section1.csv -createRoom -resetGlobals -Verbose -worldMapname Section1
 
# Create set for Robert
.\make-U2TiledWorldMap.ps1 -ruinId 1 -TiledMapsLocation F:\Usas2TiledMaps -Verbose -createRoom -forceOverWrite -name pollux


#copy some lost maps (from old onedrive 20250304)
foreach ($map in ($roommaps|where{$_.ruinid -eq "9"})){copy-item "C:\Users\rvand\Downloads\usas2-maps\maps\$($map.name).tmx" "$tiledmapsLocation\$($map.name).tmx"}


#>
