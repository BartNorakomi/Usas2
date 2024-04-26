# Put maps into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231128-202426

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId,
	[Parameter(ParameterSetName='room')]$roomname,
	[Parameter(ParameterSetName='file')]$path,
	$dsmName="Usas2.Rom.dsm",
	$datalistName="WorldMap",
	$mapslocation="..\maps",
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps",
	[switch]$convertTiledMap=$true
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1


##### Global properties #####
$global:usas2=get-Usas2Globals
$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"

##### Functions #####

#note that this functions uses script parameters as global
function add-roomToDsm
{	param ($rooms)
	foreach ($room in $rooms)
	{	#convert .tmx to .map
		if ($convertTiledMap)
		{	$tiledMapPath="$tiledmapsLocation\$($room.name).tmx"
			.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|object|room numbers)" -pack
		}
		#Add to DSM and inject to ROM
		$pckPath="$mapslocation\$($room.name).map.pck"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace
	}
}



##### MAIN #####
$DatalistProperties=$usas2.DsmDatalist|where{$_.identity -eq $datalistName}
write-verbose "DSM: $dsmname, Datalist:$datalistname"

if (-not ($dsm=load-dsm -path $dsmname))
{	write-error "DSM $dmsname not found"
}	else
{	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname

	#Add Ruin(s)
	if ($ruinid)
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

	#Add file
	elseif ($path)
	{
		write-warning "add TMX file (path) not yet supported"
	}

	#Make new maps index and inject into ROM
	$indexRecords=get-WorldMapRoomIndex -dsm $dsm -datalistname $dataListName
	if ($DatalistProperties)
	{	$indexBlock=([int]$DataListProperties.IndexBlock);$indexSegment=([int]$DataListProperties.IndexSegment)
		write-verbose "Writing Index to block:$indexblock, segment:$indexsegment"
		write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $indexrecords
	}
	#close the ROM file and save DSM
	$null=$DSM|close-DSMFileSpace
	save-dsm -dsm $dsm
}

#write "`n#datalist:"
#$dsm.datalist
#write "`n#Stats:"
$dsm|get-DSMStatistics
$global:dsm=$dsm
EXIT

<#
#Create usas2.rom DSM
. .\dsm.ps1
$dsmName="Usas2.Rom"
$DSM=new-DSM -name $dsmName -BlockSize 16KB -size 256 -SegmentSize 128 -firstblock 0xb7
$dsm|exclude-dsmblock -block 0 #exlcude first block for index
$dsm|save-dsm
$DSM|create-DSMFileSpace -verbose -force -path "$(resolve-path ".\")\usas2.rom"

#>