# Create a Tiled.worldmap files and optional its maps
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231015-20231108

[CmdletBinding()]
param
(	$name="",
	$masterMap="..\Usas2-WorldMap.csv",
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps",
	$targetLocation="$TiledMapsLocation\",
	$marginX=8,
	$marginY=8,
	$sourceOffsetX=0,
	$sourceOffsetY=0,
	$mapWidth=38,
	$mapHeight=27,
	[Parameter(ParameterSetName='ruinid',Mandatory)]$ruin=1,
	[Parameter(ParameterSetName='ruinname',Mandatory)]$ruinName="",
	[switch]$createRoom,
	[switch]$openWorldMap=$false,
	[switch]$forceOverWrite
)

$worldMapFile=$targetLocation+$name+".world"
write-verbose "input file: $masterMap"
write-verbose "output file: $worldMapFile"
write-verbose "maps location: $TiledMapsLocation"


##### Includes #####
. .\tiled-functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1

##### Functions #####

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
		{	write-warning "No TileSet defined for room $($roomProps.identity)"
		}	else
		{	write-verbose "Tileset $tilesetPath"
			$xml=add-TiledTileset -map $xml -source $tileSetPath -firstgid 1
		}
		$xml=add-TiledTileLayer -map $xml
		set-content -Value $xml.OuterXml -Path $path
	}
}

#Convert input data to WorldMap objects
#return an array of worldmap map objects
function convert-Usas2WorldMapToTiledWorldMap
{	param
	(	$mapsource,$roomMatch=".*"
	)

	$global:roomMaps=get-roomMaps -mapsource $mapsource
	foreach ($roomMap in $roomMaps|where{$_.ruinId -match $roomMatch})
	{	$filename=$roomMap.name+".tmx"
		$ruinProps=$usas2.ruin|where{$_.ruinid -eq $roomMap.ruinId}
		$roomProps=$usas2.room|where{$_.roomType -eq $roomMap.roomType}
		write-verbose "Ruin name: $($ruinProps.Name), Room name: $filename, Room type: $($roomProps.identity)"
		$fileExist=test-path "$TiledMapsLocation\$filename"
		if ($forceOverWrite -or (-not (test-path "$TiledMapsLocation\$filename") -and $createRoom))
		{	new-Usas2RoomTiledMapFile -ruinId $roomMap.ruinId -roomType $roomMap.roomType -path "$TiledMapsLocation\$filename"
		}
		if (-not (test-path "$TiledMapsLocation\$filename"))
		{	write-verbose "$filename does not exist - skipping"
		} else
		{	write-verbose "Adding room"
			new-TiledWorldMapMap -filename $filename -width ($mapWidth*8) -height ($mapHeight*8) -x ($roomMap.x*($mapWidth*8+$marginX)) -y ($roomMap.y*($mapHeight*8+$marginY))
		}
	}
}

$mapSource=get-content $masterMap
$usas2PropertiesFile="..\usas2-properties.csv"
$usas2Properties=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
$global:usas2=convert-CsvToObject -objname usas2 -csv $usas2Properties

if ($ruinName)
{	$ruin=($usas2.ruin|where{$_.name -match ("^("+($ruinname -join ("|"))+")$")}).ruinid
}

$global:maps=convert-Usas2WorldMapToTiledWorldMap -mapSource $mapSource -roomMatch ("^("+($ruin -join ("|"))+")$")
$worldmap=new-TiledWorldMap -name $name -DefaultMapWidth=$mapWidth -DefaultMapHeight=$mapHeight
$worldmap.maps=$maps
$global:worldmap=$worldmap

if (-not $name)
{	write-warning "No name defined, couldn't create worldmap."
}	else
{	$worldmap|convertto-json|set-content $worldMapFile
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
