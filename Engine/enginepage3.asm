phase	enginepage3addr


;current location=karnimata
roomX: equ ("B"-"A")*26 + "V"-"A"
roomY: equ 27

WorldMapPosition:
.Y:  db  roomY-1
.X:	 db  roomX
ClesX:      dw 64 ;$19 ;230 ;250 ;210
ClesY:      db 112 ;144-1
standchar:	dw 0	;20241020;ro;moved this from selfmodcode@engine to this var in p3


;WM DATA > in RAM
WMADR:  DW    0x8000           ;RAM location
WMMAP:  DB    1               ;MemoryMap
WMRCOL: DB    _WMRC0,_WMRC1,_WMRC2,_WMRC3,_WMRC4,_WMRC5,_WMRC6,_WMRC7
WMHMMC: DW    0,0,0,0,4,4,0,0xF0 ;(sx,sy,)dx,dy,nx,ny,col/arg,cmd=hmmc


PlayLogo:
		call  StartTeamNXTLogo              ;sets logo routine in rom at $4000 page 1 and run it
startTheGame:
		call	Replayer_Stop
		call	enableWorldmap
		ld		hl,$B000
		call	newwm
		; call	ResetPushStones	;[engine.asm]

		ld		a,-1
		ld		(PreviousRuin),a
		call	loadRoom
		; di
		; halt
		jp		LevelEngine


;Load the current room
loadRoom:

		call	loadGraphics
		ld		a,(PreviousRuin)
		ld		b,a
		call	GetRoomRuinId
		ld		(PreviousRuin),a
		cp		b
		call	nz,initRuin
		call	addThisRoomToWorldmap
		ret

;this room is in a differt Ruin than the previous
initRuin:
		call	ResetPushStones
		call	GetRoomMusicId
		call	setMusic
		ret


;ro: this does a bit more than that, it also enabled interrupt
loadGraphics:
		call	screenoff					;[engine.asm]
		ld		a,(slot.page12rom)            ;RAMROMROMRAM
		out		($a8),a
		ld		a,Loaderblock                 ;loader routine at $4000
		call	block12
;the next calls should be moved to "loadroom"
		call	ReSetVariables 				;[loader.asm]
		call	PopulateControls			;[enginepage3.asm] this allows for a double jump as soon as you enter a new map
		call	unpackCurrentRoom    ;unpacks packed map to ram. sets objectdata at the end of mapdata ends with: all RAM except page 2
		call	getroomtypeId
		call	InitializeRoomType
		call	ConvertToMapinRam             ;convert 16bit tiles into 0=background, 1=hard foreground, 2=ladder, 3=lava. Converts from map in $4000 to MapData in page 3



		call	SwapSpatColAndCharTable2	;[engine.asm]
		call	SwapSpatColAndCharTable		;[engine.asm]
		call	SwapSpatColAndCharTable2	;[engine.asm]
		
		call	CopyScoreBoard                ;set scoreboard from page 2 rom to Vram -> to page 0 - bottom 40 pixels (scoreboard) |loader|
		call	CopyVramObjectsPage1and3      ;copy VRAM objects to page 1 and 3 - screen 5 - bottom 40 pixels |loader|

		call	GetRoomPaletteId
		call	getPalette
		call	SetMapPalette

		call	BuildUpMap                    ;build up the map in Vram to page 1,2,3,4
		call	SetObjects                    ;after unpacking the map to ram, all the object data is found at the end of the mapdata. Convert this into the object/enemytables
		


		call  RemoveSpritesFromScreen       ;|loader|
		call  SwapSpatColAndCharTable
		call  PutSpatToVramSlow
		call  SwapSpatColAndCharTable
		call  PutSpatToVramSlow
		call  initiatebordermaskingsprites  ;|loader|

		ld    a,1				;!! RO:whaztizfor?
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
		ld    a,1
		ld    (AmountOfFramesUntilScreenTurnsOn?),a
		ret


;enable *this* room in the worldmap (still POC)
addThisRoomToWorldMap:
		call	enableWorldMap
		call	getroomtypeId
		ld		de,(WorldMapPosition)
		call	newwmr                  ;create room [DE] with type [A] on the map
		call	GetRoomRuinId	;is this Polux (hub)
		cp		ruinid.Polux
		ret		nz
		ld		a,(hl)			;then make the room green (color 12)
		and		0xF0
		or		12				;green
		ld		(hl),a
		ret

;Set the engine properties for type [A]
;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
;SetEngine:
InitializeRoomType:
		call getroomtype
		ld	 a,(hl) ;width
		ld	(roomMap.width),a
		push hl
		ld   l,A
		ld   h,0
		add  hl,hl ;x2
		add  hl,hl ;x4
		add  hl,hl ;x8
		ld   (roomMap.widthPix),HL
		pop hl
		inc	 hl		; height
		inc	 hl		; engine
		ld	 a,(hl)
		ld	 (scrollEngine),a              ;1= 304x216 engine, 2=256x216 SF2 engine, 3=256x216 SF2 engine sprite split ON 
		dec	 a
		jp	 z,.type1 ;.Engine304x216
		dec	 a
		jp	 z,.type2 ;256x216 SF2
;	jp	 .type3	;256x216 SF2 engine sprite split ON 

;SF2 engine
; in the SF2 engine we can choose to have spritesplit active, which gives us 14 extra sprites  
.type3:	;.Engine256x216WithSpriteSplit:
		ld    a,1	;Mark sprite split active
		jr	 .SetSpriteSplit

;SF2 engine
.type2:	;.Engine256x216:
		xor	 a	;Mark sprite split inactive

.SetSpriteSplit:
		ld    (SpriteSplitFlag),a   
		ld    de,ExitRight256x216 ;equ 252 ; 29*8
		ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
	
;check if player enters on the left side of the screen or on the right side. On the left camerax = 0, on the right camerax=15
		xor	 A
		ld	 hl,256/2
		ld	 de,(ClesX)
		sbc	 hl,de
		jr	 nc,.setCameraX
		ld	 a,15
.setCameraX:
		ld    (CameraX),a

;if engine type = 256x216 and x Cles = 34*8, then move cles 6 tiles to the left, because this Engine type has a screen width of 6 tiles less
		ex	 de,hl	;	ld    hl,(ClesX)
		ld	 de,ExitRight304x216
		xor	 a
		sbc	 hl,de
		ret	 nz
		ld	 hl,252 	;!! some magicnumber
		ld	 (ClesX),hl
		ret

.type1:	;.Engine304x216:
		ld    a,1                           ;sprite split active
		ld    (SpriteSplitFlag),a
		ld    de,ExitRight304x216 ;equ 38*8-3
		ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
		ret
  

;clear wall mapdate tiles to background
removeObjectFromRoomMapData: ; RemoveWallFromRoomTiles:
		ld    l,(ix+enemies_and_objects.x)        ;x object
		ld    h,(ix+enemies_and_objects.x+1)
		ld    a,(ix+enemies_and_objects.y)        ;y object
		call getRoomMapData
;Fill a part of the current room tile matrix										
		ld	a,(ix+enemies_and_objects.nx)
		srl	a ;/2
		srl	a ;/4
		srl	a ;/8
		and	0x1f
		ld 	b,a
		ld	a,(ix+enemies_and_objects.ny)
		srl	a ;/2
		srl	a ;/4
		srl	a ;/8
		and	0x1f
		ld 	c,a
		ld	a,BackgroundID
		jp	fillRoomMapData


;20240914;ro;a generic block fill for mapdata
;in: HL=startAddress, B=lenX (tiles), C=lenY (tiles), A=value
fillRoomMapData:
		ex  af,af'	;'
		ld	a,roomMap.numcol
		sub	b
		ld	e,a
		ld	d,0
		ld	a,c
		ld	c,b
.fmp1:	ex	af,af'	;'
.fmp0:	ld	(hl),a
		inc	hl
		djnz .fmp0
		add	hl,de
		ld	b,c
		ex  af,af'	;'
		dec	A
		jp	nz,.fmp1
		ret

;currently this is in POC phase
;area files are spread out over multiple blocks, these are not:
UnpackAreaSign:
		exx
		push	bc
		push	hl

		ld    a,(slot.page1rom)		;RAMROMROMRAM
		out   ($a8),a	
		; ld    a,AreaSignTestBlock	;packed area signs at $4000
		; call  block12
		; call	GetRoomRuinId
		; dec a
		; add		a,a
		; ld		hl,AreaSignList
		; ld		d,0
		; ld		e,a
		; add		hl,de
		; ld		a,(hl)
		; inc		hl
		; ld		h,(hl)
		; ld		l,a
		call	GetRoomRuinId ;20241212;ro;new
		call	getAreaSign
		ld		de,$8000
		call	Depack		;In: HL: source, DE: destination

		pop		hl
		pop		bc
		exx

		ld    a,Loaderblock		;loader routine at $4000
		call  block12
		ret
; AreaSignList:	dw	AreaSign01,AreaSign02,AreaSign03,AreaSign04,AreaSign05,AreaSign06,AreaSign07,AreaSign08,AreaSign09,AreaSign10,AreaSign11,AreaSign12,AreaSign13,AreaSign14,AreaSign15,AreaSign16,AreaSign17,AreaSign18,AreaSign19




CheckSwitchNextSong:
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
		ld		a,(NewPrContr)	
		bit		6,a           ;M pressed ?
		ret		z
		ld		a,(CurrentSongBeingPlayed)
		inc		a
		cp		7
		jr		nz,.EndCheckLastSong
		ld		a,1
.EndCheckLastSong:
		jp		setMusic

;Initialize music
;in:	A=musicId
setMusic:
		push	af
		ld		a,(RePlayer_playing)
		and		a
		call	nz,Replayer_Stop
		pop		af
		ld		(CurrentSongBeingPlayed),a
		ld		c,a
		ld		b,0
		ld		a,usas2repBlock and 255               ;ahl = sound data (after format ID, so +1)
		ld		hl,$8000+1
		call	RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
		call	RePlayer_Tick                 ;initialise, load samples
		ret
  
; LoadSamplesAndPlaySong0:
; 		ld    a,(RePlayer_playing)
; 		and   a
; 		ret   nz

; 		ld		a,2
; 		ld    (CurrentSongBeingPlayed),a
; 		call  RePlayer_Stop
; 		ld    bc,2                          ;track nr
; 		ld    a,usas2repBlock               ;ahl = sound data (after format ID, so +1)
; 		ld    hl,$8000+1
; 		call  RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
; 		call  RePlayer_Tick                 ;initialise, load samples
; ret


SoundData: equ $8000
initializeVGMRePlay:
		ld    a,(slot.page12rom)            ;all RAM except page 1+2
		out   ($a8),a
		ei		;ro:why is this here?

		ld    a,FormatOPL4_ID
		call  RePlayer_Detect               ;detect moonsound
		call  RePlayerSFX_Initialize
		ld a,LoadSamples?					;debug function to skip sample load
		and A
		ret z
		ld    bc,0                          ;track nr 0 is samples
		ld    a,usas2repBlock and 255               ;ahl = sound data (after format ID, so +1)
		ld    hl,$8000+1
		call  RePlayer_Play                 ;bc = track number, ahl = sound data (after format ID, so +1)
		call	RePlayer_Tick
		call	RePlayer_Stop
		ret


SetElementalWeaponInVramJumper:       ;check if F1 is pressed and the menu can be entered
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a

  ld    a,F1Menublock                 ;F1 Menu routine at $4000
  call  block12

  jp    SetElementalWeaponInVram
  
  

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



; Main_Loop:
; 		halt
; 		call  RePlayer_Tick
; 		jp    Main_Loop  

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
unpackCurrentRoom: 
		ld de,(WorldMapPosition) 			;WorldMapPositionX/Y:  
		call getRoom	;out: A=block,DE=RomAdr            
		call  block34		;we can only switch block34 if page 1 is in rom
		ld    de,UnpackedRoomFile	;Unpack RoomLayout to page3 buffer
		jp    Depack 				;In: HL: source, DE: destination


MapHeight:                  equ 27
;MapLenght256x216:           equ 32
;MapLenght304x216:           equ 38
;CheckTile256x216MapLenght:  equ 32 + 2
;CheckTile304x216MapLenght:  equ 38 + 2

;Space for room tile classes
;MapData:
RoomMap:
.numcol:	equ 38+2	;ro; i'm not really sure why we store 2 extra empty bytes on each row...
.numrow:	equ 27+2
.width:		db 0 		;width of the current room in tiles
.widthPix:	dw 0 	;idem but in pixels
.data:		ds    .numrow * .numcol ,0   

;Get Ruin properties
;in:	A=ruinId
;out:	HL=RecAdr
GetRuin:
	push bc
	LD	h,0
	ld	l,A
	add	hl,hl	;x2
	add	hl,hl	;4
	add hl,hl	;8
	add	hl,hl	;16
	ld	bc,RuinPropertiesLUT.data
	add	hl,bc
	pop bc
ret

;RuinPropertiesLookUpTable
RuinPropertiesLUT:
.reclen:		equ 16		;[attribute]The length of one record
.numrec:		equ 32		;[attribute]Number of records
.tileset:		equ +0		;[property]Default Tileset ID
.palette:		equ +1		;[property]Default palette ID
.music:			equ +2		;[property]Default music ID
.Name:			equ +3		;[property]Name of the ruin as string
.data:						;RM:table generated externally
	DB 0,0,0,"             "
	DB 1,1,0,"Polux        "
	DB 2,2,0,"Lemniscate   "
	DB 6,6,3,"World Forrest"
	DB 4,4,0,"Pegu         "
	DB 0,0,0,"Bio          "
	DB 6,6,3,"Karni Mata   "
	DB 7,7,2,"Konark       "
	DB 0,0,0,"Ashoka's hell"
	DB 9,9,0,"Taxilla      "
	DB 0,0,0,"Euderus Set  "
	DB 11,11,0,"Akna         "
	DB 0,0,0,"Fate         "
	DB 0,0,0,"Sepa         "
	DB 0,0,0,"undefined    "
	DB 0,0,0,"Chi          "
	DB 0,0,0,"Sui          "
	DB 0,0,0,"Grot         "
	DB 0,0,0,"Tiwanaku     "
	DB 0,0,0,"Aggayu       "
	DB 0,0,0,"Ka           "
	DB 0,0,0,"Genbu        "
	DB 0,0,0,"Fuu          "
	DB 0,0,0,"Indra        "
	DB 0,0,0,"Morana       "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "



;Return the correct tile ID for this room
GetRoomTilesetId:
		ld a,(UnpackedRoomFile+roomdatablock.tileset)	; overwrite?
		and $1f
		ret nz
		ld		a,RuinPropertiesLUT.tileset
		call	getRoomRuinProperty
		ret

;Return the correct palette ID for this room
GetRoomPaletteId:
		ld		a,(UnpackedRoomFile+roomdatablock.palette)	; overwrite?
		and 	A	;$1f ;and max palettes, which is  not set atm
		ret		nz
		ld		a,RuinPropertiesLUT.palette
		call	getRoomRuinProperty
		ret

;Return the correct music ID for this room
GetRoomMusicId:
		ld		a,(UnpackedRoomFile+roomdatablock.music)	; overwrite?
		and		a
		ret		nz
		ld		a,RuinPropertiesLUT.music
		call	getRoomRuinProperty
		ret

;return a property from the current room ruin
;in:	A=property
getRoomRuinProperty:
		push	hl
		push	af
		call	GetRoomRuinId
		call	GetRuin
		pop		af
		add 	a,L
		ld		l,A
		ld		a,0
		adc		a,H
		ld		h,A
		ld		a,(hl)
		pop		hl
		ret

;Return the current room type
GetRoomTypeId:
		ld    a,(UnpackedRoomFile+roomDataBlock.mapid)  ;tttrrrrr (t=type,r=ruin)
		rlca
		rlca
		rlca
		and   7
		ret

;Return the current ruinID
GetRoomRuinId:
		ld    a,(UnpackedRoomFile+roomDataBlock.mapid)  ;tttrrrrr (t=type,r=ruin)
		and   0x1f
		ret


BuildUpMap:
		;Set ROM with tileset blocks to p1,p2
		ld    a,(slot.page12rom)
		out   ($a8),a
		call GetRoomTilesetId
		call getTileset

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
		; ld    a,32*2
		; ld    (.SelfModifyingCodeMapLenght),a

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
		; ld    a,38*2
		; ld    (.SelfModifyingCodeMapLenght),a

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

;.SelfModifyingCodeMapLenght: equ $+1  
;		ld    de,000
		ld	 de,(roomMap.width)
		ld	 d,0
		add   ix,de                         ;go to next row of tiles
		add   ix,de                         ;go to next row of tiles
		pop   bc
		djnz .put8blines
		ret

;Get block and Address of dataTypeIndex [A]
;out: A=block, HL=adr (p1) (block is set at p1)
getDataTypeIndex:
		ld		e,A	
		ld		d,0
		ld		hl,dataTypeIndex.Adr+0x4000
		add		hl,de
		add		hl,de
		ld		A,dataTypeIndex.block
		call	block12
		ld		a,(hl)		;dataTypeIndexRecord.DsmBlock
		inc		hl
		ld		d,(hl)		;dataTypeIndexRecord.DsmSegment
		add		a,dsm.firstblock
		call	block12
		LD		E,0
    	SRL		D			;seglen=128
	    RR		E
		ld		hl,0x4000
		add		hl,de
		ret

;Get GFX location, and set blocks at page 1,2
;in: A=tileSetId
getTileset:
		ld		c,a
		ld		b,0

		ld		a,dataType.Tileset
		call	getDataTypeIndex

		push	hl
		add		hl,bc
		add		hl,bc
		ld		c,(hl)		;get pointer
		inc		hl
		ld		b,(hl)
		pop		hl
		add		hl,bc

;rm: voorlopig zo, met raw sc5 uitgaande van volledige 32K (als we niet gaan packen laten we dit zo)
;		LD		B,(HL)          ;parts
		INC		HL
		LD		A,(HL)          ;DsmBlock part 1
		INC		HL
		add		a,dsm.firstblock ;temp
		ex		af,af'
;	    LD		D,(HL)          ;seg=0 atm
		INC		HL
;		LD		E,0
;    	SRL   D               ;seglen=128
;	    RR    E
		inc		hl ;len
		LD		A,(HL)          ;DsmBlock part 2
		add		a,dsm.firstBlock
		call		block34
		ex	af,af'
		jp	block12


;Get GFX location, and set block at page 1
;in: A=areaSignId (=ruinId)
getAreaSign:
		ld		c,a
		ld		b,0

		ld		a,dataType.areasignpacked
		call	getDataTypeIndex
		push	hl
		add		hl,bc
		add		hl,bc
		ld		c,(hl)		;get pointer
		inc		hl
		ld		b,(hl)
		pop		hl
		add		hl,bc

		INC		HL
		LD		A,(HL)          ;DsmBlock
		INC		HL
	    LD		D,(HL)          ;seg
		add		a,dsm.firstblock ;temp
		Call	block12
		LD		E,0
	   	SRL   D               ;seglen=128
	    RR    E
		LD		HL,0x4000
		add		hl,de
		ret

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
;tileClassIds
BackgroundID:		equ 0	; 0 = background
HardForeGroundID:	equ 1	; 1 = hardforeground
LadderId:			equ 2	; 2 = LadderTilesEndAdrEnd
SpikeId:			equ 3	; 3 = spikes/poison
StairLeftId:		equ 4	; 4 = stairsleftup
StairRightId:		equ 5	; 5 = stairsrightup
LavaId:				equ 6	; 6 = lava
WaterId:			equ 7	; 7 = water

tileConversionTable: ;(classid,tilenr) order desc
  DB  HardForeGroundID,ForegroundTilesStart,WaterID,WaterTilesStart,StairRightId,StairRightTilesStart
  DB  StairLeftId,StairLeftTilesStart,LavaId,LavaTilesStart
  DB  SpikeId,SpikeTilesStart,BackgroundID,FreeTilesStart
  DB  ladderID,LadderTilesEndAdrStart,BackgroundID,0

;20231104
;Convert TileNumbers to TileClassIDs
ConvertToMapinRam:
		ld	 de,UnpackedRoomFile.tiledata 
		ld	 hl,roomMap.data	;MapData
;		ld	 a,MapHeight
		ld	 b,MapHeight
		ld	 a,(roommap.width)
		ld	 c,a
.L0:	push bc 
		ld	 b,c
		push hl
.L1:	push hl
		call .convertTile
		pop	 hl

;the following code changes lava and spike tiles, to speed this up, both their values in tileConversionTable can be adjusted instead.
;Lava is turning to hard foreground when lavawalk is obtained
		ld	a,c
		cp	LavaId
		jr	nz,.EndCheckLava
		ld	a,(LavaWalkObtained?)
		or	a
		jr	z,.EndCheckLava
		ld	c,HardForeGroundID
		.EndCheckLava:
		;spikes is turning to background when spikeswalk is obtained
		ld	a,c
		cp	SpikeId
		jr	nz,.EndCheckSpikes
		ld	a,(SpikesWalkObtained?)
		or	a
		jr	z,.EndCheckSpikes
		ld	c,BackgroundID
		.EndCheckSpikes:

		ld	 (HL),c	;store classID
		inc	 hl
		djnz .L1

		ld  (hl),0 ;2 empty tiles on the right side of the map
		inc hl
		ld  (hl),0
		pop	 hl
		ld	 bc,roomMap.numcol
		add	 hl,bc
		pop	bc
		djnz .l0
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
.vdpready:					;check the VDP CommandExecutionStatus to see if the VDP is ready for a new cmd
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


;in: D=ROMblock (+0 and +1), b=vpage, hl=vramAdr
copyGraphicsToScreen:
		ld    a,d                 ;Graphicsblock
		call  block12
  
		ld		a,b
		call	SetVdp_Write	
		ld		hl,$4000	;source adr
		ld    c,$98
		ld    a,64                ;first 128 line, copy 64*256 = $4000 bytes to Vram
		call  .loop1    

		ld    a,d                 ;Graphicsblock+1
		inc   a
		call  block12
  
		ld		hl,$4000
		ld    c,$98
		ld    a,64 ; 42                ;second 84 line, copy 64*256 = $4000 bytes to Vram
		call  .loop1   
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
	and		%0110 0000	; 'F2' and 'F1' key
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


;Copy ROM to VRAM using Direct VDP Access
;in: A=ROMblock, HL=romAdr, DE=DyDx, BC=NyNx
PageToWriteTo: ds  1                    ;0=page 0 or 1, 1=page 2 or 3
AddressToWriteFrom: ds  2
AddressToWriteTo: ds  2
NXAndNY: ds  2
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
		ld    (AddressToWriteFrom),hl
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
		ld		hl,(AddressToWriteTo)           ;set next line to start writing to
		add		hl,de                           ;increase 128 bytes to go to the next line
		ld		(AddressToWriteTo),hl
		ld		a,(PageToWriteTo)             ;0=page 0 or 1, 1=page 2 or 3
		call	SetVdp_Write
		ld		hl,(AddressToWriteFrom)         ;set next line to start writing from
		add		hl,de                           ;increase 128 bytes to go to the next line
		ld		(AddressToWriteFrom),hl
		ld		a,(NXAndNY)
		ld		b,a
		otir
		ret



VramGraphicsPage1And3AlreadyInScreen?: db  0
ScoreBoardAlreadyInScreen?: db  0
AmountOfFramesUntilScreenTurnsOn?:  ds  1
CurrentSongBeingPlayed: db  0
BigEnemyPresentInVramPage3:   db 0      ;1=big statue mouth, 2=huge blob, 3=huge spider
ObjectPresentInVramPage1:     db 0      ;1=omni directional platform

;Table for 015-PlatformRetracting
AppearingBlocksTable: ;dy, dx, appear(1)/dissapear(0). 255 = end
.numrec:	equ 7
.reclen:	equ 6
.data:		ds	.numrec*.reclen ; 7 * 6 ;7 blocks maximum, 6 bytes per block
			ds  .reclen ;   6 ;1 extra block buffer	!!ro:why?
AmountOfAppearingBlocks:  ds  1

OctoPussyBulletSlowDownHandler:   db 0
EnemyHitByPrimairyAttack?:	db	0		;0=hit by secundary attack, 1=hit by primary attack

PlayerIsInWater?:				db	1


;Here we store all variables that are required when saving game
SaveGameVariables:
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

MapObtained?:				db	1



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

;VDP command regs
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
.tiledata:  rb  38*27*2	;no really, but it'll do for now (this is the MAX storage needed)
.object:	rb 256


;roomObjects
roomObject.PushStone: EQU 1
roomObject.PlatformRetracting: EQU 15


;roomobject class byte offsets
roomObjectClassIdOffset: EQU 1 ;tho ID isn't a part of the class, for now we act like it is
roomObjectClass.Enemy.X: EQU 0+roomObjectClassIdOffset
roomObjectClass.Enemy.Y: EQU 1+roomObjectClassIdOffset
roomObjectClass.Enemy.Face: EQU 2+roomObjectClassIdOffset
roomObjectClass.Enemy.Speed: EQU 3+roomObjectClassIdOffset
roomObjectClass.Enemy.numBytes: EQU 4+roomObjectClassIdOffset

roomObjectClass.General.X: EQU 0+roomObjectClassIdOffset
roomObjectClass.General.Y: EQU 1+roomObjectClassIdOffset
roomObjectClass.General.numBytes: EQU 2+roomObjectClassIdOffset

roomObjectClass.EnemySpawn.X: EQU 0+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.Y: EQU 1+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.Face: EQU 2+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.Speed: EQU 3+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.maxNum: EQU 4+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.spawnSpeed: EQU 5+roomObjectClassIdOffset
roomObjectClass.EnemySpawn.numBytes: EQU 6+roomObjectClassIdOffset

roomObjectClass.BreakableWall.X: EQU 0+roomObjectClassIdOffset
roomObjectClass.BreakableWall.Y: EQU 1+roomObjectClassIdOffset
roomObjectClass.BreakableWall.Width: EQU 2+roomObjectClassIdOffset
roomObjectClass.BreakableWall.Height: EQU 3+roomObjectClassIdOffset
roomObjectClass.BreakableWall.Xrestore: EQU 4+roomObjectClassIdOffset
roomObjectClass.BreakableWall.Yrestore: EQU 5+roomObjectClassIdOffset
roomObjectClass.BreakableWall.numBytes:	EQU	6+roomObjectClassIdOffset

roomObjectClass.MovingPlatform.Xstart: EQU 0+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Ystart: EQU 1+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.X: EQU 2+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Y: EQU 3+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Width: EQU 4+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Height: EQU 5+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Face: EQU 6+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Speed: EQU 7+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.Active: EQU 8+roomObjectClassIdOffset
roomObjectClass.MovingPlatform.numBytes: EQU 9+roomObjectClassIdOffset

roomObjectClass.glassBall.ballNumber: EQU 0+roomObjectClassIdOffset
roomObjectClass.glassBall.numBytes: EQU 1+roomObjectClassIdOffset


fill: equ 2
amountofenemies:        equ 22
lenghtenemytable:       equ 27 + fill ;ro:technically, it is not the table, but the tableRecord length. The table itself is numberOfRecords*RecordLength.
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
.nrspritesSimple:       equ 14
.coordinates:           equ 14
.tableRecordPointer:	equ 14
.nrspritesTimes16:      equ 15
.v1:                    equ 16 | .sx:		equ 16
.v2:                    equ 17 
.v3:                    equ 18 | .vMove:	equ 18
.v4:                    equ 19 | .hMove:	equ 19
.v5:                    equ 20 | .SnapPlayer?:	equ 20
.v6:                    equ 21 | .spawnSpeed:	equ 21
.v7:                    equ 22 | .spawnMax:		equ 22
.v8:                    equ 23 | .phase:	equ 23
.v9:                    equ 24
.hit?:                  equ 25 | .v10:	equ 25
.life:                  equ 26 | .v11:	equ 26
.movementpatternsblock: equ 27

endenginepage3variables:  equ $+enginepage3length
org variables

