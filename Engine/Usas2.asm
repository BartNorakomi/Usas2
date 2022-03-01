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
Graphicsblock4:  equ   $11
phase	$4000
itemsKarniMataPage3:
  incbin "..\grapx\itemsKarniMataPage3.SC5",7,$1000  ;skip header

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
;Graphicsblock5:  equ   $15
phase	$4000
;scoreboard:
;  incbin "..\grapx\scoreboard.SC5",7,$1000  ;skip header
;itemsKarniMata:
;  incbin "..\grapx\itemsKarniMata.SC5",7,$1000  ;skip header
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
phase	$4000
	ds		$c000-$,$ff
dephase

;
; block $1c - $1d
;
phase	$4000
	ds		$8000-$,$ff
dephase


;
; block $1e - &1f
;
MapsBlock01:  equ   $1e
phase	$8000
MapA01_001:   ;EngineType, graphics, palette,
  incbin "..\maps\A01-001.map.pck"  | .amountofobjects: db  14
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks13Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks14Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks15Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object4: db 1,        0|dw PushingPuzzlOverview|db 06*8,12*8,12*8,0,     00,       00,+00,+00,+00,+00,+00,+07,+00|dw PuzzleSwitchTable2|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object5: db 1,        0|dw PushingPuzzleSwitch |db 13*8,10*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch15On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 13*8,12*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch16On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 13*8,24*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch19On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object08:db 1,        0|dw PushingPuzzleSwitch |db 13*8,26*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch20On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

.object09:db 1,        0|dw PushingPuzzleSwitch |db 19*8,10*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch21On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object10:db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch26On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

.object11:db 1,        0|dw PushingPuzzleSwitch |db 25*8,10*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch27On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object12:db 1,        0|dw PushingPuzzleSwitch |db 25*8,12*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch28On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object13:db 1,        0|dw PushingPuzzleSwitch |db 25*8,24*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch31On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object14:db 1,        0|dw PushingPuzzleSwitch |db 25*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch32On?,PuzzleSwitchTable2|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_002:
  incbin "..\maps\A01-002.map.pck"  | .amountofobjects: db  7
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks1Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks2Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks3Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 19*8,06*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch1On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 19*8,12*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 19*8,18*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch3On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch4On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_003:
  incbin "..\maps\A01-003.map.pck"  | .amountofobjects: db  7
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks19Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks20Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 0,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 14*8,11*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch38On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch40On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 25*8,26*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch41On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object7: db 1,        0|dw PushingPuzzlOverview|db 08*8,14*8,14*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      



MapA01_004:
  incbin "..\maps\A01-004.map.pck"  | .amountofobjects: db  2
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object1: db 1,        0|dw PushingPuzzlOverview|db 03*8,07*8,07*8,0,     00,       00,+00,+00,+00,+00,+00,+10,+00|dw PuzzleSwitchTable1|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object2: db 1,        0|dw PushingPuzzleSwitch |db 14*8,13*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch14On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzlOverview|db 14*8,15*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_005:
  incbin "..\maps\A01-005.map.pck"  | .amountofobjects: db  8
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks4Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks5Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks6Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 18*8,08*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch5On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 16*8,14*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch6On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 16*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch7On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 17*8,30*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch8On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      


MapA01_006:
  incbin "..\maps\A01-006.map.pck"  | .amountofobjects: db  8
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks21Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks22Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 0,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 12*8,06*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch42On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 12*8,16*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch43On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch44On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 25*8,15*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch45On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object8: db 1,        0|dw PushingPuzzlOverview|db 08*8,18*8,18*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
  
  
MapA01_007:
  incbin "..\maps\A01-007.map.pck"  | .amountofobjects: db  9
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks16Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks17Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks18Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 25*8,06*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch33On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 25*8,14*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch34On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 25*8,18*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch35On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 25*8,22*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch36On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object8: db 1,        0|dw PushingPuzzleSwitch |db 25*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch37On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object9: db 1,        0|dw PushingPuzzlOverview|db 07*8,15*8,15*8,0,     00,       00,+00,+00,+00,+00,+00,+04,+00|dw PuzzleSwitchTable3|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_008:
  incbin "..\maps\A01-008.map.pck"  | .amountofobjects: db  8
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks7Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks8Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks9Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
.object4: db 1,        0|dw PushingPuzzleSwitch |db 13*8,06*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch9On? ,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object5: db 1,        0|dw PushingPuzzleSwitch |db 13*8,10*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch10On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object6: db 1,        0|dw PushingPuzzleSwitch |db 13*8,16*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch11On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object7: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch12On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
.object8: db 1,        0|dw PushingPuzzleSwitch |db 19*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch13On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_009:
  incbin "..\maps\A01-009.map.pck"  | .amountofobjects: db  1
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
.object1: db 1,        0|dw PushingPuzzlOverview|db 10*8,12*8,12*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

	ds		$c000-$,$ff
dephase

;
; block $20 - &21
;

MapsBlock02:  equ   $20
phase	$8000
MapB01_001:
  incbin "..\maps\b01-001.map.pck"  | .amountofobjects: db  3
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 2,        0|dw Sf2Hugeobject1      |db 8*06|dw 8*09|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016| ds fill
.object2: db 2,        0|dw Sf2Hugeobject2      |db 8*12|dw 8*12|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016| ds fill
.object3: db 2,        0|dw Sf2Hugeobject3      |db 8*03|dw 8*13|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016| ds fill

MapB01_002:
  incbin "..\maps\b01-002.map.pck"  | .amountofobjects: db  4
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life   
.object1: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
.object2: db 1,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
.object3: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*15|db 16,16|dw CleanOb3,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
;Beetle
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw Beetle           |db 8*14+10|dw 8*19|db 22,28|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 003| ds fill
 
MapB01_003:
  incbin "..\maps\b01-003.map.pck"  | .amountofobjects: db  7
;Demontje Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 0,        0|dw DemontjeBullet      |db 8*10|dw 8*15|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw Demontje            |db 8*08|dw 8*31|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object3:db -1,        1|dw Demontje            |db 8*11|dw 8*34|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+01,+00,+00, 0|db 001| ds fill
.object4:db -1,        1|dw Demontje            |db 8*07|dw 8*10|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 001| ds fill
.object5:db -1,        1|dw Demontje            |db 8*09|dw 8*07|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+03,+00,+00, 0|db 001| ds fill
;Landstrider
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object6:db -1,        1|dw Landstrider         |db 8*14|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object7:db -1,        1|dw Landstrider         |db 8*24|dw 8*29|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_004:
  incbin "..\maps\b01-004.map.pck"  | .amountofobjects: db  3
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
.object2: db 1,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
.object3: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*15|db 16,16|dw CleanOb3,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill

MapB01_005:
  incbin "..\maps\b01-005.map.pck"  | .amountofobjects: db  8
;Green Wasp ;v6=Green Wasp(0) / Brown Wasp(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw Wasp                |db 8*13|dw 8*11|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object2:db -1,        1|dw Wasp                |db 8*10|dw 8*15|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+01,+03,+00,+00,+00, 0|db 001| ds fill
.object3:db -1,        1|dw Wasp                |db 8*09|dw 8*18|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+02,+06,+00,+00,+00, 0|db 001| ds fill
.object4:db -1,        1|dw Wasp                |db 8*17|dw 8*23|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+03,+09,+00,+00,+00, 0|db 001| ds fill
;Brown Wasp ;v6=Green Wasp(0) / Brown Wasp(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object5:db -1,        1|dw Wasp                |db 8*03|dw 8*10|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+04,+12,+01,+00,+00, 0|db 001| ds fill
.object6:db -1,        1|dw Wasp                |db 8*05|dw 8*14|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+05,+15,+01,+00,+00, 0|db 001| ds fill
.object7:db -1,        1|dw Wasp                |db 8*11|dw 8*20|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+06,+18,+01,+00,+00, 0|db 001| ds fill
.object8:db -1,        1|dw Wasp                |db 8*16|dw 8*28|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+07,+21,+01,+00,+00, 0|db 001| ds fill

MapB01_006:
  incbin "..\maps\b01-006.map.pck" | .amountofobjects: db  5
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 1,        0|dw PlatformVertically  |db 8*15|dw 8*13|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+01,+00,+00,+16,+00,+00,+00, 0|db 000| ds fill

;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw Slime               |db 8*17|dw 8*24|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object3:db -1,        1|dw Slime               |db 8*17|dw 8*06|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object4:db -1,        1|dw Slime               |db 8*05|dw 8*19|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object5:db -1,        1|dw Slime               |db 8*21|dw 8*30|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_007:
  incbin "..\maps\b01-007.map.pck"  | .amountofobjects: db  5
;FireEye Grey
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw FireEyeGrey         |db 8*19|dw 8*21|db 48,32|dw 12*16,spat+(12*2)|db 72-(11*6),11  ,11*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005| ds fill
;Fire Eye Firebullets
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object2: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb1,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object3: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb2,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object4: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb3,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object5: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb4,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill

MapB01_008:
  incbin "..\maps\b01-008.map.pck"  | .amountofobjects: db  5
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw GreenSpider         |db 8*23|dw 8*12|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001| ds fill

;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3:db -1,        1|dw BoringEye           |db 8*18|dw 8*09|db 32,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001| ds fill
;Boring Eye Red;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw BoringEye           |db 8*18|dw 8*31|db 32,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001| ds fill
.object5:db -1,        1|dw BoringEye           |db 8*04|dw 8*22|db 32,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001| ds fill

MapB01_009:
  incbin "..\maps\b01-009.map.pck"  | .amountofobjects: db  6
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 0,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
.object2: db 0,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
;Spider Green
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3:db -0,        1|dw GreenSpider         |db 8*14|dw 8*19|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001| ds fill

;Bat Spawner
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db +1,        1|dw BatSpawner          |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+00,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object5:db -0,        1|dw Bat                 |db 8*10|dw 8*19|db 26,22|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object6:db -0,        1|dw Bat                 |db 8*06|dw 8*19|db 26,22|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_010:
  incbin "..\maps\b01-010.map.pck"  | .amountofobjects: db  6
;Retarded Zombie Spawnpoint
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db +1,        1|dw ZombieSpawnPoint    |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+01,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000| ds fill

;Retarded Zombie
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object3:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 16*16,spat+(16*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object4:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 20*16,spat+(20*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object5:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 24*16,spat+(24*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object6: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill

MapB01_011:
  incbin "..\maps\b01-011.map.pck"  | .amountofobjects: db  3
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
;Treeman
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw Treeman             |db 8*11|dw 8*30|db 32,26|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005| ds fill
;Grinder
.object3:db -1,        1|dw Grinder             |db 8*19|dw 8*16|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005| ds fill

MapB01_012:
  incbin "..\maps\b01-012.map.pck"  | .amountofobjects: db  2
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +32,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000| ds fill
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw GreenSpider         |db 8*17|dw 8*15|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001| ds fill

MapB01_013:
  incbin "..\maps\b01-013.map.pck"  | .amountofobjects: db  1
;Hunchback
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw Hunchback           |db 8*21|dw 8*34|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 003| ds fill

MapB01_014:
  incbin "..\maps\b01-014.map.pck"  | .amountofobjects: db  3
;Scorpion
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw Scorpion            |db 8*03|dw 8*20|db 32,22|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+01,+00,+00,+00,+00, 0|db 001| ds fill
.object2:db -1,        1|dw Scorpion            |db 8*12|dw 8*20|db 32,22|dw 18*16,spat+(18*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+01,+00,+00,+00,+00, 0|db 001| ds fill
;Spider Green
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3:db -1,        1|dw GreenSpider         |db 8*23|dw 8*19|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_015:
  incbin "..\maps\b01-015.map.pck"  | .amountofobjects: db  7
;Octopussy Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object1: db 0,        0|dw OctopussyBullet     |db 8*12|dw 8*16|db 08,08|dw CleanOb1,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object2: db 0,        0|dw OctopussyBullet     |db 8*13|dw 8*18|db 08,08|dw CleanOb2,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object3: db 0,        0|dw OctopussyBullet     |db 8*14|dw 8*20|db 08,08|dw CleanOb3,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object4: db 0,        0|dw OctopussyBullet     |db 8*15|dw 8*22|db 08,08|dw CleanOb4,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Octopussy Bullet Slow Down Handler
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object5: db 1,        0|dw OP_SlowDownHandler  |db 8*12|dw 8*16|db 00,00|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Octopussy
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object6:db -0,        1|dw Octopussy           |db 8*15|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001| ds fill
.object7:db -1,        1|dw Octopussy           |db 8*14|dw 8*23|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001| ds fill

MapB01_016:
  incbin "..\maps\b01-016.map.pck"  | .amountofobjects: db  3
;SensorTentacles
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw SensorTentacles     |db 8*12|dw 8*16|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001| ds fill
.object2:db -1,        1|dw SensorTentacles     |db 8*07|dw 8*19|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*07+1,+1, 0|db 1| ds fill
;.object3:db -1,        1|dw SensorTentacles     |db 8*12|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001| ds fill
;Yellow Wasp
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3:db -1,        1|dw YellowWasp          |db 8*12|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_017:
  incbin "..\maps\b01-017.map.pck"  | .amountofobjects: db  2
;Huge Blob
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw HugeBlob            |db 8*11|dw 8*20|db 48,46|dw 16*16,spat+(16*2)|db 72-(12*6),12  ,12*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005| ds fill
;Huge Blob software sprite part
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object2: db 1,        0|dw HugeBlobSWsprite    |db 0*00|dw 0*00|db 21,14|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill

MapB01_018:
  incbin "..\maps\b01-018.map.pck"  | .amountofobjects: db  7
;Snowball Thrower
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw SnowballThrower     |db 8*21|dw 8*13|db 32,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill
;Snowball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object2: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb1,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object3: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb2,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Snowball Thrower
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw SnowballThrower     |db 8*05|dw 8*13|db 32,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001| ds fill
;Snowball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object5: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb3,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object6: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb4,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Trampoline Blob
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object7:db -1,        1|dw TrampolineBlob      |db 8*17|dw 8*18|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 255| ds fill

MapB01_019:
  incbin "..\maps\b01-019.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 0,        0|dw GlassBall5          |db 8*02|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object2: db 0,        0|dw GlassBall6          |db 8*02|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000| ds fill
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*06|dw 8*13|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_020:
  incbin "..\maps\b01-020.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 2,        0|dw GlassBall3          |db 8*19|dw 8*02|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object2: db 2,        0|dw GlassBall4          |db 8*19|dw 8*24|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000| ds fill
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*23|dw 8*13|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_021:
  incbin "..\maps\b01-021.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 0,        0|dw GlassBall1          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
.object2: db 0,        0|dw GlassBall2          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000| ds fill
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*15|dw 8*27|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_022:
  incbin "..\maps\b01-022.map.pck"  | .amountofobjects: db  6
;Demontje Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 0,        0|dw DemontjeBullet      |db 8*10|dw 8*15|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw Demontje            |db 8*20|dw 8*30|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001| ds fill
.object3:db -1,        1|dw Demontje            |db 8*18|dw 8*08|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 001| ds fill
;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object4: db 1,        0|dw WaterfallEyesYellow |db 8*15+3|dw 8*26|db 06,14|dw CleanOb2,0 db 0,0,0,                   +067,+00,+00,+03,+01,8*15+3,8*10,8*15+3,8*18,8*15+3,8*26| ds fill
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object5: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*26+2|db 06,10|dw CleanOb3,0 db 0,0,0,                 +119,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000| ds fill
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object6:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_023:
  incbin "..\maps\b01-023.map.pck"  | .amountofobjects: db  6
;Black Hole Baby
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw BlackHoleBaby       |db 8*08|dw 8*05|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill
.object2:db -1,        1|dw BlackHoleBaby       |db 8*12|dw 8*16|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill
.object3:db -1,        1|dw BlackHoleBaby       |db 8*10|dw 8*22|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill
.object4:db -1,        1|dw BlackHoleBaby       |db 8*23|dw 8*03|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill
.object5:db -1,        1|dw BlackHoleBaby       |db 8*23|dw 8*17|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill
.object6:db -1,        1|dw BlackHoleBaby       |db 8*17|dw 8*33|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002| ds fill

MapB01_024:
  incbin "..\maps\b01-024.map.pck"  | .amountofobjects: db  4
;Lancelot
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1:db -1,        1|dw Lancelot            |db 8*13|dw 8*20|db 32,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001| ds fill
;Lancelot Sword
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life,   
.object2: db 1,        0|dw LancelotSword       |db 8*10|dw 8*10|db 07,27|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object3:db -1,        1|dw BoringEye           |db 8*13|dw 8*17|db 32,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001| ds fill
;Black Hole Alien
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -1,        1|dw BlackHoleAlien      |db 8*05|dw 8*22|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005| ds fill

MapB01_025:
  incbin "..\maps\b01-025.map.pck"  | .amountofobjects: db  3
;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object4: db 1,        0|dw WaterfallEyesGrey   |db 8*15+3|dw 8*22|db 06,14|dw CleanOb1,0 db 0,0,0,                   +095,+00,+01,+02,+01,8*15+3,8*14,8*15+3,8*22,8*00+3,8*00| ds fill
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object5: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*22+2|db 06,10|dw CleanOb2,0 db 0,0,0,                   +139,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000| ds fill
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object6:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill

MapB01_026:
  incbin "..\maps\b01-026.map.pck"  | .amountofobjects: db  10
;Dripping Ooze Drop
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   , Hit?,life 
.object1: db 1,        0|dw DrippingOozeDrop    |db 8*09-5|dw 8*10+3|db 08,05|dw CleanOb1,0 db 0,0,0,                 +149,+02,+03,+00,+63,+00,+00,8*09-5,8*10+3, 0|db 000| ds fill
;Dripping Ooze
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -0,        1|dw DrippingOoze        |db 8*22|dw 8*24|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill

;Dripping Ooze Drop
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   , Hit?,life 
.object3: db 1,        0|dw DrippingOozeDrop    |db 8*09-5|dw 8*22+3|db 08,05|dw CleanOb2,0 db 0,0,0,                 +149,+02,+03,+00,180,+00,+00,8*09-5,8*22+3, 0|db 000| ds fill
;Dripping Ooze
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object4:db -0,        1|dw DrippingOoze        |db 8*22|dw 8*24|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill

;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object5: db 1,        0|dw WaterfallEyesGrey   |db 8*15+3|dw 8*28|db 06,14|dw CleanOb3,0 db 0,0,0,                   +095,+00,200,+02,+01,8*15+3,8*06,8*15+3,8*28,8*00+3,8*00| ds fill
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object6: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*28+2|db 06,10|dw CleanOb4,0 db 0,0,0,                 +139,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000| ds fill
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object7:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill

;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object8: db 1,        0|dw WaterfallEyesYellow |db 8*15+3|dw 8*17|db 06,14|dw CleanOb5,0 db 0,0,0,                   +067,+00,+01,+01,+00,8*15+3,8*17,8*00+3,8*00,8*00+3,8*00| ds fill
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object9: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*17+2|db 06,10|dw CleanOb6,0 db 0,0,0,                 +119,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000| ds fill
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object10:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001| ds fill



MapB01_027:
  incbin "..\maps\b01-027.map.pck"  | .amountofobjects: db  2
;Big Statue Mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object1: db 1,        0|dw BigStatueMouth    |db 8*09+4|dw 8*09|db 11,14|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000| ds fill
;Cute Mini Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9, Hit?,life 
.object2:db -1,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+40,+01,+00, 0|db 001| ds fill




	ds		$c000-$,$ff
dephase


fill: equ 0

;NrSprites: (18 - (amount of sprites*3))

;ADDED NR sprites, so from v1 everything should be moved 1 byte to the right
;ADDED Amount sprites, so from v1 everything should be moved 1 more byte to the right
;ADDED spataddress, so from v7 everything should be moved 2 more bytes to the right
;ADDED extra byte for x, so from ny everything should be moved 1 more bytes to the right

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
PlayerSpriteData_Colo_LeftSitting:          include "..\sprites\secretsofgrindea\LeftSitting.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_RightSitting:         include "..\sprites\secretsofgrindea\RightSitting.tgs.gen"	  
PlayerSpriteData_Colo_RightSitting:         include "..\sprites\secretsofgrindea\RightSitting.tcs.gen"	  | db +0-8,-0

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

PlayerSpriteData_Char_LeftJump1:            include "..\sprites\secretsofgrindea\LeftJump1.tgs.gen"	  
PlayerSpriteData_Colo_LeftJump1:            include "..\sprites\secretsofgrindea\LeftJump1.tcs.gen"	  | db +0-8,+1
PlayerSpriteData_Char_LeftJump2:            include "..\sprites\secretsofgrindea\LeftJump2.tgs.gen"	  
PlayerSpriteData_Colo_LeftJump2:            include "..\sprites\secretsofgrindea\LeftJump2.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftJump3:            include "..\sprites\secretsofgrindea\LeftJump3.tgs.gen"	  
PlayerSpriteData_Colo_LeftJump3:            include "..\sprites\secretsofgrindea\LeftJump3.tcs.gen"	  | db +0-8,+2

PlayerSpriteData_Char_RightJump1:           include "..\sprites\secretsofgrindea\RightJump1.tgs.gen"	  
PlayerSpriteData_Colo_RightJump1:           include "..\sprites\secretsofgrindea\RightJump1.tcs.gen"	  | db +0-8,-1
PlayerSpriteData_Char_RightJump2:           include "..\sprites\secretsofgrindea\RightJump2.tgs.gen"	  
PlayerSpriteData_Colo_RightJump2:           include "..\sprites\secretsofgrindea\RightJump2.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightJump3:           include "..\sprites\secretsofgrindea\RightJump3.tgs.gen"	  
PlayerSpriteData_Colo_RightJump3:           include "..\sprites\secretsofgrindea\RightJump3.tcs.gen"	  | db +0-8,-2

PlayerSpriteData_Char_LeftSitPunch1:        include "..\sprites\secretsofgrindea\LeftSitPunch1.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitPunch1:        include "..\sprites\secretsofgrindea\LeftSitPunch1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftSitPunch2:        include "..\sprites\secretsofgrindea\LeftSitPunch2.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitPunch2:        include "..\sprites\secretsofgrindea\LeftSitPunch2.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_LeftSitPunch3:        include "..\sprites\secretsofgrindea\LeftSitPunch3.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitPunch3:        include "..\sprites\secretsofgrindea\LeftSitPunch3.tcs.gen"	  | db +0-8,-1

PlayerSpriteData_Char_RightSitPunch1:       include "..\sprites\secretsofgrindea\RightSitPunch1.tgs.gen"	  
PlayerSpriteData_Colo_RightSitPunch1:       include "..\sprites\secretsofgrindea\RightSitPunch1.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightSitPunch2:       include "..\sprites\secretsofgrindea\RightSitPunch2.tgs.gen"	  
PlayerSpriteData_Colo_RightSitPunch2:       include "..\sprites\secretsofgrindea\RightSitPunch2.tcs.gen"	  | db +0-8,+0
PlayerSpriteData_Char_RightSitPunch3:       include "..\sprites\secretsofgrindea\RightSitPunch3.tgs.gen"	  
PlayerSpriteData_Colo_RightSitPunch3:       include "..\sprites\secretsofgrindea\RightSitPunch3.tcs.gen"	  | db +0-8,+1

PlayerSpriteData_Char_Dying1:               include "..\sprites\secretsofgrindea\Dying1.tgs.gen"	  
PlayerSpriteData_Colo_Dying1:               include "..\sprites\secretsofgrindea\Dying1.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_Dying2:               include "..\sprites\secretsofgrindea\Dying2.tgs.gen"	  
PlayerSpriteData_Colo_Dying2:               include "..\sprites\secretsofgrindea\Dying2.tcs.gen"	  | db +3-8,-3

PlayerSpriteData_Char_LeftCharge1:         include "..\sprites\secretsofgrindea\LeftCharge1.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge1:         include "..\sprites\secretsofgrindea\LeftCharge1.tcs.gen"	  | db -1-8,+1
PlayerSpriteData_Char_LeftCharge2:         include "..\sprites\secretsofgrindea\LeftCharge2.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge2:         include "..\sprites\secretsofgrindea\LeftCharge2.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftCharge3:         include "..\sprites\secretsofgrindea\LeftCharge3.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge3:         include "..\sprites\secretsofgrindea\LeftCharge3.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftCharge4:         include "..\sprites\secretsofgrindea\LeftCharge4.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge4:         include "..\sprites\secretsofgrindea\LeftCharge4.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftCharge5:         include "..\sprites\secretsofgrindea\LeftCharge5.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge5:         include "..\sprites\secretsofgrindea\LeftCharge5.tcs.gen"	  | db -4-8,+4
PlayerSpriteData_Char_LeftCharge6:         include "..\sprites\secretsofgrindea\LeftCharge6.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge6:         include "..\sprites\secretsofgrindea\LeftCharge6.tcs.gen"	  | db -4-8,+4
PlayerSpriteData_Char_LeftCharge7:         include "..\sprites\secretsofgrindea\LeftCharge7.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge7:         include "..\sprites\secretsofgrindea\LeftCharge7.tcs.gen"	  | db -2-8,+2
PlayerSpriteData_Char_LeftCharge8:         include "..\sprites\secretsofgrindea\LeftCharge8.tgs.gen"	  
PlayerSpriteData_Colo_LeftCharge8:         include "..\sprites\secretsofgrindea\LeftCharge8.tcs.gen"	  | db -1-8,+1

PlayerSpriteData_Char_RightCharge1:        include "..\sprites\secretsofgrindea\RightCharge1.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge1:        include "..\sprites\secretsofgrindea\RightCharge1.tcs.gen"	  | db +1-8,-1
PlayerSpriteData_Char_RightCharge2:        include "..\sprites\secretsofgrindea\RightCharge2.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge2:        include "..\sprites\secretsofgrindea\RightCharge2.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightCharge3:        include "..\sprites\secretsofgrindea\RightCharge3.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge3:        include "..\sprites\secretsofgrindea\RightCharge3.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightCharge4:        include "..\sprites\secretsofgrindea\RightCharge4.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge4:        include "..\sprites\secretsofgrindea\RightCharge4.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightCharge5:        include "..\sprites\secretsofgrindea\RightCharge5.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge5:        include "..\sprites\secretsofgrindea\RightCharge5.tcs.gen"	  | db +4-8,-4
PlayerSpriteData_Char_RightCharge6:        include "..\sprites\secretsofgrindea\RightCharge6.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge6:        include "..\sprites\secretsofgrindea\RightCharge6.tcs.gen"	  | db +4-8,-4
PlayerSpriteData_Char_RightCharge7:        include "..\sprites\secretsofgrindea\RightCharge7.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge7:        include "..\sprites\secretsofgrindea\RightCharge7.tcs.gen"	  | db +2-8,-2
PlayerSpriteData_Char_RightCharge8:        include "..\sprites\secretsofgrindea\RightCharge8.tgs.gen"	  
PlayerSpriteData_Colo_RightCharge8:        include "..\sprites\secretsofgrindea\RightCharge8.tcs.gen"	  | db +1-8,-1



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
  include "MovementPatterns1.asm"
	ds		$c000-$,$ff
dephase

;
; block $41 + $42
;
RetardZombieSpriteblock:  equ   $41
SlimeSpriteblock:  equ   $41
BeetleSpriteblock:  equ   $41
phase	$8000
LeftRetardZombieWalk1_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk1.tgs.gen"	 ;y offset, x offset   
LeftRetardZombieWalk1_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk2_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk2.tgs.gen"	  
LeftRetardZombieWalk2_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk3_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk3.tgs.gen"	  
LeftRetardZombieWalk3_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk3.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk4_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk4.tgs.gen"	  
LeftRetardZombieWalk4_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk4.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk5_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk5.tgs.gen"	  
LeftRetardZombieWalk5_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk5.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk6_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk6.tgs.gen"	  
LeftRetardZombieWalk6_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk6.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieWalk7_Char:                 include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk7.tgs.gen"	  
LeftRetardZombieWalk7_Col:                  include "..\sprites\enemies\RetardZombie\LeftRetardZombieWalk7.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieLookBack_Char:              include "..\sprites\enemies\RetardZombie\LeftRetardZombieLookBack.tgs.gen"	  
LeftRetardZombieLookBack_Col:               include "..\sprites\enemies\RetardZombie\LeftRetardZombieLookBack.tcs.gen"  | db 00,00,00,00, 16,00,16,00

RightRetardZombieWalk1_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk1.tgs.gen"	  
RightRetardZombieWalk1_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk2_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk2.tgs.gen"	  
RightRetardZombieWalk2_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk3_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk3.tgs.gen"	  
RightRetardZombieWalk3_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk3.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk4_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk4.tgs.gen"	  
RightRetardZombieWalk4_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk4.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk5_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk5.tgs.gen"	  
RightRetardZombieWalk5_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk5.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk6_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk6.tgs.gen"	  
RightRetardZombieWalk6_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk6.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieWalk7_Char:                include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk7.tgs.gen"	  
RightRetardZombieWalk7_Col:                 include "..\sprites\enemies\RetardZombie\RightRetardZombieWalk7.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieLookBack_Char:             include "..\sprites\enemies\RetardZombie\RightRetardZombieLookBack.tgs.gen"	  
RightRetardZombieLookBack_Col:              include "..\sprites\enemies\RetardZombie\RightRetardZombieLookBack.tcs.gen"  | db 00,00,00,00, 16,00,16,00

RetardZombieRising1_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising1.tgs.gen"	  
RetardZombieRising1_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising1.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising2_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising2.tgs.gen"	  
RetardZombieRising2_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising2.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising3_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising3.tgs.gen"	  
RetardZombieRising3_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising3.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising4_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising4.tgs.gen"	  
RetardZombieRising4_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising4.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising5_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising5.tgs.gen"	  
RetardZombieRising5_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising5.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising6_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising6.tgs.gen"	  
RetardZombieRising6_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising6.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising7_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising7.tgs.gen"	  
RetardZombieRising7_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising7.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising8_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising8.tgs.gen"	  
RetardZombieRising8_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising8.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising9_Char:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising9.tgs.gen"	  
RetardZombieRising9_Col:                    include "..\sprites\enemies\RetardZombie\RetardZombieRising9.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising10_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising10.tgs.gen"	  
RetardZombieRising10_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising10.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising11_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising11.tgs.gen"	  
RetardZombieRising11_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising11.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising12_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising12.tgs.gen"	  
RetardZombieRising12_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising12.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising13_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising13.tgs.gen"	  
RetardZombieRising13_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising13.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising14_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising14.tgs.gen"	  
RetardZombieRising14_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising14.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising15_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising15.tgs.gen"	  
RetardZombieRising15_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising15.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising16_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising16.tgs.gen"	  
RetardZombieRising16_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising16.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising17_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising17.tgs.gen"	  
RetardZombieRising17_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising17.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising18_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising18.tgs.gen"	  
RetardZombieRising18_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising18.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising19_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising19.tgs.gen"	  
RetardZombieRising19_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising19.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising20_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising20.tgs.gen"	  
RetardZombieRising20_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising20.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising21_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising21.tgs.gen"	  
RetardZombieRising21_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising21.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising22_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising22.tgs.gen"	  
RetardZombieRising22_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising22.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising23_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising23.tgs.gen"	  
RetardZombieRising23_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising23.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising24_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising24.tgs.gen"	  
RetardZombieRising24_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising24.tcs.gen"	  | db 00,00,00,00, 16,00,16,00
RetardZombieRising25_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieRising25.tgs.gen"	  
RetardZombieRising25_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieRising25.tcs.gen"	  | db 00,00,00,00, 16,00,16,00

LeftRetardZombieFalling1_Char:              include "..\sprites\enemies\RetardZombie\LeftRetardZombieFalling1.tgs.gen"	  
LeftRetardZombieFalling1_Col:               include "..\sprites\enemies\RetardZombie\LeftRetardZombieFalling1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftRetardZombieFalling2_Char:              include "..\sprites\enemies\RetardZombie\LeftRetardZombieFalling2.tgs.gen"	  
LeftRetardZombieFalling2_Col:               include "..\sprites\enemies\RetardZombie\LeftRetardZombieFalling2.tcs.gen"  | db 00,00,00,00, 16,00,16,00

RightRetardZombieFalling1_Char:             include "..\sprites\enemies\RetardZombie\RightRetardZombieFalling1.tgs.gen"	  
RightRetardZombieFalling1_Col:              include "..\sprites\enemies\RetardZombie\RightRetardZombieFalling1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightRetardZombieFalling2_Char:             include "..\sprites\enemies\RetardZombie\RightRetardZombieFalling2.tgs.gen"	  
RightRetardZombieFalling2_Col:              include "..\sprites\enemies\RetardZombie\RightRetardZombieFalling2.tcs.gen"  | db 00,00,00,00, 16,00,16,00

RetardZombieSitting1_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieSitting1.tgs.gen"	  
RetardZombieSitting1_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieSitting1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RetardZombieSitting2_Char:                  include "..\sprites\enemies\RetardZombie\RetardZombieSitting2.tgs.gen"	  
RetardZombieSitting2_Col:                   include "..\sprites\enemies\RetardZombie\RetardZombieSitting2.tcs.gen"  | db 00,00,00,00, 16,00,16,00

LeftSlime1_Char:                            include "..\sprites\enemies\Slime\LeftSlime1.tgs.gen"	 ;y offset, x offset   
LeftSlime1_Col:                             include "..\sprites\enemies\Slime\LeftSlime1.tcs.gen"  | db 00,00,00,00
LeftSlime2_Char:                            include "..\sprites\enemies\Slime\LeftSlime2.tgs.gen"	  
LeftSlime2_Col:                             include "..\sprites\enemies\Slime\LeftSlime2.tcs.gen"  | db 00,00,00,00
LeftSlime3_Char:                            include "..\sprites\enemies\Slime\LeftSlime3.tgs.gen"	  
LeftSlime3_Col:                             include "..\sprites\enemies\Slime\LeftSlime3.tcs.gen"  | db 00,00,00,00
LeftSlime4_Char:                            include "..\sprites\enemies\Slime\LeftSlime4.tgs.gen"	  
LeftSlime4_Col:                             include "..\sprites\enemies\Slime\LeftSlime4.tcs.gen"  | db 00,00,00,00
LeftSlime5_Char:                            include "..\sprites\enemies\Slime\LeftSlime5.tgs.gen"	  
LeftSlime5_Col:                             include "..\sprites\enemies\Slime\LeftSlime5.tcs.gen"  | db 00,00,00,00
LeftSlime6_Char:                            include "..\sprites\enemies\Slime\LeftSlime6.tgs.gen"	  
LeftSlime6_Col:                             include "..\sprites\enemies\Slime\LeftSlime6.tcs.gen"  | db 00,00,00,00

RightSlime1_Char:                           include "..\sprites\enemies\Slime\RightSlime1.tgs.gen"	  
RightSlime1_Col:                            include "..\sprites\enemies\Slime\RightSlime1.tcs.gen"  | db 00,00,00,00
RightSlime2_Char:                           include "..\sprites\enemies\Slime\RightSlime2.tgs.gen"	  
RightSlime2_Col:                            include "..\sprites\enemies\Slime\RightSlime2.tcs.gen"  | db 00,00,00,00
RightSlime3_Char:                           include "..\sprites\enemies\Slime\RightSlime3.tgs.gen"	  
RightSlime3_Col:                            include "..\sprites\enemies\Slime\RightSlime3.tcs.gen"  | db 00,00,00,00
RightSlime4_Char:                           include "..\sprites\enemies\Slime\RightSlime4.tgs.gen"	  
RightSlime4_Col:                            include "..\sprites\enemies\Slime\RightSlime4.tcs.gen"  | db 00,00,00,00
RightSlime5_Char:                           include "..\sprites\enemies\Slime\RightSlime5.tgs.gen"	  
RightSlime5_Col:                            include "..\sprites\enemies\Slime\RightSlime5.tcs.gen"  | db 00,00,00,00
RightSlime6_Char:                           include "..\sprites\enemies\Slime\RightSlime6.tgs.gen"	  
RightSlime6_Col:                            include "..\sprites\enemies\Slime\RightSlime6.tcs.gen"  | db 00,00,00,00

LeftBeetleWalk1_Char:                       include "..\sprites\enemies\Beetle\LeftBeetleWalk1.tgs.gen"	;y offset, x offset  
LeftBeetleWalk1_Col:                        include "..\sprites\enemies\Beetle\LeftBeetleWalk1.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12
LeftBeetleWalk2_Char:                       include "..\sprites\enemies\Beetle\LeftBeetleWalk2.tgs.gen"	  
LeftBeetleWalk2_Col:                        include "..\sprites\enemies\Beetle\LeftBeetleWalk2.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12
LeftBeetleWalk3_Char:                       include "..\sprites\enemies\Beetle\LeftBeetleWalk3.tgs.gen"	  
LeftBeetleWalk3_Col:                        include "..\sprites\enemies\Beetle\LeftBeetleWalk3.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12
LeftBeetleWalk4_Char:                       include "..\sprites\enemies\Beetle\LeftBeetleWalk4.tgs.gen"	  
LeftBeetleWalk4_Col:                        include "..\sprites\enemies\Beetle\LeftBeetleWalk4.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12

RightBeetleWalk1_Char:                      include "..\sprites\enemies\Beetle\RightBeetleWalk1.tgs.gen"	  
RightBeetleWalk1_Col:                       include "..\sprites\enemies\Beetle\RightBeetleWalk1.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16
RightBeetleWalk2_Char:                      include "..\sprites\enemies\Beetle\RightBeetleWalk2.tgs.gen"	  
RightBeetleWalk2_Col:                       include "..\sprites\enemies\Beetle\RightBeetleWalk2.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16
RightBeetleWalk3_Char:                      include "..\sprites\enemies\Beetle\RightBeetleWalk3.tgs.gen"	  
RightBeetleWalk3_Col:                       include "..\sprites\enemies\Beetle\RightBeetleWalk3.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16
RightBeetleWalk4_Char:                      include "..\sprites\enemies\Beetle\RightBeetleWalk4.tgs.gen"	  
RightBeetleWalk4_Col:                       include "..\sprites\enemies\Beetle\RightBeetleWalk4.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16

LeftBeetleFly1_Char:                        include "..\sprites\enemies\Beetle\LeftBeetleFly1.tgs.gen"	;y offset, x offset  
LeftBeetleFly1_Col:                         include "..\sprites\enemies\Beetle\LeftBeetleFly1.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12
LeftBeetleFly2_Char:                        include "..\sprites\enemies\Beetle\LeftBeetleFly2.tgs.gen"	  
LeftBeetleFly2_Col:                         include "..\sprites\enemies\Beetle\LeftBeetleFly2.tcs.gen"  | db -10,12,-10,12, 06,-4,06,-4, 06,12,06,12

RightBeetleFly1_Char:                       include "..\sprites\enemies\Beetle\RightBeetleFly1.tgs.gen"	  
RightBeetleFly1_Col:                        include "..\sprites\enemies\Beetle\RightBeetleFly1.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16
RightBeetleFly2_Char:                       include "..\sprites\enemies\Beetle\RightBeetleFly2.tgs.gen"	  
RightBeetleFly2_Col:                        include "..\sprites\enemies\Beetle\RightBeetleFly2.tcs.gen"  | db -10,00,-10,00, 06,00,06,00, 06,16,06,16
	ds		$c000-$,$ff
dephase

;
; block $43 + $44
;
GreenSpiderSpriteblock:  equ   $43
BoringEyeRedSpriteblock:  equ   $43
BatSpriteblock:  equ   $43
OctopussySpriteblock:  equ   $43
phase	$8000
LeftGreenSpiderWalk1_Char:                  include "..\sprites\enemies\Spider\LeftGreenSpiderWalk1.tgs.gen"	;y offset, x offset  
LeftGreenSpiderWalk1_Col:                   include "..\sprites\enemies\Spider\LeftGreenSpiderWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
LeftGreenSpiderWalk2_Char:                  include "..\sprites\enemies\Spider\LeftGreenSpiderWalk2.tgs.gen"	  
LeftGreenSpiderWalk2_Col:                   include "..\sprites\enemies\Spider\LeftGreenSpiderWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreenSpiderWalk3_Char:                  include "..\sprites\enemies\Spider\LeftGreenSpiderWalk3.tgs.gen"	  
LeftGreenSpiderWalk3_Col:                   include "..\sprites\enemies\Spider\LeftGreenSpiderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreenSpiderWalk4_Char:                  include "..\sprites\enemies\Spider\LeftGreenSpiderWalk4.tgs.gen"	  
LeftGreenSpiderWalk4_Col:                   include "..\sprites\enemies\Spider\LeftGreenSpiderWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

RightGreenSpiderWalk1_Char:                 include "..\sprites\enemies\Spider\RightGreenSpiderWalk1.tgs.gen"	  
RightGreenSpiderWalk1_Col:                  include "..\sprites\enemies\Spider\RightGreenSpiderWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
RightGreenSpiderWalk2_Char:                 include "..\sprites\enemies\Spider\RightGreenSpiderWalk2.tgs.gen"	  
RightGreenSpiderWalk2_Col:                  include "..\sprites\enemies\Spider\RightGreenSpiderWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreenSpiderWalk3_Char:                 include "..\sprites\enemies\Spider\RightGreenSpiderWalk3.tgs.gen"	  
RightGreenSpiderWalk3_Col:                  include "..\sprites\enemies\Spider\RightGreenSpiderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreenSpiderWalk4_Char:                 include "..\sprites\enemies\Spider\RightGreenSpiderWalk4.tgs.gen"	  
RightGreenSpiderWalk4_Col:                  include "..\sprites\enemies\Spider\RightGreenSpiderWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

LeftGreenSpiderOrangeEyesWalk1_Char:        include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk1.tgs.gen"	  
LeftGreenSpiderOrangeEyesWalk1_Col:         include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
LeftGreenSpiderOrangeEyesWalk2_Char:        include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk2.tgs.gen"	  
LeftGreenSpiderOrangeEyesWalk2_Col:         include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreenSpiderOrangeEyesWalk3_Char:        include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk3.tgs.gen"	  
LeftGreenSpiderOrangeEyesWalk3_Col:         include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreenSpiderOrangeEyesWalk4_Char:        include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk4.tgs.gen"	  
LeftGreenSpiderOrangeEyesWalk4_Col:         include "..\sprites\enemies\Spider\LeftGreenSpiderOrangeEyesWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

RightGreenSpiderOrangeEyesWalk1_Char:       include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk1.tgs.gen"	  
RightGreenSpiderOrangeEyesWalk1_Col:        include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
RightGreenSpiderOrangeEyesWalk2_Char:       include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk2.tgs.gen"	  
RightGreenSpiderOrangeEyesWalk2_Col:        include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreenSpiderOrangeEyesWalk3_Char:       include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk3.tgs.gen"	  
RightGreenSpiderOrangeEyesWalk3_Col:        include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreenSpiderOrangeEyesWalk4_Char:       include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk4.tgs.gen"	  
RightGreenSpiderOrangeEyesWalk4_Col:        include "..\sprites\enemies\Spider\RightGreenSpiderOrangeEyesWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

BoringEyeRed1_Char:                         include "..\sprites\enemies\BoringEye\BoringEyeRed1.tgs.gen"	;y offset, x offset  
BoringEyeRed1_Col:                          include "..\sprites\enemies\BoringEye\BoringEyeRed1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeRed2_Char:                         include "..\sprites\enemies\BoringEye\BoringEyeRed2.tgs.gen"	  
BoringEyeRed2_Col:                          include "..\sprites\enemies\BoringEye\BoringEyeRed2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeRed3_Char:                         include "..\sprites\enemies\BoringEye\BoringEyeRed3.tgs.gen"	  
BoringEyeRed3_Col:                          include "..\sprites\enemies\BoringEye\BoringEyeRed3.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeRed4_Char:                         include "..\sprites\enemies\BoringEye\BoringEyeRed4.tgs.gen"	  
BoringEyeRed4_Col:                          include "..\sprites\enemies\BoringEye\BoringEyeRed4.tcs.gen"  | db 00,00,00,00, 16,00,16,00

LeftBat1_Char:                              include "..\sprites\enemies\Bat\LeftBat1.tgs.gen"	;y offset, x offset  
LeftBat1_Col:                               include "..\sprites\enemies\Bat\LeftBat1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftBat2_Char:                              include "..\sprites\enemies\Bat\LeftBat2.tgs.gen"	  
LeftBat2_Col:                               include "..\sprites\enemies\Bat\LeftBat2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftBat3_Char:                              include "..\sprites\enemies\Bat\LeftBat3.tgs.gen"	  
LeftBat3_Col:                               include "..\sprites\enemies\Bat\LeftBat3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftBat4_Char:                              include "..\sprites\enemies\Bat\LeftBat4.tgs.gen"	  
LeftBat4_Col:                               include "..\sprites\enemies\Bat\LeftBat4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightBat1_Char:                             include "..\sprites\enemies\Bat\RightBat1.tgs.gen"	  
RightBat1_Col:                              include "..\sprites\enemies\Bat\RightBat1.tcs.gen"  | db 00,-10,00,-10, 00,06,00,06, 16,-10,16,-10, 16,06,16,06
RightBat2_Char:                             include "..\sprites\enemies\Bat\RightBat2.tgs.gen"	  
RightBat2_Col:                              include "..\sprites\enemies\Bat\RightBat2.tcs.gen"  | db 00,-10,00,-10, 00,06,00,06, 16,-10,16,-10, 16,06,16,06
RightBat3_Char:                             include "..\sprites\enemies\Bat\RightBat3.tgs.gen"	  
RightBat3_Col:                              include "..\sprites\enemies\Bat\RightBat3.tcs.gen"  | db 00,-10,00,-10, 00,06,00,06, 16,-10,16,-10, 16,06,16,06
RightBat4_Char:                             include "..\sprites\enemies\Bat\RightBat4.tgs.gen"	  
RightBat4_Col:                              include "..\sprites\enemies\Bat\RightBat4.tcs.gen"  | db 00,-10,00,-10, 00,06,00,06, 16,-10,16,-10, 16,06,16,06

LeftOctopussy1_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy1.tgs.gen"	 ;y offset, x offset   
LeftOctopussy1_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy1.tcs.gen"  | db -1,00,-1,00
LeftOctopussy2_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy2.tgs.gen"	  
LeftOctopussy2_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy2.tcs.gen"  | db -2,00,-2,00
LeftOctopussy3_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy3.tgs.gen"	  
LeftOctopussy3_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy3.tcs.gen"  | db -1,00,-1,00
LeftOctopussy4_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy4.tgs.gen"	  
LeftOctopussy4_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy4.tcs.gen"  | db 00,00,00,00
LeftOctopussy5_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy5.tgs.gen"	  
LeftOctopussy5_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy5.tcs.gen"  | db 01,00,01,00
LeftOctopussy6_Char:                        include "..\sprites\enemies\Octopussy\LeftOctopussy6.tgs.gen"	  
LeftOctopussy6_Col:                         include "..\sprites\enemies\Octopussy\LeftOctopussy6.tcs.gen"  | db 00,00,00,00

RightOctopussy1_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy1.tgs.gen"	  
RightOctopussy1_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy1.tcs.gen"  | db -1,00,-1,00
RightOctopussy2_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy2.tgs.gen"	  
RightOctopussy2_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy2.tcs.gen"  | db -2,00,-2,00
RightOctopussy3_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy3.tgs.gen"	  
RightOctopussy3_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy3.tcs.gen"  | db -1,00,-1,00
RightOctopussy4_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy4.tgs.gen"	  
RightOctopussy4_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy4.tcs.gen"  | db 00,00,00,00
RightOctopussy5_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy5.tgs.gen"	  
RightOctopussy5_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy5.tcs.gen"  | db 01,00,01,00
RightOctopussy6_Char:                       include "..\sprites\enemies\Octopussy\RightOctopussy6.tgs.gen"	  
RightOctopussy6_Col:                        include "..\sprites\enemies\Octopussy\RightOctopussy6.tcs.gen"  | db 00,00,00,00

LeftOctopussyEyesOpen1_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen1.tgs.gen"	 ;y offset, x offset   
LeftOctopussyEyesOpen1_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen1.tcs.gen"  | db -1,00,-1,00
LeftOctopussyEyesOpen2_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen2.tgs.gen"	  
LeftOctopussyEyesOpen2_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen2.tcs.gen"  | db -2,00,-2,00
LeftOctopussyEyesOpen3_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen3.tgs.gen"	  
LeftOctopussyEyesOpen3_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen3.tcs.gen"  | db -1,00,-1,00
LeftOctopussyEyesOpen4_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen4.tgs.gen"	  
LeftOctopussyEyesOpen4_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen4.tcs.gen"  | db 00,00,00,00
LeftOctopussyEyesOpen5_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen5.tgs.gen"	  
LeftOctopussyEyesOpen5_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen5.tcs.gen"  | db 01,00,01,00
LeftOctopussyEyesOpen6_Char:                include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen6.tgs.gen"	  
LeftOctopussyEyesOpen6_Col:                 include "..\sprites\enemies\Octopussy\LeftOctopussyEyesOpen6.tcs.gen"  | db 00,00,00,00

RightOctopussyEyesOpen1_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen1.tgs.gen"	  
RightOctopussyEyesOpen1_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen1.tcs.gen"  | db -1,00,-1,00
RightOctopussyEyesOpen2_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen2.tgs.gen"	  
RightOctopussyEyesOpen2_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen2.tcs.gen"  | db -2,00,-2,00
RightOctopussyEyesOpen3_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen3.tgs.gen"	  
RightOctopussyEyesOpen3_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen3.tcs.gen"  | db -1,00,-1,00
RightOctopussyEyesOpen4_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen4.tgs.gen"	  
RightOctopussyEyesOpen4_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen4.tcs.gen"  | db 00,00,00,00
RightOctopussyEyesOpen5_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen5.tgs.gen"	  
RightOctopussyEyesOpen5_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen5.tcs.gen"  | db 01,00,01,00
RightOctopussyEyesOpen6_Char:               include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen6.tgs.gen"	  
RightOctopussyEyesOpen6_Col:                include "..\sprites\enemies\Octopussy\RightOctopussyEyesOpen6.tcs.gen"  | db 00,00,00,00

LeftOctopussyAttack_Char:                   include "..\sprites\enemies\Octopussy\LeftOctopussyAttack.tgs.gen"	 ;y offset, x offset   
LeftOctopussyAttack_Col:                    include "..\sprites\enemies\Octopussy\LeftOctopussyAttack.tcs.gen"  | db 00,00,00,00

RightOctopussyAttack_Char:                  include "..\sprites\enemies\Octopussy\RightOctopussyAttack.tgs.gen"	  
RightOctopussyAttack_Col:                   include "..\sprites\enemies\Octopussy\RightOctopussyAttack.tcs.gen"  | db 00,00,00,00

	ds		$c000-$,$ff
dephase

;
; block $45 + $46
;
GreySpiderSpriteblock:  equ   $45
BoringEyeGreenSpriteblock:  equ   $45
HunchbackSpriteblock:  equ   $45
phase	$8000
LeftGreySpiderWalk1_Char:                   include "..\sprites\enemies\Spider\LeftGreySpiderWalk1.tgs.gen"	 ;y offset, x offset 
LeftGreySpiderWalk1_Col:                    include "..\sprites\enemies\Spider\LeftGreySpiderWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
LeftGreySpiderWalk2_Char:                   include "..\sprites\enemies\Spider\LeftGreySpiderWalk2.tgs.gen"	  
LeftGreySpiderWalk2_Col:                    include "..\sprites\enemies\Spider\LeftGreySpiderWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreySpiderWalk3_Char:                   include "..\sprites\enemies\Spider\LeftGreySpiderWalk3.tgs.gen"	  
LeftGreySpiderWalk3_Col:                    include "..\sprites\enemies\Spider\LeftGreySpiderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreySpiderWalk4_Char:                   include "..\sprites\enemies\Spider\LeftGreySpiderWalk4.tgs.gen"	  
LeftGreySpiderWalk4_Col:                    include "..\sprites\enemies\Spider\LeftGreySpiderWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

RightGreySpiderWalk1_Char:                  include "..\sprites\enemies\Spider\RightGreySpiderWalk1.tgs.gen"	  
RightGreySpiderWalk1_Col:                   include "..\sprites\enemies\Spider\RightGreySpiderWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
RightGreySpiderWalk2_Char:                  include "..\sprites\enemies\Spider\RightGreySpiderWalk2.tgs.gen"	  
RightGreySpiderWalk2_Col:                   include "..\sprites\enemies\Spider\RightGreySpiderWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreySpiderWalk3_Char:                  include "..\sprites\enemies\Spider\RightGreySpiderWalk3.tgs.gen"	  
RightGreySpiderWalk3_Col:                   include "..\sprites\enemies\Spider\RightGreySpiderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreySpiderWalk4_Char:                  include "..\sprites\enemies\Spider\RightGreySpiderWalk4.tgs.gen"	  
RightGreySpiderWalk4_Col:                   include "..\sprites\enemies\Spider\RightGreySpiderWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

LeftGreySpiderOrangeEyesWalk1_Char:         include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk1.tgs.gen"	  
LeftGreySpiderOrangeEyesWalk1_Col:          include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
LeftGreySpiderOrangeEyesWalk2_Char:         include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk2.tgs.gen"	  
LeftGreySpiderOrangeEyesWalk2_Col:          include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreySpiderOrangeEyesWalk3_Char:         include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk3.tgs.gen"	  
LeftGreySpiderOrangeEyesWalk3_Col:          include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
LeftGreySpiderOrangeEyesWalk4_Char:         include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk4.tgs.gen"	  
LeftGreySpiderOrangeEyesWalk4_Col:          include "..\sprites\enemies\Spider\LeftGreySpiderOrangeEyesWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

RightGreySpiderOrangeEyesWalk1_Char:        include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk1.tgs.gen"	  
RightGreySpiderOrangeEyesWalk1_Col:         include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk1.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16
RightGreySpiderOrangeEyesWalk2_Char:        include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk2.tgs.gen"	  
RightGreySpiderOrangeEyesWalk2_Col:         include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreySpiderOrangeEyesWalk3_Char:        include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk3.tgs.gen"	  
RightGreySpiderOrangeEyesWalk3_Col:         include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16
RightGreySpiderOrangeEyesWalk4_Char:        include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk4.tgs.gen"	  
RightGreySpiderOrangeEyesWalk4_Col:         include "..\sprites\enemies\Spider\RightGreySpiderOrangeEyesWalk4.tcs.gen"  | db -1,00,-1,00, -1,16,-1,16

BoringEyeGreen1_Char:                       include "..\sprites\enemies\BoringEye\BoringEyeGreen1.tgs.gen"	;y offset, x offset  
BoringEyeGreen1_Col:                        include "..\sprites\enemies\BoringEye\BoringEyeGreen1.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeGreen2_Char:                       include "..\sprites\enemies\BoringEye\BoringEyeGreen2.tgs.gen"	  
BoringEyeGreen2_Col:                        include "..\sprites\enemies\BoringEye\BoringEyeGreen2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeGreen3_Char:                       include "..\sprites\enemies\BoringEye\BoringEyeGreen3.tgs.gen"	  
BoringEyeGreen3_Col:                        include "..\sprites\enemies\BoringEye\BoringEyeGreen3.tcs.gen"  | db 00,00,00,00, 16,00,16,00
BoringEyeGreen4_Char:                       include "..\sprites\enemies\BoringEye\BoringEyeGreen4.tgs.gen"	  
BoringEyeGreen4_Col:                        include "..\sprites\enemies\BoringEye\BoringEyeGreen4.tcs.gen"  | db 00,00,00,00, 16,00,16,00

LeftHunchback1_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback1.tgs.gen"	 ;y offset, x offset   
LeftHunchback1_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback1.tcs.gen"  | db 00,00+7-6,00,00+7-6, 00,16+7-6,00,16+7-6, 16,00+7-6,16,00+7-6, 16,16+7-6,16,16+7-6
LeftHunchback2_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback2.tgs.gen"	  
LeftHunchback2_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback2.tcs.gen"  | db 00,00+6-6,00,00+6-6, 00,16+6-6,00,16+6-6, 16,00+6-6,16,00+6-6, 16,16+6-6,16,16+6-6
LeftHunchback3_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback3.tgs.gen"	  
LeftHunchback3_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback3.tcs.gen"  | db 00,00+6-6,00,00+6-6, 00,16+6-6,00,16+6-6, 16,00+6-6,16,00+6-6, 16,16+6-6,16,16+6-6
LeftHunchback4_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback4.tgs.gen"	  
LeftHunchback4_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback4.tcs.gen"  | db 00,00+5-6,00,00+5-6, 00,16+5-6,00,16+5-6, 16,00+5-6,16,00+5-6, 16,16+5-6,16,16+5-6
LeftHunchback5_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback5.tgs.gen"	  
LeftHunchback5_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback5.tcs.gen"  | db 00,00+5-6,00,00+5-6, 00,16+5-6,00,16+5-6, 16,00+5-6,16,00+5-6, 16,16+5-6,16,16+5-6
LeftHunchback6_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback6.tgs.gen"	  
LeftHunchback6_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback6.tcs.gen"  | db 00,00+2-6,00,00+2-6, 00,16+2-6,00,16+2-6, 16,00+2-6,16,00+2-6, 16,16+2-6,16,16+2-6
LeftHunchback7_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback7.tgs.gen"	  
LeftHunchback7_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback7.tcs.gen"  | db 00,00+3-6,00,00+3-6, 00,16+3-6,00,16+3-6, 16,00+3-6,16,00+3-6, 16,16+3-6,16,16+3-6
LeftHunchback8_Char:                        include "..\sprites\enemies\Hunchback\LeftHunchback8.tgs.gen"	  
LeftHunchback8_Col:                         include "..\sprites\enemies\Hunchback\LeftHunchback8.tcs.gen"  | db 00,00+0-6,00,00+0-6, 00,16+0-6,00,16+0-6, 16,00+0-6,16,00+0-6, 16,16+0-6,16,16+0-6

RightHunchback1_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback1.tgs.gen"	  
RightHunchback1_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback1.tcs.gen"  | db 00,00-2+0,00,00-2+0, 00,16-2+0,00,16-2+0, 16,00-2+0,16,00-2+0, 16,16-2+0,16,16-2+0
RightHunchback2_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback2.tgs.gen"	  
RightHunchback2_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback2.tcs.gen"  | db 00,00-2+1,00,00-2+1, 00,16-2+1,00,16-2+1, 16,00-2+1,16,00-2+1, 16,16-2+1,16,16-2+1
RightHunchback3_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback3.tgs.gen"	  
RightHunchback3_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback3.tcs.gen"  | db 00,00-2+1,00,00-2+1, 00,16-2+1,00,16-2+1, 16,00-2+1,16,00-2+1, 16,16-2+1,16,16-2+1
RightHunchback4_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback4.tgs.gen"	  
RightHunchback4_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback4.tcs.gen"  | db 00,00-2+2,00,00-2+2, 00,16-2+2,00,16-2+2, 16,00-2+2,16,00-2+2, 16,16-2+2,16,16-2+2
RightHunchback5_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback5.tgs.gen"	  
RightHunchback5_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback5.tcs.gen"  | db 00,00-2+2,00,00-2+2, 00,16-2+2,00,16-2+2, 16,00-2+2,16,00-2+2, 16,16-2+2,16,16-2+2
RightHunchback6_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback6.tgs.gen"	  
RightHunchback6_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback6.tcs.gen"  | db 00,00-2+5,00,00-2+5, 00,16-2+5,00,16-2+5, 16,00-2+5,16,00-2+5, 16,16-2+5,16,16-2+5
RightHunchback7_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback7.tgs.gen"	  
RightHunchback7_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback7.tcs.gen"  | db 00,00-2+4,00,00-2+4, 00,16-2+4,00,16-2+4, 16,00-2+4,16,00-2+4, 16,16-2+4,16,16-2+4
RightHunchback8_Char:                       include "..\sprites\enemies\Hunchback\RightHunchback8.tgs.gen"	  
RightHunchback8_Col:                        include "..\sprites\enemies\Hunchback\RightHunchback8.tcs.gen"  | db 00,00-2+7,00,00-2+7, 00,16-2+7,00,16-2+7, 16,00-2+7,16,00-2+7, 16,16-2+7,16,16-2+7
	ds		$c000-$,$ff
dephase

;
; block $47 + $48
;
RedExplosionSpriteblock:  equ   $47
ScorpionSpriteblock:  equ   $47
phase	$8000
RedExplosionSmall1_Char:                    include "..\sprites\explosions\RedExplosionSmall1.tgs.gen"	;y offset, x offset  
RedExplosionSmall1_col:                     include "..\sprites\explosions\RedExplosionSmall1.tcs.gen"  | db 00,00,00,00
RedExplosionSmall2_Char:                    include "..\sprites\explosions\RedExplosionSmall2.tgs.gen"	  
RedExplosionSmall2_col:                     include "..\sprites\explosions\RedExplosionSmall2.tcs.gen"  | db 00,00,00,00
RedExplosionSmall3_Char:                    include "..\sprites\explosions\RedExplosionSmall3.tgs.gen"	  
RedExplosionSmall3_col:                     include "..\sprites\explosions\RedExplosionSmall3.tcs.gen"  | db 00,00,00,00
RedExplosionSmall4_Char:                    include "..\sprites\explosions\RedExplosionSmall4.tgs.gen"	  
RedExplosionSmall4_col:                     include "..\sprites\explosions\RedExplosionSmall4.tcs.gen"  | db 00,00,00,00

RedExplosionBig1_Char:                      include "..\sprites\explosions\RedExplosionBig1.tgs.gen"	  
RedExplosionBig1_col:                       include "..\sprites\explosions\RedExplosionBig1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RedExplosionBig2_Char:                      include "..\sprites\explosions\RedExplosionBig2.tgs.gen"	  
RedExplosionBig2_col:                       include "..\sprites\explosions\RedExplosionBig2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RedExplosionBig3_Char:                      include "..\sprites\explosions\RedExplosionBig3.tgs.gen"	  
RedExplosionBig3_col:                       include "..\sprites\explosions\RedExplosionBig3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RedExplosionBig4_Char:                      include "..\sprites\explosions\RedExplosionBig4.tgs.gen"	  
RedExplosionBig4_col:                       include "..\sprites\explosions\RedExplosionBig4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RedExplosionBig5_Char:                      include "..\sprites\explosions\RedExplosionBig5.tgs.gen"	  
RedExplosionBig5_col:                       include "..\sprites\explosions\RedExplosionBig5.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

LeftScorpionWalk1_Char:                     include "..\sprites\enemies\Scorpion\LeftScorpionWalk1.tgs.gen"	 ;y offset, x offset 
LeftScorpionWalk1_Col:                      include "..\sprites\enemies\Scorpion\LeftScorpionWalk1.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10
LeftScorpionWalk2_Char:                     include "..\sprites\enemies\Scorpion\LeftScorpionWalk2.tgs.gen"	  
LeftScorpionWalk2_Col:                      include "..\sprites\enemies\Scorpion\LeftScorpionWalk2.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10
LeftScorpionWalk3_Char:                     include "..\sprites\enemies\Scorpion\LeftScorpionWalk3.tgs.gen"	  
LeftScorpionWalk3_Col:                      include "..\sprites\enemies\Scorpion\LeftScorpionWalk3.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10
LeftScorpionWalk4_Char:                     include "..\sprites\enemies\Scorpion\LeftScorpionWalk4.tgs.gen"	  
LeftScorpionWalk4_Col:                      include "..\sprites\enemies\Scorpion\LeftScorpionWalk4.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10

RightScorpionWalk1_Char:                    include "..\sprites\enemies\Scorpion\RightScorpionWalk1.tgs.gen"	  
RightScorpionWalk1_Col:                     include "..\sprites\enemies\Scorpion\RightScorpionWalk1.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16
RightScorpionWalk2_Char:                    include "..\sprites\enemies\Scorpion\RightScorpionWalk2.tgs.gen"	  
RightScorpionWalk2_Col:                     include "..\sprites\enemies\Scorpion\RightScorpionWalk2.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16
RightScorpionWalk3_Char:                    include "..\sprites\enemies\Scorpion\RightScorpionWalk3.tgs.gen"	  
RightScorpionWalk3_Col:                     include "..\sprites\enemies\Scorpion\RightScorpionWalk3.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16
RightScorpionWalk4_Char:                    include "..\sprites\enemies\Scorpion\RightScorpionWalk4.tgs.gen"	  
RightScorpionWalk4_Col:                     include "..\sprites\enemies\Scorpion\RightScorpionWalk4.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16

LeftScorpionAttack1_Char:                   include "..\sprites\enemies\Scorpion\LeftScorpionAttack1.tgs.gen"	 ;y offset, x offset 
LeftScorpionAttack1_Col:                    include "..\sprites\enemies\Scorpion\LeftScorpionAttack1.tcs.gen"  | db 00,12-10,00,12-10, 16,00-10,16,00-10, 16,16-10,16,16-10
LeftScorpionAttack2_Char:                   include "..\sprites\enemies\Scorpion\LeftScorpionAttack2.tgs.gen"	  
LeftScorpionAttack2_Col:                    include "..\sprites\enemies\Scorpion\LeftScorpionAttack2.tcs.gen"  | db 00,09-00,00,09-00, 16,00-00,16,00-00, 16,16-00,16,16-00

RightScorpionAttack1_Char:                  include "..\sprites\enemies\Scorpion\RightScorpionAttack1.tgs.gen"	  
RightScorpionAttack1_Col:                   include "..\sprites\enemies\Scorpion\RightScorpionAttack1.tcs.gen"  | db 00,04,00,04, 16,00,16,00, 16,16,16,16
RightScorpionAttack2_Char:                  include "..\sprites\enemies\Scorpion\RightScorpionAttack2.tgs.gen"	  
RightScorpionAttack2_Col:                   include "..\sprites\enemies\Scorpion\RightScorpionAttack2.tcs.gen"  | db 00,07-10,00,07-10, 16,00-10,16,00-10, 16,16-10,16,16-10

LeftScorpionRattle2_Char:                   include "..\sprites\enemies\Scorpion\LeftScorpionRattle2.tgs.gen"	 ;y offset, x offset 
LeftScorpionRattle2_Col:                    include "..\sprites\enemies\Scorpion\LeftScorpionRattle2.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10
LeftScorpionRattle3_Char:                   include "..\sprites\enemies\Scorpion\LeftScorpionRattle3.tgs.gen"	  
LeftScorpionRattle3_Col:                    include "..\sprites\enemies\Scorpion\LeftScorpionRattle3.tcs.gen"  | db 00,16-10,00,16-10, 16,00-10,16,00-10, 16,16-10,16,16-10

RightScorpionRattle2_Char:                  include "..\sprites\enemies\Scorpion\RightScorpionRattle2.tgs.gen"	  
RightScorpionRattle2_Col:                   include "..\sprites\enemies\Scorpion\RightScorpionRattle2.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16
RightScorpionRattle3_Char:                  include "..\sprites\enemies\Scorpion\RightScorpionRattle3.tgs.gen"	  
RightScorpionRattle3_Col:                   include "..\sprites\enemies\Scorpion\RightScorpionRattle3.tcs.gen"  | db 00,00,00,00, 16,00,16,00, 16,16,16,16

	ds		$c000-$,$ff
dephase

;
; block $49 + $4a
;
GreyExplosionSpriteblock:  equ   $49
phase	$8000
GreyExplosionSmall1_Char:                   include "..\sprites\explosions\GreyExplosionSmall1.tgs.gen"	 ;y offset, x offset 
GreyExplosionSmall1_col:                    include "..\sprites\explosions\GreyExplosionSmall1.tcs.gen"  | db 00,00,00,00
GreyExplosionSmall2_Char:                   include "..\sprites\explosions\GreyExplosionSmall2.tgs.gen"	  
GreyExplosionSmall2_col:                    include "..\sprites\explosions\GreyExplosionSmall2.tcs.gen"  | db 00,00,00,00
GreyExplosionSmall3_Char:                   include "..\sprites\explosions\GreyExplosionSmall3.tgs.gen"	  
GreyExplosionSmall3_col:                    include "..\sprites\explosions\GreyExplosionSmall3.tcs.gen"  | db 00,00,00,00
GreyExplosionSmall4_Char:                   include "..\sprites\explosions\GreyExplosionSmall4.tgs.gen"	  
GreyExplosionSmall4_col:                    include "..\sprites\explosions\GreyExplosionSmall4.tcs.gen"  | db 00,00,00,00

GreyExplosionBig1_Char:                     include "..\sprites\explosions\GreyExplosionBig1.tgs.gen"	  
GreyExplosionBig1_col:                      include "..\sprites\explosions\GreyExplosionBig1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
GreyExplosionBig2_Char:                     include "..\sprites\explosions\GreyExplosionBig2.tgs.gen"	  
GreyExplosionBig2_col:                      include "..\sprites\explosions\GreyExplosionBig2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
GreyExplosionBig3_Char:                     include "..\sprites\explosions\GreyExplosionBig3.tgs.gen"	  
GreyExplosionBig3_col:                      include "..\sprites\explosions\GreyExplosionBig3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
GreyExplosionBig4_Char:                     include "..\sprites\explosions\GreyExplosionBig4.tgs.gen"	  
GreyExplosionBig4_col:                      include "..\sprites\explosions\GreyExplosionBig4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
GreyExplosionBig5_Char:                     include "..\sprites\explosions\GreyExplosionBig5.tgs.gen"	  
GreyExplosionBig5_col:                      include "..\sprites\explosions\GreyExplosionBig5.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
	ds		$c000-$,$ff
dephase

;
; block $4b + $4c
;
GrinderSpriteblock:  equ   $4b
TreemanSpriteblock:  equ   $4b
phase	$8000
LeftGrinderWalk1_Char:                      include "..\sprites\enemies\Grinder\LeftGrinderWalk1.tgs.gen"	 ;y offset, x offset 
LeftGrinderWalk1_Col:                       include "..\sprites\enemies\Grinder\LeftGrinderWalk1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftGrinderWalk2_Char:                      include "..\sprites\enemies\Grinder\LeftGrinderWalk2.tgs.gen"	  
LeftGrinderWalk2_Col:                       include "..\sprites\enemies\Grinder\LeftGrinderWalk2.tcs.gen"  | db 00,-02,00,-02, 00,14,00,14, 16,-02,16,-02, 16,14,16,14
LeftGrinderWalk3_Char:                      include "..\sprites\enemies\Grinder\LeftGrinderWalk3.tgs.gen"	  
LeftGrinderWalk3_Col:                       include "..\sprites\enemies\Grinder\LeftGrinderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftGrinderWalk4_Char:                      include "..\sprites\enemies\Grinder\LeftGrinderWalk4.tgs.gen"	  
LeftGrinderWalk4_Col:                       include "..\sprites\enemies\Grinder\LeftGrinderWalk4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftGrinderWalk5_Char:                      include "..\sprites\enemies\Grinder\LeftGrinderWalk5.tgs.gen"	  
LeftGrinderWalk5_Col:                       include "..\sprites\enemies\Grinder\LeftGrinderWalk5.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightGrinderWalk1_Char:                     include "..\sprites\enemies\Grinder\RightGrinderWalk1.tgs.gen"	  
RightGrinderWalk1_Col:                      include "..\sprites\enemies\Grinder\RightGrinderWalk1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightGrinderWalk2_Char:                     include "..\sprites\enemies\Grinder\RightGrinderWalk2.tgs.gen"	  
RightGrinderWalk2_Col:                      include "..\sprites\enemies\Grinder\RightGrinderWalk2.tcs.gen"  | db 00,02,00,02, 00,18,00,18, 16,02,16,02, 16,18,16,18
RightGrinderWalk3_Char:                     include "..\sprites\enemies\Grinder\RightGrinderWalk3.tgs.gen"	  
RightGrinderWalk3_Col:                      include "..\sprites\enemies\Grinder\RightGrinderWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightGrinderWalk4_Char:                     include "..\sprites\enemies\Grinder\RightGrinderWalk4.tgs.gen"	  
RightGrinderWalk4_Col:                      include "..\sprites\enemies\Grinder\RightGrinderWalk4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightGrinderWalk5_Char:                     include "..\sprites\enemies\Grinder\RightGrinderWalk5.tgs.gen"	  
RightGrinderWalk5_Col:                      include "..\sprites\enemies\Grinder\RightGrinderWalk5.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

LeftGrinderAttack1_Char:                    include "..\sprites\enemies\Grinder\LeftGrinderAttack1.tgs.gen"	  
LeftGrinderAttack1_Col:                     include "..\sprites\enemies\Grinder\LeftGrinderAttack1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftGrinderAttack2_Char:                    include "..\sprites\enemies\Grinder\LeftGrinderAttack2.tgs.gen"	  
LeftGrinderAttack2_Col:                     include "..\sprites\enemies\Grinder\LeftGrinderAttack2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightGrinderAttack1_Char:                   include "..\sprites\enemies\Grinder\RightGrinderAttack1.tgs.gen"	  
RightGrinderAttack1_Col:                    include "..\sprites\enemies\Grinder\RightGrinderAttack1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightGrinderAttack2_Char:                   include "..\sprites\enemies\Grinder\RightGrinderAttack2.tgs.gen"	  
RightGrinderAttack2_Col:                    include "..\sprites\enemies\Grinder\RightGrinderAttack2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

LeftTreemanWalk1_Char:                      include "..\sprites\enemies\Treeman\LeftTreemanWalk1.tgs.gen"	 ;y offset, x offset 
LeftTreemanWalk1_Col:                       include "..\sprites\enemies\Treeman\LeftTreemanWalk1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftTreemanWalk2_Char:                      include "..\sprites\enemies\Treeman\LeftTreemanWalk2.tgs.gen"	  
LeftTreemanWalk2_Col:                       include "..\sprites\enemies\Treeman\LeftTreemanWalk2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftTreemanWalk3_Char:                      include "..\sprites\enemies\Treeman\LeftTreemanWalk3.tgs.gen"	  
LeftTreemanWalk3_Col:                       include "..\sprites\enemies\Treeman\LeftTreemanWalk3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftTreemanWalk4_Char:                      include "..\sprites\enemies\Treeman\LeftTreemanWalk4.tgs.gen"	  
LeftTreemanWalk4_Col:                       include "..\sprites\enemies\Treeman\LeftTreemanWalk4.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightTreemanWalk1_Char:                     include "..\sprites\enemies\Treeman\RightTreemanWalk1.tgs.gen"	  
RightTreemanWalk1_Col:                      include "..\sprites\enemies\Treeman\RightTreemanWalk1.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12
RightTreemanWalk2_Char:                     include "..\sprites\enemies\Treeman\RightTreemanWalk2.tgs.gen"	  
RightTreemanWalk2_Col:                      include "..\sprites\enemies\Treeman\RightTreemanWalk2.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12
RightTreemanWalk3_Char:                     include "..\sprites\enemies\Treeman\RightTreemanWalk3.tgs.gen"	  
RightTreemanWalk3_Col:                      include "..\sprites\enemies\Treeman\RightTreemanWalk3.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12
RightTreemanWalk4_Char:                     include "..\sprites\enemies\Treeman\RightTreemanWalk4.tgs.gen"	  
RightTreemanWalk4_Col:                      include "..\sprites\enemies\Treeman\RightTreemanWalk4.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12

LeftTreemanAttack1_Char:                    include "..\sprites\enemies\Treeman\LeftTreemanAttack1.tgs.gen"	  
LeftTreemanAttack1_Col:                     include "..\sprites\enemies\Treeman\LeftTreemanAttack1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftTreemanAttack2_Char:                    include "..\sprites\enemies\Treeman\LeftTreemanAttack2.tgs.gen"	  
LeftTreemanAttack2_Col:                     include "..\sprites\enemies\Treeman\LeftTreemanAttack2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightTreemanAttack1_Char:                   include "..\sprites\enemies\Treeman\RightTreemanAttack1.tgs.gen"	  
RightTreemanAttack1_Col:                    include "..\sprites\enemies\Treeman\RightTreemanAttack1.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12
RightTreemanAttack2_Char:                   include "..\sprites\enemies\Treeman\RightTreemanAttack2.tgs.gen"	  
RightTreemanAttack2_Col:                    include "..\sprites\enemies\Treeman\RightTreemanAttack2.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12

LeftTreemanHit_Char:                        include "..\sprites\enemies\Treeman\LeftTreemanHit.tgs.gen"	  
LeftTreemanHit_Col:                         include "..\sprites\enemies\Treeman\LeftTreemanHit.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16

RightTreemanHit_Char:                       include "..\sprites\enemies\Treeman\RightTreemanHit.tgs.gen"	  
RightTreemanHit_Col:                        include "..\sprites\enemies\Treeman\RightTreemanHit.tcs.gen"  | db 00,-4,00,-4, 00,12,00,12, 16,-4,16,-4, 16,12,16,12




	ds		$c000-$,$ff
dephase

;
; block $4d + $4e
;
GreenWaspSpriteblock:  equ   $4d
LandstriderSpriteblock:  equ   $4d
phase	$8000
LeftGreenWasp1_Char:                        include "..\sprites\enemies\Wasp\LeftGreenWasp1.tgs.gen"	;y offset, x offset  
LeftGreenWasp1_Col:                         include "..\sprites\enemies\Wasp\LeftGreenWasp1.tcs.gen"  | db 00,00,00,00
LeftGreenWasp2_Char:                        include "..\sprites\enemies\Wasp\LeftGreenWasp2.tgs.gen"	  
LeftGreenWasp2_Col:                         include "..\sprites\enemies\Wasp\LeftGreenWasp2.tcs.gen"  | db 00,00,00,00
LeftGreenWasp3_Char:                        include "..\sprites\enemies\Wasp\LeftGreenWasp3.tgs.gen"	  
LeftGreenWasp3_Col:                         include "..\sprites\enemies\Wasp\LeftGreenWasp3.tcs.gen"  | db 00,00,00,00
LeftGreenWasp4_Char:                        include "..\sprites\enemies\Wasp\LeftGreenWasp4.tgs.gen"	  
LeftGreenWasp4_Col:                         include "..\sprites\enemies\Wasp\LeftGreenWasp4.tcs.gen"  | db 00,00,00,00
LeftGreenWaspAttack_Char:                   include "..\sprites\enemies\Wasp\LeftGreenWaspAttack.tgs.gen"	  
LeftGreenWaspAttack_Col:                    include "..\sprites\enemies\Wasp\LeftGreenWaspAttack.tcs.gen"  | db 00,00,00,00

RightGreenWasp1_Char:                       include "..\sprites\enemies\Wasp\RightGreenWasp1.tgs.gen"	  
RightGreenWasp1_Col:                        include "..\sprites\enemies\Wasp\RightGreenWasp1.tcs.gen"  | db 00,00,00,00
RightGreenWasp2_Char:                       include "..\sprites\enemies\Wasp\RightGreenWasp2.tgs.gen"	  
RightGreenWasp2_Col:                        include "..\sprites\enemies\Wasp\RightGreenWasp2.tcs.gen"  | db 00,00,00,00
RightGreenWasp3_Char:                       include "..\sprites\enemies\Wasp\RightGreenWasp3.tgs.gen"	  
RightGreenWasp3_Col:                        include "..\sprites\enemies\Wasp\RightGreenWasp3.tcs.gen"  | db 00,00,00,00
RightGreenWasp4_Char:                       include "..\sprites\enemies\Wasp\RightGreenWasp4.tgs.gen"	  
RightGreenWasp4_Col:                        include "..\sprites\enemies\Wasp\RightGreenWasp4.tcs.gen"  | db 00,00,00,00
RightGreenWaspAttack_Char:                  include "..\sprites\enemies\Wasp\RightGreenWaspAttack.tgs.gen"	  
RightGreenWaspAttack_Col:                   include "..\sprites\enemies\Wasp\RightGreenWaspAttack.tcs.gen"  | db 00,00,00,00

LeftLandstrider1_Char:                      include "..\sprites\enemies\Landstrider\LeftLandstrider1.tgs.gen"	  
LeftLandstrider1_Col:                       include "..\sprites\enemies\Landstrider\LeftLandstrider1.tcs.gen"  | db 00,-1,00,-1
LeftLandstrider2_Char:                      include "..\sprites\enemies\Landstrider\LeftLandstrider2.tgs.gen"	  
LeftLandstrider2_Col:                       include "..\sprites\enemies\Landstrider\LeftLandstrider2.tcs.gen"  | db 00,00,00,00
LeftLandstrider3_Char:                      include "..\sprites\enemies\Landstrider\LeftLandstrider3.tgs.gen"	  
LeftLandstrider3_Col:                       include "..\sprites\enemies\Landstrider\LeftLandstrider3.tcs.gen"  | db 00,01,00,01
LeftLandstrider4_Char:                      include "..\sprites\enemies\Landstrider\LeftLandstrider4.tgs.gen"	  
LeftLandstrider4_Col:                       include "..\sprites\enemies\Landstrider\LeftLandstrider4.tcs.gen"  | db 00,00,00,00

RightLandstrider1_Char:                     include "..\sprites\enemies\Landstrider\RightLandstrider1.tgs.gen"	  
RightLandstrider1_Col:                      include "..\sprites\enemies\Landstrider\RightLandstrider1.tcs.gen"  | db 00,01,00,01
RightLandstrider2_Char:                     include "..\sprites\enemies\Landstrider\RightLandstrider2.tgs.gen"	  
RightLandstrider2_Col:                      include "..\sprites\enemies\Landstrider\RightLandstrider2.tcs.gen"  | db 00,00,00,00
RightLandstrider3_Char:                     include "..\sprites\enemies\Landstrider\RightLandstrider3.tgs.gen"	  
RightLandstrider3_Col:                      include "..\sprites\enemies\Landstrider\RightLandstrider3.tcs.gen"  | db 00,-1,00,-1
RightLandstrider4_Char:                     include "..\sprites\enemies\Landstrider\RightLandstrider4.tgs.gen"	  
RightLandstrider4_Col:                      include "..\sprites\enemies\Landstrider\RightLandstrider4.tcs.gen"  | db 00,00,00,00

LeftLandstriderDuck1_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderDuck1.tgs.gen"	  
LeftLandstriderDuck1_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderDuck1.tcs.gen"  | db 00,01,00,01
LeftLandstriderDuck2_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderDuck2.tgs.gen"	  
LeftLandstriderDuck2_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderDuck2.tcs.gen"  | db 00,01,00,01
LeftLandstriderDuck3_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderDuck3.tgs.gen"	  
LeftLandstriderDuck3_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderDuck3.tcs.gen"  | db 00,01,00,01
LeftLandstriderDuck4_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderDuck4.tgs.gen"	  
LeftLandstriderDuck4_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderDuck4.tcs.gen"  | db 00,01,00,01

RightLandstriderDuck1_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderDuck1.tgs.gen"	  
RightLandstriderDuck1_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderDuck1.tcs.gen"  | db 00,-1,00,-1
RightLandstriderDuck2_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderDuck2.tgs.gen"	  
RightLandstriderDuck2_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderDuck2.tcs.gen"  | db 00,-1,00,-1
RightLandstriderDuck3_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderDuck3.tgs.gen"	  
RightLandstriderDuck3_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderDuck3.tcs.gen"  | db 00,-1,00,-1
RightLandstriderDuck4_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderDuck4.tgs.gen"	  
RightLandstriderDuck4_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderDuck4.tcs.gen"  | db 00,-1,00,-1

LeftLandstriderGrow1_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderGrow1.tgs.gen"	  
LeftLandstriderGrow1_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderGrow1.tcs.gen"  | db 00,01,00,01, 16,01,16,01
LeftLandstriderGrow2_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderGrow2.tgs.gen"	  
LeftLandstriderGrow2_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderGrow2.tcs.gen"  | db 00,01,00,01, 16,01,16,01
LeftLandstriderGrow3_Char:                  include "..\sprites\enemies\Landstrider\LeftLandstriderGrow3.tgs.gen"	  
LeftLandstriderGrow3_Col:                   include "..\sprites\enemies\Landstrider\LeftLandstriderGrow3.tcs.gen"  | db 00,01,00,01, 16,01,16,01

RightLandstriderGrow1_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderGrow1.tgs.gen"	  
RightLandstriderGrow1_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderGrow1.tcs.gen"  | db 00,-1,00,-1, 16,-1,16,-1
RightLandstriderGrow2_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderGrow2.tgs.gen"	  
RightLandstriderGrow2_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderGrow2.tcs.gen"  | db 00,-1,00,-1, 16,-1,16,-1
RightLandstriderGrow3_Char:                 include "..\sprites\enemies\Landstrider\RightLandstriderGrow3.tgs.gen"	  
RightLandstriderGrow3_Col:                  include "..\sprites\enemies\Landstrider\RightLandstriderGrow3.tcs.gen"  | db 00,-1,00,-1, 16,-1,16,-1

LeftBigLandstrider1_Char:                   include "..\sprites\enemies\Landstrider\LeftBigLandstrider1.tgs.gen"	  
LeftBigLandstrider1_Col:                    include "..\sprites\enemies\Landstrider\LeftBigLandstrider1.tcs.gen"  | db 00,-1,00,-1, 16,-1,16,-1
LeftBigLandstrider2_Char:                   include "..\sprites\enemies\Landstrider\LeftBigLandstrider2.tgs.gen"	  
LeftBigLandstrider2_Col:                    include "..\sprites\enemies\Landstrider\LeftBigLandstrider2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
LeftBigLandstrider3_Char:                   include "..\sprites\enemies\Landstrider\LeftBigLandstrider3.tgs.gen"	  
LeftBigLandstrider3_Col:                    include "..\sprites\enemies\Landstrider\LeftBigLandstrider3.tcs.gen"  | db 00,01,00,01, 16,01,16,01
LeftBigLandstrider4_Char:                   include "..\sprites\enemies\Landstrider\LeftBigLandstrider4.tgs.gen"	  
LeftBigLandstrider4_Col:                    include "..\sprites\enemies\Landstrider\LeftBigLandstrider4.tcs.gen"  | db 00,00,00,00, 16,00,16,00

RightBigLandstrider1_Char:                  include "..\sprites\enemies\Landstrider\RightBigLandstrider1.tgs.gen"	  
RightBigLandstrider1_Col:                   include "..\sprites\enemies\Landstrider\RightBigLandstrider1.tcs.gen"  | db 00,01,00,01, 16,01,16,01
RightBigLandstrider2_Char:                  include "..\sprites\enemies\Landstrider\RightBigLandstrider2.tgs.gen"	  
RightBigLandstrider2_Col:                   include "..\sprites\enemies\Landstrider\RightBigLandstrider2.tcs.gen"  | db 00,00,00,00, 16,00,16,00
RightBigLandstrider3_Char:                  include "..\sprites\enemies\Landstrider\RightBigLandstrider3.tgs.gen"	  
RightBigLandstrider3_Col:                   include "..\sprites\enemies\Landstrider\RightBigLandstrider3.tcs.gen"  | db 00,-1,00,-1, 16,-1,16,-1
RightBigLandstrider4_Char:                  include "..\sprites\enemies\Landstrider\RightBigLandstrider4.tgs.gen"	  
RightBigLandstrider4_Col:                   include "..\sprites\enemies\Landstrider\RightBigLandstrider4.tcs.gen"  | db 00,00,00,00, 16,00,16,00

	ds		$c000-$,$ff
dephase

;
; block $4f + $50
;
BrownWaspSpriteblock:  equ   $4f
phase	$8000
LeftBrownWasp1_Char:                        include "..\sprites\enemies\Wasp\LeftBrownWasp1.tgs.gen"	;y offset, x offset  
LeftBrownWasp1_Col:                         include "..\sprites\enemies\Wasp\LeftBrownWasp1.tcs.gen"  | db 00,00,00,00
LeftBrownWasp2_Char:                        include "..\sprites\enemies\Wasp\LeftBrownWasp2.tgs.gen"	  
LeftBrownWasp2_Col:                         include "..\sprites\enemies\Wasp\LeftBrownWasp2.tcs.gen"  | db 00,00,00,00
LeftBrownWasp3_Char:                        include "..\sprites\enemies\Wasp\LeftBrownWasp3.tgs.gen"	  
LeftBrownWasp3_Col:                         include "..\sprites\enemies\Wasp\LeftBrownWasp3.tcs.gen"  | db 00,00,00,00
LeftBrownWasp4_Char:                        include "..\sprites\enemies\Wasp\LeftBrownWasp4.tgs.gen"	  
LeftBrownWasp4_Col:                         include "..\sprites\enemies\Wasp\LeftBrownWasp4.tcs.gen"  | db 00,00,00,00
LeftBrownWaspAttack_Char:                   include "..\sprites\enemies\Wasp\LeftBrownWaspAttack.tgs.gen"	  
LeftBrownWaspAttack_Col:                    include "..\sprites\enemies\Wasp\LeftBrownWaspAttack.tcs.gen"  | db 00,00,00,00

RightBrownWasp1_Char:                       include "..\sprites\enemies\Wasp\RightBrownWasp1.tgs.gen"	  
RightBrownWasp1_Col:                        include "..\sprites\enemies\Wasp\RightBrownWasp1.tcs.gen"  | db 00,00,00,00
RightBrownWasp2_Char:                       include "..\sprites\enemies\Wasp\RightBrownWasp2.tgs.gen"	  
RightBrownWasp2_Col:                        include "..\sprites\enemies\Wasp\RightBrownWasp2.tcs.gen"  | db 00,00,00,00
RightBrownWasp3_Char:                       include "..\sprites\enemies\Wasp\RightBrownWasp3.tgs.gen"	  
RightBrownWasp3_Col:                        include "..\sprites\enemies\Wasp\RightBrownWasp3.tcs.gen"  | db 00,00,00,00
RightBrownWasp4_Char:                       include "..\sprites\enemies\Wasp\RightBrownWasp4.tgs.gen"	  
RightBrownWasp4_Col:                        include "..\sprites\enemies\Wasp\RightBrownWasp4.tcs.gen"  | db 00,00,00,00
RightBrownWaspAttack_Char:                  include "..\sprites\enemies\Wasp\RightBrownWaspAttack.tgs.gen"	  
RightBrownWaspAttack_Col:                   include "..\sprites\enemies\Wasp\RightBrownWaspAttack.tcs.gen"  | db 00,00,00,00
	ds		$c000-$,$ff
dephase

;
; block $51 + $52
;
FireEyeGreySpriteblock:  equ   $51
DemontjeBrownSpriteblock:  equ   $51
HugeBlobSpriteblock:  equ   $51
phase	$8000
LeftDemontjeBrown1_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeBrown1.tgs.gen"	;y offset, x offset  
LeftDemontjeBrown1_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeBrown1.tcs.gen"  | db 00,01,00,01
LeftDemontjeBrown2_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeBrown2.tgs.gen"	  
LeftDemontjeBrown2_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeBrown2.tcs.gen"  | db 00,00,00,00
LeftDemontjeBrown3_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeBrown3.tgs.gen"	  
LeftDemontjeBrown3_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeBrown3.tcs.gen"  | db 00,00,00,00
LeftDemontjeBrown4_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeBrown4.tgs.gen"	  
LeftDemontjeBrown4_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeBrown4.tcs.gen"  | db 00,00,00,00

RightDemontjeBrown1_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeBrown1.tgs.gen"	  
RightDemontjeBrown1_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeBrown1.tcs.gen"  | db 00,-1,00,-1
RightDemontjeBrown2_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeBrown2.tgs.gen"	  
RightDemontjeBrown2_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeBrown2.tcs.gen"  | db 00,00,00,00
RightDemontjeBrown3_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeBrown3.tgs.gen"	  
RightDemontjeBrown3_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeBrown3.tcs.gen"  | db 00,00,00,00
RightDemontjeBrown4_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeBrown4.tgs.gen"	  
RightDemontjeBrown4_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeBrown4.tcs.gen"  | db 00,00,00,00

FireEyeGrey1_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey1.tgs.gen"	 ;y offset, x offset 
FireEyeGrey1_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey1.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGrey2_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey2.tgs.gen"	  
FireEyeGrey2_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey2.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGrey3_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey3.tgs.gen"	  
FireEyeGrey3_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey3.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGrey4_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey4.tgs.gen"	  
FireEyeGrey4_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey4.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGrey5_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey5.tgs.gen"	  
FireEyeGrey5_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey5.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGrey6_Char:                          include "..\sprites\enemies\FireEye\FireEyeGrey6.tgs.gen"	  
FireEyeGrey6_Col:                           include "..\sprites\enemies\FireEye\FireEyeGrey6.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16

HugeBlob1_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob1.tgs.gen"	 ;y offset, x offset 
HugeBlob1_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob1.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
HugeBlob2_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob2.tgs.gen"	  
HugeBlob2_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
HugeBlob3_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob3.tgs.gen"	  
HugeBlob3_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,12,16,12, 16,28,16,28, 32,00,32,00, 32,16,32,16
HugeBlob4_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob4.tgs.gen"	  
HugeBlob4_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob4.tcs.gen"  | db 00,14,00,14, 00,30,00,30, 16,06,16,06, 16,22,16,22, 32,06,32,06, 32,22,32,22
HugeBlob5_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob5.tgs.gen"	  
HugeBlob5_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob5.tcs.gen"  | db 00,10,00,10, 00,26,00,26, 16,08,16,08, 16,24,16,24, 32,08,32,08, 32,24,32,24
HugeBlob6_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob6.tgs.gen"	  
HugeBlob6_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob6.tcs.gen"  | db 00,00,00,00, 00,17,00,17, 16,06,16,06, 16,22,16,22, 32,06,32,06, 32,22,32,22
HugeBlob7_Char:                             include "..\sprites\enemies\HugeBlob\HugeBlob7.tgs.gen"	  
HugeBlob7_Col:                              include "..\sprites\enemies\HugeBlob\HugeBlob7.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,02,16,02, 16,18,16,18, 32,02,32,02, 32,18,32,18
	ds		$c000-$,$ff
dephase

;
; block $53 + $54
;
FireEyeGreenSpriteblock:  equ   $53
DemontjeGreenSpriteblock:  equ   $53
HugeBlobWhiteSpriteblock:  equ   $53
SensorTentaclesSpriteblock:  equ   $53
YellowWaspSpriteblock:  equ   $53
phase	$8000
LeftDemontjeGreen1_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeGreen1.tgs.gen"	;y offset, x offset  
LeftDemontjeGreen1_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeGreen1.tcs.gen"  | db 00,01,00,01
LeftDemontjeGreen2_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeGreen2.tgs.gen"	  
LeftDemontjeGreen2_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeGreen2.tcs.gen"  | db 00,00,00,00
LeftDemontjeGreen3_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeGreen3.tgs.gen"	  
LeftDemontjeGreen3_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeGreen3.tcs.gen"  | db 00,00,00,00
LeftDemontjeGreen4_Char:                    include "..\sprites\enemies\Demontje\LeftDemontjeGreen4.tgs.gen"	  
LeftDemontjeGreen4_Col:                     include "..\sprites\enemies\Demontje\LeftDemontjeGreen4.tcs.gen"  | db 00,00,00,00

RightDemontjeGreen1_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeGreen1.tgs.gen"	  
RightDemontjeGreen1_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeGreen1.tcs.gen"  | db 00,-1,00,-1
RightDemontjeGreen2_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeGreen2.tgs.gen"	  
RightDemontjeGreen2_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeGreen2.tcs.gen"  | db 00,00,00,00
RightDemontjeGreen3_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeGreen3.tgs.gen"	  
RightDemontjeGreen3_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeGreen3.tcs.gen"  | db 00,00,00,00
RightDemontjeGreen4_Char:                   include "..\sprites\enemies\Demontje\RightDemontjeGreen4.tgs.gen"	  
RightDemontjeGreen4_Col:                    include "..\sprites\enemies\Demontje\RightDemontjeGreen4.tcs.gen"  | db 00,00,00,00

FireEyeGreen1_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen1.tgs.gen"	 ;y offset, x offset 
FireEyeGreen1_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen1.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGreen2_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen2.tgs.gen"	  
FireEyeGreen2_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen2.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGreen3_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen3.tgs.gen"	  
FireEyeGreen3_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen3.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGreen4_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen4.tgs.gen"	  
FireEyeGreen4_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen4.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGreen5_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen5.tgs.gen"	  
FireEyeGreen5_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen5.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16
FireEyeGreen6_Char:                         include "..\sprites\enemies\FireEye\FireEyeGreen6.tgs.gen"	  
FireEyeGreen6_Col:                          include "..\sprites\enemies\FireEye\FireEyeGreen6.tcs.gen"  | db 00,08,00,08,00,08, 16,00,16,00, 16,16,16,16, 32,00,32,00, 32,16,32,16

HugeBlobWhite1_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\1.spr",0,384 | ds 192,9 | db 00,00+00, 00,16+00, 00,32+00, 00,48+00, 16,00+00, 16,16+00, 16,32+00, 16,48+00, 32,00+00, 32,16+00, 32,32+00, 32,48+00
HugeBlobWhite2_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\2.spr",0,384 | ds 192,9 | db 00,00+00, 00,16+00, 00,32+00, 00,48+00, 16,00+00, 16,16+00, 16,32+00, 16,48+00, 32,00+00, 32,16+00, 32,32+00, 32,48+00
HugeBlobWhite3_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\3.spr",0,384 | ds 192,9 | db 00,00+00, 00,16+00, 00,32+00, 00,48+00, 16,00+00, 16,16+00, 16,32+00, 16,48+00, 32,00+00, 32,16+00, 32,32+00, 32,48+00
HugeBlobWhite4_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\4.spr",0,384 | ds 192,9 | db 00,00+06, 00,16+06, 00,32+06, 00,48+06, 16,00+06, 16,16+06, 16,32+06, 16,48+06, 32,00+06, 32,16+06, 32,32+06, 32,48+06
HugeBlobWhite5_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\5.spr",0,384 | ds 192,9 | db 00,00+08, 00,16+08, 00,32+08, 00,48+08, 16,00+08, 16,16+08, 16,32+08, 16,48+08, 32,00+08, 32,16+08, 32,32+08, 32,48+08
HugeBlobWhite6_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\6.spr",0,384 | ds 192,9 | db 00,00+06, 00,16+06, 00,32+06, 00,48+06, 16,00+06, 16,16+06, 16,32+06, 16,48+06, 32,00+06, 32,16+06, 32,32+06, 32,48+06
HugeBlobWhite7_Char:                        incbin "..\sprites\enemies\HugeBlob\HugeBlobWhite\7.spr",0,384 | ds 192,9 | db 00,00+02, 00,16+02, 00,32+02, 00,48+02, 16,00+02, 16,16+02, 16,32+02, 16,48+02, 32,00+02, 32,16+02, 32,32+02, 32,48+02

SensorTentacles1_Char:                      include "..\sprites\enemies\SensorTentacles\SensorTentacles1.tgs.gen"	 ;y offset, x offset 
SensorTentacles1_Col:                       include "..\sprites\enemies\SensorTentacles\SensorTentacles1.tcs.gen"  | db 00,00, 00,00
SensorTentacles2_Char:                      include "..\sprites\enemies\SensorTentacles\SensorTentacles2.tgs.gen"	  
SensorTentacles2_Col:                       include "..\sprites\enemies\SensorTentacles\SensorTentacles2.tcs.gen"  | db 00,00, 00,00
SensorTentacles3_Char:                      include "..\sprites\enemies\SensorTentacles\SensorTentacles3.tgs.gen"	  
SensorTentacles3_Col:                       include "..\sprites\enemies\SensorTentacles\SensorTentacles3.tcs.gen"  | db 00,00, 00,00
SensorTentacles4_Char:                      include "..\sprites\enemies\SensorTentacles\SensorTentacles4.tgs.gen"	  
SensorTentacles4_Col:                       include "..\sprites\enemies\SensorTentacles\SensorTentacles4.tcs.gen"  | db 00,00, 00,00
SensorTentacles5_Char:                      include "..\sprites\enemies\SensorTentacles\SensorTentacles5.tgs.gen"	  
SensorTentacles5_Col:                       include "..\sprites\enemies\SensorTentacles\SensorTentacles5.tcs.gen"  | db 00,00, 00,00
SensorTentaclesAttack1_Char:                include "..\sprites\enemies\SensorTentacles\SensorTentaclesAttack1.tgs.gen"	  
SensorTentaclesAttack1_Col:                 include "..\sprites\enemies\SensorTentacles\SensorTentaclesAttack1.tcs.gen"  | db 00,00, 00,00
SensorTentaclesAttack2_Char:                include "..\sprites\enemies\SensorTentacles\SensorTentaclesAttack2.tgs.gen"	  
SensorTentaclesAttack2_Col:                 include "..\sprites\enemies\SensorTentacles\SensorTentaclesAttack2.tcs.gen"  | db 00,00, 00,00

LeftYellowWasp1_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp1.tgs.gen"	  
LeftYellowWasp1_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp1.tcs.gen"  | db 00,00, 00,00
LeftYellowWasp2_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp2.tgs.gen"	  
LeftYellowWasp2_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp2.tcs.gen"  | db 00,00, 00,00
LeftYellowWasp3_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp3.tgs.gen"	  
LeftYellowWasp3_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp3.tcs.gen"  | db 00,00, 00,00
LeftYellowWasp4_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp4.tgs.gen"	  
LeftYellowWasp4_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp4.tcs.gen"  | db 00,00, 00,00
;LeftYellowWasp5_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp5.tgs.gen"	  
;LeftYellowWasp5_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp5.tcs.gen"  | db 00,00, 00,00
;LeftYellowWasp6_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp6.tgs.gen"	  
;LeftYellowWasp6_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp6.tcs.gen"  | db 00,00, 00,00
;LeftYellowWasp7_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp7.tgs.gen"	  
;LeftYellowWasp7_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp7.tcs.gen"  | db 00,00, 00,00
;LeftYellowWasp8_Char:                       include "..\sprites\enemies\Wasp\LeftYellowWasp8.tgs.gen"	  
;LeftYellowWasp8_Col:                        include "..\sprites\enemies\Wasp\LeftYellowWasp8.tcs.gen"  | db 00,00, 00,00

RightYellowWasp1_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp1.tgs.gen"	  
RightYellowWasp1_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp1.tcs.gen"  | db 00,00, 00,00
RightYellowWasp2_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp2.tgs.gen"	  
RightYellowWasp2_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp2.tcs.gen"  | db 00,00, 00,00
RightYellowWasp3_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp3.tgs.gen"	  
RightYellowWasp3_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp3.tcs.gen"  | db 00,00, 00,00
RightYellowWasp4_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp4.tgs.gen"	  
RightYellowWasp4_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp4.tcs.gen"  | db 00,00, 00,00
;RightYellowWasp5_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp5.tgs.gen"	  
;RightYellowWasp5_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp5.tcs.gen"  | db 00,00, 00,00
;RightYellowWasp6_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp6.tgs.gen"	  
;RightYellowWasp6_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp6.tcs.gen"  | db 00,00, 00,00
;RightYellowWasp7_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp7.tgs.gen"	  
;RightYellowWasp7_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp7.tcs.gen"  | db 00,00, 00,00
;RightYellowWasp8_Char:                      include "..\sprites\enemies\Wasp\RightYellowWasp8.tgs.gen"	  
;RightYellowWasp8_Col:                       include "..\sprites\enemies\Wasp\RightYellowWasp8.tcs.gen"  | db 00,00, 00,00
	ds		$c000-$,$ff
dephase

;
; block $55 + $56
;
DemontjeGreySpriteblock:  equ   $55
SnowballThrowerSpriteblock:  equ   $55
TrampolineBlobSpriteblock:  equ   $55
BlackHoleAlienSpriteblock:  equ   $55
BlackHoleBabySpriteblock:  equ   $55
phase	$8000
LeftDemontjeGrey1_Char:                     include "..\sprites\enemies\Demontje\LeftDemontjeGrey1.tgs.gen"	;y offset, x offset  
LeftDemontjeGrey1_Col:                      include "..\sprites\enemies\Demontje\LeftDemontjeGrey1.tcs.gen"  | db 00,01,00,01
LeftDemontjeGrey2_Char:                     include "..\sprites\enemies\Demontje\LeftDemontjeGrey2.tgs.gen"	  
LeftDemontjeGrey2_Col:                      include "..\sprites\enemies\Demontje\LeftDemontjeGrey2.tcs.gen"  | db 00,00,00,00
LeftDemontjeGrey3_Char:                     include "..\sprites\enemies\Demontje\LeftDemontjeGrey3.tgs.gen"	  
LeftDemontjeGrey3_Col:                      include "..\sprites\enemies\Demontje\LeftDemontjeGrey3.tcs.gen"  | db 00,00,00,00
LeftDemontjeGrey4_Char:                     include "..\sprites\enemies\Demontje\LeftDemontjeGrey4.tgs.gen"	  
LeftDemontjeGrey4_Col:                      include "..\sprites\enemies\Demontje\LeftDemontjeGrey4.tcs.gen"  | db 00,00,00,00

RightDemontjeGrey1_Char:                    include "..\sprites\enemies\Demontje\RightDemontjeGrey1.tgs.gen"	  
RightDemontjeGrey1_Col:                     include "..\sprites\enemies\Demontje\RightDemontjeGrey1.tcs.gen"  | db 00,-1,00,-1
RightDemontjeGrey2_Char:                    include "..\sprites\enemies\Demontje\RightDemontjeGrey2.tgs.gen"	  
RightDemontjeGrey2_Col:                     include "..\sprites\enemies\Demontje\RightDemontjeGrey2.tcs.gen"  | db 00,00,00,00
RightDemontjeGrey3_Char:                    include "..\sprites\enemies\Demontje\RightDemontjeGrey3.tgs.gen"	  
RightDemontjeGrey3_Col:                     include "..\sprites\enemies\Demontje\RightDemontjeGrey3.tcs.gen"  | db 00,00,00,00
RightDemontjeGrey4_Char:                    include "..\sprites\enemies\Demontje\RightDemontjeGrey4.tgs.gen"	  
RightDemontjeGrey4_Col:                     include "..\sprites\enemies\Demontje\RightDemontjeGrey4.tcs.gen"  | db 00,00,00,00

LeftSnowballThrower1_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower1.tgs.gen"	  
LeftSnowballThrower1_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower1.tcs.gen"  | db 00,00, 00,00, 16,00+1, 16,00+1
LeftSnowballThrower2_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower2.tgs.gen"	  
LeftSnowballThrower2_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower2.tcs.gen"  | db 00,00, 00,00, 16,00-1, 16,00-1
LeftSnowballThrower3_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower3.tgs.gen"	  
LeftSnowballThrower3_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower3.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrower4_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower4.tgs.gen"	  
LeftSnowballThrower4_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower4.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrower5_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower5.tgs.gen"	  
LeftSnowballThrower5_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower5.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrower6_Char:                  include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower6.tgs.gen"	  
LeftSnowballThrower6_Col:                   include "..\sprites\enemies\SnowballThrower\LeftSnowballThrower6.tcs.gen"  | db 00,00, 00,00, 16,00+1, 16,00+1

RightSnowballThrower1_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower1.tgs.gen"	  
RightSnowballThrower1_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower1.tcs.gen"  | db 00,00, 00,00, 16,00-1, 16,00-1
RightSnowballThrower2_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower2.tgs.gen"	  
RightSnowballThrower2_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower2.tcs.gen"  | db 00,00, 00,00, 16,00+1, 16,00+1
RightSnowballThrower3_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower3.tgs.gen"	  
RightSnowballThrower3_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower3.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrower4_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower4.tgs.gen"	  
RightSnowballThrower4_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower4.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrower5_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower5.tgs.gen"	  
RightSnowballThrower5_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower5.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrower6_Char:                 include "..\sprites\enemies\SnowballThrower\RightSnowballThrower6.tgs.gen"	  
RightSnowballThrower6_Col:                  include "..\sprites\enemies\SnowballThrower\RightSnowballThrower6.tcs.gen"  | db 00,00, 00,00, 16,00-1, 16,00-1

LeftSnowballThrowerAttack1_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack1.tgs.gen"	  
LeftSnowballThrowerAttack1_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack1.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrowerAttack2_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack2.tgs.gen"	  
LeftSnowballThrowerAttack2_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack2.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrowerAttack3_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack3.tgs.gen"	  
LeftSnowballThrowerAttack3_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack3.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
LeftSnowballThrowerAttack4_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack4.tgs.gen"	  
LeftSnowballThrowerAttack4_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack4.tcs.gen"  | db 00+3,00-3, 00+3,00-3, 16+3,00+2, 16+3,00+2
LeftSnowballThrowerAttack5_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack5.tgs.gen"	  
LeftSnowballThrowerAttack5_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack5.tcs.gen"  | db 00+4,00-2, 00+4,00-2, 16+4,00+1, 16+4,00+1
LeftSnowballThrowerAttack6_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack6.tgs.gen"	  
LeftSnowballThrowerAttack6_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack6.tcs.gen"  | db 00+4,00-1, 00+4,00-1, 16+4,00+2, 16+4,00+2
LeftSnowballThrowerAttack7_Char:            include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack7.tgs.gen"	  
LeftSnowballThrowerAttack7_Col:             include "..\sprites\enemies\SnowballThrower\LeftSnowballThrowerAttack7.tcs.gen"  | db 00,00-2, 00,00-2, 16,00-1, 16,00-1

RightSnowballThrowerAttack1_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack1.tgs.gen"	  
RightSnowballThrowerAttack1_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack1.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrowerAttack2_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack2.tgs.gen"	  
RightSnowballThrowerAttack2_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack2.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrowerAttack3_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack3.tgs.gen"	  
RightSnowballThrowerAttack3_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack3.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00
RightSnowballThrowerAttack4_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack4.tgs.gen"	  
RightSnowballThrowerAttack4_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack4.tcs.gen"  | db 00+3,00+3, 00+3,00+3, 16+3,00-2, 16+3,00-2
RightSnowballThrowerAttack5_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack5.tgs.gen"	  
RightSnowballThrowerAttack5_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack5.tcs.gen"  | db 00+4,00+2, 00+4,00+2, 16+4,00-1, 16+4,00-1
RightSnowballThrowerAttack6_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack6.tgs.gen"	  
RightSnowballThrowerAttack6_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack6.tcs.gen"  | db 00+4,00+1, 00+4,00+1, 16+4,00-2, 16+4,00-2
RightSnowballThrowerAttack7_Char:           include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack7.tgs.gen"	  
RightSnowballThrowerAttack7_Col:            include "..\sprites\enemies\SnowballThrower\RightSnowballThrowerAttack7.tcs.gen"  | db 00,00+2, 00,00+2, 16,00+1, 16,00+1

TrampolineBlob1_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob1.tgs.gen"	  
TrampolineBlob1_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob1.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob2_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob2.tgs.gen"	  
TrampolineBlob2_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob2.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob3_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob3.tgs.gen"	  
TrampolineBlob3_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob3.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob4_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob4.tgs.gen"	  
TrampolineBlob4_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob4.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob5_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob5.tgs.gen"	  
TrampolineBlob5_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob5.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob6_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob6.tgs.gen"	  
TrampolineBlob6_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob6.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob7_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob7.tgs.gen"	  
TrampolineBlob7_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob7.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlob8_Char:                       include "..\sprites\enemies\TrampolineBlob\TrampolineBlob8.tgs.gen"	  
TrampolineBlob8_Col:                        include "..\sprites\enemies\TrampolineBlob\TrampolineBlob8.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5

TrampolineBlobJump1_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump1.tgs.gen"	  
TrampolineBlobJump1_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump1.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlobJump2_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump2.tgs.gen"	  
TrampolineBlobJump2_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump2.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlobJump3_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump3.tgs.gen"	  
TrampolineBlobJump3_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump3.tcs.gen"  | db 00-18,00-5+8, 00-18,00-5+8, 00-2,00-5+8, 00-2,00-5+8
;TrampolineBlobJump4_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump4.tgs.gen"	  
;TrampolineBlobJump4_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump4.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlobJump5_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump5.tgs.gen"	  
TrampolineBlobJump5_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump5.tcs.gen"  | db 00-10,00-5, 00-10,00-5, 00-10,16-5, 00-10,16-5
TrampolineBlobJump6_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump6.tgs.gen"	  
TrampolineBlobJump6_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump6.tcs.gen"  | db 00-08,00-5, 00-08,00-5, 00-08,16-5, 00-08,16-5
;TrampolineBlobJump7_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump7.tgs.gen"	  
;TrampolineBlobJump7_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump7.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlobJump8_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump8.tgs.gen"	  
TrampolineBlobJump8_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump8.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5
TrampolineBlobJump9_Char:                   include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump9.tgs.gen"	  
TrampolineBlobJump9_Col:                    include "..\sprites\enemies\TrampolineBlob\TrampolineBlobJump9.tcs.gen"  | db 00,00-5, 00,00-5, 00,16-5, 00,16-5

LeftBlackHoleAlien1_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien1.tgs.gen"	 ;y offset, x offset 
LeftBlackHoleAlien1_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien1.tcs.gen"  | db 00,00+2,00,00+2, 00,16+2,00,16+2, 16,00+2,16,00+2, 16,16+2,16,16+2
LeftBlackHoleAlien2_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien2.tgs.gen"	  
LeftBlackHoleAlien2_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftBlackHoleAlien3_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien3.tgs.gen"	  
LeftBlackHoleAlien3_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
LeftBlackHoleAlien4_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien4.tgs.gen"	  
LeftBlackHoleAlien4_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien4.tcs.gen"  | db 00,00+2,00,00+2, 00,16+2,00,16+2, 16,00+2,16,00+2, 16,16+2,16,16+2
LeftBlackHoleAlien5_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien5.tgs.gen"	  
LeftBlackHoleAlien5_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien5.tcs.gen"  | db 00,00+2,00,00+2, 00,16+2,00,16+2, 16,00+2,16,00+2, 16,16+2,16,16+2
LeftBlackHoleAlien6_Char:                   include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien6.tgs.gen"	  
LeftBlackHoleAlien6_Col:                    include "..\sprites\enemies\BlackHoleAlien\LeftBlackHoleAlien6.tcs.gen"  | db 00,00+2,00,00+2, 00,16+2,00,16+2, 16,00+2,16,00+2, 16,16+2,16,16+2

RightBlackHoleAlien1_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien1.tgs.gen"	  
RightBlackHoleAlien1_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien1.tcs.gen"  | db 00,00-2,00,00-2, 00,16-2,00,16-2, 16,00-2,16,00-2, 16,16-2,16,16-2
RightBlackHoleAlien2_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien2.tgs.gen"	  
RightBlackHoleAlien2_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien2.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightBlackHoleAlien3_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien3.tgs.gen"	  
RightBlackHoleAlien3_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien3.tcs.gen"  | db 00,00,00,00, 00,16,00,16, 16,00,16,00, 16,16,16,16
RightBlackHoleAlien4_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien4.tgs.gen"	  
RightBlackHoleAlien4_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien4.tcs.gen"  | db 00,00-2,00,00-2, 00,16-2,00,16-2, 16,00-2,16,00-2, 16,16-2,16,16-2
RightBlackHoleAlien5_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien5.tgs.gen"	  
RightBlackHoleAlien5_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien5.tcs.gen"  | db 00,00-2,00,00-2, 00,16-2,00,16-2, 16,00-2,16,00-2, 16,16-2,16,16-2
RightBlackHoleAlien6_Char:                  include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien6.tgs.gen"	  
RightBlackHoleAlien6_Col:                   include "..\sprites\enemies\BlackHoleAlien\RightBlackHoleAlien6.tcs.gen"  | db 00,00-2,00,00-2, 00,16-2,00,16-2, 16,00-2,16,00-2, 16,16-2,16,16-2

LeftBlackHoleBaby1_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby1.tgs.gen"	 ;y offset, x offset 
LeftBlackHoleBaby1_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby1.tcs.gen"  | db 00,00,00,00
LeftBlackHoleBaby2_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby2.tgs.gen"	  
LeftBlackHoleBaby2_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby2.tcs.gen"  | db 00,00,00,00
LeftBlackHoleBaby3_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby3.tgs.gen"	  
LeftBlackHoleBaby3_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby3.tcs.gen"  | db 00,00,00,00
LeftBlackHoleBaby4_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby4.tgs.gen"	  
LeftBlackHoleBaby4_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby4.tcs.gen"  | db 00,00,00,00
LeftBlackHoleBaby5_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby5.tgs.gen"	  
LeftBlackHoleBaby5_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby5.tcs.gen"  | db 00,00,00,00
LeftBlackHoleBaby6_Char:                    include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby6.tgs.gen"	  
LeftBlackHoleBaby6_Col:                     include "..\sprites\enemies\BlackHoleBaby\LeftBlackHoleBaby6.tcs.gen"  | db 00,00,00,00

RightBlackHoleBaby1_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby1.tgs.gen"	  
RightBlackHoleBaby1_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby1.tcs.gen"  | db 00,00,00,00
RightBlackHoleBaby2_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby2.tgs.gen"	  
RightBlackHoleBaby2_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby2.tcs.gen"  | db 00,00,00,00
RightBlackHoleBaby3_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby3.tgs.gen"	  
RightBlackHoleBaby3_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby3.tcs.gen"  | db 00,00,00,00
RightBlackHoleBaby4_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby4.tgs.gen"	  
RightBlackHoleBaby4_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby4.tcs.gen"  | db 00,00,00,00
RightBlackHoleBaby5_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby5.tgs.gen"	  
RightBlackHoleBaby5_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby5.tcs.gen"  | db 00,00,00,00
RightBlackHoleBaby6_Char:                   include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby6.tgs.gen"	  
RightBlackHoleBaby6_Col:                    include "..\sprites\enemies\BlackHoleBaby\RightBlackHoleBaby6.tcs.gen"  | db 00,00,00,00
	ds		$c000-$,$ff
dephase

;
; block $57 + $58
;
DemontjeRedSpriteblock:  equ   $57
WaterfallSpriteblock:  equ   $57
DrippingOozeSpriteblock:  equ   $57
CuteMiniBatSpriteblock:  equ   $57
phase	$8000
LeftDemontjeRed1_Char:                      include "..\sprites\enemies\Demontje\LeftDemontjeRed1.tgs.gen"	;y offset, x offset  
LeftDemontjeRed1_Col:                       include "..\sprites\enemies\Demontje\LeftDemontjeRed1.tcs.gen"  | db 00,01,00,01
LeftDemontjeRed2_Char:                      include "..\sprites\enemies\Demontje\LeftDemontjeRed2.tgs.gen"	  
LeftDemontjeRed2_Col:                       include "..\sprites\enemies\Demontje\LeftDemontjeRed2.tcs.gen"  | db 00,00,00,00
LeftDemontjeRed3_Char:                      include "..\sprites\enemies\Demontje\LeftDemontjeRed3.tgs.gen"	  
LeftDemontjeRed3_Col:                       include "..\sprites\enemies\Demontje\LeftDemontjeRed3.tcs.gen"  | db 00,00,00,00
LeftDemontjeRed4_Char:                      include "..\sprites\enemies\Demontje\LeftDemontjeRed4.tgs.gen"	  
LeftDemontjeRed4_Col:                       include "..\sprites\enemies\Demontje\LeftDemontjeRed4.tcs.gen"  | db 00,00,00,00

RightDemontjeRed1_Char:                     include "..\sprites\enemies\Demontje\RightDemontjeRed1.tgs.gen"	  
RightDemontjeRed1_Col:                      include "..\sprites\enemies\Demontje\RightDemontjeRed1.tcs.gen"  | db 00,-1,00,-1
RightDemontjeRed2_Char:                     include "..\sprites\enemies\Demontje\RightDemontjeRed2.tgs.gen"	  
RightDemontjeRed2_Col:                      include "..\sprites\enemies\Demontje\RightDemontjeRed2.tcs.gen"  | db 00,00,00,00
RightDemontjeRed3_Char:                     include "..\sprites\enemies\Demontje\RightDemontjeRed3.tgs.gen"	  
RightDemontjeRed3_Col:                      include "..\sprites\enemies\Demontje\RightDemontjeRed3.tcs.gen"  | db 00,00,00,00
RightDemontjeRed4_Char:                     include "..\sprites\enemies\Demontje\RightDemontjeRed4.tgs.gen"	  
RightDemontjeRed4_Col:                      include "..\sprites\enemies\Demontje\RightDemontjeRed4.tcs.gen"  | db 00,00,00,00

Waterfall1_Char:                            include "..\sprites\enemies\Waterfall\Waterfall1.tgs.gen"	;y offset, x offset  
Waterfall1_Col:                             include "..\sprites\enemies\Waterfall\Waterfall1.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall2_Char:                            include "..\sprites\enemies\Waterfall\Waterfall2.tgs.gen"	;y offset, x offset  
Waterfall2_Col:                             include "..\sprites\enemies\Waterfall\Waterfall2.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall3_Char:                            include "..\sprites\enemies\Waterfall\Waterfall3.tgs.gen"	;y offset, x offset  
Waterfall3_Col:                             include "..\sprites\enemies\Waterfall\Waterfall3.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall4_Char:                            include "..\sprites\enemies\Waterfall\Waterfall4.tgs.gen"	;y offset, x offset  
Waterfall4_Col:                             include "..\sprites\enemies\Waterfall\Waterfall4.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall5_Char:                            include "..\sprites\enemies\Waterfall\Waterfall5.tgs.gen"	;y offset, x offset  
Waterfall5_Col:                             include "..\sprites\enemies\Waterfall\Waterfall5.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall6_Char:                            include "..\sprites\enemies\Waterfall\Waterfall6.tgs.gen"	;y offset, x offset  
Waterfall6_Col:                             include "..\sprites\enemies\Waterfall\Waterfall6.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall7_Char:                            include "..\sprites\enemies\Waterfall\Waterfall7.tgs.gen"	;y offset, x offset  
Waterfall7_Col:                             include "..\sprites\enemies\Waterfall\Waterfall7.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
Waterfall8_Char:                            include "..\sprites\enemies\Waterfall\Waterfall8.tgs.gen"	;y offset, x offset  
Waterfall8_Col:                             include "..\sprites\enemies\Waterfall\Waterfall8.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3

WaterfallStart1_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart1.tgs.gen"	;y offset, x offset  
WaterfallStart1_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart1.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart2_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart2.tgs.gen"	;y offset, x offset  
WaterfallStart2_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart2.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart3_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart3.tgs.gen"	;y offset, x offset  
WaterfallStart3_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart3.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart4_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart4.tgs.gen"	;y offset, x offset  
WaterfallStart4_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart4.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart5_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart5.tgs.gen"	;y offset, x offset  
WaterfallStart5_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart5.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart6_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart6.tgs.gen"	;y offset, x offset  
WaterfallStart6_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart6.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallStart7_Char:                       include "..\sprites\enemies\Waterfall\WaterfallStart7.tgs.gen"	;y offset, x offset  
WaterfallStart7_Col:                        include "..\sprites\enemies\Waterfall\WaterfallStart7.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3

WaterfallEnd1_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd1.tgs.gen"	;y offset, x offset  
WaterfallEnd1_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd1.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd2_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd2.tgs.gen"	;y offset, x offset  
WaterfallEnd2_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd2.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd3_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd3.tgs.gen"	;y offset, x offset  
WaterfallEnd3_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd3.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd4_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd4.tgs.gen"	;y offset, x offset  
WaterfallEnd4_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd4.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd5_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd5.tgs.gen"	;y offset, x offset  
WaterfallEnd5_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd5.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd6_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd6.tgs.gen"	;y offset, x offset  
WaterfallEnd6_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd6.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd7_Char:                         include "..\sprites\enemies\Waterfall\WaterfallEnd7.tgs.gen"	;y offset, x offset  
WaterfallEnd7_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd7.tcs.gen"  | db 00-1,00-3, 00-1,00-3, 16-1,00-3, 16-1,00-3, 32-1,00-3, 32-1,00-3, 48-1,00-3, 48-1,00-3
WaterfallEnd8Empty_Char:                    include "..\sprites\enemies\Waterfall\WaterfallEnd8Empty.tgs.gen"	;y offset, x offset  
WaterfallEnd8_Col:                          include "..\sprites\enemies\Waterfall\WaterfallEnd7.tcs.gen"  | db 00,00, 00,00, 16,00, 16,00, 32,00, 32,00, 48,00, 48,00

DrippingOoze1_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",0*128,128
DrippingOoze1_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+0*064,064  | db 16+5,00, 16+5,16, 16,00, 16,16
DrippingOoze2_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",1*128,128
DrippingOoze2_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+1*064,064  | db 16+5,00, 16+5,16, 16,00, 16,16
DrippingOoze3_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",2*128,128
DrippingOoze3_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+2*064,064  | db 16+8,00, 16+8,16, 16,00, 16,16
DrippingOoze4_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",3*128,128
DrippingOoze4_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+3*064,064  | db 16,00, 16,16, 16+5,00, 16+5,16
DrippingOoze5_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",4*128,128
DrippingOoze5_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+4*064,064  | db 16,00, 16,16, 16+6,00, 16+6,16
DrippingOoze6_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",5*128,128
DrippingOoze6_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+5*064,064  | db 15,00, 15,16, 15+11,00, 15+11,16
DrippingOoze7_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",6*128,128
DrippingOoze7_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+6*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze8_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",7*128,128
DrippingOoze8_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+7*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze9_Char:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",8*128,128
DrippingOoze9_Col:                          incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+8*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze10_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",9*128,128
DrippingOoze10_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+9*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze11_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",10*128,128
DrippingOoze11_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+10*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze12_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",11*128,128
DrippingOoze12_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+11*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze13_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",12*128,128
DrippingOoze13_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+12*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze14_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",13*128,128
DrippingOoze14_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+13*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze15_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",14*128,128
DrippingOoze15_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+14*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze16_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",15*128,128
DrippingOoze16_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+15*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze17_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",16*128,128
DrippingOoze17_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+16*064,064  | db 00,00, 00,16, 16,00, 16,16
DrippingOoze18_Char:                        incbin "..\sprites\enemies\DrippingOoze\1.spr",17*128,128
DrippingOoze18_Col:                         incbin "..\sprites\enemies\DrippingOoze\1.spr",72*32+17*064,064  | db 00,00, 00,16, 16,00, 16,16

LeftCuteMiniBat1_Char:                      include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat1.tgs.gen"	;y offset, x offset  
LeftCuteMiniBat1_Col:                       include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat1.tcs.gen"  | db 00,00,00,00
LeftCuteMiniBat2_Char:                      include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat2.tgs.gen"	  
LeftCuteMiniBat2_Col:                       include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat2.tcs.gen"  | db 00,00,00,00
LeftCuteMiniBat3_Char:                      include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat3.tgs.gen"	  
LeftCuteMiniBat3_Col:                       include "..\sprites\enemies\CuteMiniBat\LeftCuteMiniBat3.tcs.gen"  | db 00,00,00,00

RightCuteMiniBat1_Char:                     include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat1.tgs.gen"	  
RightCuteMiniBat1_Col:                      include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat1.tcs.gen"  | db 00,00,00,00
RightCuteMiniBat2_Char:                     include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat2.tgs.gen"	  
RightCuteMiniBat2_Col:                      include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat2.tcs.gen"  | db 00,00,00,00
RightCuteMiniBat3_Char:                     include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat3.tgs.gen"	  
RightCuteMiniBat3_Col:                      include "..\sprites\enemies\CuteMiniBat\RightCuteMiniBat3.tcs.gen"  | db 00,00,00,00


	ds		$c000-$,$ff
dephase

;
; block $59 - $5c
;
B01TilesBlock:  equ   $59
phase	$4000
  incbin "..\grapx\B01.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase

;
; block $5d - $60
;
A01TilesBlock:  equ   $5f
phase	$4000
  incbin "..\grapx\A01.SC5",7,$6A00  ;skip header
	ds		$c000-$,$ff
dephase



; Note: The routine below is a bit complex because it supports
; songs > 16K. However, if you know that your song will always be < 16K you
; can simplify it a lot:
; - read the header and trash it!
; - read the rest of the file
; - modify the play_nextpos routine so that 3 is added to the pattern address
;
; block $61 - $62
;
MusicTestBlock:  equ   $61
phase	$8000
;  incbin "..\music\perftest.mwm",7  ;skip header
  incbin "perftest.mwm" ;,7  ;skip header..... Header is 6 bytes ???
	ds		$c000-$,$ff
dephase

;
; block $63 - $64
;
Graphicsblock5:  equ   $63
phase	$4000
scoreboard:
  incbin "..\grapx\scoreboard.SC5",7,$1000  ;skip header
itemsKarniMata:
  incbin "..\grapx\itemsKarniMata.SC5",7,$1400  ;skip header
	ds		$8000-$,$ff
dephase

;
; block $65 - $66
;
MusicReplayerBlock:  equ   $65
phase	$4000
  include "MusicPlayer_new.asm"  
	ds		$8000-$,$ff
dephase

;
; block $67 + $68
;
LancelotSpriteblock:  equ   $67
phase	$8000
LeftLancelot1_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot1.tgs.gen"	  
LeftLancelot1_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot1.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelot2_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot2.tgs.gen"	  
LeftLancelot2_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot2.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
LeftLancelot3_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot3.tgs.gen"	  
LeftLancelot3_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot3.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelot4_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot4.tgs.gen"	  
LeftLancelot4_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot4.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
LeftLancelot5_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot5.tgs.gen"	  
LeftLancelot5_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot5.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
LeftLancelot6_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot6.tgs.gen"	  
LeftLancelot6_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot6.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
LeftLancelot7_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot7.tgs.gen"	  
LeftLancelot7_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot7.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelot8_Char:                         include "..\sprites\enemies\Lancelot\LeftLancelot8.tgs.gen"	  
LeftLancelot8_Col:                          include "..\sprites\enemies\Lancelot\LeftLancelot8.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00

RightLancelot1_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot1.tgs.gen"	  
RightLancelot1_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot1.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelot2_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot2.tgs.gen"	  
RightLancelot2_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot2.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
RightLancelot3_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot3.tgs.gen"	  
RightLancelot3_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot3.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelot4_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot4.tgs.gen"	  
RightLancelot4_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot4.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
RightLancelot5_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot5.tgs.gen"	  
RightLancelot5_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot5.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
RightLancelot6_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot6.tgs.gen"	  
RightLancelot6_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot6.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
RightLancelot7_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot7.tgs.gen"	  
RightLancelot7_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot7.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelot8_Char:                        include "..\sprites\enemies\Lancelot\RightLancelot8.tgs.gen"	  
RightLancelot8_Col:                         include "..\sprites\enemies\Lancelot\RightLancelot8.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
	ds		$c000-$,$ff
dephase

;
; block $69 + $69
;
LancelotShieldHitSpriteblock:  equ   $69
phase	$8000
LeftLancelotShieldHit1_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit1.tgs.gen"	  
LeftLancelotShieldHit1_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit1.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelotShieldHit2_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit2.tgs.gen"	  
LeftLancelotShieldHit2_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit2.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
LeftLancelotShieldHit3_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit3.tgs.gen"	  
LeftLancelotShieldHit3_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit3.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelotShieldHit4_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit4.tgs.gen"	  
LeftLancelotShieldHit4_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit4.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
LeftLancelotShieldHit5_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit5.tgs.gen"	  
LeftLancelotShieldHit5_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit5.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
LeftLancelotShieldHit6_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit6.tgs.gen"	  
LeftLancelotShieldHit6_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit6.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
LeftLancelotShieldHit7_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit7.tgs.gen"	  
LeftLancelotShieldHit7_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit7.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
LeftLancelotShieldHit8_Char:                include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit8.tgs.gen"	  
LeftLancelotShieldHit8_Col:                 include "..\sprites\enemies\Lancelot\LeftLancelotShieldHit8.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00

RightLancelotShieldHit1_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit1.tgs.gen"	  
RightLancelotShieldHit1_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit1.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelotShieldHit2_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit2.tgs.gen"	  
RightLancelotShieldHit2_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit2.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
RightLancelotShieldHit3_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit3.tgs.gen"	  
RightLancelotShieldHit3_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit3.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelotShieldHit4_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit4.tgs.gen"	  
RightLancelotShieldHit4_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit4.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
RightLancelotShieldHit5_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit5.tgs.gen"	  
RightLancelotShieldHit5_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit5.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
RightLancelotShieldHit6_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit6.tgs.gen"	  
RightLancelotShieldHit6_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit6.tcs.gen"  | db 00+1,00, 00+1,00, 16+1,00, 16+1,00
RightLancelotShieldHit7_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit7.tgs.gen"	  
RightLancelotShieldHit7_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit7.tcs.gen"  | db 00-1+1,00, 00-1+1,00, 16-1+1,00, 16-1+1,00
RightLancelotShieldHit8_Char:               include "..\sprites\enemies\Lancelot\RightLancelotShieldHit8.tgs.gen"	  
RightLancelotShieldHit8_Col:                include "..\sprites\enemies\Lancelot\RightLancelotShieldHit8.tcs.gen"  | db 00-2+1,00, 00-2+1,00, 16-2+1,00, 16-2+1,00
	ds		$c000-$,$ff
dephase







totallenght:	Equ	$-Usas2
	ds		$80000-totallenght
