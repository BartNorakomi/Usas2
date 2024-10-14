# convert .pl file to az80 assembly tekst
# Shadow@FuzzyLogic
# 20231208-20241014

[CmdletBinding()]
param
(	
	[Parameter(ParameterSetName='file')]$path="..\grapx\tilesheets\KarniMata.tiles.PL",
	[switch]$toAsm,
	[switch]$to8bitRgb,
	$inputFileType="msx" #unused atm
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
$escape = [Char]0x1B

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
		#write-host "Palette file: $($file.name)"
		$rgb=@(0..15)
		for ($color=0;$color -lt 16;$color++)
		{	$g=$pal[$color*2+1] -band 7;$r=$pal[$color*2+0] -shr 4 -band 7;$b=$pal[$color*2+0] -band 7
			$msxRgb=[pscustomobject]@{r=$r;g=$g;b=$b}
			$pcRgb=[pscustomobject]@{r=[math]::Round($r /7*255);g=[math]::Round($g /7 *255);b=[math]::Round($b /7 *255);}
			$rgb[$color]=[pscustomobject]@{
			num=$color;
			msxRgb9bit=$msxRgb;
			pcRgb24bit=$pcRgb;
			pcHex="{0:x2}" -f [byte]$pcrgb.r + "{0:x2}" -f [byte]$pcrgb.g  + "{0:x2}" -f [byte]$pcrgb.b;
			output="$escape[48;2;$($pcrgb.r);$($pcrgb.g);$($pcrgb.b)m      $escape[0m"
			}
		}
		$rgb
	}
}




