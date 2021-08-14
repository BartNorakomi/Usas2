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
  ld    a,01        ;is zwart in onze huidige pallet
	ld		($f3e9),a	  ;foreground color 
	ld		($f3ea),a	  ;background color 
	ld		($f3eb),a	  ;border color

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

	xor		a			;init blocks
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a

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

	ld		a,loaderblock
	call	block34			        ;at address $8000 / page 2
  jp    $8000 ;loader.address      ;set loader in page 2 and jp to it

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


; 
; block 00 - 02 engine 
;	
enginepage3:
	include	"enginepage3.asm"	

; 
; block 00 - 02 engine 
;	
engine:
phase	engaddr
	include	"engine.asm"	
endengine:
dephase
enlength:	Equ	$-engine

;
; fill remainder of blocks 00-02
;
	ds		$a000-$,$ff		

;
; block $03 - $04
;
;StarFoxSpritesBlock:  equ   $03
phase	$4000
;StarFoxShipSprite1Color:
;	include "../grapx/shippos1.tcs.gen"	    ;sprite color
;StarFoxShipSprite1Character:
;	include "../grapx/shippos1.tcs.gen"	    ;sprite color
	ds		$8000-$,$ff
dephase

;
; block $05 - $08
;
;Graphicsblock1:  equ   $05
phase	$4000
;  incbin "..\grapx\usasWorld2a.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usasWorld1a.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usas1.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\bomba1.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\Mulana1.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $09 - $0c
;
;Graphicsblock2:  equ   $09
phase	$4000
;  incbin "..\grapx\usasWorld2b.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usasWorld1b.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usas2.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\bomba2.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\Mulana2.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $0d - $10
;
;Graphicsblock3:  equ   $0d
phase	$4000
;  incbin "..\grapx\usasWorld2c.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usasWorld1c.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usas3.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\bomba3.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\Mulana3.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $11 - $14
;
;Graphicsblock4:  equ   $11
phase	$4000
;  incbin "..\grapx\usasWorld2d.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usasWorld1d.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\usas4.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\bomba4.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\Mulana4.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase


;
; block $15 
;
Graphicsblock5:  equ   $15
phase	$4000
  incbin "..\grapx\scoreboard.SC5",7,$2000  ;skip header
;  incbin "..\grapx\bomba4.SC5",7,$6A00  ;skip header
;  incbin "..\grapx\Mulana4.SC5",7,$6A00  ;skip header
	ds		$6000-$,$ff
dephase


;
; block $16 - $17
;
;resetorg:
loaderblock:  equ $16
phase	$8000
	include "loader.asm"
	ds		$c000-$,$ff
dephase
;org resetorg+$4000
;/main loader of the game, this deals with loading the levels/music/sprites etc and initialising game variables

;
; block $18 - $1b
;
;GraphicsBlockTilesW1:  equ   $18
phase	$4000
;  incbin "..\grapx\UsasTilesW1A.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $1c - $1f
;
A01TilesBlock:  equ   $1c
phase	$4000
  incbin "..\grapx\A01.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $20 - &21
;
MapA01Block:  equ   $20
phase	$8000
MapA01_001:   ;EngineType, palette,
  db  1,1
  incbin "..\maps\A01-001.map.pck"  ;469 bytes
MapA01_002:
  db  1,1
  incbin "..\maps\A01-002.map.pck"  ;467 bytes
MapA01_003:
  db  1,1
  incbin "..\maps\A01-003.map.pck"  ;502 bytes
MapA01_004:
  db  2,1
  incbin "..\maps\A01-004.map.pck"  ;467 bytes
MapA01_005:
  db  1,1
  incbin "..\maps\A01-005.map.pck"  ;502 bytes
MapA01_006:
  db  1,1
  incbin "..\maps\A01-006.map.pck"  ;467 bytes
MapA01_007:
  db  1,1
  incbin "..\maps\A01-007.map.pck"  ;502 bytes
MapA01_008:
  db  1,1
  incbin "..\maps\A01-008.map.pck"  ;467 bytes
MapA01_009:
  db  1,1
  incbin "..\maps\A01-009.map.pck"  ;502 bytes
MapA01_010:
  db  1,1
;  incbin "..\maps\A01-010.map.pck"  ;467 bytes
MapA01_011:
  db  1,1
;  incbin "..\maps\A01-011.map.pck"  ;502 bytes
	ds		$c000-$,$ff
dephase

;
; block $22
;
ryucharacterfaceblock:        equ $22
ryuactiontablesblock:         equ $22
phase	$4000
  incbin "..\grapx\character select\character faces\ryucharacterface.dat"
  include "actiontables\ryuactiontables.asm"
	ds		$6000-$,$ff
dephase

;
; block $23 - $24
; block $25 - $26
; block $27 - $28
; block $29 - $2a
;
ryuframelistblock:            equ $23
phase	$8000
  include "..\grapx\ryu\spritesryuPage0\frames.lst" 
	ds		$c000-$,$ff
dephase
phase	$8000
  include "..\grapx\ryu\spritesryuPage1\frames.lst" 
	ds		$c000-$,$ff
dephase
phase	$8000
  include "..\grapx\ryu\spritesryuPage2\frames.lst" 
	ds		$c000-$,$ff
dephase
phase	$8000
  include "..\grapx\ryu\spritesryuPage3\frames.lst" 
	ds		$c000-$,$ff
dephase

;
; block $2b - $2c
; block $2d - $2e
; block $2f - $30
; block $31 - $32
;
ryuspritedatablock:           equ $2b
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage0\frames.dat"
	ds		$4000-$,$ff
dephase
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage1\frames.dat"
	ds		$4000-$,$ff
dephase
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage2\frames.dat"
	ds		$4000-$,$ff
dephase
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage3\frames.dat"
	ds		$4000-$,$ff
dephase


  include "actiontables\actiontableslenghts.asm"


totallenght:	Equ	$-Usas2
	ds		$80000-totallenght
