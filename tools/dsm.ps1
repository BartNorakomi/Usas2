#Data Space Manager
#Shadow@FuzzyLogic
#20231027-20231123

##### Globals #####
$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}
$dsmObjectFilenameExtention="dsm"
$dsmIndexFilenameExtention="index"
$dsmSpaceFilenameExtention="dsm.space"


# DSM OBJECT
# Initiate a new DSM object
function new-DSM
{   param
    (   [Parameter(Mandatory)][string]$name,
        [uint32]$BlockSize=16KB,
		[uint32]$FirstBlock=0,
        [uint32]$numBlocks=8,
        [uint32]$SegmentSize=512 #bytes
    )
        [uint32]$numSegmentsPerBlock=$Blocksize/$SegmentSize
        $SegmentAllocationTable=new-DSMSegmentAllocationTable -numBlocks $numBlocks -numSegmentsPerBlock $numSegmentsPerBlock
        return [psobject]@{name=$name;blocksize=$blocksize;firstBlock=$firstBlock;numblocks=$numblocks;segmentSize=$segmentSize;numSegmentsPerBlock=$numSegmentsPerBlock;segmentAllocationTable=$SegmentAllocationTable;dataList=[System.Collections.ArrayList]::new();fileSpace=$null}
}

# DSM OBJECT
# Decommission an existing DSM object (no checking!)
function remove-DSM
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM
    )
    #do some segment checks first... (todo)
    $DSM=$null
    return $dsm
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
# Save DSM object as a file
function save-DSM
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        $path
    )
	if (-not $path) {$path="$($DSM.name).$dsmObjectFilenameExtention"}
	write-verbose "saving DSM as $path"
    $null=$DSM|close-DSMFileSpace #Close any filespace first
    #20231130;disabled;ConvertTo-Json -InputObject $DSM -depth 3|Set-Content $path
    Export-Clixml -InputObject $dsm -Depth 3 -Path $path
}

# DSM OBJECT
# Load DSM object from a file
function load-DSM
{   param
    (   [Parameter(Mandatory)]$path
    )
    #20231130;disabled;$DSM=get-content "$($path).$dsmObjectFilenameExtention" |ConvertFrom-Json
    ###foreach ($alloc in $dsm.segmentAllocationTable) {$alloc.alloc=$alloc.alloc -split (" ")}
    $DSM=Import-Clixml -Path $path
    return $DSM
}

# SEGMENT
# Clear a SatRecord (force) -for testing purpose only
function clear-DsmBlock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block
    )
    foreach ($this in $block)
    {   $DSM.SegmentAllocationTable[$this]=new-DSMSegmentAllocationRecord -numSegmentsPerBlock $dsm.numSegmentsPerBlock
    }
    return
}


# SEGMENT
# Exclude a whole block from the allocationTable
function exclude-DSMblock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block
    )
    foreach ($this in $block)
    {   lock-DSMSegment -DSM $DSM -block $this -segment 0 -length $DSM.numSegmentsPerBlock
    }
    return  
}

# SEGMENT
# Include a whole block from the allocationTable (might destroy allocations)
function include-DSMblock
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block
    )
    foreach ($this in $block)
    {   unlock-DSMSegment -DSM $DSM -block $this -segment 0
    }
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
# UnLock a segmentChain (free)
#in: DSM, block, segment
function unLock-DSMSegment
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(Mandatory)]$block,
        [Parameter(Mandatory)]$segment
    )
    $SatRecord=$DSM.SegmentAllocationTable[$block]
    $length=get-DsmAssignedSegmentChain -satrecord $satrecord -startsegment $Segment
    #write-verbose "unlock-DSMsegment block: $block segment: $segment"
    while ($length)
    {   $satRecord.alloc[$segment+$length-1]=0
        $length--
        $satRecord.numfree++
    }
    return $satrecord
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
    $numSeg=$SatRecord.alloc.count-$startSegment
    if ($numseg -lt 1)
    {   write-error "Available number of allocations too low"
        return
    }
    $count=0
    while (($startSegment+$count -lt $SatRecord.alloc.count) -and ($SatRecord.alloc[$startSegment+$count] -eq 0))
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
        {   #write-warning "not the beginning of a segmentAllocationBlock"
            return  
        }
        $count=1
        while (($startSegment+$count -lt $SatRecord.alloc.count) -and ($SatRecord.alloc[$startSegment+$count] -eq ($SatRecord.alloc[$startSegment+$count-1]+1)))
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
        while ($SatRecord.alloc.count -ge $index+$length)
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
                    return [pscustomobject]@{block=$block;segment=$startSegment;length=$length};break;
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
# Free an earlier allocated piece of blockspace
# in:   DSM object, Alloc information, either AllocArray (block,segment) or -block -segment
# out   -
#       $false=error
function free-DSMSpace
{   param
    (
    [Parameter(Mandatory,ValueFromPipeline)]$DSM,
    [Parameter(ParameterSetName='alloc',Mandatory)]$alloc,
    [Parameter(ParameterSetName='blockSegment',Mandatory)]$block,
    [Parameter(ParameterSetName='blockSegment',Mandatory)]$segment
    )

    if ($alloc) {$block=$alloc.block;$segment=$alloc.segment}
    $null=unlock-DSMSegment -DSM $DSM -block $block -segment $segment
    return $true
}


# DATA LIST
# Add one, or more file(s) to DSM.datalist and optionally update the file space file
# out:	Array of allocations
function add-DSMFile
{   param
    (	[Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(ParameterSetName='ListName',Mandatory)]$dataListName,
        [Parameter(ParameterSetName='ListObject',Mandatory)]$dataList,
        $path, $files, #either by name or object
        $addLength=0, [switch]$updateFileSpace #optional
    )
    if (-not $datalist) {$datalist=get-DSMDataList -dsm $dsm -name $datalistname|select -first 1}
    if (-not $files) {$Files=gci $path}
  
    foreach ($file in $Files)
    {   if ($datalist -and -not (get-DsmDataListAllocation -dataList $datalist -name $file.name))
        {   write-verbose "Adding $($file.fullname) $($file.length) to DSM"
            if ($alloc=$DSM|alloc-DSMSpace -lengthBytes ($file.length+$addlength))
            {	if ($datalist)
                {	write-verbose "adding to datalist: $($datalist.name)"
                    $null=$DataList|add-DSMDataListAllocation -name $file.name -alloc $alloc
                }   
                if ($updateFileSpace -and $DSM.filespace)
                {	write-verbose "updating file space -block $($alloc.block) -segment $($alloc.segment) $($alloc.length)"
                    $data=get-content $file -Encoding byte
                    $null=$DSM|write-DSMFileSpace -block $alloc.block -segment $alloc.segment -data $data
                }
                $alloc
            } else
            {
                write-warning "Allocation fault"
            }
        } else
        {   write-warning "file $($file.name) already in datalist $($datalist.name)" 
        }
    }
}


# DATA LIST
# Remove a file from the data list, and free up the allocation
function remove-DSMfile
{   param
    (	[Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(ParameterSetName='ListName',Mandatory)]$dataListName,
        [Parameter(ParameterSetName='ListObject')]$dataList,
        $name,$allocation,  #either name or object
        [switch]$updateFileSpace #optional
    )
    if ($name) {$name=Split-Path -path $name -Leaf} #keep only filename.ext, strip path chars
    if (-not $datalist) {$datalist=get-DSMDataList -dsm $dsm -name $datalistname|select -first 1}
	if (-not $allocation) {$allocation=$datalist.allocations|where{$_.name -eq $name}}

    if ($allocation)
    {   if (free-DSMSpace -dsm $dsm -alloc $allocation)
        {   remove-DsmDatalistAllocation -dataList $datalist -allocation $allocation
            # don't really need to update the file space
            #if ($updateFileSpace)
            #{   $null=$DSM|write-DSMFileSpace -block $allocation["block"] -segment $allocaction["segment"] -data $data
            #}
        }
    }
}


# DATA LIST
# replace a file in  DSM Datalist
function replace-DsmFile
{   param
    (	[Parameter(Mandatory,ValueFromPipeline)]$DSM,
        [Parameter(ParameterSetName='ListName',Mandatory)]$dataListName,
        [Parameter(ParameterSetName='ListObject')]$dataList,
        [Parameter(Mandatory)]$name,  #current filename
        [Parameter(Mandatory)]$path,  #path to new file
        [switch]$updateFileSpace #optional
    )
    if (-not $datalist) {$datalist=get-DSMDataList -dsm $dsm -name $datalistname|select -first 1}
    remove-DSMfile -dsm $dsm -datalist $datalist -name $name
    add-DSMFile -dsm $dsm -dataList $datalist -path $path -updateFileSpace:$updateFileSpace
}


# DATA LIST
# Return an empty dataListRecord
function new-DSMDataList
{   param   (   $name=""
            )
    return  [pscustomobject]@{name=$name;allocations=[System.Collections.ArrayList]::new()} #block=0;segment=0;length=0}        
}    

# DATA LIST
# Get dataList(s) from an existing DSM object
function get-DSMDataList
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		$name="*"
    )
    return $dsm.datalist|where{$_.name -like $name}
}

# DATA LIST
# Add a new dataList to an existing DSM object
function add-DSMDataList
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		$name=""
    )
    if (-not ($list=get-DSMDataList -DSM $dsm -name $name))
    {   $list=new-DSMDataList -name $name
	    [void]$DSM.dataList.add($list)
	}
    return $list
}    

# DATA LIST
# Remove a dataList from an existing DSM object and optionally free space allocations as well
function remove-DSMDataList
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		$name="", [switch]$freeAllocation
    )
    if ($list=get-DSMDataList -DSM $dsm -name $name)
    {   if ($freeAllocation)
        {   foreach ($allocation in $list.allocations)
            {   remove-DSMfile -dsm $dsm -datalist $datalist -allocation $allocation
            }
        }        
        [void]$DSM.dataList.remove($list)
	}
    return
}    

# DATA LIST
# add an existing SegmentAllocation to an existing dataList
function add-DSMDataListAllocation
{   param
    (	[Parameter(ParameterSetName='DSM',Mandatory,ValueFromPipeline)]$DSM,
		[Parameter(ParameterSetName='DSM',Mandatory)]$dataListName="",
		[Parameter(ParameterSetName='DSMDataList',Mandatory,ValueFromPipeline)]$dataList,
		[Parameter(Mandatory)]$name="",
		$alloc,$block=0,$segment=0,$length=0  #either ALLOC or block/seg/len
    )
    if (-not $alloc) {$alloc=[pscustomobject]@{block=$block;segment=$segment;length=$length}}
    if (-not $datalist) {$datalist=$DSM.datalist|where{$_.name -eq $datalistname}}
	#Only add if it doens't exist yet
    if (-not (get-DsmDataListAllocation -dataList $datalist -name $name))
	{	$allocation=$alloc
        $allocation|Add-Member @{name=$name}
        [void]$datalist.allocations.add($allocation)
	}
    return
}    


function get-DsmDataListAllocation
{   [CmdletBinding()]
    param
    (   [Parameter(Mandatory,ValueFromPipeline)]$dataList,
        [Parameter(Mandatory)]$name=""
    )
    return ($datalist.allocations|where{$_.name -eq $name})
}


# DATA LIST
# remove an existing datalist allocation
function remove-DsmDatalistAllocation
{   param
    (	[Parameter(ParameterSetName='listName',Mandatory,ValueFromPipeline)]$DSM,
		[Parameter(ParameterSetName='listName',Mandatory)]$dataListName="",
		[Parameter(ParameterSetName='listObject',Mandatory,ValueFromPipeline)]$dataList,
		$allocation,$name #either by name or object
    )    
	if (-not $datalist) {$datalist=get-DSMDataList -dsm $dsm -name $datalistname|select -first 1}
	if (-not $allocation) {$allocation=$datalist.allocations|where{$_.name -eq $name}}
    if ($allocation)
	{   [void]$datalist.allocations.remove($allocation)
	}    
	return
}    


# FILE SPACE
# Create an empty DSM fileSpace as file
function create-DSMFileSpace
{   param
    (   [Parameter(Mandatory,ValueFromPipeline)]$DSM,
        $path, [switch]$force #force overwrite
    )
	if (-not $path) {$path="$(resolve-path ".\")\$($DSM.name).$dsmSpaceFilenameExtention"}
	if  ((Test-Path $path) -and (-not $force))
    {   write-warning "File '$path' already exists. Use -force to overwrite"

    }   else
    {
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
    write "Allocations:    $($dsm.dataList.allocations.count)"
}


#------------------------------------------------------------------------------------------
# TESTS
exit
$global:DSM=new-DSM -name Usas2Test.Rom -BlockSize 16KB -numBlocks 8 -SegmentSize 128
$dl=add-DSMDataList -dsm $dsm -name "DL"
$dsm|add-DSMFile -dataListName dl -path .\*.ps1 -verbose
$dsm|remove-DSMfile -name concat-sc5files.ps1 -dataListName dl -verbose
$dsm.segmentAllocationTable
$dsm.datalist.allocations

$dsm|unLock-DSMSegment -block 0 -segment 10
$dsm.segmentAllocationTable

$dsm|replace-DsmFile -dataListName dl -name .\package.json -path .\package.json -verbose
$dsm|replace-DsmFile -dataListName dl -name make-dsmindex.ps1 -path .\package.json -verbose
$dsm.datalist.allocations
$dsm.segmentAllocationTable

#$DSM|create-DSMFileSpace -verbose
# ALLOC
#$null=$DSM|exclude-DSMblock -block 0,1,2,3   #exclude code blocks
#$null=$DSM|include-DSMblock -block 0
#lock-DSMSegment -dsm $dsm -block 0 -segment 0 -length 2
#unlock-DSMSegment -dsm $dsm -block 0 -segment 0
#$alloc=$dsm|alloc-DSMSpace -lengthBytes 512
#write-host $alloc
#$null=$dsm|free-DSMSpace -alloc $alloc #-block 1 -segment 0
#$x=add-dsmfile -dsm $dsm -path ".\make-dsmIndex.ps1" -verbose -datalist $dl
#write-host $x
#$x=remove-DSMfile -dsm $dsm -name ".\make-dsmIndex.ps1" -verbose -datalist $dl
#write-host $x
#$x=replace-dsmfile -dsm $dsm -name ".\make-dsmIndex.ps1" -path ".\make-dsmIndex.ps1" -verbose -datalist $dl
#write-host $x
#write-host "-"; $dsm.segmentAllocationTable


# DATA LIST
#$roommapDataList=$DSM|add-DSMDataList -name "roomMap"
#$gfxDataList=$DSM|add-DSMDataList -name "gfx"
#$vgmDataList=$DSM|add-DSMDataList -name "vgm"
#$global:codeDataList=$DSM|add-DSMDataList -name "cod"
#$dsm|remove-dsmdatalist -name "gfx"
#get-DSMDataList -dsm $dsm

# FILE SPACE
#$null=$DSM|open-DSMFileSpace -verbose
#$null=$DSM|write-DSMFileSpaceblock -block 0 -blockdata ([System.Text.Encoding]::UTF8.GetBytes(">> block #00"))
#$null=$DSM|close-DSMFileSpace -verbose

# ADD/REMOVE/REPLACE FILE
#$null=$DSM|open-DSMFileSpace -verbose
#$null=add-DSMFile -DSM $DSM -path ".\*.ps1" -datalistname cod -updateFileSpace -verbose
#$null=add-DSMFile -DSM $DSM -path ".\*.ps1" -datalist $codedatalist -verbose
#$dsm.segmentAllocationTable
#$codeDatalist.allocations
#write "-"
#remove-DSMfile -DSM $dsm -dataListName cod -name "Usas2-SharedFunctions.inc.ps1"
#remove-DSMfile -DSM $dsm -dataList $codeDatalist -name "Usas2-SharedFunctions.inc.ps1"
#$x=replace-DsmFile -dsm $dsm -dataListName cod -name "Usas2-SharedFunctions.inc.ps1" -path ".\romspace.js" -updateFileSpace
#$codeDatalist.allocations
#$codedatalist.allocations.gettype()

#remove-dsmdatalist -dsm $dsm -name cod -freeAllocation
#write "-"
#$dsm.datalist
#$codeDatalist.allocations
#$dsm.segmentAllocationTable

$null=$DSM|close-DSMFileSpace -verbose
#save-DSM -DSM $dsm
get-DSMStatistics -DSM $dsm
Exit

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