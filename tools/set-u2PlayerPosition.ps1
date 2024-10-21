# Set player Room and/or position
# 20240801;shadow;new

[CmdletBinding()]
param
(	$room,$x,$y,
	$dsmPath=".\Usas2.Rom.dsm",
	$romfile="..\Engine\usas2.rom"

)

#GLOBALS
$EnginePage3RomStartAddress=0x0201
$WorldMapPositionY_offset=0
$WorldMapPositionX_offset=1
$ClesX_offset=2 #      dw 230 ;$19 ;230 ;250 ;210
$ClesY_offset=4 #      db 150 ;144-1


##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1

##### Main #####
write-verbose "Opening $dsmPath"
if (-not ($dsm=load-dsm -path $dsmPath))
{	write-error "DSM $dmsname not found"
}	else
{	$global:dsm=$dsm
	#open the ROM file
	$null=$DSM|open-DSMFileSpace -path $romfile

	$seekPosition=$EnginePage3RomStartAddress+$WorldMapPositionY_offset
	$null=$DSM.filespace.stream.seek($seekPosition,0)
	$currentRoom=read-DSMFileSpace -dsm $dsm -length 2
	$currentPosition=read-DSMFileSpace -dsm $dsm -length 3
	$currentRoomName=get-roomname -x $currentroom[1] -y $currentRoom[0]
	write-host "Current room location: $currentRoomname / X:$($currentRoom[1]), Y:$($currentRoom[0])"
	write-host "Current position: X:$($currentPosition[1]*256+$currentPosition[0]), Y:$($currentPosition[2])"

	if ($room)
	{	write-verbose "# changing Room"
		$roomLocation=get-roomlocation -name $room
		write-verbose "Room $room has location X=$($roomLocation.x), Y=$($roomLocation.y)"
		write-verbose "Write room location to ROM file offset $seekPosition"
		#direct seek, cuz there's no fine grain seek-filespace in DSM. yet
		$null=$DSM.filespace.stream.seek($seekPosition,0)
		$data=[byte[]]::new(2);$data[0]=$roomLocation.y;$data[1]=$roomlocation.X
		write-dsmFilespace -dsm $dsm -data $data
	}

	if ($X)
	{	write-verbose "# changing X-position"
		$seekPosition=$EnginePage3RomStartAddress+$ClesX_offset
		write-verbose "Write X to ROM file offset $seekPosition"
		#direct seek, cuz there's no fine grain seek-filespace in DSM. yet
		$null=$DSM.filespace.stream.seek($seekPosition,0)
		$data=[byte[]]::new(2);$data[0]=$x -band 255;$data[1]=$x -shr 8 -band 0xff
		write-dsmFilespace -dsm $dsm -data $data
	}
	
	if ($Y)
	{	write-verbose "# changing Y-position"
		$seekPosition=$EnginePage3RomStartAddress+$ClesY_offset
		write-verbose "Write Y to ROM file offset $seekPosition"
		#direct seek, cuz there's no fine grain seek-filespace in DSM. yet
		$null=$DSM.filespace.stream.seek($seekPosition,0)
		$data=[byte[]]::new(1);$data[0]=$Y -band 0xff
		write-dsmFilespace -dsm $dsm -data $data
	}

	#close the ROM file
	$null=$DSM|close-DSMFileSpace
}