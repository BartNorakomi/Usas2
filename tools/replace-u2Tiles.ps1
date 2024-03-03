# Replace tiles - for incidental usage
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20240302-20240302

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId,
	[Parameter(ParameterSetName='room')]$roomname,
	[Parameter(ParameterSetName='file')]$path,
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps"
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\Tiled-Functions.inc.ps1

##### Global properties #####
$global:usas2=get-Usas2Globals


##### functions: #####
function replace-tiles
{	param ($path)
	if (-not ($TiledMap=get-TiledMap -path $path))
	{	return $false}
	$layers=$Tiledmap.map.layer|where{$_.visible -ne 0 -and $_.name -ne "objects"}

	#conversion
	# iterate through layers
	foreach ($layer in $layers)
	{	write-verbose $layer.name
		$tiles=$layer.innertext.split(",")
		#$data=@()::new($tiles.count);$index=0 #new array
		#iterate through tiles
		foreach ($tile in $tiles)
		{	#convert tile here

		}
	}
}

#### Main: #####

#handle inputtype (ruin,room,file)

if ($ruinid)
	{	write-verbose "Ruin(s) $ruinid"
		$ruinIdFilter=("^("+($ruinId -join ("|"))+")$")
		$rooms=get-U2WorldMapRooms -ruinid $ruinidfilter
		$RoomFiles=$rooms|%{"$tiledMapslocation\$($_.name).tmx"}
	}
elseif ($roomname)
{	write-verbose "Room(s) $roomname"
	$roomNameFilter=("^("+($roomname -join ("|"))+")$")
	$rooms=get-U2WorldMapRooms -roomname $roomNameFilter
	$RoomFiles=$rooms|%{"$tiledMapslocation\$($_.name).tmx"}
}
elseif ($path)
{	write-verbose "Path(s) $path"
	$roomfiles=(gci $path).fullname
}

foreach ($roomfile in $roomfiles)
{	write-verbose $roomfile
	replace-tiles -path $roomfile
}