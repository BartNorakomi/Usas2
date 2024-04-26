# Put gfx files into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231207-20231207
#Invoke-Expression  "dir $($usas2.tiledtileset[4].defaultLocation)$($usas2.tiledtileset[4].imagesourcefile)"

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruin')]$ruinId,
	#[Parameter(ParameterSetName='room')]$roomname,
	[Parameter(ParameterSetName='file')]$path, #="..\grapx\tilesheets\KarniMata.Tiles.sc5",
	$dsmName="Usas2.Rom.dsm",
	$datalistName="BitMapGfx",
	[switch]$convertGfx=$true
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1


##### Global properties #####
$global:usas2=get-Usas2Globals
$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"

##### Functions #####



##### MAIN #####
$DataListProperties=$usas2.DsmDatalist|where{$_.identity -eq $datalistname}
write-verbose "DSM: $dsmname, Datalist:$datalistname"

if (-not ($dsm=load-dsm -path $dsmname))
{	write-error "DSM $dmsname not found"
}	else
{	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname

	#Add FILE to DSM and inject to ROM
	if ($path)
	{	write-verbose "Adding File(s) $path"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $path -updateFileSpace
	}

	#Add ruin file
	if ($ruinid)
	{	write-verbose "Adding Ruin(s) $ruinid"
		foreach ($id in $ruinId)
		{	$ruinProps=$usas2.ruin|where{$_.ruinid  -eq $id}
			$tilesetProps=$usas2.tileset|where{$_.identity -eq $ruinprops.tileset}
			write-verbose "RuinId $id, Filename: $($tilesetProps.file)"
			$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $tilesetProps.file -updateFileSpace
		}
	}

	#Make index and inject into ROM
	$BitmapGfxIndex=get-BitmapGfxIndex -dsm $dsm -datalist $datalistname
	write-verbose ($BitmapGfxIndex.indexPointerTable -join(",")); write-verbose ($BitmapGfxIndex.index -join(","))
	$data=($BitmapGfxIndex.indexPointerTable+$BitmapGfxIndex.index)
	if ($DataListProperties)
	{	$indexBlock=([int]$DataListProperties.IndexBlock);$indexSegment=([int]$DataListProperties.IndexSegment)
		write-verbose "Writing Index to block:$indexblock, segment:$indexsegment"
		write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $data
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