# convert .pl file to az80 assembly tekst
# Shadow@FuzzyLogic
# 20231208-20231208

[CmdletBinding()]
param
(	
	[Parameter(ParameterSetName='file')]$path="..\grapx\tilesheets\sKarniMataPalette.PL",
	[switch]$toAsm,
	[switch]$to8bitRgb
)

##### Includes #####
#. .\Usas2-SharedFunctions.inc.ps1
#. .\DSM.ps1


##### Global properties #####
#$global:usas2=get-Usas2Globals
#$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"


##### Functions #####

<#
#lemniscate:
$colors=0xff5200,0xffba00,0xffe073,0x272752,0x525273,0x73739b,0x9b9bba,0xffffff,0x0079bd,0x00a0e2,0x00bdfe,0x383711,0x5b5930,0x78784d,0xaaa37d,0x000000
$text="DW ";$colors|%{$text+=",0x{0:X4}" -f (([math]::floor($_ -shr 8 -band 0x0000ff /255 *7) -shl 8) -bor ([math]::floor($_ -shr 16 -band 0x0000ff /255 *7) -shl 4) -bor ([math]::floor($_ -band 0x0000ff /255 *7)))}
#>


##### Main #####

foreach ($file in gci $path)
{	$pal=Get-Content $file -Encoding Byte
	write-host $file
	if ($toasm)
	{	$text=";$($file.name)`n"
		$text+="DB $(($pal|select -first 32|%{"`${0:x2}" -f $_}) -join (","))"
		$text
	}

	if ($to8bitRgb)
	{	write-verbose "to8bitrgb"
		$rgb=@(0..15)
		for ($color=0;$color -lt 16;$color++)
		{	$rgb[$color]=[pscustomobject]@{
				number=$color;
				msxRgb=[pscustomobject]@{g=$pal[$color*2+1] -band 7;r=$pal[$color*2+0] -shr 4 -band 7;b=$pal[$color*2+0] -band 7}
				pcRgb=[pscustomobject]@{r=[math]::Round(($pal[$color*2+0] -shr 4 -band 7) /7*255);g=[math]::Round(($pal[$color*2+1] -band 7) /7*255);b=[math]::Round(($pal[$color*2+0] -band 7) /7*255);}
			}
		}
		$rgb
	}
}




