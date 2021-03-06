phase	$c000
WorldMapData:
WorldMapDataWidth:      equ 7     ;amount of maps in width 
WorldMapDataMapLenght:  equ 6     ;amount of bytes data per map
              ;block            mapname   enginetype,tiledata,palette
MapA01_001Data: db MapsBlock01 | dw MapA01_001 | db 1,3,3                  | MapA01_002Data: db MapsBlock01 | dw MapA01_002 | db 1,3,3                  | MapA01_003Data: db MapsBlock01 | dw MapA01_003 | db 1,3,3
MapA01_004Data: db MapsBlock01 | dw MapA01_004 | db 1,3,3                  | MapA01_005Data: db MapsBlock01 | dw MapA01_005 | db 1,3,3                  | MapA01_006Data: db MapsBlock01 | dw MapA01_006 | db 1,3,3
MapA01_007Data: db MapsBlock01 | dw MapA01_007 | db 1,3,3                  | MapA01_008Data: db MapsBlock01 | dw MapA01_008 | db 1,3,3                  | MapA01_009Data: db MapsBlock01 | dw MapA01_009 | db 1,3,3

MapB01_001Data: db MapsBlock02 | dw MapB01_001 | db 2,3,3                  | MapB01_002Data: db MapsBlock02 | dw MapB01_002 | db 1,3,3                  | MapB01_003Data: db MapsBlock02 | dw MapB01_003 | db 1,3,3
MapB01_004Data: db MapsBlock02 | dw MapB01_004 | db 1,3,3                  | MapB01_005Data: db MapsBlock02 | dw MapB01_005 | db 1,3,3                  | MapB01_006Data: db MapsBlock02 | dw MapB01_006 | db 1,3,3
MapB01_007Data: db MapsBlock02 | dw MapB01_007 | db 1,3,3                  | MapB01_008Data: db MapsBlock02 | dw MapB01_008 | db 1,3,3                  | MapB01_009Data: db MapsBlock02 | dw MapB01_009 | db 1,3,3
MapB01_010Data: db MapsBlock02 | dw MapB01_010 | db 1,3,3                  | MapB01_011Data: db MapsBlock02 | dw MapB01_011 | db 1,3,3                  | MapB01_012Data: db MapsBlock02 | dw MapB01_012 | db 1,3,3
MapB01_013Data: db MapsBlock02 | dw MapB01_013 | db 1,3,3                  | MapB01_014Data: db MapsBlock02 | dw MapB01_014 | db 1,3,3                  | MapB01_015Data: db MapsBlock02 | dw MapB01_015 | db 1,3,3
MapB01_016Data: db MapsBlock02 | dw MapB01_016 | db 2,3,3                  | MapB01_017Data: db MapsBlock02 | dw MapB01_017 | db 1,3,3                  | MapB01_018Data: db MapsBlock02 | dw MapB01_018 | db 1,3,3
MapB01_019Data: db MapsBlock02 | dw MapB01_019 | db 2,3,3                  | MapB01_020Data: db MapsBlock02 | dw MapB01_020 | db 2,3,3                  | MapB01_021Data: db MapsBlock02 | dw MapB01_021 | db 2,3,3
MapB01_022Data: db MapsBlock02 | dw MapB01_022 | db 1,3,3                  | MapB01_023Data: db MapsBlock02 | dw MapB01_023 | db 1,3,3                  | MapB01_024Data: db MapsBlock02 | dw MapB01_024 | db 1,3,3
MapB01_025Data: db MapsBlock02 | dw MapB01_025 | db 1,3,3                  | MapB01_026Data: db MapsBlock02 | dw MapB01_026 | db 1,3,3                  | MapB01_027Data: db MapsBlock02 | dw MapB01_027 | db 1,3,3

MapA01Data: db MapsBlock0A | dw MapA01 | db 1,0,0   | MapB01Data: db MapsBlock0B | dw MapB01 | db 1,0,0   | MapC01Data: db MapsBlock0C | dw MapC01 | db 1,0,0   | MapD01Data: db MapsBlock0D | dw MapD01 | db 1,0,0   | MapE01Data: db MapsBlock0E | dw MapE01 | db 1,1,1   | MapF01Data: db MapsBlock0F | dw MapF01 | db 1,1,1   | MapG01Data: db MapsBlock0G | dw MapG01 | db 1,1,1
MapA02Data: db MapsBlock0A | dw MapA02 | db 1,0,0   | MapB02Data: db MapsBlock0B | dw MapB02 | db 1,0,0   | MapC02Data: db MapsBlock0C | dw MapC02 | db 1,0,0   | MapD02Data: db MapsBlock0D | dw MapD02 | db 1,0,0   | MapE02Data: db MapsBlock0E | dw MapE02 | db 1,1,1   | MapF02Data: db MapsBlock0F | dw MapF02 | db 1,1,1   | MapG02Data: db MapsBlock0G | dw MapG02 | db 1,1,1
MapA03Data: db MapsBlock0A | dw MapA03 | db 1,0,0   | MapB03Data: db MapsBlock0B | dw MapB03 | db 1,0,0   | MapC03Data: db MapsBlock0C | dw MapC03 | db 1,0,0   | MapD03Data: db MapsBlock0D | dw MapD03 | db 1,0,0   | MapE03Data: db MapsBlock0E | dw MapE03 | db 1,1,1   | MapF03Data: db MapsBlock0F | dw MapF03 | db 1,1,1   | MapG03Data: db MapsBlock0G | dw MapG03 | db 1,1,1
MapA04Data: db MapsBlock0A | dw MapA04 | db 2,3,3   | MapB04Data: db MapsBlock0B | dw MapB04 | db 1,3,3   | MapC04Data: db MapsBlock0C | dw MapC04 | db 1,3,3   | MapD04Data: db MapsBlock0D | dw MapD04 | db 1,0,0   | MapE04Data: db MapsBlock0E | dw MapE04 | db 1,1,1   | MapF04Data: db MapsBlock0F | dw MapF04 | db 1,1,1   | MapG04Data: db MapsBlock0G | dw MapG04 | db 1,1,1
MapA05Data: db MapsBlock0A | dw MapA05 | db 1,3,3   | MapB05Data: db MapsBlock0B | dw MapB05 | db 1,3,3   | MapC05Data: db MapsBlock0C | dw MapC05 | db 1,3,3   | MapD05Data: db MapsBlock0D | dw MapD05 | db 1,0,0   | MapE05Data: db MapsBlock0E | dw MapE05 | db 1,1,1   | MapF05Data: db MapsBlock0F | dw MapF05 | db 1,1,1   | MapG05Data: db MapsBlock0G | dw MapG05 | db 1,1,1
MapA06Data: db MapsBlock0A | dw MapA06 | db 1,3,3   | MapB06Data: db MapsBlock0B | dw MapB06 | db 1,3,3   | MapC06Data: db MapsBlock0C | dw MapC06 | db 1,3,3   | MapD06Data: db MapsBlock0D | dw MapD06 | db 1,5,5   | MapE06Data: db MapsBlock0E | dw MapE06 | db 1,5,5   | MapF06Data: db MapsBlock0F | dw MapF06 | db 1,5,5   | MapG06Data: db MapsBlock0G | dw MapG06 | db 1,5,5
MapA07Data: db MapsBlock0A | dw MapA07 | db 1,3,3   | MapB07Data: db MapsBlock0B | dw MapB07 | db 1,3,3   | MapC07Data: db MapsBlock0C | dw MapC07 | db 1,3,3   | MapD07Data: db MapsBlock0D | dw MapD07 | db 1,5,5   | MapE07Data: db MapsBlock0E | dw MapE07 | db 1,5,5   | MapF07Data: db MapsBlock0F | dw MapF07 | db 1,5,5   | MapG07Data: db MapsBlock0G | dw MapG07 | db 1,5,5
MapA08Data: db MapsBlock0A | dw MapA08 | db 1,4,4   | MapB08Data: db MapsBlock0B | dw MapB08 | db 1,4,4   | MapC08Data: db MapsBlock0C | dw MapC08 | db 1,4,4   | MapD08Data: db MapsBlock0D | dw MapD08 | db 1,4,4   | MapE08Data: db MapsBlock0E | dw MapE08 | db 1,5,5   | MapF08Data: db MapsBlock0F | dw MapF08 | db 1,5,5   | MapG08Data: db MapsBlock0G | dw MapG08 | db 1,5,5
MapA09Data: db MapsBlock0A | dw MapA09 | db 1,4,4   | MapB09Data: db MapsBlock0B | dw MapB09 | db 1,4,4   | MapC09Data: db MapsBlock0C | dw MapC09 | db 1,4,4   | MapD09Data: db MapsBlock0D | dw MapD09 | db 1,4,4   | MapE09Data: db MapsBlock0E | dw MapE09 | db 1,5,5   | MapF09Data: db MapsBlock0F | dw MapF09 | db 1,5,5   | MapG09Data: db MapsBlock0G | dw MapG09 | db 1,5,5
MapA10Data: db MapsBlock0A | dw MapA10 | db 1,2,2   | MapB10Data: db MapsBlock0B | dw MapB10 | db 1,2,2   | MapC10Data: db MapsBlock0C | dw MapC10 | db 1,2,2   | MapD10Data: db MapsBlock0D | dw MapD10 | db 1,4,4   | MapE10Data: db MapsBlock0E | dw MapE10 | db 1,4,4   | MapF10Data: db MapsBlock0F | dw MapF10 | db 1,1,1   | MapG10Data: db MapsBlock0G | dw MapG10 | db 1,1,1
MapA11Data: db MapsBlock0A | dw MapA11 | db 1,2,2   | MapB11Data: db MapsBlock0B | dw MapB11 | db 1,2,2   | MapC11Data: db MapsBlock0C | dw MapC11 | db 1,2,2   | MapD11Data: db MapsBlock0D | dw MapD11 | db 1,4,4   | MapE11Data: db MapsBlock0E | dw MapE11 | db 1,4,4   | MapF11Data: db MapsBlock0F | dw MapF11 | db 1,1,1   | MapG11Data: db MapsBlock0G | dw MapG11 | db 1,1,1
MapA12Data: db MapsBlock0A | dw MapA12 | db 1,2,2   | MapB12Data: db MapsBlock0B | dw MapB12 | db 1,2,2   | MapC12Data: db MapsBlock0C | dw MapC12 | db 1,2,2   | MapD12Data: db MapsBlock0D | dw MapD12 | db 1,4,4   | MapE12Data: db MapsBlock0E | dw MapE12 | db 1,2,2   | MapF12Data: db MapsBlock0F | dw MapF12 | db 1,1,1   | MapG12Data: db MapsBlock0G | dw MapG12 | db 1,1,1
MapA13Data: db MapsBlock0A | dw MapA13 | db 1,2,2   | MapB13Data: db MapsBlock0B | dw MapB13 | db 1,2,2   | MapC13Data: db MapsBlock0C | dw MapC13 | db 1,2,2   | MapD13Data: db MapsBlock0D | dw MapD13 | db 1,2,2   | MapE13Data: db MapsBlock0E | dw MapE13 | db 1,2,2   | MapF13Data: db MapsBlock0F | dw MapF13 | db 1,1,1   | MapG13Data: db MapsBlock0G | dw MapG13 | db 1,1,1





;WorldMapPointer:  dw  MapB01_018Data
;WorldMapPointer:  dw  MapB01_027Data
;WorldMapPointer:  dw  MapB01_014Data
WorldMapPointer:  dw  MapC07Data

loadGraphics:
;  call  InitiateMusicReplayer         ;set music replayer at $4000 in ram

  call  screenoff
  call  ReSetVariables

  call  SwapSpatColAndCharTable2
  call  SwapSpatColAndCharTable
  call  SwapSpatColAndCharTable2
  
  ld    ix,(WorldMapPointer)
  call  SetEngineType                 ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
  call  SetTilesInVram                ;copies all the tiles to Vram
  call  PopulateControls              ;this allows for a double jump as soon as you enter a new map
  call  SetMapPalette                 ;sets palette
  call  UnpackMapdata_SetObjects      ;unpacks packed map to $4000 in ram and sets objects
  call  ConvertToMapinRam             ;convert 16bit tiles into 0=background, 1=hard foreground, 2=ladder, 3=lava. Converts from map in $4000 to MapData in page 3
  call  BuildUpMap                    ;build up the map in Vram to page 1,2,3,4
  call  CopyScoreBoard                ;copy scoreboard to page 0 - screen 5 - bottom 40 pixels (scoreboard)
  call  CopyItemsKarniMata            ;copy items to page 1 - screen 5 - bottom 40 pixels (scoreboard)
  call  RemoveSpritesFromScreen
  call  SwapSpatColAndCharTable
  call  PutSpatToVramSlow
  call  SwapSpatColAndCharTable
  call  PutSpatToVramSlow
  call  initiatebordermaskingsprites

;	di
;  ld    a,$05
;	out   ($99),a       ;set bits 15-17
;	ld    a,14+128
;  ei
;	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)

  ld    a,1
  ld    (CopyObject+spage),a
  ld    a,216
  ld    (CopyObject+sy),a  
  
  call  SetInterruptHandler           ;set Lineint and Vblank  
  call  WaitForInterrupt              ;if SF2 engine: Wait for Vblank | if normal engine: wait for lineint

;  xor   a
;  ld    (Controls),a                  ;this allows for a double jump as soon as you enter a new map
;  ld    (NewPrContr),a                  ;this allows for a double jump as soon as you enter a new map
  jp    LevelEngine

InitiateMusicReplayer:                ;set music replayer at $4000 in ram
  ld    a,(slot.page2rom)             ;all RAM except page 2
  out   ($a8),a
  
  ld    a,MusicReplayerBlock          ;Music replayer block
  call  block34                       ;set at $8000
  
  ld    hl,$8000
  ld    de,$4000
  ld    bc,$4000
  ldir                                ;copy music replayer to $4000 in ram
  
  ld    a,MusicTestBlock              ;set test tune at $8000 in rom
  call  block34                       ;song at $8000        
  
  call  initOPL4                      ;Initialise OPL4
;  call  Initialise                    ;Initialise driver
;  call  stop_music                    ;stop + halt music
;  call  Music.LoadKit
;  call  Music.LoadSong
;  Call  start_music

.playloop:
;  Call  play_int                      ;play music on interrupt
  halt
  jp .playloop













initOPL4:       ld      a,5
                out     ($c6),a
                ld      a,3
                out     ($c7),a

; Initialiseer OPL4 om te lezen/schrijven
                ld      e,$20
                ld      hl,OWNTONES * 12
setSRAMacces:   ld      bc,256 * 17 + 2
                call    wave_out          ; Memory Acces mogelijk
                ld      b,e
                ld      c,3
                call    wave_out
                ld      b,h
                inc     c
                call    wave_out
                ld      b,l
                inc     c
                call    wave_out
                ld      a,6
                out     ($7e),a

                ld      hl,cymball
                ld      b,12    ; 12 bytes verplaatsen
move_headers1:  in      a,($c4)
                and     1
                jr      nz,move_headers1
                ld      a,(hl)
                inc     hl
                out     ($7f),a
                djnz    move_headers1
                ret

; Schrijf waarde naar register
wave_out:       ld      a,c
                out     ($7e),a
		nop
                ld      a,b
                out     ($7f),a
                ret

; cymball - 400
cymball:     	db    70,120,216,18,126,181,165,      0,244,242,6,0

OWNTONES:       equ     48      ; aantal mogelijke eigen samples















  
ReSetVariables:
  ;set player sprites to spritenumber 28 for char and color address
  ld    a,$7b ;-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddress),a
  ld    a,$75 ;-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddress),a
  ld    a,$73 ;-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddressMirror),a
  ld    a,$6d ;-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddressMirror),a
  ;set player sprites to spritenumber 28 for spatposition
  ld    hl,spat+(28 * 2)
  ld    (Apply32bitShift.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerLeftSideOfScreen.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerRightSideOfScreen.SelfmodyfyingSpataddressPlayer),hl          
  
  ld    a,StartingJumpSpeedEqu        ;reset Starting Jump Speed
  ld    (StartingJumpSpeed),a
  inc   a
  ld    (StartingJumpSpeedWhenHit),a
  
  ld    hl,.NormalRunningTable        ;Reset Normal Running Table
  ld    de,RunningTable1
  ld    bc,RunningTableLenght
  ldir

  xor   a
  ld    (ShakeScreen?),a
  ld    (PlayerDead?),a

  xor   a
  ld    (ArrowActive?),a              ;remove arrow weapon  
  ld    (FireballActive?),a              ;remove arrow weapon  
  ret  

.NormalRunningTable:
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
;  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
;  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
;  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1


WaitForInterrupt:
  ld    a,(CameraY)
  xor   a
  ld    (R23onVblank),a
  add   a,lineintheight
  ld    (R19onVblank),a

  ld    a,(scrollEngine)          ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a                         
  ld    hl,lineintflag  
;  jr    z,.EngineFound
  ld    hl,vblankintflag    
  .EngineFound:  
  xor   a
  ld    (hl),a  
.checkflag:
  cp    (hl)
  jr    z,.checkflag

  xor   a
  ld    (vblankintflag),a
  ld    (lineintflag),a
  ld    (SpriteSplitAtY100?),a
  ret

SpriteSplitFlag:      db  1
SpriteSplitAtY100?:   db  0

PutSpatToVramSlow:
	ld		hl,(invisspratttableaddress)		;sprite attribute table in VRAM ($17600)
	ld		a,1
	call	SetVdp_Write	

	ld		hl,spatSlow			                ;sprite attribute table
  ld    c,$98
	call	outix128
  ret

spatSlow:						;sprite attribute table
	db		000,000,000,0	,000,000,004,0	,000,000,008,0	,000,000,012,0
	db		000,000,016,0	,000,000,020,0	,000,000,024,0	,000,000,028,0
	db		000,000,032,0	,000,000,036,0	,000,000,040,0	,000,000,044,0
	db		000,000,048,0	,000,000,052,0	,000,000,056,0	,000,000,060,0
	
	db		000,000,064,0	,000,000,068,0	,000,000,072,0	,000,000,076,0
	db		000,000,080,0	,000,000,084,0	,000,100,088,0	,000,100,092,0
	db		000,100,096,0	,000,100,100,0	,000,000,104,0	,000,000,108,0
	db		000,000,112,0	,000,000,116,0	,000,000,120,0	,000,000,124,0

RemoveSpritesFromScreen:
  ld    hl,spat
  ld    de,2
  ld    b,32
  .loop:
  ld    (hl),217
  add   hl,de
  djnz  .loop
  ret

WaitVblank:
  xor   a
  ld    hl,vblankintflag
.checkflag:
  cp    (hl)
  jr    z,.checkflag
  ld    (hl),a  
  ld    (lineintflag),a
  ret

BuildUpMap:
  ld    hl,$4000
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jp    z,buildupMap38x27
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  cp    2
  jp    z,buildupMap32x27
  ret
  
UnpackMapdata_SetObjects:
  ;set all objects Alive? to 0 / clear all objects from the list
  ld    b,amountofenemies
  ld    hl,enemies_and_objects
  ld    de,lenghtenemytable
  xor   a
  .ClearEnemyTableLoop:
  ld    (hl),a
  add   hl,de
  djnz  .ClearEnemyTableLoop

;unpack map data
  ld    a,(slot.page2rom)             ;all RAM except page 2
  out   ($a8),a      

  ld    a,(ix+0)                      ;Map block
  call  block34

  ld    l,(ix+1)                      ;map data in rom
  ld    h,(ix+2)
    
  ld    de,$4000
  call  Depack
  
  ;FOR NOW LETS ASUME DEPACK ALWAYS ENDS HL 2 BYTES FURTHER TO THE RIGHT
  dec   hl
  dec   hl
    
  ld    a,(hl)                        ;amount of objects for this map
  or    a
  ret   z
  
  inc   hl                            ;object 1 - table
  ld    de,enemies_and_objects        ;copy just 1 object for now
  
  .CopyAllEnemiesLoop:
  ld    bc,lenghtenemytable
  ldir
  dec   a
  jp    nz,.CopyAllEnemiesLoop
  ret

SetMapPalette:
;set palette
  ld    a,(ix+5)                      ;palette
  or    a
  ld    hl,VoodooWaspPalette
  jr    z,.goSetPalette
  dec   a
  ld    hl,GoddessPalette
  jr    z,.goSetPalette
  dec   a
  ld    hl,KonarkPalette
  jr    z,.goSetPalette
  dec   a
  ld    hl,KarniMataPalette
  jr    z,.goSetPalette
  dec   a
  ld    hl,BlueTemplePalette
  jr    z,.goSetPalette
  dec   a
  ld    hl,BurialPalette
  jr    z,.goSetPalette

  .goSetPalette:  
  call  setpalette
  ret

SetTilesInVram:  
;set tiles in Vram
  ld    a,(ix+4)                      ;tile data
  or    a
  ld    d,VoodooWaspTilesBlock
  jr    z,.settiles
  dec   a
  ld    d,GoddessTilesBlock
  jr    z,.settiles
  dec   a
  ld    d,KonarkTilesBlock
  jr    z,.settiles
  dec   a
  ld    d,KarniMataTilesBlock
  jr    z,.settiles
  dec   a
  ld    d,BlueTempleTilesBlock
  jr    z,.settiles
  dec   a
  ld    d,BurialTilesBlock
  jr    z,.settiles

  .settiles:
  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a          

  ld    hl,$8000                      ;page 1 - screen 5
  ld    b,0
  call  copyGraphicsToScreen
  ret

SetEngineType:                    ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
;Set Engine type
  ld    a,(ix+3)                  ;engine type
  ld    (scrollEngine),a          ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a                         ;1= 304x216 engine  2=256x216 SF2 engine
  jp    z,.Engine304x216

.Engine256x216:                   ;SF2 engine
  ld    de,CheckTile256x216MapLenght
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,ExitRight256x216
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
  ld    a,MapLenght256x216
  ld    (ConvertToMapinRam.SelfModifyingCodeMapLenght+1),a
  ld    de,MapData- 68
  ld    (checktile.selfmodifyingcodeStartingPosMapForCheckTile+1),de
  xor   a
  ld    (SpriteSplitFlag),a
 
;check if player enters on the left side of the screen or on the right side. On the left camerax = 0, on the right camerax=15
  ld    hl,256/2
  ld    de,(ClesX)
  sbc   hl,de
  ld    a,15
  jr    c,.setCameraX
  xor   a
  .setCameraX:
  ld    (CameraX),a
  
  ;if engine type = 256x216 and x Cles = 34*8, then move cles 6 tiles to the left, because this Engine type has a screen width of 6 tiles less
  ld    hl,(ClesX)
  ld    de,ExitRight304x216
  xor   a
  sbc   hl,de
  ret   nz
  ld    hl,252 ;28*8
  ld    (ClesX),hl
  ret

.Engine304x216:                        ;
  ld    de,CheckTile304x216MapLenght
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,ExitRight304x216
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
  ld    a,MapLenght304x216
  ld    (ConvertToMapinRam.SelfModifyingCodeMapLenght+1),a
  ld    de,MapData- 80
  ld    (checktile.selfmodifyingcodeStartingPosMapForCheckTile+1),de

  ld    a,1
  ld    (SpriteSplitFlag),a
  ret
  
buildupMap32x27:
;first put 32*27 tiles to page 0, starting at (0,0)
  ld    a,32
  ld    b,a                 ;32 tiles on x-axis
  ld    (AmountTilesToPut),a
  ld    a,0
  ld    (DXtiles),a
  ld    (SetTile+dx),a
  ld    a,0 * 2             ;6 tiles (2 bytes each)
  ld    (AmountTilesToSkip),a
  ld    c,27                ;27 tiles on y axis
  xor   a
  ld    (SetTile+dy),a
  ld    (SetTile+dpage),a
  call  buildupMap38x27.xloop
  
  ld    hl,.CopyPage0to1
  call  docopy  
  ld    hl,.CopyPage0to2
  call  docopy  
  ld    hl,.CopyPage0to3
  call  docopy  
  ret

.CopyPage0to1:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,001   ;dx,--,dy,dpage
  db    000,001,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   
.CopyPage0to2:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,002   ;dx,--,dy,dpage
  db    000,001,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   
.CopyPage0to3:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,003   ;dx,--,dy,dpage
  db    000,001,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

buildupMap38x27:
;first put 32*27 tiles to page 0, starting at (0,0)
  push  hl

  ld    a,32
  ld    b,a                 ;32 tiles on x-axis
  ld    (AmountTilesToPut),a
  ld    a,0
  ld    (DXtiles),a
  ld    (SetTile+dx),a
  ld    a,6 * 2             ;6 tiles (2 bytes each)
  ld    (AmountTilesToSkip),a
  ld    c,27                ;27 tiles on y axis
  xor   a
  ld    (SetTile+dy),a
  ld    (SetTile+dpage),a
  call  .xloop
  pop   hl

;now put 6*27 tiles to page 3, starting at (208,0)
  ld    de,64
  add   hl,de
  xor   a
  ld    (SetTile+dy),a

  ld    a,3
  ld    (SetTile+dpage),a

  ld    a,6
  ld    b,a                 ;32 tiles on x-axis
  ld    (AmountTilesToPut),a
  ld    a,208
  ld    (DXtiles),a
  ld    (SetTile+dx),a
  ld    a,32 * 2             ;6 tiles (2 bytes each)
  ld    (AmountTilesToSkip),a
  ld    c,27                ;27 tiles on y axis
  call  .xloop

  ld    hl,.CopyRemainingParts1
  call  docopy  
  ld    hl,.CopyRemainingParts2
  call  docopy 
  ld    hl,.CopyRemainingParts3
  call  docopy  
  ld    hl,.CopyRemainingParts4
  call  docopy  
  ld    hl,.CopyRemainingParts5
  call  docopy  
  ret

.CopyRemainingParts1:
  db    208,000,000,003   ;sx,--,sy,spage
  db    224,000,000,002   ;dx,--,dy,dpage
  db    032,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.CopyRemainingParts2:
  db    208,000,000,003   ;sx,--,sy,spage
  db    240,000,000,001   ;dx,--,dy,dpage
  db    016,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.CopyRemainingParts3:
  db    016,000,000,000   ;sx,--,sy,spage
  db    000,000,000,001   ;dx,--,dy,dpage
  db    240,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.CopyRemainingParts4:
  db    016,000,000,001   ;sx,--,sy,spage
  db    000,000,000,002   ;dx,--,dy,dpage
  db    224,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.CopyRemainingParts5:
  db    016,000,000,002   ;sx,--,sy,spage
  db    000,000,000,003   ;dx,--,dy,dpage
  db    208,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   
      
.xloop:  
  ;get tilenr in de
  ld    e,(hl)              ;each tile is 16 bit. bit 0-4 (value between 0-31) give us the x value if we multiply by 8
  inc   hl
  ld    d,(hl)
  inc   hl                  ;next tile in tilemap
  
  ;set sx and sy of this tile
  dec   de
  
  ld    a,e
  add   a,a
  add   a,a
  add   a,a                 ;*8
  ld    (SetTile+sx),a

  rr    d
  rr    e                   ;/2
  rr    d
  rr    e                   ;/4
  ld    a,e                 ;each tile is 16 bit. bit 5-9 (value between 32-512) give us the y value
  and   %1111 1000
  ld    (SetTile+sy),a

  exx
  ld    hl,SetTile
  call  docopy
  exx

  ld    a,(SetTile+dx)
  add   a,8
  ld    (SetTile+dx),a
  djnz  .xloop

  ld    a,(AmountTilesToSkip)
  ld    e,a
  ld    d,0
  add   hl,de

  ld    a,(SetTile+dy)
  add   a,8
  ld    (SetTile+dy),a

  ld    a,(DXtiles)
  ld    (SetTile+dx),a

  ld    a,(AmountTilesToPut)
  ld    b,a
  dec   c
  jr    nz,.xloop
  ret

  db    0
MapData:
  ds    (38+2) * (27+2) ,0  ;a map is 38 * 27 tiles big  
MapDataLenght:  Equ $-MapData

;Engine256x216: a map is 32x27. We add 2 empty tiles on the right per row, and the remainder is filled with background tiles. Total mapsize will be 34x27 + empty fill
;Engine304x216: a map is 38x27. We add 2 empty tiles on the right per row, and we have two extra rows with background tiles. Total mapsize will be 40x27 + empty rows


MapHeight:                  equ 27
MapLenght256x216:           equ 32
MapLenght304x216:           equ 38

CheckTile256x216MapLenght:  equ 32 + 2
CheckTile304x216MapLenght:  equ 38 + 2

ConvertToMapinRam:
  ld    hl,MapData-1
  ld    de,MapData
  ld    bc,MapDataLenght
  ldir

;new
;tiles 0 - 31 are ladder tiles
;tiles 32 - 47 are spikes and lava
;tiles 48 - 49 are stairs left up
;tiles 50 - 51 are stairs right up
;tiles 52 - 255 are hard foreground
;tiles 256 - > are background


;newer
;tilenr: 1 t/m 16 = ladder
;tilenr: 17 t/m 31 = 
;tilenr: 32 t/m 39 = spikes/poison
;tilenr: 40 t/m 47 = lava
;tilenr: 48 t/m 49 = stairs left
;tilenr: 50 t/m 51 = stairs right
;tilenr: 52 t/m 255 = foreground
;tilenr: 256 t/m 1023 = background

;convert into
;tile 0 = background
;tile 1 = hardforeground
;tile 2 = laddertiles
;tile 3 = spikes/poison
;tile 4 = stairsleftup
;tile 5 = stairsrightup
;tile 6 = lava

  ld    hl,$4000
  ld    iy,MapData

  ld    c,MapHeight
.SelfModifyingCodeMapLenght:
  ld    b,000               ;maplenght: 32 or 38, depending on which engine is active
.loop:
  push  hl
  call  .convertTile
  pop   hl
  inc   hl
  inc   hl
  inc   iy
  djnz  .loop
  
  inc   iy
  inc   iy                  ;2 empty tiles on the right side of the map
  
  dec   c
  jp    nz,.SelfModifyingCodeMapLenght
  
  ret
  
;duplicate the last row 4 tiles
  ld    hl,40*26 + MapData 
  ld    de,40*27 + MapData 
  ld    bc,40
  ldir  

  ld    hl,40*26 + MapData 
  ld    de,40*28 + MapData 
  ld    bc,40
  ldir  

  ld    hl,40*26 + MapData 
  ld    de,40*29 + MapData 
  ld    bc,40
  ldir  

  ld    hl,40*26 + MapData 
  ld    de,40*30 + MapData 
  ld    bc,40
  ldir  
  ret

.convertTile:
  ;get tilenr in de
  ld    e,(hl)              ;each tile is 16 bit. bit 0-4 (value between 0-31) give us the x value if we multiply by 8
  inc   hl
  ld    d,(hl)
  inc   hl                  ;next tile in tilemap
  
  ;set sx and sy of this tile
  dec   de
  
  ld    hl,31               ;ladder
  xor   a
  sbc   hl,de
  jp    nc,.laddertiles

  ld    hl,39               ;spikes & poison
  xor   a
  sbc   hl,de
  jp    nc,.spikespoison
  
  ld    hl,47               ;lava
  xor   a
  sbc   hl,de
  jp    nc,.lava

  ld    hl,49               ;stairs left up
  xor   a
  sbc   hl,de
  jp    nc,.stairsleftup

  ld    hl,51               ;stairs right up
  xor   a
  sbc   hl,de
  jp    nc,.stairsrightup

  ld    hl,255
  xor   a
  sbc   hl,de
  jp    nc,.hardforeground
    
.background:
  ld    (iy),0
  ret

.hardforeground:
  ld    (iy),1
  ret

.laddertiles:
  ld    (iy),2
  ret

.spikespoison: 
  ld    (iy),3
  ret

.stairsleftup:
  ld    (iy),4
  ret

.stairsrightup:
  ld    (iy),5
  ret

.lava:
  ld    (iy),6
  ret
  
SetTile:
  db    000,000,000,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    008,000,008,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

DoCopy:
  ld    a,32
  di
  out   ($99),a
  ld    a,17+128
  ei
  out   ($99),a
  ld    c,$9b
.vdpready:
  ld    a,2
  di
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)
  rra
  ld    a,0
  out   ($99),a
  ld    a,15+128
  ei
  out   ($99),a
  jr    c,.vdpready

;ld b,15
;otir
;ret

	dw    $a3ed,$a3ed,$a3ed,$a3ed
	dw    $a3ed,$a3ed,$a3ed,$a3ed
	dw    $a3ed,$a3ed,$a3ed,$a3ed
	dw    $a3ed,$a3ed,$a3ed
  ret

lineintheight: equ 212-43
SetInterruptHandler:
  di
  ld    hl,InterruptHandler 
  ld    ($38+1),hl          ;set new normal interrupt
  ld    a,$c3               ;jump command
  ld    ($38),a
 
  ld    a,(VDP_0)           ;set ei1
  or    16                  ;ei1 checks for lineint and vblankint
  ld    (VDP_0),a           ;ei0 (which is default at boot) only checks vblankint
  out   ($99),a
  ld    a,128
  out   ($99),a

  ld    a,lineintheight
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  ei
  out   ($99),a 
  ret

bordermasksprite_graphics:
include "../sprites/bordermasksprite.tgs.gen"
bordermasksprite_color:
include "../sprites/bordermasksprite.tcs.gen"
bordermasksprite_color_withCEbit:
include "../sprites/bordermaskspriteECbit.tcs.gen"

initiatebordermaskingsprites:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    a,11                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    a,06                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:
  ld    (SetBorderMaskingSprites.selfmodifyingcodeAmountSpritesOneSide),a

	ld		c,$98                 ;out port
	ld		de,(sprchatableaddress)		      ;sprite character table in VRAM ($17800)
  call  bordermaskspritecharacter
	ld		de,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
  call  bordermaskspritecharacter
	ld		de,(sprcoltableaddress)		      ;sprite color table in VRAM ($17400)
  call  bordermaskspritecolor
	ld		de,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
  call  bordermaskspritecolor
  ret

  bordermaskspritecharacter:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    b,22                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    b,12                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:

  ;put border masking sprites character
  ld    hl,0 * 32             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write
  
  .loop:
  push  bc
  ld    hl,bordermasksprite_graphics
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
  pop   bc
  djnz  .loop
  ;/put border masking sprites character
  ret
  
  bordermaskspritecolor:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    b,11                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    b,06                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:
    
  ;put border masking sprites color
  ld    hl,0 * 16             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write

  .loop:                      ;alternate writing Color data between left and right sprites
  push  bc
  ld    hl,bordermasksprite_color_withCEbit
	call	outix16               ;1 sprites left side of screen (1 * 16 = 16 bytes)
  ld    hl,bordermasksprite_color
	call	outix16               ;1 sprites right side of screen (1 * 16 = 16 bytes)
  pop   bc
  djnz  .loop
  ;/put border masking sprites color
  ret

copyGraphicsToScreen:
  ld    a,d                 ;Graphicsblock
  call  block12
  
	ld		a,b
	call	SetVdp_Write	
	ld		hl,$4000
  ld    c,$98
  ld    a,64                ;first 128 line, copy 64*256 = $4000 bytes to Vram
  ld    b,0
      
  call  .loop1    

  ld    a,d                 ;Graphicsblock
  add   a,2
  call  block12
  
	ld		hl,$4000
  ld    c,$98
  ld    a,64 ; 42                ;second 84 line, copy 64*256 = $4000 bytes to Vram
  ld    b,0
      
  call  .loop1   

  ;this last part is to fill the screen with a repetition
;	ld		hl,$4000
;  ld    c,$98
;  ld    a,22                ;second 84 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
;  call  .loop1   
  ret

.loop1:
  otir
  dec   a
  jp    nz,.loop1
  ret

copyScoreBoard:
  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a          

  ld    hl,.FillBottomPartScoreBoard
  call  docopy  

  ld    hl,$6C00            ;page 0 - screen 5 - bottom 40 pixels (scoreboard)
  ld    a,Graphicsblock5    ;block to copy from
  call  block12
  
	xor   a
	call	SetVdp_Write	
	ld		hl,scoreboard
  ld    c,$98
  ld    a,32/2              ;copy 32 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1    

.FillBottomPartScoreBoard:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,248,000   ;dx,--,dy,dpage
  db    000,001,008,000   ;nx,--,ny,--
  db    %1111 1111,000,$C0       ;fill 

CopyItemsKarniMata:
  .Page3:
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ;copy Huge Blob graphics to page 3
  ld    hl,$6C00+$8000            ;page 3 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
  ld    a,Graphicsblock4          ;block to copy from
  call  block12
  
	ld    a,1
	call	SetVdp_Write	
	ld		hl,itemsKarniMataPage3
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1    

  ;Copy level objects to page 1
  .Page1:
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ld    hl,$6C00+$8000            ;page 1 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
  ld    a,Graphicsblock5          ;block to copy from
  call  block12
  
	xor   a
	call	SetVdp_Write	
	ld		hl,itemsKarniMata
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1    

KarniMataPalette:
  incbin "..\grapx\tilesheets\sKarniMatapalette.PL" ;file palette 
VoodooWaspPalette:
  incbin "..\grapx\tilesheets\sVoodooWaspPalette.PL" ;file palette 
GoddessPalette:
  incbin "..\grapx\tilesheets\sGoddessPalette.PL" ;file palette 
BlueTemplePalette:
  incbin "..\grapx\tilesheets\sBlueTemplePalette.PL" ;file palette 
KonarkPalette:
  incbin "..\grapx\tilesheets\sKonarkPalette.PL" ;file palette 
KonarkBrighterPalette1:
  incbin "..\grapx\tilesheets\sKonarkBrighterPalette1.PL" ;file palette 
KonarkBrighterPalette2:
  incbin "..\grapx\tilesheets\sKonarkBrighterPalette2.PL" ;file palette 
KonarkBrighterPalette3:
  incbin "..\grapx\tilesheets\sKonarkBrighterPalette3.PL" ;file palette 
BurialPalette:
  incbin "..\grapx\tilesheets\sBurialPalette.PL" ;file palette 

currentpage:                ds  1
sprcoltableaddress:         ds  2
spratttableaddress:         ds  2
sprchatableaddress:         ds  2
invissprcoltableaddress:    ds  2
invisspratttableaddress:    ds  2
invissprchatableaddress:    ds  2



SetPalette:
	xor		a
	di
	out		($99),a
	ld		a,16+128
	out		($99),a
	ld		bc,$209A
	otir
	ei
	ret

;
;Set VDP port #98 to start writing at address AHL (17-bit)
;
SetVdp_Write: 
;first set register 14 (actually this only needs to be done once
	rlc     h
	rla
	rlc     h
	rla
	srl     h
	srl     h
	di
	out     ($99),a       ;set bits 15-17
	ld      a,14+128
	out     ($99),a
;/first set register 14 (actually this only needs to be done once

	ld      a,l           ;set bits 0-7
;	nop
	out     ($99),a
	ld      a,h           ;set bits 8-14
	or      64            ; + write access
	ei
	out     ($99),a       
	ret

SetVdp_WriteRemainDI: 
;first set register 14 (actually this only needs to be done once
	rlc     h
	rla
	rlc     h
	rla
	srl     h
	srl     h
	di
	out     ($99),a       ;set bits 15-17
	ld      a,14+128
	out     ($99),a
;/first set register 14 (actually this only needs to be done once

	ld      a,l           ;set bits 0-7
;	nop
	out     ($99),a
	ld      a,h           ;set bits 8-14
	or      64            ; + write access
	out     ($99),a       
	ret

Depack:     ;In: HL: source, DE: destination
	inc	hl		;skip original file length
	inc	hl		;which is stored in 4 bytes
	inc	hl
	inc	hl

	ld	a,128
	
	exx
	ld	de,1
	exx
	
.depack_loop:
	call .getbits
	jr	c,.output_compressed	;if set, we got lz77 compression
	ldi				;copy byte from compressed data to destination (literal byte)

	jr	.depack_loop
	
;handle compressed data
.output_compressed:
	ld	c,(hl)		;get lowest 7 bits of offset, plus offset extension bit
	inc	hl		;to next byte in compressed data

.output_match:
	ld	b,0
	bit	7,c
	jr	z,.output_match1	;no need to get extra bits if carry not set

	call .getbits
	call .rlbgetbits
	call .rlbgetbits
	call .rlbgetbits

	jr	c,.output_match1	;since extension mark already makes bit 7 set 
	res	7,c		;only clear it if the bit should be cleared
.output_match1:
	inc	bc
	
;return a gamma-encoded value
;length returned in HL
	exx			;to second register set!
	ld	h,d
	ld	l,e             ;initial length to 1
	ld	b,e		;bitcount to 1

;determine number of bits used to encode value
.get_gamma_value_size:
	exx
	call .getbits
	exx
	jr	nc,.get_gamma_value_size_end	;if bit not set, bitlength of remaining is known
	inc	b				;increase bitcount
	jr	.get_gamma_value_size		;repeat...

.get_gamma_value_bits:
	exx
	call .getbits
	exx
	
	adc	hl,hl				;insert new bit in HL
.get_gamma_value_size_end:
	djnz	.get_gamma_value_bits		;repeat if more bits to go

.get_gamma_value_end:
	inc	hl		;length was stored as length-2 so correct this
	exx			;back to normal register set
	
	ret	c
;HL' = length

	push	hl		;address compressed data on stack

	exx
	push	hl		;match length on stack
	exx

	ld	h,d
	ld	l,e		;destination address in HL...
	sbc	hl,bc		;calculate source address

	pop	bc		;match length from stack

	ldir			;transfer data

	pop	hl		;address compressed data back from stack

	jr	.depack_loop

.rlbgetbits:
	rl b
.getbits:
	add	a,a
	ret	nz
	ld	a,(hl)
	inc	hl
	rla
	ret    

;DoubleTapCounter:         db  1
;freezecontrols?:          db  0
;
; bit	7	  6	  5		    4		    3		    2		  1		  0
;		  0	  0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  F5	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
PopulateControls:	
;  ld    a,(freezecontrols?)
;  or    a
;  jp    nz,.freezecontrols

;	ld		a,(NewPrContr)
;	ld		(NewPrContrOld),a
	
	ld		a,15		; select joystick port 1
	di
	out		($a0),a
	ld		a,$8f
	out		($a1),a
	ld		a,14		; read joystick data
	out		($a0),a
	ei
	in		a,($a2)
	cpl
	and		$3f			; 00BARLDU
	ld		c,a

	ld		de,$04F0
	
	in		a,($aa)
	and		e
	or		6
	out		($aa),a
	in		a,($a9)
	cpl
	and		$20			; 'F1' key
	rlca				  ; 01000000
	or		c
	ld		c,a			; 01BARLDU
	
	in		a,($aa)	; M = B-trigger
	and		e
	or		d
	out		($aa),a
	in		a,($a9)
	cpl
	and		d			; xxxxxBxx
	ld		b,a
	in		a,($aa)
	and		e
	or		8
	out		($aa),a
	in		a,($a9)
	cpl					; RDULxxxA
	and		$F1		; RDUL000A
	rlca				; DUL000AR
	or		b			; DUL00BAR
	rla					; UL00BAR0
	rla					; L00BAR0D
	rla					; 00BAR0DU
	ld		b,a
	rla					; 0BAR0DUL
	rla					; BAR0DUL0
	rla					; AR0DUL00
	and		d			; 00000L00
	or		b			; 00BARLDU
	or		c			; 51BARLDU
	
	ld		b,a
	ld		hl,Controls
	ld		a,(hl)
	xor		b
	and		b
	ld		(NewPrContr),a
	ld		(hl),b

;  ld    a,(DoubleTapCounter)
;  dec   a
;  ret   z	
;  ld    (DoubleTapCounter),a
	ret

endenginepage3:
dephase
enginepage3length:	Equ	$-enginepage3

variables: org $c000+enginepage3length
slot:						
.ram:		                    equ	  $e000
.page1rom:	                equ	  slot.ram+1
.page2rom:	                equ	  slot.ram+2
.page12rom:	                equ	  slot.ram+3
memblocks:
.1:			                    equ	  slot.ram+4
.2:			                    equ	  slot.ram+5
.3:			                    equ	  slot.ram+6
.4:			                    equ	  slot.ram+7	
VDP_0:		                  equ   $F3DF
VDP_8:		                  equ   $FFE7
engaddr:	                  equ	  $03e
loader.address:             equ   $8000
enginepage3addr:            equ   $c000
sx:                         equ   0
sy:                         equ   2
spage:                      equ   3
dx:                         equ   4
dy:                         equ   6
dpage:                      equ   7 
nx:                         equ   8
ny:                         equ   10
copydirection:              equ   13
copytype:                   equ   14
restorebackground?:         equ   -1
framecounter:               rb    1

Controls:	                  rb		1
NewPrContr:	                rb		1
oldControls: 				        rb    1
amountoftimeSamecontrols: 	rb    1
NewPrContrOld:              rb    1

AmountTilesToPut:           rb    1
AmountTilesToSkip:          rb    1
DXtiles:                    rb    1

;These belong together
Player1SxB1:                  rb    1
Player1SyB1:                  rb    1
Player1NxB1:                  rb    1
Player1NyB1:                  rb    1
Player1SxB2:                  rb    1
Player1SyB2:                  rb    1
Player1NxB2:                  rb    1
Player1NyB2:                  rb    1
P1Attpoint1Sx:                rb    1
P1Attpoint1Sy:                rb    1
P1Attpoint2Sx:                rb    1
P1Attpoint2Sy:                rb    1
;These belong together

spatpointer:                  rb		2
scrollEngine:                 rb    1
PageOnNextVblank:             rb    1
R18onVblank:                  rb    1
R23onVblank:                  rb    1
R19onVblank:                  rb    1

DoubleJumpAvailable?:         rb    1
PlayerDead?:                  rb    1


amountofenemies:        equ 22
lenghtenemytable:       equ 27 + fill
enemies_and_objects:    rb  lenghtenemytable * amountofenemies
.alive?:                equ 0
.Sprite?:               equ 1
.movementpattern:       equ 2
.y:                     equ 4
.x:                     equ 5
.ny:                    equ 7
.nx:                    equ 8
.sprnrinspat:           equ 9
.SprNrTimes16:          equ 9
.ObjectNumber:          equ 9
.spataddress:           equ 11 | .coordinates:           equ 11
.nrsprites:             equ 13
.nrspritesSimple:       equ 14
.nrspritesTimes16:      equ 15
.v1:                    equ 16
.v2:                    equ 17
.v3:                    equ 18
.v4:                    equ 19
.v5:                    equ 20 | .SnapPlayer?:           equ 20
.v6:                    equ 21
.v7:                    equ 22
.v8:                    equ 23
.v9:                    equ 24
.hit?:                  equ 25 | .v10:                   equ 25
.life:                  equ 26 | .v11:                   equ 26

endenginepage3variables:  equ $+enginepage3length
org variables

