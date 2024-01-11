loader:
	call screenoff
	call ReSetVariables
	call SwapSpatColAndCharTable2
	call SwapSpatColAndCharTable
	call SwapSpatColAndCharTable2

	ld de,(WorldMapPositionY) 			;WorldMapPositionX/Y:  
	call getRoom
	call SetEngineType

	;call  SetTilesInVram				;copies all the tiles to Vram
	call PopulateControls			;this allows for a double jump as soon as you enter a new map
	ld	a,RuinId.KarniMata		 		;ruinId (temp)
	call getPalette
	call SetMapPalette				
  ret


ObjectExample: 
db 5,76,30,64,64,0
db 5,76,40,64,64,0
db 5,76,60,64,64
db 5,76,80,64,64
db 5,76,100,64,64
db 5,76,120,64,64
db 5,76,140,64,64
db 0 ;3 retracting platforms

;AppBlocksHandler
;5=id platform
;76,80=xy
;64,64=open/close framespeed
;en dat keer 3
;12:44
;0=eod


;db 1,0,0,$28,$a0,$44,16,3,3,1 ;platform
;db 1,0,0,$28,$b0,$44,16,3,3,1
;db $8f,64/2,$40,03,02 ;retard zombie
;db $8f,$54,$50,03,02
;db $8f,$64,$60,03,02
;db $8f,$74,$70,03,02
;db $96,32/2,$80,03,01 ;slime
;db $96,$24,$30,03,01
db 0

SetObjects:                             ;after unpacking the map to ram, all the object data is found at the end of the mapdata. Convert this into the object/enemytables
;set test objects
  ld  hl,ObjectExample  
  ld  de,UnpackedRoomFile.object
  ld  bc,200
;  ldir

;halt

  call	clearEnemyTable
  ld    hl,CleanOb1                     ;refers to the cleanup table for 1st object. we can place 3 objects max. CleanOb1, CleanOb2 and CleanOb3 are their tables
  ld    b,12                            ;first hardware object sprite nr (sprite 0-11 are border masking sprites, after this start the hardware sprite objects)
  exx                                   ;keep CleanOb1 address untouched
  
  ld    ix,UnpackedRoomFile.object      ;room object data list
  ld    iy,enemies_and_objects          ;start object table in iy

  .loop:
  ld    a,(ix)
  or    a
  ret   z                               ;0=end room object list
  call  .SetObject
  add   ix,de                           ;add the lenght of current object data to ix, and set next object in ix
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table
  jp    .loop                           ;go handle next object
  
  .SetObject:
  cp    1
  jp    z,.Object001                    ;platform
  cp    5
  jp    z,.Object005                    ;retracting platforms
  cp    143
  jp    z,.Object143                    ;retarded zombie
  cp    150
  jp    z,.Object150                    ;trampoline blob
  ret

  .Object005:                           ;retracting platform  
  ld    hl,Object005Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*2
  ldir    

  ;retracting platform has 3 different situations:
  ;1=only 1 retracting platform in total: animation will be platform1 on, platform1 off
  ;2=only 2 retracting platforms in total: animation will be platform1 on, platform2 on, platform1 off, platform2 off
  ;3=3 or more retracting platforms in total: animation will be platform1 on, platform3 off, platform2 on, platform1 off, platform3 on, platform2 off (this concept can then be used for more than 3)
  
  ;first let's find total amount of retracting platforms
  ld    b,1                             ;amount of retracting platforms
  ld    de,Object005Table.lenghtobjectdata
  push  ix
  call  .FindTotalAmountOfRetractingPlatforms
  pop   ix

  ld    a,b
  ld    (AmountOfAppearingBlocks),a
  dec   a                               ;only 1 platform ?
;  jp    z,.MoreThan2RetractingPlatforms ;only 1 platform uses the same placement routin as more than 2
  jp    z,.Only1RetractingPlatform ;only 1 platform uses the same placement routin as more than 2
  dec   a                               ;only 2 platforms ?
  jp    z,.Only2RetractingPlatforms

  .MoreThan2RetractingPlatforms:  
  push  iy
  ld    iy,AppearingBlocksTable
  push  iy
  .PlatformLoop:
  ld    a,(ix+Object005Table.y)
  ld    l,a
  ld    (iy+0),a                        ;y block 1 (block turns on)
  ld    (iy+9),a                        ;y block 1 (block turns off)
  ld    a,(ix+Object005Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    h,a
  ld    (iy+1),a                        ;x block 1 (block turns on)
  ld    (iy+2),1                        ;block 1 on
  ld    (iy+10),a                       ;x block 1 (block turns off)
  ld    (iy+11),0                       ;block 1 off

  ld    de,Object005Table.lenghtobjectdata
  add   ix,de                           ;next object
  ld    de,6
  add   iy,de                           ;next block that turns on in list

  djnz  .PlatformLoop
  ld    (iy+0),255                      ;end list

  pop   iy  
  ld    (iy+3),l                        ;y last block (block turns on)
  ld    (iy+4),h                        ;x last block (block turns on)
  ld    (iy+5),0                        ;off
  pop   iy
  
  ld    de,Object005Table.lenghtobjectdata
  ret  

  .Only2RetractingPlatforms:  
  ld    a,1
  ld    (AppearingBlocksTable+2),a
  ld    (AppearingBlocksTable+5),a
  xor   a
  ld    (AppearingBlocksTable+8),a
  ld    (AppearingBlocksTable+11),a
  ld    a,255
  ld    (AppearingBlocksTable+12),a

  ld    a,(ix+Object005Table.y)
  ld    (AppearingBlocksTable+0),a
  ld    (AppearingBlocksTable+6),a
  ld    a,(ix+Object005Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+1),a
  ld    (AppearingBlocksTable+7),a

  ld    de,Object005Table.lenghtobjectdata
  add   ix,de                           ;next retracting platform

  ld    a,(ix+Object005Table.y)
  ld    (AppearingBlocksTable+3),a
  ld    (AppearingBlocksTable+9),a
  ld    a,(ix+Object005Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+4),a
  ld    (AppearingBlocksTable+10),a

  ld    de,Object005Table.lenghtobjectdata
  ret

  .Only1RetractingPlatform:
  ld    a,1
  ld    (AppearingBlocksTable+2),a
  xor   a
  ld    (AppearingBlocksTable+5),a
  ld    a,255
  ld    (AppearingBlocksTable+6),a

  ld    a,(ix+Object005Table.y)
  ld    (AppearingBlocksTable+0),a
  ld    (AppearingBlocksTable+3),a
  ld    a,(ix+Object005Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+1),a
  ld    (AppearingBlocksTable+4),a

  ld    de,Object005Table.lenghtobjectdata
  ret

  .FindTotalAmountOfRetractingPlatforms:
  add   ix,de                           ;next object
  ld    a,(ix)
  cp    5
  ret   nz
  inc   b
  jr    .FindTotalAmountOfRetractingPlatforms

  .Object001:                           ;moving platform
;v1-2=box right (16 bit)
;v1-1=box right (16 bit)
;v1=sx software sprite in Vram
;v2=active?
;v3=y movement
;v4=x movement
;v5=SnapPlayer?
;v6=box left (16 bit)
;v7=box left (16 bit)
;v8=box top
;v9=box bottom
;v10=speed
  ld    hl,Object001Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  exx
  ld    (iy+enemies_and_objects.ObjectNumber),l
  ld    (iy+enemies_and_objects.ObjectNumber+1),h
  ld    de,CleanObjectTableLenght
  add   hl,de                           ;set next clean object table for potential next object
  exx

  ;set x (relative to box)
  ld    a,(ix+Object001Table.xbox)
  add   a,(ix+Object001Table.relativex)
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y (relative to box)
  ld    a,(ix+Object001Table.ybox)
  add   a,(ix+Object001Table.relativey)
  ld    (iy+enemies_and_objects.y),a
  
  ;set box x left
  ld    l,(ix+Object001Table.xbox)
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.v6),l   ;v6 and v7=box left (16bit)
  ld    (iy+enemies_and_objects.v7),h   ;v6 and v7=box left (16bit)

  ;set box x right
  ld    a,(ix+Object001Table.xbox)
  add   a,(ix+Object001Table.widthbox)
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  call  .CheckIfObjectMovementIsWithinAllowedRange
  ld    (iy+enemies_and_objects.v1-2),l ;v1-2 and v1-1=box right (16bit)
  ld    (iy+enemies_and_objects.v1-1),h ;v1-2 and v1-1=box right (16bit)

  ;set box y top
  ld    a,(ix+Object001Table.ybox)
  ld    (iy+enemies_and_objects.v8),a   ;v8=box top

  ;set box y bottom
  add   a,(ix+Object001Table.heightbox)
  ld    (iy+enemies_and_objects.v9),a   ;v9=box bottom

  ;set facing direction
  ld    a,(ix+Object001Table.face)
  add   a,a
  ld    d,0
  ld    e,a
  ld    hl,Movementtable-2
  add   hl,de
  ld    a,(hl)                          ;y
  ld    (iy+enemies_and_objects.v3),a   ;v3=y movement
  inc   hl
  ld    a,(hl)                          ;x
  ld    (iy+enemies_and_objects.v4),a   ;v4=x movement
  
  ;set speed
  ld    a,(ix+Object001Table.speed)
  ld    (iy+enemies_and_objects.v10),a  ;v10=speed

  ;set active
  ld    a,(ix+Object001Table.active)
  ld    (iy+enemies_and_objects.v2),a   ;v2=active?

  ld    de,Object001Table.lenghtobjectdata
  ret

  .CheckIfObjectMovementIsWithinAllowedRange:
  ld    de,253                          ;box right edge
  xor   a                               ;clear carry flag
  sbc   hl,de
  jr    c,.WithinRange
  ld    hl,253                          ;16 pixels wide
  ret
  .WithinRange:
  add   hl,de
  ret

  .Object150:                           ;trampoline blob
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v4=Horizontal Movement
;v5=Unable to be hit duration
  ld    hl,Object150Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT

  ;set x
  ld    a,(ix+Object150Table.x)
  add   a,8                             ;all hardware sprites need to be put 16 pixel to the right
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object150Table.y)
  ld    (iy+enemies_and_objects.y),a

  ;set facing direction
  ld    a,(ix+Object150Table.face)
  cp    3
  jr    z,.EndCheckMovingRight          ;the standard movement direction of any object is right, if this is the facing direction, then we don't need to change movement direction
  ld    (iy+enemies_and_objects.v4),-1  ;v4=Horizontal Movement
  .EndCheckMovingRight:

  ld    de,Object150Table.lenghtobjectdata
  ret

  .Object143:                           ;retarded zombie
;v1=Animation Counter
;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait Timer
  ld    hl,Object143Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT

  ;set x
  ld    a,(ix+Object143Table.x)
  add   a,8                             ;all hardware sprites need to be put 16 pixel to the right
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object143Table.y)
  ld    (iy+enemies_and_objects.y),a

  ;set facing direction
  ld    a,(ix+Object143Table.face)
  cp    3
  jr    z,.EndCheckMovingRight2          ;the standard movement direction of any object is right, if this is the facing direction, then we don't need to change movement direction
  ld    (iy+enemies_and_objects.v4),-1  ;v4=Horizontal Movement
  .EndCheckMovingRight2:

  ld    de,Object143Table.lenghtobjectdata
  ret

SetSPATPositionForThisSprite:           ;we need to define the position this sprite takes in the SPAT
  exx
  push  hl
  ld    l,b                             ;hardware object sprite nr (sprite 0-11 are border masking sprites, after this start the hardware sprite objects)
  ld    h,0
  add   hl,hl                           ;*2
  push  hl
  ld    de,spat
  add   hl,de
  ld    (iy+enemies_and_objects.spataddress),l
  ld    (iy+enemies_and_objects.spataddress+1),h
  pop   hl
  add   hl,hl                           ;*4
  add   hl,hl                           ;*8
  add   hl,hl                           ;*16  
  ld    (iy+enemies_and_objects.SprNrTimes16),l
  ld    (iy+enemies_and_objects.SprNrTimes16+1),h
  pop   hl
  ld    a,(iy+enemies_and_objects.nrspritesSimple)
  add   a,b
  ld    b,a                             ;set next sprite position in b by adding the amount of sprites current object uses
  exx
  ret

                ;y,x  1=up,   2=upright,  3=right,  4=rightdown,  5=down, 6=downleft, 7=left, 8=leftup)
Movementtable:    db  -1,+0,  -1,+1,      +0,+1,    +1,+1,        +1,+0,  +1,-1,      +0,-1,  -1,-1  

Object001Table:               ;platform
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
          db 1,        0|dw Platform            |db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.ID: equ 0
.relativex: equ 1
.relativey: equ 2
.xbox: equ 3
.ybox: equ 4
.widthbox: equ 5
.heightbox: equ 6
.face: equ 7
.speed: equ 8
.active: equ 9
.lenghtobjectdata: equ 10

Object005Table:               ;retracting platform (handler)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
          db 1,        0|dw AppBlocksHandler    |db 0*00|dw 0*00|db 00,00|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
                              ;AppearingBlocks
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
          db 0,        0|dw AppearingBlocks     |db 8*21|dw 8*19|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.openspeed: equ 3
.closespeed: equ 4
.lenghtobjectdata: equ 5

Object143Table:               ;retarded zombie
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
;         db -0,        1|dw RetardedZombie      |db 0000|dw 0000|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
         db -1,        1|dw RetardedZombie      |db 0000|dw 0000|db 32,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object150Table:               ;trampoline blob: v9=special width for Pushing Stone Puzzle Switch
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw TrampolineBlob      |db 0000|dw 0000|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+08,+36, 0|db 255,movepatblo1| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

;Get room type [A] table record address [HL]
getRoomType:
		push bc
		ld l,A
		ld h,0
		add hl,hl
		add hl,hl
		ld bc,roomTypes.data
		add hl,bc
		pop bc
ret

;Get room [DE] location, block[A] address[HL]
getRoom:
		call GetWorldMapRoomLocation
		add a,Dsm.firstBlock+dsm.indexBlock	;offset (temp)
		ld bc,$8000							;destination
		add hl,bc
		ld ix,MapDataCopiedToRam
		ld (ix),a ;block
		ld (ix+1),l ;adr
		ld (ix+2),h
		ld (ix+3),1 ;engine
		ld (ix+4),0 ;tileSet
		ld (ix+5),0 ;pal
ret


;Get WorldMapRoom
;In:	DE=IndexID (D=X,E=Y)
;out:	HL=Address(relative, 0-3fff), A=block(relative)
GetWorldMapRoomLocation:
		ld    a,Dsm.firstBlock+dsm.indexBlock
		call  block34
        LD    HL,roomindex.data
        LD    BC,roomindex.reclen-1
GWMR.1: LD    A,D             ;x
        CP    (HL)
        INC   HL
        JR    NZ,GWMR.0
        LD    A,E             ;y
        CP    (HL)
        JR    NZ,GWMR.0
        INC   HL
        LD    A,(HL)          ;block
        INC   HL
        LD    H,(HL)          ;seg
        LD    L,0
        SRL   H     	    ;seglen=128, so shift 1 right
        RR    L
        RET
GWMR.0: ADD   HL,BC
        JP    GWMR.1


;store and set palette for this room
SetMapPalette:
		push  hl
		ld    de,CurrentPalette
		ld    bc,32
		ldir
		pop   hl
		call setpalette
ret

;Get palette location
;in:	A=palId
;out:	HL=adr
getPalette:
		push bc
		LD	h,0
		ld	l,A
		add	hl,hl	;x2
		add	hl,hl	;4
		add hl,hl	;8
		add	hl,hl	;16
		add hl,hl	;32
		ld	bc,palettes.data
		add	hl,bc
		pop bc
ret

palettes:
.reclen:		equ 32
.numrec:		equ 32
.data:
.0:				DS .reclen		;incBin filename,0,.reclen
.1:				DS .reclen
.2:				DS .reclen
.3:				DS .reclen
.4:				DS .reclen
.5:				DS .reclen
.6KarniMata:	DB 71,5,18,1,32,5,52,3,32,1,0,3,80,3,115,6,0,2,119,7,64,6,35,2,69,4,112,5,112,2,0,0
.7:				DS .reclen




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

RemoveSpritesFromScreen:
  ld    hl,spat
  ld    de,2
  ld    b,32
  .loop:
  ld    (hl),217
  add   hl,de
  djnz  .loop
  ret

CopyVramObjectsPage1and3:
  ;Copy level objects to page 1
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ld    a,Graphicsblock5          ;block to copy from
  call  block34
  
	xor   a
  ld    hl,$6C00+$8000            ;page 1 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
	call	SetVdp_Write	
	ld		hl,itemsKarniMata
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1     

  ;copy Huge Blob graphics and primary and secundary weapons to page 3
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ld    a,Graphicsblock4          ;block to copy from
  call  block34

	ld    a,1
  ld    hl,$6C00+$8000            ;page 3 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
	call	SetVdp_Write	

	ld		hl,itemsKarniMataPage3
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1   
  
copyScoreBoard:                       ;set scoreboard from page 2 rom to Vram
  ld    a,(ScoreBoardAlreadyInScreen?)
  or    a
  ret   nz
  ld    a,1
  ld    (ScoreBoardAlreadyInScreen?),a

  ld    hl,$6C00+128                      ;page 0 - screen 5 - bottom 40 pixels (scoreboard)
  ld    a,Graphicsblock5              ;block to copy from
  call  block34
  
	xor   a
	call	SetVdp_Write	
	ld		hl,scoreboard
  ld    c,$98
  ld    a,38/2                        ;copy 38 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1
  jp    outix128



;SetTilesInVram:  
;set tiles in Vram
;  ld    a,(ix+4)                      ;tile data
;  or    a
;  ld    d,VoodooWaspTilesBlock        ;0
;  jr    z,.settiles
;  dec   a
;  ld    d,GoddessTilesBlock           ;1
;  jr    z,.settiles
;  dec   a
;  ld    d,KonarkTilesBlock            ;2
;  jr    z,.settiles
;  dec   a
;  ld    d,KarniMataTilesBlock         ;3
;  jr    z,.settiles
;  dec   a
;  ld    d,BlueTempleTilesBlock        ;4
;  jr    z,.settiles
;  dec   a
;  ld    d,BurialTilesBlock            ;5
;  jr    z,.settiles
;  dec   a
;  ld    d,BossAreaTilesBlock          ;6
;  jr    z,.settiles
;  dec   a
;  ld    d,IceTempleTilesBlock         ;7
;  jr    z,.settiles

;  .settiles:
;  ld    a,(slot.page12rom)            ;all RAM except page 12
;  out   ($a8),a          

;  ld    hl,$8000                      ;page 1 - screen 5
;  ld    b,0
;  call  copyGraphicsToScreen2
;  ret

;copyGraphicsToScreen2:
;  ld    a,d                           ;Graphicsblock
;  call  block34
  
;	ld		a,b
;	call	SetVdp_Write	
;	ld		hl,$8000
;  ld    c,$98
;  ld    a,64                          ;first 128 line, copy 64*256 = $4000 bytes to Vram
      
;  call  .loop1    

;  ld    a,d                           ;Graphicsblock
;  inc   a
;  call  block34
  
;	ld		hl,$8000
;  ld    c,$98
;  ld    a,64 ; 42                     ;second 84 line, copy 64*256 = $4000 bytes to Vram
      
;  call  .loop1   
;  ret

;.loop1:
;  call  outix256
;  dec   a
;  jp    nz,.loop1
;  ret

;BorderMaskingSpritesCall:
;  call  SetBorderMaskingSprites       ;set border masking sprites position in Spat
;NoBorderMaskingSpritesCall:
;  nop | nop | nop                     ;skip border masking sprites
SetEngineType:                        ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
;Set Engine type
;  ld    hl,BorderMaskingSpritesCall
;  ld    de,LevelEngine.SelfModifyingCallBMS
;  ld    bc,3
;  ldir

  ld    a,1
  ld    (SpriteSplitFlag),a           ;sprite split active

  ld    a,(ix+3)                      ;engine type
  ld    (scrollEngine),a              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a                             ;1= 304x216 engine  2=256x216 SF2 engine
  jp    z,.Engine304x216

  .Engine256x216:                     ;SF2 engine
  dec   a                             ;'normal' SF2 engine ?
  jr    nz,.Engine256x216WithSpriteSplit

;  ld    hl,NoBorderMaskingSpritesCall
;  ld    de,LevelEngine.SelfModifyingCallBMS
;  ld    bc,3
;  ldir
  
  xor   a
  ld    (SpriteSplitFlag),a           ;SF2 engine with spritesplit inactive

  .Engine256x216WithSpriteSplit:
  ld    de,CheckTile256x216MapLenght
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,ExitRight256x216
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
  ld    a,MapLenght256x216
  ld    (ConvertToMapinRam.SelfModifyingCodeMapLenght+1),a
  ld    de,MapData- 68
  ld    (checktile.selfmodifyingcodeStartingPosMapForCheckTile+1),de
 
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
  ret
  
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

  xor   a                              ;restore variables to put SF2 objects in play
  ld    (PutObjectInPage3?),a
  ld    a,1
  ld    (RestoreBackgroundSF2Object?),a

  ld    a,-1
  ld    (HugeObjectFrame),a           ;Reset this value by setting it to -1
  xor   a
  ld    (ShakeScreen?),a
  ld    (PlayerDead?),a
  ld    (SecundaryWeaponActive?),a              ;remove arrow weapon  

  ld    hl,lineint
  ld    (InterruptHandler.SelfmodyfyingLineIntRoutine),hl

  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  ret   z                              ;wait for previous primary attack to end
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a   
  ld    hl,0
  ld    (PlayerAnicount),hl     
  ret  

.NormalRunningTable:
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
;  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
;  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
;  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1
  
  ruinProperties:
.reclen:		equ 16		;[attribute]The length of one record
.numrec:		equ 32		;[attribute]Number of records
.tileset:		equ +0		;[property]Default Tileset ID
.palette:		equ +1		;[property]Default palette ID
.music:			equ +2		;[property]Default music ID
.Name:			equ +3		;[property]Name of the ruin as string
.data:						;RM:table generated externally
	DB	0,0,0,"             "
	DB	0,0,0,"Hub          "
	DB	0,0,0,"Lemniscate   "
	DB	0,0,0,"Bos Stenen Wa"
	DB	0,0,0,"Pegu         "
	DB	0,0,0,"Bio          "
	DB	6,6,3,"Karni Mata   "
	DB	0,0,0,"Konark       "
	DB	0,0,0,"Verhakselaar "
	DB	0,0,0,"Taxilla      "
	DB	0,0,0,"Euderus Set  "
	DB	0,0,0,"Akna         "
	DB	0,0,0,"Fate         "
	DB	0,0,0,"Sepa         "
	DB	0,0,0,"undefined    "
	DB	0,0,0,"Chi          "
	DB	0,0,0,"Sui          "
	DB	0,0,0,"Grot         "
	DB	0,0,0,"Tiwanaku     "
	DB	0,0,0,"Aggayu       "
	DB	0,0,0,"Ka           "
	DB	0,0,0,"Genbu        "
	DB	0,0,0,"Fuu          "
	DB	0,0,0,"Indra        "
	DB	0,0,0,"Morana       "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "