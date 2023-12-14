$files=gci ..\..\grapx\BossGoat\* -include *.lst,*.dat -Recurse
foreach ($file in $files)
{	copy $file ".\$($file[0].Directory.BaseName).$($file[0].name)"
}
