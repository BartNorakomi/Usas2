[CmdletBinding()]
param ($datFile,$patFile,$exportFile)
$filemodes=@{Append=6;Create=2;CreateNew=1;Open=3;OpenOrCreate=4;Truncate=5}

function resolve-NewPath
{	param (	$path)
	return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)	
}


if (-not ($patPath=resolve-path -path $patfile))
{   write-error "$patfile not found";exit}

# function create-phraseFile
# {   param
#     (   
#         $path, [switch]$force #force overwrite
#     )
# 	if  ((Test-Path $path) -and (-not $force))
#     {   write-warning "File '$path' already exists. Use -force to overwrite"
#     }   else
#     {   write-verbose "Creating $path"
#         if ($fs=[io.file]::create((resolve-newPath -path $path)))
#         {	$rawData=[byte[]]::new($DSM.blocksize)
#             for ($i=0;$i -lt $DSM.size;$i++)
#             {	write-verbose "Writing Block $i, size $($DSM.blocksize)"
#                 $fs.Write($RawData,0,$RawData.count)
#             }
# 			$dsm.filespace.path=$path
#             $fs.close()
#         }
#     }
# }



function get-FileData
{   param ($File)
    if (-not ($datPath=resolve-path -path $file))
    {   write-error "$file not found";exit
    } else
    {   write-verbose "Opening files: $file"
        if (-not ($fs=[io.file]::OpenRead($datPath)))
        {   write-error "Filestream error";exit
        } else
        {   write-verbose "file Size $file : 0x$("{0:X8}" -f $fs.length)"
            $datData=[byte[]]::new($fs.length)
            [void]$fs.read($datdata,0,$datdata.length)
            $fs.close()
        }
    }
   return ,$datData
}

function get-phraseLength
{   param ($id,$data)
    $index=0
    while ($data[($index+$id)] -ne 0x00)
    {   $index ++
    }
    return $index
}
function get-phrase
{   param ($id,$data)
    $length=get-phraseLength -id $id -data $dat
    return $length
}
function convert-pat
{   param ($pat)
    $newPat=[byte[]]::new($pat.length)
    for ($index=0;$index -lt $numRecords;$index++)
    {   write-verbose "Record: $($index)"
        [byte]$L=$pat[$index*2]
        [byte]$H=$pat[$index*2+1]
        [uint16]$newData=($H*256+$l+$pat.length)
        write-verbose $newdata
        $L=[byte]($newdata -band 0xff)
        $H=[byte]($newdata -shr 8)
        # write-verbose $L
        # write-verbose $H
        # get-phrase -id ($H*256+$l) -data $dat
        $newPat[$index*2]=$L
        $newPat[$index*2+1]=$H
    }
    return $newPat
}

#MAIN
$dat=get-FileData -file $datfile
$pat=get-FileData -file $patfile
$global:pat=$pat;
$numRecords=$pat.length/2
write-verbose "Number of records: $numRecords"

Write-verbose "Export to $exportFile"
$fsDst=[io.file]::create((resolve-NewPath -path $exportFile))					#create destination file (eagerly)
# $fsDst
$newPat=convert-pat -pat $pat
$global:newPat=$newPat

$fsDst.write($newpat,0,$newpat.length)
$fsDst.write($dat,0,$dat.length)
$fsDst.close()

