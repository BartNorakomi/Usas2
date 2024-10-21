param ([switch]$music)

$cmd='& "C:\Program Files\openMSX\openmsx.exe" -machine Panasonic_FS-A1GT -carta "..\engine\Usas2.rom" -command "set throttle off; after time 6 \`"set throttle on\`""'
if ($music) {$cmd+=" -ext moonsound"}

invoke-expression $cmd


