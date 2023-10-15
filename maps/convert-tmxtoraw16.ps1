#Convert Tiled map files to raw data file, and pack it with BB to .map.pck
#20231009;RomanVanDerMeulen aka shadow@fuzzylogic
<#
Example: convert all BX maps
.\convert-tmxtoraw16.ps1 -path "C:\Users\rvand\OneDrive\Usas2\maps\Bx*.tmx" -targetPath ".\" -includeLayer ".*" -excludeLayer "(Objects|room numbers)" -pack
#>

[CmdletBinding()]
param
(	$path=".\*.tmx",
	$targetPath=".\maps",
	$includeLayer=".*",
	$excludeLayer="(objects|room numbers)",
	$targetFileExtention="map",
	[switch]$pack=$false
)


#Take a Tiled .tmx file and write the raw Layer(s) data to a .map file of size mapXl*mapYl
function Convert-TmxFile
{	param
	(	$inFile,
		$outFile,
		$includeLayer
	)	

	write-verbose "$infile > $outFile" 

	[xml]$data=Get-Content $inFile
	write-verbose "Map width: $($data.map.width)"
	write-verbose "Map height: $($data.map.height)"
	$fileLength=[uint16]$data.map.width * [uint16]$data.map.height
	write-verbose "$outFile file length: $($fileLength*2)"

	#Initialize a block of raw data in bytes
	$rawData=[byte[]]::new($filelength*2)

	#Walk through each layer in descending order
	foreach ($layer in ($data.map.layer|where{($_.name -match $includeLayer) -and ($_.name -notmatch $excludeLayer) -and ([boolean]$_.visible -eq $false)}))
	{	write-verbose "Layer: $($layer.name)"	#Buffy was here
		$position=0	;#pointer in the byte array
		foreach ($tile in $layer.innertext.split(","))
		{	$HL=[uint16]$tile
			if ($HL -ne 0 -and $HL -ne 0x0a)
			{	$L=$HL -band 255
				$H=$HL -shr 8
				$rawData[$position]=$L
				$rawData[$position+1]=$H
			}
			$position=$position+2
		}
	}
	$null=Set-Content -Value $rawdata -Path $outFile -Encoding Byte
	#return $rawdata
}


##### Main: #####
Write "Convert Tiled .tmx file to raw 16-bit data .map file and pack it to .map.pck (if -pack:`$true)"
foreach ($file in gci $path -Include *.tmx)
{	write-host "$($file.basename);" -NoNewline
	$inFile=$file.fullname
	if (-not ($targetPath.substring($targetPath.length-1,1) -eq "\")) {$targetPath=$targetPath+"\"}
	$outFile="$targetPath$($file.basename).$targetFileExtention"
	Convert-TmxFile -infile $infile -outfile $outfile -includeLayer $includeLayer -excludeLayer $excludeLayer
	if ($pack)
	{	write-verbose "Packing file"
		$null=.\pack.exe $outfile
	}
}

<#
Some extra's
gci -path C:\Users\rvand\OneDrive\Usas2\maps\* -include *.tmx|where{$_.LastWriteTime -gt (Get-Date).AddDays(-7)}
#Changed today
gci -path C:\Users\rvand\OneDrive\Usas2\maps\* -include *.tmx|where{$_.LastWriteTime -gt (Get-Date).AddDays(-1)}|%{.\convert-tmxtoraw16.ps1 -path $_.fullname -verbose -pack}
#>



