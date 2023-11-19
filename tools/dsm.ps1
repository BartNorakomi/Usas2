#Data Space Manager
#Shadow@FuzzyLogic
#20231027-20231119 


#Globals
$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}
$dsmObjectFilenameExtention="dsm"
$dsmIndexFilenameExtention="dsm.index"
$dsmSpaceFilenameExtention="dsm.space"



# DSM OBJECT
#Initiate a new DSM object
function new-DSM
{   param
    (   [string]$name,
        [uint32]$BlockSize=16KB,
		[uint32]$FirstBlock=0,
        [uint32]$numBlocks=8,
        [uint32]$SegmentSize=512 #bytes
    )
        [uint32]$numSegmentsPerBlock=$Blocksize/$SegmentSize
        $SegmentAllocationTable=new-DSMSegmentAllocationTable -numBlocks $numBlocks -numSegmentsPerBlock $numSegmentsPerBlock
        return [psobject]@{name=$name;blocksize=$blocksize;firstBlock=$firstBlock;numblocks=$numblocks;segmentSize=$segmentSize;numSegmentsPerBlock=$numSegmentsPerBlock;segmentAllocationTable=$SegmentAllocationTable;dataList=@();fileSpace=$null}
}

# DSM OBJECT
#Decommission an existing DSM object
function remove-DSM
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM
    )
    #do some segment checks first... (todo)
    $DSM=$null
    return $true
}

# DSM OBJECT
# Return an empty SatRecord
function new-DSMSegmentAllocationRecord
{   param   ( [uint32]$numSegmentsPerBlock
            )
    return  [pscustomobject]@{numfree=$numSegmentsPerBlock;alloc=@(0)*$numSegmentsPerBlock}
}

# DSM OBJECT
# Initialize and return empty SAT
function new-DSMSegmentAllocationTable
{   param ([uint32]$numBlocks,[uint32]$numSegmentsPerBlock)
    for ($i=0;$i -lt $numblocks;$i++)
    {   new-DSMSegmentAllocationRecord -numSegmentsPerBlock $numSegmentsPerBlock
    }
}

# DSM OBJECT
# Save DSM space as a file
function save-DSM
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        $path
    )
	if (-not $path) {$path="$($DSM.name).$dsmObjectFilenameExtention"}
	write-verbose "saving DSM as $path"
	
    ConvertTo-Json -InputObject $DSM|Set-Content $path
}

# DSM OBJECT
# Load DSM space from a file
function load-DSM
{   param
    (   
        [Parameter(Mandatory)]$path
    )
    $DSM=get-content "$($path).$dsmObjectFilenameExtention" |ConvertFrom-Json
    return $DSM
}


# SEGMENT
# Exclude a whole block from the allocationTable
function exclude-DSMblock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block
    )
    lock-DSMSegment -DSM $DSM -block $block -segment 0 -length $DSM.numSegmentsPerBlock
    return  
}

# SEGMENT
# Lock a segmentChain
#in: DSM, block, segment, length
function lock-DSMSegment
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block,
        [Parameter(Mandatory)]$segment,
        [Parameter(Mandatory)]$length
    )
    $SatRecord=$DSM.SegmentAllocationTable[$block]
    if ($SatRecord.numfree -lt $length)
    {   write-error "Block free space capacity is to low"
    } else
    {   $freeCount=get-DSMFreeSegmentChain -SatRecord $SatRecord -startSegment $segment
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
#in: DSM, block, segment
function unLock-DSMSegment
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block,
        [Parameter(Mandatory)]$segment
    )
    $SatRecord=$DSM.SegmentAllocationTable[$block]
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
function get-DSMSegmentChain
{   param
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $startSegment
    )
    if ($SatRecord.alloc[$startSegment] -eq 0)
    {   return get-DSMFreeSegmentChain -satrecord $satrecord -startsegment $startSegment
    }   else
    {   return get-DsmAssignedSegmentChain -satrecord $satrecord -startsegment $startSegment
    }
}

# SEGMENT
# return the length of a segmentChain of free records
function get-DSMFreeSegmentChain
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
function find-DSMFreeSegment
{    param 
    (   [Parameter(ParameterSetName='record',Mandatory,ValueFromPipeline)]$SatRecord,
        $length
    )
    if ($length)
    {   $index=0
        while ($SatRecord.alloc.length -ge $index+$length)
        {   $count=get-DSMFreeSegmentChain -SatRecord $SatRecord -startSegment $index
            if ($count+1 -gt $length) {return $index;break}
            $index++
        }
    }
    return -1
}


# ALLOCATE
# Find a space big enough
function find-DSMFreeSpace
{   param
    (
    [Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
    $lengthBytes
    )
    if ($length=[int][Math]::Ceiling($lengthBytes/$DSM.segmentSize))
    {   $block=0;$segment=0
        foreach ($SatRecord in $DSM.segmentAllocationTable)
        {   if ($SatRecord.numfree+1 -gt $length)
            {   if (($startSegment=find-DSMFreeSegment -SatRecord $SatRecord -length $length) -ne -1)
                {    #$segmentRecord|lock-DSMSegment -segment $startSegment -length $length
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
# in:   DSM object, length in bytes
# out:  array (block,segment,length)
#       $false=no freespace found
function alloc-DSMSpace
{   param
    (
    [Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
    $lengthBytes
    )
    if ($space=find-DSMFreeSpace -DSM $DSM -lengthBytes $lengthBytes)
    {   $null=lock-DSMSegment -DSM $DSM -block $space.block -segment $space.segment -length $space.length
        return $space
    } else
    {   return $false
    }
}


# ALLOCATE
# Add one, or more file(s) to DSM and optionally to a datalist and optionally update the file space file
# out:	Array of allocations
function add-DSMFile
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
        $dataListName="", $path, $files,
        $addLength=0, [switch]$updateFileSpace #optional
    )
    $datalist=$DSM.dataList|where{$_.name -eq $datalistname}
    if (-not $files) {$Files=gci $path}
    foreach ($file in $Files)
    {	write-verbose "Adding $($file.fullname) $($file.length)"
        if ($alloc=$DSM|alloc-DSMSpace -lengthBytes ($file.length+$addlength))
        {	if ($datalist)
            {	$null=$DataList|add-DSMDataListAllocation -name $file.name -allocation $alloc
                [pscustomobject]$alloc
            }
            if ($updateFileSpace -and $DSM.filespace)
            {	write-verbose "updateing file space -block $($alloc["block"]) -segment $($alloc["segment"]) $($alloc["length"])"
                $data=get-content $file -Encoding byte
                $null=$DSM|write-DSMFileSpace -block $alloc["block"] -segment $alloc["segment"] -data $data
            }
        }
    }
}


# DATA LIST
# Return an empty dataListRecord
function new-DSMDataList
{   param   (   $name=""
            )
    return  [pscustomobject]@{name=$name;allocations=@()} #block=0;segment=0;length=0}        
}    

# DATA LIST
# Add a new dataList to an existing DSM object
function add-DSMDataList
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		$name=""
    )    
    $list=new-DSMDataList -name $name
	$DSM.dataList+=$list
	return $DSM.datalist|where{$_.name -eq $name}
}    

# DATA LIST
# add an existing allocation to an existing dataList
function add-DSMDataListAllocation
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		[Parameter(ParameterSetName='DSM',Mandatory)]$dataListName="",
		[Parameter(ParameterSetName='DSMDataList',Mandatory,ValueFromPipeline)]$dataList,
		$allocation,
		$name="",$block=0,$segment=0,$length=0
    )    
	if ($datalistname) {$datalist=$DSM.datalist|where{$_.name -eq $datalistname}}
	if (-not ($datalist.allocations|where{$_.name -eq $name}))
	{	if (-not $allocation) {$allocation=@{block=$block;segment=$segment;length=$length}}
		$datalist.allocations+=[pscustomobject]($allocation+@{name=$name})
	}    
	return
}    


# FILE SPACE
# Create an empty DSM fileSpace as file
function create-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        $path
    )
	if (-not $path) {$path="$(resolve-path ".\")\$($DSM.name).$dsmSpaceFilenameExtention"}
	write-verbose "saving DSM space as $path"
	if ($fs=[io.file]::create($path))
	{	$rawData=[byte[]]::new($DSM.blocksize)
		for ($i=0;$i -lt $DSM.numblocks;$i++)
		{	write-verbose "Writing Block $i, size $($DSM.blocksize)"
			$fs.Write($RawData,0,$RawData.Length)
		}
		$fs.close()
	}
}


# FILE SPACE
# Open DSM file space with WRITE access
function open-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        $path
    )
	if (-not $DSM.filespace)
	{	if (-not $path) {$path="$(resolve-path ".\")\$($DSM.name).$dsmSpaceFilenameExtention"}
		write-verbose "Opening DSM file space $path"
		if ($fs=[io.file]::open($path,$filemodes["open"]))
		{	$DSM.filespace=$fs
			return $fs
		} else
		{	return $false
		}
	} else
	{	return $DSM.filespace
	}

}


# FILE SPACE
# Close DSM files space (system)
function close-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM
    )
	if ($DSM.filespace)
	{	$DSM.filespace.close()
		$DSM.filespace=$null		#no error checking!
	}
}


# FILE SPACE
# Seek to a block+segment position in an open File Space
function seek-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
		$block=0,$segment=0
    )
	if ($DSM.filespace)
	{	$seekPosition=($block*$DSM.blocksize)+($segment*$DSM.segmentsize)
		return $DSM.filespace.seek($seekPosition,0)
	} else
	{	return $false
	}
}


# FILE SPACE
# Read from an open File Space
function read-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
		[Parameter(Mandatory)]$length=0,
		$block=-1,$segment=0	#optional seek to block/segment
    )

	if (-not $DSM.filespace)
	{	return 0
	} else
	{	if ($block -ne -1)
		{	if (-not ($seek=seek-DSMFileSpace -DSM $DSM -block $block -segment $segment).GetType().name -eq "int32")
			{	return $false
			}
		}
		$Data=[byte[]]::new($length)
		$null=$DSM.filespace.read($data,0,$data.length)
		return $data
	}
}


# FILE SPACE
# Read one whole block from an open File Space
function read-DSMFileSpaceBlock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
		$block=0
    )

	return $DSM|read-DSMFileSpace -length ($DSM.blocksize) -block $block -segment 0
}


# FILE SPACE
# Write to an open File Space
function write-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
		[Parameter(Mandatory)]$Data,
		$block=-1,$segment=0	#optional seek to block/segment
    )
	if (-not $DSM.filespace)
	{	return $false
	} else
	{	if ($block -ne -1)
		{	if (-not ($seek=seek-DSMFileSpace -DSM $DSM -block $block -segment $segment).GetType().name -eq "int32")
			{	return $false
			}
		}
		return $DSM.filespace.write($Data,0,$Data.length)
	}
}

# FILE SPACE
# Write one whole block to an open File Space
function write-DSMFileSpaceBlock
{   param
	(   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
		$block=0,$blockData
	)
	return $DSM|write-DSMFileSpace -data $blockData -block $block -segment 0
}



# STATISTICS
function get-DSMStatistics
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM
	)
	$capacity=$DSM.numblocks*$DSM.blocksize
	$free=$($DSM.segmentAllocationTable.numfree|measure -Sum).sum*$DSM.segmentsize
	write "Name:		$($DSM.name)"
	write "Blocks:		$($DSM.numblocks) of $($DSM.blocksize)"
	write "Capacity:	$capacity	/ $($capacity/1kb)KB"
	write "Free space:	$free	/ $($free/1kb)KB"
	write "In use:		$($capacity-$free)	/ $(($capacity-$free)/1kb)KB"
}


#------------------------------------------------------------------------------------------
# TESTS
exit
$global:DSM=new-DSM -name Usas2.Rom -BlockSize 16KB -numBlocks 8 -SegmentSize 256
#$DSM|create-DSMFileSpace -verbose

$null=$DSM|open-DSMFileSpace -verbose
$null=$DSM|write-DSMFileSpaceblock -block 0 -blockdata ([System.Text.Encoding]::UTF8.GetBytes(">> block #00"))
$null=$DSM|write-DSMFileSpaceblock -block 1 -blockdata ([System.Text.Encoding]::UTF8.GetBytes(">> block #01"))
#if (-not ($global:data=$DSM|read-DSMFileSpaceBlock -block 0 -verbose)) {write-error "error reading"}
#$data|select -first 32|format-hex
#if (-not ($global:data=$DSM|read-DSMFileSpace -length 32 -block 1)) {write-error "error reading"}
#$data|select -first 32|format-hex
$null=$DSM|close-DSMFileSpace -verbose

#$global:SegmentAllocationTable=new-DSMSegmentAllocationTable -numBlocks $numBlocks -numSegmentsPerBlock $numSegmentsPerBlock
#$null=$DSM.SegmentAllocationTable[0]|lock-DSMSegment -segment 0 -length 30
#$null=$DSM.SegmentAllocationTable[0]|lock-DSMSegment -segment 4 -length 3
#$DSM.SegmentAllocationTable[0]|get-DsmAssignedSegmentChain -startSegment 0
#$null=$global:SegmentAllocationTable[0]|lock-DSMSegment -segment 4 -length 2
#$global:SegmentAllocationTable[0].alloc -join(",")# return the length of an segmentChain
#$global:SegmentAllocationTable[0]|get-DSMFreeSegmentChain -startSegment 0
#$DSM|find-DSMFreeSegment -length 29|lock-DSMSegment -segment 2 -length 20
#if (($a=find-DSMFreeSegment -SatRecord $DSM.segmentAllocationTable[0] -length 20) -ne -1) {write-host $a}
#DSM.SegmentAllocationTable[0]|lock-DSMSegment -segment $a -length 20
#$a=$DSM|find-DSMFreeSpace -length 28;$null=$DSM|lock-DSMSegment -block $a.block -segment $a.segment -length $a.length
#$a=$DSM|find-DSMFreeSpace -length 5;$null=$DSM|lock-DSMSegment -block $a.block -segment $a.segment -length $a.length
#$DSM|find-DSMFreeSpace -length 32
#$DSM|unLock-DSMSegment -segment $a.segment -block $a.block
#$DSM|alloc-DSMSpace -lengthBytes 100; #$null=$DSM|lock-DSMSegment -block $a.block -segment $a.segment -length $a.length
$null=$DSM|exclude-DSMblock -block 0   #exclude code blocks
$null=$DSM|exclude-DSMblock -block 1
#$null=$DSM|exclude-DSMblock -block 2
#$null=$DSM|exclude-DSMblock -block 3
$roommapDataList=$DSM|add-DSMDataList -name "roomMap"
$gfxDataList=$DSM|add-DSMDataList -name "gfx"
$vgmDataList=$DSM|add-DSMDataList -name "vgm"
$codeDataList=$DSM|add-DSMDataList -name "cod"
#$null=$DSM|open-DSMFileSpace -verbose
$null=add-DSMFile -DSM $DSM -path ".\*.ps1" -datalistname cod -updateFileSpace -verbose
$codeDatalist.allocations
#$null=$DSM|close-DSMFileSpace -verbose

exit
$filelist=gc .\filelist.txt
foreach ($this in $filelist.split("`n")) {add-DSMFile -DSM $DSM -path $this -datalistname cod}
#$codedatalist.allocations

#$DSM|add-DSMDataListAllocation -datalistname "roommap" -name "file1" -block 1 -segment 1 -length 1
#$DSM.dataList|where{$_.name -eq "roommap"}|add-DSMDataListAllocation -name "file3" -block 3 -segment 1 -length 1
#exit
$path="..\grapx\tilesheets\*.sc5"
$null=add-DSMFile -DSM $DSM -path $path -datalistname gfx
#$gfxdatalist.allocations
$mapsLocation="C:\Users\rvand\Usas2-main\maps"
$Files=gci $mapsLocation\* -include *.map.pck|select -first 10
$null=add-DSMFile -DSM $DSM -files $files -datalistname roommap
#$roommapDataList.allocations

get-DSMStatistics -DSM $DSM

exit


$DSM.SegmentAllocationTable|ft #[0].alloc -join(",")