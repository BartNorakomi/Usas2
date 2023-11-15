#DataManagementSystem
#Shadow@FuzzyLogic
#20231027-20231030  

# DMS OBJECT
#Initiate a new DMS object
function new-Dms
{   param
    (   [string]$name,
        [uint32]$BlockSize=16KB,
        [uint32]$numBlocks=10,
        [uint32]$SegmentSize=512 #bytes   
    )
        [uint32]$numSegmentsPerBlock=$Blocksize/$SegmentSize
        $SegmentAllocationTable=new-DmsSegmentAllocationTable -numBlocks $numBlocks -numSegmentsPerBlock $numSegmentsPerBlock
        return [psobject]@{name=$name;blocksize=$blocksize;numblocks=$numblocks;segmentSize=$segmentSize;numSegmentsPerBlock=$numSegmentsPerBlock;segmentAllocationTable=$SegmentAllocationTable;dataList=@()}
}

# DMS OBJECT
#Decommission an existing DMS object
function remove-dms
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$Dms
    )
    #do some segment checks first... (todo)
    $dms=$null
    return $true
}

# DMS OBJECT
# Return an empty SatRecord
function new-DmsSegmentAllocationRecord
{   param   ( [uint32]$numSegmentsPerBlock
            )
    return  [pscustomobject]@{numfree=$numSegmentsPerBlock;alloc=@(0)*$numSegmentsPerBlock}
}

# DMS OBJECT
# Initialize and return empty SAT
function new-DmsSegmentAllocationTable
{   param ([uint32]$numBlocks,[uint32]$numSegmentsPerBlock)
    for ($i=0;$i -lt $numblocks;$i++)
    {   new-DmsSegmentAllocationRecord -numSegmentsPerBlock $numSegmentsPerBlock
    }
}

# DMS OBJECT
# Save DMS space as a file
function save-dms
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$Dms,
        $path
    )
	if (-not $path) {$path=$dms.name}
	write-verbose "saving DMS as $path"
	
    ConvertTo-Json -InputObject $dms|Set-Content "$($path).dms"
}

# DMS OBJECT
# Load DMS space from a file
function load-dms
{   param
    (   
        [Parameter(Mandatory)]$path
    )
    $dms=get-content "$($path).dms" |ConvertFrom-Json
    return $dms
}


# SEGMENT
# Exclude a whole block from the allocationTable
function exclude-Dmsblock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$Dms,
        [Parameter(Mandatory)]$block
    )
    lock-DmsSegment -dms $dms -block $block -segment 0 -length $dms.numSegmentsPerBlock
    return  
}

# SEGMENT
# Lock a segmentChain
#in: DMS, block, segment, length
function lock-DmsSegment
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$Dms,
        [Parameter(Mandatory)]$block,
        [Parameter(Mandatory)]$segment,
        [Parameter(Mandatory)]$length
    )
    $SatRecord=$dms.SegmentAllocationTable[$block]
    if ($SatRecord.numfree -lt $length)
    {   write-error "Block free space capacity is to low"
    } else
    {   $freeCount=get-DmsFreeSegmentChain -SatRecord $SatRecord -startSegment $segment
        if ($length -gt $freeCount)
        {   write-error "SegmentChain with length $length doesn't fit in this block"
            return
        } else
        {   for ($i=$0;$i -lt $length;$i++)
            {   $SatRecord.alloc[$segment+$i]=$i+1
                $SatRecord.numfree--
            }
            return $SatRecord
        }
    }
}


# SEGMENT
# UnLock a segmentChain
#in: DMS, block, segment
function unLock-DmsSegment
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$Dms,
        [Parameter(Mandatory)]$block,
        [Parameter(Mandatory)]$segment
    )
    $SatRecord=$dms.SegmentAllocationTable[$block]
    $length=get-DsmAssignedSegmentChain -satrecord $satrecord -startsegment $Segment
    #if ($length)
    #{   #write-host "unlock $length"
        while ($length)
        {   $satRecord.alloc[$length-1]=0
            $length--
            $satRecord.numfree++
        }
    #}
    return
}

# SEGMENT
# Get the length of a segmentChain (either free, or assigned)
function get-DmsSegmentChain
{   param
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $startSegment
    )
    if ($SatRecord.alloc[$startSegment] -eq 0)
    {   return get-DmsFreeSegmentChain -satrecord $satrecord -startsegment $startSegment
    }   else
    {   return get-DsmAssignedSegmentChain -satrecord $satrecord -startsegment $startSegment
    }
}

# SEGMENT
# return the length of a segmentChain of free records
function get-DmsFreeSegmentChain
{   param
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $startSegment
    )
    $numSeg=$SatRecord.alloc.length-$startSegment
    if ($numseg -lt 1)
    {   write-error "Available number of allocations too low"
        return
    }
    $count=0
    while (($startSegment+$count -lt $SatRecord.alloc.length) -and ($SatRecord.alloc[$startSegment+$count] -eq 0))
    {   $count++        
    }
    return $count
}

# SEGMENT
#Get the length of a segmentChain of assigned records
function get-DsmAssignedSegmentChain
{   param 
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $startSegment
    )   if ($SatRecord.alloc[$startSegment] -ne 1)
        {   #not the beginning of a segmentAllocationBlock
            return  
        }
        $count=1
        while (($startSegment+$count -lt $SatRecord.alloc.length) -and ($SatRecord.alloc[$startSegment+$count] -eq ($SatRecord.alloc[$startSegment+$count-1]+1)))
        {   $count++
        }
        return $count
}

# SEGMENT
#Look in a SatRecord if there's a spot free
#in:  SatRecord,length of records
#out: -1, not found else index@satrecord
function find-DmsFreeSegment
{    param 
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $length
    )
    if ($length)
    {   $index=0
        while ($SatRecord.alloc.length -ge $index+$length)
        {   $count=get-DmsFreeSegmentChain -SatRecord $SatRecord -startSegment $index
            if ($count+1 -gt $length) {return $index;break}
            $index++
        }
    }
    return -1
}


# ALLOCATE
# Find a space big enough
function find-DmsFreeSpace
{   param
    (
    [Parameter(ParameterSetName='dms',Mandatory,ValueFromPipeline)]$dms,
    $lengthBytes
    )
    if ($length=[int][Math]::Ceiling($lengthBytes/$dms.segmentSize))
    {   $block=0;$segment=0
        foreach ($SatRecord in $dms.segmentAllocationTable)
        {   if ($SatRecord.numfree+1 -gt $length)
            {   if (($startSegment=find-DmsFreeSegment -SatRecord $SatRecord -length $length) -ne -1)
                {    #$segmentRecord|lock-DmsSegment -segment $startSegment -length $length
                    return @{block=$block;segment=$startSegment;length=$length};break;
                }
            }
            $block++
        }
    } else
    {   return $false
    }
}


# ALLOCATE
# Reserve and return a piece of blockspace
# in:   Dms object, length in bytes
# out:  array (block,segment,length)
#       $false=no freespace found
function alloc-DmsSpace
{   param
    (
    [Parameter(ParameterSetName='dms',Mandatory,ValueFromPipeline)]$dms,
    $lengthBytes
    )
    if ($space=find-DmsFreeSpace -dms $dms -lengthBytes $lengthBytes)
    {   $null=lock-DmsSegment -dms $dms -block $space.block -segment $space.segment -length $space.length
        return $space
    } else
    {   return $false
    }
}


# DATA LIST
# Return an empty dataListRecord
function new-DmsDataList
{   param   (   $name=""
            )
    return  [pscustomobject]@{name=$name;allocations=@()} #block=0;segment=0;length=0}
}

# DATA LIST
# Add a new dataList to an existing DMS object
function add-DmsDataList
{   param
    (	[Parameter(ParameterSetName='dms',Mandatory,ValueFromPipeline)]$dms,
		$name=""
    )
    $list=new-DmsDataList -name $name
	$dms.dataList+=$list
	return $dms.datalist|where{$_.name -eq $name}
}

# DATA LIST
# add an existing allocation to an existing dataList
function add-DmsDataListAllocation
{   param
    (	[Parameter(ParameterSetName='dms',Mandatory,ValueFromPipeline)]$dms,
		[Parameter(ParameterSetName='dms',Mandatory)]$dataListName="",
		[Parameter(ParameterSetName='dmsDataList',Mandatory,ValueFromPipeline)]$dataList,
		$allocation,
		$name="",$block=0,$segment=0,$length=0
    )
	if ($datalistname) {$datalist=$dms.datalist|where{$_.name -eq $datalistname}}
	if (-not ($datalist.allocations|where{$_.name -eq $name}))
	{	if (-not $allocation) {$allocation=@{block=$block;segment=$segment;length=$length}}
		$datalist.allocations+=[pscustomobject]($allocation+@{name=$name})
	}
	return
}

# DATA LIST
# Add one, or more file(s) to DMS and optional datalist
function add-DmsFile
{   param
    (	[Parameter(ParameterSetName='dms',Mandatory,ValueFromPipeline)]$dms,
		$dataListName="", $path, $files, $filelist
	)
	$datalist=$dms.dataList|where{$_.name -eq $datalistname}
	if (-not $files) {$Files=gci $path}
	foreach ($file in $Files)
	{	if ($alloc=$dms|alloc-DmsSpace -lengthBytes $file.length)
		{	if ($datalist)
			{	$null=$DataList|add-DmsDataListAllocation -name $file.name -allocation $alloc
			}
		}
	}
}

#------------------------------------------------------------------------------------------
# TESTS
exit

$global:dms=new-dms -name Usas2.Rom -BlockSize 32KB -numBlocks 256 -SegmentSize 512
#$global:SegmentAllocationTable=new-DmsSegmentAllocationTable -numBlocks $numBlocks -numSegmentsPerBlock $numSegmentsPerBlock
#$null=$dms.SegmentAllocationTable[0]|lock-DmsSegment -segment 0 -length 30
#$null=$dms.SegmentAllocationTable[0]|lock-DmsSegment -segment 4 -length 3
#$dms.SegmentAllocationTable[0]|get-DsmAssignedSegmentChain -startSegment 0
#$null=$global:SegmentAllocationTable[0]|lock-DmsSegment -segment 4 -length 2
#$global:SegmentAllocationTable[0].alloc -join(",")# return the length of an segmentChain
#$global:SegmentAllocationTable[0]|get-DmsFreeSegmentChain -startSegment 0
#$dms|find-DmsFreeSegment -length 29|lock-DmsSegment -segment 2 -length 20
#if (($a=find-DmsFreeSegment -SatRecord $dms.segmentAllocationTable[0] -length 20) -ne -1) {write-host $a}
#dms.SegmentAllocationTable[0]|lock-DmsSegment -segment $a -length 20
#$a=$dms|find-DmsFreeSpace -length 28;$null=$dms|lock-DmsSegment -block $a.block -segment $a.segment -length $a.length
#$a=$dms|find-DmsFreeSpace -length 5;$null=$dms|lock-DmsSegment -block $a.block -segment $a.segment -length $a.length
#$dms|find-DmsFreeSpace -length 32
#$dms|unLock-DmsSegment -segment $a.segment -block $a.block
#$dms|alloc-DmsSpace -lengthBytes 100; #$null=$dms|lock-DmsSegment -block $a.block -segment $a.segment -length $a.length
$null=$dms|exclude-Dmsblock -block 0   #exclude code blocks
$null=$dms|exclude-Dmsblock -block 1
$null=$dms|exclude-Dmsblock -block 2
$null=$dms|exclude-Dmsblock -block 3
$roommapDataList=$dms|add-DmsDataList -name "roomMap"
$gfxDataList=$dms|add-DmsDataList -name "gfx"
$vgmDataList=$dms|add-DmsDataList -name "vgm"
$codeDataList=$dms|add-DmsDataList -name "cod"
#add-DmsFile -dms $dms -path ".\*.ps1" -datalistname cod

$filelist=gc .\filelist.txt
foreach ($this in $filelist.split("`n")) {add-DmsFile -dms $dms -path $this -datalistname cod}
$codedatalist.allocations

#$dms|add-DmsDataListAllocation -datalistname "roommap" -name "file1" -block 1 -segment 1 -length 1
#$dms.dataList|where{$_.name -eq "roommap"}|add-DmsDataListAllocation -name "file3" -block 3 -segment 1 -length 1
#exit
$path="..\grapx\tilesheets\*.sc5"
$null=add-DmsFile -dms $dms -path $path -datalistname gfx
$gfxdatalist.allocations
$mapsLocation="C:\Users\rvand\Usas2-main\maps"
$Files=gci $mapsLocation\* -include *.map.pck|select -first 10
$null=add-DmsFile -dms $dms -files $files -datalistname roommap
$roommapDataList.allocations


exit


$dms.SegmentAllocationTable|ft #[0].alloc -join(",")