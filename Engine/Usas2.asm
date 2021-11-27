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
  ld    a,15        ;is zwart in onze huidige pallet
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

;	ld		a,loaderblock
;	call	block34			        ;at address $8000 / page 2
;  jp    $8000 ;loader.address      ;set loader in page 2 and jp to it

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
scoreboard:
  incbin "..\grapx\scoreboard.SC5",7,$1000  ;skip header
itemsKarniMata:
  incbin "..\grapx\itemsKarniMata.SC5",7,$1000  ;skip header
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
B01TilesBlock:  equ   $18
phase	$4000
  incbin "..\grapx\B01.SC5",7,$6A00  ;skip header
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
MapsBlock01:  equ   $20
phase	$8000
MapA01_001:   ;EngineType, graphics, palette,
  incbin "..\maps\A01-001.map.pck"  | .amountofobjects: db  14
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks13Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks14Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks15Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object4: db 1,        1,     007,06*8,12*8,12*8,0,     00,       00,+00,+00,+00,+00,+00,+07,+00|dw PuzzleSwitchTable2|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object5: db 1,        1,     006,13*8,10*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch15On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,13*8,12*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch16On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,13*8,24*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch19On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object08:db 1,        1,     006,13*8,26*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch20On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

.object09:db 1,        1,     006,19*8,10*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch21On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object10:db 1,        1,     006,19*8,26*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch26On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

.object11:db 1,        1,     006,25*8,10*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch27On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object12:db 1,        1,     006,25*8,12*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch28On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object13:db 1,        1,     006,25*8,24*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch31On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object14:db 1,        1,     006,25*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch32On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_002:
  incbin "..\maps\A01-002.map.pck"  | .amountofobjects: db  7
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks1Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks2Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks3Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,19*8,06*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch1On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,19*8,12*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,19*8,18*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch3On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch4On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_003:
  incbin "..\maps\A01-003.map.pck"  | .amountofobjects: db  7
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks19Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks20Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 0,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,14*8,11*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch38On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,19*8,26*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch40On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,25*8,26*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch41On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object7: db 1,        1,     007,08*8,14*8,14*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      



MapA01_004:
  incbin "..\maps\A01-004.map.pck"  | .amountofobjects: db  2
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object1: db 1,        1,     007,03*8,07*8,07*8,0,     00,       00,+00,+00,+00,+00,+00,+10,+00|dw PuzzleSwitchTable1|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object2: db 1,        1,     006,14*8,13*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch14On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        1,     007,14*8,15*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_005:
  incbin "..\maps\A01-005.map.pck"  | .amountofobjects: db  8
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks4Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks5Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks6Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,18*8,08*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch5On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,16*8,14*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch6On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,16*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch7On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,17*8,30*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch8On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      


MapA01_006:
  incbin "..\maps\A01-006.map.pck"  | .amountofobjects: db  8
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks21Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks22Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 0,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,12*8,06*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch42On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,12*8,16*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch43On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch44On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,25*8,15*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch45On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object8: db 1,        1,     007,08*8,18*8,18*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
  
  
MapA01_007:
  incbin "..\maps\A01-007.map.pck"  | .amountofobjects: db  9
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks16Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks17Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks18Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,25*8,06*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch33On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,25*8,14*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch34On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,25*8,18*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch35On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,25*8,22*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch36On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object8: db 1,        1,     006,25*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch37On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object9: db 1,        1,     007,07*8,15*8,15*8,0,     00,       00,+00,+00,+00,+00,+00,+04,+00|dw PuzzleSwitchTable3|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_008:
  incbin "..\maps\A01-008.map.pck"  | .amountofobjects: db  8
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        1,     005,000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks7Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     005,000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks8Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     005,000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks9Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        1,     006,13*8,06*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch9On? ,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        1,     006,13*8,10*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch10On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        1,     006,13*8,16*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch11On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        1,     006,19*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch12On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object8: db 1,        1,     006,19*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch13On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_009:
  incbin "..\maps\A01-009.map.pck"  | .amountofobjects: db  1
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object1: db 1,        1,     007,10*8,12*8,12*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapB01_001:
  incbin "..\maps\b01-001.map.pck"  | .amountofobjects: db  3
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;                                                                 repeat point y   x snap
.object1: db 2,        1,     002,048,072,48,48,        00,       00,+00,+00,+00,+00,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 2,        1,     003,100,100,48,48,        00,       00,+00,+00,+00,+00, 00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 2,        1,     004,030,104,48,48,        00,       00,+00,+00,+00,+00, 00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapB01_002:
  incbin "..\maps\b01-002.map.pck"  | .amountofobjects: db  3
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             
.object1: db 1,        1,     001,076,150,16,16|dw CleanOb1|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     001,090,100,16,16|dw CleanOb2|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     001,120,050,16,16|dw CleanOb3|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
  
MapB01_003:
  incbin "..\maps\b01-003.map.pck"  | .amountofobjects: db  0
MapB01_004:
  incbin "..\maps\b01-004.map.pck"  | .amountofobjects: db  3
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             
.object1: db 1,        1,     001,076,150,16,16|dw CleanOb1|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     001,090,100,16,16|dw CleanOb2|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        1,     001,120,120,16,16|dw CleanOb3|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_005:
  incbin "..\maps\b01-005.map.pck"  | .amountofobjects: db  0
MapB01_006:
  incbin "..\maps\b01-006.map.pck" | .amountofobjects: db  1
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
.object1: db 1,        1,     000,100,100,16,32|dw CleanOb1|      db +32,+00,+01,+00,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_007:
  incbin "..\maps\b01-007.map.pck"  | .amountofobjects: db  1
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
.object1: db 1,        1,     001,120,050,16,32|dw CleanOb1|      db +32,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_008:
  incbin "..\maps\b01-008.map.pck"  | .amountofobjects: db  1
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
.object1: db 1,        1,     001,150,050,16,32|dw CleanOb1|      db +32,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_009:
  incbin "..\maps\b01-009.map.pck"  | .amountofobjects: db  2
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             
.object1: db 1,        1,     001,076,150,16,16|dw CleanOb1|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        1,     001,090,100,16,16|dw CleanOb2|      db +64,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_010:
  incbin "..\maps\b01-010.map.pck"  | .amountofobjects: db  0
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7                                     ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;

MapB01_011:
  incbin "..\maps\b01-011.map.pck"  | .amountofobjects: db  1
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
.object1: db 1,        1,     001,150,150,20,32|dw CleanOb1|      db +64,+00,+00,-01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
MapB01_012:
  incbin "..\maps\b01-012.map.pck"  | .amountofobjects: db  1
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, offsettab                                             ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
.object1: db 1,        1,     001,180,050,16,32|dw CleanOb1|      db +32,+00,+00,+01,+00,16,00,16, 16,4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
	ds		$c000-$,$ff
dephase

;
; block $22
;
ryucharacterfaceblock:        equ $22
ryuactiontablesblock:         equ $22
phase	$4000
  incbin "..\grapx\character select\character faces\ryucharacterface.dat"
;  include "actiontables\ryuactiontables.asm"
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

;
; block $33 - $34
;
MapsBlock02:  equ   $33
phase	$8000
	ds		$c000-$,$ff
dephase

;Player's sprite positions 
;
; block $35 - $38
;
PlayerSpritesBlock:      equ   $35  
phase	$4000
PlayerSpriteData_Char_RightStand:           include "..\sprites\secretsofgrindea\RightStand.tgs.gen"	;x offset top, x offset bottom
PlayerSpriteData_Colo_RightStand:           include "..\sprites\secretsofgrindea\RightStand.tcs.gen"	| db +0-8,+0
PlayerSpriteData_Char_LeftStand:           	include "..\sprites\secretsofgrindea\LeftStand.tgs.gen"	    
PlayerSpriteData_Colo_LeftStand:           	include "..\sprites\secretsofgrindea\LeftStand.tcs.gen"		| db +0-8,+0   

PlayerSpriteData_Char_RightRun7:            include "..\sprites\secretsofgrindea\RightRun7.tgs.gen"	  
PlayerSpriteData_Colo_RightRun7:            include "..\sprites\secretsofgrindea\RightRun7.tcs.gen"	  | db +0-8,-1
PlayerSpriteData_Char_RightRun8:            include "..\sprites\secretsofgrindea\RightRun8.tgs.gen"	  
PlayerSpriteData_Colo_RightRun8:            include "..\sprites\secretsofgrindea\RightRun8.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightRun9:            include "..\sprites\secretsofgrindea\RightRun9.tgs.gen"	  
PlayerSpriteData_Colo_RightRun9:            include "..\sprites\secretsofgrindea\RightRun9.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightRun10:           include "..\sprites\secretsofgrindea\RightRun10.tgs.gen"	  
PlayerSpriteData_Colo_RightRun10:           include "..\sprites\secretsofgrindea\RightRun10.tcs.gen"	| db +0-8,-2  
PlayerSpriteData_Char_RightRun1:            include "..\sprites\secretsofgrindea\RightRun1.tgs.gen"	  
PlayerSpriteData_Colo_RightRun1:            include "..\sprites\secretsofgrindea\RightRun1.tcs.gen"	  | db +0-8,-1
PlayerSpriteData_Char_RightRun2:            include "..\sprites\secretsofgrindea\RightRun2.tgs.gen"	  
PlayerSpriteData_Colo_RightRun2:            include "..\sprites\secretsofgrindea\RightRun2.tcs.gen"	  | db +0-8,-1
PlayerSpriteData_Char_RightRun3:            include "..\sprites\secretsofgrindea\RightRun3.tgs.gen"	  
PlayerSpriteData_Colo_RightRun3:            include "..\sprites\secretsofgrindea\RightRun3.tcs.gen"	  | db +0-8,-1
PlayerSpriteData_Char_RightRun4:            include "..\sprites\secretsofgrindea\RightRun4.tgs.gen"	  
PlayerSpriteData_Colo_RightRun4:            include "..\sprites\secretsofgrindea\RightRun4.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightRun5:            include "..\sprites\secretsofgrindea\RightRun5.tgs.gen"	  
PlayerSpriteData_Colo_RightRun5:            include "..\sprites\secretsofgrindea\RightRun5.tcs.gen"	  | db +0-8,-3
PlayerSpriteData_Char_RightRun6:            include "..\sprites\secretsofgrindea\RightRun6.tgs.gen"	  
PlayerSpriteData_Colo_RightRun6:            include "..\sprites\secretsofgrindea\RightRun6.tcs.gen"	  | db +0-8,-1

PlayerSpriteData_Char_LeftRun2:             include "..\sprites\secretsofgrindea\LeftRun2.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun2:             include "..\sprites\secretsofgrindea\LeftRun2.tcs.gen"	  | db +0-8,+1
PlayerSpriteData_Char_LeftRun3:             include "..\sprites\secretsofgrindea\LeftRun3.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun3:             include "..\sprites\secretsofgrindea\LeftRun3.tcs.gen"	  | db +0-8,+1
PlayerSpriteData_Char_LeftRun4:             include "..\sprites\secretsofgrindea\LeftRun4.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun4:             include "..\sprites\secretsofgrindea\LeftRun4.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftRun5:             include "..\sprites\secretsofgrindea\LeftRun5.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun5:             include "..\sprites\secretsofgrindea\LeftRun5.tcs.gen"	  | db +0-8,+3
PlayerSpriteData_Char_LeftRun6:             include "..\sprites\secretsofgrindea\LeftRun6.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun6:             include "..\sprites\secretsofgrindea\LeftRun6.tcs.gen"	  | db +0-8,+1
PlayerSpriteData_Char_LeftRun7:             include "..\sprites\secretsofgrindea\LeftRun7.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun7:             include "..\sprites\secretsofgrindea\LeftRun7.tcs.gen"	  | db +0-8,+1
PlayerSpriteData_Char_LeftRun8:             include "..\sprites\secretsofgrindea\LeftRun8.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun8:             include "..\sprites\secretsofgrindea\LeftRun8.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftRun9:             include "..\sprites\secretsofgrindea\LeftRun9.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun9:             include "..\sprites\secretsofgrindea\LeftRun9.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftRun10:            include "..\sprites\secretsofgrindea\LeftRun10.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun10:            include "..\sprites\secretsofgrindea\LeftRun10.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftRun1:             include "..\sprites\secretsofgrindea\LeftRun1.tgs.gen"	  
PlayerSpriteData_Colo_LeftRun1:             include "..\sprites\secretsofgrindea\LeftRun1.tcs.gen"	  | db +0-8,+1

PlayerSpriteData_Char_Climbing1:            include "..\sprites\secretsofgrindea\Climbing1.tgs.gen"	  
PlayerSpriteData_Colo_Climbing1:            include "..\sprites\secretsofgrindea\Climbing1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing2:            include "..\sprites\secretsofgrindea\Climbing2.tgs.gen"	  
PlayerSpriteData_Colo_Climbing2:            include "..\sprites\secretsofgrindea\Climbing2.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing3:            include "..\sprites\secretsofgrindea\Climbing3.tgs.gen"	  
PlayerSpriteData_Colo_Climbing3:            include "..\sprites\secretsofgrindea\Climbing3.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing4:            include "..\sprites\secretsofgrindea\Climbing4.tgs.gen"	  
PlayerSpriteData_Colo_Climbing4:            include "..\sprites\secretsofgrindea\Climbing4.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing5:            include "..\sprites\secretsofgrindea\Climbing5.tgs.gen"	  
PlayerSpriteData_Colo_Climbing5:            include "..\sprites\secretsofgrindea\Climbing5.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing6:            include "..\sprites\secretsofgrindea\Climbing6.tgs.gen"	  
PlayerSpriteData_Colo_Climbing6:            include "..\sprites\secretsofgrindea\Climbing6.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing7:            include "..\sprites\secretsofgrindea\Climbing7.tgs.gen"	  
PlayerSpriteData_Colo_Climbing7:            include "..\sprites\secretsofgrindea\Climbing7.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing8:            include "..\sprites\secretsofgrindea\Climbing8.tgs.gen"	  
PlayerSpriteData_Colo_Climbing8:            include "..\sprites\secretsofgrindea\Climbing8.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing9:            include "..\sprites\secretsofgrindea\Climbing9.tgs.gen"	  
PlayerSpriteData_Colo_Climbing9:            include "..\sprites\secretsofgrindea\Climbing9.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_Climbing10:           include "..\sprites\secretsofgrindea\Climbing10.tgs.gen"	  
PlayerSpriteData_Colo_Climbing10:           include "..\sprites\secretsofgrindea\Climbing10.tcs.gen"	| db +0-8,+0
PlayerSpriteData_Char_Climbing11:           include "..\sprites\secretsofgrindea\Climbing11.tgs.gen"	  
PlayerSpriteData_Colo_Climbing11:           include "..\sprites\secretsofgrindea\Climbing11.tcs.gen"	| db +0-8,+0
PlayerSpriteData_Char_Climbing12:           include "..\sprites\secretsofgrindea\Climbing12.tgs.gen"	  
PlayerSpriteData_Colo_Climbing12:           include "..\sprites\secretsofgrindea\Climbing12.tcs.gen"	| db +0-8,+0
PlayerSpriteData_Char_Climbing13:           include "..\sprites\secretsofgrindea\Climbing13.tgs.gen"	  
PlayerSpriteData_Colo_Climbing13:           include "..\sprites\secretsofgrindea\Climbing13.tcs.gen"	| db +0-8,+0

PlayerSpriteData_Char_RightPunch1a:         include "..\sprites\secretsofgrindea\RightPunch1a.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1a:         include "..\sprites\secretsofgrindea\RightPunch1a.tcs.gen"| db +0-8,-1
PlayerSpriteData_Char_RightPunch1b:         include "..\sprites\secretsofgrindea\RightPunch1b.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1b:         include "..\sprites\secretsofgrindea\RightPunch1b.tcs.gen"| db +0-8,-2
PlayerSpriteData_Char_RightPunch1c:         include "..\sprites\secretsofgrindea\RightPunch1c.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1c:         include "..\sprites\secretsofgrindea\RightPunch1c.tcs.gen"| db +1-8,-2
PlayerSpriteData_Char_RightPunch1d:         include "..\sprites\secretsofgrindea\RightPunch1d.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1d:         include "..\sprites\secretsofgrindea\RightPunch1d.tcs.gen"| db +1-8,-2
PlayerSpriteData_Char_RightPunch1e:         include "..\sprites\secretsofgrindea\RightPunch1e.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1e:         include "..\sprites\secretsofgrindea\RightPunch1e.tcs.gen"| db +4-8,-1
PlayerSpriteData_Char_RightPunch1f:         include "..\sprites\secretsofgrindea\RightPunch1f.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1f:         include "..\sprites\secretsofgrindea\RightPunch1f.tcs.gen"| db +4-8,-2
PlayerSpriteData_Char_RightPunch1g:         include "..\sprites\secretsofgrindea\RightPunch1g.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1g:         include "..\sprites\secretsofgrindea\RightPunch1g.tcs.gen"| db +1-8,+0
PlayerSpriteData_Char_RightPunch1h:         include "..\sprites\secretsofgrindea\RightPunch1h.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1h:         include "..\sprites\secretsofgrindea\RightPunch1h.tcs.gen"| db +1-8,+0
PlayerSpriteData_Char_RightPunch1i:         include "..\sprites\secretsofgrindea\RightPunch1i.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch1i:         include "..\sprites\secretsofgrindea\RightPunch1i.tcs.gen"| db +0-8,+0

PlayerSpriteData_Char_RightPunch2a:         include "..\sprites\secretsofgrindea\RightPunch2a.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch2a:         include "..\sprites\secretsofgrindea\RightPunch2a.tcs.gen"| db +0-8,-0
PlayerSpriteData_Char_RightPunch2b:         include "..\sprites\secretsofgrindea\RightPunch2b.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch2b:         include "..\sprites\secretsofgrindea\RightPunch2b.tcs.gen"| db +3-8,-0
PlayerSpriteData_Char_RightPunch2c:         include "..\sprites\secretsofgrindea\RightPunch2c.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch2c:         include "..\sprites\secretsofgrindea\RightPunch2c.tcs.gen"| db +8-8,-2
PlayerSpriteData_Char_RightPunch2d:         include "..\sprites\secretsofgrindea\RightPunch2d.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch2d:         include "..\sprites\secretsofgrindea\RightPunch2d.tcs.gen"| db +8-8,-2
PlayerSpriteData_Char_RightPunch2e:         include "..\sprites\secretsofgrindea\RightPunch2e.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch2e:         include "..\sprites\secretsofgrindea\RightPunch2e.tcs.gen"| db +2-8,-0

PlayerSpriteData_Char_RightPunch3a:         include "..\sprites\secretsofgrindea\RightPunch3a.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch3a:         include "..\sprites\secretsofgrindea\RightPunch3a.tcs.gen"| db +4-8,-1
PlayerSpriteData_Char_RightPunch3b:         include "..\sprites\secretsofgrindea\RightPunch3b.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch3b:         include "..\sprites\secretsofgrindea\RightPunch3b.tcs.gen"| db +4-8,-1
PlayerSpriteData_Char_RightPunch3c:         include "..\sprites\secretsofgrindea\RightPunch3c.tgs.gen"	  
PlayerSpriteData_Colo_RightPunch3c:         include "..\sprites\secretsofgrindea\RightPunch3c.tcs.gen"| db +4-8,-1

PlayerSpriteData_Char_RightLowKick:         include "..\sprites\secretsofgrindea\RightLowKick.tgs.gen"	  
PlayerSpriteData_Colo_RightLowKick:         include "..\sprites\secretsofgrindea\RightLowKick.tcs.gen"	| db +0-8,+6
PlayerSpriteData_Char_RightHighKick:        include "..\sprites\secretsofgrindea\RightHighKick.tgs.gen"	  
PlayerSpriteData_Colo_RightHighKick:        include "..\sprites\secretsofgrindea\RightHighKick.tcs.gen"	| db +0-8,+6

PlayerSpriteData_Char_LeftPunch1a:          include "..\sprites\secretsofgrindea\LeftPunch1a.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1a:          include "..\sprites\secretsofgrindea\LeftPunch1a.tcs.gen"| db +0-8,+1
PlayerSpriteData_Char_LeftPunch1b:          include "..\sprites\secretsofgrindea\LeftPunch1b.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1b:          include "..\sprites\secretsofgrindea\LeftPunch1b.tcs.gen"| db +0-8,+2
PlayerSpriteData_Char_LeftPunch1c:          include "..\sprites\secretsofgrindea\LeftPunch1c.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1c:          include "..\sprites\secretsofgrindea\LeftPunch1c.tcs.gen"| db -1-8,+2
PlayerSpriteData_Char_LeftPunch1d:          include "..\sprites\secretsofgrindea\LeftPunch1d.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1d:          include "..\sprites\secretsofgrindea\LeftPunch1d.tcs.gen"| db -1-8,+2
PlayerSpriteData_Char_LeftPunch1e:          include "..\sprites\secretsofgrindea\LeftPunch1e.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1e:          include "..\sprites\secretsofgrindea\LeftPunch1e.tcs.gen"| db -4-8,+1
PlayerSpriteData_Char_LeftPunch1f:          include "..\sprites\secretsofgrindea\LeftPunch1f.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1f:          include "..\sprites\secretsofgrindea\LeftPunch1f.tcs.gen"| db -4-8,+2
PlayerSpriteData_Char_LeftPunch1g:          include "..\sprites\secretsofgrindea\LeftPunch1g.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1g:          include "..\sprites\secretsofgrindea\LeftPunch1g.tcs.gen"| db -1-8,+0
PlayerSpriteData_Char_LeftPunch1h:          include "..\sprites\secretsofgrindea\LeftPunch1h.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1h:          include "..\sprites\secretsofgrindea\LeftPunch1h.tcs.gen"| db -1-8,+0
PlayerSpriteData_Char_LeftPunch1i:          include "..\sprites\secretsofgrindea\LeftPunch1i.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch1i:          include "..\sprites\secretsofgrindea\LeftPunch1i.tcs.gen"| db +0-8,+0

PlayerSpriteData_Char_LeftPunch2a:          include "..\sprites\secretsofgrindea\LeftPunch2a.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch2a:          include "..\sprites\secretsofgrindea\LeftPunch2a.tcs.gen"| db +0-8,+0
PlayerSpriteData_Char_LeftPunch2b:          include "..\sprites\secretsofgrindea\LeftPunch2b.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch2b:          include "..\sprites\secretsofgrindea\LeftPunch2b.tcs.gen"| db -3-8,+0
PlayerSpriteData_Char_LeftPunch2c:          include "..\sprites\secretsofgrindea\LeftPunch2c.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch2c:          include "..\sprites\secretsofgrindea\LeftPunch2c.tcs.gen"| db -8-8,+2
PlayerSpriteData_Char_LeftPunch2d:          include "..\sprites\secretsofgrindea\LeftPunch2d.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch2d:          include "..\sprites\secretsofgrindea\LeftPunch2d.tcs.gen"| db -8-8,+2
PlayerSpriteData_Char_LeftPunch2e:          include "..\sprites\secretsofgrindea\LeftPunch2e.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch2e:          include "..\sprites\secretsofgrindea\LeftPunch2e.tcs.gen"| db -2-8,+0

PlayerSpriteData_Char_LeftPunch3a:          include "..\sprites\secretsofgrindea\LeftPunch3a.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch3a:          include "..\sprites\secretsofgrindea\LeftPunch3a.tcs.gen"| db -4-8,+1
PlayerSpriteData_Char_LeftPunch3b:          include "..\sprites\secretsofgrindea\LeftPunch3b.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch3b:          include "..\sprites\secretsofgrindea\LeftPunch3b.tcs.gen"| db -4-8,+1
PlayerSpriteData_Char_LeftPunch3c:          include "..\sprites\secretsofgrindea\LeftPunch3c.tgs.gen"	  
PlayerSpriteData_Colo_LeftPunch3c:          include "..\sprites\secretsofgrindea\LeftPunch3c.tcs.gen"| db -4-8,+1

PlayerSpriteData_Char_LeftLowKick:          include "..\sprites\secretsofgrindea\LeftLowKick.tgs.gen"	  
PlayerSpriteData_Colo_LeftLowKick:          include "..\sprites\secretsofgrindea\LeftLowKick.tcs.gen"	| db +0-8,-6
PlayerSpriteData_Char_LeftHighKick:         include "..\sprites\secretsofgrindea\LeftHighKick.tgs.gen"	  
PlayerSpriteData_Colo_LeftHighKick:         include "..\sprites\secretsofgrindea\LeftHighKick.tcs.gen"	| db -0-8,-6

PlayerSpriteData_Char_LeftPush1:            include "..\sprites\secretsofgrindea\LeftPush1.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush1:            include "..\sprites\secretsofgrindea\LeftPush1.tcs.gen"	  | db +1-10,+0
PlayerSpriteData_Char_LeftPush2:            include "..\sprites\secretsofgrindea\LeftPush2.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush2:            include "..\sprites\secretsofgrindea\LeftPush2.tcs.gen"	  | db +0-10,+1
PlayerSpriteData_Char_LeftPush3:            include "..\sprites\secretsofgrindea\LeftPush3.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush3:            include "..\sprites\secretsofgrindea\LeftPush3.tcs.gen"	  | db +0-10,+1
PlayerSpriteData_Char_LeftPush4:            include "..\sprites\secretsofgrindea\LeftPush4.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush4:            include "..\sprites\secretsofgrindea\LeftPush4.tcs.gen"	  | db +0-10,+1
PlayerSpriteData_Char_LeftPush5:            include "..\sprites\secretsofgrindea\LeftPush5.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush5:            include "..\sprites\secretsofgrindea\LeftPush5.tcs.gen"	  | db +0-10,+1
PlayerSpriteData_Char_LeftPush6:            include "..\sprites\secretsofgrindea\LeftPush6.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush6:            include "..\sprites\secretsofgrindea\LeftPush6.tcs.gen"	  | db +1-10,+0
PlayerSpriteData_Char_LeftPush7:            include "..\sprites\secretsofgrindea\LeftPush7.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush7:            include "..\sprites\secretsofgrindea\LeftPush7.tcs.gen"	  | db +1-10,+0
PlayerSpriteData_Char_LeftPush8:            include "..\sprites\secretsofgrindea\LeftPush8.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush8:            include "..\sprites\secretsofgrindea\LeftPush8.tcs.gen"	  | db +1-10,+0
PlayerSpriteData_Char_LeftPush9:            include "..\sprites\secretsofgrindea\LeftPush9.tgs.gen"	  
PlayerSpriteData_Colo_LeftPush9:            include "..\sprites\secretsofgrindea\LeftPush9.tcs.gen"	  | db +1-10,+0

PlayerSpriteData_Char_RightPush1:           include "..\sprites\secretsofgrindea\RightPush1.tgs.gen"	  
PlayerSpriteData_Colo_RightPush1:           include "..\sprites\secretsofgrindea\RightPush1.tcs.gen"	  | db +0-7,+0
PlayerSpriteData_Char_RightPush2:           include "..\sprites\secretsofgrindea\RightPush2.tgs.gen"	  
PlayerSpriteData_Colo_RightPush2:           include "..\sprites\secretsofgrindea\RightPush2.tcs.gen"	  | db +1-7,-1
PlayerSpriteData_Char_RightPush3:           include "..\sprites\secretsofgrindea\RightPush3.tgs.gen"	  
PlayerSpriteData_Colo_RightPush3:           include "..\sprites\secretsofgrindea\RightPush3.tcs.gen"	  | db +1-7,-1
PlayerSpriteData_Char_RightPush4:           include "..\sprites\secretsofgrindea\RightPush4.tgs.gen"	  
PlayerSpriteData_Colo_RightPush4:           include "..\sprites\secretsofgrindea\RightPush4.tcs.gen"	  | db +1-7,-1
PlayerSpriteData_Char_RightPush5:           include "..\sprites\secretsofgrindea\RightPush5.tgs.gen"	  
PlayerSpriteData_Colo_RightPush5:           include "..\sprites\secretsofgrindea\RightPush5.tcs.gen"	  | db +1-7,-1
PlayerSpriteData_Char_RightPush6:           include "..\sprites\secretsofgrindea\RightPush6.tgs.gen"	  
PlayerSpriteData_Colo_RightPush6:           include "..\sprites\secretsofgrindea\RightPush6.tcs.gen"	  | db +0-7,+0
PlayerSpriteData_Char_RightPush7:           include "..\sprites\secretsofgrindea\RightPush7.tgs.gen"	  
PlayerSpriteData_Colo_RightPush7:           include "..\sprites\secretsofgrindea\RightPush7.tcs.gen"	  | db +0-7,+0
PlayerSpriteData_Char_RightPush8:           include "..\sprites\secretsofgrindea\RightPush8.tgs.gen"	  
PlayerSpriteData_Colo_RightPush8:           include "..\sprites\secretsofgrindea\RightPush8.tcs.gen"	  | db +0-7,+0
PlayerSpriteData_Char_RightPush9:           include "..\sprites\secretsofgrindea\RightPush9.tgs.gen"	  
PlayerSpriteData_Colo_RightPush9:           include "..\sprites\secretsofgrindea\RightPush9.tcs.gen"	  | db +0-7,+0

PlayerSpriteData_Char_LeftRolling1:         include "..\sprites\secretsofgrindea\LeftRolling1.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling1:         include "..\sprites\secretsofgrindea\LeftRolling1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling2:         include "..\sprites\secretsofgrindea\LeftRolling2.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling2:         include "..\sprites\secretsofgrindea\LeftRolling2.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling3:         include "..\sprites\secretsofgrindea\LeftRolling3.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling3:         include "..\sprites\secretsofgrindea\LeftRolling3.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling4:         include "..\sprites\secretsofgrindea\LeftRolling4.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling4:         include "..\sprites\secretsofgrindea\LeftRolling4.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling5:         include "..\sprites\secretsofgrindea\LeftRolling5.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling5:         include "..\sprites\secretsofgrindea\LeftRolling5.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling6:         include "..\sprites\secretsofgrindea\LeftRolling6.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling6:         include "..\sprites\secretsofgrindea\LeftRolling6.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling7:         include "..\sprites\secretsofgrindea\LeftRolling7.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling7:         include "..\sprites\secretsofgrindea\LeftRolling7.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling8:         include "..\sprites\secretsofgrindea\LeftRolling8.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling8:         include "..\sprites\secretsofgrindea\LeftRolling8.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling9:         include "..\sprites\secretsofgrindea\LeftRolling9.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling9:         include "..\sprites\secretsofgrindea\LeftRolling9.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling10:        include "..\sprites\secretsofgrindea\LeftRolling10.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling10:        include "..\sprites\secretsofgrindea\LeftRolling10.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling11:        include "..\sprites\secretsofgrindea\LeftRolling11.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling11:        include "..\sprites\secretsofgrindea\LeftRolling11.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftRolling12:        include "..\sprites\secretsofgrindea\LeftRolling12.tgs.gen"	  
PlayerSpriteData_Colo_LeftRolling12:        include "..\sprites\secretsofgrindea\LeftRolling12.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_RightRolling1:        include "..\sprites\secretsofgrindea\RightRolling1.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling1:        include "..\sprites\secretsofgrindea\RightRolling1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling2:        include "..\sprites\secretsofgrindea\RightRolling2.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling2:        include "..\sprites\secretsofgrindea\RightRolling2.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling3:        include "..\sprites\secretsofgrindea\RightRolling3.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling3:        include "..\sprites\secretsofgrindea\RightRolling3.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling4:        include "..\sprites\secretsofgrindea\RightRolling4.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling4:        include "..\sprites\secretsofgrindea\RightRolling4.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling5:        include "..\sprites\secretsofgrindea\RightRolling5.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling5:        include "..\sprites\secretsofgrindea\RightRolling5.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling6:        include "..\sprites\secretsofgrindea\RightRolling6.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling6:        include "..\sprites\secretsofgrindea\RightRolling6.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling7:        include "..\sprites\secretsofgrindea\RightRolling7.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling7:        include "..\sprites\secretsofgrindea\RightRolling7.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling8:        include "..\sprites\secretsofgrindea\RightRolling8.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling8:        include "..\sprites\secretsofgrindea\RightRolling8.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling9:        include "..\sprites\secretsofgrindea\RightRolling9.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling9:        include "..\sprites\secretsofgrindea\RightRolling9.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling10:       include "..\sprites\secretsofgrindea\RightRolling10.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling10:       include "..\sprites\secretsofgrindea\RightRolling10.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling11:       include "..\sprites\secretsofgrindea\RightRolling11.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling11:       include "..\sprites\secretsofgrindea\RightRolling11.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightRolling12:       include "..\sprites\secretsofgrindea\RightRolling12.tgs.gen"	  
PlayerSpriteData_Colo_RightRolling12:       include "..\sprites\secretsofgrindea\RightRolling12.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_LeftSitting:          include "..\sprites\secretsofgrindea\LeftSitting.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitting:          include "..\sprites\secretsofgrindea\LeftSitting.tcs.gen"	  | db +0-8,+1

PlayerSpriteData_Char_RightSitting:         include "..\sprites\secretsofgrindea\RightSitting.tgs.gen"	  
PlayerSpriteData_Colo_RightSitting:         include "..\sprites\secretsofgrindea\RightSitting.tcs.gen"	  | db +0-8,-1

PlayerSpriteData_Char_LeftBeingHit1:        include "..\sprites\secretsofgrindea\LeftBeingHit1.tgs.gen"	  
PlayerSpriteData_Colo_LeftBeingHit1:        include "..\sprites\secretsofgrindea\LeftBeingHit1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftBeingHit2:        include "..\sprites\secretsofgrindea\LeftBeingHit2.tgs.gen"	  
PlayerSpriteData_Colo_LeftBeingHit2:        include "..\sprites\secretsofgrindea\LeftBeingHit2.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_RightBeingHit1:       include "..\sprites\secretsofgrindea\RightBeingHit1.tgs.gen"	  
PlayerSpriteData_Colo_RightBeingHit1:       include "..\sprites\secretsofgrindea\RightBeingHit1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightBeingHit2:       include "..\sprites\secretsofgrindea\RightBeingHit2.tgs.gen"	  
PlayerSpriteData_Colo_RightBeingHit2:       include "..\sprites\secretsofgrindea\RightBeingHit2.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_Empty:                include "..\sprites\secretsofgrindea\Empty.tgs.gen"	  
PlayerSpriteData_Colo_Empty:                include "..\sprites\secretsofgrindea\RightBeingHit1.tcs.gen"	  | db +0-8,+0


EndPlayerSprites1: | ds $c000-$,$ff | dephase ;bf80

;
; block $39 - $3c
;
KarniMataTilesBlock:  equ   $39
phase	$4000
  incbin "..\grapx\Karni-Mata-TILES.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\Karni-Mata-TILESbottom.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $3d - $40
;
movementpatterns1block:  equ   $3d
phase	$4000
  include "MovementPatterns\MovementPatterns1.asm"
	ds		$c000-$,$ff
dephase


;  include "actiontables\actiontableslenghts.asm"
totallenght:	Equ	$-Usas2
	ds		$80000-totallenght
