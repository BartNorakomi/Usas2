dos2unix AA01.tmx
tmx16 AA01.tmx AA01.map

dos2unix AA02.tmx
tmx16 AA02.tmx AA02.map

dos2unix AA03.tmx
tmx16 AA03.tmx AA03.map

dos2unix AA04.tmx
tmx16 AA04.tmx AA04.map

dos2unix AA05.tmx
tmx16 AA05.tmx AA05.map

dos2unix AA06.tmx
tmx16 AA06.tmx AA06.map

dos2unix AA35.tmx
tmx16 AA35.tmx AA35.map

dos2unix AA47.tmx
tmx16 AA47.tmx AA47.map

dos2unix AA48.tmx
tmx16 AA48.tmx AA48.map

dos2unix AA49.tmx
tmx16 AA49.tmx AA49.map


pack AA*.map

cd..
cd engine
tniasm Usas2.asm
del tniasm.out
del tniasm.tmp
cd..
cd maps