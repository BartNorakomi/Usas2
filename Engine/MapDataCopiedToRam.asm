              ;block            mapname   enginetype,tiledata,palette
WorldMapDataWidth:      equ 2 ;7     ;amount of maps in width 
WorldMapDataMapLenght:  equ 6     ;amount of bytes data per map

MapA01_001Data: db MapsBlock01 | dw MapA01_001 | db 1,3,3                  | MapA01_002Data: db MapsBlock01 | dw MapA01_002 | db 1,3,3                  | MapA01_003Data: db MapsBlock01 | dw MapA01_003 | db 1,3,3
MapA01_004Data: db MapsBlock01 | dw MapA01_004 | db 1,3,3                  | MapA01_005Data: db MapsBlock01 | dw MapA01_005 | db 1,3,3                  | MapA01_006Data: db MapsBlock01 | dw MapA01_006 | db 1,3,3
MapA01_007Data: db MapsBlock01 | dw MapA01_007 | db 1,3,3                  | MapA01_008Data: db MapsBlock01 | dw MapA01_008 | db 1,3,3                  | MapA01_009Data: db MapsBlock01 | dw MapA01_009 | db 1,3,3
MapA01_010Data: db MapsBlock01 | dw MapA01_010 | db 1,3,3                  | MapA01_011Data: db MapsBlock01 | dw MapA01_011 | db 1,3,3                  | MapA01_012Data: db MapsBlock01 | dw MapA01_012 | db 1,3,3
MapA01_013Data: db MapsBlock01 | dw MapA01_013 | db 1,3,3                  | MapA01_014Data: db MapsBlock01 | dw MapA01_014 | db 1,3,3                  | MapA01_015Data: db MapsBlock01 | dw MapA01_015 | db 1,3,3
MapA01_016Data: db MapsBlock01 | dw MapA01_016 | db 1,3,3

MapB01_001Data: db MapsBlock02 | dw MapB01_001 | db 2,3,3                  | MapB01_002Data: db MapsBlock02 | dw MapB01_002 | db 1,3,3                  | MapB01_003Data: db MapsBlock02 | dw MapB01_003 | db 1,3,3
MapB01_004Data: db MapsBlock02 | dw MapB01_004 | db 1,3,3                  | MapB01_005Data: db MapsBlock02 | dw MapB01_005 | db 1,3,3                  | MapB01_006Data: db MapsBlock02 | dw MapB01_006 | db 1,3,3
MapB01_007Data: db MapsBlock02 | dw MapB01_007 | db 1,3,3                  | MapB01_008Data: db MapsBlock02 | dw MapB01_008 | db 1,3,3                  | MapB01_009Data: db MapsBlock02 | dw MapB01_009 | db 1,3,3
MapB01_010Data: db MapsBlock02 | dw MapB01_010 | db 1,3,3                  | MapB01_011Data: db MapsBlock02 | dw MapB01_011 | db 1,3,3                  | MapB01_012Data: db MapsBlock02 | dw MapB01_012 | db 1,3,3
MapB01_013Data: db MapsBlock02 | dw MapB01_013 | db 1,3,3                  | MapB01_014Data: db MapsBlock02 | dw MapB01_014 | db 1,3,3                  | MapB01_015Data: db MapsBlock02 | dw MapB01_015 | db 1,3,3
MapB01_016Data: db MapsBlock02 | dw MapB01_016 | db 2,3,3                  | MapB01_017Data: db MapsBlock02 | dw MapB01_017 | db 1,3,3                  | MapB01_018Data: db MapsBlock02 | dw MapB01_018 | db 1,3,3
MapB01_019Data: db MapsBlock02 | dw MapB01_019 | db 2,3,3                  | MapB01_020Data: db MapsBlock02 | dw MapB01_020 | db 2,3,3                  | MapB01_021Data: db MapsBlock02 | dw MapB01_021 | db 2,3,3
MapB01_022Data: db MapsBlock02 | dw MapB01_022 | db 1,3,3                  | MapB01_023Data: db MapsBlock02 | dw MapB01_023 | db 1,3,3                  | MapB01_024Data: db MapsBlock02 | dw MapB01_024 | db 1,3,3
MapB01_025Data: db MapsBlock02 | dw MapB01_025 | db 1,3,3                  | MapB01_026Data: db MapsBlock02 | dw MapB01_026 | db 1,3,3                  | MapB01_027Data: db MapsBlock02 | dw MapB01_027 | db 1,3,3
;engine type 1 = normal (304x192), engine type 2 = SF2 engine with bordermasking spritesplit off, engine type 2 = SF2 engine with bordermasking spritesplit on (so more sprites are available)
MapA01Data: db MapsBlock0A | dw MapA01 | db 1,0,0   | MapB01Data: db MapsBlock0B | dw MapB01 | db 1,0,0   | MapC01Data: db MapsBlock0C | dw MapC01 | db 1,0,0   | MapD01Data: db MapsBlock0D | dw MapD01 | db 1,0,0   | MapE01Data: db MapsBlock0E | dw MapE01 | db 1,1,1   | MapF01Data: db MapsBlock0F | dw MapF01 | db 1,1,1   | MapG01Data: db MapsBlock0G | dw MapG01 | db 1,1,1
MapA02Data: db MapsBlock0A | dw MapA02 | db 1,0,0   | MapB02Data: db MapsBlock0B | dw MapB02 | db 1,0,0   | MapC02Data: db MapsBlock0C | dw MapC02 | db 1,0,0   | MapD02Data: db MapsBlock0D | dw MapD02 | db 1,0,0   | MapE02Data: db MapsBlock0E | dw MapE02 | db 1,1,1   | MapF02Data: db MapsBlock0F | dw MapF02 | db 1,1,1   | MapG02Data: db MapsBlock0G | dw MapG02 | db 1,1,1
MapA03Data: db MapsBlock0A | dw MapA03 | db 1,0,0   | MapB03Data: db MapsBlock0B | dw MapB03 | db 1,0,0   | MapC03Data: db MapsBlock0C | dw MapC03 | db 1,0,0   | MapD03Data: db MapsBlock0D | dw MapD03 | db 1,0,0   | MapE03Data: db MapsBlock0E | dw MapE03 | db 1,1,1   | MapF03Data: db MapsBlock0F | dw MapF03 | db 1,1,1   | MapG03Data: db MapsBlock0G | dw MapG03 | db 1,1,1
MapA04Data: db MapsBlock0A | dw MapA04 | db 3,3,3   | MapB04Data: db MapsBlock0B | dw MapB04 | db 1,3,3   | MapC04Data: db MapsBlock0C | dw MapC04 | db 1,3,3   | MapD04Data: db MapsBlock0D | dw MapD04 | db 2,6,6   | MapE04Data: db MapsBlock0E | dw MapE04 | db 2,6,6   | MapF04Data: db MapsBlock0F | dw MapF04 | db 1,1,1   | MapG04Data: db MapsBlock02 | dw MapB01_017 | db 1,3,3 ;     MapB01_017Data: db MapsBlock02 | dw MapB01_017 | db 1,3,3
MapA05Data: db MapsBlock0A | dw MapA05 | db 1,3,3   | MapB05Data: db MapsBlock0B | dw MapB05 | db 1,3,3   | MapC05Data: db MapsBlock0C | dw MapC05 | db 1,3,3   | MapD05Data: db MapsBlock0D | dw MapD05 | db 1,0,0 | MapE05Data: db MapsBlock02 | dw MapB01_019 | db 2,3,3 | MapF05Data: db MapsBlock0F | dw MapF05 | db 1,1,1   | MapG05Data: db MapsBlock0G | dw MapG05 | db 3,5,5
MapA06Data: db MapsBlock0A | dw MapA06 | db 1,3,3   | MapB06Data: db MapsBlock0B | dw MapB06 | db 1,3,3   | MapC06Data: db MapsBlock0C | dw MapC06 | db 1,3,3   | MapD06Data: db MapsBlock0D | dw MapD06 | db 1,5,5   | MapE06Data: db MapsBlock0E | dw MapE06 | db 1,5,5   | MapF06Data: db MapsBlock0F | dw MapF06 | db 1,5,5   | MapG06Data: db MapsBlock0G | dw MapG06 | db 1,5,5
MapA07Data: db MapsBlock0A | dw MapA07 | db 1,3,3   | MapB07Data: db MapsBlock0B | dw MapB07 | db 1,3,3   | MapC07Data: db MapsBlock0C | dw MapC07 | db 1,3,3   | MapD07Data: db MapsBlock0D | dw MapD07 | db 1,5,5   | MapE07Data: db MapsBlock0E | dw MapE07 | db 1,5,5   | MapF07Data: db MapsBlock0F | dw MapF07 | db 1,5,5   | MapG07Data: db MapsBlock0G | dw MapG07 | db 1,5,5
MapA08Data: db MapsBlock0A | dw MapA08 | db 1,4,4   | MapB08Data: db MapsBlock0B | dw MapB08 | db 1,4,4   | MapC08Data: db MapsBlock0C | dw MapC08 | db 1,4,4   | MapD08Data: db MapsBlock0D | dw MapD08 | db 1,4,4   | MapE08Data: db MapsBlock0E | dw MapE08 | db 1,5,5   | MapF08Data: db MapsBlock0F | dw MapF08 | db 1,5,5   | MapG08Data: db MapsBlock0G | dw MapG08 | db 1,5,5
MapA09Data: db MapsBlock0A | dw MapA09 | db 1,4,4   | MapB09Data: db MapsBlock0B | dw MapB09 | db 1,4,4   | MapC09Data: db MapsBlock0C | dw MapC09 | db 1,4,4   | MapD09Data: db MapsBlock0D | dw MapD09 | db 1,4,4   | MapE09Data: db MapsBlock0E | dw MapE09 | db 1,5,5   | MapF09Data: db MapsBlock0F | dw MapF09 | db 1,5,5   | MapG09Data: db MapsBlock0G | dw MapG09 | db 1,5,5
MapA10Data: db MapsBlock0A | dw MapA10 | db 1,2,2   | MapB10Data: db MapsBlock0B | dw MapB10 | db 1,2,2   | MapC10Data: db MapsBlock0C | dw MapC10 | db 1,2,2   | MapD10Data: db MapsBlock0D | dw MapD10 | db 1,4,4   | MapE10Data: db MapsBlock0E | dw MapE10 | db 1,4,4   | MapF10Data: db MapsBlock0F | dw MapF10 | db 1,5,5   | MapG10Data: db MapsBlock0G | dw MapG10 | db 1,5,5
MapA11Data: db MapsBlock0A | dw MapA11 | db 1,2,2   | MapB11Data: db MapsBlock0B | dw MapB11 | db 1,2,2   | MapC11Data: db MapsBlock0C | dw MapC11 | db 1,2,2   | MapD11Data: db MapsBlock0D | dw MapD11 | db 1,4,4   | MapE11Data: db MapsBlock0E | dw MapE11 | db 1,4,4   | MapF11Data: db MapsBlock0F | dw MapF11 | db 1,5,5   | MapG11Data: db MapsBlock0G | dw MapG11 | db 1,5,5
MapA12Data: db MapsBlock0A | dw MapA12 | db 1,2,2   | MapB12Data: db MapsBlock0B | dw MapB12 | db 1,2,2   | MapC12Data: db MapsBlock0C | dw MapC12 | db 1,2,2   | MapD12Data: db MapsBlock0D | dw MapD12 | db 1,4,4   | MapE12Data: db MapsBlock0E | dw MapE12 | db 1,2,2   | MapF12Data: db MapsBlock0F | dw MapF12 | db 1,5,5   | MapG12Data: db MapsBlock0G | dw MapG12 | db 1,5,5
MapA13Data: db MapsBlock0A | dw MapA13 | db 2,2,2   | MapB13Data: db MapsBlock0B | dw MapB13 | db 1,2,2   | MapC13Data: db MapsBlock0C | dw MapC13 | db 1,2,2   | MapD13Data: db MapsBlock0D | dw MapD13 | db 1,2,2   | MapE13Data: db MapsBlock0E | dw MapE13 | db 1,2,2   | MapF13Data: db MapsBlock0F | dw MapF13 | db 1,7,7   | MapG13Data: db MapsBlock0G | dw MapG13 | db 2,7,7

MapAA01Data: db MapsBlockAA01|dw MapAA01|db 1,3,3  |  MapAB01Data: db MapsBlockAB01|dw MapAB01|db 1,3,3  |  
MapAA02Data: db MapsBlockAA02|dw MapAA02|db 1,3,3  |  MapAB02Data: db MapsBlockAB02|dw MapAB02|db 1,3,3  |  
MapAA03Data: db MapsBlockAA03|dw MapAA03|db 1,3,3  |  ds 6                                               |  
MapAA04Data: db MapsBlockAA04|dw MapAA04|db 1,3,3  |  ds 6                                               |  
MapAA05Data: db MapsBlockAA05|dw MapAA05|db 1,3,3  |  MapAB05Data: db MapsBlockAB05|dw MapAB05|db 1,3,3  |  
MapAA06Data: db MapsBlockAA06|dw MapAA06|db 1,3,3  |  MapAB06Data: db MapsBlockAB06|dw MapAB06|db 1,3,3  |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  MapAB09Data: db MapsBlockAB09|dw MapAB09|db 1,3,3  |  
ds 6                                               |  MapAB10Data: db MapsBlockAB10|dw MapAB10|db 1,3,3  |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  MapAB12Data: db MapsBlockAB12|dw MapAB12|db 1,3,3  |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
MapAA35Data: db MapsBlockAA35|dw MapAA35|db 1,3,3  |  MapAB35Data: db MapsBlockAB35|dw MapAB35|db 1,3,3  |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  ds 6                                               |  
ds 6                                               |  MapAB45Data: db MapsBlockAB45|dw MapAB45|db 1,3,3  |  
ds 6                                               |  MapAB46Data: db MapsBlockAB46|dw MapAB46|db 1,3,3  |  
MapAA47Data: db MapsBlockAA47|dw MapAA47|db 1,3,3  |  MapAB47Data: db MapsBlockAB47|dw MapAB47|db 1,3,3  |  
MapAA48Data: db MapsBlockAA48|dw MapAA48|db 1,3,3  |  MapAB48Data: db MapsBlockAB48|dw MapAB48|db 1,3,3  |  
MapAA49Data: db MapsBlockAA49|dw MapAA49|db 1,3,3  |  MapAB49Data: db MapsBlockAB49|dw MapAB49|db 1,3,3  |  
ds 6                                               |  ds 6                                               |  