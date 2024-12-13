##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
$global:usas2=get-Usas2Globals -force

#$tableProperties=[pscustomObject]@{ruinTileset=@{offset=0;length=1};ruinPalette=@{offset=1;length=1};ruinMusic=@{offset=2;length=1};ruinNAme=@{offset=3;length=13}}
$tableAttributes=[pscustomObject]@{numrec=32;reclen=16}
write ";RuinPropertiesLUT: tileset,palette,music,name"
for ($i=0;$i -lt $tableAttributes.numrec;$i++)
{	$ruinProps=$usas2.ruin|where{$_.ruinId -eq $i}
	if (-not ($ruinTileset=($usas2.tileset|where{$_.identity -eq $ruinProps.tileset}).id)) {$ruinTileset=0}
	if (-not ($ruinPalette=($usas2.palette|where{$_.identity -eq $ruinProps.palette}).id)) {$ruinPalette=0}
	if (-not ($ruinMusic=($usas2.music|where{$_.identity -eq $ruinProps.music}).id)) {$ruinMusic=0}
	if (-not ($ruinName=($ruinProps.name))) {$ruinName=""}
	write "DB $ruinTileset,$ruinPalette,$ruinMusic,`"$([string]($ruinName).PadRight(13," ").substring(0,13))`""
}
