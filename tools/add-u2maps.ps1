# Put maps into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231128-202426

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId,
	[Parameter(ParameterSetName='room')]$roomname,
	[Parameter(ParameterSetName='file')]$path,
	[Parameter(ParameterSetName='latestFile')]$newest,
	$dsmName="Usas2.Rom.dsm",
	$datalistName="WorldMap",
	$mapslocation="..\maps",
	$TiledMapsLocation="C:\Users\$($env:username)\OneDrive\Usas2\maps",
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
$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"


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
$DatalistProperties=$usas2.DsmDatalist|where{$_.identity -eq $datalistName}
write-verbose "DSM: $dsmname, Datalist:$datalistname"
$indexBlock=([int]$DataListProperties.IndexBlock);$indexSegment=([int]$DataListProperties.IndexSegment)

if (-not ($dsm=load-dsm -path $dsmname))
{	write-error "DSM $dmsname not found"
}	else
{	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname
	
#$roomIndex=@{numrec=1024;reclen=4;size=4*1024;data=[byte[]]::new(4*1024)}
# #Read the current roomIndex from the ROM
# $roomIndex.data=read-DSMFileSpace -dsm $dsm -length ($roomindex.size) -block $indexBlock -segment $indexsegment
# $global:roomindex=$roomindex
# $roomindex.data=get-WorldMapRoomIndex -dsm $dsm -datalistname $dataListName

# #Find a room in the binairy RoomIndex, and return the record-index
# function get-roomIndexRoom
# {	param ($RoomIndex,$roomName)
# 	if ($room=get-roomLocation -name $roomName.Substring(0,4))
# 	{	while ($i -lt $roomindex.numrec)
# 		{	if ($roomindex.data[$i*$roomindex.reclen+0] -eq $room.x -and $roomindex.data[$i*$roomindex.reclen+1] -eq $room.y) {return $i;break}
# 			$i++;
# 		}
# 	}
# }
# get-roomIndexRoom -roomindex $roomindex -roomname "aw27"

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

	#Add most recent TILED map files
	elseif ($newest)
	{	write-verbose "Adding most recent $newest Tiled Map files (.tmx)"
		$files=gci $Tiledmapslocation\*.tmx|Sort-Object -Property lastWriteTime -Descending|select -first $newest
		foreach ($file in $files)
		{	write-verbose "File: $($file.fullname)"
			if ($convertTiledMap)
			{	$tiledMapPath=$file.fullname
				.\convert-tmxtoraw16.ps1 -path $tiledMapPath -targetPath $mapsLocation -includeLayer ".*" -excludeLayer "(Objects|object|room numbers)" -pack
			}
			#Add to DSM and inject to ROM
			$pckPath="$mapslocation\$($file.basename).map.pck"
			#write-verbose $pckpath
			$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $pckpath -name $pckpath -updateFileSpace
		}
	}


	#Make new maps index and inject into ROM
	if ($updateIndex)
	{	$indexRecords=get-WorldMapRoomIndex -dsm $dsm -datalistname $dataListName
		if ($DatalistProperties)
		{	$indexBlock=([int]$DataListProperties.IndexBlock);$indexSegment=([int]$DataListProperties.IndexSegment)
			write-verbose "Writing Index to block:$indexblock, segment:$indexsegment"
			write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $indexrecords
		}
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