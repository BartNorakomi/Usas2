cd..
cd maps
gci -path  C:\Users\bartf\OneDrive\Usas2\maps\* -include *.tmx|where{$_.LastWriteTime -gt (Get-Date).AddHours(-24)}|%{.\convert-tmxtoraw16.ps1 -path $_.fullname -pack -targetPath .\ }
cd..
cd engine
.\tniasm Usas2.asm
del .\tniasm.out
del .\tniasm.tmp
