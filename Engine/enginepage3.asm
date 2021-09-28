phase	$c000
WorldMapData:
WorldMapDataWidth:      equ 3     ;amount of maps 
WorldMapDataMapLenght:  equ 6     ;amount of bytes data per map
              ;block          mapname     enginetype,tiledata,palette
MapA01_001Data: db MapsBlock01 | dw MapA01_001 | db 1,1,1                  | MapA01_002Data: db MapsBlock01 | dw MapA01_002 | db 1,1,1                  | MapA01_003Data: db MapsBlock01 | dw MapA01_003 | db 1,1,1
MapA01_004Data: db MapsBlock01 | dw MapA01_004 | db 1,1,1                  | MapA01_005Data: db MapsBlock01 | dw MapA01_005 | db 1,1,1                  | MapA01_006Data: db MapsBlock01 | dw MapA01_006 | db 1,1,1
MapA01_007Data: db MapsBlock01 | dw MapA01_007 | db 1,1,1                  | MapA01_008Data: db MapsBlock01 | dw MapA01_008 | db 1,1,1                  | MapA01_009Data: db MapsBlock01 | dw MapA01_009 | db 1,1,1

MapB01_001Data: db MapsBlock01 | dw MapB01_001 | db 1,2,2                  | MapB01_002Data: db MapsBlock01 | dw MapB01_002 | db 1,2,2                  | MapB01_003Data: db MapsBlock01 | dw MapB01_003 | db 1,2,2
MapB01_004Data: db MapsBlock01 | dw MapB01_004 | db 1,2,2                  | MapB01_005Data: db MapsBlock01 | dw MapB01_005 | db 1,2,2                  | MapB01_006Data: db MapsBlock01 | dw MapB01_006 | db 1,2,2
MapB01_007Data: db MapsBlock01 | dw MapB01_007 | db 1,2,2                  | MapB01_008Data: db MapsBlock01 | dw MapB01_008 | db 1,2,2                  | MapB01_009Data: db MapsBlock01 | dw MapB01_009 | db 1,2,2
MapB01_010Data: db MapsBlock01 | dw MapB01_010 | db 2,2,2                  | MapB01_011Data: db MapsBlock01 | dw MapB01_011 | db 1,2,2                  | MapB01_012Data: db MapsBlock01 | dw MapB01_012 | db 1,2,2

;WorldMapPointer:  dw  MapA01_001Data
WorldMapPointer:  dw  MapB01_001Data

loadGraphics:

.skipSpriteInit:
  call  screenoff
  ld    ix,(WorldMapPointer)
  call  SetEngineType                 ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
  call  SetTilesInVram                ;copies all the tiles to Vram
  call  SetMapPalette                 ;sets palette
  call  UnpackMapdata                 ;unpacks packed map to $4000 in ram
  call  ConvertToMapinRam             ;convert 16bit tiles into 0=background, 1=hard foreground, 2=ladder, 3=lava. Converts from map in $4000 to MapData in page 3
  call  BuildUpMap                    ;build up the map in Vram to page 1,2,3,4
  call  copyScoreBoard                ;copy scoreboard to page 0 - screen 5 - bottom 40 pixels (scoreboard)
  call  SwapSpatColAndCharTable
  call  initiatebordermaskingsprites
  call  SetInterruptHandler           ;set Lineint and Vblank
  jp    LevelEngine

BuildUpMap:
  ld    hl,$4000
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jp    z,buildupMap38x27
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  cp    2
  jp    z,buildupMap32x27
  ret
  
UnpackMapdata:
;unpack map data
  ld    a,(slot.page2rom)             ;all RAM except page 2
  out   ($a8),a      

  ld    a,(ix+0)                      ;Map block
  call  block34

  ld    l,(ix+1)                      ;map data in rom
  ld    h,(ix+2)
    
  ld    de,$4000
  call  Depack
  ret

SetMapPalette:
;set palette
  ld    a,(ix+5)                      ;palette
  dec   a
  ld    hl,A01Palette
  jr    z,.goSetPalette
  ld    hl,B01Palette
  .goSetPalette:
  call  setpalette
  ret

SetTilesInVram:  
;set tiles in Vram
  ld    a,(ix+4)                      ;tile data
  dec   a
  ld    d,A01TilesBlock
  jr    z,.settiles
  ld    d,B01TilesBlock

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

.Engine256x216:
  ld    de,32
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,-29*8
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de

  ld    a,32
  ld    (ConvertToMapinRam.loop2+1),a

  ;if engine type = 256x216 and x Cles = 34*8, then move cles 6 tiles to the left, because this Engine type has a screen width of 6 tiles less
  ld    hl,(ClesX)
  ld    de,34*8
  xor   a
  sbc   hl,de
  ret   nz
  ld    hl,28*8
  ld    (ClesX),hl
  xor   a
  ld    (CameraX),a
  ret

.Engine304x216:                        ;
  ld    de,38
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,-35*8          ;-35*8
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de

  ld    a,38
  ld    (ConvertToMapinRam.loop2+1),a
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
  
MapData:
  ds    38 * 27           ;a map is 38 * 27 tiles big  

ConvertToMapinRam:
;tiles 0 - 251 are hard foreground
;tiles 252 - 253 are ladder tiles
;tiles 254 - 255 are lava
;tiles 256 - > are background

  ld    hl,$4000
  ld    iy,MapData

  ld    c,27
.loop2:
  ld    b,32 ;32 ;38
.loop:
  push  hl
  call  .convertTile
  pop   hl
  inc   hl
  inc   hl
  inc   iy
  djnz  .loop
  
  dec   c
  jp    nz,.loop2
  ret

.convertTile:
  ;get tilenr in de
  ld    e,(hl)              ;each tile is 16 bit. bit 0-4 (value between 0-31) give us the x value if we multiply by 8
  inc   hl
  ld    d,(hl)
  inc   hl                  ;next tile in tilemap
  
  ;set sx and sy of this tile
  dec   de
  
  ld    hl,251
  xor   a
  sbc   hl,de
  jp    nc,.hardforeground
  ld    de,2
  add   hl,de
  jp    c,.laddertiles
  ld    de,2
  add   hl,de
  jp    c,.lava
    
.background:
  ld    (iy),0
  ret

.hardforeground:
  ld    (iy),1
  ret

.laddertiles:
  ld    (iy),2
  ret

.lava:
  ld    (iy),3
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

ld b,15
otir
ret

;	dw    $a3ed,$a3ed,$a3ed,$a3ed
;	dw    $a3ed,$a3ed,$a3ed,$a3ed
;	dw    $a3ed,$a3ed,$a3ed,$a3ed
;	dw    $a3ed,$a3ed,$a3ed
;  ret

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

clessprite_graphics:
include "../sprites/cles.tgs.gen"
clessprite_color:
include "../sprites/cles.tcs.gen"


initiatebordermaskingsprites:
	ld		c,$98                 ;out port

	ld		de,(sprchatableaddress)		      ;sprite character table in VRAM ($17800)
  call  .bordermaskspritecharacter
	ld		de,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
  call  .bordermaskspritecharacter
	ld		de,(sprcoltableaddress)		      ;sprite color table in VRAM ($17400)
  call  .bordermaskspritecolor
	ld		de,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
  call  .bordermaskspritecolor
  ret

.bordermaskspritecharacter:
;put border masking sprites character
  ld    hl,0 * 32             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write
  
  ld    b,22 ;32 ;22                  ;22 sprites

.loop1:
  push  bc
  ld    hl,bordermasksprite_graphics
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
  pop   bc
  djnz  .loop1
;/put border masking sprites character


  ld    hl,clessprite_graphics
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)

  ret
  
  
.bordermaskspritecolor:
;put border masking sprites color
  ld    hl,0 * 16             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write

  ld    b,11 ;16                  ;first 16 sprites
.loop2:
  push  bc
  ld    hl,bordermasksprite_color_withCEbit
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)
  pop   bc
  djnz  .loop2

  ld    b,11 ;16                  ;next 16 sprites
.loop3:
  push  bc
  ld    hl,bordermasksprite_color
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)
  pop   bc
  djnz  .loop3
;/put border masking sprites color


  ld    hl,clessprite_color
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)
	call	outix16               ;1 sprites (1 * 16 = 16 bytes)


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
  ld    a,42                ;second 84 line, copy 64*256 = $4000 bytes to Vram
  ld    b,0
      
  call  .loop1   

  ;this last part is to fill the screen with a repetition
	ld		hl,$4000
  ld    c,$98
  ld    a,22                ;second 84 line, copy 64*256 = $4000 bytes to Vram
  ld    b,0
      
  call  .loop1   
  ret

.loop1:
  otir
  dec   a
  jp    nz,.loop1
  ret

copyScoreBoard:
  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a          

  ld    hl,$6C00            ;page 0 - screen 5 - bottom 40 pixels (scoreboard)
  ld    a,Graphicsblock5    ;block to copy from
  call  block12
  
	xor   a
	call	SetVdp_Write	
	ld		hl,$4000
  ld    c,$98
  ld    a,20                ;first 40 lines, copy 64*256 = $4000 bytes to Vram
  ld    b,0
  jp    copyGraphicsToScreen.loop1    

A01Palette:
  incbin "..\grapx\A01palette.PL" ;file palette 
B01Palette:
  incbin "..\grapx\B01palette.PL" ;file palette 
;  incbin "..\grapx\UsasTilesW1Apalette" ;file palette 
;  incbin "..\grapx\usasWorld2palette" ;file palette 
;  incbin "..\grapx\usasWorld1palette" ;file palette 
;  incbin "..\grapx\usaspalette" ;file palette 
;  incbin "..\grapx\bombapalette" ;file palette 
;  incbin "..\grapx\mulanapalette" ;file palette 

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
	nop
	out     ($99),a
	ld      a,h           ;set bits 8-14
	or      64            ; + write access
	ei
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

	ld		a,(NewPrContr)
	ld		(NewPrContrOld),a
	
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
copytype:                   equ   14
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

endenginepage3variables:  equ $+enginepage3length
org variables

