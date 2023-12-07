# Put maps into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231128-20231205

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId=".*",
#	[Parameter(ParameterSetName='room')]$roomname,
#	[Parameter(ParameterSetName='file')]$path,
	$dsmName="Usas2.Rom.dsm",
	$datalistName="WorldMap",
	$mapslocation="..\maps",
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps"
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1


##### Global properties #####
$global:usas2=get-Usas2Globals
$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"

##### MAIN #####
$ruinIdFilter=("^("+($ruinId -join ("|"))+")$")
write-verbose "DSM: $dsmname, Datalist:$datalistname"

if (-not ($dsm=load-dsm -path $dsmname))
{	write-error "DSM $dmsname not found"
}	else
{	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname
	$rooms=get-U2WorldMapRooms -ruinid $ruinidfilter 
	foreach ($room in $rooms)
	{	#convert .tmx to .map
		$tiledMapPath="$tiledmapsLocation\$($room.name).tmx"
		.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|room numbers)" -pack
		#Add to DSM and inject to ROM
		$pckPath="$mapslocation\$($room.name).map.pck"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace
	}
	#Make new maps index and inject into ROM
	$indexRecords=get-WorldMapRoomIndex -dsm $dsm -datalistname $dataListName
	write-DSMFileSpace -dsm $dsm -block 0 -segment 0 -data $indexrecords #$data 

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