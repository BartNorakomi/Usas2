# Put (known) files into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231207-20241208
#Invoke-Expression  "dir $($usas2.tiledtileset[4].defaultLocation)\$($usas2.tiledtileset[4].imagesourcefile)"

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruinTileset')]$TilesetRuinId,
	[Parameter(ParameterSetName='ruinTileset')][switch]$convertGfx=$true,
	[Parameter(ParameterSetName='path')]$path,
	[Parameter(ParameterSetName='path')]$datalistName,
	[Parameter(ParameterSetName='identity')]$identity,
	[Parameter(ParameterSetName='identity')]$dataType="*",
	[Parameter(ParameterSetName='test')][switch]$test,
	# [Parameter(ParameterSetName='test')]$datalistName,
	$dsmPath, #=".\Usas2.Rom.dsm",
	$romfile, #="$(resolve-path `"..\Engine\usas2.rom`")", #over rule DSM.filespace.path

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
	write-verbose "Converting `"$bmpfile`" to `"$sc5file`". Pal: `"$palfile`""
	if (-not (test-path $bmpfile)) {write "$bmpfile not found"}
	elseif (-not (test-path $palfile)) {write "$palfile not found"}
	else
	{	npx convertgfx --source $bmpfile --fixedPalette $palfile --targetScreen5 $sc5file --gamma 2.2
	}
}


##### MAIN #####
if (-not $dsmPath) {$dsmPath=$usas2.dsm.path}
write-verbose "DSM: $dsmPath"
$fileTypes=@{};$usas2.datatype|%{$fileTypes[$_.identity]=$_.id}

if (-not ($dsm=load-dsm -path $dsmPath))
{	write-error "DSM $dmsname not found"
}	else
{	if (-not $romfile) {$romfile=$dsm.filespace.path}
	write-verbose "ROM file: $romfile"
	$null=$DSM|open-DSMFileSpace -path $romfile
	
	
	switch ($PSCmdlet.ParameterSetName)
	{	"test"
	{	write-verbose "mode: Test mode"
			write-verbose "DSM: $dsmPath, Datalist:$datalistname"
			$datalist=add-DSMDataList -dsm $dsm -name $datalistname
			# $fileTypes[$datalistname]
			$usas2.datatype|where{$_.DsmDatalist -eq $datalistname}
			break
		}

		#-path: Add any FILE to DSM and inject to ROM
		"path"
		{	write-verbose "-path Adding File(s) $path"
			$x=replace-dsmfile -dsm $dsm -dataListname $datalistName -path $path -updateFileSpace
			break
		}
		
		#Add a manifest FILE to DSM and inject to ROM
		"identity"
		{	write-verbose "mode: add by identity $identity"
			$files=get-u2file -identity $identity -filetype $datatype
			foreach ($file in $files)
			{	write-verbose " File: $file"
				$datatype=$usas2.datatype|where{$_.id -eq $file.dataTypeId}
				if ($datatype.dsmdatalist)
				{	write-verbose " Adding to datalist `"$($datatype.dsmdatalist)`", and injecting it into the ROM space"
					$datalist=add-DSMDataList -dsm $dsm -name $datatype.dsmdatalist
					$x=replace-dsmfile -dsm $dsm -dataList $datalist -path "$($file.path)" -updateFileSpace
				}
			}
			break
		}
	

		#Add ruin tileset, convert gfx first if needed.
		"ruinTileset"
		{	write-verbose "mode: ruinId Adding Ruin(s) $tileSetRuinid"
			$datalist=add-DSMDataList -dsm $dsm -name "tileset"
			foreach ($id in $tilesetRuinId)
			{	$ruinManifest=get-u2Ruin -id "^$id$"
				$tilesetManifest=get-u2TileSet -identity $ruinManifest.tileset
				$sc5File=(get-U2File -identity $tilesetManifest.file -fileType $fileTypes["tileset"]).path
				if	(-not $sc5File)
				{	write-verbose "sc5file not found in manifest"
				} else
				{	if ($convertGfx)
					{	$bmpFile=(get-u2file -identity $tilesetManifest.imagesourcefile -filetype $filetypes["TiledTileSetImage"]).path
						$palFile=(get-u2file -identity $tilesetManifest.paletteSourcefile -filetype $filetypes["palette"]).path
						$x=convert-BmpToSc5 -bmpfile $bmpfile -sc5file $sc5file -palfile $palFile
					}
					write-verbose "RuinId $id, tilesetFile: $sc5file"
					if ($sc5file) {$x=replace-dsmfile -dsm $dsm -dataList $datalist -path $sc5file -updateFileSpace}
				}
			}
			break
		}

	}


	#Make index and inject into ROM
	if ($updateIndex)
	{	write-verbose "-==== Updating the ROM index for collection(s) of files ====-"
		$datalistName="index"
		$datalist=add-DSMDataList -dsm $dsm -name $datalistname
		
		$collections="tileset","areasign"
		foreach ($collectionName in $collections)
		{	write-verbose "Updating index for collection `"$collectionname`""
			$fileIndex=new-U2RomFileIndex -DSM $dsm -collection $usas2.$collectionName
			$data=$fileindex.indexPointerTable+$fileindex.indexPartsTable
			$null=remove-dsmdata -dsm $dsm -datalist $datalist -name $collectionName
			$alloc=add-DSMData -dsm $dsm -dataList $datalist -name $collectionName -part 0 -data $data -updateFileSpace:$true
			# write-verbose ($fileindex.indexPointerTable -join(","));
			# write-verbose ($fileindex.indexPartsTable -join(","));
		}
		#update the Master Index as well
		$index=$usas2.index|where{$_.identity -eq "master"}
		if ($index)
		{	$indexBlock=([int]$index.DsmBlock);$indexSegment=([int]$index.DsmSegment)
			write-verbose "Writing MasterIndex to block:$indexblock, segment:$indexsegment"
			$masterIndex=new-u2RomMasterFileIndex
			write-verbose ($masterindex -join(","));
			write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $masterIndex
		}
	}
	
	#close the ROM file and save DSM
	$null=$DSM|close-DSMFileSpace
	save-dsm -dsm $dsm -path $dsmPath

}

#write "`n#datalist:"
#$dsm.datalist
#write "`n#Stats:"
$dsm|get-DSMStatistics
$global:dsm=$dsm
EXIT

<#
.\add-u2gfx.ps1 -Verbose -updateIndex:$false -file (gci ..\grapx\AreaSigns\*.sc5.pck)
#>