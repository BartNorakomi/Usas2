#A powershell version of romspace.js (laurens)
#Shadow@FuzzyLogic 20231118

[CmdletBinding()]
param
(	$romfile="..\engine\usas2.rom",[uint32]$bank=0
)

function get-RomFile
{	param ($romfile)
	if (-not ($file=get-item $romfile))
	{	write-error "File $romfile not found"
	} else
	{	$rom=[byte[]]::new($file.length)
		$fs=[io.file]::OpenRead($file.fullname)	#We'll use .net functions instead of get-content -enconding byte, since that's slooooow
		$null=$fs.read($rom,0,$rom.length)
		$fs.close()
		return $rom
	}
}

$global:rom=get-romfile -romfile $romfile
$totalUsed=0
[uint32]$bankSize=0x4000
[uint32]$numBanks=$rom.length/$bankSize
write-verbose "$romfile, size=$($rom.length)"

while ($bank -lt $numBanks)
{	[uint32]$bankAddress=$bank*$bankSize	#offsetAddress in ROM
	$used=$bankSize
	$spaceMarker=$rom[$bankAddress + $used - 1];
	if (($spaceMarker -eq 0) -or ($spacemarker -eq 0xff))
	{	while (($used -gt 0) -and ($rom[$bankAddress + $used - 1] -eq $spaceMarker))
		{	$used--
		}
	}
	$free=$banksize-$used
	$totalused+=$used
	[pscustomobject]@{bank=("{0:X2}" -f $bank);used="{0:X4}" -f $used;usedPerc="{0,3}" -f [uint32]($used/$banksize*100)+"%";free="{0:X4}" -f $free;freePerc="{0,3}" -f [uint32]($free/$banksize*100)+"%"}
	$bank++
}

write-verbose "Total usage: $totalused/$([uint32]($totalUsed/1024))KB, "

