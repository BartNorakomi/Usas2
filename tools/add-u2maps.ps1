# Put maps into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231128-20250225

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId,
	[Parameter(ParameterSetName='room')][ValidateLength(4,4)]$roomname,
	[Parameter(ParameterSetName='file')]$path,
	[Parameter(ParameterSetName='latestFile')]$newest,
	$dsmPath, #=".\Usas2.Rom.dsm",
	$romfile, #="$(resolve-path `"..\Engine\usas2.rom`")", #over rule DSM.filespace.path
	$datalistName="WorldMap",
	$mapslocation="..\maps",
	$TiledMapsLocation, #="C:\Users\rvand\SynologyDrive\Usas2\maps", #"$env:onedrive\usas2\maps", #"C:\Users\$($env:username)\OneDrive\Usas2\maps",
	[switch]$convertTiledMap=$true,
	[switch]$resetGlobals=$false,
	[switch]$updateIndex=$true
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1 
. .\DSM.ps1


##### Global properties #####
if ($resetGlobals) {$global:usas2=$null}
$global:usas2=get-Usas2Globals
if (-not $tiledmapsLocation) {$tiledmapsLocation=get-U2TiledMapLocation} else {set-U2TiledMapLocation -path $TiledMapsLocation}
write-verbose "Tiled maps location: $tiledmapsLocation"

##### Functions #####

#note that this functions uses script parameters as global
function add-roomToDsm
{	param ($rooms)
	foreach ($room in $rooms)
	{	#convert .tmx to .map
		if ($convertTiledMap) #global!
		{	$tiledMapPath="$tiledmapsLocation\$($room.name).tmx"
			.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|object|room numbers)" -pack
		}
		#Add to DSM and inject to ROM
		$pckPath="$mapslocation\$($room.name).map.pck"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace
	}
}



##### MAIN #####
if (-not $dsmPath) {$dsmPath=$usas2.dsm.path}
write-verbose "DSM: $dsmPath, Datalist:$datalistname"

if (-not ($dsm=load-dsm -path $dsmPath))
{	write-error "DSM $dmsname not found"
}	else
{	if (-not $romfile) {$romfile=$dsm.filespace.path}
	write-verbose "ROM file: $romfile"
	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname
	

	#Add any FILE to DSM and inject to ROM
	if ($path)
	{	write-verbose "[path] Adding File(s) $path"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $path -updateFileSpace
	}

	#Add Ruin(s)
	elseif ($ruinid)
	{	write-verbose "Adding Ruin(s) $ruinid"
		$ruinIdFilter=("^("+($ruinId -join ("|"))+")$")
		$rooms=get-U2WorldMapRooms -ruinid $ruinidfilter
		add-roomToDsm -rooms $rooms
	}

	#Add room(s)
	elseif ($roomname)
	{	write-verbose "Adding room(s) $roomname"
		$roomNameFilter=("^("+($roomname -join ("|"))+")$")
		$rooms=get-U2WorldMapRooms -roomname $roomNameFilter
		add-roomToDsm -rooms $rooms
	}

	#Add most recent TILED map files
	elseif ($newest)
	{	write-verbose "Adding most recent $newest Tiled Map files (.tmx)"
		$files=gci $Tiledmapslocation\*.tmx|where{$_.basename -match "^[0-9[a-zA-Z0-9]{4}$"}|Sort-Object -Property lastWriteTime -Descending|select -first $newest
		if (-not $files) {write "No files found at $tiledmapslocation"}
		foreach ($file in $files)
		{	write-verbose "Add File: $($file.fullname)"
			if ($convertTiledMap)
			{	$tiledMapPath=$file.fullname
				.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|object|room numbers)" -pack
			}
			#Add to DSM and inject to ROM
			$pckPath="$mapslocation\$($file.basename).map.pck"
			if ($pckPath) {$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace}
		}
	}


	#Make new maps index and inject into ROM
	if ($updateIndex)
	{	$indexRecords=get-U2WorldMapRomIndex -dsm $dsm -datalistname $dataListName
		$index=$usas2.index|where{$_.identity -eq "rooms"}
		if ($indexRecords -and $index)
		{	$indexBlock=([int]$index.DsmBlock);$indexSegment=([int]$index.DsmSegment)
			write-verbose "Writing Index to block:$indexblock, segment:$indexsegment"
			write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $indexrecords
		}
	}

	#close the ROM file and save DSM
	$null=$DSM|close-DSMFileSpace
	save-dsm -dsm $dsm -path $dsmPath
}


$dsm|get-DSMStatistics
$global:dsm=$dsm
EXIT
