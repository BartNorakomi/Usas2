cd..
cd maps
.\convert-tmxtoraw16.ps1 -Path C:\Users\bartf\OneDrive\Usas2\maps\BT*.tmx -targetPath .\  -pack
cd..
cd engine
.\tniasm Usas2.asm
del .\tniasm.out
del .\tniasm.tmp

