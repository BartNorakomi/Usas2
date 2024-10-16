# Create a Tiled.worldmap files and optional its maps
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231015-20231128

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruinid')]$ruinId=1,
	[Parameter(ParameterSetName='ruinname')]$ruinName="",
	$name="",
	$marginX=8,
	$marginY=8,
	$sourceOffsetX=0,
	$sourceOffsetY=0,
	$mapWidth=38,
	$mapHeight=27,
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps",
	$targetLocation="$TiledMapsLocation\",
	[switch]$createRoom,
	[switch]$openWorldMap=$false,
	[switch]$printWorldMap=$false,
	[switch]$forceOverWrite,
	$masterMap, #="..\Usas2-WorldMap.csv",
	$usas2PropertiesFile="..\usas2-properties.csv"
)

$worldMapFile=$targetLocation+$name+".world"
write-verbose "input file: $masterMap"
write-verbose "output file: $worldMapFile"
write-verbose "maps location: $TiledMapsLocation"


##### Includes #####
. .\tiled-functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1

##### Global properties #####
$global:usas2=get-Usas2Globals
if (-not $mastermap) {$mastermap="..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile}

##### Functions #####

# Return the worldmap as printable data
# Just a test function, to see if the map is still correct
# in:	WmMatrix=WorldMatrix data (get-roommatrix output)
#		$ruinIdFilter=optional filter for ruins. Default is no filter.
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

# Create a new Tiled map file
function new-Usas2RoomTiledMapFile
{	[CmdletBinding()]
	param
	(	$ruinId,$RoomType,$path	
	)
	$ruinProps=$usas2.ruin|where{$_.ruinid -eq $ruinId}
	$roomProps=$usas2.room|where{$_.roomType -eq $roomType}
	$width=$roomProps.width 
	$height=$roomProps.height
	$tileSet=$ruinProps.Tileset
	
	if (-not ($width -and $height -and $tileSet))
	{	write-warning "Roomproperties not defined for $($roomProps.identity), cannot create room"
	} else
	{	write-verbose "Creating $path, width=$width, height=$height"
		$xml=new-TiledMap -width $width -height $height
		#Attach a TileSet to the map
		$TileSetProps=$usas2.tiledtileset|where{$tileset -match $_.identity}
		$tileSetPath=$TileSetProps.path
		#Tileset overwrite for this roomType (like teleport room)?
		$hasSet=($usas2.TiledtileSet|where{$_.identity -eq $roomProps.identity}).path
		if ($hasSet) {$tileSetPath=$hasSet}
		if (-not $tileSetPath)
		{	write-warning "No TileSet defined for ruin $($ruinprops.identity)-or room $($roomProps.identity)"
		}	else
		{	write-verbose "Tileset $tilesetPath"
			$xml=add-TiledTileset -map $xml -source $tileSetPath -firstgid 1
		}
		$xml=add-TiledTileLayer -map $xml
		set-content -Value $xml.OuterXml -Path $path
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
		$ruinProps=$usas2.ruin|where{$_.ruinid -eq $roomMap.ruinId}
		$roomProps=$usas2.room|where{$_.roomType -eq $roomMap.roomType}
		write-verbose "Ruin name: $($ruinProps.Name), Room name: $filename, Room type: $($roomProps.identity)"
		$fileExist=test-path "$TiledMapsLocation\$filename"
		write-verbose "File $filename exist? $fileexist"
		if ($forceOverWrite -or (-not $fileExist -and $createRoom))
		{	new-Usas2RoomTiledMapFile -ruinId $roomMap.ruinId -roomType $roomMap.roomType -path "$TiledMapsLocation\$filename"
		}
		if (-not (test-path "$TiledMapsLocation\$filename"))	# test it again, in case it has just been created
		{	write-verbose "$filename does not exist - skipping"
		} else
		{	write-verbose "Adding room"
			new-TiledWorldMapMap -filename $filename -width ($mapWidth*8) -height ($mapHeight*8) -x ($roomMap.x*($mapWidth*8+$marginX)) -y ($roomMap.y*($mapHeight*8+$marginY))
		}
	}
}


##### main: #####

# If parameter "ruinName" was used, then resolve the ruinID
if ($ruinName) {$ruinId=($usas2.ruin|where{$_.name -match ("^("+($ruinname -join ("|"))+")$")}).ruinid}
write-verbose "RuinId: $ruinid"

$WorldMapSource=get-content $masterMap

# optionally, print the map to host
if ($printWorldMap)
{	$global:WmMatrix=get-roomMatrix -mapsource $WorldMapSource
	print-worldMapMatrix -wmmatrix $wmmatrix -ruinIdFilter ("^("+($ruinId -join ("|"))+")$")
}

# Converting csv to tiled objects
$global:maps=convert-Usas2WorldMapToTiledWorldMap -WorldmapSource $WorldMapSource -roomMatch ("^("+($ruinId -join ("|"))+")$")

# Create tiled.worldmap
if (-not $name)
{	write-verbose "No name defined, couldn't create worldmap."
}	else
{	$worldmap=new-TiledWorldMap -name $name -DefaultMapWidth=$mapWidth -DefaultMapHeight=$mapHeight
	$worldmap.maps=$maps
	$worldmap|convertto-json|set-content $worldMapFile
	if ($openWorldMap) {& $worldmapfile}
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
	$map|Get-TiledTileSet|where{$_.firstgid -ne 1}|%{$_|remove-tiledtileset}
	$map|set-TiledMap -path "$tmxLocation\$($WorldMapMap.filename)"
}

%{$map=get-TiledMap $tmxLocation\$_;$map|Get-TiledTileSet|where{$_.firstgid -ne 1}|%{$_|remove-tiledtileset};$map|set-tiledmap  $tmxLocation\$_}
#>
