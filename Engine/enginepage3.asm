phase	enginepage3addr


;bt21=21,43;bt28=28,45;bt16=16,45;br16=16,43
;WorldMapPositionY:  db  17 | WorldMapPositionX:  db  44 ;ballroom 1 (with pipe)
;WorldMapPositionY:  db  20 | WorldMapPositionX:  db  44 ;ballroom 2
;WorldMapPositionY:  db  19 | WorldMapPositionX:  db  43 ;huge blob room

;boss demon
;roomX: equ ("B"-"A")*26 + "G"-"A"
;WorldMapPositionY:  db  12-1 | WorldMapPositionX:  db  roomX

;waterfall scene
;roomX: equ ("B"-"A")*26 + "T"-"A"
;WorldMapPositionY:  db  12-1 | WorldMapPositionX:  db  roomX

;boss plant
;roomX: equ ("B"-"A")*26 + "E"-"A"
;WorldMapPositionY:  db  21-1 | WorldMapPositionX:  db  roomX

;lemniscate wall bash
;roomX: equ ("A"-"A")*26 + "V"-"A"
;roomY: equ 27
;WorldMapPositionY:  db  roomY-1 | WorldMapPositionX:  db  roomX

roomX: equ ("B"-"A")*26 + "R"-"A"
roomY: equ 16
WorldMapPositionY:  db  roomY-1 | WorldMapPositionX:  db  roomX
ClesX:      dw 64 ;$19 ;230 ;250 ;210
ClesY:      db 152 ;144-1

PlayLogo:
  call  StartTeamNXTLogo              ;sets logo routine in rom at $4000 page 1 and run it

loadGraphics:
;	ld    a,(RePlayer_playing)
;	and   a
;  call  z,VGMRePlay

	ld    a,(slot.page12rom)            ;RAMROMROMRAM
	out   ($a8),a
	ld    a,Loaderblock                 ;loader routine at $4000
	call  block12
	call  loader                        ;loader routines > 20240405;updated, now returns A=block, HL=adr || old:returns with IX=roomdatastuff, used by next call
	call  UnpackMapdataAndObjectData    ;unpacks packed map to ram. sets objectdata at the end of mapdata ends with: all RAM except page 2

;	ld a,(slot.page12rom)            ;RAMROMROMRAM
;	out ($a8),a
;	ld a,Loaderblock                 ;loader routine at $4000
;	call block12
;	ld a,Ruinid.Pegu
	call GetRoomPaletteId
	call getPalette
	call SetMapPalette
	call getroomtypeId
	call InitializeRoomType

	call  ConvertToMapinRam             ;convert 16bit tiles into 0=background, 1=hard foreground, 2=ladder, 3=lava. Converts from map in $4000 to MapData in page 3
	call  BuildUpMap                    ;build up the map in Vram to page 1,2,3,4

	call  CopyScoreBoard                ;set scoreboard from page 2 rom to Vram -> to page 0 - bottom 40 pixels (scoreboard) |loader|
	call  CopyVramObjectsPage1and3      ;copy VRAM objects to page 1 and 3 - screen 5 - bottom 40 pixels |loader|


	call  SetObjects                    ;after unpacking the map to ram, all the object data is found at the end of the mapdata. Convert this into the object/enemytables

;	ld    a,(slot.page12rom)            ;all RAM except page 12
;	out   ($a8),a       

;	ld    a,(slot.page12rom)            ;all RAM except page 12
;	out   ($a8),a
;	ld    a,Loaderblock                 ;loader routine at $4000
;	call  block12
;	call  SetObjects                    ;after unpacking the map to ram, all the object data is found at the end of the mapdata. Convert this into the object/enemytables

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

  call  LoadSamplesAndPlaySong0

  ld    a,1
  ld    (AmountOfFramesUntilScreenTurnsOn?),a

	ld    a,(UnpackedRoomFile+roomDataBlock.mapid)
	and   $1f
  ld    (PreviousRuin),a

  jp    LevelEngine



;UnpackedRoomFile:
;.meta:		rb 8
;.tiledata:  rb  38*27*2
;clear wall mapdate tiles to background
RemoveWallFromRoomTiles:
;   ld    b,+16                               ;add y to check (y is expressed in pixels)
;   ld    de,000                              ;add x to check (x is expressed in pixels)
;   call  checktileObject                     ;perform checktile object, but only to set hl pointing to the left top tile where wall starts
											;ro: that should really be a general function, like "getRoomTileLocation"
;ro: in the original "checkTileObject" function, X is loaded as 8-bit, while it is a 16-bit. So:
  ld    l,(ix+enemies_and_objects.x)        ;x object
  ld    h,(ix+enemies_and_objects.x+1)
  ld    a,(ix+enemies_and_objects.y)        ;y object
  add   a,16
  call    CheckTile.XandYset				;<< yes, this should be generic as mentioned earlier.

;Fill a part of the current room tile matrix (ro: this should be a general function)										
; so, I changed it.
  ld    a,(ix+enemies_and_objects.nx)
  srl	a ;/2
  srl	a ;/4
  srl	a ;/8
  and	0x1f
  ld 	b,a
  ld    a,(ix+enemies_and_objects.ny)
  srl	a ;/2
  srl	a ;/4
  srl	a ;/8
  and	0x1f
  ld 	c,a
  jp	fillMapData

;20240914;ro;a generic block fill for mapdata
;in: HL=startAddress, B=lenX (tiles), C=lenY (tiles), A=value > atm =0
fillMapData:
		; ld	a,40	;line lenght    > this isn't correct and only working on 38 wide rooms. So:
		ld	a,(checktile.selfmodifyingcodeMapLenght+1)		;see why selfmodcode is stupid? you might need the var on other parts too.
		sub	b
		ld	e,a
		ld	d,0
		ld	a,c
		ld	c,b
.fmp0:	ld	(hl),d
		inc	hl
		djnz .fmp0
		add	hl,de
		ld	b,c
		dec	A
		jp	nz,.fmp0
ret

AreaSignList:	dw	AreaSign01,AreaSign02,AreaSign03,AreaSign04,AreaSign05,AreaSign06,AreaSign07,AreaSign08,AreaSign09,AreaSign10,AreaSign11,AreaSign12,AreaSign13,AreaSign14,AreaSign15,AreaSign16,AreaSign17,AreaSign18,AreaSign19
UnpackAreaSign:
	ld    a,(slot.page1rom)            ;RAMROMROMRAM
	out   ($a8),a	

	ld    a,AreaSignTestBlock			;packed area signs at $4000
	call  block12

	exx
	push	bc
	push	hl

	ld    a,(UnpackedRoomFile+roomDataBlock.mapid)
	and   $1f
	add		a,a
	ld		hl,AreaSignList
	ld		d,0
	ld		e,a
	add		hl,de
	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a

;	ld		hl,AreaSign02
	ld		de,$8000
	call	Depack						;In: HL: source, DE: destination

	pop		hl
	pop		bc
	exx

	ld    a,Loaderblock                 ;loader routine at $4000
	call  block12
	ret


VramGraphicsPage1And3AlreadyInScreen?: db  0
ScoreBoardAlreadyInScreen?: db  0
AmountOfFramesUntilScreenTurnsOn?:  ds  1
CurrentSongBeingPlayed: db  0

CheckSwitchNextSong:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		6,a           ;F1 pressed ?
  ret   z

	.GoSwitchNextSong:
  call  RePlayer_Stop
  ld    a,(CurrentSongBeingPlayed)
  inc   a
  cp    7
  jr    nz,.EndCheckLastSong
  ld    a,1
  .EndCheckLastSong:
  ld    (CurrentSongBeingPlayed),a
  ld    c,a
  ld    b,0
;  ld    bc,3                          ;track nr
  ld    a,usas2repBlock               ;ahl = sound data (after format ID, so +1)
  ld    hl,$8000+1
  call  RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
  call  RePlayer_Tick                 ;initialise, load samples
  ret
  
LoadSamplesAndPlaySong0:
	ld    a,(RePlayer_playing)
	and   a
	ret   nz

  ld		a,2
  ld    (CurrentSongBeingPlayed),a
  call  RePlayer_Stop
  ld    bc,2                          ;track nr
  ld    a,usas2repBlock               ;ahl = sound data (after format ID, so +1)
  ld    hl,$8000+1
  call  RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
  call  RePlayer_Tick                 ;initialise, load samples

;	call	CheckSwitchNextSong.GoSwitchNextSong
  ret


SetElementalWeaponInVramJumper:       ;check if F1 is pressed and the menu can be entered
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
  call  RePlayer_Detect               ;detect moonsound
  call  RePlayerSFX_Initialize
  ld a,LoadSamples?	;debug function to skip sample load
  and A
  ret z
  ld    bc,0                          ;track nr 0 will alos initialize samples
  ld    a,usas2repBlock               ;ahl = sound data (after format ID, so +1)
  ld    hl,$8000+1
  call  RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
  call	RePlayer_Tick
  call	RePlayer_Stop
  ret

Main_Loop:
  halt
  call  RePlayer_Tick
  jp    Main_Loop  

INCLUDE "RePlayer.asm"

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


clearEnemyTable:
		ld    b,amountofenemies
		ld    hl,enemies_and_objects
		ld    de,lenghtenemytable
		xor   a
.Loop:	ld    (hl),a
		add   hl,de
		djnz  .Loop
ret


;unpacks packed map to ram. ends with: all RAM except page 2
;in:	IX
UnpackMapdataAndObjectData:             
		;unpack map data
;		ld    a,(slot.page12rom)            ;all RAM except page 2
;		out   ($a8),a      
;		ld    a,(ix+0)		;ROM block 
		call  block34		;we can only switch block34 if page 1 is in rom
;		ld    l,(ix+1)		;ROM adr
;		ld    h,(ix+2)

		;unpack map data
;		ld    a,(slot.page2rom)             ;all RAM except page 2
;		out   ($a8),a      
			
		ld    de,UnpackedRoomFile	;Unpack RoomLayout to page3 buffer
		jp    Depack 				;In: HL: source, DE: destination

;Engine256x216: a map is 32x27. We add 2 empty tiles on the right per row, and the remainder is filled with background tiles. Total mapsize will be 34x27 + empty fill
;Engine304x216: a map is 38x27. We add 2 empty tiles on the right per row, and we have two extra rows with background tiles. Total mapsize will be 40x27 + empty rows

MapHeight:                  equ 27
MapLenght256x216:           equ 32
MapLenght304x216:           equ 38

CheckTile256x216MapLenght:  equ 32 + 2
CheckTile304x216MapLenght:  equ 38 + 2

;Space for room tile IDs
MapData:	ds    (38+2) * (27+2) ,0  ;a map is 38 * 27 tiles big  


;Return the correct tile ID for this room
GetRoomTilesetId:
		ld a,(UnpackedRoomFile+roomdatablock.tileset)	;tileset overwrite?
		and $1f
		ret nz
		ld a,(UnpackedRoomFile+roomdatablock.mapid)		;default tileset
		and $1f
ret

;Return the correct palette ID for this room
GetRoomPaletteId:
		ld a,(UnpackedRoomFile+roomdatablock.palette)	;tileset overwrite?
		and $1f
		ret nz
		ld a,(UnpackedRoomFile+roomdatablock.mapid)		;default tileset
		and $1f
ret

;Return the current room type
GetRoomTypeId:
		ld    a,(UnpackedRoomFile+roomDataBlock.mapid)  ;tttrrrrr (t=type,r=ruin)
		rlca
		rlca
		rlca
		and   7
ret

BuildUpMap:
		;Set ROM with tileset blocks to p1,p2
		ld    a,(slot.page12rom)
		out   ($a8),a
		call GetRoomTilesetId
		call GetTilesetBitmap

		;start writing VDP at 0,0,0 
		xor   a
		ld    hl,0
		call	SetVdp_Write	
		ld    ix,UnpackedRoomFile.tiledata
		ld    c,$98                         ;out port for outi's

		ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
		dec   a
		jp    z,.buildupMap38x27
		;  jp    .buildupMap32x27
.buildupMap32x27:
		ld    a,32*2
		ld    (.SelfModifyingCodeMapLenght),a

		;rom->vram copy 14 rows to page 0
		ld    b,14                          ;14 rows
.loop6:	call  .Put8blines
;		djnz  .loop6

		;vdp copy these 14 rows to page 1
		ld    hl,.CopyPage0to1first14rows
		call  docopy

		;rom->vram copy the last 13 rows to page 0
		ld    b,13                          ;13 rows
.loop7:	call  .Put8blines
;		djnz  .loop7

		;vdp copy these 13 rows to page 1
		ld    hl,.CopyPage0to1second13rows
		call  docopy

		;set vdp ready to write in page 3 in vram 
		ld    a,1
		ld    hl,$8000                      ;start writing at (0,0) page 3
		call	SetVdp_Write	

		;rom->vram copy 7 rows to page 3
		ld    ix,UnpackedRoomFile.tiledata	;reset source
		ld    b,07                          ;7 rows
.loop8:	call  .Put8blines
	;	djnz  .loop8

		;vdp copy page 0 to page 2
		ld    hl,.CopyPage0to2
		call  docopy

		;rom->vram copy the next 14 rows to page 3
		ld    b,14                          ;14 rows
.loop9: call  .Put8blines
;		djnz  .loop9

		;vdp copy the last 5 rows to page 3
		ld    hl,.CopyPage0to3last6rows
		call  docopy

		ld    a,Loaderblock                 ;loader routine at $4000
		call  block12
ret

.CopyPage0to1first14rows:
		db    000,000,000,000   ;sx,--,sy,spage
		db    000,000,000,001   ;dx,--,dy,dpage
		db    000,001,14*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy
.CopyPage0to1second13rows:
		db    000,000,14*8,000   ;sx,--,sy,spage
		db    000,000,14*8,001   ;dx,--,dy,dpage
		db    000,001,13*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy
.CopyPage0to2:
		db    000,000,000,000   ;sx,--,sy,spage
		db    000,000,000,002   ;dx,--,dy,dpage
		db    000,001,216,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   
.CopyPage0to3last6rows:
		db    000,000,21*8,000   ;sx,--,sy,spage
		db    000,000,21*8,003   ;dx,--,dy,dpage
		db    000,001,6*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   


.buildupMap38x27:
		ld    a,38*2
		ld    (.SelfModifyingCodeMapLenght),a

		;rom->vram copy 14 rows to page 0
		ld    b,14                          ;14 rows
.loop1:	call  .Put8blines
	;	djnz  .loop1

		;vdp copy these 14 rows to page 2
		ld    hl,.Page0toPage2first14rows
		call  docopy

		;rom->vram copy the last 13 rows to page 0
		ld    b,13                          ;13 rows
.loop4:	call  .Put8blines
;		djnz  .loop4

		;vdp copy these last 13 rows to page 2
		ld    hl,.Page0toPage2second13rows
		call  docopy

		;set vdp ready to write in page 3 in vram 
		ld    a,1
		ld    hl,$8000                      ;start writing at (0,0) page 3
		call	SetVdp_Write	

		;rom->vram copy 6 rows to page 3
		ld    ix,UnpackedRoomFile.tiledata + 12
		ld    b,06                          ;6 rows
.loop2: call  .Put8blines
;		djnz  .loop2

		;vdp copy page 0 to page 1
		ld    hl,.Page0toPage1
		call  docopy

		;rom->vram copy the next 14 rows to page 3
		ld    b,14                          ;14 rows
.loop3: call  .Put8blines
;		djnz  .loop3

		;vdp copy a 20 rows of a strip (32x160) page 3 to page 2
		ld    hl,.Page3toPage2_StripOf32first20rows
		call  docopy

		;rom->vram copy the last 7 rows to page 3
		ld    b,07                          ;7 rows
.loop5: call  .Put8blines
;		djnz  .loop5

		;vdp copy the remaining 2 small copies
		ld    hl,.Page3toPage2_StripOf32second7rows
		call  docopy
		ld    hl,.Page3toPage1_StripOf16
		call  docopy

		ld    a,Loaderblock                 ;loader routine at $4000
		call  block12
ret

.Page0toPage1:
		db    016,000,000,000   ;sx,--,sy,spage
		db    000,000,000,001   ;dx,--,dy,dpage
		db    240,000,216,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

.Page0toPage2first14rows:
		db    032,000,000,000   ;sx,--,sy,spage
		db    000,000,000,002   ;dx,--,dy,dpage
		db    224,000,14*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

.Page0toPage2second13rows:
		db    032,000,14*8,000   ;sx,--,sy,spage
		db    000,000,14*8,002   ;dx,--,dy,dpage
		db    224,000,13*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

.Page3toPage1_StripOf16:
		db    208,000,000,003   ;sx,--,sy,spage
		db    240,000,000,001   ;dx,--,dy,dpage
		db    016,000,216,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

.Page3toPage2_StripOf32first20rows:
		db    208,000,000,003   ;sx,--,sy,spage
		db    224,000,000,002   ;dx,--,dy,dpage
		db    032,000,20*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

.Page3toPage2_StripOf32second7rows:
		db    208,000,20*8,003   ;sx,--,sy,spage
		db    224,000,20*8,002   ;dx,--,dy,dpage
		db    032,000,7*8,000   ;nx,--,ny,--
		db    000,000,$D0       ;fast copy   

;Put [B] rows of 32 tiles on screen 20240502
.Put8Blines:
.Put8lines:
		push  bc

		di
		ld    (spatpointer),sp              ;store stack pointer
		ld    a,8                           ;8 lines
		ld    de,0 * 128                    ;1st line
.MainLoop:
		ld    sp,ix                         ;sp now points to mapdata in ram
		ld    b,5*32                        ;32 tiles per line (x5 because the 4 outi's also dec b)
.LineLoop:
		pop   hl                            ;starting address of tile in rom
		add   hl,de                         ;tileline of tile
		outi
		outi
		outi
		outi                                ;first line of this tile
		djnz  .LineLoop  

		ld    hl,1 * 128                    ;lenght of 1 line (128 bytes)
		add   hl,de                         ;next line
		ex    de,hl

		dec   a
		jp    nz,.MainLoop

		ei
		ld    sp,(spatpointer)              ;recall stack pointer

.SelfModifyingCodeMapLenght: equ $+1  
		ld    de,000
		add   ix,de                         ;go to next row of tiles
		pop   bc
		djnz .put8blines
		ret



;Get GFX location, and set blocks at page 1,2
GetTilesetBitmap: 
;		LD    BC,TileSetIndex
		LD	BC,dsm.bitmapGfxindexAdr	; $9000 		;start of the gfx index (temp)
        LD	L,A
        LD	H,0
        ADD	HL,HL
        ADD	HL,BC
		LD A,dsm.firstblock+dsm.indexblock 		;indexblock (temp)
		call block34							;map it to p2
        LD	A,(HL)
        INC	HL
        LD	H,(HL)
        LD	L,A
		ld	bc,dsm.bitmapGfxindexAdr+dsm.bitmapGfxRecords ;$9000+64
		add	hl,bc
;rm: voorlopig zo, met raw sc5 uitgaande van volledige 32K
		LD    A,(HL)          ;pal
		INC   HL
;		LD    B,(HL)          ;parts
		INC   HL
		LD    A,(HL)          ;block part 1
		add	a,dsm.firstblock ;temp
		Call	block12
		INC   HL
;	    LD    D,(HL)          ;seg
		INC   HL
;   	 LD    E,0
;    	SRL   D               ;seglen=128
;	    RR    E
		LD    A,(HL)          ;block part 2
		add a,dsm.firstBlock ;temp
		jp	block34

;        LD    A,(HL)          ;pal
;        INC   HL
;        LD    B,(HL)          ;parts
;        INC   HL
;GFX.0:  LD    A,(HL)          ;block
;        INC   HL
;        LD    D,(HL)          ;seg
;        INC   HL
;        LD    E,0
;        SRL   D               ;seglen=128
;        RR    E
;        DJNZ  GFX.0
;        RET


; Tiles numbering
LadderTilesEndAdrStart:	equ 1
LadderTilesEndAdrEnd:	equ 8 	;tilenr: 1 t/m 8 = ladder
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

WaterTilesStart:	equ	52
WaterTilesEnd:		equ	57

ForegroundTilesStart: equ 58
ForegroundTilesEnd: equ 255	;tilenr: 52 t/m 255 = foreground
BackgroundTilesStart:	equ 256
BackgroundTilesEnd:	equ 1023;tilenr: 256 t/m 1023 = background
;convert into
BackgroundID:		equ 0	;tile 0 = background
HardForeGroundID:	equ 1	;tile 1 = hardforeground
LadderId:			equ 2	;tile 2 = LadderTilesEndAdrEnd
SpikeId:			equ 3	;tile 3 = spikes/poison
StairLeftId:		equ 4	;tile 4 = stairsleftup
StairRightId:		equ 5	;tile 5 = stairsrightup
LavaId:				equ 6	;tile 6 = lava
WaterId:			equ 7	;tile 7 = water

tileConversionTable: ;(id,tilenr) order desc
  DB  HardForeGroundID,ForegroundTilesStart,WaterID,WaterTilesStart,StairRightId,StairRightTilesStart
  DB  StairLeftId,StairLeftTilesStart,LavaId,LavaTilesStart
  DB  SpikeId,SpikeTilesStart,BackgroundID,FreeTilesStart
  DB  ladderID,LadderTilesEndAdrStart,BackgroundID,0

;20231104
;Convert TileNumbers to TileIDs
ConvertToMapinRam:
	ld  de,UnpackedRoomFile.tiledata 
	ld  hl,MapData
	ld	a,MapHeight
.SelfModifyingCodeMapLenght:
    ld	b,000   ;maplenght: 32 or 38, depending on which engine is active
    push af
.loop:
    push hl
    call .convertTile
    pop hl

;the following code changes lava and spike tiles, to speed this up, both their values in tileConversionTable can be adjusted instead.
;Lava is turning to hard foreground when lavawalk is obtained
	ld		a,c
	cp		LavaId
	jr		nz,.EndCheckLava
	ld		a,(LavaWalkObtained?)
	or		a
	jr		z,.EndCheckLava
	ld		c,HardForeGroundID
	.EndCheckLava:
;spikes is turning to background when spikeswalk is obtained
	ld		a,c
	cp		SpikeId
	jr		nz,.EndCheckSpikes
	ld		a,(SpikesWalkObtained?)
	or		a
	jr		z,.EndCheckSpikes
	ld		c,BackgroundID
	.EndCheckSpikes:

    ld  (HL),c
    inc hl
    djnz .loop

    ld  (hl),0 ;2 empty tiles on the right side of the map
    inc hl
    ld  (hl),0
    inc hl  

    pop AF
    dec a
    jp  nz,.SelfModifyingCodeMapLenght
ret
  
;Convert one MapTileNr to TileID using a lookupTable
.convertTile:
        ld	A,(de)
		inc de
		rrca
		rrca
		ld	l,a
        ld  a,(de)
        inc de
        ld c,BackgroundId
        cp $60
        ret nc
		and $3f
		rla
		rla
		rla
		or l

        ld hl,tileConversionTable
.loop0: ld c,(hl)
        inc hl
        cp (hl)
        ret nc
        inc hl
        jp .loop0
  
SetTile:
  db    000,000,000,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    008,000,008,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy   

TinyCopyWhichFunctionsAsWaitVDPReady:
	db		0,0,0,0
	db		0,0,0,0
	db		1,0,1,0
	db		0,%0000 0000,$98

DoCopy:	push bc
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

;15xOTI
		dw	$a3ed,$a3ed,$a3ed,$a3ed	;will destroy BC
		dw	$a3ed,$a3ed,$a3ed,$a3ed
		dw	$a3ed,$a3ed,$a3ed,$a3ed
		dw	$a3ed,$a3ed,$a3ed
		pop bc
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


;Write pal data [HL] to VDP
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
;Set VDP to start writing at address AHL (17-bit)
SetVdp_Write: 
	rlc     h	;first set register 14 (actually this only needs to be done once
	rla
	rlc     h
	rla
	srl     h
	srl     h
	di
	out     ($99),a       ;set bits 15-17
	ld      a,14+128
	out     ($99),a

	ld      a,l           ;set bits 0-7
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
	
freezecontrols?:          db  0
;DoubleTapCounter:         db  1
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

PageToWriteTo: ds  1                    ;0=page 0 or 1, 1=page 2 or 3
AddressToWriteFrom: ds  2
AddressToWriteTo: ds  2
NXAndNY: ds  2
BigEnemyPresentInVramPage3:   db 0      ;1=big statue mouth, 2=huge blob, 3=huge spider
ObjectPresentInVramPage1:     db 0      ;1=omni directional platform

;Copy ROM to VRAM using Direct VDP Access
;in:HL=SxSy, DE=DxDy, BC=NxNy, A=ROMblock
CopyRomToVram:
	ex    af,af'                          ;store rom block

	in	 a,($a8)                         ;store current rom/ram settings of page 1+2
	push af
	ld	 a,(memblocks.1)
	push af
	ld	 a,(memblocks.2)
	push af

	ld    a,(slot.page12rom)              ;all RAM except page 1+2
	out   ($a8),a      
	ex    af,af'
	call  block1234                       ;CARE!!! we can only switch block34 if page 1 is in rom  
	call  .go                             ;go copy

	pop   af
	call  block34
	pop   af
	call  block12
	pop   af
	out   ($a8),a                         ;reset rom/ram settings of page 1+2
  ret

.go:
	ld    (AddressToWriteFrom),hl	;ro: write from? don't you mean READ from?
	ld    (AddressToWriteTo),de
	ld    (NXAndNY),bc

	ld    c,$98                           ;out port
	ld    de,128                          ;increase 128 bytes to go to the next line

.loop:
	call  .WriteOneLine
	ld    a,(NXAndNY+1)
	dec   a
	ld    (NXAndNY+1),a
	jp    nz,.loop
ret

.WriteOneLine:
	ld    hl,(AddressToWriteTo)           ;set next line to start writing to
	add   hl,de                           ;increase 128 bytes to go to the next line
	ld    (AddressToWriteTo),hl

	ld		a,(PageToWriteTo)             ;0=page 0 or 1, 1=page 2 or 3
	call	SetVdp_Write

	ld    hl,(AddressToWriteFrom)         ;set next line to start writing from
	add   hl,de                           ;increase 128 bytes to go to the next line
	ld    (AddressToWriteFrom),hl
	ld    a,(NXAndNY)
	;  cp    128
	;  jr    z,.outi128
	ld    b,a
	otir
  ret


AppearingBlocksTable: ;dy, dx, appear(1)/dissapear(0)      255 = end
  ds    7 * 6 ;7 blocks maximum, 6 bytes per block
  ds    6 ;1 extra block buffer
AmountOfAppearingBlocks:  ds  1
OctoPussyBulletSlowDownHandler:   db 0
EnemyHitByPrimairyAttack?:	db	0		;0=hit by secundary attack, 1=hit by primary attack

PlayerIsInWater?:				db	1




SaveGameVariables:						;Here we store all variables that are required when saving game
BossDead?:					db	%0000 0000		;bit 0=demon, bit 1=voodoo wasp, bit 2=zombie caterpillar, bit 3=ice goat, bit 4=huge blob, bit 5=boss plant

SecundaryWeaponOwned:		db	%0000 0000	;bit 0=fire, bit 1=ice, bit 2=earth, bit 3=water
PrimaryWeaponOwned:			db	%0000 0000	;bit 0=sword, bit 1=dagger, bit 2=axe, bit 3=spear
SwordInfusedWithElement?:	db	%0000 0001	;bit 0=fire, bit 1=ice, bit 2=earth, bit 3=water
DaggerInfusedWithElement?:	db	%0000 0010	;bit 0=fire, bit 1=ice, bit 2=earth, bit 3=water
AxeInfusedWithElement?:		db	%0000 1000	;bit 0=fire, bit 1=ice, bit 2=earth, bit 3=water
SpearInfusedWithElement?:	db	%0000 0100	;bit 0=fire, bit 1=ice, bit 2=earth, bit 3=water
;CurrentPrimaryWeapon:         db  0 ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
;CurrentMagicWeapon:           db  0 ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water, 10=kinetic energy

DoubleJumpObtained?:		db	1
RollingObtained?:			db	1
WallBashObtained?:			db	1
WallWalkObtained?:			db	1
WallJumpObtained?:			db	1
LavaWalkObtained?:			db	1
SpikesWalkObtained?:		db	1
FlyingObtained?:			db	1
SwimmingObtained?:			db	1
MeditatingObtained?:		db	1

SpearObtained?:				db	1
SwordObtained?:				db	1
DaggerObtained?:			db	1
AxeObtained?:				db	1

FireMagicObtained?:			db	1
AirObtained?:				db	1
EarthObtained?:				db	1
WaterObtained?:				db	1
BowAndArrowObtained?:		db	1





endenginepage3:
dephase
enginepage3length:	Equ	$-enginepage3

variables: org $c000+enginepage3length
slot:						
.ram:				equ	  $e000
.page1rom:			equ	  slot.ram+1
.page2rom:			equ	  slot.ram+2
.page12rom:			equ	  slot.ram+3
memblocks:
.1:					equ	  slot.ram+4
.2:					equ	  slot.ram+5
.3:					equ	  slot.ram+6
.4:					equ	  slot.ram+7	
VDP_0:				equ   $F3DF
VDP_8:				equ   $FFE7


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

;PlayerIsInWater?:				rb	1

AmountOfPoisonDropsInCurrentRoom:   rb    1
AmountOfWaterfallsInCurrentRoom:    rb    1
AmountOfSF2ObjectsCurrentRoom:      rb    1
CurrentActiveWaterfall:             rb    1

PreviousRuin:                 rb    1 ;Ruin we were in before current room


;RoomDataBlock structure
roomDataBlock:	equ 0
.mapId:			equ +0
.tileSet:		equ +1
.music:			equ +2
.palette:		equ +3
.free:			equ +4
.mapTiles:		equ +8
;Space for room tiles data 
UnpackedRoomFile:
.meta:		rb 8
.tiledata:  rb  38*27*2
.object:	rb 256


fill: equ 2

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

