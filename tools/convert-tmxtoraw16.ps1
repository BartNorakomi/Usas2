#Convert Tiled map files to raw data file, and pack it with BB to .map.pck
#20231009-20240328;RomanVanDerMeulen aka shadow@fuzzylogic
<#
Example: convert all BX maps
.\convert-tmxtoraw16.ps1 -path "C:\Users\$($env:username)\OneDrive\Usas2\maps\Bx*.tmx" -targetPath ".\" -includeLayer ".*" -excludeLayer "(Objects|room numbers)" -pack
#>

[CmdletBinding()]
param
(	$path=".\*.tmx", #C:\Users\$($env:username)\OneDrive\Usas2\maps
	$targetPath="..\maps",
	$includeLayer=".*",
	$excludeLayer="(objects|object|room numbers)",
	$targetFileExtention="map",
	[switch]$pack=$false,
	$bitBusterPath=".\pack.exe",
	[switch]$verboseMore
)

##### Includes #####
. .\Tiled-Functions.inc.ps1
. .\Usas2-SharedFunctions.inc.ps1

##### Functions #####



#Take a Tiled .tmx file and write the raw Layer(s) data to a .map file of size mapXl*mapYl
function Convert-TmxFile
{	param
	(	$inFile,
		$outFile,
		$includeLayer,
		$excludeLayer
	)	

	write-verbose "Reading Tiled file $infile"
	$TiledMap=get-TiledMap -path $infile #[xml]$data=Get-Content $inFile
	$roomName=(get-item $inFile).basename
	
	#first, get default ruin props
	$RoomProps=get-roomDefaultProperties -roomName $roomName
	write-verbose "default ruinId/roomType: $($roomProps[0])"
	#next insert optional tmxMapProperties
	$roomProps=convert-TmxMapProperties -TiledMap $TiledMap -roomProps $roomProps
	write-verbose "Room name: $roomName, ruinId/roomType: $($roomProps[0])"
	#convert the tiles in this map
	$TiledLayerData=Convert-TmxLayers -data $tiledMap -includeLayer $includeLayer -excludeLayer $excludeLayer
	write-verboseMore "Tiles Block length: $($TiledLayerData.length)"
	#convert objects in this map
	$RoomObjects=convert-TmxObjects -tiledMap $tiledMap
	write-verboseMore ($RoomObjects -join(","))
	write-verbose "Writing to file $outfile" 
	$null=Set-Content -Value ($roomProps+$TiledLayerData+$roomObjects) -Path $outFile -Encoding Byte
}

# Get roomproperties as 8bytes block
# Depends on script globals $worldmap,$usas2
# in:	roomname (xxyy)
# out:	8 bytes data block
function get-roomDefaultProperties
{	param
	(	$roomName
	)
	$room=$worldmap|where{$_.name -eq $roomname}
	#$ruinIdentity=($usas2.ruin|where{$_.ruinId -eq $room.ruinid}).identity
	$ruinIdRoomType=[byte](($room.ruinid -band 0x1F) -bor ($room.roomtype -band 0xe0) -band 255)
	#$ruinProperties=get-U2ruinProperties -ruinid $room.ruinid #-identity $ruinIdentity
	
	$data=[byte[]]::new(8)
	$data[0]=$ruinIdRoomType
	# 20240430;ro;this should be "0" (null, or default). So, I rem'd them out
	#$data[1]=$ruinProperties.tileset
	#$data[2]=$ruinProperties.music
	#$data[3]=$ruinProperties.palette
	return ,$data
}


# 20240108
# Convert optional map properties and put in roomProps header block
function convert-TmxMapProperties
{	param
	(	$TiledMap,$roomProps
	)
	if ($tileset=$TiledMap.map.properties.property|where{$_.name -eq "tileset"})
	{	write-verboseMore "Alternative tileset: $($tileset.value)"
		$roomProps[1]=$tileset.value
	}
	if ($music=$TiledMap.map.properties.property|where{$_.name -eq "music"})
	{	write-verboseMore "Alternative music: $($music.value)"
		$roomProps[2]=$music.value
	}
	if ($palette=$TiledMap.map.properties.property|where{$_.name -eq "palette"})
	{	write-verboseMore "Alternative palette: $($palette.value)"
		$roomProps[3]=$palette.value
	}
	if ($roomType=$TiledMap.map.properties.property|where{$_.name -eq "roomType"})
	{	write-verboseMore "Alternative roomType: $($roomType.value)"
		$roomProps[0]=($roomProps[0] -band 0x1F) -bor ($roomType.value -shl 5 -band 0xe0)
	}
	return ,$roomProps
}


#Convert Tmx XML layers to RAW byte data 
#in:  XML data, layers to include, layers to exclude
function Convert-TmxLayers
{	param
	(	$data,
		$includeLayer,
		$excludeLayer
	)	
	write-verbose "Map width:$($data.map.width), height:$($data.map.height)"
	$fileLength=[uint16]$data.map.width * [uint16]$data.map.height
	#Initialize an array of raw data in bytes
	$rawData=[byte[]]::new($filelength*2)

	#Walk through each layer in descending order
	foreach ($layer in ($data.map.layer|where{$_.name -and ($_.name -match $includeLayer) -and ($_.name -notmatch $excludeLayer) -and ([boolean]$_.visible -eq $false)}))
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
	return ,$rawdata
}

#20231231
# Convert objects from the "object" layer to raw data
# in:	TiledMap
# out:	binary block of data, null terminated
# let wel, de engine moet echt de software sprites eerst afhandelen, en die moeten van boven naar beneden gesorteerd worden.
function convert-TmxObjects
{ param ($tiledMap)
	write-verbose "Converting Objects"
	[byte[]]$dataBlock=[byte]0
	$objects=get-RoomObjects -tiledmap $tiledmap|sort Uid -Descending #sort so software sprite objects come first
	$global:objects=$objects	#ro: is this for debugging? if so, disable it
	foreach ($object in $objects)
	{	$uid=$object.uid #get UID from map
		if ($roomobject=$usas2.roomobject|where{$_.uid -eq $uid}) #get object info from globalVars
		{	write-verbose "Object Uid=$($roomobject.uid), id=$($roomobject.identity), class=$($roomobject.objectclass)"
			$class=$U2objectClassDefinitions.$($roomobject.objectclass)	#get the class
			$blockLength=($class|measure -sum numBytes).sum
			write-verbosemore "Class properties: $($class.propertyname)"
			write-verboseMore "Number of bytes for this class: $blockLength"
			$data=[byte[]]::new($blockLength+1)
			$data[0]=$uid	#first byte is object's ID
			foreach ($classProperty in $class)
			{	
				#if ($classProperty.propertyType -eq "default") {$value=$object.($classProperty.propertyName)}
				#elseif ($classProperty.propertyType -eq "custom") {$value=$object.properties.property|where{$_.name -eq $classProperty.propertyName}}
				$value=$object.($classProperty.propertyName)
				#Does this object have the property value set?
				if (-not $value) {$value=$classProperty.propertyValue} #if not set, take default value from class
				#Pre-conversion
				switch ($classProperty.preConversion)
				{	toTile	#convert value to Tile number
					{	$value=$value/8 -band 255
					}
					half	#convert value in half
					{	$value=$value/2 -band 255
					}
					Default {}
				}
				write-verboseMore "$($classProperty.propertyName)=$value"
				#Put number of bytes in byte Array
				for ($b=0;$b -lt $classProperty.numbytes;$b++) {$data[$classProperty.offset+$b+1]=$value -band 255;$value=$value -shr8}
			}
			#Post-conversion
			#<tba>
			$datablock=$data+$datablock
		}
	}
	return ,$datablock
}

# Get all valid room objects (objects with a UID) and merge all properties at object rool level
#in:	TiledMap (xml)
#out:	Array of objects
function get-RoomObjects
{	param ($tiledMap)
	#$tiledMap.map.objectgroup.object
	$objects=($tiledMap.map.objectgroup|where{-not $_.visible}).object|where{($_.properties.property.name -eq "uid") -and ($_.visible -ne "0" )}
	foreach ($object in $objects)
	{	$object.properties.property|%{add-member -InputObject $object -membertype NoteProperty -name $_.name -value ([int]$_.value)}
		$object
	}
}


# 20231229
# Import the objectClass definitions from .csv file and return as an object
function get-U2objectClassDefinitions
{	param ([string]$usas2objectclassfile="..\usas2-objectclass.csv", [switch]$force)
	if (-not ($U2objectClassDefinitions.objectname -eq "u2objectclass") -or $force)
	{	write-verbose "Retrieving objectClass properties from file"
		$usas2objectclass=Import-Csv -Path $usas2objectclassFile -Delimiter `t|where{$_.enabled -eq 1}
		$names=($usas2objectclass).name|select -unique
		$rootObj=new-CustomObject -propertyNames $names -name "u2objectclass"
		foreach ($name in $names)
		{	$records=$usas2objectclass|where{$_.name -eq $name}
			$rootObj.$name=$records|%{[pscustomobject]@{propertyName=[string]$_.propertyName;propertyType=[string]$_.propertyType;propertyValue=[uint16]$_.propertyValue;offset=[uint32]$_.offset;numBytes=[uint32]$_.numBytes;preConversion=[string]$_.preConversion}}
		}
		$U2objectClassDefinitions=$rootObj
	}
	return $U2objectClassDefinitions
}


##### Script globals #####
$convertToAddress=$true
$usas2=get-Usas2Globals -force
$U2objectClassDefinitions=get-U2objectClassDefinitions -force
$WorldMap=get-roomMaps -mapsource (get-content ("..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile))
$global:U2objectClassDefinitions=$U2objectClassDefinitions
$global:worldmap=$worldmap

##### Main: #####
#tests
#$path="C:\Users\rvand\OneDrive\Usas2\maps\Br21.tmx"
#$tiledmap=get-tiledmap -path $path
#get-RoomObjects -tiledmap $tiledmap
#$tiledMap.map.objectgroup.object.properties.property|%{[pscustomobject]@{$_.name=$_.value}}
#exit

<#$objectData=convert-TmxObjects -tiledMap $tiledmap
$objectdata -join(",")
$global:usas2=$usas2
$global:tiledmap=$tiledmap
exit
#$targetPath="C:\Users\rvand\Usas2-main\maps"
#>
Write-verbose "Convert Tiled .tmx file to raw 16-bit data .map file and pack it to .map.pck (if -pack:`$true)"
write-verbose "Source: $path. Target: $targetPath. Include layers: $includelayer. Exclude layers: $excludelayer"

foreach ($file in gci $path -Include *.tmx)
{	#write-host "$($file.basename);" -NoNewline
	$inFile=$file.fullname
	if (-not ($targetPath.substring($targetPath.length-1,1) -eq "\")) {$targetPath=$targetPath+"\"}
	$outFile="$targetPath$($file.basename).$targetFileExtention"
	Convert-TmxFile -infile $infile -outfile $outfile -includeLayer $includeLayer -excludeLayer $excludeLayer
	if ($pack)
	{	write-verbose "Packing file > $targetPath$($file.basename).$targetFileExtention.pck"
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
foreach ($map in $worldmap.maps) {.\convert-tmxtoraw16.ps1 -path "C:\Users\$($env:username)\OneDrive\Usas2\maps\$($map.filename)" -verbose -pack}

[xml]$data=Get-Content C:\Users\rvand\OneDrive\Usas2\maps\BW24.tmx
$rawdata=Convert-TmxLayers -data $data -includeLayer $includeLayer -excludeLayer $excludeLayer
$global:rawdata=$rawdata
#$rawdata|format-hex

.\convert-tmxtoraw16.ps1 -path "C:\Users\rvand\OneDrive\Usas2\maps\BS20.tmx" -verbose
#>



