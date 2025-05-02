# Create one or more TiledTileSet.tsx files
# A custom script for the MSX Usas2 project
# Shadow@FuzzyLogic
# 20241121-20250225

<#
required manifest properties:
 ruin.<identity>.name
 ruin.<identity>.ruinId
 ruin.<identity>.TiledTileset
 tiledTileSet.<identity>.path
 tiledTileSet.<identity>.imageSource
 #>

[CmdletBinding()]
param
(	[Parameter(ParameterSetName='ruinid')]$ruinId, #UID number
    [Parameter(ParameterSetName='ruinname')]$ruinName, #name property String
    [Parameter(ParameterSetName='ruinIdentity')]$ruinIdentity, #IdentifierString
	[string]$TiledMapsLocation, #="C:\Users\$($env:username)\OneDrive\Usas2\maps",
	[string]$targetLocation="$TiledMapsLocation\",
	[switch]$forceOverWrite,
	[switch]$resetGlobals=$false
#	$usas2PropertiesFile="..\usas2-properties.csv"
)



##### Includes #####
. .\tiled-functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1

##### Global properties #####
if ($resetGlobals) {$global:usas2=$null}
$global:usas2=get-Usas2Globals
if (-not $tiledmapsLocation) {$tiledmapsLocation=get-U2TiledMapLocation} else {set-U2TiledMapLocation -path $TiledMapsLocation}
write-verbose "Tiled maps location: $tiledmapsLocation"

##### Functions #####

#Get a tiledTileset manifest
#note that all filters are based on REGEX
function get-U2TiledTileset
{	param
	(	[Parameter(ParameterSetName='identity')]$identity,
		[Parameter(ParameterSetName='id')]$id,
        [Parameter(ParameterSetName='name')]$name
	)
	if ($identity -ne $null) {$Manifest=$usas2.tiledTileSet|where{$_.identity -match $identity}}
	elseif ($id -ne $null) {$Manifest=$usas2.tiledTileset|where{$_.Id -match $id}}
	elseif ($name -ne $null) {$Manifest=$usas2.tiledTileset|where{$_.name -match $id}}
	return $Manifest
}



##### main: #####

#get the ruin manifest(s)
if ($ruinname)
{   if ($ruinName.gettype().IsArray) {$name=("^("+($ruinname -join ("|"))+")$")} else {$name="^$ruinname`$"}
    $ruinManifest=get-U2Ruin -name $name
}
elseif ($ruinId)
{   if ($ruinId.gettype().IsArray) {$id=("^("+($ruinId -join ("|"))+")$")} else {$id="^$ruinId`$"}
    $ruinManifest=get-U2Ruin -id $Id
}
elseif ($ruinIdentity)
{   if ($ruinIdentity.gettype().IsArray) {$identity=("^("+($ruinIdentity -join ("|"))+")$")} else {$identity="^$ruinIdentity`$"}
    $ruinManifest=get-U2Ruin -identity $identity
}

# $ruinManifest;exit

# get-U2TiledTileset -id $ruinManifest.ruinid
# $TiledTileSetManifest=get-U2TiledTileset -identity $ruinManifest.tiledTileset
foreach ($this in $RuinManifest)
{   $TiledTileSetManifest=get-U2TiledTileset -identity $this.tiledTileset   
    $global:TiledTileSetManifest=$TiledTileSetManifest
    # new-TiledTileSet	$name="",$tileWidth=8,$tileHeight=8,[Parameter(Mandatory,Position=0,ValueFromPipeline)]$imagePath
    write-verbose "TiledTileset name=$($TiledTileSetManifest.name), width=$($TiledTileSetManifest.tileWidth), height=$($TiledTileSetManifest.tileHeight), imagePath=$($TiledTileSetManifest.imageSourceFile)"
    $TiledTileset=new-TiledTileSet -name $TiledTileSetManifest.name -tileWidth $TiledTileSetManifest.tileWidth -tileHeight $TiledTileSetManifest.tileHeight -imagePath $TiledTileSetManifest.imageSourceFile
    write-verbose $TiledTileset.tileset.OuterXml
    #$path=resolve-NewPath -path (Invoke-Expression -Command `"$($TiledTileSetManifest.defaultLocation)\$($TiledTileSetManifest.name).tsx`")
    $path=resolve-newpath -path "$TiledMapsLocation\$($TiledTileSetManifest.path)"
    write-verbose "file: $path"
    set-TiledTileSet -tileset $TiledTileset -path $path
}
