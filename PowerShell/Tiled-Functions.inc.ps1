#Functions for Tiled
# shadow@fuzzylogic
# 20231018-20231024

[CmdletBinding()]
param
(	[switch]$test
)

#Load an existing map file
function get-TiledMap
{	param ($path)
	[xml]$map=Get-Content $path
	return $map
}

#Save map file
function set-TiledMap
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,Position=1)]$path
	)
	$null= set-content -Value $map.OuterXml -Path $path
}

#Return an empty Tiled.Map Object in XLM document format
function new-TiledMap
{	param
	(	$orientation="orthogonal",
	$renderorder="right-down",
	$width=38,
		$height=27,
		$tilewidth=8,
		$tileheight=8,
		$infinite=0
	)
	$map=New-Object System.Xml.XmlDocument
	$mapElement=$map.CreateElement("map")
	$null=$map.appendChild($mapElement)
	# Attributes
	$mapAttributes=[PSCustomObject]@{"version"="1.10";"tiledversion"="1.10.2";"orientation"=$orientation;"renderorder"=$renderorder;"width"=$width;"height"=$height;"tilewidth"=$tilewidth;"tileheight"=$tileheight;"infinite"=$infinite;"nextlayerid"=1;"nextobjectid"=1;}#"layer"=$layer;}
	$mapAttributes.psobject.properties|%{$mapElement.SetAttribute("$($_.name)","$($_.value)")}
	return $map
}


#Get properties of the map. note: name/type in regex format
function Get-TiledMapProperty
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		$name=".*",$type=".*"
	)
	return $map.map.properties.property|where{$_.name -match $name -and $_.type -match $type}
}


# Add a property to Tiled.Map 
function add-TiledMapProperty
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory)]$name,
		[Parameter(Mandatory)]$type,
		[Parameter(Mandatory)]$value
	)
	if ($property=$map.map.properties.property|where{$_.name -eq $name -and $_.type -eq $type})
	{	write-error "Map property already exists"
	}	else
	{	if (-not ($properties=$map.map.properties)) {$properties=$map.CreateElement("properties");[void]$map.map.AppendChild($properties)}
		$property=$map.CreateElement("property")
		$null=$property.SetAttribute("name",$name)
		$null=$property.SetAttribute("type",$type)
		$null=$property.SetAttribute("value",$value)
		[void]$properties.AppendChild($property)
		#if (-not $map.map.properties) {[void]$map.map.AppendChild($properties)}
		return $map
	}
}


#Set value to an existing map property
function set-TiledMapProperty
{	param
	(	[Parameter(ParameterSetName='name',Mandatory,Position=0,ValueFromPipeline)]$map,
		[Parameter(ParameterSetName='node',Mandatory,Position=0,ValueFromPipeline)]$property,
		[Parameter(ParameterSetName='name',Mandatory)][string]$name,
		[Parameter(ParameterSetName='name',Mandatory)]$type,
		[Parameter(Mandatory)]$value
	)
	if ($property)
	{	if (-not ($property.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a valid Property object"
		}	else
		{	$node=$property
		}
	}
	elseif ($name) {$node=$map.map.properties.property|where{$_.name -eq $name -and $_.type -eq $type}|select -first 1}
	
	if (-not $node)
	{	write-error "Property name $name not found"
	} else
	{	$node.value="$value"
		if ($map) {return $map} else {return $node}
	}
}


#Remove an existing map property
function remove-TiledMapProperty
{	param
	(	[Parameter(ParameterSetName='name',Mandatory,Position=0,ValueFromPipeline)]$map,
		[Parameter(ParameterSetName='node',Mandatory,Position=0,ValueFromPipeline)]$property,
		[Parameter(ParameterSetName='name',Mandatory)][string]$name,
		[Parameter(ParameterSetName='name',Mandatory)]$type
	)
	if ($property)
	{	if (-not ($property.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a valid Property object"
		}	else
		{	$node=$property
		}
	}
	else {$node=$map.map.properties.property|where{$_.name -eq $name -and $_.type -eq $type}|select -first 1}

	if (-not $node)
	{	write-error "Property name $name not found"
	} else
	{	[void]$node.parentnode.removeChild($node)
		if ($map) {return $map} else {return}
	}
	
}


#Get tileset(s) by source(regex) and/or firstgid(support wildcarts)
function Get-TiledTileSet
{	[CmdletBinding(DefaultParameterSetName='source')]
	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		$source=".*",
		$firstGid="*"
	) 
	return $map.map.TileSet|where{$_.firstgid -like $firstGid -and $_.source -match $source}
}


#Add a tileSet to an existing Tiled Map Object (XML)
function add-TiledTileset
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory)][string]$source,
		$firstgid=1
	)
	if ($tileset=$map.map.TileSet|where{$_.firstgid -eq $firstGid -and $_.source -eq $source})
	{	write-error "Tileset already exists"
	} else
	{	$tileset=$map.CreateElement("tileset")
		$null=$map.map.AppendChild($tileset)
		$null=$tileset.SetAttribute("firstgid",$firstgid)
		$null=$tileset.SetAttribute("source",$source)
		return $map
	}
}

#Set tileset value(s)
function set-TiledTileSet
{	[CmdletBinding(DefaultParameterSetName='tileset')]
	param
	(	[Parameter(Mandatory,ParameterSetName='source',Position=0,ValueFromPipeline)]
		[Parameter(Mandatory,ParameterSetName='firstGid',Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,ParameterSetName='tileset',Position=0,ValueFromPipeline)]$tileSet,
		[Parameter(ParameterSetName='source',Position=1)]$source,
		[Parameter(ParameterSetName='firstGid',Position=1)]$firstGid,
		[Parameter(ParameterSetName='tileset',Position=2)]
		[Parameter(ParameterSetName='source',Position=2)]
		[Parameter(ParameterSetName='firstGid',Position=2)]$newSource,
		[Parameter(ParameterSetName='tileset',Position=2)]
		[Parameter(ParameterSetName='source',Position=2)]
		[Parameter(ParameterSetName='firstGid',Position=2)]$newFirstGid
	)
	if ($tileset)
	{	if (-not ($tileset.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a valid Tileset object"
		}	else
		{	$node=$tileset
		}
	}
	elseif ($firstGid) {$node=$map|get-TiledTileset -firstGid $firstGid|select -first 1}
	elseif ($source) {$node=$map|get-TiledTileset -source $source|select -first 1}
	
	if ($node)
	{	if ($newSource) {$node.source=$newSource}
		if ($newFirstGid) {$node.firstGid=[string]$newFirstGid}
	}	
	if ($map) {return $map} else {return $node}
}

#Remove tileset
function Remove-TiledTileSet
{	[CmdletBinding(DefaultParameterSetName='tileset')]
	param
	(	[Parameter(Mandatory,ParameterSetName='source',Position=0,ValueFromPipeline)]
		[Parameter(Mandatory,ParameterSetName='firstGid',Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,ParameterSetName='tileset',Position=0,ValueFromPipeline)]$tileSet,
		[Parameter(ParameterSetName='source',Position=1)]$source=".*",
		[Parameter(ParameterSetName='firstGid',Position=1)]$firstGid
	) 
	if ($tileset)
	{	if (-not ($tileset.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a valid Tileset object"
		}	else
		{	$node=$tileset
		}
	}
	elseif ($firstGid) {$node=$map|get-TiledTileset -firstGid $firstGid|select -first 1}
	elseif ($source) {$node=$map|get-TiledTileset -source $source|select -first 1}
	
	if ($node) {[void]$node.parentnode.removeChild($node)}

	if ($map) {return $map} else {return $null}
}


#Get tile layer by name(regex) or id (supports wildcards)
function get-TiledTileLayer
{	[CmdletBinding(DefaultParameterSetName='name')]
	param
	(	[Parameter(Mandatory, ParameterSetName = 'name', Position = 0, ValueFromPipeline)]
		[Parameter(Mandatory, ParameterSetName = 'id', Position = 0, ValueFromPipeline)]$map,
		[Parameter(ParameterSetName = 'name', Position = 1)]$name=".*",
		[Parameter(ParameterSetName = 'id', Position = 1)]$id
	)
	if ($id) {return $map.map.Layer|where{$_.id -like $id}}
	elseif ($name) {return $map.map.Layer|where{$_.name -match $name}}
}


#Add a tile layer to an existing Tiled Map Object (XML)
function add-TiledTileLayer
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$map,
		$name="Slayaaaah",
		$TileFormat="csv",
		$data
	)
	$layer=$map.CreateElement("layer")
	$null=$map.map.AppendChild($layer)
	$null=$layer.SetAttribute("id",$map.map.nextlayerid)
	$null=$layer.SetAttribute("name",$name)
	$null=$layer.SetAttribute("width",$map.map.width)
	$null=$layer.SetAttribute("height",$map.map.height)

	$dat=$map.CreateElement("data")
	$null=$dat.SetAttribute("encoding",$tileFormat)
	if (-not $data){$dat.innerText=([int[]]::new(([int]$map.map.width)*([int]$map.map.height))) -join ","} else {$dat.innerText=$data}
	$null=$layer.AppendChild($dat)

	$id=([byte]$map.map.nextlayerid)+1
	$map.map.nextlayerid=[string]$id
	return $map
}


#Set existing tileLayer properties, and/or data
function Set-TiledTileLayer
{	[CmdletBinding(DefaultParameterSetName='node')]
	param
	(	[Parameter(Mandatory,ParameterSetName='name',Position=0,ValueFromPipeline)]
		[Parameter(Mandatory,ParameterSetName='id',Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,ParameterSetName='node',Position=0,ValueFromPipeline)]$tileLayer,
		[Parameter(ParameterSetName='name',Position=1)][string]$name,
		[Parameter(ParameterSetName='id',Position=1)]$id,
		[string]$newName,$width,$height,$data #,$newId
	) 
	if ($tileLayer)
	{	if (-not ($tileLayer.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a TileLayer object"
		}	else
		{	$node=$tileLayer;
		}
	}
	elseif ($name) {$node=get-TiledTileLayer -map $map -name $name|select -first 1}
	elseif ($id) {$node=get-TiledTileLayer -map $map -id $id|select -first 1}
	
	if ($node)
	{	if ($newname) {$node.name=[string]$newname}
		if ($newId) {$node.name=[string]$newId}
		if ($width) {$node.width=[string]$width}
		if ($height) {$node.height=[string]$heights}
		if ($data) {$node.data.innerText=$data}
	}

	if ($map) {return $map} else {return $null}
}


#Clear data of existing layer
function Clear-TiledTileLayer
{	[CmdletBinding(DefaultParameterSetName='node')]
	param
	(	[Parameter(Mandatory,ParameterSetName='name',Position=0,ValueFromPipeline)]
		[Parameter(Mandatory,ParameterSetName='id',Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,ParameterSetName='node',Position=0,ValueFromPipeline)]$tileLayer,
		[Parameter(ParameterSetName='name',Position=1)][string]$name,
		[Parameter(ParameterSetName='id',Position=1)]$id
	) 
	if ($tileLayer)
	{	if (-not ($tileLayer.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a TileLayer object"
		}	else
		{	$node=$tileLayer;
		}
	}
	elseif ($name) {$node=get-TiledTileLayer -map $map -name $name|select -first 1}
	elseif ($id) {$node=get-TiledTileLayer -map $map -id $id|select -first 1}
	
	if ($node)
	{	$data=([int[]]::new(([int]$node.width)*([int]$node.height))) -join ","
		$node.data.innerText=$data
	}

	if ($map) {return $map} else {return $null}
}

#Remove tileLayer
function Remove-TiledTileLayer
{	[CmdletBinding(DefaultParameterSetName='node')]
	param
	(	[Parameter(Mandatory,ParameterSetName='name',Position=0,ValueFromPipeline)]
		[Parameter(Mandatory,ParameterSetName='id',Position=0,ValueFromPipeline)]$map,
		[Parameter(Mandatory,ParameterSetName='node',Position=0,ValueFromPipeline)]$tileLayer,
		[Parameter(ParameterSetName='name',Position=1)][string]$name,
		[Parameter(ParameterSetName='id',Position=1)]$id
	) 
	if ($tileLayer)
	{	if (-not ($tileLayer.gettype().name -eq "XmlElement"))
		{	write-error "Input object not a TileLayer object"
		}	else
		{	$node=$tileLayer;
		}
	}
	elseif ($name) {$node=get-TiledTileLayer -map $map -name $name|select -first 1}
	elseif ($id) {$node=get-TiledTileLayer -map $map -id $id|select -first 1}
	
	if ($node) {[void]$node.parentnode.removeChild($node)}

	if ($map) {return $map} else {return $null}
}


##### WorldMap functions #####

#Return a blank worldmap object
function new-TiledWorldMap
{	param
	(	$DefaultMapWidth=38,$DefaultMapHeight=27,$name
	)
	return [PSCustomObject]@{maps=@();onlyShowAdjacentMaps=$false;type="world";defaultMapWidth=$DefaultMapWidth;defaultMapHeight=$DefaultMapHeight;name=$name}
}

function get-TiledWorldMap
{	param ($path)
	return Get-Content -Path $path |ConvertFrom-Json
}

function set-TiledWorldMap
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$WorldMap,
		$path
	)
	$worldmap|convertto-json|set-content -path $path
}


#Return a blank WorldMap.Map Object
function new-TiledWorldMapMap
{	param
	(	[Parameter(ValueFromPipeline)]$WorldMap,
		[Parameter(Mandatory)]$filename,
		$width,$height,$x=0,$y=0
	)
	if ($worldmap)
	{	if (-not $width) {$width=$worldmap.defaultMapWidth}
		if (-not $height) {$height=$worldmap.defaultMapHeight}
	}
	return [PSCustomObject]@{fileName=$filename;height=$Height;width=$Width;x=$x;y=$y}
}


#Add a map to the worldmap
function add-TiledWorldMapMap
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$WorldMap,
		[Parameter(Mandatory,ParameterSetName='node',Position=0)]$map,
		[Parameter(Mandatory,ParameterSetName='name',Position=0)]$filename,
		[Parameter(ParameterSetName='name')]$width,
		[Parameter(ParameterSetName='name')]$height,
		[Parameter(ParameterSetName='name')]$x,
		[Parameter(ParameterSetName='name')]$y
	)
	if ($filename) {$map=new-TiledWorldMapMap -filename $filename -width $width -height $height -x $x -y $y}
	if ($map) {$worldMap.maps+=$map}
	if ($worldmap) {return $worldmap} else {return}
}


#get Worldmap.map
function get-TiledWorldMapMap
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$WorldMap,
		$filename=".*"
		
	)
	return $worldmap.maps|where{$_.filename -match $filename}
}


#Remove an existing Worldmap.map (unfinished)
function Remove-TiledWorldMapMap
{	param
	(	[Parameter(Mandatory,Position=0,ValueFromPipeline)]$WorldMap,
	[Parameter(Mandatory,ParameterSetName='node',Position=0)]$map,
	[Parameter(Mandatory,ParameterSetName='name',Position=0)]$filename
	)
	#if ($filename) {$map=$worldmap.maps|where{$_.filename -eq $filename}}
	#if ($map) {}
}






##################################################


## tests
if ($test)
{
#includes
. .\csvtoobj.ps1



}

<#
. .\Tiled-Functions.ps1
$filename="bt27.tmx"
$tmxLocation="C:\Users\rvand\OneDrive\Usas2\maps"
$map=get-TiledMap $tmxLocation\$filename
$map|get-TiledMapProperty
$map|Get-TiledTileSet|where{$_.firstgid -ne 1}|%{Remove-TiledTileSet $_}
$map|set-TiledMap -path $tmxLocation\$filename

$map|add-TiledMapProperty -name name -type string -value "bt28"
$tsKarniMata="C:\Users\rvand\OneDrive\Usas2\maps\tilesheets\tsKarniMata.tsx


$map=new-TiledMap
$map|add-TiledMapProperty -name name -type string -value "newMap"
$map|add-TiledMapProperty -name name -type int -value 1
$map|Get-TiledMapProperty
$map|Get-TiledMapProperty|set-TiledMapProperty -value newer
$map|get-TiledTileLayer
$map|add-TiledTileLayer -name Karni
$map|set-TiledTileLayer -newname Karnemelk
$map|set-TiledTileLayer -id 1 -data "1,2,3,4,5,6,7,8,9,10"
$map|Clear-TiledTileLayer -id 1
($map|get-TiledTileLayer).data.innertext
$map|get-TiledTileLayer -id 1|Remove-TiledTileLayer

$WorldMapFile="C:\Users\rvand\OneDrive\Usas2\maps\KarniMata.world"
$WorldMap=Get-Content $WorldMapFile|ConvertFrom-Json
$worldmap=new-TiledWorldMap -name test -DefaultMapWidth 38 -DefaultMapHeight 27
$map=new-TiledWorldMapMap -WorldMap $worldmap -filename test.tmx
add-TiledWorldMapMap -WorldMap $worldmap -map $map


#>


