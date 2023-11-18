# shared functions
# 20231024-20231101;shadow@fuzzylogic

# 20231101
# Create and return an Object (with empty properties)
function new-CustomObject
{              param ($name,$propertyNames)
                $o=[PSCustomObject]@{ObjectName=$name}
                $propertyNames|%{$o|add-member NoteProperty $_ $null}
                return $o
}

# 20231101
# Return a hastable of property=value from CSV records (e.g. globalProperties)
function new-CsvHash
{              param ($CsvRecord)

                $hash=@{};$CsvRecord|%{$hash+=@{$_.propertyname=$_.propertyvalue}}
                return $Hash
}

# 20231101
# Return an object created out of CSV records (e.g. globalproperties)
#the CSV should have "name","identiy","propertyname","propertyvalue" records
function convert-CsvToObject
{              param ($objname="Default",$csv)

                #Create root object
                $names=$csv.name|select -Unique
                $rootObj=new-CustomObject -propertyNames $names -name $objname

                #Create child objects
                foreach ($name in $names)
                {              $nameRecords=$csv|where{$_.name -eq $name}
                               $nameIdentities=$nameRecords.identity|where{$_ -notmatch "(\*|\(|\)|\||\\)"}|select -Unique
                               $rootObj.$name=@()
                               foreach ($identity in $nameIdentities)
                               {              #$match=$identity
                                               #if ($match -notmatch "^\^") {$match="^"+$match} 
                                               #if ($match -notmatch "\$$") {$match=$match+"$"}
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

# return roomName located at(x,y)
function get-roomName
{	param ($x,$y)
	$rowNames="AAABACADAEAFAGAHAIAJAKALAMANAOAPAQARASATAUAVAWAXAYAZBABBBCBDBEBFBGBHBIBJBKBLBMBNBOBPBQBRBSBTBUBVBWBXBYBZ"
	return $rownames.substring($x*2,2)+"0$($y+1)".substring(([string]$y).length-1,2)
}

# WorldMap
#Return the mastermap as a matrix[y][x]=roomType/RuinId
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
#Return the masterMap as a hashTable Index [filename]=roomType/RuinId
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
#Return the masterMap as a array of map objects
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

exit

<# test stuff
$global:roomMaps=get-roomMaps -mapsource $mapsource
#$global:roomHash=get-roomHashTable -mapsource $mapsource
#$global:roomMatrix=get-roomMatrix -mapsource $mapsource

$usas2PropertiesFile=".\usas2-properties.csv"
$global:usas2Properties=Import-Csv -Path $usas2PropertiesFile -Delimiter `t|where{$_.enabled -eq 1}
$global:usas2=convert-CsvToObject -objname usas2 -csv $usas2Properties

#>