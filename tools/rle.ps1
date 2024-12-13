[CmdletBinding()]
param
(	#[switch]$getglobals
)


function Encode-RLE
{	param ([byte[]]$data)
	$output = [System.Collections.Generic.List[byte]]::new()
	$count = 1

	for ($i=1; $i -lt $data.Length; $i++)
	{	if ($data[$i] -eq $data[$i - 1] -and $count -lt 255)
		{	$count++
		} else
		{	$output.Add($count)
			$output.Add($data[$i - 1])
			$count = 1
		}
	}
    # Add the last run
    $output.Add($count)
    $output.Add($data[$data.Length - 1])
    return $output
}

function Decode-RLE
{   param ([byte[]]$data)
	$output = [System.Collections.Generic.List[byte]]::new()
    for ($i=0; $i -lt $data.Length; $i=$i+2)
    {   $count=$data[$i]
        $value=$data[$i+1]
        for ($j=0;$j -lt $count;$j++) {$output.add($value)}
    }
    return $output
}

# $data=(get-content -path "..\grapx\WaterfallScene\Backdrop1.SC5" -Encoding Byte)
$data=(get-content -path ".\b1.SC5" -Encoding Byte)
$data.length
$out=Encode-RLE -data $data 
$out.length

exit
#test
$data=(get-content .\01-Hub.4bpp.bmp -Encoding Byte)
$data.length
$out=Encode-RLE -data $data 
$out.length
Set-Content "01-hub.4bpp.bmp.rle" -Encoding Byte -Value $out

$data=(get-content .\01-Hub.4bpp.bmp.rle -Encoding Byte)
$data.length
$out=Decode-RLE -data $data
$out.length
Set-Content "01-hub.4bpp.new.bmp" -Encoding Byte -Value $out
