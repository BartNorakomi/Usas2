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
	if (-not ($Map=get-TiledMap -path $path))
	{	return $false}
	write-verbose "map: $path"
	$layers=$map.map.layer|where{$_.visible -ne 0 -and $_.name -ne "objects"}

	#Lemniscate fix, all BG tiles move 64 positions further
	$dataLength=([uint16]$map.map.width)*([int]$map.map.height)
	$newData=([uint16[]]::new($dataLength))
	foreach ($layer in $layers)
	{	write-verbose $layer.name
		$data=$layer.innertext.split(",")
		for ($i=0;$i -lt $dataLength;$i++)
		{	$value=[uint16]$data[$i];
			if (($value -ge 57) -and ($value -le 30*32)) {$value+=2*32;}
			$newData[$i]=$value
		}
		Set-TiledMapTileLayer -tileLayer $layer -data ($newData -join(","))
	}
	set-TiledMap -map $map -path $path
}

#### Main: #####

#$path="C:\Users\rvand\OneDrive\Usas2\maps\AS23org.tmx"
#$path="C:\Users\rvand\OneDrive\Usas2\maps\AS23.tmx"
#replace-tiles -path $path
exit

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

#$global:roomfiles=$roomfiles
#$roomfiles|%{copy $_ C:\users\rvand\OneDrive\Usas2\retired\maps\} #save a copy

foreach ($roomfile in $roomfiles)
{	write-verbose $roomfile
	replace-tiles -path $roomfile
}