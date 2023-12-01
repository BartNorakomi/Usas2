# Usas2 shared functions
# shadow@fuzzylogic 20231024-20231201

# 20231101
# Create and return an Object (with empty properties)
function new-CustomObject
{	param ($name,$propertyNames)
	$o=[PSCustomObject]@{ObjectName=$name}
	$propertyNames|%{$o|add-member NoteProperty $_ $null}
	return $o
}

# 20231101
# Return a hastable of property=value from CSV records (e.g. globalProperties)
function new-CsvHash
{	param ($CsvRecord)
	$hash=@{};$CsvRecord|%{$hash+=@{$_.propertyname=$_.propertyvalue}}
	return $Hash
}

# 20231101
# Return an object created out of CSV records (e.g. globalproperties)
#the CSV should have "name","identiy","propertyname","propertyvalue" records
function convert-CsvToObject
{	param ($objname="Default",$csv)

	#Create root object
	$names=$csv.name|select -Unique
	$rootObj=new-CustomObject -propertyNames $names -name $objname

	#Create child objects
	foreach ($name in $names)
	{	$nameRecords=$csv|where{$_.name -eq $name}
		$nameIdentities=$nameRecords.identity|where{$_ -notmatch "(\*|\(|\)|\||\\)"}|select -Unique
		$rootObj.$name=@()
		foreach ($identity in $nameIdentities)
		{ 
			$identityRecords=$nameRecords|where{$Identity -match "^"+$_.identity+"$"}
			#$identityRecords=$nameRecords|where{$Identity -match $_.identity}
			$identityHash=new-CsvHash -CsvRecord $identityRecords
			$identityHash+=@{Identity=$identity}
			$rootObj.$name+=[pscustomobject]$identityHash
		}
	}
	return $rootObj
}


##### USAS2 specific Functions #####
$global:WorldMapColumnNames="AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ" -split(" ")

function get-Usas2Globals
{	param ($usas2PropertiesFile="..\usas2-properties.csv")
	$usas2Properties=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
	$global:usas2=convert-CsvToObject -objname usas2 -csv $usas2Properties
	return $usas2
}

# return roomName located at(x,y)
function get-roomName
{	param ($x,$y)
	return $WorldMapColumnNames[$x]+"0$($y+1)".substring(([string]$y).length-1,2)
}


# return the coordinates of a room by its name
# in:	roomName (filename base)
#out:	object (x,y)
function get-roomLocation
{	param ($name)
	$x=$global:WorldMapColumnNames.IndexOf($name.substring(0,2).toupper())
	#"0$($y+1)".substring(([string]$y).length-1,2)
	$y=[uint32]$name.substring(2,2)
	return [pscustomobject]@{x=$x;y=$y}
}


# WorldMap
#Return the WorldMap (CSV data) as a matrix[y][x]=roomType/RuinId
function get-roomMatrix
{	param ($mapsource)
	$roomMatrix=$mapsource;$index=0
	foreach ($row in $mapSource)
	{	$roomMatrix[$index]=$roomMatrix[$index].split("`t")
		$index++
	}
	return $roomMatrix
}

# WorldMap
#Return the WorldMap (CSV data) as a hashTable Index [filename]=roomType/RuinId
function get-roomHashTable
{	param ($mapsource,$sourceOffsetX=0,$sourceOffsetY=0)
	$y=-$sourceOffsetY
	foreach ($row in $mapSource)
	{	$x=-$sourceOffsetX
		forEach ($column in $row.split("`t"))
		{	#write-host $column
			if ($column)
			{	$roomname=get-roomName -x $x -y $y
				@{$roomName=$column} #[pscustomobject]@{ruinId=$column-band0x1f;roomType=$colum-band0xe0;x=$x;y=$y}}
			}
			$x++
		}
		$y++
	}
}

# WorldMap
# Return the WorldMap (CSV data) as a array of map objects
# in:	mapsource=CSV input data
#		optional: X/Y offsets if the CSV matrix data doesn't start at 0,0
# out:	Array of object (roomname,ruinId,roomType,XposWorldmap,YposWorldmap)
function get-roomMaps
{	param ($mapsource,$sourceOffsetX=0,$sourceOffsetY=0)
	$y=-$sourceOffsetY
	foreach ($row in $mapSource)
	{	$x=-$sourceOffsetX
		forEach ($column in $row.split("`t"))
		{	#write-host $column
			if ($column)
			{	$roomname=get-roomName -x $x -y $y
				[pscustomobject]@{name=$roomname;ruinId=$column-band0x1f;roomType=$column-band0xe0;x=$x;y=$y}
			}
			$x++
		}
		$y++
	}
}


# Get WorldMapRooms > same as above, but with some presets and a filter on ruin and room
function get-U2WorldMapRooms
{	param ($ruinId=".*",$roomId=".*")
	$WorldMapSource=get-content ("..\"+($usas2.worldmap|where{$_.identity -eq "global"}).sourcefile)
	$roomMaps=get-roommaps -mapsource $WorldMapSource
	$roomMaps|where{($_.ruinId -match $ruinId) -and ($_.roomType -match $roomId)}
}


# ROOM MAP FILE INDEX 20231201
# return a WorldMap index of the files in a datalist as byte array of records (id(xxyy)[16],block[8],segment[8]) 
function get-WorldMapRoomIndex
{	param
	(	[Parameter(Mandatory,ValueFromPipeline)]$DSM,$datalistName=".*"
	)
	$IndexRecordLength=4
	$datalist=get-dsmdatalist -dsm $dsm -name $datalistName
	#$numIndexRecords=$datalist.allocations.count
	if ($datalist.allocations)
	{	$indexRecords=[byte[]]::new(0) #::new($numIndexRecords*$IndexRecordLength)
		foreach ($this in $datalist.allocations)
		{	write-verbose $this.name
			$location=get-roomLocation $this.name.substring(0,4)
			[uint32]$id=$location.x*256+$location.y
			[byte]$block=$this.block
			[byte]$segment=$this.segment
			write-verbose "ID:$id, block:$block, seg:$segment"
			$indexRecords+=[byte]$location.x,[byte]$location.y,$block,$segment
		}
	}
	return $indexRecords
}
