dos2unix A01-001.tmx
tmx16 A01-001.tmx A01-001.map

dos2unix A01-002.tmx
tmx16 A01-002.tmx A01-002.map

dos2unix A01-003.tmx
tmx16 A01-003.tmx A01-003.map

dos2unix A01-004.tmx
tmx16 A01-004.tmx A01-004.map

dos2unix A01-005.tmx
tmx16 A01-005.tmx A01-005.map

dos2unix A01-006.tmx
tmx16 A01-006.tmx A01-006.map

dos2unix A01-007.tmx
tmx16 A01-007.tmx A01-007.map

dos2unix A01-008.tmx
tmx16 A01-008.tmx A01-008.map

dos2unix A01-009.tmx
tmx16 A01-009.tmx A01-009.map

pack A01*.map

cd..
cd engine
tniasm Usas2.asm
del tniasm.out
del tniasm.tmp
cd..
cd maps