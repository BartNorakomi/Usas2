# Put (known) files into the datalist, and write to the ROM
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20231207-20241208
#Invoke-Expression  "dir $($usas2.tiledtileset[4].defaultLocation)\$($usas2.tiledtileset[4].imagesourcefile)"

[CmdletBinding()]
param
(	#[Parameter(ParameterSetName='ruinTileset')]$TilesetRuinId,
	#@[Parameter(ParameterSetName='ruinTileset')][switch]$convertGfx=$true,
	[Parameter(ParameterSetName='path')]$path,
	[Parameter(ParameterSetName='path',Mandatory=$true)]$datalistName,
	[Parameter(ParameterSetName='manifest')]$identity,
	[Parameter(ParameterSetName='manifest',Mandatory=$true)]$dataTypeId="*",
	#[Parameter(ParameterSetName='test')][switch]$test,
	#[Parameter(ParameterSetName='generic')][switch]$generic,
	# [Parameter(ParameterSetName='test')]$datalistName,
	$dsmPath, #=".\Usas2.Rom.dsm",
	$romfile, #="$(resolve-path `"..\Engine\usas2.rom`")", #over rule DSM.filespace.path
	[switch]$convertDataFirst=$false,
	[switch]$resetGlobals=$false,
	[switch]$updateIndex=$true,
	[string]$exportPath	#for test purposes
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
$dataListUpdates=@();$portraitList=$null;

if (-not ($dsm=load-dsm -path $dsmPath))
{	write-error "DSM $dmsname not found"
}	else
{	if (-not $romfile) {$romfile=$dsm.filespace.path}
	write-verbose "ROM file: $romfile"
	$null=$DSM|open-DSMFileSpace -path $romfile
	
	#The ROM must have an "index" data list
	$indexDatalist=add-DSMDataList -dsm $dsm -name "index"

	write-verbose "Mode: $($PSCmdlet.ParameterSetName)"
	switch ($PSCmdlet.ParameterSetName)
	{	"test"
	{	write-verbose "[Test]"
			write-verbose "DSM:`"$dsmPath`", Datalist:`"$datalistname`""
			$datalist=add-DSMDataList -dsm $dsm -name $datalistname
			# $fileTypes[$datalistname]
			$usas2.datatype|where{$_.DsmDatalist -eq $datalistname}
			break
		}

		#-path: Add any FILE to DSM and inject to ROM
		"path"
		{	write-verbose "- Adding File(s) $path"
			$x=replace-dsmfile -dsm $dsm -dataListname $datalistName -path $path -updateFileSpace
			break
		}

		#Add one or more manifest-FILEs to DSM and inject to ROM
		"manifest"
		{	write-verbose "Add id(s): $identity"
			$files=get-u2file -identity $identity -filetype $datatypeId
			foreach ($file in $files)
			{	write-verbose "File: $file"
				$datatype=$usas2.datatype|where{$_.id -eq $file.dataTypeId}
				write-verbose "datatype: $datatype"
				#handle necessary data conversions
				switch -Regex ($dataType.Id)
				{	"(^1$)" #tileset
					{	if ($convertDataFirst)
						{	$tilesetManifest=get-u2TileSet -identity .*|where{$_.file -eq $file.identity}
							write-verbose "$tilesetManifest"
							$sc5file=$file.path
							$bmpFile=(get-u2file -identity $tilesetManifest.imagesourcefile -filetype $filetypes["TiledTileSetImage"]).path
							$palFile=(get-u2file -identity $tilesetManifest.paletteSourcefile -filetype $filetypes["palette"]).path
							$x=convert-BmpToSc5 -bmpfile $bmpfile -sc5file $sc5file -palfile $palFile
						}
					}
					"(^16$)" #assetName
					{	$idName="id";$propertyName="name"
					}
					"(^17$)" #assetDescription
					{	$idName="id";$propertyName="description"
					}
					"(^18$)" #portraitName
					{	$idName="id";$propertyName="displayName"
					}
					"(^16$|^17$|^18$)" #general IndexedDataBlock
					{	write-verbose "converting CSV file `"$($file.path)`" to indexedDataBlock [$idname,$propertyname]"
						$collection=Import-Csv -Path $file.path -Delimiter `t|where{$_.ena -eq 1}
						$indexedDataBlock=new-u2RomCsvIndexedDataBlock -collection $collection -idName $idname -propertyName $propertyName
						write-verbose "Block length: $($indexedDataBlock.length)"
						if ($exportPath) {$indexedDataBlock|set-content -Encoding byte -path $exportPath}
						if ($indexDataList -and $datatype.indexName) {$alloc=replace-DSMData -dsm $dsm -dataList $indexDataList -name $datatype.indexName -data $indexedDataBlock -updateFileSpace:$true}
					}
					"(^19$)" #portrait
					{	if ($convertDataFirst)
						{	#create .por file
							if (-not $portraitList) {$portraitList=Import-Csv -Path "..\usas2-portrait.csv" -Delimiter `t|where{$_.ena -eq 1}}
							$portraitManifest=$usas2.portrait|where{$_.file -eq $file.identity}
							$portrait=@{header=[byte[]]::new(0x1f);face=[byte[]]::new;eyesOpen=[byte[]]::new;eyesClosed=[byte[]]::new;mouthOpen=[byte[]]::new;mouthClosed=[byte[]]::new}
							$elements="face","eyesOpen","eyesClosed","mouthOpen","mouthClosed"
							$headerPointer=1;$imageOffset=$portrait["header"].length;
							foreach($element in $elements)
							{	$record=$portraitList|where{$_.id -eq $portraitManifest.id -and $_.element -eq $element}
								write-verbose "$record"
								$portrait["header"][$headerPointer+0]=$imageOffset -band 255;$portrait["header"][$headerPointer+1]=$imageOffset -shr 8;$headerPointer+=2
								$portrait["header"][$headerPointer]=$record.width;$headerPointer++
								$portrait["header"][$headerPointer]=$record.height;$headerPointer++
								$portrait["header"][$headerPointer]=$record.dx;$headerPointer++
								$portrait["header"][$headerPointer]=$record.dy;$headerPointer++
								$bmpFile=Resolve-Path -path ("..\"+$record.sourceBmp)
								$sc5File=Resolve-newPath -path ("..\grapx\$($record.name)$($record.element).4bpp.gfx")
								$palFile=Resolve-Path -path ("..\grapx\tilesheets\karnimata.tiles.pl")
								$cmd="npx convertgfx --source `"$bmpfile`"  --slice.x $($record.sx) --slice.y $($record.sy) --slice.width $($record.width) --slice.height $($record.height) --fixedPalette `"$PalFile`" --targetScreen5 `"$sc5File`" --gamma 2.2"
								write-verbose $cmd
								$x=Invoke-Expression ($cmd)
								$portrait[$element]=Get-Content -path $sc5file -Encoding Byte;$imageOffset+=$portrait[$element].length
							}
							$portrait["header"][0]=$portrait["header"][0] -bor 0x8c
							write-verbose "header: $($portrait["header"] -join(","))"
							[byte[]]$data=$portrait["header"]+$portrait["face"]+$portrait["eyesOpen"]+$portrait["eyesClosed"]+$portrait["mouthOpen"]+$portrait["mouthClosed"]
							write-verbose "$($file.path) is $($data.length) bytes long"
							Set-Content -path $file.path -Value $data -Encoding byte
						}

					}
				}
				
				#add file to datalist if necessary
				if ($datatype.dsmdatalist)
				{	
					$datalist=add-DSMDataList -dsm $dsm -name $datatype.dsmdatalist	#add new, or get existing dataList
					if ( -not (resolve-path $file.path -ErrorAction SilentlyContinue))
					{	write-verbose "File `"$($file.path)`" not found"
					} else
						{write-verbose "Adding `"$($file.identity)`" to datalist `"$($datatype.dsmdatalist)`", and injecting it into the ROM space"
						$x=replace-dsmfile -dsm $dsm -dataList $datalist -path "$($file.path)" -updateFileSpace
					}
					if (-not $dataListUpdates.contains($dataType.dsmdataList)) {$dataListUpdates+=$dataType.dsmdataList} #mark for update
				}
			}
			break
		}
	
	}


	#Make index and inject into ROM
	if ($updateIndex)
	{	write-verbose "-==== Updating the ROM indexes ====-"
	
		write-verbose "datalist updates: $datalistupdates"
		$datalistName="index"
		$datalist=add-DSMDataList -dsm $dsm -name $datalistname
		foreach ($collectionName in $dataListUpdates)
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
		{	$masterIndex=new-u2RomMasterFileIndex
			$indexBlock=([int]$index.DsmBlock);$indexSegment=([int]$index.DsmSegment)
			write-verbose "Writing MasterIndex to block:$indexblock, segment:$indexsegment"
			write-verbose ($masterindex -join(","));
			write-DSMFileSpace -dsm $dsm -block $indexBlock -segment $indexSegment -data $masterIndex
		}
	}
	
	#close the ROM file and save DSM
	$null=$DSM|close-DSMFileSpace
	save-dsm -dsm $dsm -path $dsmPath

}

$dsm|get-DSMStatistics
$global:dsm=$dsm
EXIT
