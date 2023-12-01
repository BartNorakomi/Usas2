# Put maps into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231128-20231128

[CmdletBinding()]
param
(	$ruinId=".*",
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
#if (-not $masterWorldMapFile) {$masterWorldMapFile="..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile}


##### MAIN #####
$ruinIdFilter=("^("+($ruinId -join ("|"))+")$")

if (-not ($global:dsm=load-dsm -path $dsmname))
{	write-error "DSM $dmsname not found"
}	else
{	$null=$DSM|open-DSMFileSpace -verbose
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname
	$rooms=get-U2WorldMapRooms -ruinid $ruinidfilter
	foreach ($room in $rooms)
	{	#convert .tmx to .map
		$tiledMapPath="$tiledmapsLocation\$($room.name).tmx"
		.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|room numbers)" -pack
		#Add to DSM
		$pckPath="$mapslocation\$($room.name).map.pck"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace
	}
	$null=$DSM|close-DSMFileSpace -verbose
	#Make new maps index
	.\make-dsmIndex.ps1 -indexType maps
	
	save-dsm -dsm $dsm
}

write "`n"
$dsm|get-DSMStatistics
EXIT

<#
#Create DSM
$dsmName="Usas2.Rom"
$DSM=new-DSM -name $dsmName -BlockSize 16KB -numBlocks 8 -SegmentSize 128
$dsm|save-dsm
#>