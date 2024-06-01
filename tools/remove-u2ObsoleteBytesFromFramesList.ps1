# Remove 7 bytes from each frame in frames.lst file
# Shadow@FuzzyLogic
# 20240531-20240531

[CmdletBinding()]
param
(	
	[Parameter(ParameterSetName='file')]$path="..\grapx\AreaSigns\frames.lst"
)

$files=get-childitem $path
foreach ($file in $files)
{	$newFile="$($file.directoryname)\$($file.basename).new$($file.extension)"
	write "Converting `"$($file.fullname)`" > `"$newfile`""
	$lst=get-content $file
	$lst|where{$_ -notmatch "db (000h,...h,...h,...h,...h$|...h,...h$)"}|Out-File $newfile -encoding ascii

}