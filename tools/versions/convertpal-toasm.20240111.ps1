# convert .pl file to az80 assembly tekst
# Shadow@FuzzyLogic
# 20231208-20231208

[CmdletBinding()]
param
(	
	[Parameter(ParameterSetName='file')]$path="..\grapx\tilesheets\sKarniMataPalette.PL"
)

##### Includes #####
#. .\Usas2-SharedFunctions.inc.ps1
#. .\DSM.ps1


##### Global properties #####
#$global:usas2=get-Usas2Globals
#$romfile="$(resolve-path "..\Engine\usas2.rom")" #\usas2.rom"


##### Functions #####



##### Main #####
foreach ($file in gci $path)
{	$pal=Get-Content $file -Encoding Byte
	$text=";$($file.name)`n"
	$text+="DB $(($pal|select -first 32|%{"`${0:x2}" -f $_}) -join (","))"
	$text
}