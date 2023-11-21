#Convert Tiled map files to raw data file, and pack it with BB to .map.pck
#20231009;RomanVanDerMeulen aka shadow@fuzzylogic
<#
Example: convert all BX maps
.\convert-tmxtoraw16.ps1 -path "C:\Users\$($env:username)\OneDrive\Usas2\maps\Bx*.tmx" -targetPath ".\" -includeLayer ".*" -excludeLayer "(Objects|room numbers)" -pack
#>

[CmdletBinding()]
param
(	$path=".\*.tmx", #C:\Users\$($env:username)\OneDrive\Usas2\maps
	$targetPath="..\maps",
	$includeLayer=".*",
	$excludeLayer="(objects|room numbers)",
	$targetFileExtention="map",
	[switch]$pack=$false,
	$bitBusterPath=".\pack.exe"
)


#Take a Tiled .tmx file and write the raw Layer(s) data to a .map file of size mapXl*mapYl
function Convert-TmxFile
{	param
	(	$inFile,
		$outFile,
		$includeLayer,
		$excludeLayer
	)	

	write-verbose "$infile > $outFile" 
	[xml]$data=Get-Content $inFile
	$rawData=Convert-TmxLayers -data $data -includeLayer $includeLayer -excludeLayer $excludeLayer
	write-verbose "Writing RAW data to file" 
	$null=Set-Content -Value $rawdata -Path $outFile -Encoding Byte
}


#Convert Tmx XML layers to RAW byte data 
#in:  XML data, layers to include, layers to exclude
function Convert-TmxLayers
{	param
	(	$data,
		$includeLayer,
		$excludeLayer
	)	

	write-verbose "Map width: $($data.map.width)"
	write-verbose "Map height: $($data.map.height)"
	$fileLength=[uint16]$data.map.width * [uint16]$data.map.height
	write-verbose "Block length: $($fileLength*2)"

	#Initialize a block of raw data in bytes
	$rawData=[byte[]]::new($filelength*2)

	#Walk through each layer in descending order
	foreach ($layer in ($data.map.layer|where{($_.name -match $includeLayer) -and ($_.name -notmatch $excludeLayer) -and ([boolean]$_.visible -eq $false)}))
	{	write-verbose "Layer: $($layer.name)"	#Buffy was here
		$position=0	;#pointer in the byte array
		foreach ($tile in $layer.innertext.replace("`n","").split(","))
		{	$HL=[uint16]$tile
			if ($HL -ne 0)
			{	if ($convertToAddress)
				{	$HL--
					#$hl=$hl*4	#8pixels=4bytes
					$tilesPerRow=32;$TileLenX=8;$TileLenY=8;$pixelsPerByte=2;$bytesPerTile=$tileLenx*$TilelenY/$pixelsPerByte
					$hl=0x4000 + (($hl -band $tilesPerRow-1) * ($TileLenX/$pixelsPerByte) + ($hl -band ($tilesPerRow-1 -bxor 0xffff)) * $bytesPerTile)		
				}
				$L=$HL -band 255
				$H=$HL -shr 8
				
				$rawData[$position]=$L
				$rawData[$position+1]=$H
			}
			$position=$position+2
		}
	}
	return $rawdata
}


#tests
#$path="C:\Users\rvand\OneDrive\Usas2\maps\BS20.tmx"
#$targetPath="C:\Users\rvand\Usas2-main\maps"
$convertToAddress=$true

##### Main: #####
Write "Convert Tiled .tmx file to raw 16-bit data .map file and pack it to .map.pck (if -pack:`$true)"
write-verbose "Source: $path"
write-verbose "Target: $targetPath"
foreach ($file in gci $path -Include *.tmx)
{	write-host "$($file.basename);" -NoNewline
	$inFile=$file.fullname
	if (-not ($targetPath.substring($targetPath.length-1,1) -eq "\")) {$targetPath=$targetPath+"\"}
	$outFile="$targetPath$($file.basename).$targetFileExtention"
	Convert-TmxFile -infile $infile -outfile $outfile -includeLayer $includeLayer -excludeLayer $excludeLayer
	if ($pack)
	{	write-verbose "Packing file > $($file.directoryname)\$($file.basename).$targetFileExtention.pck"
		$packExe=(get-item $bitBusterPath).fullname
		pushd $targetPath
		$null=& $packExe ".\$($file.basename).$targetFileExtention"
		popd
	}
}

<#
$targetPath="C:\Users\rvand\Usas2-main\maps"
#Changed last hour
gci -path C:\Users\$($env:username)\OneDrive\Usas2\maps\* -include *.tmx|where{$_.LastWriteTime -gt (Get-Date).AddHours(-1)}|%{.\convert-tmxtoraw16.ps1 -path $_.fullname -verbose -pack}
gci -path C:\Users\$($env:username)\OneDrive\Usas2\maps\* -include *.tmx|where{$_.LastWriteTime -gt (Get-Date).AddDays(-2)}|%{.\convert-tmxtoraw16.ps1 -path $_.fullname -verbose -pack}

#From Worldmap
. .\Tiled-Functions.inc.ps1
$worldMap=get-TiledWorldMap -path "C:\Users\rvand\OneDrive\Usas2\maps\KarniMata.world"
foreach ($map in $worldmap.maps) {.\convert-tmxtoraw16.ps1 -path "C:\Users\$($env:username)\OneDrive\Usas2\maps\$($map.filename)" -targetpath $targetpath -verbose -pack}

[xml]$data=Get-Content C:\Users\rvand\OneDrive\Usas2\maps\BW24.tmx
$rawdata=Convert-TmxLayers -data $data -includeLayer $includeLayer -excludeLayer $excludeLayer
$global:rawdata=$rawdata
#$rawdata|format-hex

$file="C:\Users\rvand\OneDrive\Usas2\maps\BS20.tmx"
.\convert-tmxtoraw16.ps1 -path $file
#>



