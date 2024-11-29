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
	$dsmPath=".\Usas2.Rom.dsm",
	$romfile, #="$(resolve-path `"..\Engine\usas2.rom`")", #over rule DSM.filespace.path
	$datalistName="BitMapGfx",
	[switch]$convertGfx=$true,
	[switch]$resetGlobals=$false,
	[switch]$updateIndex=$true
)

##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\DSM.ps1


##### Global properties #####
if ($resetGlobals) {$global:usas2=$null}
$global:usas2=get-Usas2Globals

##### Functions #####

function convert-BmpToSc5
{	param ($bmpfile,$sc5file,$palfile)
	#npx convertgfx --source "../grapx/tilesheets/pegu.tiles.bmp" --fixedPalette "../grapx/tilesheets/pegu.tiles.pl" --targetScreen5 "../grapx/tilesheets/pegu.tiles.sc5"
	write-verbose "Converting `"$bmpfile`" to `"$sc5file`". Pal: `"$palfile`""
	npx convertgfx --source $bmpfile --fixedPalette $palfile --targetScreen5 $sc5file --gamma 2.2
}


##### MAIN #####
$fileTypes=@{};$usas2.filetype|%{$fileTypes[$_.identity]=$_.id}
$DataListProperties=$usas2.DsmDatalist|where{$_.identity -eq $datalistname}
write-verbose "DSM: $dsmPath, Datalist:$datalistname"

if (-not ($dsm=load-dsm -path $dsmPath))
{	write-error "DSM $dmsname not found"
}	else
{	if (-not $romfile) {$romfile=$dsm.filespace.path}
	$null=$DSM|open-DSMFileSpace -path $romfile
	$datalist=add-DSMDataList -dsm $dsm -name $datalistname

	#Add FILE to DSM and inject to ROM
	if ($path)
	{	write-verbose "[path] Adding File(s) $path"
		$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $path -updateFileSpace
	}

	#Add ruin file
	if ($ruinid)
	{	write-verbose "[ruinId] Adding Ruin(s) $ruinid"
		foreach ($id in $ruinId)
		{	$ruinManifest=get-u2Ruin -id $id
			$tilesetManifest=get-u2TileSet -identity $ruinManifest.tileset
			if	($sc5File=(get-U2File -identity $tilesetManifest.file -fileType $fileTypes["tileset"]).path)
			{	if ($convertGfx)
				{	$bmpFile=(get-u2file -identity $tilesetManifest.imagesourcefile -filetype $filetypes["TiledTileSetImage"]).path
					$palFile=(get-u2file -identity $tilesetManifest.paletteSourcefile -filetype $filetypes["palette"]).path
					$x=convert-BmpToSc5 -bmpfile $bmpfile -sc5file $sc5file -palfile $palFile
				}
				write-verbose "RuinId $id, Filename: $sc5file"
				$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $sc5file -updateFileSpace
			}
		}
	}

	#Make index and inject into ROM
	if ($updateIndex)
	{	$BitmapGfxIndex=get-BitmapGfxIndex -dsm $dsm -datalist $datalistname
		write-verbose ($BitmapGfxIndex.indexPointerTable -join(",")); write-verbose ($BitmapGfxIndex.index -join(","))
		$data=($BitmapGfxIndex.indexPointerTable+$BitmapGfxIndex.index)
		if ($DataListProperties)
		{	$indexBlock=([int]$DataListProperties.IndexBlock);$indexSegment=([int]$DataListProperties.IndexSegment)
			write-verbose "Writing Index to block:$indexblock, segment:$indexsegment"
			write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $data
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
$dsmPath="Usas2.Rom"
$DSM=new-DSM -name $dsmPath -BlockSize 16KB -size 256 -SegmentSize 128 -firstblock 0xb7
$dsm|exclude-dsmblock -block 0 #exlcude first block for index
$dsm|save-dsm
$DSM|create-DSMFileSpace -verbose -force -path "$(resolve-path ".\")\usas2.rom"

#>