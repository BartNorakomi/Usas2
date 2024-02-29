
##### Includes #####
. .\tiled-functions.ps1


$ruinName="Pegu" #need to rip this one
$ruinId=4
if (-not $maps) {.\make-worldmap.ps1  -ruin $ruinId}
#$maps|where{$_.filename -match "as14"}
$mapsPath="C:\Users\$($env:username)\OneDrive\Usas2\maps"
$File="C:\Users\rvand\OneDrive\Usas2\maps\robert.tmx"
if (-not $robert) {[xml]$global:robert=get-content $file}

$mapWidth=$robert.map.width	#in tiles
$mapHeight=$robert.map.height	#in tiles
$roomWidth=38	#in tiles
$roomHeight=27	#in tiles
$marginX=1	#in tiles
$marginY=1	#in tiles
$tileset=$robert.map.tileset|where {$_.source -match $ruinName}
$layers=$robert.map.layer|where{$_.visible -ne 0 -and $_.name -ne "objects"}

# iterate through maps
foreach ($map in $maps)
{	$mapX=$map.x/8	#room start positions
	$mapy=$map.y/8
	$xml=new-TiledMap -width $roomwidth -height $roomheight
	$xml=add-TiledTileset -xml $xml -source $tileset.source -firstgid 1

	# iterate through layers
	foreach ($layer in $layers)
	{	$tiles=$layer.data.InnerText.split("`n")|select -skip 1 -First ($mapheight)
		#create a matrix
		for ($i=0;$i -lt $mapHeight;$i++) {$tiles[$i]=$tiles[$i].split(",")}

		#rip layer data
		$global:data=@()::new(38*27);$index=0
		for ($y=$mapY;$y -lt ($mapY+$roomHeight);$y++)
		{	for ($x=$mapX;$x -lt ($mapX+$roomWidth);$x++)
			{	$tile=$tiles[$y][$x]
				if ($tile -ne 0) {$tile=$tile-($tileset.firstgid)+1}
				$data[$index]=$tile #write-host "$tile," -NoNewLine	
				$index++
			}
		}
		$xml=add-TiledTileLayer -xml $xml -name $layer.name -data ($data -join(","))
	}
	
	#$global:xml=$xml
	"$mapspath\$($map.filename)"
	#set-content -Value $xml.OuterXml -Path "$mapspath\$($map.filename)"
}

#$data to raw
#$data=$inner.replace("`n","").split(",")|%{[uint16]$_}
	