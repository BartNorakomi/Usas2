phase	$c000

MusicOn?:   equ 0
LogoOn?:    equ 0

MapDataCopiedToRam:  ds  WorldMapDataMapLenght

; 51 breed 51 hoog



;Tiledata,palette: 0=Voodoo Wasp, 2=Konark,   1=Goddess Area, 3=Karni Mata, 4=BlueTemple, 5=Burial, 6=Boss Area, 7=IceTemple



;WorldMapPointer:  dw  MapE04Data      ;Boss Zombie Caterpillar
;WorldMapPointer:  dw  MapD04Data      ;Boss Voodoo Wasp
;WorldMapPointer:  dw  MapA07Data      ;Retarded Zombies
;WorldMapPointer:  dw  MapA04Data      ;Area Sign
;WorldMapPointer:  dw  MapD12Data      ;pit
;WorldMapPointer:  dw  MapA05Data      ;
;WorldMapPointer:  dw  MapG05Data      ;NPC interaction
;WorldMapPointer:  dw  MapF06Data      ;
;WorldMapPointer:  dw  MapE09Data      ;lava
;WorldMapPointer:  dw  MapG13Data      ;Boss Goat (iceboss)
;WorldMapPointer:  dw  MapA12Data      ;omni directional platforms
;WorldMapPointer:  dw  MapB01_018Data      ;trampoline
;WorldMapPointer:  dw  MapB01_017Data      ;Huge Blob
;WorldMapPointer:  dw  MapG04Data      ;Huge Blob
;WorldMapPointer:  dw  MapE05Data      ;let's make this a Glass Ball Room

;WorldMapPointer:  dw  MapA01_001Data      ;Puzzle
;WorldMapPointer:  dw  MapA01_010Data      ;Puzzle
;WorldMapPointer:  dw  MapA01_011Data      ;Puzzle
;WorldMapPointer:  dw  MapA01_013Data      ;Puzzle
;WorldMapPointer:  dw  MapA01_015Data      ;Puzzle
;WorldMapPointer:  dw  MapA01_016Data      ;Puzzle where you push stone on retracting platforms
;WorldMapPointer:  dw  MapB01_019Data      ;Glass Ball Room

PlayLogo:
  call  StartTeamNXTLogo              ;sets logo routine in rom at $4000 page 1 and run it
loadGraphics:
;	ld    a,(Player_playing)
;	and   a
;  call  z,VGMRePlay

  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a
  ld    a,Loaderblock                 ;loader routine at $4000
  call  block12
  call  loader                        ;loader routines
  call  UnpackMapdata_SetObjects      ;unpacks packed map to $4000 in ram and sets objects.                                       ;ends with: all RAM except page 2
  call  ConvertToMapinRam             ;convert 16bit tiles into 0=background, 1=hard foreground, 2=ladder, 3=lava. Converts from map in $4000 to MapData in page 3
  call  BuildUpMap                    ;build up the map in Vram to page 1,2,3,4
;This can be removed after we optimised the BuildUpMap routine
;  halt | halt | halt | halt                  ;this is instead of a call waitvdpready. copy instructions need to finish before we put vramobjects in page1and3
  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a       
  call  CopyScoreBoard                ;set scoreboard from page 2 rom to Vram -> to page 0 - bottom 40 pixels (scoreboard) |loader|
  call  CopyVramObjectsPage1and3      ;copy VRAM objects to page 1 and 3 - screen 5 - bottom 40 pixels |loader|
  call  RemoveSpritesFromScreen       ;|loader|
  call  SwapSpatColAndCharTable
  call  PutSpatToVramSlow
  call  SwapSpatColAndCharTable
  call  PutSpatToVramSlow
  call  initiatebordermaskingsprites  ;|loader|

;  di                                  ;register 14 sets VRAM address to read/write to/from. This value is only set once per frame ingame, we assume it's set to $05 at all times, so set it back when going back to the game
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

  call  SetElementalWeaponInVramJumper

;  xor   a
;  ld    (Controls),a                  ;this allows for a double jump as soon as you enter a new map
;  ld    (NewPrContr),a                  ;this allows for a double jump as soon as you enter a new map

  ld    a,(CheckNewPressedControlUpForDoubleJump)
  cp    2
  jr    nz,.EndCheckDoubleJump        ;check if we need to double jump when entering a new room
	ld		a,(NewPrContr)
	set   0,a
	ld		(NewPrContr),a
  .EndCheckDoubleJump:

  jp    LevelEngine

SetElementalWeaponInVramJumper:                        ;check if F1 is pressed and the menu can be entered
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a

  ld    a,F1Menublock                 ;F1 Menu routine at $4000
  call  block12

  jp    SetElementalWeaponInVram
  
;  ret
  

StartTeamNXTLogo:
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a

  ld    a,teamNXTlogoblock            ;teamNXT logo routine at $4000
  call  block34
  jp    TeamNXTLogoRoutine

CopyLogoPart:                                       ;this is used in the normal engine to clean up any object that has been placed (platform, pushing stone etc)
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from left to right

SoundData: equ $8000
VGMRePlay:
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a
  ei
  
  ld    a,FormatOPL4_ID
  call  Player_Detect                 ;detect moonsound
  ld    bc,0                          ;track nr
  ld    a,usas2repBlock               ;ahl = sound data (after format ID, so +1)
  ld    hl,$8000+1
  call  Player_Play                   ;bc = track number, ahl = sound data (after format ID, so +1)
  jp    Player_Tick                   ;initialise, load samples
  
Main_Loop:
  halt
  call  Player_Tick
  jp    Main_Loop  

Player_Tick:
  ld    a,(slot.page12rom)             ;all RAM except page 1+2
  out   ($a8),a
  
	ld a,(Player_playing)
	and a
	ret z
	ld ix,(Player_stackPointer)
	dec (ix)
	ret nz
;	call Mapper_GetBank
	ld a,(ASCII16Mapper_currentBank)	
	push af
	call Player_Pop
;	call Mapper_SetBank
	ld (ASCII16Mapper_currentBank),a
	ld (7000H),a
	call Player_Process
	ld b,a
;	call Mapper_GetBank
	ld a,(ASCII16Mapper_currentBank)	
	call Player_Push
	ld (ix),b
	ld (Player_stackPointer),ix
	pop af
;	call Mapper_SetBank
	ld (ASCII16Mapper_currentBank),a
	ld (7000H),a
	ret

FormatOPL4_ID: equ 1

; a = format ID (first byte of sound data)
; f <- c: found
Player_Detect:
	call Player_Detect_Format
	jp c,Player_SetJumpTable
	jp Player_ClearJumpTable

; a = format ID (first byte of sound data)
; f <- c: found
Player_Detect_Format:
;	cp FormatOPN_ID
;	jp z,FormatOPN_Detect
	cp FormatOPL4_ID
	jp z,FormatOPL4_Detect
	and a
	ret

; f <- c: found
; hl = jump table
Player_SetJumpTable:
	ld de,Player_Process
	ld bc,3 * 3
	ldir
	ret

; f <- c: found
Player_ClearJumpTable:
	ld hl,Player_Process
	ld de,Player_Process + 1
	ld bc,3 * 3 - 1
	ld (hl),0C9H  ; ret
	ldir
	ret

; hl = sound data
Player_Jump:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
;	call Mapper_GetBank
	ld a,(ASCII16Mapper_currentBank)	
	add a,(hl)
	inc hl
	add hl,de
;	jp Mapper_SetBank
	ld (ASCII16Mapper_currentBank),a
	ld (7000H),a
  ret

; hl = sound data
; ix = stack pointer
Player_Return:
	call Player_Pop
;	jp Mapper_SetBank
	ld (ASCII16Mapper_currentBank),a
	ld (7000H),a	
  ret
	
; hl = sound data
; ix = stack pointer
Player_Call:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld b,(hl)
	inc hl
;	call Mapper_GetBank
	ld a,(ASCII16Mapper_currentBank)
	call Player_Push
	add hl,de
	add a,b
;	jp Mapper_SetBank
	ld (ASCII16Mapper_currentBank),a
	ld (7000H),a	
  ret

INCLUDE "MoonSoundZ80.asm"
INCLUDE "MoonSound.asm"
FormatOPL4_Detect:
	call  MoonSound_Detect
	ld    hl,MoonSoundZ80_JumpTable
;	ret   c
;	call  MoonSound_Detect
;	ld    hl,MoonSound_JumpTable
	ret

;IDBYT2: equ 2DH
;GETCPU: equ 183H

; f <- c: turbo R
;Utils_IsTurboR:
;	ld hl,IDBYT2
;	call Memory_ReadBIOS
;	add a,-3
;	ret

; f <- c: R800
;Utils_IsR800:
;	call Utils_IsTurboR
;	ret nc
;	push ix
;	ld ix,GETCPU
;	call Memory_CallBIOS
;	pop ix
;	add a,-1
;	ret



; bc = track number
; ahl = sound data (after format ID, so +1)
Player_Play:
	add hl,bc
	add hl,bc
	add hl,bc
	add hl,bc
	ld b,a
	xor a
	ld (Player_playing),a
	ld a,b
	ld ix,Player_stack
	call Player_Push
	ld a,1
	ld (ix),a
	ld (Player_stackPointer),ix
	ld (Player_playing),a
	ret

Player_Stop:
	xor a
	ld (Player_playing),a
	call Player_Mute
	ret

Player_Resume:
	call Player_Restore
	ld a,1
	ld (Player_playing),a
	ret

; hl = value
; ix = stack pointer
; ix <- stack pointer
Player_Push:
	ld (ix + 0),l
	ld (ix + 1),h
	ld (ix + 2),a
	inc ix
	inc ix
	inc ix
	ret

; ix = stack pointer
; hl <- value
; ix <- stack pointer
Player_Pop:
	dec ix
	dec ix
	dec ix
	ld l,(ix + 0)
	ld h,(ix + 1)
	ld a,(ix + 2)
	ret

ASCII16Mapper_currentBank:
	db usas2repBlock
Player_STACK_CAPACITY: equ 128
Player_playing:
	db 0
Player_stackPointer:
	dw Player_stack
Player_stack:
	ds Player_STACK_CAPACITY * 3 + 1
Player_Process:
	db 0C9H, 0, 0
Player_Mute:
	db 0C9H, 0, 0
Player_Restore:
	db 0C9H, 0, 0

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

WaitVblank:
  xor   a
  ld    hl,vblankintflag
.checkflag:
  cp    (hl)
  jr    z,.checkflag
  ld    (hl),a  
  ld    (lineintflag),a
  ret
































WorldMapPointer:  dw  MapBS20Data      ;NPC interaction
;WorldMapPointer:  dw  MapBR18Data      ;NPC interaction


MapDataInRam: ds  38*27*2
;UnpackedMapAddress: equ $4000
UnpackedMapAddress: equ MapDataInRam

BuildUpMap:
  call  screenon

  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a    

  ld    a,KarniMataTilesBlock         ;tilesheet gfx in page 1+2 rom
  call  block1234

  xor   a
  ld    hl,0                          ;start writing at (0,0) page 0
	call	SetVdp_Write	

  ;put 32*27 tiles to page 0, starting at (0,0) in the map in ram
  ld    hl,UnpackedMapAddress-0*38*2
  ld    (.SelfModifyingCodeStartingTile),hl
  ld    c,$98                         ;out port for outi's

  ld    b,27                          ;put 27 rows
  call  .Put8lines

  ld    hl,.Page0toPage1
  call  docopy

  ;now put 32*27 tiles to page 3, starting at (48,0) in the map in ram
  ld    a,1
  ld    hl,$8000                      ;start writing at (0,0) page 3
	call	SetVdp_Write	

  ;put 32*27 tiles to page 3, starting at (48,0) in the map in ram
  ld    hl,UnpackedMapAddress-0*38*2 + 12
  ld    (.SelfModifyingCodeStartingTile),hl
  ld    c,$98                         ;out port for outi's

  ld    b,13                          ;put 27 rows
  call  .Put8lines

  ;als je 13 rows opgebouwd hebt, dan is de Page0toPage1 copy klaar
  ld    hl,.Page0toPage2
  call  docopy
  ld    c,$98                         ;out port for outi's

  ld    b,14                          ;put 27 rows
  call  .Put8lines

  ld    hl,.Page3toPage1_StripOf16
  call  docopy
  ld    hl,.Page3toPage2_StripOf32
  call  docopy

  ld    a,Loaderblock                 ;loader routine at $4000
  call  block12
  ret

.Page0toPage1:
  db    016,000,000,000   ;sx,--,sy,spage
  db    000,000,000,001   ;dx,--,dy,dpage
  db    240,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.Page0toPage2:
  db    032,000,000,000   ;sx,--,sy,spage
  db    000,000,000,002   ;dx,--,dy,dpage
  db    224,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.Page3toPage1_StripOf16:
  db    208,000,000,003   ;sx,--,sy,spage
  db    240,000,000,001   ;dx,--,dy,dpage
  db    016,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.Page3toPage2_StripOf32:
  db    208,000,000,003   ;sx,--,sy,spage
  db    224,000,000,002   ;dx,--,dy,dpage
  db    032,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

  .Put8lines:
  ld    de,0 * 128                    ;1st line
  call  .PutLine
  ld    de,1 * 128                    ;2nd line
  call  .PutLine
  ld    de,2 * 128                    ;3d line
  call  .PutLine
  ld    de,3 * 128                    ;4th line
  call  .PutLine
  ld    de,4 * 128                    ;5th line
  call  .PutLine
  ld    de,5 * 128                    ;6th line
  call  .PutLine
  ld    de,6 * 128                    ;7th line
  call  .PutLine
  ld    de,7 * 128                    ;8th line
  call  .PutLine
  ld    hl,(.SelfModifyingCodeStartingTile)
  ld    de,38*2
  add   hl,de                         ;go to next row of tiles
  ld    (.SelfModifyingCodeStartingTile),hl
  djnz  .Put8lines
  ret

  .PutLine:
  exx  
  ;We will now put the 1st line of 32 tiles
  .SelfModifyingCodeStartingTile: equ $+1
  ld    de,UnpackedMapAddress+0*38*2         ;map in ram
  ld    b,032                         ;32 tiles per line
  .LineLoop:
  ;get tilenr in de
  ld    a,(de)                        ;each tile is already adjusted to the address where the tile starts in rom
  ld    l,a
  inc   de
  ld    a,(de)
  ld    h,a                           ;hl=starting address of tile in rom
  inc   de                            ;next tile in our room

  push  hl                            ;starting address of tile in tilesheet in rom
  exx
  pop   hl
  add   hl,de                         ;tileline of tile
  outi
  outi
  outi
  outi                                ;first line of this tile
  exx
  djnz  .LineLoop  
  exx
  ret





















;BuildUpMap:
  ld    hl,UnpackedMapAddress                      ;map in ram
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jp    z,buildupMap38x27
;  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
;  cp    2
;  jp    z,buildupMap32x27
;  ret
  jp    buildupMap32x27
  
UnpackMapdata_SetObjects:             ;unpacks packed map to $4000 in ram and sets objects. ends with: all RAM except page 2
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
  ld    a,(slot.page12rom)            ;all RAM except page 2
  out   ($a8),a      

  ld    a,(ix+0)                      ;Map block
  call  block34                       ;we can only switch block34 if page 1 is in rom

  ld    l,(ix+1)                      ;map data in rom
  ld    h,(ix+2)

;unpack map data
  ld    a,(slot.page2rom)             ;all RAM except page 2
  out   ($a8),a      
    
  ld    de,UnpackedMapAddress
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
  db    240,000,000,001   ;dx,--,dy,dpage
  db    016,000,226,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

.CopyRemainingParts2:
  db    208,000,000,003   ;sx,--,sy,spage
  db    224,000,000,002   ;dx,--,dy,dpage
  db    032,000,226,000   ;nx,--,ny,--
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
















; Tiles numbering
LadderTilesStart:	equ 1
LadderTilesEnd:	equ 8 	;tilenr: 1 t/m 8 = ladder
FreeTilesStart:	equ 9
FreeTilesEnd:	equ 31	;tilenr: 9 t/m 31 = free
SpikeTilesStart:	equ 32
SpikeTilesEnd:	equ 39	;tilenr: 32 t/m 39 = spikes/poison
LavaTilesStart:	equ 40
LavaTilesEnd:	equ 47	;tilenr: 40 t/m 47 = lava
StairLeftTilesStart:	equ 48
StairLeftTilesEnd:	equ 49	;tilenr: 48 t/m 49 = stairs left
StairRightTilesStart:	equ 50
StairRightTilesEnd:	equ 51	;tilenr: 50 t/m 51 = stairs right
ForegroundTilesStart: equ 52
ForegroundTilesEnd: equ 255	;tilenr: 52 t/m 255 = foreground
BackgroundTilesStart:	equ 256
BackgroundTilesEnd:	equ 1023;tilenr: 256 t/m 1023 = background
;convert into
BackgroundID:	equ 0	;tile 0 = background
HardForeGroundID:	equ 1	;tile 1 = hardforeground
LadderId:	equ 2	;tile 2 = laddertilesEnd
SpikeId:		equ 3	;tile 3 = spikes/poison
StairLeftId:	equ 4	;tile 4 = stairsleftup
StairRightId:	equ 5	;tile 5 = stairsrightup
LavaId:		equ 6	;tile 6 = lava

tileConversionTable: ;(id,tilenr) order desc
  DB  HardForeGroundID,ForegroundTilesStart,StairRightId,StairRightTilesStart
  DB  StairLeftId,StairLeftTilesStart,LavaId,LavaTilesStart
  DB  SpikeId,SpikeTilesStart,BackgroundID,FreeTilesStart
  DB  ladderID,LadderTilesStart,BackgroundID,0

ConvertToMapinRam2:
  ld  de,UnpackedMapAddress 
  ld  hl,MapData
  ld    a,MapHeight
.SelfModifyingCodeMapLenght:
  ld    b,000               ;maplenght: 32 or 38, depending on which engine is active
  push af
.loop:
  call  .convertTile
  exx
  ld (HL),c
  inc   hl
  djnz  .loop
  
  inc hl 
  inc hl                   ;2 empty tiles on the right side of the map
  
  pop AF
  dec a
  jp    nz,.SelfModifyingCodeMapLenght
  ret
  
;Convert MapTileNr to TileID
.convertTile:
        ld    a,(de)
        inc   de
        ex  af,af'
        ld  a,(de)
        inc de
        and a
        ld c,BackgroundId
        ret nz
        ex  af,af'
        dec a
        
        exx
        ld hl,tileConversionTable
.loop0: ld c,(hl)
        inc hl
        cp (hl)
        ret nc
        inc hl
        jp .loop0






















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
;tilenr: 1 t/m 8 = ladder
;tilenr: 9 t/m 31 = free
;tilenr: 32 t/m 39 = spikes/poison
;tilenr: 40 t/m 47 = lava
;tilenr: 48 t/m 49 = stairs left
;tilenr: 50 t/m 51 = stairs right
;tilenr: 52 t/m 255 = foreground
;tilenr: 256 t/m 1023 = background

;newer
;tilenr: $4000 + 001*4 t/m $4000 + 008*4 = ladder
;tilenr: $4000 + 009*4 t/m $4000 + 031*4 = free
;tilenr: $4400 + 000*4 t/m $4400 + 007*4 = spikes/poison
;tilenr: $4400 + 008*4 t/m $4400 + 009*4 = stairs left
;tilenr: $4400 + 010*4 t/m $4400 + 011*4 = stairs right
;tilenr: $4400 + 012*4 t/m $1c00 + 021*4 = foreground


;convert into
;tile 0 = background
;tile 1 = hardforeground
;tile 2 = laddertiles
;tile 3 = spikes/poison
;tile 4 = stairsleftup
;tile 5 = stairsrightup
;tile 6 = lava

  ld    hl,UnpackedMapAddress
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
  
;duplicate the last row 4 times
;  ld    hl,40*26 + MapData 
;  ld    de,40*27 + MapData 
;  ld    bc,40
;  ldir  

;  ld    hl,40*26 + MapData 
;  ld    de,40*28 + MapData 
;  ld    bc,40
;  ldir  

;  ld    hl,40*26 + MapData 
;  ld    de,40*29 + MapData 
;  ld    bc,40
;  ldir  

;  ld    hl,40*26 + MapData 
;  ld    de,40*30 + MapData 
;  ld    bc,40
;  ldir  
;  ret

.convertTile:
  ;get tilenr in de
  ld    e,(hl)              ;each tile is 16 bit. bit 0-4 (value between 0-31) give us the x value if we multiply by 8
  inc   hl
  ld    d,(hl)
  
;**************** HACK **************** 
;  ld    a,d
;  and   %0000 0011          ;remove bit 15,14,13,12,11,10
;  ld    d,a
;**************** HACK **************** 

;############## TODO ################

;newer
;tilenr: 1 t/m 8 = ladder
;tilenr: 9 t/m 31 = free
;tilenr: 32 t/m 39 = spikes/poison
;tilenr: 40 t/m 47 = lava
;tilenr: 48 t/m 49 = stairs left
;tilenr: 50 t/m 51 = stairs right
;tilenr: 52 t/m 255 = foreground
;tilenr: 256 t/m 1023 = background
;newer
;tilenr: $4000 + 001*4 t/m $4000 + 008*4 = ladder
;tilenr: $4000 + 009*4 t/m $4000 + 031*4 = free
;tilenr: $4400 + 000*4 t/m $4400 + 007*4 = spikes/poison
;tilenr: $4400 + 008*4 t/m $4400 + 015*4 = lava
;tilenr: $4400 + 016*4 t/m $4400 + 017*4 = stairs left
;tilenr: $4400 + 018*4 t/m $4400 + 019*4 = stairs right
;tilenr: $4400 + 020*4 t/m $5c00 + 021*4 = foreground


;LadderTiles:	      equ 8
;FreeTiles:          equ 31
;SpikesPoisonTiles:	equ 39
;LavaTiles:	        equ 47
;StairLeftTiles:	    equ 49
;StairRightTiles:	  equ 51
;ForegroundTiles:    equ 255

LadderTiles:	      equ $4000 + 008*4
FreeTiles:          equ $4000 + 031*4
SpikesPoisonTiles:	equ $4400 + 007*4
LavaTiles:	        equ $4400 + 015*4
StairLeftTiles:	    equ $4400 + 017*4
StairRightTiles:	  equ $4400 + 019*4
ForegroundTiles:    equ $5c00 + 021*4

  
  inc   hl                  ;next tile in tilemap
  
  ;set sx and sy of this tile
  dec   de
  
  ld    hl,LadderTiles               ;ladder
  xor   a
  sbc   hl,de
  jp    nc,.laddertiles

  ld    hl,SpikesPoisonTiles               ;spikes & poison
  xor   a
  sbc   hl,de
  jp    nc,.spikespoison
  
  ld    hl,LavaTiles               ;lava
  xor   a
  sbc   hl,de
  jp    nc,.lava

  ld    hl,StairLeftTiles               ;stairs left up
  xor   a
  sbc   hl,de
  jp    nc,.stairsleftup

  ld    hl,StairRightTiles               ;stairs right up
  xor   a
  sbc   hl,de
  jp    nc,.stairsrightup

  ld    hl,ForegroundTiles
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



copyGraphicsToScreen:
  ld    a,d                 ;Graphicsblock
  call  block12
  
	ld		a,b
	call	SetVdp_Write	
	ld		hl,$4000
  ld    c,$98
  ld    a,64                ;first 128 line, copy 64*256 = $4000 bytes to Vram
 ; ld    b,0
      
  call  .loop1    

  ld    a,d                 ;Graphicsblock
;  add   a,2
  inc   a
  call  block12
  
	ld		hl,$4000
  ld    c,$98
  ld    a,64 ; 42                ;second 84 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
  call  .loop1   

  ;this last part is to fill the screen with a repetition
;	ld		hl,$4000
;  ld    c,$98
;  ld    a,22                ;second 84 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
;  call  .loop1   
  ret

.loop1:
  call  outix256
  dec   a
  jp    nz,.loop1
  ret

RestoreBackgroundScoreboard1Line:                    ;this is used to clean up the scoreboard which is backed up to (0,0) page 1
  db    000,000,000,003   ;sx,--,sy,spage
  db    000,000,000,001   ;dx,--,dy,dpage
  db    000,001,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from left to right

RestoreScoreboard1Line:                             ;this is used to backup the scoreboard from (0,216) - (255,255) page 0 to (0,0) page 1
  db    000,000,000,001   ;sx,--,sy,spage
  db    000,000,216,000   ;dx,--,dy,dpage
  db    000,001,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from left to right

BackupScoreboard1Line:                             ;this is used to backup the scoreboard from (0,216) - (255,255) page 0 to (0,0) page 1
  db    000,000,216,000   ;sx,--,sy,spage
  db    000,000,000,001   ;dx,--,dy,dpage
  db    000,001,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from left to right

RemoveScoreBoard1Line:
  db    000,000,000,000   ;sx,--,sy,spage
  db    002,000,219,000   ;dx,--,dy,dpage
  db    252,000,001,000   ;nx,--,ny,--
  db    %1011 1011,000,$C0       ;fill 

;FillBottomPartScoreBoard:
;  db    000,000,000,000   ;sx,--,sy,spage
;  db    000,000,248,000   ;dx,--,dy,dpage
;  db    000,001,008,000   ;nx,--,ny,--
;  db    %1111 1111,000,$C0       ;fill 





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
;Set VDP port #98 to start reading at address AHL (17-bit)
;
SetVdp_Read:  rlc     h
              rla
              rlc     h
              rla
              srl     h
              srl     h
              di
              out     ($99),a         ;set bits 15-17
              ld      a,14+128
              out     ($99),a
              ld      a,l             ;set bits 0-7
;              nop
              out     ($99),a
              ld      a,h             ;set bits 8-14
              ei                      ; + read access
              out     ($99),a
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
freezecontrols?:          db  0
;
; bit	7	  6	  5		    4		    3		    2		  1		  0
;		  0	  0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  F5	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
PopulateControls:	
  ld    a,(freezecontrols?)
  or    a
  jp    nz,.freezecontrols

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

.freezecontrols:
  xor   a
	ld		(Controls),a
	ld		(NewPrContr),a
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
Bossframecounter:           rb    1

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

LogoAnimationPhase:           rb    1
LogoAnimationTimer1:          rb    1
LogoAnimationTimer2:          rb    1
LogoAnimationTimer3:          rb    1
LogoAnimationVar1:            rb    1
LogoAnimationVar2:            rb    1
LogoAnimationVar3:            rb    1




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
.spataddress:           equ 11
.nrsprites:             equ 13
.nrspritesSimple:       equ 14 | .coordinates:           equ 14
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
.movementpatternsblock: equ 27

endenginepage3variables:  equ $+enginepage3length
org variables

