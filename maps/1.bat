dos2unix A01.tmx
tmx16 A01.tmx A01.map
dos2unix A02.tmx
tmx16 A02.tmx A02.map
dos2unix A03.tmx
tmx16 A03.tmx A03.map
pack A*.map

dos2unix B01.tmx
tmx16 B01.tmx B01.map
dos2unix B02.tmx
tmx16 B02.tmx B02.map
dos2unix B03.tmx
tmx16 B03.tmx B03.map
pack B*.map

dos2unix C01.tmx
tmx16 C01.tmx C01.map
dos2unix C02.tmx
tmx16 C02.tmx C02.map
dos2unix C03.tmx
tmx16 C03.tmx C03.map
pack C*.map

dos2unix D01.tmx
tmx16 D01.tmx D01.map
dos2unix D02.tmx
tmx16 D02.tmx D02.map
dos2unix D03.tmx
tmx16 D03.tmx D03.map
pack D*.map


cd..
cd engine
tniasm Usas2.asm
del tniasm.out
del tniasm.tmp
cd..
cd maps