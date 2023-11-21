		fname	"Usas2.rom"
	org		$4000

Usas2:
;
; StarFox - ROM version
;
; Written by: TNI Team
;
	dw		"AB",init,0,0,0,0,0,0
;
; this is one-time only... can be overwritten with game stuff after it's done
;

RomBlockSize: equ 16*1024

memInit:	
	phase	$c000
;
initMem:	
	call	whereAmI	; Slot of this ROM
	ld		(romSlot),a
	ld		hl,$0000
	call	findRam		; Slot of RAM in page 0
	ld		(page0ram),a
	ld		hl,$4000
	call	findRam		; Slot of RAM in page 1
	ld		(page1ram),a
	ld		hl,$8000
	call	findRam		; Slot of RAM in page 2
	ld		(page2ram),a
	
	;ld	a,(page2ram)
	and		$03
	add		a,a
	add		a,a
	ld		b,a
	ld		a,(page1ram)
	and		$03
	or		b
	add		a,a
	add		a,a
	ld		b,a
	ld		a,(page0ram)
	and		$03
	or		b
	ld		b,a
	call	$138
	and		$c0
	or		b
	ld		b,a
	ld		(slot.ram),a
	
	and		$f3
	ld		c,a
	ld		a,(romSlot)
	and		$03
	add		a,a
	add		a,a
	or		c
	ld		(slot.page1rom),a
	
	ld		a,b
	and		$cf
	ld		c,a
	ld		a,(romSlot)
	and		$03
	add		a,a
	add		a,a
	add		a,a
	add		a,a
	or		c
	ld		(slot.page2rom),a
	
	ld		a,b
	and		$c3
	ld		c,a
	ld		a,(romSlot)
	and		$03
	ld		b,a
	add		a,a
	add		a,a
	or		b
	add		a,a
	add		a,a
	or		c
	ld		(slot.page12rom),a
	
	ld		a,(romSlot)
	ld		h,$80
	call	$24
	
	ld		a,(page1ram)
	ld		h,$40
	call	$24
	
	ld		a,(romSlot)
	ld		h,$40
	call	$24
	
	ld		b,3
	ld		de,.enaRam
	ld		hl,$3ffd
	push	hl
.ramOn:		
	push	bc
	push	de
	push	hl
	ld		a,(de)
	ld		e,a
	ld		a,(page0ram)
	call	$14
	pop		hl
	pop		de
	pop		bc
	inc		de
	inc		hl
	djnz	.ramOn
	ld		a,(page0ram)
	push	af
	pop		iy
	pop		ix
	ld		(tempStack),sp
	jp		$1c

.done:		
	ld		sp,(tempStack)
	ret

.enaRam:	
	jp		.done

searchSlot:		db	0
searchAddress:	dw	0
tempStack:		dw	0
page0ram:		db	0
page1ram:		db	0
page2ram:		db	0
romSlot:		db	0
;
; Out: A = slot of this ROM (E000SSPP)
;
whereAmI:	
	call	$138
	rrca
	rrca
	and		$03
	ld		c,a
	ld		b,0
	ld		hl,$fcc1
	add		hl,bc
	or		(hl)
	ld		c,a
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	ld		a,(hl)
	and		$0c
	or		c
	ret
;
; In: HL = Address in page to search RAM
; Out: A = RAM slot of the page
;
findRam:	
	ld		bc,4 *256+ 0
	ld		(searchAddress),hl
	ld		hl,$fcc1
.primary.loop:	
	push	bc
	push	hl
	ld		a,(hl)
	bit		7,a
	jr		nz,.secondary
	ld		a,c
	call	.check
.primary.next:	
	pop		hl
	pop		bc
	ld		a,(searchSlot)
	ret		c
	inc		hl
	inc		c
	djnz	.primary.loop
	ld		a,-1			; should normally never occur
	ld		(searchSlot),a
	ret

.secondary:	
	and		$80
	or		c
	ld		b,4
.sec.loop:	
	push	bc
	call	.check
	pop		bc
	jr		c,.primary.next
	add		a,4
	djnz	.sec.loop
	jr		.primary.next

.check:		
	ld		(searchSlot),a
	call	.read
	ld		b,a
	cpl
	ld		c,a
	call	.write
	call	.read
	cp		c
	jr		nz,.noram
	cpl
	call	.write
	call	.read
	cp		b
	jr		nz,.noram
	ld		a,(searchSlot)
	scf
	ret
.noram:		
	ld		a,(searchSlot)
	or		a
	ret

.read:		
	push	bc
	push	hl
	ld		a,(searchSlot)
	ld		hl,(searchAddress)
	call	$0c
	pop		hl
	pop		bc
	ret

.write:		
	push	bc
	push	hl
	ld		e,a
	ld		a,(searchSlot)
	ld		hl,(searchAddress)
	call	$14
	pop		hl
	pop		bc
	ret

initMem.length:	equ	$-initMem
		dephase
;
; end of one-time only code...
;

;
init:		
  ld    a,15        ;is zwart in onze huidige pallet
	ld		($f3e9),a	  ;foreground color 
	ld		($f3ea),a	  ;background color 
	ld		($f3eb),a	  ;border color

  ld    a,15        ;start write to this palette color (15)
  di
	out		($99),a
	ld		a,16+128
	out		($99),a
	xor		a
	out		($9a),a
  ei
	out		($9a),a

	ld 		a,5			    ;switch to screen 5
	call 	$5f

	ld		a,(VDP_8+1)	
	and		%1111 1101	;set 60 hertz
	or		%1000 0000	;screen height 212
	ld		(VDP_8+1),a
	di
	out		($99),a
	ld		a,9+128
	ei
	out		($99),a

;screenmode transparancy (i think this is about usage of color 0 in sprites)
	ld		a,(vdp_8)
	or		32				  ;transparant mode off
;	and		223				  ;tranparant mode on
	ld		(vdp_8),a
	di
	out		($99),a
	ld		a,8+128
	ei
	out		($99),a

  xor   a
	ld		(vdp_8+15),a
	di
	out		($99),a
	ld		a,23+128
	ei
	out		($99),a

	di
	im		1
	ld		bc,initMem.length
	ld		de,initMem
	ld		hl,memInit
	ldir
	call	initMem

;	xor		a			;init blocks
;	ld		(memblocks.1),a
;	ld		($5000),a
;	inc		a
;	ld		(memblocks.2),a
;	ld		($7000),a
;	inc		a
;	ld		(memblocks.3),a
;	ld		($9000),a
;	inc		a
;	ld		(memblocks.4),a
;	ld		($b000),a

  xor   a     ;init blocks ascii16
	ld		(memblocks.1),a
	ld		($6000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a


; load BIOS / engine , load startup
	ld		hl,tempisr
	ld		de,$38
	ld		bc,6
	ldir

;SpriteInitialize:
	ld		a,(vdp_0+1)
	or		2			;sprites 16*16
	ld		(vdp_0+1),a
	di
	out		($99),a
	ld		a,1+128
	ei
	out		($99),a
;/SpriteInitialize:

	ld		hl,engine
	ld		de,engaddr
	ld		bc,enlength	        ;load engine
	ldir

	ld		hl,enginepage3
	ld		de,enginepage3addr
	ld		bc,enginepage3length	    ;load enginepage3
	ldir

;  call  enablesupermarioworldinterrupt

;	ld		a,loaderblock
;	call	block34			        ;at address $8000 / page 2
;  jp    $8000 ;loader.address      ;set loader in page 2 and jp to it


if MusicOn?
  call  VGMRePlay
endif
if LogoOn?
  jp    PlayLogo
endif
  jp    loadGraphics

		; set temp ISR
tempisr:	
	push	af
	in		a,($99)             ;check and acknowledge vblank int (ei0 is set)
	pop		af
	ei	
	ret

;enablesupermarioworldinterrupt:
;  di
;  ld    hl,InterruptHandler ;set new normal interrupt
;  ld    ($38+1),hl
;  ld    a,$c3
;  ld    ($38),a
 
;  ld    a,(vdp_0)           ;set ei1
;  or    16                  ;ei1 checks for lineint and vblankint
;  ld    (vdp_0),a           ;ei0 (which is default at boot) only checks vblankint
;  out   ($99),a
;  ld    a,128
;  ei
;  out   ($99),a
;  ret



; ROM block 00-01: boot, enginepage3, enginepage0
enginepage3:				include	"enginepage3.asm"
enginepage3RomEndAddress:	EQU $-1-$4000

engine:
;phase	engaddr	;moved phasing to the engine.asm source file itself, where it belongs
							include	"engine.asm"	
;endengine:
;dephase
;enlength:					Equ	$-engine
enginepage0RomEndAddress: 	equ $-1-$4000
							ds	2*$4000 - $ and $3fff,$ff		; fill remainder of blocks 00-01

; ROM block 02-02: f1menu
F1Menublock:				equ $02
f1MenuRomAddress:			equ $-$4000
phase	$4000	;should be in f1menu.asm source(!)
							include	"F1Menu.asm"	
endF1MenuRoutine:
F1MenuRoutinelength:		Equ	$-F1MenuRoutine
;							ds	$8000-$,$ff	;fill remainder of this block		
dephase
f1MenuRomEndAddress:	equ $-1-$4000
							ds	1*$4000 - $ and $3fff,$ff	;Fill remainder of this block

; ROM block 03-03: loader
loaderRomStartAddress:		equ $-$4000
Loaderblock:  				equ $03
phase	$4000	;should be in loader.asm source (!)
StartLoaderRoutine:			include	"loader.asm"	
endLoaderRoutine:
LoaderRoutinelength:		Equ	$-StartLoaderRoutine
;							ds	$8000-$,$ff		
dephase
loaderRomEndAddress:		equ $-1-$4000
							ds	1*$4000 - $ and $3fff,$ff	;Fill remainder of this block

; block $4
PlayerMovementRoutinesBlock:  equ   $4
phase	$4000
  include "PlayerMovementRoutines.asm" | endPlayerMovementRoutines:  
	ds		$8000-$,$ff
dephase

; block $5
movementpatterns1block:  equ   $5
movepatblo1:  equ   $5
phase	$8000
  include "MovementPatterns1.asm"
	ds		$c000-$,$ff
dephase

; block $6
MovementPatternsFixedPage1block:  equ   $6
phase	$4000
  include "MovementPatternsFixedPage1.asm"
	ds		$8000-$,$ff
dephase

; block $7
movementpatterns2block:  equ   $7
movepatblo2:  equ   $7
phase	$8000
  include "MovementPatterns2.asm"
	ds		$c000-$,$ff
dephase

; block $08
teamNXTlogoblock:  equ $8
phase	$8000
	include "teamNXTlogo.asm"
	ds		$c000-$,$ff
dephase

; block $09                   (worldmap matrix)
RomAddressWorldMapMatrix:
WorldMapDataCopiedToRamBlock:  equ   $9
phase	$8000
  ;include "WorldMapDataCopiedToRam.asm"
  	incbin "WorldMapDataCopiedToRam.dat"
	ds		$c000-$,$ff
dephase

; block $0a - $5e             (music)
usas2repBlock:  equ   $0a
phase	$0000
  incbin "usas2.rep"
	ds		$154000-$,$ff
dephase

; block $5f
phase	$8000
MapsBlockBT01:  equ   $5f | MapBT01: incbin "..\maps\BT01.map.pck"  | include "..\maps\mapdata\BT01.asm"  
MapsBlockBT08:  equ   $5f | MapBT08: incbin "..\maps\BT08.map.pck"  | include "..\maps\mapdata\BT08.asm"  
MapsBlockBT12:  equ   $5f | MapBT12: incbin "..\maps\BT12.map.pck"  | include "..\maps\mapdata\BT12.asm"  
MapsBlockBT13:  equ   $5f | MapBT13: incbin "..\maps\BT13.map.pck"  | include "..\maps\mapdata\BT13.asm"  
MapsBlockBT16:  equ   $5f | MapBT16: incbin "..\maps\BT16.map.pck"  | include "..\maps\mapdata\BT16.asm"  
MapsBlockBT20:  equ   $5f | MapBT20: incbin "..\maps\BT20.map.pck"  | include "..\maps\mapdata\BT20.asm"  
MapsBlockBT21:  equ   $5f | MapBT21: incbin "..\maps\BT21.map.pck"  | include "..\maps\mapdata\BT21.asm"  
MapsBlockBT22:  equ   $5f | MapBT22: incbin "..\maps\BT22.map.pck"  | include "..\maps\mapdata\BT22.asm"  
MapsBlockBT23:  equ   $5f | MapBT23: incbin "..\maps\BT23.map.pck"  | include "..\maps\mapdata\BT23.asm"  
MapsBlockBT24:  equ   $5f | MapBT24: incbin "..\maps\BT24.map.pck"  | include "..\maps\mapdata\BT24.asm"  
MapsBlockBT26:  equ   $5f | MapBT26: incbin "..\maps\BT26.map.pck"  | include "..\maps\mapdata\BT26.asm"  
MapsBlockBT27:  equ   $5f | MapBT27: incbin "..\maps\BT27.map.pck"  | include "..\maps\mapdata\BT27.asm"  
MapsBlockBT28:  equ   $5f | MapBT28: incbin "..\maps\BT28.map.pck"  | include "..\maps\mapdata\BT28.asm"  
MapsBlockBT30:  equ   $5f | MapBT30: incbin "..\maps\BT30.map.pck"  | include "..\maps\mapdata\BT30.asm"  
MapsBlockBT31:  equ   $5f | MapBT31: incbin "..\maps\BT31.map.pck"  | include "..\maps\mapdata\BT31.asm"  
MapsBlockBT33:  equ   $5f | MapBT33: incbin "..\maps\BT33.map.pck"  | include "..\maps\mapdata\BT33.asm"  
MapsBlockBT34:  equ   $5f | MapBT34: incbin "..\maps\BT34.map.pck"  | include "..\maps\mapdata\BT34.asm"  
MapsBlockBT37:  equ   $5f | MapBT37: incbin "..\maps\BT37.map.pck"  | include "..\maps\mapdata\BT37.asm"  
MapsBlockBT38:  equ   $5f | MapBT38: incbin "..\maps\BT38.map.pck"  | include "..\maps\mapdata\BT38.asm"  
MapsBlockBT39:  equ   $5f | MapBT39: incbin "..\maps\BT39.map.pck"  | include "..\maps\mapdata\BT39.asm"  
MapsBlockBT40:  equ   $5f | MapBT40: incbin "..\maps\BT40.map.pck"  | include "..\maps\mapdata\BT40.asm"  
MapsBlockBT45:  equ   $5f | MapBT45: incbin "..\maps\BT45.map.pck"  | include "..\maps\mapdata\BT45.asm"  
MapsBlockBT49:  equ   $5f | MapBT49: incbin "..\maps\BT49.map.pck"  | include "..\maps\mapdata\BT49.asm"  
MapsBlockBT50:  equ   $5f | MapBT50: incbin "..\maps\BT50.map.pck"  | include "..\maps\mapdata\BT50.asm"  
	ds		$c000-$,$ff
dephase

; block $60 - $7b             (sc5 tilesheets)
GraphicsSc5DataStartBlock:  equ $60
GraphicsSc5DataEndBlock:    equ GraphicsSc5DataStartBlock+$1b
include "GraphicsSc5Data.asm"

; block $7c - $8f             (hardware sprites)
SpriteDataStartBlock: equ $7c
SpriteDataEndBlock:   equ SpriteDataStartBlock+$13
include "SpriteData.asm"

; block $90 - $B8             (software sprites)
BossSpritesDataStartBlock:  equ $90
BossSpritesDataEndBlock:  equ BossSpritesDataStartBlock+$28
include "BossSpriteData.asm"

totallenght:	Equ	$-Usas2
	ds		(8*$80000)-totallenght
