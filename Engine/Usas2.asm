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


; 
; block 00
;	
enginepage3:
	include	"enginepage3.asm"	

; 
; block 00 - 01 engine 
;	
engine:
phase	engaddr
	include	"engine.asm"	
endengine:
dephase
enlength:	Equ	$-engine
;
; fill remainder of blocks 00-01
;
	ds		$c000-$,$ff		

;
; block $02
;
F1Menublock:  equ $02
phase	$4000
	include	"F1Menu.asm"	
endF1MenuRoutine:
F1MenuRoutinelength:	Equ	$-F1MenuRoutine
	ds		$8000-$,$ff		
dephase

;
; block $03
;
Loaderblock:  equ $03
phase	$4000
StartLoaderRoutine:
	include	"loader.asm"	
endLoaderRoutine:
LoaderRoutinelength:	Equ	$-StartLoaderRoutine
	ds		$8000-$,$ff		
dephase

;
; block $04
;
	ds		$4000

;
; block $05
;
	ds		$4000

;
; block $06
;
	ds		$4000

;
; block $07
;
	ds		$4000

;
; block $08
;
	ds		$4000

;
; block $09
;
	ds		$4000

;
; block $0A
;
	ds		$4000

;
; block $0B
;
teamNXTlogoblock:  equ $B
phase	$8000
	include "teamNXTlogo.asm"
	ds		$c000-$,$ff
dephase

;
; block $18 - $1b
;
phase	$4000
	ds		$c000-$,$ff
dephase





;
; block $e
;
;MapsBlock03:  equ   $f
phase	$8000

	ds		$c000-$,$ff
dephase


















;
; block $f
;
MapsBlock01:  equ   $f
phase	$8000
MapA01_001:   ;EngineType, graphics, palette,
  incbin "..\maps\A01-001.map.pck"  | .amountofobjects: db  14
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks13Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks14Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks15Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object4: db 1,        0|dw PushingPuzzlOverview|db 8*06|db 8*12,8*12,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable2|db  +00,+00,+00,+00,+00,+07,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*13|dw 8*10|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch15On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*13|dw 8*12|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch16On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*13|dw 8*24|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch19On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object8: db 1,        0|dw PushingPuzzleSwitch |db 8*13|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch20On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

.object9: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*10|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch21On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object10: db 1,       0|dw PushingPuzzleSwitch |db 8*19|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch26On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

.object11: db 1,       0|dw PushingPuzzleSwitch |db 8*25|dw 8*10|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch27On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object12: db 1,       0|dw PushingPuzzleSwitch |db 8*25|dw 8*12|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch28On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object13: db 1,       0|dw PushingPuzzleSwitch |db 8*25|dw 8*24|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch31On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object14: db 1,       0|dw PushingPuzzleSwitch |db 8*25|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable2,PuzzleSwitch32On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1


MapA01_002:
  incbin "..\maps\A01-002.map.pck"  | .amountofobjects: db  7
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks1Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks2Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks3Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*06|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch1On? |db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*12|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch2On? |db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*18|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch3On? |db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch4On? |db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks1Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks2Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks3Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 19*8,06*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch1On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 19*8,12*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 19*8,18*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch3On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object7: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch4On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_003:
  incbin "..\maps\A01-003.map.pck"  | .amountofobjects: db  7
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks19Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks20Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*14|dw 8*11|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch38On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch40On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch41On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object7: db 1,        0|dw PushingPuzzlOverview|db 8*08|db 8*14,8*14,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable4|db  +00,+00,+00,+00,+00,+05,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1




;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks19Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks20Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 0,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 14*8,11*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch38On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch40On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 25*8,26*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch41On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
;.object7: db 1,        0|dw PushingPuzzlOverview|db 08*8,14*8,14*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      



MapA01_004:
  incbin "..\maps\A01-004.map.pck"  | .amountofobjects: db  2
  
  
;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object1: db 1,        0|dw PushingPuzzlOverview|db 8*03|db 8*07,8*07,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable1|db  +00,+00,+00,+00,+00,+10,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object2: db 1,        0|dw PushingPuzzleSwitch |db 8*14|dw 8*13|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch14On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1


  
  
  
  
  
  
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
;.object1: db 1,        0|dw PushingPuzzlOverview|db 03*8,07*8,07*8,0,     00,       00,+00,+00,+00,+00,+00,+10,+00|dw PuzzleSwitchTable1|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object2: db 1,        0|dw PushingPuzzleSwitch |db 14*8,13*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch14On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzlOverview|db 14*8,15*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch2On?|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_005:
  incbin "..\maps\A01-005.map.pck"  | .amountofobjects: db  7


;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks4Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks5Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks6Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*18|dw 8*08|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch5On? |db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*16|dw 8*14|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch6On? |db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*16|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch7On? |db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*18|dw 8*30|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch8On? |db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

  
  
  
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks4Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks5Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks6Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 18*8,08*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 | dw PuzzleSwitch5On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 16*8,14*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 | dw PuzzleSwitch6On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 16*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 | dw PuzzleSwitch7On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object7: db 1,        0|dw PushingPuzzleSwitch |db 17*8,30*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 | dw PuzzleSwitch8On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      


MapA01_006:
  incbin "..\maps\A01-006.map.pck"  | .amountofobjects: db  8

;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks21Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks22Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*12|dw 8*06|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch42On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*12|dw 8*16|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch43On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*19|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch44On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*15|db 16,16|db 0,0,0| dw PuzzleSwitchTable4,PuzzleSwitch45On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object8: db 1,        0|dw PushingPuzzlOverview|db 8*08|db 8*18,8*18,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable4|db  +00,+00,+00,+00,+00,+05,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1








;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks21Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks22Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 0,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00|dw PuzzleBlocksEmpty| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 12*8,06*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch42On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 12*8,16*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch43On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch44On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object7: db 1,        0|dw PushingPuzzleSwitch |db 25*8,15*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch45On?,PuzzleSwitchTable4|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
;.object8: db 1,        0|dw PushingPuzzlOverview|db 08*8,18*8,18*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
  
  
MapA01_007:
  incbin "..\maps\A01-007.map.pck"  | .amountofobjects: db  9


;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks16Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks17Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks18Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*06|db 16,16|db 0,0,0| dw PuzzleSwitchTable3,PuzzleSwitch33On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*14|db 16,16|db 0,0,0| dw PuzzleSwitchTable3,PuzzleSwitch34On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*18|db 16,16|db 0,0,0| dw PuzzleSwitchTable3,PuzzleSwitch35On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*22|db 16,16|db 0,0,0| dw PuzzleSwitchTable3,PuzzleSwitch36On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object8: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*30|db 16,16|db 0,0,0| dw PuzzleSwitchTable3,PuzzleSwitch37On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object9: db 1,        0|dw PushingPuzzlOverview|db 8*07|db 8*15,8*15,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable3|db  +00,+00,+00,+00,+00,+04,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1





;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks16Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks17Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks18Y| db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 25*8,06*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch33On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 25*8,14*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch34On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 25*8,18*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch35On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object7: db 1,        0|dw PushingPuzzleSwitch |db 25*8,22*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch36On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object8: db 1,        0|dw PushingPuzzleSwitch |db 25*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch37On?,PuzzleSwitchTable3|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
;.object9: db 1,        0|dw PushingPuzzlOverview|db 07*8,15*8,15*8,0,     00,       00,+00,+00,+00,+00,+00,+04,+00|dw PuzzleSwitchTable3|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_008:
  incbin "..\maps\A01-008.map.pck"  | .amountofobjects: db  8

;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks7Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks8Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks9Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*15|dw 8*06|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch9On? |db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*15|dw 8*10|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch10On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*15|dw 8*16|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch11On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*21|dw 8*26|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch12On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object8: db 1,        0|dw PushingPuzzleSwitch |db 8*21|dw 8*30|db 16,16|db 0,0,0| dw PuzzleSwitchTable1,PuzzleSwitch13On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



  
       ;alive?,inscreen?,movempat,  y,  x,ny,nx,spnrinspat,nrsprites, v1, v2, v3, v4, v5, v6, v7   coordinates                            ,v1,v2,v3,v4,sprchar,damagewhentouch?,   hp, item?        , attack
;Pushing Stones
;.object1: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb1|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks7Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object2: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb2|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks8Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object3: db 1,        0|dw PushingStone        |db 000,000,16,16|dw CleanOb3|      db 112,+00,+01,+00,+00,+00,+00 | dw PuzzleBlocks9Y | db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;Pushing stone Puzzle Switch                                       init?,#nr,on?,act,snap
;.object4: db 1,        0|dw PushingPuzzleSwitch |db 13*8,06*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch9On? ,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object5: db 1,        0|dw PushingPuzzleSwitch |db 13*8,10*8,16,16,      00,       00,+01,+00,+00,+00,+00,+00,+00 |dw PuzzleSwitch10On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object6: db 1,        0|dw PushingPuzzleSwitch |db 13*8,16*8,16,16,      00,       00,+01,+02,+00,+00,+00,+00,+00 |dw PuzzleSwitch11On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object7: db 1,        0|dw PushingPuzzleSwitch |db 19*8,26*8,16,16,      00,       00,+01,+01,+00,+00,+00,+00,+00 |dw PuzzleSwitch12On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      
;.object8: db 1,        0|dw PushingPuzzleSwitch |db 19*8,30*8,16,16,      00,       00,+01,+03,+00,+00,+00,+00,+00 |dw PuzzleSwitch13On?,PuzzleSwitchTable1|db 4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      

MapA01_009:
  incbin "..\maps\A01-009.map.pck"  | .amountofobjects: db  1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object9: db 1,        0|dw PushingPuzzlOverview|db 8*10|db 8*12,8*12,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable4|db  +00,+00,+00,+00,+00,+05,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



;Pushing stone Puzzle Pieces overview       x backup                                   total,setnr?
;.object1: db 1,        0|dw PushingPuzzlOverview|db 10*8,12*8,12*8,0,     00,       00,+00,+00,+00,+00,+00,+05,+00|dw PuzzleSwitchTable4|db 4,16,4, 16,20,16,20, 32,4,32,4,  32,20,32,20, 1,-2, 0, 0, 0,      0,               1|dw 300|db 0, 1      



MapA01_010:
  incbin "..\maps\A01-010.map.pck"  | .amountofobjects: db  7

;Trampoline Blob: v9=special width for Pushing Stone Puzzle Switch
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw TrampolineBlob      |db 8*23|dw 8*04|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+08,+36, 0|db 255,movepatblo1| ds fill-1
.object2:db -1,        1|dw TrampolineBlob      |db 8*19|dw 8*23|db 16,22|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+08,+36, 0|db 255,movepatblo1| ds fill-1
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*15|dw 8*06|db 16,16|db 0,0,0| dw PuzzleSwitchTable5,PuzzleSwitch46On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*15|db 16,16|db 0,0,0| dw PuzzleSwitchTable5,PuzzleSwitch47On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*21|dw 8*21|db 16,16|db 0,0,0| dw PuzzleSwitchTable5,PuzzleSwitch48On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object7: db 1,        0|dw PushingPuzzlOverview|db 8*07|db 8*15,8*15,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable5|db  +00,+00,+00,+00,+00,+03,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1




MapA01_011:
  incbin "..\maps\A01-011.map.pck"  | .amountofobjects: db  8

;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Slime               |db 8*07|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movepatblo1| ds fill-1
.object2:db -1,        1|dw Slime               |db 8*15|dw 8*03|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movepatblo1| ds fill-1

;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks23Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*09|dw 8*29|db 16,16|db 0,0,0| dw PuzzleSwitchTable6,PuzzleSwitch49On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*17|dw 8*12|db 16,16|db 0,0,0| dw PuzzleSwitchTable6,PuzzleSwitch50On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*11|db 16,16|db 0,0,0| dw PuzzleSwitchTable6,PuzzleSwitch51On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*25|db 16,16|db 0,0,0| dw PuzzleSwitchTable6,PuzzleSwitch52On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object8: db 1,        0|dw PushingPuzzlOverview|db 8*12|db 8*18,8*18,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable6|db  +00,+00,+00,+00,+00,+04,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



MapA01_012:
  incbin "..\maps\A01-012.map.pck"  | .amountofobjects: db  6
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks24Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks25Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*14|db 16,16|db 0,0,0| dw PuzzleSwitchTable7,PuzzleSwitch53On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*23|db 16,16|db 0,0,0| dw PuzzleSwitchTable7,PuzzleSwitch54On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object6: db 1,        0|dw PushingPuzzlOverview|db 8*14|db 8*19,8*19,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable7|db  +00,+00,+00,+00,+00,+02,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



MapA01_013:
  incbin "..\maps\A01-013.map.pck"  | .amountofobjects: db  8

;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Slime               |db 8*14|dw 8*07|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movepatblo1| ds fill-1
.object2:db -1,        1|dw Slime               |db 8*14|dw 8*30|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Slime               |db 8*23|dw 8*23|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*16|dw 8*08|db 16,16|db 0,0,0| dw PuzzleSwitchTable8,PuzzleSwitch55On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*16|dw 8*28|db 16,16|db 0,0,0| dw PuzzleSwitchTable8,PuzzleSwitch56On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*08|db 16,16|db 0,0,0| dw PuzzleSwitchTable8,PuzzleSwitch57On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*28|db 16,16|db 0,0,0| dw PuzzleSwitchTable8,PuzzleSwitch58On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object8: db 1,        0|dw PushingPuzzlOverview|db 8*09|db 8*16,8*16,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable8|db  +00,+00,+00,+00,+00,+03,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1


MapA01_014:
  incbin "..\maps\A01-014.map.pck"  | .amountofobjects: db  5
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks26Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*13|db 16,16|db 0,0,0| dw PuzzleSwitchTable9,PuzzleSwitch59On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object5: db 1,        0|dw PushingPuzzlOverview|db 8*14|db 8*20,8*20,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable9|db  +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1


MapA01_015:
  incbin "..\maps\A01-015.map.pck"  | .amountofobjects: db  9

;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object1: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks27Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks28Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0 | dw PuzzleBlocks29Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Switch: v1=initialize?, v2=switch nr(0-3), v3=switch on?, v4=activate switch to turn on or off
.object4: db 1,        0|dw PushingPuzzleSwitch |db 8*09|dw 8*20|db 16,16|db 0,0,0|dw PuzzleSwitchTable10,PuzzleSwitch60On?|db +01,+03,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 1,        0|dw PushingPuzzleSwitch |db 8*13|dw 8*07|db 16,16|db 0,0,0|dw PuzzleSwitchTable10,PuzzleSwitch61On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*10|db 16,16|db 0,0,0|dw PuzzleSwitchTable10,PuzzleSwitch62On?|db +01,+02,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object7: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*12|db 16,16|db 0,0,0|dw PuzzleSwitchTable10,PuzzleSwitch63On?|db +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object8: db 1,        0|dw PushingPuzzleSwitch |db 8*25|dw 8*20|db 16,16|db 0,0,0|dw PuzzleSwitchTable10,PuzzleSwitch64On?|db +01,+01,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Pushing stone Puzzle Pieces overview                          x,x backup, v6=total pieces,v7=current piece to put
.object9: db 1,        0|dw PushingPuzzlOverview|db 8*15|db 8*14,8*14,0,0|dw 00000000,0 db 0|dw PuzzleSwitchTable10|db +00,+00,+00,+00,+00,+05,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapA01_016:
  incbin "..\maps\A01-016.map.pck"  | .amountofobjects: db  3  
;AppearingBlocks Handler
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw AppBlocksHandler    |db 0*00|dw 0*00|db 00,00|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;AppearingBlocks
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 0,        0|dw AppearingBlocks     |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1



;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
.object3: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks30Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
;.object2: db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb2,0 db 0 | dw PuzzleBlocks31Y| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
;.object3: db 0,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb3,0 db 0|dw PuzzleBlocksEmpty| db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movepatblo1| ds fill-1
  



	ds		$c000-$,$ff
dephase

;
; block $20 - &21
;

MapsBlock02:  equ   $20/2
phase	$8000
MapB01_001:
  incbin "..\maps\b01-001.map.pck"  | .amountofobjects: db  3
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,        0|dw Sf2Hugeobject1      |db 8*06|dw 8*09|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movepatblo1| ds fill-1
.object2: db 2,        0|dw Sf2Hugeobject2      |db 8*12|dw 8*12|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movepatblo1| ds fill-1
.object3: db 2,        0|dw Sf2Hugeobject3      |db 8*03|dw 8*13|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movepatblo1| ds fill-1

MapB01_002:
  incbin "..\maps\b01-002.map.pck"  | .amountofobjects: db  4
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
.object1: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*15|db 16,16|dw CleanOb3,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Beetle
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw Beetle           |db 8*14+10|dw 8*19|db 22,28|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 003,movepatblo1| ds fill-1
 
MapB01_003:
  incbin "..\maps\b01-003.map.pck"  | .amountofobjects: db  7
;Demontje Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw DemontjeBullet      |db 8*10|dw 8*15|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Demontje            |db 8*08|dw 8*31|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Demontje            |db 8*11|dw 8*34|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -1,        1|dw Demontje            |db 8*07|dw 8*10|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -1,        1|dw Demontje            |db 8*09|dw 8*07|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+03,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Landstrider
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object6:db -1,        1|dw Landstrider         |db 8*14|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -1,        1|dw Landstrider         |db 8*24|dw 8*29|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_004:
  incbin "..\maps\b01-004.map.pck"  | .amountofobjects: db  3
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*15|db 16,16|dw CleanOb3,0 db 0,0,0,                      +64,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapB01_005:
  incbin "..\maps\b01-005.map.pck"  | .amountofobjects: db  8
;Green Wasp ;v6=Green Wasp(0) / Brown Wasp(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Wasp                |db 8*13|dw 8*11|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object2:db -1,        1|dw Wasp                |db 8*10|dw 8*15|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+01,+03,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Wasp                |db 8*09|dw 8*18|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+02,+06,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -1,        1|dw Wasp                |db 8*17|dw 8*23|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+03,+09,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Brown Wasp ;v6=Green Wasp(0) / Brown Wasp(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object5:db -1,        1|dw Wasp                |db 8*03|dw 8*10|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+04,+12,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object6:db -1,        1|dw Wasp                |db 8*05|dw 8*14|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+05,+15,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -1,        1|dw Wasp                |db 8*11|dw 8*20|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+06,+18,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object8:db -1,        1|dw Wasp                |db 8*16|dw 8*28|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+07,+21,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_006:
  incbin "..\maps\b01-006.map.pck" | .amountofobjects: db  5
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformVertically  |db 8*15|dw 8*13|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+01,+00,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Slime               |db 8*17|dw 8*24|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Slime               |db 8*17|dw 8*06|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -1,        1|dw Slime               |db 8*05|dw 8*19|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -1,        1|dw Slime               |db 8*21|dw 8*30|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_007:
  incbin "..\maps\b01-007.map.pck"  | .amountofobjects: db  5
;FireEye Grey
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw FireEyeGrey         |db 8*19|dw 8*21|db 48,32|dw 12*16,spat+(12*2)|db 72-(11*6),11  ,11*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1
;Fire Eye Firebullets
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb1,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb2,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object4: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb3,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object5: db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb4,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapB01_008:
  incbin "..\maps\b01-008.map.pck"  | .amountofobjects: db  5
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw GreenSpider         |db 8*23|dw 8*12|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw BoringEye           |db 8*18|dw 8*09|db 22,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Boring Eye Red;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw BoringEye           |db 8*18|dw 8*31|db 22,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -1,        1|dw BoringEye           |db 8*04|dw 8*22|db 22,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_009:
  incbin "..\maps\b01-009.map.pck"  | .amountofobjects: db  6
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 0,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 0,        0|dw PlatformHorizontally|db 8*11|dw 8*12|db 16,16|dw CleanOb2,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Spider Green
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -0,        1|dw GreenSpider         |db 8*14|dw 8*19|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

;Bat Spawner
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db +1,        1|dw BatSpawner          |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+00,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object5:db -0,        1|dw Bat                 |db 8*10|dw 8*19|db 26,22|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object6:db -0,        1|dw Bat                 |db 8*06|dw 8*19|db 26,22|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_010:
  incbin "..\maps\b01-010.map.pck"  | .amountofobjects: db  6
;Retarded Zombie Spawnpoint
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db +1,        1|dw ZombieSpawnPoint    |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+01,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Retarded Zombie
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 16*16,spat+(16*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 20*16,spat+(20*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 24*16,spat+(24*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object6: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapB01_011:
  incbin "..\maps\b01-011.map.pck"  | .amountofobjects: db  3
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Treeman
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Treeman             |db 8*11|dw 8*30|db 32,26|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1
;Grinder
.object3:db -1,        1|dw Grinder             |db 8*19|dw 8*16|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1

MapB01_012:
  incbin "..\maps\b01-012.map.pck"  | .amountofobjects: db  2
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +32,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw GreenSpider         |db 8*17|dw 8*15|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_013:
  incbin "..\maps\b01-013.map.pck"  | .amountofobjects: db  1
;Hunchback
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Hunchback           |db 8*21|dw 8*34|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 003,movepatblo1| ds fill-1

MapB01_014:
  incbin "..\maps\b01-014.map.pck"  | .amountofobjects: db  3
;Scorpion
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Scorpion            |db 8*03|dw 8*20|db 32,22|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object2:db -1,        1|dw Scorpion            |db 8*12|dw 8*20|db 32,22|dw 18*16,spat+(18*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,-01,+01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Spider Green
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw GreenSpider         |db 8*23|dw 8*19|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_015:
  incbin "..\maps\b01-015.map.pck"  | .amountofobjects: db  7
;Octopussy Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 0,        0|dw OctopussyBullet     |db 8*12|dw 8*16|db 08,08|dw CleanOb1,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 0,        0|dw OctopussyBullet     |db 8*13|dw 8*18|db 08,08|dw CleanOb2,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw OctopussyBullet     |db 8*14|dw 8*20|db 08,08|dw CleanOb3,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object4: db 0,        0|dw OctopussyBullet     |db 8*15|dw 8*22|db 08,08|dw CleanOb4,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Octopussy Bullet Slow Down Handler
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object5: db 1,        0|dw OP_SlowDownHandler  |db 8*12|dw 8*16|db 00,00|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Octopussy
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object6:db -1,        1|dw Octopussy           |db 8*14|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -1,        1|dw Octopussy           |db 8*14|dw 8*23|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_016:
  incbin "..\maps\b01-016.map.pck"  | .amountofobjects: db  3
;SensorTentacles
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw SensorTentacles     |db 8*12|dw 8*16|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001,movepatblo1| ds fill-1
.object2:db -1,        1|dw SensorTentacles     |db 8*07|dw 8*19|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*07+1,+1, 0|db 1,movepatblo1| ds fill-1
;.object3:db -1,        1|dw SensorTentacles     |db 8*12|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001,movepatblo1| ds fill-1
;Yellow Wasp
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw YellowWasp          |db 8*12|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_017:
  incbin "..\maps\b01-017.map.pck"  | .amountofobjects: db  2
;Huge Blob
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw HugeBlob            |db 8*11|dw 8*20|db 48,46|dw 16*16,spat+(16*2)|db 72-(12*6),12  ,12*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1
;Huge Blob software sprite part
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 1,        0|dw HugeBlobSWsprite    |db 0*00|dw 0*00|db 21,14|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapB01_018:
  incbin "..\maps\b01-018.map.pck"  | .amountofobjects: db  7
;Snowball Thrower
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw SnowballThrower     |db 8*21|dw 8*13|db 32,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Snowball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb1,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb2,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Snowball Thrower
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw SnowballThrower     |db 8*05|dw 8*13|db 32,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Snowball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object5: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb3,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object6: db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb4,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Trampoline Blob
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object7:db -1,        1|dw TrampolineBlob      |db 8*17|dw 8*18|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 255,movepatblo1| ds fill-1




MapB01_019:
  incbin "..\maps\b01-019.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw GlassBall5          |db 8*02|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 0,        0|dw GlassBall6          |db 8*02|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*06|dw 8*13|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1





MapB01_020:
  incbin "..\maps\b01-020.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,        0|dw GlassBall3          |db 8*19|dw 8*02|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 2,        0|dw GlassBall4          |db 8*19|dw 8*24|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*23|dw 8*13|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_021:
  incbin "..\maps\b01-021.map.pck"  | .amountofobjects: db  4
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw GlassBall1          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 0,        0|dw GlassBall2          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw Slime               |db 8*15|dw 8*27|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_022:
  incbin "..\maps\b01-022.map.pck"  | .amountofobjects: db  6
;Demontje Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw DemontjeBullet      |db 8*10|dw 8*15|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Demontje            |db 8*20|dw 8*30|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-02,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Demontje            |db 8*18|dw 8*08|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object4: db 1,        0|dw WaterfallEyesYellow |db 8*15+3|dw 8*26|db 06,14|dw CleanOb2,0 db 0,0,0,                   +067,+00,+00,+03,+01,8*15+3,8*10,8*15+3,8*18,8*15+3,8*26,movepatblo1| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object5: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*26+2|db 06,10|dw CleanOb3,0 db 0,0,0,                 +119,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object6:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_023:
  incbin "..\maps\b01-023.map.pck"  | .amountofobjects: db  6
;Black Hole Baby
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw BlackHoleBaby       |db 8*08|dw 8*05|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1
.object2:db -1,        1|dw BlackHoleBaby       |db 8*12|dw 8*16|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1
.object3:db -1,        1|dw BlackHoleBaby       |db 8*10|dw 8*22|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1
.object4:db -1,        1|dw BlackHoleBaby       |db 8*23|dw 8*03|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1
.object5:db -1,        1|dw BlackHoleBaby       |db 8*23|dw 8*17|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1
.object6:db -1,        1|dw BlackHoleBaby       |db 8*17|dw 8*33|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movepatblo1| ds fill-1

MapB01_024:
  incbin "..\maps\b01-024.map.pck"  | .amountofobjects: db  4
;Lancelot
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw Lancelot            |db 8*13|dw 8*20|db 32,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Lancelot Sword
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 1,        0|dw LancelotSword       |db 8*10|dw 8*10|db 07,27|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw BoringEye           |db 8*13|dw 8*17|db 22,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Black Hole Alien
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw BlackHoleAlien      |db 8*05|dw 8*22|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1

MapB01_025:
  incbin "..\maps\b01-025.map.pck"  | .amountofobjects: db  3
;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object4: db 1,        0|dw WaterfallEyesGrey   |db 8*15+3|dw 8*22|db 06,14|dw CleanOb1,0 db 0,0,0,                   +095,+00,+01,+02,+01,8*15+3,8*14,8*15+3,8*22,8*00+3,8*00,movepatblo1| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object5: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*22+2|db 06,10|dw CleanOb2,0 db 0,0,0,                   +139,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object6:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_026:
  incbin "..\maps\b01-026.map.pck"  | .amountofobjects: db  10
;Dripping Ooze Drop
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   ,Hit?,life 
.object1: db 1,        0|dw DrippingOozeDrop    |db 8*09-5|dw 8*10+3|db 08,05|dw CleanOb1,0 db 0,0,0,                 +149,+02,+03,+00,+63,+00,+00,8*09-5,8*10+3, 0|db 000,movepatblo1| ds fill-1
;Dripping Ooze
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -0,        1|dw DrippingOoze        |db 8*22|dw 8*24|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Dripping Ooze Drop
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   ,Hit?,life 
.object3: db 1,        0|dw DrippingOozeDrop    |db 8*09-5|dw 8*22+3|db 08,05|dw CleanOb2,0 db 0,0,0,                 +149,+02,+03,+00,180,+00,+00,8*09-5,8*22+3, 0|db 000,movepatblo1| ds fill-1
;Dripping Ooze
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -0,        1|dw DrippingOoze        |db 8*22|dw 8*24|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object5: db 1,        0|dw WaterfallEyesGrey   |db 8*15+3|dw 8*28|db 06,14|dw CleanOb3,0 db 0,0,0,                   +095,+00,200,+02,+01,8*15+3,8*06,8*15+3,8*28,8*00+3,8*00,movepatblo1| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object6: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*28+2|db 06,10|dw CleanOb4,0 db 0,0,0,                 +139,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object7:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object2:db -0,        1|dw Waterfall           |db 8*17|dw 8*28+3|db 64,10|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

;Waterfall eyes
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.object8: db 1,        0|dw WaterfallEyesYellow |db 8*15+3|dw 8*17|db 06,14|dw CleanOb5,0 db 0,0,0,                   +067,+00,+01,+01,+00,8*15+3,8*17,8*00+3,8*00,8*00+3,8*00,movepatblo1| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object9: db 1,        0|dw WaterfallMouth      |db 8*16+7|dw 8*17+2|db 06,10|dw CleanOb6,0 db 0,0,0,                 +119,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object10:db -0,        1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

MapB01_027:
  incbin "..\maps\b01-027.map.pck"  | .amountofobjects: db  7
;Big Statue Mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object0: db 1,        0|dw BigStatueMouth    |db 8*09+4|dw 8*09|db 11,14|dw CleanOb1,0 db 0,0,0,                     +014,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Cute Mini Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+90+5,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,180,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+45,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,160,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object6:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+25+5,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,110,+01,+00, 0|db 001,movepatblo1| ds fill-1
	ds		$c000-$,$ff
dephase

fill: equ 2

;NrSprites: (18 - (amount of sprites*3))

;ADDED NR sprites, so from v1 everything should be moved 1 byte to the right
;ADDED Amount sprites, so from v1 everything should be moved 1 more byte to the right
;ADDED spataddress, so from v7 everything should be moved 2 more bytes to the right
;ADDED extra byte for x, so from ny everything should be moved 1 more bytes to the right

;
; block $11 - $14
;
phase	$8000
	ds		$c000-$,$ff
dephase
phase	$8000
	ds		$c000-$,$ff
dephase
phase	$8000
	ds		$c000-$,$ff
dephase
phase	$8000
	ds		$c000-$,$ff
dephase

;
; block $15 - $18
;
phase	$0000
	ds		$4000-$,$ff
dephase
phase	$0000
	ds		$4000-$,$ff
dephase
phase	$0000
	ds		$4000-$,$ff
dephase
phase	$0000
	ds		$4000-$,$ff
dephase

;
; block $19
;
	ds		$2000 * 2

;Player's sprite positions 
;
; block $34 - $37
;
PlayerSpritesBlock:      equ   $34 / 2 
phase	$4000
PlayerSpriteData_Char_Empty:                include "..\sprites\secretsofgrindea\Empty.tgs.gen"	  
PlayerSpriteData_Colo_Empty:                include "..\sprites\secretsofgrindea\Empty.tcs.gen"	  | db +0-8,+0

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

PlayerSpriteData_Char_LeftMeditate1:       include "..\sprites\secretsofgrindea\LeftMeditate1.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate1:       include "..\sprites\secretsofgrindea\LeftMeditate1.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftMeditate2:       include "..\sprites\secretsofgrindea\LeftMeditate2.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate2:       include "..\sprites\secretsofgrindea\LeftMeditate2.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftMeditate3:       include "..\sprites\secretsofgrindea\LeftMeditate3.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate3:       include "..\sprites\secretsofgrindea\LeftMeditate3.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftMeditate4:       include "..\sprites\secretsofgrindea\LeftMeditate4.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate4:       include "..\sprites\secretsofgrindea\LeftMeditate4.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftMeditate5:       include "..\sprites\secretsofgrindea\LeftMeditate5.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate5:       include "..\sprites\secretsofgrindea\LeftMeditate5.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftMeditate6:       include "..\sprites\secretsofgrindea\LeftMeditate6.tgs.gen"	  
PlayerSpriteData_Colo_LeftMeditate6:       include "..\sprites\secretsofgrindea\LeftMeditate6.tcs.gen"	      | db -0-8,+0

PlayerSpriteData_Char_RightMeditate1:      include "..\sprites\secretsofgrindea\RightMeditate1.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate1:      include "..\sprites\secretsofgrindea\RightMeditate1.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightMeditate2:      include "..\sprites\secretsofgrindea\RightMeditate2.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate2:      include "..\sprites\secretsofgrindea\RightMeditate2.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightMeditate3:      include "..\sprites\secretsofgrindea\RightMeditate3.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate3:      include "..\sprites\secretsofgrindea\RightMeditate3.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightMeditate4:      include "..\sprites\secretsofgrindea\RightMeditate4.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate4:      include "..\sprites\secretsofgrindea\RightMeditate4.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightMeditate5:      include "..\sprites\secretsofgrindea\RightMeditate5.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate5:      include "..\sprites\secretsofgrindea\RightMeditate5.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightMeditate6:      include "..\sprites\secretsofgrindea\RightMeditate6.tgs.gen"	  
PlayerSpriteData_Colo_RightMeditate6:      include "..\sprites\secretsofgrindea\RightMeditate6.tcs.gen"	      | db -0-8,+0

PlayerSpriteData_Char_LeftShootArrow1:     include "..\sprites\secretsofgrindea\LeftShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_LeftShootArrow1:     include "..\sprites\secretsofgrindea\LeftShootArrow1.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftShootArrow2:     include "..\sprites\secretsofgrindea\LeftShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_LeftShootArrow2:     include "..\sprites\secretsofgrindea\LeftShootArrow2.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftShootArrow3:     include "..\sprites\secretsofgrindea\LeftShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_LeftShootArrow3:     include "..\sprites\secretsofgrindea\LeftShootArrow3.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_LeftShootArrow4:     include "..\sprites\secretsofgrindea\LeftShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_LeftShootArrow4:     include "..\sprites\secretsofgrindea\LeftShootArrow4.tcs.gen"	      | db -0-8,+0
EndPlayerSprites1: | ds $c000-$,$ff | dephase ;bf80

;
; block $38 - $3b
;
phase	$4000

PlayerSprites2Block:      equ   $38 / 2
phase	$4000
db 1
PlayerSpriteData_Char_Empty_Copy:           include "..\sprites\secretsofgrindea\Empty.tgs.gen"	  
PlayerSpriteData_Colo_Empty_Copy:           include "..\sprites\secretsofgrindea\Empty.tcs.gen"	  | db +0-8,+0

PlayerSpriteData_Char_RightShootArrow1:    include "..\sprites\secretsofgrindea\RightShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_RightShootArrow1:    include "..\sprites\secretsofgrindea\RightShootArrow1.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightShootArrow2:    include "..\sprites\secretsofgrindea\RightShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_RightShootArrow2:    include "..\sprites\secretsofgrindea\RightShootArrow2.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightShootArrow3:    include "..\sprites\secretsofgrindea\RightShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_RightShootArrow3:    include "..\sprites\secretsofgrindea\RightShootArrow3.tcs.gen"	      | db -0-8,+0
PlayerSpriteData_Char_RightShootArrow4:    include "..\sprites\secretsofgrindea\RightShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_RightShootArrow4:    include "..\sprites\secretsofgrindea\RightShootArrow4.tcs.gen"	      | db -0-8,+0

PlayerSpriteData_Char_LeftSitShootArrow1:  include "..\sprites\secretsofgrindea\LeftSitShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitShootArrow1:  include "..\sprites\secretsofgrindea\LeftSitShootArrow1.tcs.gen"	    | db -0-8,+0
PlayerSpriteData_Char_LeftSitShootArrow2:  include "..\sprites\secretsofgrindea\LeftSitShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitShootArrow2:  include "..\sprites\secretsofgrindea\LeftSitShootArrow2.tcs.gen"	    | db -0-8,+0
PlayerSpriteData_Char_LeftSitShootArrow3:  include "..\sprites\secretsofgrindea\LeftSitShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitShootArrow3:  include "..\sprites\secretsofgrindea\LeftSitShootArrow3.tcs.gen"	    | db -0-8,+0
PlayerSpriteData_Char_LeftSitShootArrow4:  include "..\sprites\secretsofgrindea\LeftSitShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_LeftSitShootArrow4:  include "..\sprites\secretsofgrindea\LeftSitShootArrow4.tcs.gen"	    | db -0-8,+0

PlayerSpriteData_Char_RightSitShootArrow1: include "..\sprites\secretsofgrindea\RightSitShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_RightSitShootArrow1: include "..\sprites\secretsofgrindea\RightSitShootArrow1.tcs.gen"	  | db -0-8,+0
PlayerSpriteData_Char_RightSitShootArrow2: include "..\sprites\secretsofgrindea\RightSitShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_RightSitShootArrow2: include "..\sprites\secretsofgrindea\RightSitShootArrow2.tcs.gen"	  | db -0-8,+0
PlayerSpriteData_Char_RightSitShootArrow3: include "..\sprites\secretsofgrindea\RightSitShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_RightSitShootArrow3: include "..\sprites\secretsofgrindea\RightSitShootArrow3.tcs.gen"	  | db -0-8,+0
PlayerSpriteData_Char_RightSitShootArrow4: include "..\sprites\secretsofgrindea\RightSitShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_RightSitShootArrow4: include "..\sprites\secretsofgrindea\RightSitShootArrow4.tcs.gen"	  | db -0-8,+0

PlayerSpriteData_Char_LeftJumpShootArrow1: include "..\sprites\secretsofgrindea\LeftJumpShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_LeftJumpShootArrow1: include "..\sprites\secretsofgrindea\LeftJumpShootArrow1.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftJumpShootArrow2: include "..\sprites\secretsofgrindea\LeftJumpShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_LeftJumpShootArrow2: include "..\sprites\secretsofgrindea\LeftJumpShootArrow2.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftJumpShootArrow3: include "..\sprites\secretsofgrindea\LeftJumpShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_LeftJumpShootArrow3: include "..\sprites\secretsofgrindea\LeftJumpShootArrow3.tcs.gen"	  | db +0-8,+2
PlayerSpriteData_Char_LeftJumpShootArrow4: include "..\sprites\secretsofgrindea\LeftJumpShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_LeftJumpShootArrow4: include "..\sprites\secretsofgrindea\LeftJumpShootArrow4.tcs.gen"	  | db +0-8,+2

PlayerSpriteData_Char_RightJumpShootArrow1:include "..\sprites\secretsofgrindea\RightJumpShootArrow1.tgs.gen"	  
PlayerSpriteData_Colo_RightJumpShootArrow1:include "..\sprites\secretsofgrindea\RightJumpShootArrow1.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightJumpShootArrow2:include "..\sprites\secretsofgrindea\RightJumpShootArrow2.tgs.gen"	  
PlayerSpriteData_Colo_RightJumpShootArrow2:include "..\sprites\secretsofgrindea\RightJumpShootArrow2.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightJumpShootArrow3:include "..\sprites\secretsofgrindea\RightJumpShootArrow3.tgs.gen"	  
PlayerSpriteData_Colo_RightJumpShootArrow3:include "..\sprites\secretsofgrindea\RightJumpShootArrow3.tcs.gen"	  | db +0-8,-2
PlayerSpriteData_Char_RightJumpShootArrow4:include "..\sprites\secretsofgrindea\RightJumpShootArrow4.tgs.gen"	  
PlayerSpriteData_Colo_RightJumpShootArrow4:include "..\sprites\secretsofgrindea\RightJumpShootArrow4.tcs.gen"	  | db +0-8,-2

PlayerSpriteData_Char_LeftSilhouetteHighKick:  include "..\sprites\secretsofgrindea\LeftSilhouetteHighKick.tgs.gen"	  
PlayerSpriteData_Colo_LeftSilhouetteHighKick:  include "..\sprites\secretsofgrindea\LeftSilhouetteHighKick.tcs.gen"	  | db +0-8,-6
PlayerSpriteData_Char_LeftSilhouetteLowKick:   include "..\sprites\secretsofgrindea\LeftSilhouetteLowKick.tgs.gen"	  
PlayerSpriteData_Colo_LeftSilhouetteLowKick:   include "..\sprites\secretsofgrindea\LeftSilhouetteLowKick.tcs.gen"	  | db +0-8,-6

PlayerSpriteData_Char_RightSilhouetteHighKick:  include "..\sprites\secretsofgrindea\RightSilhouetteHighKick.tgs.gen"	  
PlayerSpriteData_Colo_RightSilhouetteHighKick:  include "..\sprites\secretsofgrindea\RightSilhouetteHighKick.tcs.gen"	  | db +0-8,+6
PlayerSpriteData_Char_RightSilhouetteLowKick:   include "..\sprites\secretsofgrindea\RightSilhouetteLowKick.tgs.gen"	  
PlayerSpriteData_Colo_RightSilhouetteLowKick:   include "..\sprites\secretsofgrindea\RightSilhouetteLowKick.tcs.gen"	  | db +0-8,+6

PlayerSpriteData_Char_RightStandLookUp:     include "..\sprites\secretsofgrindea\RightStandLookUp.tgs.gen"	;x offset top, x offset bottom
PlayerSpriteData_Colo_RightStandLookUp:     include "..\sprites\secretsofgrindea\RightStandLookUp.tcs.gen"	| db -2-8,+2
PlayerSpriteData_Char_LeftStandLookUp:      include "..\sprites\secretsofgrindea\LeftStandLookUp.tgs.gen"	    
PlayerSpriteData_Colo_LeftStandLookUp:      include "..\sprites\secretsofgrindea\LeftStandLookUp.tcs.gen"		| db +2-8,-2   

PlayerSpriteData_Char_RightSitLookDown:     include "..\sprites\secretsofgrindea\RightSitLookDown.tgs.gen"	;x offset top, x offset bottom
PlayerSpriteData_Colo_RightSitLookDown:     include "..\sprites\secretsofgrindea\RightSitLookDown.tcs.gen"	| db -0-8,+0
PlayerSpriteData_Char_LeftSitLookDown:      include "..\sprites\secretsofgrindea\LeftSitLookDown.tgs.gen"	    
PlayerSpriteData_Colo_LeftSitLookDown:      include "..\sprites\secretsofgrindea\LeftSitLookDown.tcs.gen"		| db +0-8,+0   

PlayerSpriteData_Char_LeftSpearAttack1:         include "..\sprites\secretsofgrindea\LeftSpearAttack1.tgs.gen"	  
PlayerSpriteData_Colo_LeftSpearAttack1:         include "..\sprites\secretsofgrindea\LeftSpearAttack1.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftSpearAttack2:         include "..\sprites\secretsofgrindea\LeftSpearAttack2.tgs.gen"	  
PlayerSpriteData_Colo_LeftSpearAttack2:         include "..\sprites\secretsofgrindea\LeftSpearAttack2.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftSpearAttack3:         include "..\sprites\secretsofgrindea\LeftSpearAttack3.tgs.gen"	  
PlayerSpriteData_Colo_LeftSpearAttack3:         include "..\sprites\secretsofgrindea\LeftSpearAttack3.tcs.gen"	  | db -3-8,+3
PlayerSpriteData_Char_LeftSpearAttack4:         include "..\sprites\secretsofgrindea\LeftSpearAttack4.tgs.gen"	  
PlayerSpriteData_Colo_LeftSpearAttack4:         include "..\sprites\secretsofgrindea\LeftSpearAttack4.tcs.gen"	  | db -4-8,+4

PlayerSpriteData_Char_RightSpearAttack1:        include "..\sprites\secretsofgrindea\RightSpearAttack1.tgs.gen"	  
PlayerSpriteData_Colo_RightSpearAttack1:        include "..\sprites\secretsofgrindea\RightSpearAttack1.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightSpearAttack2:        include "..\sprites\secretsofgrindea\RightSpearAttack2.tgs.gen"	  
PlayerSpriteData_Colo_RightSpearAttack2:        include "..\sprites\secretsofgrindea\RightSpearAttack2.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightSpearAttack3:        include "..\sprites\secretsofgrindea\RightSpearAttack3.tgs.gen"	  
PlayerSpriteData_Colo_RightSpearAttack3:        include "..\sprites\secretsofgrindea\RightSpearAttack3.tcs.gen"	  | db +3-8,-3
PlayerSpriteData_Char_RightSpearAttack4:        include "..\sprites\secretsofgrindea\RightSpearAttack4.tgs.gen"	  
PlayerSpriteData_Colo_RightSpearAttack4:        include "..\sprites\secretsofgrindea\RightSpearAttack4.tcs.gen"	  | db +4-8,-4

EndPlayerSprites2: | ds $c000-$,$ff | dephase
dephase


;
; block $1e - $1f
;
	ds		$8000

;
; block $20
;
RetardZombieSpriteblock:  equ   $20
SlimeSpriteblock:  equ   $20
BeetleSpriteblock:  equ   $20
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
; block $42 + $43
;
GreenSpiderSpriteblock:  equ   $42 / 2
BoringEyeRedSpriteblock:  equ   $42 / 2
BatSpriteblock:  equ   $42 / 2
OctopussySpriteblock:  equ   $42 / 2
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
; block $44 + $45
;
GreySpiderSpriteblock:  equ   $44 / 2
BoringEyeGreenSpriteblock:  equ   $44 / 2
HunchbackSpriteblock:  equ   $44 / 2
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
; block $46 + $47
;
RedExplosionSpriteblock:  equ   $46 / 2
ScorpionSpriteblock:  equ   $46 / 2
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

CoinI1_Char:                                include "..\sprites\collectables\CoinI1.tgs.gen" 
CoinI1_Col:                                 include "..\sprites\collectables\CoinI1.tcs.gen"  | db 00,00,00,00
CoinI2_Char:                                include "..\sprites\collectables\CoinI2.tgs.gen" 
CoinI2_Col:                                 include "..\sprites\collectables\CoinI2.tcs.gen"  | db 00,00,00,00
CoinI3_Char:                                include "..\sprites\collectables\CoinI3.tgs.gen" 
CoinI3_Col:                                 include "..\sprites\collectables\CoinI3.tcs.gen"  | db 00,00,00,00
CoinI4_Char:                                include "..\sprites\collectables\CoinI4.tgs.gen" 
CoinI4_Col:                                 include "..\sprites\collectables\CoinI4.tcs.gen"  | db 00,00,00,00
CoinI5_Char:                                include "..\sprites\collectables\CoinI5.tgs.gen" 
CoinI5_Col:                                 include "..\sprites\collectables\CoinI5.tcs.gen"  | db 00,00,00,00
CoinI6_Char:                                include "..\sprites\collectables\CoinI6.tgs.gen" 
CoinI6_Col:                                 include "..\sprites\collectables\CoinI6.tcs.gen"  | db 00,00,00,00

CoinV1_Char:                                include "..\sprites\collectables\CoinV1.tgs.gen" 
CoinV1_Col:                                 include "..\sprites\collectables\CoinV1.tcs.gen"  | db 00,00,00,00
CoinV2_Char:                                include "..\sprites\collectables\CoinV2.tgs.gen" 
CoinV2_Col:                                 include "..\sprites\collectables\CoinV2.tcs.gen"  | db 00,00,00,00
CoinV3_Char:                                include "..\sprites\collectables\CoinV3.tgs.gen" 
CoinV3_Col:                                 include "..\sprites\collectables\CoinV3.tcs.gen"  | db 00,00,00,00
CoinV4_Char:                                include "..\sprites\collectables\CoinV4.tgs.gen" 
CoinV4_Col:                                 include "..\sprites\collectables\CoinV4.tcs.gen"  | db 00,00,00,00
CoinV5_Char:                                include "..\sprites\collectables\CoinV5.tgs.gen" 
CoinV5_Col:                                 include "..\sprites\collectables\CoinV5.tcs.gen"  | db 00,00,00,00
CoinV6_Char:                                include "..\sprites\collectables\CoinV6.tgs.gen" 
CoinV6_Col:                                 include "..\sprites\collectables\CoinV6.tcs.gen"  | db 00,00,00,00

CoinX1_Char:                                include "..\sprites\collectables\CoinX1.tgs.gen" 
CoinX1_Col:                                 include "..\sprites\collectables\CoinX1.tcs.gen"  | db 00,00,00,00
CoinX2_Char:                                include "..\sprites\collectables\CoinX2.tgs.gen" 
CoinX2_Col:                                 include "..\sprites\collectables\CoinX2.tcs.gen"  | db 00,00,00,00
CoinX3_Char:                                include "..\sprites\collectables\CoinX3.tgs.gen" 
CoinX3_Col:                                 include "..\sprites\collectables\CoinX3.tcs.gen"  | db 00,00,00,00
CoinX4_Char:                                include "..\sprites\collectables\CoinX4.tgs.gen" 
CoinX4_Col:                                 include "..\sprites\collectables\CoinX4.tcs.gen"  | db 00,00,00,00
CoinX5_Char:                                include "..\sprites\collectables\CoinX5.tgs.gen" 
CoinX5_Col:                                 include "..\sprites\collectables\CoinX5.tcs.gen"  | db 00,00,00,00
CoinX6_Char:                                include "..\sprites\collectables\CoinX6.tgs.gen" 
CoinX6_Col:                                 include "..\sprites\collectables\CoinX6.tcs.gen"  | db 00,00,00,00

CoinILU_Char:                               include "..\sprites\collectables\CoinILU.tgs.gen" 
CoinILU_Col:                                include "..\sprites\collectables\CoinILU.tcs.gen"  | db 03,03,03,03
CoinIL_Char:                                include "..\sprites\collectables\CoinIL.tgs.gen" 
CoinIL_Col:                                 include "..\sprites\collectables\CoinIL.tcs.gen"  | db 00,03,00,03
CoinILD_Char:                               include "..\sprites\collectables\CoinILD.tgs.gen" 
CoinILD_Col:                                include "..\sprites\collectables\CoinILD.tcs.gen"  | db -3,03,-3,03
CoinID_Char:                                include "..\sprites\collectables\CoinID.tgs.gen" 
CoinID_Col:                                 include "..\sprites\collectables\CoinID.tcs.gen"  | db -3,00,-3,00
CoinIRD_Char:                               include "..\sprites\collectables\CoinIRD.tgs.gen" 
CoinIRD_Col:                                include "..\sprites\collectables\CoinIRD.tcs.gen"  | db -3,-3,-3,-3
CoinIR_Char:                                include "..\sprites\collectables\CoinIR.tgs.gen" 
CoinIR_Col:                                 include "..\sprites\collectables\CoinIR.tcs.gen"  | db 00,-3,00,-3
CoinIRU_Char:                               include "..\sprites\collectables\CoinIRU.tgs.gen" 
CoinIRu_Col:                                include "..\sprites\collectables\CoinIRU.tcs.gen"  | db 03,-3,03,-3
CoinIU_Char:                                include "..\sprites\collectables\CoinIU.tgs.gen" 
CoinIU_Col:                                 include "..\sprites\collectables\CoinIU.tcs.gen"  | db 03,00,03,00

CoinVLU_Char:                               include "..\sprites\collectables\CoinVLU.tgs.gen" 
CoinVLU_Col:                                include "..\sprites\collectables\CoinVLU.tcs.gen"  | db 03,03,03,03
CoinVL_Char:                                include "..\sprites\collectables\CoinVL.tgs.gen" 
CoinVL_Col:                                 include "..\sprites\collectables\CoinVL.tcs.gen"  | db 00,03,00,03
CoinVLD_Char:                               include "..\sprites\collectables\CoinVLD.tgs.gen" 
CoinVLD_Col:                                include "..\sprites\collectables\CoinVLD.tcs.gen"  | db -3,03,-3,03
CoinVD_Char:                                include "..\sprites\collectables\CoinVD.tgs.gen" 
CoinVD_Col:                                 include "..\sprites\collectables\CoinVD.tcs.gen"  | db -3,00,-3,00
CoinVRD_Char:                               include "..\sprites\collectables\CoinVRD.tgs.gen" 
CoinVRD_Col:                                include "..\sprites\collectables\CoinVRD.tcs.gen"  | db -3,-3,-3,-3
CoinVR_Char:                                include "..\sprites\collectables\CoinVR.tgs.gen" 
CoinVR_Col:                                 include "..\sprites\collectables\CoinVR.tcs.gen"  | db 00,-3,00,-3
CoinVRU_Char:                               include "..\sprites\collectables\CoinVRU.tgs.gen" 
CoinVRu_Col:                                include "..\sprites\collectables\CoinVRU.tcs.gen"  | db 03,-3,03,-3
CoinVU_Char:                                include "..\sprites\collectables\CoinVU.tgs.gen" 
CoinVU_Col:                                 include "..\sprites\collectables\CoinVU.tcs.gen"  | db 03,00,03,00

CoinXLU_Char:                               include "..\sprites\collectables\CoinXLU.tgs.gen" 
CoinXLU_Col:                                include "..\sprites\collectables\CoinXLU.tcs.gen"  | db 03,03,03,03
CoinXL_Char:                                include "..\sprites\collectables\CoinXL.tgs.gen" 
CoinXL_Col:                                 include "..\sprites\collectables\CoinXL.tcs.gen"  | db 00,03,00,03
CoinXLD_Char:                               include "..\sprites\collectables\CoinXLD.tgs.gen" 
CoinXLD_Col:                                include "..\sprites\collectables\CoinXLD.tcs.gen"  | db -3,03,-3,03
CoinXD_Char:                                include "..\sprites\collectables\CoinXD.tgs.gen" 
CoinXD_Col:                                 include "..\sprites\collectables\CoinXD.tcs.gen"  | db -3,00,-3,00
CoinXRD_Char:                               include "..\sprites\collectables\CoinXRD.tgs.gen" 
CoinXRD_Col:                                include "..\sprites\collectables\CoinXRD.tcs.gen"  | db -3,-3,-3,-3
CoinXR_Char:                                include "..\sprites\collectables\CoinXR.tgs.gen" 
CoinXR_Col:                                 include "..\sprites\collectables\CoinXR.tcs.gen"  | db 00,-3,00,-3
CoinXRU_Char:                               include "..\sprites\collectables\CoinXRU.tgs.gen" 
CoinXRu_Col:                                include "..\sprites\collectables\CoinXRU.tcs.gen"  | db 03,-3,03,-3
CoinXU_Char:                                include "..\sprites\collectables\CoinXU.tgs.gen" 
CoinXU_Col:                                 include "..\sprites\collectables\CoinXU.tcs.gen"  | db 03,00,03,00

CoinEmpty_Char:                             include "..\sprites\collectables\coinEmpty.tgs.gen" 
CoinEmpty_Col:                              include "..\sprites\collectables\coinEmpty.tcs.gen"  | db 00,00,00,00

CoinAfterglow1_Char:                        include "..\sprites\collectables\coinAfterglow1.tgs.gen" 
CoinAfterglow1_Col:                         include "..\sprites\collectables\coinAfterglow1.tcs.gen"  | db 00,00,00,00
CoinAfterglow2_Char:                        include "..\sprites\collectables\coinAfterglow2.tgs.gen" 
CoinAfterglow2_Col:                         include "..\sprites\collectables\coinAfterglow2.tcs.gen"  | db 00,00,00,00
CoinAfterglow3_Char:                        include "..\sprites\collectables\coinAfterglow3.tgs.gen" 
CoinAfterglow3_Col:                         include "..\sprites\collectables\coinAfterglow3.tcs.gen"  | db 00,00,00,00
CoinAfterglow4_Char:                        include "..\sprites\collectables\coinAfterglow4.tgs.gen" 
CoinAfterglow4_Col:                         include "..\sprites\collectables\coinAfterglow4.tcs.gen"  | db 00,00,00,00
CoinAfterglow5_Char:                        include "..\sprites\collectables\coinAfterglow5.tgs.gen" 
CoinAfterglow5_Col:                         include "..\sprites\collectables\coinAfterglow5.tcs.gen"  | db 00,00,00,00
CoinAfterglow6_Char:                        include "..\sprites\collectables\coinAfterglow6.tgs.gen" 
CoinAfterglow6_Col:                         include "..\sprites\collectables\coinAfterglow6.tcs.gen"  | db 00,00,00,00
CoinAfterglow7_Char:                        include "..\sprites\collectables\coinAfterglow7.tgs.gen" 
CoinAfterglow7_Col:                         include "..\sprites\collectables\coinAfterglow7.tcs.gen"  | db 00,00,00,00
CoinAfterglow8_Char:                        include "..\sprites\collectables\coinAfterglow8.tgs.gen" 
CoinAfterglow8_Col:                         include "..\sprites\collectables\coinAfterglow8.tcs.gen"  | db 00,00,00,00
CoinAfterglow9_Char:                        include "..\sprites\collectables\coinAfterglow9.tgs.gen" 
CoinAfterglow9_Col:                         include "..\sprites\collectables\coinAfterglow9.tcs.gen"  | db 00,00,00,00
CoinAfterglow10_Char:                       include "..\sprites\collectables\coinAfterglow10.tgs.gen" 
CoinAfterglow10_Col:                        include "..\sprites\collectables\coinAfterglow10.tcs.gen"  | db 00,00,00,00
CoinAfterglow11_Char:                       include "..\sprites\collectables\coinAfterglow11.tgs.gen" 
CoinAfterglow11_Col:                        include "..\sprites\collectables\coinAfterglow11.tcs.gen"  | db 00,00,00,00
CoinAfterglow12_Char:                       include "..\sprites\collectables\coinAfterglow12.tgs.gen" 
CoinAfterglow12_Col:                        include "..\sprites\collectables\coinAfterglow12.tcs.gen"  | db 00,00,00,00
CoinAfterglow13_Char:                       include "..\sprites\collectables\coinAfterglow13.tgs.gen" 
CoinAfterglow13_Col:                        include "..\sprites\collectables\coinAfterglow13.tcs.gen"  | db 00,00,00,00
CoinAfterglow14_Char:                       include "..\sprites\collectables\coinAfterglow14.tgs.gen" 
CoinAfterglow14_Col:                        include "..\sprites\collectables\coinAfterglow14.tcs.gen"  | db 00,00,00,00
CoinAfterglow15_Char:                       include "..\sprites\collectables\coinAfterglow15.tgs.gen" 
CoinAfterglow15_Col:                        include "..\sprites\collectables\coinAfterglow15.tcs.gen"  | db 00,00,00,00
CoinAfterglow16_Char:                       include "..\sprites\collectables\coinAfterglow16.tgs.gen" 
CoinAfterglow16_Col:                        include "..\sprites\collectables\coinAfterglow16.tcs.gen"  | db 00,00,00,00
CoinAfterglow17_Char:                       include "..\sprites\collectables\coinAfterglow17.tgs.gen" 
CoinAfterglow17_Col:                        include "..\sprites\collectables\coinAfterglow17.tcs.gen"  | db 00,00,00,00
CoinAfterglow18_Char:                       include "..\sprites\collectables\coinAfterglow18.tgs.gen" 
CoinAfterglow18_Col:                        include "..\sprites\collectables\coinAfterglow18.tcs.gen"  | db 00,00,00,00
CoinAfterglow19_Char:                       include "..\sprites\collectables\coinAfterglow19.tgs.gen" 
CoinAfterglow19_Col:                        include "..\sprites\collectables\coinAfterglow19.tcs.gen"  | db 00,00,00,00
CoinAfterglow20_Char:                       include "..\sprites\collectables\coinAfterglow20.tgs.gen" 
CoinAfterglow20_Col:                        include "..\sprites\collectables\coinAfterglow20.tcs.gen"  | db 00,00,00,00

	ds		$c000-$,$ff
dephase

;
; block $48 + $49
;
GreyExplosionSpriteblock:  equ   $48 / 2
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
; block $4a + $4b
;
GrinderSpriteblock:  equ   $4a / 2
TreemanSpriteblock:  equ   $4a / 2
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
; block $4c + $4d
;
GreenWaspSpriteblock:  equ   $4c / 2
LandstriderSpriteblock:  equ   $4c / 2
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
; block $4e + $4f
;
BrownWaspSpriteblock:  equ   $4e / 2
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
; block $50 + $51
;
FireEyeGreySpriteblock:  equ   $50 / 2
DemontjeBrownSpriteblock:  equ   $50 / 2
HugeBlobSpriteblock:  equ   $50 / 2
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
; block $29 ;$52 + $53
;
FireEyeGreenSpriteblock:  equ   $29 ;$52 / 2
DemontjeGreenSpriteblock:  equ  $29 ; $52 / 2
HugeBlobWhiteSpriteblock:  equ  $29 ; $52 / 2
SensorTentaclesSpriteblock: equ $29 ;  $52 / 2
YellowWaspSpriteblock:  equ   $29 ;$52 / 2
HugeSpiderSpriteblock:  equ   $29 ;$52 / 2
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

HugeSpider1_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",0*8*32,8*32	  
HugeSpider1_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider2_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",1*8*32,8*32	  
HugeSpider2_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider3_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",2*8*32,8*32	  
HugeSpider3_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,01, 16,17, 16,33, 16,49
HugeSpider4_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",3*8*32,8*32	  
HugeSpider4_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,02, 16,18, 16,34, 16,50
HugeSpider5_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",4*8*32,8*32	  
HugeSpider5_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider6_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",5*8*32,8*32	  
HugeSpider6_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider7_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",6*8*32,8*32	  
HugeSpider7_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider8_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",7*8*32,8*32	  
HugeSpider8_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider9_Char:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",8*8*32,8*32	  
HugeSpider9_Col:                            incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider10_Char:                          incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",9*8*32,8*32	  
HugeSpider10_Col:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider11_Char:                          incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",10*8*32,8*32	  
HugeSpider11_Col:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
HugeSpider12_Char:                          incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\1.spr",11*8*32,8*32	  
HugeSpider12_Col:                           incbin "..\sprites\enemies\HugeSpider\1SpriteOnly\black.spr",8*32*12,8*16  | db 00,00, 00,16, 0,32, 0,48, 16,00, 16,16, 16,32, 16,48
	ds		$c000-$,$ff
dephase

;
; block $54 + $55
;
DemontjeGreySpriteblock:  equ   $54 / 2
SnowballThrowerSpriteblock:  equ   $54 / 2
TrampolineBlobSpriteblock:  equ   $54 / 2
BlackHoleAlienSpriteblock:  equ   $54 / 2
BlackHoleBabySpriteblock:  equ   $54 / 2
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
; block $56 + $57
;
DemontjeRedSpriteblock:  equ   $56 / 2
WaterfallSpriteblock:  equ   $56 / 2
DrippingOozeSpriteblock:  equ   $56 / 2
CuteMiniBatSpriteblock:  equ   $56 / 2
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


; block $58
  ds    $4000 * 5


;
; block $31
;
Graphicsblock5:  equ   $31 
phase	$8000
scoreboard:
  incbin "..\grapx\scoreboard\scoreboard.SC5",7,39*128  ;skip header
itemsKarniMata:
  incbin "..\grapx\itemsKarniMata.SC5",7,$1400  ;skip header
ElementalWeapons:
  incbin "..\grapx\ElementalWeapons.SC5",7,128*22  ;=$b00 - skip header
	ds		$c000-$,$ff
dephase

; block $32
  ds    $4000


;
; block $33
;
LancelotSpriteblock:  equ   $33
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
; block $34
;
LancelotShieldHitSpriteblock:  equ   $34
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

; block $35
  ds $4000 * 19





;
; block $48
;
phase	$8000
MapsBlockBU01:  equ   $48 | MapBU01: incbin "..\maps\BU01.map.pck"  | include "..\maps\mapdata\BU01.asm"  
MapsBlockBU03:  equ   $48 | MapBU03: incbin "..\maps\BU03.map.pck"  | include "..\maps\mapdata\BU03.asm"  
MapsBlockBU04:  equ   $48 | MapBU04: incbin "..\maps\BU04.map.pck"  | include "..\maps\mapdata\BU04.asm"  
MapsBlockBU05:  equ   $48 | MapBU05: incbin "..\maps\BU05.map.pck"  | include "..\maps\mapdata\BU05.asm"  
MapsBlockBU06:  equ   $48 | MapBU06: incbin "..\maps\BU06.map.pck"  | include "..\maps\mapdata\BU06.asm"  
MapsBlockBU07:  equ   $48 | MapBU07: incbin "..\maps\BU07.map.pck"  | include "..\maps\mapdata\BU07.asm"  
MapsBlockBU08:  equ   $48 | MapBU08: incbin "..\maps\BU08.map.pck"  | include "..\maps\mapdata\BU08.asm"  
MapsBlockBU13:  equ   $48 | MapBU13: incbin "..\maps\BU13.map.pck"  | include "..\maps\mapdata\BU13.asm"  
MapsBlockBU14:  equ   $48 | MapBU14: incbin "..\maps\BU14.map.pck"  | include "..\maps\mapdata\BU14.asm"  
MapsBlockBU15:  equ   $48 | MapBU15: incbin "..\maps\BU15.map.pck"  | include "..\maps\mapdata\BU15.asm"  
MapsBlockBU16:  equ   $48 | MapBU16: incbin "..\maps\BU16.map.pck"  | include "..\maps\mapdata\BU16.asm"  
MapsBlockBU17:  equ   $48 | MapBU17: incbin "..\maps\BU17.map.pck"  | include "..\maps\mapdata\BU17.asm"  
MapsBlockBU22:  equ   $48 | MapBU22: incbin "..\maps\BU22.map.pck"  | include "..\maps\mapdata\BU22.asm"  
MapsBlockBU24:  equ   $48 | MapBU24: incbin "..\maps\BU24.map.pck"  | include "..\maps\mapdata\BU24.asm"  
MapsBlockBU26:  equ   $48 | MapBU26: incbin "..\maps\BU26.map.pck"  | include "..\maps\mapdata\BU26.asm"  
MapsBlockBU27:  equ   $48 | MapBU27: incbin "..\maps\BU27.map.pck"  | include "..\maps\mapdata\BU27.asm"  
MapsBlockBU30:  equ   $48 | MapBU30: incbin "..\maps\BU30.map.pck"  | include "..\maps\mapdata\BU30.asm"  
MapsBlockBU31:  equ   $48 | MapBU31: incbin "..\maps\BU31.map.pck"  | include "..\maps\mapdata\BU31.asm"  
MapsBlockBU33:  equ   $48 | MapBU33: incbin "..\maps\BU33.map.pck"  | include "..\maps\mapdata\BU33.asm"  
MapsBlockBU36:  equ   $48 | MapBU36: incbin "..\maps\BU36.map.pck"  | include "..\maps\mapdata\BU36.asm"  
MapsBlockBU37:  equ   $48 | MapBU37: incbin "..\maps\BU37.map.pck"  | include "..\maps\mapdata\BU37.asm"  
MapsBlockBU40:  equ   $48 | MapBU40: incbin "..\maps\BU40.map.pck"  | include "..\maps\mapdata\BU40.asm"  
MapsBlockBU44:  equ   $48 | MapBU44: incbin "..\maps\BU44.map.pck"  | include "..\maps\mapdata\BU44.asm"  
MapsBlockBU45:  equ   $48 | MapBU45: incbin "..\maps\BU45.map.pck"  | include "..\maps\mapdata\BU45.asm"  
MapsBlockBU46:  equ   $48 | MapBU46: incbin "..\maps\BU46.map.pck"  | include "..\maps\mapdata\BU46.asm"  
MapsBlockBU47:  equ   $48 | MapBU47: incbin "..\maps\BU47.map.pck"  | include "..\maps\mapdata\BU47.asm"  
MapsBlockBU48:  equ   $48 | MapBU48: incbin "..\maps\BU48.map.pck"  | include "..\maps\mapdata\BU48.asm"  
MapsBlockBU49:  equ   $48 | MapBU49: incbin "..\maps\BU49.map.pck"  | include "..\maps\mapdata\BU49.asm"  
MapsBlockBU50:  equ   $48 | MapBU50: incbin "..\maps\BU50.map.pck"  | include "..\maps\mapdata\BU50.asm"  
	ds		$c000-$,$ff
dephase



;
; block $49
;
phase	$8000
MapsBlockBV01:  equ   $49 | MapBV01: incbin "..\maps\BV01.map.pck"  | include "..\maps\mapdata\BV01.asm"  
MapsBlockBV05:  equ   $49 | MapBV05: incbin "..\maps\BV05.map.pck"  | include "..\maps\mapdata\BV05.asm"  
MapsBlockBV07:  equ   $49 | MapBV07: incbin "..\maps\BV07.map.pck"  | include "..\maps\mapdata\BV07.asm"  
MapsBlockBV14:  equ   $49 | MapBV14: incbin "..\maps\BV14.map.pck"  | include "..\maps\mapdata\BV14.asm"  
MapsBlockBV17:  equ   $49 | MapBV17: incbin "..\maps\BV17.map.pck"  | include "..\maps\mapdata\BV17.asm"  
MapsBlockBV24:  equ   $49 | MapBV24: incbin "..\maps\BV24.map.pck"  | include "..\maps\mapdata\BV24.asm"  
MapsBlockBV27:  equ   $49 | MapBV27: incbin "..\maps\BV27.map.pck"  | include "..\maps\mapdata\BV27.asm"  
MapsBlockBV30:  equ   $49 | MapBV30: incbin "..\maps\BV30.map.pck"  | include "..\maps\mapdata\BV30.asm"  
MapsBlockBV31:  equ   $49 | MapBV31: incbin "..\maps\BV31.map.pck"  | include "..\maps\mapdata\BV31.asm"  
MapsBlockBV33:  equ   $49 | MapBV33: incbin "..\maps\BV33.map.pck"  | include "..\maps\mapdata\BV33.asm"  
MapsBlockBV34:  equ   $49 | MapBV34: incbin "..\maps\BV34.map.pck"  | include "..\maps\mapdata\BV34.asm"  
MapsBlockBV37:  equ   $49 | MapBV37: incbin "..\maps\BV37.map.pck"  | include "..\maps\mapdata\BV37.asm"  
MapsBlockBV39:  equ   $49 | MapBV39: incbin "..\maps\BV39.map.pck"  | include "..\maps\mapdata\BV39.asm"  
MapsBlockBV40:  equ   $49 | MapBV40: incbin "..\maps\BV40.map.pck"  | include "..\maps\mapdata\BV40.asm"  
MapsBlockBV44:  equ   $49 | MapBV44: incbin "..\maps\BV44.map.pck"  | include "..\maps\mapdata\BV44.asm"  
MapsBlockBV47:  equ   $49 | MapBV47: incbin "..\maps\BV47.map.pck"  | include "..\maps\mapdata\BV47.asm"  
MapsBlockBV48:  equ   $49 | MapBV48: incbin "..\maps\BV48.map.pck"  | include "..\maps\mapdata\BV48.asm"  
MapsBlockBV50:  equ   $49 | MapBV50: incbin "..\maps\BV50.map.pck"  | include "..\maps\mapdata\BV50.asm"  
	ds		$c000-$,$ff
dephase

;
; block $4a
;
phase	$8000
MapsBlockBW01:  equ   $4a | MapBW01: incbin "..\maps\BW01.map.pck"  | include "..\maps\mapdata\BW01.asm"  
MapsBlockBW02:  equ   $4a | MapBW02: incbin "..\maps\BW02.map.pck"  | include "..\maps\mapdata\BW02.asm"  
MapsBlockBW04:  equ   $4a | MapBW04: incbin "..\maps\BW04.map.pck"  | include "..\maps\mapdata\BW04.asm"  
MapsBlockBW05:  equ   $4a | MapBW05: incbin "..\maps\BW05.map.pck"  | include "..\maps\mapdata\BW05.asm"  
MapsBlockBW13:  equ   $4a | MapBW13: incbin "..\maps\BW13.map.pck"  | include "..\maps\mapdata\BW13.asm"  
MapsBlockBW14:  equ   $4a | MapBW14: incbin "..\maps\BW14.map.pck"  | include "..\maps\mapdata\BW14.asm"  
MapsBlockBW17:  equ   $4a | MapBW17: incbin "..\maps\BW17.map.pck"  | include "..\maps\mapdata\BW17.asm"  
MapsBlockBW18:  equ   $4a | MapBW18: incbin "..\maps\BW18.map.pck"  | include "..\maps\mapdata\BW18.asm"  
MapsBlockBW24:  equ   $4a | MapBW24: incbin "..\maps\BW24.map.pck"  | include "..\maps\mapdata\BW24.asm"  
MapsBlockBW25:  equ   $4a | MapBW25: incbin "..\maps\BW25.map.pck"  | include "..\maps\mapdata\BW25.asm"  
MapsBlockBW26:  equ   $4a | MapBW26: incbin "..\maps\BW26.map.pck"  | include "..\maps\mapdata\BW26.asm"  
MapsBlockBW27:  equ   $4a | MapBW27: incbin "..\maps\BW27.map.pck"  | include "..\maps\mapdata\BW27.asm"  
MapsBlockBW30:  equ   $4a | MapBW30: incbin "..\maps\BW30.map.pck"  | include "..\maps\mapdata\BW30.asm"  
MapsBlockBW33:  equ   $4a | MapBW33: incbin "..\maps\BW33.map.pck"  | include "..\maps\mapdata\BW33.asm"  
MapsBlockBW34:  equ   $4a | MapBW34: incbin "..\maps\BW34.map.pck"  | include "..\maps\mapdata\BW34.asm"  
MapsBlockBW35:  equ   $4a | MapBW35: incbin "..\maps\BW35.map.pck"  | include "..\maps\mapdata\BW35.asm"  
MapsBlockBW40:  equ   $4a | MapBW40: incbin "..\maps\BW40.map.pck"  | include "..\maps\mapdata\BW40.asm"  
MapsBlockBW46:  equ   $4a | MapBW46: incbin "..\maps\BW46.map.pck"  | include "..\maps\mapdata\BW46.asm"  
MapsBlockBW47:  equ   $4a | MapBW47: incbin "..\maps\BW47.map.pck"  | include "..\maps\mapdata\BW47.asm"  
MapsBlockBW49:  equ   $4a | MapBW49: incbin "..\maps\BW49.map.pck"  | include "..\maps\mapdata\BW49.asm"  
MapsBlockBW50:  equ   $4a | MapBW50: incbin "..\maps\BW50.map.pck"  | include "..\maps\mapdata\BW50.asm"  
	ds		$c000-$,$ff
dephase


;
; block $4b
;
phase	$8000
MapsBlockBX02:  equ   $4b | MapBX02: incbin "..\maps\BX02.map.pck"  | include "..\maps\mapdata\BX02.asm"  
MapsBlockBX03:  equ   $4b | MapBX03: incbin "..\maps\BX03.map.pck"  | include "..\maps\mapdata\BX03.asm"  
MapsBlockBX04:  equ   $4b | MapBX04: incbin "..\maps\BX04.map.pck"  | include "..\maps\mapdata\BX04.asm"  
MapsBlockBX27:  equ   $4b | MapBX27: incbin "..\maps\BX27.map.pck"  | include "..\maps\mapdata\BX27.asm"  
MapsBlockBX28:  equ   $4b | MapBX28: incbin "..\maps\BX28.map.pck"  | include "..\maps\mapdata\BX28.asm"  
MapsBlockBX29:  equ   $4b | MapBX29: incbin "..\maps\BX29.map.pck"  | include "..\maps\mapdata\BX29.asm"  
MapsBlockBX30:  equ   $4b | MapBX30: incbin "..\maps\BX30.map.pck"  | include "..\maps\mapdata\BX30.asm"  
MapsBlockBX40:  equ   $4b | MapBX40: incbin "..\maps\BX40.map.pck"  | include "..\maps\mapdata\BX40.asm"  
MapsBlockBX41:  equ   $4b | MapBX41: incbin "..\maps\BX41.map.pck"  | include "..\maps\mapdata\BX41.asm"  
MapsBlockBX42:  equ   $4b | MapBX42: incbin "..\maps\BX42.map.pck"  | include "..\maps\mapdata\BX42.asm"  
MapsBlockBX43:  equ   $4b | MapBX43: incbin "..\maps\BX43.map.pck"  | include "..\maps\mapdata\BX43.asm"  
MapsBlockBX44:  equ   $4b | MapBX44: incbin "..\maps\BX44.map.pck"  | include "..\maps\mapdata\BX44.asm"  
MapsBlockBX45:  equ   $4b | MapBX45: incbin "..\maps\BX45.map.pck"  | include "..\maps\mapdata\BX45.asm"  
MapsBlockBX46:  equ   $4b | MapBX46: incbin "..\maps\BX46.map.pck"  | include "..\maps\mapdata\BX46.asm"  
MapsBlockBX47:  equ   $4b | MapBX47: incbin "..\maps\BX47.map.pck"  | include "..\maps\mapdata\BX47.asm"  
MapsBlockBX48:  equ   $4b | MapBX48: incbin "..\maps\BX48.map.pck"  | include "..\maps\mapdata\BX48.asm"  
MapsBlockBX49:  equ   $4b | MapBX49: incbin "..\maps\BX49.map.pck"  | include "..\maps\mapdata\BX49.asm"  
MapsBlockBX50:  equ   $4b | MapBX50: incbin "..\maps\BX50.map.pck"  | include "..\maps\mapdata\BX50.asm"  
	ds		$c000-$,$ff
dephase













;
; block $4c
;
PlayerReflectionSpriteblock:  equ   $4c ;$98 / 2
phase	$8000
ReflPlayerSpriteData_Char_RightStand:           include "..\sprites\enemies\ReflectionPlayer\RightStand.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightStand:           include "..\sprites\enemies\ReflectionPlayer\RightStand.tcs.gen"  | db 0,0, 0,0, 0,0

ReflPlayerSpriteData_Char_LeftStand:           	include "..\sprites\enemies\ReflectionPlayer\LeftStand.tgs.gen"	    
ReflPlayerSpriteData_Colo_LeftStand:           	include "..\sprites\enemies\ReflectionPlayer\LeftStand.tcs.gen"		| db 0,0, 0,0, 0,0

ReflPlayerSpriteData_Char_RightRun7:            include "..\sprites\enemies\ReflectionPlayer\RightRun7.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun7:            include "..\sprites\enemies\ReflectionPlayer\RightRun7.tcs.gen"	  | db 0,-1, 0,-1, 0,-1 ; db +0-8,-1
ReflPlayerSpriteData_Char_RightRun8:            include "..\sprites\enemies\ReflectionPlayer\RightRun8.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun8:            include "..\sprites\enemies\ReflectionPlayer\RightRun8.tcs.gen"	  | db 0,-2, 0,-2, 0,-2 ; db +0-8,-2
ReflPlayerSpriteData_Char_RightRun9:            include "..\sprites\enemies\ReflectionPlayer\RightRun9.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun9:            include "..\sprites\enemies\ReflectionPlayer\RightRun9.tcs.gen"	  | db 0,-2, 0,-2, 0,-2 ; db +0-8,-2
ReflPlayerSpriteData_Char_RightRun10:           include "..\sprites\enemies\ReflectionPlayer\RightRun10.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun10:           include "..\sprites\enemies\ReflectionPlayer\RightRun10.tcs.gen"	| db 0,-2, 0,-2, 0,-2 ; db +0-8,-2  
ReflPlayerSpriteData_Char_RightRun1:            include "..\sprites\enemies\ReflectionPlayer\RightRun1.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun1:            include "..\sprites\enemies\ReflectionPlayer\RightRun1.tcs.gen"	  | db 0,-1, 0,-1, 0,-1 ; db +0-8,-1
ReflPlayerSpriteData_Char_RightRun2:            include "..\sprites\enemies\ReflectionPlayer\RightRun2.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun2:            include "..\sprites\enemies\ReflectionPlayer\RightRun2.tcs.gen"	  | db 0,-1, 0,-1, 0,-1 ; db +0-8,-1
ReflPlayerSpriteData_Char_RightRun3:            include "..\sprites\enemies\ReflectionPlayer\RightRun3.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun3:            include "..\sprites\enemies\ReflectionPlayer\RightRun3.tcs.gen"	  | db 0,-1, 0,-1, 0,-1 ; db +0-8,-1
ReflPlayerSpriteData_Char_RightRun4:            include "..\sprites\enemies\ReflectionPlayer\RightRun4.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun4:            include "..\sprites\enemies\ReflectionPlayer\RightRun4.tcs.gen"	  | db 0,-2, 0,-2, 0,-2 ; db +0-8,-2
ReflPlayerSpriteData_Char_RightRun5:            include "..\sprites\enemies\ReflectionPlayer\RightRun5.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun5:            include "..\sprites\enemies\ReflectionPlayer\RightRun5.tcs.gen"	  | db 0,-3, 0,-3, 0,-3 ; db +0-8,-3
ReflPlayerSpriteData_Char_RightRun6:            include "..\sprites\enemies\ReflectionPlayer\RightRun6.tgs.gen"	  
ReflPlayerSpriteData_Colo_RightRun6:            include "..\sprites\enemies\ReflectionPlayer\RightRun6.tcs.gen"	  | db 0,-1, 0,-1, 0,-1 ; db +0-8,-1

ReflPlayerSpriteData_Char_LeftRun2:             include "..\sprites\enemies\ReflectionPlayer\LeftRun2.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun2:             include "..\sprites\enemies\ReflectionPlayer\LeftRun2.tcs.gen"	  | db 0,+1, 0,+1, 0,+1 ; db +0-8,+1
ReflPlayerSpriteData_Char_LeftRun3:             include "..\sprites\enemies\ReflectionPlayer\LeftRun3.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun3:             include "..\sprites\enemies\ReflectionPlayer\LeftRun3.tcs.gen"	  | db 0,+1, 0,+1, 0,+1 ; db +0-8,+1
ReflPlayerSpriteData_Char_LeftRun4:             include "..\sprites\enemies\ReflectionPlayer\LeftRun4.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun4:             include "..\sprites\enemies\ReflectionPlayer\LeftRun4.tcs.gen"	  | db 0,+2, 0,+2, 0,+2 ; db +0-8,+2
ReflPlayerSpriteData_Char_LeftRun5:             include "..\sprites\enemies\ReflectionPlayer\LeftRun5.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun5:             include "..\sprites\enemies\ReflectionPlayer\LeftRun5.tcs.gen"	  | db 0,+3, 0,+3, 0,+3 ; db +0-8,+3
ReflPlayerSpriteData_Char_LeftRun6:             include "..\sprites\enemies\ReflectionPlayer\LeftRun6.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun6:             include "..\sprites\enemies\ReflectionPlayer\LeftRun6.tcs.gen"	  | db 0,+1, 0,+1, 0,+1 ; db +0-8,+1
ReflPlayerSpriteData_Char_LeftRun7:             include "..\sprites\enemies\ReflectionPlayer\LeftRun7.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun7:             include "..\sprites\enemies\ReflectionPlayer\LeftRun7.tcs.gen"	  | db 0,+1, 0,+1, 0,+1 ; db +0-8,+1
ReflPlayerSpriteData_Char_LeftRun8:             include "..\sprites\enemies\ReflectionPlayer\LeftRun8.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun8:             include "..\sprites\enemies\ReflectionPlayer\LeftRun8.tcs.gen"	  | db 0,+2, 0,+2, 0,+2 ; db +0-8,+2
ReflPlayerSpriteData_Char_LeftRun9:             include "..\sprites\enemies\ReflectionPlayer\LeftRun9.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun9:             include "..\sprites\enemies\ReflectionPlayer\LeftRun9.tcs.gen"	  | db 0,+2, 0,+2, 0,+2 ; db +0-8,+2
ReflPlayerSpriteData_Char_LeftRun10:            include "..\sprites\enemies\ReflectionPlayer\LeftRun10.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun10:            include "..\sprites\enemies\ReflectionPlayer\LeftRun10.tcs.gen"	  | db 0,+2, 0,+2, 0,+2 ; db +0-8,+2
ReflPlayerSpriteData_Char_LeftRun1:             include "..\sprites\enemies\ReflectionPlayer\LeftRun1.tgs.gen"	  
ReflPlayerSpriteData_Colo_LeftRun1:             include "..\sprites\enemies\ReflectionPlayer\LeftRun1.tcs.gen"	  | db 0,+1, 0,+1, 0,+1 ; db +0-8,+1
	ds		$c000-$,$ff
dephase

;
; block $4d
;
PlayerMovementRoutinesBlock:  equ   $4d
phase	$4000
  include "PlayerMovementRoutines.asm"  
endPlayerMovementRoutines:  
	ds		$8000-$,$ff
dephase


;
; block $4e
;
phase	$8000
MapsBlockBC04:  equ   $4e | MapBC04: incbin "..\maps\BC04.map.pck"  | include "..\maps\mapdata\BC04.asm"  
MapsBlockBC05:  equ   $4e | MapBC05: incbin "..\maps\BC05.map.pck"  | include "..\maps\mapdata\BC05.asm"  
MapsBlockBC06:  equ   $4e | MapBC06: incbin "..\maps\BC06.map.pck"  | include "..\maps\mapdata\BC06.asm"  
MapsBlockBC21:  equ   $4e | MapBC21: incbin "..\maps\BC21.map.pck"  | include "..\maps\mapdata\BC21.asm"  
MapsBlockBC26:  equ   $4e | MapBC26: incbin "..\maps\BC26.map.pck"  | include "..\maps\mapdata\BC26.asm"  
MapsBlockBC27:  equ   $4e | MapBC27: incbin "..\maps\BC27.map.pck"  | include "..\maps\mapdata\BC27.asm"  
MapsBlockBC33:  equ   $4e | MapBC33: incbin "..\maps\BC33.map.pck"  | include "..\maps\mapdata\BC33.asm"  
MapsBlockBC37:  equ   $4e | MapBC37: incbin "..\maps\BC37.map.pck"  | include "..\maps\mapdata\BC37.asm"  
MapsBlockBC41:  equ   $4e | MapBC41: incbin "..\maps\BC41.map.pck"  | include "..\maps\mapdata\BC41.asm"  
MapsBlockBC42:  equ   $4e | MapBC42: incbin "..\maps\BC42.map.pck"  | include "..\maps\mapdata\BC42.asm"  
MapsBlockBC43:  equ   $4e | MapBC43: incbin "..\maps\BC43.map.pck"  | include "..\maps\mapdata\BC43.asm"  
MapsBlockBC44:  equ   $4e | MapBC44: incbin "..\maps\BC44.map.pck"  | include "..\maps\mapdata\BC44.asm"  
MapsBlockBC45:  equ   $4e | MapBC45: incbin "..\maps\BC45.map.pck"  | include "..\maps\mapdata\BC45.asm"  
MapsBlockBC46:  equ   $4e | MapBC46: incbin "..\maps\BC46.map.pck"  | include "..\maps\mapdata\BC46.asm"  
MapsBlockBC47:  equ   $4e | MapBC47: incbin "..\maps\BC47.map.pck"  | include "..\maps\mapdata\BC47.asm"  
MapsBlockBC48:  equ   $4e | MapBC48: incbin "..\maps\BC48.map.pck"  | include "..\maps\mapdata\BC48.asm"  
MapsBlockBC49:  equ   $4e | MapBC49: incbin "..\maps\BC49.map.pck"  | include "..\maps\mapdata\BC49.asm"  
MapsBlockBC50:  equ   $4e | MapBC50: incbin "..\maps\BC50.map.pck"  | include "..\maps\mapdata\BC50.asm"  
	ds		$c000-$,$ff
dephase



;
; block $4f
;
phase	$8000
MapsBlockBD02:  equ   $4f | MapBD02: incbin "..\maps\BD02.map.pck"  | include "..\maps\mapdata\BD02.asm"  
MapsBlockBD04:  equ   $4f | MapBD04: incbin "..\maps\BD04.map.pck"  | include "..\maps\mapdata\BD04.asm"  
MapsBlockBD16:  equ   $4f | MapBD16: incbin "..\maps\BD16.map.pck"  | include "..\maps\mapdata\BD16.asm"  
MapsBlockBD17:  equ   $4f | MapBD17: incbin "..\maps\BD17.map.pck"  | include "..\maps\mapdata\BD17.asm"  
MapsBlockBD21:  equ   $4f | MapBD21: incbin "..\maps\BD21.map.pck"  | include "..\maps\mapdata\BD21.asm"  
MapsBlockBD25:  equ   $4f | MapBD25: incbin "..\maps\BD25.map.pck"  | include "..\maps\mapdata\BD25.asm"  
MapsBlockBD26:  equ   $4f | MapBD26: incbin "..\maps\BD26.map.pck"  | include "..\maps\mapdata\BD26.asm"  
MapsBlockBD33:  equ   $4f | MapBD33: incbin "..\maps\BD33.map.pck"  | include "..\maps\mapdata\BD33.asm"  
MapsBlockBD37:  equ   $4f | MapBD37: incbin "..\maps\BD37.map.pck"  | include "..\maps\mapdata\BD37.asm"  
MapsBlockBD41:  equ   $4f | MapBD41: incbin "..\maps\BD41.map.pck"  | include "..\maps\mapdata\BD41.asm"  
MapsBlockBD45:  equ   $4f | MapBD45: incbin "..\maps\BD45.map.pck"  | include "..\maps\mapdata\BD45.asm"  
MapsBlockBD49:  equ   $4f | MapBD49: incbin "..\maps\BD49.map.pck"  | include "..\maps\mapdata\BD49.asm"  
	ds		$c000-$,$ff
dephase


;
; block $50
;
phase	$8000
MapsBlockBE02:  equ   $50 | MapBE02: incbin "..\maps\BE02.map.pck"  | include "..\maps\mapdata\BE02.asm"  
MapsBlockBE04:  equ   $50 | MapBE04: incbin "..\maps\BE04.map.pck"  | include "..\maps\mapdata\BE04.asm"  
MapsBlockBE06:  equ   $50 | MapBE06: incbin "..\maps\BE06.map.pck"  | include "..\maps\mapdata\BE06.asm"  
MapsBlockBE07:  equ   $50 | MapBE07: incbin "..\maps\BE07.map.pck"  | include "..\maps\mapdata\BE07.asm"  
MapsBlockBE08:  equ   $50 | MapBE08: incbin "..\maps\BE08.map.pck"  | include "..\maps\mapdata\BE08.asm"  
MapsBlockBE09:  equ   $50 | MapBE09: incbin "..\maps\BE09.map.pck"  | include "..\maps\mapdata\BE09.asm"  
MapsBlockBE17:  equ   $50 | MapBE17: incbin "..\maps\BE17.map.pck"  | include "..\maps\mapdata\BE17.asm"  
MapsBlockBE18:  equ   $50 | MapBE18: incbin "..\maps\BE18.map.pck"  | include "..\maps\mapdata\BE18.asm"  
MapsBlockBE21:  equ   $50 | MapBE21: incbin "..\maps\BE21.map.pck"  | include "..\maps\mapdata\BE21.asm"  
MapsBlockBE26:  equ   $50 | MapBE26: incbin "..\maps\BE26.map.pck"  | include "..\maps\mapdata\BE26.asm"  
MapsBlockBE27:  equ   $50 | MapBE27: incbin "..\maps\BE27.map.pck"  | include "..\maps\mapdata\BE27.asm"  
MapsBlockBE28:  equ   $50 | MapBE28: incbin "..\maps\BE28.map.pck"  | include "..\maps\mapdata\BE28.asm"  
MapsBlockBE37:  equ   $50 | MapBE37: incbin "..\maps\BE37.map.pck"  | include "..\maps\mapdata\BE37.asm"  
MapsBlockBE38:  equ   $50 | MapBE38: incbin "..\maps\BE38.map.pck"  | include "..\maps\mapdata\BE38.asm"  
MapsBlockBE45:  equ   $50 | MapBE45: incbin "..\maps\BE45.map.pck"  | include "..\maps\mapdata\BE45.asm"  
MapsBlockBE47:  equ   $50 | MapBE47: incbin "..\maps\BE47.map.pck"  | include "..\maps\mapdata\BE47.asm"  
MapsBlockBE49:  equ   $50 | MapBE49: incbin "..\maps\BE49.map.pck"  | include "..\maps\mapdata\BE49.asm"  
	ds		$c000-$,$ff
dephase


;
; block $51
;
phase	$8000
MapsBlockBF02:  equ   $51 | MapBF02: incbin "..\maps\BF02.map.pck"  | include "..\maps\mapdata\BF02.asm"  
MapsBlockBF04:  equ   $51 | MapBF04: incbin "..\maps\BF04.map.pck"  | include "..\maps\mapdata\BF04.asm"  
MapsBlockBF05:  equ   $51 | MapBF05: incbin "..\maps\BF05.map.pck"  | include "..\maps\mapdata\BF05.asm"  
MapsBlockBF06:  equ   $51 | MapBF06: incbin "..\maps\BF06.map.pck"  | include "..\maps\mapdata\BF06.asm"  
MapsBlockBF09:  equ   $51 | MapBF09: incbin "..\maps\BF09.map.pck"  | include "..\maps\mapdata\BF09.asm"  
MapsBlockBF10:  equ   $51 | MapBF10: incbin "..\maps\BF10.map.pck"  | include "..\maps\mapdata\BF10.asm"  
MapsBlockBF11:  equ   $51 | MapBF11: incbin "..\maps\BF11.map.pck"  | include "..\maps\mapdata\BF11.asm"  
MapsBlockBF12:  equ   $51 | MapBF12: incbin "..\maps\BF12.map.pck"  | include "..\maps\mapdata\BF12.asm"  
MapsBlockBF13:  equ   $51 | MapBF13: incbin "..\maps\BF13.map.pck"  | include "..\maps\mapdata\BF13.asm"  
MapsBlockBF18:  equ   $51 | MapBF18: incbin "..\maps\BF18.map.pck"  | include "..\maps\mapdata\BF18.asm"  
MapsBlockBF20:  equ   $51 | MapBF20: incbin "..\maps\BF20.map.pck"  | include "..\maps\mapdata\BF20.asm"  
MapsBlockBF21:  equ   $51 | MapBF21: incbin "..\maps\BF21.map.pck"  | include "..\maps\mapdata\BF21.asm"  
MapsBlockBF25:  equ   $51 | MapBF25: incbin "..\maps\BF25.map.pck"  | include "..\maps\mapdata\BF25.asm"  
MapsBlockBF26:  equ   $51 | MapBF26: incbin "..\maps\BF26.map.pck"  | include "..\maps\mapdata\BF26.asm"  
MapsBlockBF34:  equ   $51 | MapBF34: incbin "..\maps\BF34.map.pck"  | include "..\maps\mapdata\BF34.asm"  
MapsBlockBF35:  equ   $51 | MapBF35: incbin "..\maps\BF35.map.pck"  | include "..\maps\mapdata\BF35.asm"  
MapsBlockBF36:  equ   $51 | MapBF36: incbin "..\maps\BF36.map.pck"  | include "..\maps\mapdata\BF36.asm"  
MapsBlockBF37:  equ   $51 | MapBF37: incbin "..\maps\BF37.map.pck"  | include "..\maps\mapdata\BF37.asm"  
MapsBlockBF38:  equ   $51 | MapBF38: incbin "..\maps\BF38.map.pck"  | include "..\maps\mapdata\BF38.asm"  
MapsBlockBF39:  equ   $51 | MapBF39: incbin "..\maps\BF39.map.pck"  | include "..\maps\mapdata\BF39.asm"  
MapsBlockBF40:  equ   $51 | MapBF40: incbin "..\maps\BF40.map.pck"  | include "..\maps\mapdata\BF40.asm"  
MapsBlockBF41:  equ   $51 | MapBF41: incbin "..\maps\BF41.map.pck"  | include "..\maps\mapdata\BF41.asm"  
MapsBlockBF42:  equ   $51 | MapBF42: incbin "..\maps\BF42.map.pck"  | include "..\maps\mapdata\BF42.asm"  
MapsBlockBF45:  equ   $51 | MapBF45: incbin "..\maps\BF45.map.pck"  | include "..\maps\mapdata\BF45.asm"  
MapsBlockBF47:  equ   $51 | MapBF47: incbin "..\maps\BF47.map.pck"  | include "..\maps\mapdata\BF47.asm"  
MapsBlockBF48:  equ   $51 | MapBF48: incbin "..\maps\BF48.map.pck"  | include "..\maps\mapdata\BF48.asm"  
MapsBlockBF49:  equ   $51 | MapBF49: incbin "..\maps\BF49.map.pck"  | include "..\maps\mapdata\BF49.asm"  
	ds		$c000-$,$ff
dephase


;
; block $52
;
phase	$8000
MapsBlockBG02:  equ   $52 | MapBG02: incbin "..\maps\BG02.map.pck"  | include "..\maps\mapdata\BG02.asm"  
MapsBlockBG06:  equ   $52 | MapBG06: incbin "..\maps\BG06.map.pck"  | include "..\maps\mapdata\BG06.asm"  
MapsBlockBG07:  equ   $52 | MapBG07: incbin "..\maps\BG07.map.pck"  | include "..\maps\mapdata\BG07.asm"  
MapsBlockBG13:  equ   $52 | MapBG13: incbin "..\maps\BG13.map.pck"  | include "..\maps\mapdata\BG13.asm"  
MapsBlockBG18:  equ   $52 | MapBG18: incbin "..\maps\BG18.map.pck"  | include "..\maps\mapdata\BG18.asm"  
MapsBlockBG19:  equ   $52 | MapBG19: incbin "..\maps\BG19.map.pck"  | include "..\maps\mapdata\BG19.asm"  
MapsBlockBG20:  equ   $52 | MapBG20: incbin "..\maps\BG20.map.pck"  | include "..\maps\mapdata\BG20.asm"  
MapsBlockBG21:  equ   $52 | MapBG21: incbin "..\maps\BG21.map.pck"  | include "..\maps\mapdata\BG21.asm"  
MapsBlockBG25:  equ   $52 | MapBG25: incbin "..\maps\BG25.map.pck"  | include "..\maps\mapdata\BG25.asm"  
MapsBlockBG26:  equ   $52 | MapBG26: incbin "..\maps\BG26.map.pck"  | include "..\maps\mapdata\BG26.asm"  
MapsBlockBG27:  equ   $52 | MapBG27: incbin "..\maps\BG27.map.pck"  | include "..\maps\mapdata\BG27.asm"  
MapsBlockBG28:  equ   $52 | MapBG28: incbin "..\maps\BG28.map.pck"  | include "..\maps\mapdata\BG28.asm"  
MapsBlockBG29:  equ   $52 | MapBG29: incbin "..\maps\BG29.map.pck"  | include "..\maps\mapdata\BG29.asm"  
MapsBlockBG36:  equ   $52 | MapBG36: incbin "..\maps\BG36.map.pck"  | include "..\maps\mapdata\BG36.asm"  
MapsBlockBG37:  equ   $52 | MapBG37: incbin "..\maps\BG37.map.pck"  | include "..\maps\mapdata\BG37.asm"  
MapsBlockBG38:  equ   $52 | MapBG38: incbin "..\maps\BG38.map.pck"  | include "..\maps\mapdata\BG38.asm"  
MapsBlockBG42:  equ   $52 | MapBG42: incbin "..\maps\BG42.map.pck"  | include "..\maps\mapdata\BG42.asm"  
MapsBlockBG45:  equ   $52 | MapBG45: incbin "..\maps\BG45.map.pck"  | include "..\maps\mapdata\BG45.asm"  
	ds		$c000-$,$ff
dephase


;
; block $53
;
phase	$8000
MapsBlockBH02:  equ   $53 | MapBH02: incbin "..\maps\BH02.map.pck"  | include "..\maps\mapdata\BH02.asm"  
MapsBlockBH07:  equ   $53 | MapBH07: incbin "..\maps\BH07.map.pck"  | include "..\maps\mapdata\BH07.asm"  
MapsBlockBH08:  equ   $53 | MapBH08: incbin "..\maps\BH08.map.pck"  | include "..\maps\mapdata\BH08.asm"  
MapsBlockBH13:  equ   $53 | MapBH13: incbin "..\maps\BH13.map.pck"  | include "..\maps\mapdata\BH13.asm"  
MapsBlockBH14:  equ   $53 | MapBH14: incbin "..\maps\BH14.map.pck"  | include "..\maps\mapdata\BH14.asm"  
MapsBlockBH17:  equ   $53 | MapBH17: incbin "..\maps\BH17.map.pck"  | include "..\maps\mapdata\BH17.asm"  
MapsBlockBH18:  equ   $53 | MapBH18: incbin "..\maps\BH18.map.pck"  | include "..\maps\mapdata\BH18.asm"  
MapsBlockBH21:  equ   $53 | MapBH21: incbin "..\maps\BH21.map.pck"  | include "..\maps\mapdata\BH21.asm"  
MapsBlockBH29:  equ   $53 | MapBH29: incbin "..\maps\BH29.map.pck"  | include "..\maps\mapdata\BH29.asm"  
MapsBlockBH35:  equ   $53 | MapBH35: incbin "..\maps\BH35.map.pck"  | include "..\maps\mapdata\BH35.asm"  
MapsBlockBH36:  equ   $53 | MapBH36: incbin "..\maps\BH36.map.pck"  | include "..\maps\mapdata\BH36.asm"  
MapsBlockBH37:  equ   $53 | MapBH37: incbin "..\maps\BH37.map.pck"  | include "..\maps\mapdata\BH37.asm"  
MapsBlockBH38:  equ   $53 | MapBH38: incbin "..\maps\BH38.map.pck"  | include "..\maps\mapdata\BH38.asm"  
MapsBlockBH41:  equ   $53 | MapBH41: incbin "..\maps\BH41.map.pck"  | include "..\maps\mapdata\BH41.asm"  
MapsBlockBH42:  equ   $53 | MapBH42: incbin "..\maps\BH42.map.pck"  | include "..\maps\mapdata\BH42.asm"  
MapsBlockBH47:  equ   $53 | MapBH47: incbin "..\maps\BH47.map.pck"  | include "..\maps\mapdata\BH47.asm"  
	ds		$c000-$,$ff
dephase


;
; block $54
;
phase	$8000
MapsBlockBI02:  equ   $54 | MapBI02: incbin "..\maps\BI02.map.pck"  | include "..\maps\mapdata\BI02.asm"  
MapsBlockBI03:  equ   $54 | MapBI03: incbin "..\maps\BI03.map.pck"  | include "..\maps\mapdata\BI03.asm"  
MapsBlockBI08:  equ   $54 | MapBI08: incbin "..\maps\BI08.map.pck"  | include "..\maps\mapdata\BI08.asm"  
MapsBlockBI09:  equ   $54 | MapBI09: incbin "..\maps\BI09.map.pck"  | include "..\maps\mapdata\BI09.asm"  
MapsBlockBI14:  equ   $54 | MapBI14: incbin "..\maps\BI14.map.pck"  | include "..\maps\mapdata\BI14.asm"  
MapsBlockBI15:  equ   $54 | MapBI15: incbin "..\maps\BI15.map.pck"  | include "..\maps\mapdata\BI15.asm"  
MapsBlockBI16:  equ   $54 | MapBI16: incbin "..\maps\BI16.map.pck"  | include "..\maps\mapdata\BI16.asm"  
MapsBlockBI17:  equ   $54 | MapBI17: incbin "..\maps\BI17.map.pck"  | include "..\maps\mapdata\BI17.asm"  
MapsBlockBI21:  equ   $54 | MapBI21: incbin "..\maps\BI21.map.pck"  | include "..\maps\mapdata\BI21.asm"  
MapsBlockBI25:  equ   $54 | MapBI25: incbin "..\maps\BI25.map.pck"  | include "..\maps\mapdata\BI25.asm"  
MapsBlockBI26:  equ   $54 | MapBI26: incbin "..\maps\BI26.map.pck"  | include "..\maps\mapdata\BI26.asm"  
MapsBlockBI27:  equ   $54 | MapBI27: incbin "..\maps\BI27.map.pck"  | include "..\maps\mapdata\BI27.asm"  
MapsBlockBI28:  equ   $54 | MapBI28: incbin "..\maps\BI28.map.pck"  | include "..\maps\mapdata\BI28.asm"  
MapsBlockBI29:  equ   $54 | MapBI29: incbin "..\maps\BI29.map.pck"  | include "..\maps\mapdata\BI29.asm"  
MapsBlockBI32:  equ   $54 | MapBI32: incbin "..\maps\BI32.map.pck"  | include "..\maps\mapdata\BI32.asm"  
MapsBlockBI33:  equ   $54 | MapBI33: incbin "..\maps\BI33.map.pck"  | include "..\maps\mapdata\BI33.asm"  
MapsBlockBI34:  equ   $54 | MapBI34: incbin "..\maps\BI34.map.pck"  | include "..\maps\mapdata\BI34.asm"  
MapsBlockBI35:  equ   $54 | MapBI35: incbin "..\maps\BI35.map.pck"  | include "..\maps\mapdata\BI35.asm"  
MapsBlockBI41:  equ   $54 | MapBI41: incbin "..\maps\BI41.map.pck"  | include "..\maps\mapdata\BI41.asm"  
MapsBlockBI46:  equ   $54 | MapBI46: incbin "..\maps\BI46.map.pck"  | include "..\maps\mapdata\BI46.asm"  
MapsBlockBI47:  equ   $54 | MapBI47: incbin "..\maps\BI47.map.pck"  | include "..\maps\mapdata\BI47.asm"  
	ds		$c000-$,$ff
dephase


;
; block $55
;
phase	$8000
MapsBlockBJ03:  equ   $55 | MapBJ03: incbin "..\maps\BJ03.map.pck"  | include "..\maps\mapdata\BJ03.asm"  
MapsBlockBJ04:  equ   $55 | MapBJ04: incbin "..\maps\BJ04.map.pck"  | include "..\maps\mapdata\BJ04.asm"  
MapsBlockBJ05:  equ   $55 | MapBJ05: incbin "..\maps\BJ05.map.pck"  | include "..\maps\mapdata\BJ05.asm"  
MapsBlockBJ06:  equ   $55 | MapBJ06: incbin "..\maps\BJ06.map.pck"  | include "..\maps\mapdata\BJ06.asm"  
MapsBlockBJ09:  equ   $55 | MapBJ09: incbin "..\maps\BJ09.map.pck"  | include "..\maps\mapdata\BJ09.asm"  
MapsBlockBJ15:  equ   $55 | MapBJ15: incbin "..\maps\BJ15.map.pck"  | include "..\maps\mapdata\BJ15.asm"  
MapsBlockBJ16:  equ   $55 | MapBJ16: incbin "..\maps\BJ16.map.pck"  | include "..\maps\mapdata\BJ16.asm"  
MapsBlockBJ19:  equ   $55 | MapBJ19: incbin "..\maps\BJ19.map.pck"  | include "..\maps\mapdata\BJ19.asm"  
MapsBlockBJ20:  equ   $55 | MapBJ20: incbin "..\maps\BJ20.map.pck"  | include "..\maps\mapdata\BJ20.asm"  
MapsBlockBJ21:  equ   $55 | MapBJ21: incbin "..\maps\BJ21.map.pck"  | include "..\maps\mapdata\BJ21.asm"  
MapsBlockBJ22:  equ   $55 | MapBJ22: incbin "..\maps\BJ22.map.pck"  | include "..\maps\mapdata\BJ22.asm"  
MapsBlockBJ25:  equ   $55 | MapBJ25: incbin "..\maps\BJ25.map.pck"  | include "..\maps\mapdata\BJ25.asm"  
MapsBlockBJ29:  equ   $55 | MapBJ29: incbin "..\maps\BJ29.map.pck"  | include "..\maps\mapdata\BJ29.asm"  
MapsBlockBJ30:  equ   $55 | MapBJ30: incbin "..\maps\BJ30.map.pck"  | include "..\maps\mapdata\BJ30.asm"  
MapsBlockBJ31:  equ   $55 | MapBJ31: incbin "..\maps\BJ31.map.pck"  | include "..\maps\mapdata\BJ31.asm"  
MapsBlockBJ32:  equ   $55 | MapBJ32: incbin "..\maps\BJ32.map.pck"  | include "..\maps\mapdata\BJ32.asm"  
MapsBlockBJ35:  equ   $55 | MapBJ35: incbin "..\maps\BJ35.map.pck"  | include "..\maps\mapdata\BJ35.asm"  
MapsBlockBJ41:  equ   $55 | MapBJ41: incbin "..\maps\BJ41.map.pck"  | include "..\maps\mapdata\BJ41.asm"  
MapsBlockBJ42:  equ   $55 | MapBJ42: incbin "..\maps\BJ42.map.pck"  | include "..\maps\mapdata\BJ42.asm"  
MapsBlockBJ43:  equ   $55 | MapBJ43: incbin "..\maps\BJ43.map.pck"  | include "..\maps\mapdata\BJ43.asm"  
MapsBlockBJ46:  equ   $55 | MapBJ46: incbin "..\maps\BJ46.map.pck"  | include "..\maps\mapdata\BJ46.asm"  
	ds		$c000-$,$ff
dephase

;
; block $56
;
phase	$8000
MapsBlockBK04:  equ   $56 | MapBK04: incbin "..\maps\BK04.map.pck"  | include "..\maps\mapdata\BK04.asm"  
MapsBlockBK05:  equ   $56 | MapBK05: incbin "..\maps\BK05.map.pck"  | include "..\maps\mapdata\BK05.asm"  
MapsBlockBK06:  equ   $56 | MapBK06: incbin "..\maps\BK06.map.pck"  | include "..\maps\mapdata\BK06.asm"  
MapsBlockBK07:  equ   $56 | MapBK07: incbin "..\maps\BK07.map.pck"  | include "..\maps\mapdata\BK07.asm"  
MapsBlockBK08:  equ   $56 | MapBK08: incbin "..\maps\BK08.map.pck"  | include "..\maps\mapdata\BK08.asm"  
MapsBlockBK09:  equ   $56 | MapBK09: incbin "..\maps\BK09.map.pck"  | include "..\maps\mapdata\BK09.asm"  
MapsBlockBK10:  equ   $56 | MapBK10: incbin "..\maps\BK10.map.pck"  | include "..\maps\mapdata\BK10.asm"  
MapsBlockBK11:  equ   $56 | MapBK11: incbin "..\maps\BK11.map.pck"  | include "..\maps\mapdata\BK11.asm"  
MapsBlockBK16:  equ   $56 | MapBK16: incbin "..\maps\BK16.map.pck"  | include "..\maps\mapdata\BK16.asm"  
MapsBlockBK19:  equ   $56 | MapBK19: incbin "..\maps\BK19.map.pck"  | include "..\maps\mapdata\BK19.asm"  
MapsBlockBK25:  equ   $56 | MapBK25: incbin "..\maps\BK25.map.pck"  | include "..\maps\mapdata\BK25.asm"  
MapsBlockBK26:  equ   $56 | MapBK26: incbin "..\maps\BK26.map.pck"  | include "..\maps\mapdata\BK26.asm"  
MapsBlockBK27:  equ   $56 | MapBK27: incbin "..\maps\BK27.map.pck"  | include "..\maps\mapdata\BK27.asm"  
MapsBlockBK28:  equ   $56 | MapBK28: incbin "..\maps\BK28.map.pck"  | include "..\maps\mapdata\BK28.asm"  
MapsBlockBK29:  equ   $56 | MapBK29: incbin "..\maps\BK29.map.pck"  | include "..\maps\mapdata\BK29.asm"  
MapsBlockBK32:  equ   $56 | MapBK32: incbin "..\maps\BK32.map.pck"  | include "..\maps\mapdata\BK32.asm"  
MapsBlockBK43:  equ   $56 | MapBK43: incbin "..\maps\BK43.map.pck"  | include "..\maps\mapdata\BK43.asm"  
MapsBlockBK44:  equ   $56 | MapBK44: incbin "..\maps\BK44.map.pck"  | include "..\maps\mapdata\BK44.asm"  
MapsBlockBK45:  equ   $56 | MapBK45: incbin "..\maps\BK45.map.pck"  | include "..\maps\mapdata\BK45.asm"  
MapsBlockBK46:  equ   $56 | MapBK46: incbin "..\maps\BK46.map.pck"  | include "..\maps\mapdata\BK46.asm"  
	ds		$c000-$,$ff
dephase


;
; block $57
;
phase	$8000
MapsBlockBL09:  equ   $57 | MapBL09: incbin "..\maps\BL09.map.pck"  | include "..\maps\mapdata\BL09.asm"  
MapsBlockBL11:  equ   $57 | MapBL11: incbin "..\maps\BL11.map.pck"  | include "..\maps\mapdata\BL11.asm"  
MapsBlockBL18:  equ   $57 | MapBL18: incbin "..\maps\BL18.map.pck"  | include "..\maps\mapdata\BL18.asm"  
MapsBlockBL19:  equ   $57 | MapBL19: incbin "..\maps\BL19.map.pck"  | include "..\maps\mapdata\BL19.asm"  
MapsBlockBL20:  equ   $57 | MapBL20: incbin "..\maps\BL20.map.pck"  | include "..\maps\mapdata\BL20.asm"  
MapsBlockBL29:  equ   $57 | MapBL29: incbin "..\maps\BL29.map.pck"  | include "..\maps\mapdata\BL29.asm"  
MapsBlockBL40:  equ   $57 | MapBL40: incbin "..\maps\BL40.map.pck"  | include "..\maps\mapdata\BL40.asm"  
MapsBlockBL43:  equ   $57 | MapBL43: incbin "..\maps\BL43.map.pck"  | include "..\maps\mapdata\BL43.asm"  
MapsBlockBL44:  equ   $57 | MapBL44: incbin "..\maps\BL44.map.pck"  | include "..\maps\mapdata\BL44.asm"  
MapsBlockBL45:  equ   $57 | MapBL45: incbin "..\maps\BL45.map.pck"  | include "..\maps\mapdata\BL45.asm"  
MapsBlockBL46:  equ   $57 | MapBL46: incbin "..\maps\BL46.map.pck"  | include "..\maps\mapdata\BL46.asm"  
	ds		$c000-$,$ff
dephase


;
; block $58
;
phase	$8000
MapsBlockBM09:  equ   $58 | MapBM09: incbin "..\maps\BM09.map.pck"  | include "..\maps\mapdata\BM09.asm"  
MapsBlockBM18:  equ   $58 | MapBM18: incbin "..\maps\BM18.map.pck"  | include "..\maps\mapdata\BM18.asm"  
MapsBlockBM19:  equ   $58 | MapBM19: incbin "..\maps\BM19.map.pck"  | include "..\maps\mapdata\BM19.asm"  
MapsBlockBM26:  equ   $58 | MapBM26: incbin "..\maps\BM26.map.pck"  | include "..\maps\mapdata\BM26.asm"  
MapsBlockBM27:  equ   $58 | MapBM27: incbin "..\maps\BM27.map.pck"  | include "..\maps\mapdata\BM27.asm"  
MapsBlockBM28:  equ   $58 | MapBM28: incbin "..\maps\BM28.map.pck"  | include "..\maps\mapdata\BM28.asm"  
MapsBlockBM29:  equ   $58 | MapBM29: incbin "..\maps\BM29.map.pck"  | include "..\maps\mapdata\BM29.asm"  
MapsBlockBM33:  equ   $58 | MapBM33: incbin "..\maps\BM33.map.pck"  | include "..\maps\mapdata\BM33.asm"  
MapsBlockBM34:  equ   $58 | MapBM34: incbin "..\maps\BM34.map.pck"  | include "..\maps\mapdata\BM34.asm"  
MapsBlockBM35:  equ   $58 | MapBM35: incbin "..\maps\BM35.map.pck"  | include "..\maps\mapdata\BM35.asm"  
MapsBlockBM36:  equ   $58 | MapBM36: incbin "..\maps\BM36.map.pck"  | include "..\maps\mapdata\BM36.asm"  
MapsBlockBM38:  equ   $58 | MapBM38: incbin "..\maps\BM38.map.pck"  | include "..\maps\mapdata\BM38.asm"  
MapsBlockBM40:  equ   $58 | MapBM40: incbin "..\maps\BM40.map.pck"  | include "..\maps\mapdata\BM40.asm"  
MapsBlockBM43:  equ   $58 | MapBM43: incbin "..\maps\BM43.map.pck"  | include "..\maps\mapdata\BM43.asm"  
	ds		$c000-$,$ff
dephase


;
; block $59
;
phase	$8000
MapsBlockBN07:  equ   $59 | MapBN07: incbin "..\maps\BN07.map.pck"  | include "..\maps\mapdata\BN07.asm"  
MapsBlockBN09:  equ   $59 | MapBN09: incbin "..\maps\BN09.map.pck"  | include "..\maps\mapdata\BN09.asm"  
MapsBlockBN19:  equ   $59 | MapBN19: incbin "..\maps\BN19.map.pck"  | include "..\maps\mapdata\BN19.asm"  
MapsBlockBN26:  equ   $59 | MapBN26: incbin "..\maps\BN26.map.pck"  | include "..\maps\mapdata\BN26.asm"  
MapsBlockBN31:  equ   $59 | MapBN31: incbin "..\maps\BN31.map.pck"  | include "..\maps\mapdata\BN31.asm"  
MapsBlockBN33:  equ   $59 | MapBN33: incbin "..\maps\BN33.map.pck"  | include "..\maps\mapdata\BN33.asm"  
MapsBlockBN36:  equ   $59 | MapBN36: incbin "..\maps\BN36.map.pck"  | include "..\maps\mapdata\BN36.asm"  
MapsBlockBN38:  equ   $59 | MapBN38: incbin "..\maps\BN38.map.pck"  | include "..\maps\mapdata\BN38.asm"  
MapsBlockBN40:  equ   $59 | MapBN40: incbin "..\maps\BN40.map.pck"  | include "..\maps\mapdata\BN40.asm"  
MapsBlockBN41:  equ   $59 | MapBN41: incbin "..\maps\BN41.map.pck"  | include "..\maps\mapdata\BN41.asm"  
MapsBlockBN42:  equ   $59 | MapBN42: incbin "..\maps\BN42.map.pck"  | include "..\maps\mapdata\BN42.asm"  
MapsBlockBN43:  equ   $59 | MapBN43: incbin "..\maps\BN43.map.pck"  | include "..\maps\mapdata\BN43.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5a
;
phase	$8000
MapsBlockBO04:  equ   $5a | MapBO04: incbin "..\maps\BO04.map.pck"  | include "..\maps\mapdata\BO04.asm"  
MapsBlockBO05:  equ   $5a | MapBO05: incbin "..\maps\BO05.map.pck"  | include "..\maps\mapdata\BO05.asm"  
MapsBlockBO06:  equ   $5a | MapBO06: incbin "..\maps\BO06.map.pck"  | include "..\maps\mapdata\BO06.asm"  
MapsBlockBO07:  equ   $5a | MapBO07: incbin "..\maps\BO07.map.pck"  | include "..\maps\mapdata\BO07.asm"  
MapsBlockBO08:  equ   $5a | MapBO08: incbin "..\maps\BO08.map.pck"  | include "..\maps\mapdata\BO08.asm"  
MapsBlockBO09:  equ   $5a | MapBO09: incbin "..\maps\BO09.map.pck"  | include "..\maps\mapdata\BO09.asm"  
MapsBlockBO19:  equ   $5a | MapBO19: incbin "..\maps\BO19.map.pck"  | include "..\maps\mapdata\BO19.asm"  
MapsBlockBO20:  equ   $5a | MapBO20: incbin "..\maps\BO20.map.pck"  | include "..\maps\mapdata\BO20.asm"  
MapsBlockBO21:  equ   $5a | MapBO21: incbin "..\maps\BO21.map.pck"  | include "..\maps\mapdata\BO21.asm"  
MapsBlockBO26:  equ   $5a | MapBO26: incbin "..\maps\BO26.map.pck"  | include "..\maps\mapdata\BO26.asm"  
MapsBlockBO29:  equ   $5a | MapBO29: incbin "..\maps\BO29.map.pck"  | include "..\maps\mapdata\BO29.asm"  
MapsBlockBO30:  equ   $5a | MapBO30: incbin "..\maps\BO30.map.pck"  | include "..\maps\mapdata\BO30.asm"  
MapsBlockBO31:  equ   $5a | MapBO31: incbin "..\maps\BO31.map.pck"  | include "..\maps\mapdata\BO31.asm"  
MapsBlockBO32:  equ   $5a | MapBO32: incbin "..\maps\BO32.map.pck"  | include "..\maps\mapdata\BO32.asm"  
MapsBlockBO33:  equ   $5a | MapBO33: incbin "..\maps\BO33.map.pck"  | include "..\maps\mapdata\BO33.asm"  
MapsBlockBO36:  equ   $5a | MapBO36: incbin "..\maps\BO36.map.pck"  | include "..\maps\mapdata\BO36.asm"  
MapsBlockBO37:  equ   $5a | MapBO37: incbin "..\maps\BO37.map.pck"  | include "..\maps\mapdata\BO37.asm"  
MapsBlockBO38:  equ   $5a | MapBO38: incbin "..\maps\BO38.map.pck"  | include "..\maps\mapdata\BO38.asm"  
MapsBlockBO39:  equ   $5a | MapBO39: incbin "..\maps\BO39.map.pck"  | include "..\maps\mapdata\BO39.asm"  
MapsBlockBO40:  equ   $5a | MapBO40: incbin "..\maps\BO40.map.pck"  | include "..\maps\mapdata\BO40.asm"  
MapsBlockBO47:  equ   $5a | MapBO47: incbin "..\maps\BO47.map.pck"  | include "..\maps\mapdata\BO47.asm"  
MapsBlockBO48:  equ   $5a | MapBO48: incbin "..\maps\BO48.map.pck"  | include "..\maps\mapdata\BO48.asm"  
MapsBlockBO49:  equ   $5a | MapBO49: incbin "..\maps\BO49.map.pck"  | include "..\maps\mapdata\BO49.asm"  
MapsBlockBO50:  equ   $5a | MapBO50: incbin "..\maps\BO50.map.pck"  | include "..\maps\mapdata\BO50.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5b
;
phase	$8000
MapsBlockBP04:  equ   $5b | MapBP04: incbin "..\maps\BP04.map.pck"  | include "..\maps\mapdata\BP04.asm"  
MapsBlockBP18:  equ   $5b | MapBP18: incbin "..\maps\BP18.map.pck"  | include "..\maps\mapdata\BP18.asm"  
MapsBlockBP19:  equ   $5b | MapBP19: incbin "..\maps\BP19.map.pck"  | include "..\maps\mapdata\BP19.asm"  
MapsBlockBP21:  equ   $5b | MapBP21: incbin "..\maps\BP21.map.pck"  | include "..\maps\mapdata\BP21.asm"  
MapsBlockBP26:  equ   $5b | MapBP26: incbin "..\maps\BP26.map.pck"  | include "..\maps\mapdata\BP26.asm"  
MapsBlockBP27:  equ   $5b | MapBP27: incbin "..\maps\BP27.map.pck"  | include "..\maps\mapdata\BP27.asm"  
MapsBlockBP30:  equ   $5b | MapBP30: incbin "..\maps\BP30.map.pck"  | include "..\maps\mapdata\BP30.asm"  
MapsBlockBP31:  equ   $5b | MapBP31: incbin "..\maps\BP31.map.pck"  | include "..\maps\mapdata\BP31.asm"  
MapsBlockBP32:  equ   $5b | MapBP32: incbin "..\maps\BP32.map.pck"  | include "..\maps\mapdata\BP32.asm"  
MapsBlockBP33:  equ   $5b | MapBP33: incbin "..\maps\BP33.map.pck"  | include "..\maps\mapdata\BP33.asm"  
MapsBlockBP34:  equ   $5b | MapBP34: incbin "..\maps\BP34.map.pck"  | include "..\maps\mapdata\BP34.asm"  
MapsBlockBP37:  equ   $5b | MapBP37: incbin "..\maps\BP37.map.pck"  | include "..\maps\mapdata\BP37.asm"  
MapsBlockBP47:  equ   $5b | MapBP47: incbin "..\maps\BP47.map.pck"  | include "..\maps\mapdata\BP47.asm"  
MapsBlockBP50:  equ   $5b | MapBP50: incbin "..\maps\BP50.map.pck"  | include "..\maps\mapdata\BP50.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5c
;
phase	$8000
MapsBlockBQ03:  equ   $5c | MapBQ03: incbin "..\maps\BQ03.map.pck"  | include "..\maps\mapdata\BQ03.asm"  
MapsBlockBQ04:  equ   $5c | MapBQ04: incbin "..\maps\BQ04.map.pck"  | include "..\maps\mapdata\BQ04.asm"  
MapsBlockBQ05:  equ   $5c | MapBQ05: incbin "..\maps\BQ05.map.pck"  | include "..\maps\mapdata\BQ05.asm"  
MapsBlockBQ06:  equ   $5c | MapBQ06: incbin "..\maps\BQ06.map.pck"  | include "..\maps\mapdata\BQ06.asm"  
MapsBlockBQ07:  equ   $5c | MapBQ07: incbin "..\maps\BQ07.map.pck"  | include "..\maps\mapdata\BQ07.asm"  
MapsBlockBQ08:  equ   $5c | MapBQ08: incbin "..\maps\BQ08.map.pck"  | include "..\maps\mapdata\BQ08.asm"  
MapsBlockBQ18:  equ   $5c | MapBQ18: incbin "..\maps\BQ18.map.pck"  | include "..\maps\mapdata\BQ18.asm"  
MapsBlockBQ21:  equ   $5c | MapBQ21: incbin "..\maps\BQ21.map.pck"  | include "..\maps\mapdata\BQ21.asm"  
MapsBlockBQ27:  equ   $5c | MapBQ27: incbin "..\maps\BQ27.map.pck"  | include "..\maps\mapdata\BQ27.asm"  
MapsBlockBQ30:  equ   $5c | MapBQ30: incbin "..\maps\BQ30.map.pck"  | include "..\maps\mapdata\BQ30.asm"  
MapsBlockBQ31:  equ   $5c | MapBQ31: incbin "..\maps\BQ31.map.pck"  | include "..\maps\mapdata\BQ31.asm"  
MapsBlockBQ32:  equ   $5c | MapBQ32: incbin "..\maps\BQ32.map.pck"  | include "..\maps\mapdata\BQ32.asm"  
MapsBlockBQ33:  equ   $5c | MapBQ33: incbin "..\maps\BQ33.map.pck"  | include "..\maps\mapdata\BQ33.asm"  
MapsBlockBQ37:  equ   $5c | MapBQ37: incbin "..\maps\BQ37.map.pck"  | include "..\maps\mapdata\BQ37.asm"  
MapsBlockBQ47:  equ   $5c | MapBQ47: incbin "..\maps\BQ47.map.pck"  | include "..\maps\mapdata\BQ47.asm"  
MapsBlockBQ50:  equ   $5c | MapBQ50: incbin "..\maps\BQ50.map.pck"  | include "..\maps\mapdata\BQ50.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5d
;
phase	$8000
MapsBlockBR03:  equ   $5d | MapBR03: incbin "..\maps\BR03.map.pck"  | include "..\maps\mapdata\BR03.asm"  
MapsBlockBR06:  equ   $5d | MapBR06: incbin "..\maps\BR06.map.pck"  | include "..\maps\mapdata\BR06.asm"  
MapsBlockBR07:  equ   $5d | MapBR07: incbin "..\maps\BR07.map.pck"  | include "..\maps\mapdata\BR07.asm"  
MapsBlockBR08:  equ   $5d | MapBR08: incbin "..\maps\BR08.map.pck"  | include "..\maps\mapdata\BR08.asm"  
MapsBlockBR16:  equ   $5d | MapBR16: incbin "..\maps\BR16.map.pck"  | include "..\maps\mapdata\BR16.asm"  
MapsBlockBR17:  equ   $5d | MapBR17: incbin "..\maps\BR17.map.pck"  | include "..\maps\mapdata\BR17.asm"  
MapsBlockBR18:  equ   $5d | MapBR18: incbin "..\maps\BR18.map.pck"  | include "..\maps\mapdata\BR18.asm"  
MapsBlockBR19:  equ   $5d | MapBR19: incbin "..\maps\BR19.map.pck"  | include "..\maps\mapdata\BR19.asm"  
MapsBlockBR20:  equ   $5d | MapBR20: incbin "..\maps\BR20.map.pck"  | include "..\maps\mapdata\BR20.asm"  
MapsBlockBR21:  equ   $5d | MapBR21: incbin "..\maps\BR21.map.pck"  | include "..\maps\mapdata\BR21.asm"  
MapsBlockBR24:  equ   $5d | MapBR24: incbin "..\maps\BR24.map.pck"  | include "..\maps\mapdata\BR24.asm"  
MapsBlockBR25:  equ   $5d | MapBR25: incbin "..\maps\BR25.map.pck"  | include "..\maps\mapdata\BR25.asm"  
MapsBlockBR27:  equ   $5d | MapBR27: incbin "..\maps\BR27.map.pck"  | include "..\maps\mapdata\BR27.asm"  
MapsBlockBR28:  equ   $5d | MapBR28: incbin "..\maps\BR28.map.pck"  | include "..\maps\mapdata\BR28.asm"  
MapsBlockBR30:  equ   $5d | MapBR30: incbin "..\maps\BR30.map.pck"  | include "..\maps\mapdata\BR30.asm"  
MapsBlockBR35:  equ   $5d | MapBR35: incbin "..\maps\BR35.map.pck"  | include "..\maps\mapdata\BR35.asm"  
MapsBlockBR36:  equ   $5d | MapBR36: incbin "..\maps\BR36.map.pck"  | include "..\maps\mapdata\BR36.asm"  
MapsBlockBR37:  equ   $5d | MapBR37: incbin "..\maps\BR37.map.pck"  | include "..\maps\mapdata\BR37.asm"  
MapsBlockBR38:  equ   $5d | MapBR38: incbin "..\maps\BR38.map.pck"  | include "..\maps\mapdata\BR38.asm"  
MapsBlockBR45:  equ   $5d | MapBR45: incbin "..\maps\BR45.map.pck"  | include "..\maps\mapdata\BR45.asm"  
MapsBlockBR46:  equ   $5d | MapBR46: incbin "..\maps\BR46.map.pck"  | include "..\maps\mapdata\BR46.asm"  
MapsBlockBR47:  equ   $5d | MapBR47: incbin "..\maps\BR47.map.pck"  | include "..\maps\mapdata\BR47.asm"  
MapsBlockBR48:  equ   $5d | MapBR48: incbin "..\maps\BR48.map.pck"  | include "..\maps\mapdata\BR48.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5e
;
phase	$8000
MapsBlockBS01:  equ   $5e | MapBS01: incbin "..\maps\BS01.map.pck"  | include "..\maps\mapdata\BS01.asm"  
MapsBlockBS03:  equ   $5e | MapBS03: incbin "..\maps\BS03.map.pck"  | include "..\maps\mapdata\BS03.asm"  
MapsBlockBS04:  equ   $5e | MapBS04: incbin "..\maps\BS04.map.pck"  | include "..\maps\mapdata\BS04.asm"  
MapsBlockBS06:  equ   $5e | MapBS06: incbin "..\maps\BS06.map.pck"  | include "..\maps\mapdata\BS06.asm"  
MapsBlockBS07:  equ   $5e | MapBS07: incbin "..\maps\BS07.map.pck"  | include "..\maps\mapdata\BS07.asm"  
MapsBlockBS08:  equ   $5e | MapBS08: incbin "..\maps\BS08.map.pck"  | include "..\maps\mapdata\BS08.asm"  
MapsBlockBS16:  equ   $5e | MapBS16: incbin "..\maps\BS16.map.pck"  | include "..\maps\mapdata\BS16.asm"  
MapsBlockBS20:  equ   $5e | MapBS20: incbin "..\maps\BS20.map.pck"  | include "..\maps\mapdata\BS20.asm"  
MapsBlockBS24:  equ   $5e | MapBS24: incbin "..\maps\BS24.map.pck"  | include "..\maps\mapdata\BS24.asm"  
MapsBlockBS28:  equ   $5e | MapBS28: incbin "..\maps\BS28.map.pck"  | include "..\maps\mapdata\BS28.asm"  
MapsBlockBS30:  equ   $5e | MapBS30: incbin "..\maps\BS30.map.pck"  | include "..\maps\mapdata\BS30.asm"  
MapsBlockBS34:  equ   $5e | MapBS34: incbin "..\maps\BS34.map.pck"  | include "..\maps\mapdata\BS34.asm"  
MapsBlockBS35:  equ   $5e | MapBS35: incbin "..\maps\BS35.map.pck"  | include "..\maps\mapdata\BS35.asm"  
MapsBlockBS38:  equ   $5e | MapBS38: incbin "..\maps\BS38.map.pck"  | include "..\maps\mapdata\BS38.asm"  
MapsBlockBS39:  equ   $5e | MapBS39: incbin "..\maps\BS39.map.pck"  | include "..\maps\mapdata\BS39.asm"  
MapsBlockBS40:  equ   $5e | MapBS40: incbin "..\maps\BS40.map.pck"  | include "..\maps\mapdata\BS40.asm"  
MapsBlockBS41:  equ   $5e | MapBS41: incbin "..\maps\BS41.map.pck"  | include "..\maps\mapdata\BS41.asm"  
MapsBlockBS44:  equ   $5e | MapBS44: incbin "..\maps\BS44.map.pck"  | include "..\maps\mapdata\BS44.asm"  
MapsBlockBS45:  equ   $5e | MapBS45: incbin "..\maps\BS45.map.pck"  | include "..\maps\mapdata\BS45.asm"  
MapsBlockBS47:  equ   $5e | MapBS47: incbin "..\maps\BS47.map.pck"  | include "..\maps\mapdata\BS47.asm"  
MapsBlockBS48:  equ   $5e | MapBS48: incbin "..\maps\BS48.map.pck"  | include "..\maps\mapdata\BS48.asm"  
MapsBlockBS49:  equ   $5e | MapBS49: incbin "..\maps\BS49.map.pck"  | include "..\maps\mapdata\BS49.asm"  
MapsBlockBS50:  equ   $5e | MapBS50: incbin "..\maps\BS50.map.pck"  | include "..\maps\mapdata\BS50.asm"  
	ds		$c000-$,$ff
dephase


;
; block $5f
;
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





;##################### MAPS #####################
;##################### MAPS #####################
;##################### MAPS #####################
;##################### MAPS #####################
;##################### MAPS #####################

;
; block $60
;
MapsBlock0A:  equ   $60
phase	$8000
MapA01:
  incbin "..\maps\a01.map.pck"  | .amountofobjects: db  0
MapA02:
  incbin "..\maps\a02.map.pck"  | .amountofobjects: db  0
MapA03:
  incbin "..\maps\a03.map.pck"  | .amountofobjects: db  0
MapA04:
  incbin "..\maps\a04.map.pck"  | .amountofobjects: db  7
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,        0|dw AreaSign             |db 8*05|dw 8*17|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+00,+00,190, 0|db 016,movepatblo1| ds fill-1


;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
;.object2:db -1,        1|dw BoringEye           |db 8*09|dw 8*18|db 22,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object3:db -1,        1|dw BoringEye           |db 8*11|dw 8*20|db 22,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object4:db -1,        1|dw BoringEye           |db 8*13|dw 8*22|db 22,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;.object5:db -1,        1|dw BoringEye           |db 8*15|dw 8*24|db 22,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

;Coin v8=coin type (0=I, 1=V, 2=X)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Coin                |db 8*00|dw 8*11|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+03,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -1,        1|dw Coin                |db 8*04|dw 8*13|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+04,+00,+00,+00,+00,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -1,        1|dw Coin                |db 8*08|dw 8*15|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+03,+00,+00,+00,+00,+02,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -1,        1|dw Coin                |db 8*12|dw 8*17|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+04,+00,+00,+00,+00,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object6:db -1,        1|dw Coin                |db 8*16|dw 8*19|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+03,+00,+00,+00,+00,+02,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -1,        1|dw Coin                |db 8*20|dw 8*21|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+04,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1


  
MapA05:
  incbin "..\maps\a05.map.pck"  | .amountofobjects: db  2

;AppearingBlocks Handler
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw AppBlocksHandler    |db 0*00|dw 0*00|db 00,00|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;AppearingBlocks
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object2: db 0,        0|dw AppearingBlocks     |db 8*21|dw 8*19|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;.object1: db 1,        0|dw DisappearingBlocks  |db 8*21|dw 8*19|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,21*8,19*8,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
  
MapA06:
  incbin "..\maps\a06.map.pck"  | .amountofobjects: db  1
;Black Hole Alien
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw BlackHoleAlien      |db 8*21|dw 8*04|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1
  
  
MapA07:
  incbin "..\maps\a07.map.pck"  | .amountofobjects: db  6  
;Retarded Zombie Spawnpoint
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc,
.object1:db +1,        1|dw ZombieSpawnPoint    |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+01,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Retarded Zombie
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 16*16,spat+(16*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 20*16,spat+(20*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 24*16,spat+(24*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object6: db 1,        0|dw PlatformHorizontally|db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+01,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
  
  
  
  
  
  
  
  
  
  
  
MapA08:
  incbin "..\maps\a08.map.pck"  | .amountofobjects: db  0
MapA09:
  incbin "..\maps\a09.map.pck"  | .amountofobjects: db  0
MapA10:
  incbin "..\maps\a10.map.pck"  | .amountofobjects: db  0
MapA11:
  incbin "..\maps\a11.map.pck"  | .amountofobjects: db  0
MapA12:
  incbin "..\maps\a12.map.pck"  | .amountofobjects: db  2
;platform Omni Directionally
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,   0|dw PlatformOmniDirectionally|db 8*11|dw 8*10|db 16,16|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object2: db 1,   0|dw PlatformOmniDirectionally|db 8*19|dw 8*25|db 16,16|dw CleanOb2,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

MapA13:
  incbin "..\maps\a13.map.pck"  | .amountofobjects: db  3
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,        0|dw BossDemon1          |db 8*08|dw 8*26|db 80,60|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,-01, 0|db 010,movepatblo1| ds fill-1
.object2: db 2,        0|dw BossDemon2          |db 8*00|dw 8*00|db 00,00|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
.object3: db 2,        0|dw BossDemon3          |db 8*00|dw 8*00|db 00,00|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+02,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
;.object4:db -1,        1|dw BoringEye           |db 8*09|dw 8*18|db 22,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1







 
	ds		$c000-$,$ff
dephase

;
; block $61
;
MapsBlock0B:  equ   $61
phase	$8000
MapB01:
  incbin "..\maps\b01.map.pck"  | .amountofobjects: db  0
MapB02:
  incbin "..\maps\b02.map.pck"  | .amountofobjects: db  0
MapB03:
  incbin "..\maps\b03.map.pck"  | .amountofobjects: db  0
MapB04:
  incbin "..\maps\b04.map.pck"  | .amountofobjects: db  0
MapB05:
  incbin "..\maps\b05.map.pck"  | .amountofobjects: db  0
MapB06:
  incbin "..\maps\b06.map.pck"  | .amountofobjects: db  5
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw GreenSpider         |db 8*23|dw 8*12|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1

;Boring Eye Green;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw BoringEye           |db 8*18|dw 8*09|db 22,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
;Boring Eye Red;v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object4:db -1,        1|dw BoringEye           |db 8*18|dw 8*31|db 22,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -1,        1|dw BoringEye           |db 8*04|dw 8*22|db 22,16|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+01,+00,+00, 0|db 001,movepatblo1| ds fill-1

  
  
  
MapB07:
  incbin "..\maps\b07.map.pck"  | .amountofobjects: db  3  
;platform (moving horizontally)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw PlatformHorizontally|db 8*15|dw 8*18|db 16,32|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+01,+00,+16,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Treeman
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw Treeman             |db 8*11|dw 8*30|db 32,26|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1
;Grinder
.object3:db -1,        1|dw Grinder             |db 8*19|dw 8*16|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1  
  
  
MapB08:
  incbin "..\maps\b08.map.pck"  | .amountofobjects: db  0
MapB09:
  incbin "..\maps\b09.map.pck"  | .amountofobjects: db  0
MapB10:
  incbin "..\maps\b10.map.pck"  | .amountofobjects: db  0
MapB11:
  incbin "..\maps\b11.map.pck"  | .amountofobjects: db  1
;platform Omni Directionally
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,   0|dw PlatformOmniDirectionally|db 8*12|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
  
  
  
MapB12:
  incbin "..\maps\b12.map.pck"  | .amountofobjects: db  0
MapB13:
  incbin "..\maps\b13.map.pck"  | .amountofobjects: db  0
	ds		$c000-$,$ff
dephase

;
; block $62
;
MapsBlock0C:  equ   $62
phase	$8000
MapC01:
  incbin "..\maps\c01.map.pck"  | .amountofobjects: db  0
MapC02:
  incbin "..\maps\c02.map.pck"  | .amountofobjects: db  0
MapC03:
  incbin "..\maps\c03.map.pck"  | .amountofobjects: db  0
MapC04:
  incbin "..\maps\c04.map.pck"  | .amountofobjects: db  0
MapC05:
  incbin "..\maps\c05.map.pck"  | .amountofobjects: db  0
MapC06:
  incbin "..\maps\c06.map.pck"  | .amountofobjects: db  0
MapC07:
  incbin "..\maps\c07.map.pck"  | .amountofobjects: db  0
MapC08:
  incbin "..\maps\c08.map.pck"  | .amountofobjects: db  0
MapC09:
  incbin "..\maps\c09.map.pck"  | .amountofobjects: db  0
MapC10:
  incbin "..\maps\c10.map.pck"  | .amountofobjects: db  0
MapC11:
  incbin "..\maps\c11.map.pck"  | .amountofobjects: db  0
MapC12:
  incbin "..\maps\c12.map.pck"  | .amountofobjects: db  0
MapC13:
  incbin "..\maps\c13.map.pck"  | .amountofobjects: db  0
	ds		$c000-$,$ff
dephase

;
; block $63
;
MapsBlock0D:  equ   $63
phase	$8000
MapD01:
  incbin "..\maps\d01.map.pck"  | .amountofobjects: db  0
MapD02:
  incbin "..\maps\d02.map.pck"  | .amountofobjects: db  0
MapD03:
  incbin "..\maps\d03.map.pck"  | .amountofobjects: db  0



       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc,
;.object1:db +1,        1|dw ZombieSpawnPoint    |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+01,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000,movepatblo1,movepatblo1| ds fill-1-1




MapD04:
  incbin "..\maps\d04.map.pck"  | .amountofobjects: db  3
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw BossVoodooWasp      |db -066|dw 8*22|db 50,52|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+81,+05,+00, 0|db 020,movepatblo1| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2: db 2,        0|dw Altar1              |db 8*02|dw 8*16|db 20,20|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+10, 0|db 000,movepatblo1| ds fill-1
.object3: db 2,        0|dw Altar2              |db 8*14|dw 8*16|db 00,00|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1




  
MapD05:
  incbin "..\maps\d05.map.pck"  | .amountofobjects: db  0
MapD06:
  incbin "..\maps\d06.map.pck"  | .amountofobjects: db  0
MapD07:
  incbin "..\maps\d07.map.pck"  | .amountofobjects: db  0
MapD08:
  incbin "..\maps\d08.map.pck"  | .amountofobjects: db  2

;Huge Spider Body
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.object1: db 1,        0|dw HugeSpiderBody      |db 8*06|dw 8*14|db 21,27|dw CleanOb1,0 db 0,0,0,                     +073,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1

;Huge Spider Legs
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -1,        1|dw HugeSpiderLegs      |db 8*04|dw 8*14|db 24,64|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1  

  

MapD09:
  incbin "..\maps\d09.map.pck"  | .amountofobjects: db  0  
MapD10:
  incbin "..\maps\d10.map.pck"  | .amountofobjects: db  0  
MapD11:
  incbin "..\maps\d11.map.pck"  | .amountofobjects: db  0  
MapD12:
  incbin "..\maps\d12.map.pck"  | .amountofobjects: db  0  
MapD13:
  incbin "..\maps\d13.map.pck"  | .amountofobjects: db  0  
	ds		$c000-$,$ff
dephase

;
; block $64
;
MapsBlock0E:  equ   $64
phase	$8000
MapE01:
  incbin "..\maps\e01.map.pck"  | .amountofobjects: db  0
MapE02:
  incbin "..\maps\e02.map.pck"  | .amountofobjects: db  0
MapE03:
  incbin "..\maps\e03.map.pck"  | .amountofobjects: db  1
  
;Player Reflection 
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw PlayerReflection    |db 8*14|dw 8*10|db 32,16|dw 12*16,spat+(12*2)|db 72-(03*6),03  ,03*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1  
  
MapE04:
  incbin "..\maps\e04.map.pck"  | .amountofobjects: db  3
  
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,       0|dw BossZombieCaterpillar|db  081|dw 8*26|db 70,56|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+54,+00,+30, 0|db 020,movepatblo1| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2: db 2,        0|dw Altar1              |db 8*02|dw 8*16|db 20,20|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+10, 0|db 000,movepatblo1| ds fill-1
.object3: db 2,        0|dw Altar2              |db 8*14|dw 8*16|db 00,00|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
    
MapE05:
  incbin "..\maps\e05.map.pck"  | .amountofobjects: db  0
MapE06:
  incbin "..\maps\e06.map.pck"  | .amountofobjects: db  0
MapE07:
  incbin "..\maps\e07.map.pck"  | .amountofobjects: db  0
MapE08:
  incbin "..\maps\e08.map.pck"  | .amountofobjects: db  0
MapE09:
  incbin "..\maps\e09.map.pck"  | .amountofobjects: db  0  
MapE10:
  incbin "..\maps\e10.map.pck"  | .amountofobjects: db  0
MapE11:
  incbin "..\maps\e11.map.pck"  | .amountofobjects: db  0
MapE12:
  incbin "..\maps\e12.map.pck"  | .amountofobjects: db  0
MapE13:
  incbin "..\maps\e13.map.pck"  | .amountofobjects: db  0  
	ds		$c000-$,$ff
dephase

;
; block $65
;
MapsBlock0F:  equ   $65
phase	$8000
MapF01:
  incbin "..\maps\f01.map.pck"  | .amountofobjects: db  0
MapF02:
  incbin "..\maps\f02.map.pck"  | .amountofobjects: db  0
MapF03:
  incbin "..\maps\f03.map.pck"  | .amountofobjects: db  1
  
;Player Reflection 
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw PlayerReflection    |db 8*14|dw 8*10|db 32,16|dw 12*16,spat+(12*2)|db 72-(03*6),03  ,03*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1  

MapF04:
  incbin "..\maps\f04.map.pck"  | .amountofobjects: db  0
MapF05:
  incbin "..\maps\f05.map.pck"  | .amountofobjects: db  0
MapF06:
  incbin "..\maps\f06.map.pck"  | .amountofobjects: db  0
MapF07:
  incbin "..\maps\f07.map.pck"  | .amountofobjects: db  0
MapF08:
  incbin "..\maps\f08.map.pck"  | .amountofobjects: db  0
MapF09:
  incbin "..\maps\f09.map.pck"  | .amountofobjects: db  0
MapF10:
  incbin "..\maps\f10.map.pck"  | .amountofobjects: db  0
MapF11:
  incbin "..\maps\f11.map.pck"  | .amountofobjects: db  0
MapF12:
  incbin "..\maps\f12.map.pck"  | .amountofobjects: db  0
MapF13:
  incbin "..\maps\f13.map.pck"  | .amountofobjects: db  0  
	ds		$c000-$,$ff
dephase

;
; block $66
;
MapsBlock0G:  equ   $66
phase	$8000
MapG01:
  incbin "..\maps\g01.map.pck"  | .amountofobjects: db  0
MapG02:
  incbin "..\maps\g02.map.pck"  | .amountofobjects: db  0
MapG03:
  incbin "..\maps\g03.map.pck"  | .amountofobjects: db  1
  
;Player Reflection 
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1:db -1,        1|dw PlayerReflection    |db 8*14|dw 8*10|db 32,16|dw 12*16,spat+(12*2)|db 72-(03*6),03  ,03*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1  

MapG04:
  incbin "..\maps\g04.map.pck"  | .amountofobjects: db  0
  
MapG05:
  incbin "..\maps\g05.map.pck"  | .amountofobjects: db  3
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
;Mika
.object1: db 2,        0|dw SDMika              |db 8*13|dw 8*00|db 00,00|dw 00000000,0 db 1,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo2| ds fill-1
;Grinder
.object2:db -1,        1|dw Grinder             |db 8*22|dw 8*16|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movepatblo1| ds fill-1  
;Spider Grey ;v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3:db -1,        1|dw GreenSpider         |db 8*19|dw 8*28|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movepatblo1| ds fill-1
    
MapG06:
  incbin "..\maps\g06.map.pck"  | .amountofobjects: db  0
MapG07:
  incbin "..\maps\g07.map.pck"  | .amountofobjects: db  0
MapG08:
  incbin "..\maps\g08.map.pck"  | .amountofobjects: db  0
MapG09:
  incbin "..\maps\g09.map.pck"  | .amountofobjects: db  0
MapG10:
  incbin "..\maps\g10.map.pck"  | .amountofobjects: db  0
MapG11:
  incbin "..\maps\g11.map.pck"  | .amountofobjects: db  0
MapG12:
  incbin "..\maps\g12.map.pck"  | .amountofobjects: db  0
MapG13:
  incbin "..\maps\g13.map.pck"  | .amountofobjects: db  1
;BossGoat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,       0|dw BossGoat             |db  064|dw 8*22|db 124,82|dw 0000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,-02,+00,+00,+20, 0|db 030,movepatblo2| ds fill-1  
	ds		$c000-$,$ff
dephase



  ds  $4000

;
; block $68
;
movementpatterns1block:  equ   $68
movepatblo1:  equ   $68
phase	$8000
  include "MovementPatterns1.asm"
	ds		$c000-$,$ff
dephase

;
; block $69
;
MovementPatternsFixedPage1block:  equ   $69
phase	$4000
  include "MovementPatternsFixedPage1.asm"
	ds		$8000-$,$ff
dephase

;
; block $6a
;
movementpatterns2block:  equ   $6a
movepatblo2:  equ   $6a
phase	$8000
  include "MovementPatterns2.asm"
	ds		$c000-$,$ff
dephase

;
; block $6b
;
phase	$8000
MapsBlockAA01:  equ   $6b | MapAA01: incbin "..\maps\AA01.map.pck"  | include "..\maps\mapdata\AA01.asm"  
MapsBlockAA02:  equ   $6b | MapAA02: incbin "..\maps\AA02.map.pck"  | include "..\maps\mapdata\AA02.asm"  
MapsBlockAA03:  equ   $6b | MapAA03: incbin "..\maps\AA03.map.pck"  | include "..\maps\mapdata\AA03.asm"  
MapsBlockAA04:  equ   $6b | MapAA04: incbin "..\maps\AA04.map.pck"  | include "..\maps\mapdata\AA04.asm"  
MapsBlockAA05:  equ   $6b | MapAA05: incbin "..\maps\AA05.map.pck"  | include "..\maps\mapdata\AA05.asm"  
MapsBlockAA06:  equ   $6b | MapAA06: incbin "..\maps\AA06.map.pck"  | include "..\maps\mapdata\AA06.asm"  
MapsBlockAA35:  equ   $6b | MapAA35: incbin "..\maps\AA35.map.pck"  | include "..\maps\mapdata\AA35.asm"  
MapsBlockAA47:  equ   $6b | MapAA47: incbin "..\maps\AA47.map.pck"  | include "..\maps\mapdata\AA47.asm"  
MapsBlockAA48:  equ   $6b | MapAA48: incbin "..\maps\AA48.map.pck"  | include "..\maps\mapdata\AA48.asm"  
MapsBlockAA49:  equ   $6b | MapAA49: incbin "..\maps\AA49.map.pck"  | include "..\maps\mapdata\AA49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $6c
;
phase	$8000
MapsBlockAB01:  equ   $6c | MapAB01: incbin "..\maps\AB01.map.pck"  | include "..\maps\mapdata\AB01.asm"  
MapsBlockAB02:  equ   $6c | MapAB02: incbin "..\maps\AB02.map.pck"  | include "..\maps\mapdata\AB02.asm"  
MapsBlockAB05:  equ   $6c | MapAB05: incbin "..\maps\AB05.map.pck"  | include "..\maps\mapdata\AB05.asm"  
MapsBlockAB06:  equ   $6c | MapAB06: incbin "..\maps\AB06.map.pck"  | include "..\maps\mapdata\AB06.asm"  
MapsBlockAB09:  equ   $6c | MapAB09: incbin "..\maps\AB09.map.pck"  | include "..\maps\mapdata\AB09.asm"  
MapsBlockAB10:  equ   $6c | MapAB10: incbin "..\maps\AB10.map.pck"  | include "..\maps\mapdata\AB10.asm"  
MapsBlockAB12:  equ   $6c | MapAB12: incbin "..\maps\AB12.map.pck"  | include "..\maps\mapdata\AB12.asm"  
MapsBlockAB35:  equ   $6c | MapAB35: incbin "..\maps\AB35.map.pck"  | include "..\maps\mapdata\AB35.asm"  
MapsBlockAB45:  equ   $6c | MapAB45: incbin "..\maps\AB45.map.pck"  | include "..\maps\mapdata\AB45.asm"  
MapsBlockAB46:  equ   $6c | MapAB46: incbin "..\maps\AB46.map.pck"  | include "..\maps\mapdata\AB46.asm"  
MapsBlockAB47:  equ   $6c | MapAB47: incbin "..\maps\AB47.map.pck"  | include "..\maps\mapdata\AB47.asm"  
MapsBlockAB48:  equ   $6c | MapAB48: incbin "..\maps\AB48.map.pck"  | include "..\maps\mapdata\AB48.asm"  
MapsBlockAB49:  equ   $6c | MapAB49: incbin "..\maps\AB49.map.pck"  | include "..\maps\mapdata\AB49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $6d
;
phase	$8000
MapsBlockAC01:  equ   $6d | MapAC01: incbin "..\maps\AC01.map.pck"  | include "..\maps\mapdata\AC01.asm"  
MapsBlockAC02:  equ   $6d | MapAC02: incbin "..\maps\AC02.map.pck"  | include "..\maps\mapdata\AC02.asm"  
MapsBlockAC03:  equ   $6d | MapAC03: incbin "..\maps\AC03.map.pck"  | include "..\maps\mapdata\AC03.asm"  
MapsBlockAC06:  equ   $6d | MapAC06: incbin "..\maps\AC06.map.pck"  | include "..\maps\mapdata\AC06.asm"  
MapsBlockAC10:  equ   $6d | MapAC10: incbin "..\maps\AC10.map.pck"  | include "..\maps\mapdata\AC10.asm"  
MapsBlockAC11:  equ   $6d | MapAC11: incbin "..\maps\AC11.map.pck"  | include "..\maps\mapdata\AC11.asm"  
MapsBlockAC12:  equ   $6d | MapAC12: incbin "..\maps\AC12.map.pck"  | include "..\maps\mapdata\AC12.asm"  
MapsBlockAC16:  equ   $6d | MapAC16: incbin "..\maps\AC16.map.pck"  | include "..\maps\mapdata\AC16.asm"  
MapsBlockAC17:  equ   $6d | MapAC17: incbin "..\maps\AC17.map.pck"  | include "..\maps\mapdata\AC17.asm"  
MapsBlockAC18:  equ   $6d | MapAC18: incbin "..\maps\AC18.map.pck"  | include "..\maps\mapdata\AC18.asm"  
MapsBlockAC19:  equ   $6d | MapAC19: incbin "..\maps\AC19.map.pck"  | include "..\maps\mapdata\AC19.asm"  
MapsBlockAC20:  equ   $6d | MapAC20: incbin "..\maps\AC20.map.pck"  | include "..\maps\mapdata\AC20.asm"  
MapsBlockAC21:  equ   $6d | MapAC21: incbin "..\maps\AC21.map.pck"  | include "..\maps\mapdata\AC21.asm"  
MapsBlockAC35:  equ   $6d | MapAC35: incbin "..\maps\AC35.map.pck"  | include "..\maps\mapdata\AC35.asm"  
MapsBlockAC36:  equ   $6d | MapAC36: incbin "..\maps\AC36.map.pck"  | include "..\maps\mapdata\AC36.asm"  
MapsBlockAC37:  equ   $6d | MapAC37: incbin "..\maps\AC37.map.pck"  | include "..\maps\mapdata\AC37.asm"  
MapsBlockAC38:  equ   $6d | MapAC38: incbin "..\maps\AC38.map.pck"  | include "..\maps\mapdata\AC38.asm"  
MapsBlockAC45:  equ   $6d | MapAC45: incbin "..\maps\AC45.map.pck"  | include "..\maps\mapdata\AC45.asm"  
MapsBlockAC47:  equ   $6d | MapAC47: incbin "..\maps\AC47.map.pck"  | include "..\maps\mapdata\AC47.asm"  
MapsBlockAC48:  equ   $6d | MapAC48: incbin "..\maps\AC48.map.pck"  | include "..\maps\mapdata\AC48.asm"  
MapsBlockAC49:  equ   $6d | MapAC49: incbin "..\maps\AC49.map.pck"  | include "..\maps\mapdata\AC49.asm"  
MapsBlockAC50:  equ   $6d | MapAC50: incbin "..\maps\AC50.map.pck"  | include "..\maps\mapdata\AC50.asm"  
	ds		$c000-$,$ff
dephase

;
; block $6e
;
phase	$8000
MapsBlockAD01:  equ   $6e | MapAD01: incbin "..\maps\AD01.map.pck"  | include "..\maps\mapdata\AD01.asm"  
MapsBlockAD02:  equ   $6e | MapAD02: incbin "..\maps\AD02.map.pck"  | include "..\maps\mapdata\AD02.asm"  
MapsBlockAD06:  equ   $6e | MapAD06: incbin "..\maps\AD06.map.pck"  | include "..\maps\mapdata\AD06.asm"  
MapsBlockAD10:  equ   $6e | MapAD10: incbin "..\maps\AD10.map.pck"  | include "..\maps\mapdata\AD10.asm"  
MapsBlockAD11:  equ   $6e | MapAD11: incbin "..\maps\AD11.map.pck"  | include "..\maps\mapdata\AD11.asm"  
MapsBlockAD12:  equ   $6e | MapAD12: incbin "..\maps\AD12.map.pck"  | include "..\maps\mapdata\AD12.asm"  
MapsBlockAD13:  equ   $6e | MapAD13: incbin "..\maps\AD13.map.pck"  | include "..\maps\mapdata\AD13.asm"  
MapsBlockAD21:  equ   $6e | MapAD21: incbin "..\maps\AD21.map.pck"  | include "..\maps\mapdata\AD21.asm"  
MapsBlockAD22:  equ   $6e | MapAD22: incbin "..\maps\AD22.map.pck"  | include "..\maps\mapdata\AD22.asm"  
MapsBlockAD23:  equ   $6e | MapAD23: incbin "..\maps\AD23.map.pck"  | include "..\maps\mapdata\AD23.asm"  
MapsBlockAD35:  equ   $6e | MapAD35: incbin "..\maps\AD35.map.pck"  | include "..\maps\mapdata\AD35.asm"  
MapsBlockAD38:  equ   $6e | MapAD38: incbin "..\maps\AD38.map.pck"  | include "..\maps\mapdata\AD38.asm"  
MapsBlockAD39:  equ   $6e | MapAD39: incbin "..\maps\AD39.map.pck"  | include "..\maps\mapdata\AD39.asm"  
MapsBlockAD40:  equ   $6e | MapAD40: incbin "..\maps\AD40.map.pck"  | include "..\maps\mapdata\AD40.asm"  
MapsBlockAD41:  equ   $6e | MapAD41: incbin "..\maps\AD41.map.pck"  | include "..\maps\mapdata\AD41.asm"  
MapsBlockAD47:  equ   $6e | MapAD47: incbin "..\maps\AD47.map.pck"  | include "..\maps\mapdata\AD47.asm"  
MapsBlockAD48:  equ   $6e | MapAD48: incbin "..\maps\AD48.map.pck"  | include "..\maps\mapdata\AD48.asm"  
MapsBlockAD49:  equ   $6e | MapAD49: incbin "..\maps\AD49.map.pck"  | include "..\maps\mapdata\AD49.asm"  
MapsBlockAD50:  equ   $6e | MapAD50: incbin "..\maps\AD50.map.pck"  | include "..\maps\mapdata\AD50.asm"  
	ds		$c000-$,$ff
dephase

;
; block $6f
;
phase	$8000
MapsBlockAE01:  equ   $6f | MapAE01: incbin "..\maps\AE01.map.pck"  | include "..\maps\mapdata\AE01.asm"  
MapsBlockAE02:  equ   $6f | MapAE02: incbin "..\maps\AE02.map.pck"  | include "..\maps\mapdata\AE02.asm"  
MapsBlockAE04:  equ   $6f | MapAE04: incbin "..\maps\AE04.map.pck"  | include "..\maps\mapdata\AE04.asm"  
MapsBlockAE05:  equ   $6f | MapAE05: incbin "..\maps\AE05.map.pck"  | include "..\maps\mapdata\AE05.asm"  
MapsBlockAE06:  equ   $6f | MapAE06: incbin "..\maps\AE06.map.pck"  | include "..\maps\mapdata\AE06.asm"  
MapsBlockAE13:  equ   $6f | MapAE13: incbin "..\maps\AE13.map.pck"  | include "..\maps\mapdata\AE13.asm"  
MapsBlockAE14:  equ   $6f | MapAE14: incbin "..\maps\AE14.map.pck"  | include "..\maps\mapdata\AE14.asm"  
MapsBlockAE15:  equ   $6f | MapAE15: incbin "..\maps\AE15.map.pck"  | include "..\maps\mapdata\AE15.asm"  
MapsBlockAE16:  equ   $6f | MapAE16: incbin "..\maps\AE16.map.pck"  | include "..\maps\mapdata\AE16.asm"  
MapsBlockAE19:  equ   $6f | MapAE19: incbin "..\maps\AE19.map.pck"  | include "..\maps\mapdata\AE19.asm"  
MapsBlockAE20:  equ   $6f | MapAE20: incbin "..\maps\AE20.map.pck"  | include "..\maps\mapdata\AE20.asm"  
MapsBlockAE21:  equ   $6f | MapAE21: incbin "..\maps\AE21.map.pck"  | include "..\maps\mapdata\AE21.asm"  
MapsBlockAE22:  equ   $6f | MapAE22: incbin "..\maps\AE22.map.pck"  | include "..\maps\mapdata\AE22.asm"  
MapsBlockAE23:  equ   $6f | MapAE23: incbin "..\maps\AE23.map.pck"  | include "..\maps\mapdata\AE23.asm"  
MapsBlockAE24:  equ   $6f | MapAE24: incbin "..\maps\AE24.map.pck"  | include "..\maps\mapdata\AE24.asm"  
MapsBlockAE25:  equ   $6f | MapAE25: incbin "..\maps\AE25.map.pck"  | include "..\maps\mapdata\AE25.asm"  
MapsBlockAE26:  equ   $6f | MapAE26: incbin "..\maps\AE26.map.pck"  | include "..\maps\mapdata\AE26.asm"  
MapsBlockAE27:  equ   $6f | MapAE27: incbin "..\maps\AE27.map.pck"  | include "..\maps\mapdata\AE27.asm"  
MapsBlockAE34:  equ   $6f | MapAE34: incbin "..\maps\AE34.map.pck"  | include "..\maps\mapdata\AE34.asm"  
MapsBlockAE35:  equ   $6f | MapAE35: incbin "..\maps\AE35.map.pck"  | include "..\maps\mapdata\AE35.asm"  
MapsBlockAE44:  equ   $6f | MapAE44: incbin "..\maps\AE44.map.pck"  | include "..\maps\mapdata\AE44.asm"  
MapsBlockAE45:  equ   $6f | MapAE45: incbin "..\maps\AE45.map.pck"  | include "..\maps\mapdata\AE45.asm"  
MapsBlockAE46:  equ   $6f | MapAE46: incbin "..\maps\AE46.map.pck"  | include "..\maps\mapdata\AE46.asm"  
MapsBlockAE47:  equ   $6f | MapAE47: incbin "..\maps\AE47.map.pck"  | include "..\maps\mapdata\AE47.asm"  
MapsBlockAE48:  equ   $6f | MapAE48: incbin "..\maps\AE48.map.pck"  | include "..\maps\mapdata\AE48.asm"  
MapsBlockAE49:  equ   $6f | MapAE49: incbin "..\maps\AE49.map.pck"  | include "..\maps\mapdata\AE49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $70
;
phase	$8000
MapsBlockAF01:  equ   $70 | MapAF01: incbin "..\maps\AF01.map.pck"  | include "..\maps\mapdata\AF01.asm"  
MapsBlockAF02:  equ   $70 | MapAF02: incbin "..\maps\AF02.map.pck"  | include "..\maps\mapdata\AF02.asm"  
MapsBlockAF04:  equ   $70 | MapAF04: incbin "..\maps\AF04.map.pck"  | include "..\maps\mapdata\AF04.asm"  
MapsBlockAF05:  equ   $70 | MapAF05: incbin "..\maps\AF05.map.pck"  | include "..\maps\mapdata\AF05.asm"  
MapsBlockAF06:  equ   $70 | MapAF06: incbin "..\maps\AF06.map.pck"  | include "..\maps\mapdata\AF06.asm"  
MapsBlockAF11:  equ   $70 | MapAF11: incbin "..\maps\AF11.map.pck"  | include "..\maps\mapdata\AF11.asm"  
MapsBlockAF12:  equ   $70 | MapAF12: incbin "..\maps\AF12.map.pck"  | include "..\maps\mapdata\AF12.asm"  
MapsBlockAF13:  equ   $70 | MapAF13: incbin "..\maps\AF13.map.pck"  | include "..\maps\mapdata\AF13.asm"  
MapsBlockAF16:  equ   $70 | MapAF16: incbin "..\maps\AF16.map.pck"  | include "..\maps\mapdata\AF16.asm"  
MapsBlockAF21:  equ   $70 | MapAF21: incbin "..\maps\AF21.map.pck"  | include "..\maps\mapdata\AF21.asm"  
MapsBlockAF22:  equ   $70 | MapAF22: incbin "..\maps\AF22.map.pck"  | include "..\maps\mapdata\AF22.asm"  
MapsBlockAF23:  equ   $70 | MapAF23: incbin "..\maps\AF23.map.pck"  | include "..\maps\mapdata\AF23.asm"  
MapsBlockAF27:  equ   $70 | MapAF27: incbin "..\maps\AF27.map.pck"  | include "..\maps\mapdata\AF27.asm"  
MapsBlockAF28:  equ   $70 | MapAF28: incbin "..\maps\AF28.map.pck"  | include "..\maps\mapdata\AF28.asm"  
MapsBlockAF34:  equ   $70 | MapAF34: incbin "..\maps\AF34.map.pck"  | include "..\maps\mapdata\AF34.asm"  
MapsBlockAF35:  equ   $70 | MapAF35: incbin "..\maps\AF35.map.pck"  | include "..\maps\mapdata\AF35.asm"  
MapsBlockAF44:  equ   $70 | MapAF44: incbin "..\maps\AF44.map.pck"  | include "..\maps\mapdata\AF44.asm"  
MapsBlockAF45:  equ   $70 | MapAF45: incbin "..\maps\AF45.map.pck"  | include "..\maps\mapdata\AF45.asm"  
MapsBlockAF47:  equ   $70 | MapAF47: incbin "..\maps\AF47.map.pck"  | include "..\maps\mapdata\AF47.asm"  
MapsBlockAF48:  equ   $70 | MapAF48: incbin "..\maps\AF48.map.pck"  | include "..\maps\mapdata\AF48.asm"  
MapsBlockAF49:  equ   $70 | MapAF49: incbin "..\maps\AF49.map.pck"  | include "..\maps\mapdata\AF49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $71
;
phase	$8000
MapsBlockAG01:  equ   $71 | MapAG01: incbin "..\maps\AG01.map.pck"  | include "..\maps\mapdata\AG01.asm"  
MapsBlockAG10:  equ   $71 | MapAG10: incbin "..\maps\AG10.map.pck"  | include "..\maps\mapdata\AG10.asm"  
MapsBlockAG11:  equ   $71 | MapAG11: incbin "..\maps\AG11.map.pck"  | include "..\maps\mapdata\AG11.asm"  
MapsBlockAG15:  equ   $71 | MapAG15: incbin "..\maps\AG15.map.pck"  | include "..\maps\mapdata\AG15.asm"  
MapsBlockAG16:  equ   $71 | MapAG16: incbin "..\maps\AG16.map.pck"  | include "..\maps\mapdata\AG16.asm"  
MapsBlockAG17:  equ   $71 | MapAG17: incbin "..\maps\AG17.map.pck"  | include "..\maps\mapdata\AG17.asm"  
MapsBlockAG18:  equ   $71 | MapAG18: incbin "..\maps\AG18.map.pck"  | include "..\maps\mapdata\AG18.asm"  
MapsBlockAG22:  equ   $71 | MapAG22: incbin "..\maps\AG22.map.pck"  | include "..\maps\mapdata\AG22.asm"  
MapsBlockAG23:  equ   $71 | MapAG23: incbin "..\maps\AG23.map.pck"  | include "..\maps\mapdata\AG23.asm"  
MapsBlockAG28:  equ   $71 | MapAG28: incbin "..\maps\AG28.map.pck"  | include "..\maps\mapdata\AG28.asm"  
MapsBlockAG33:  equ   $71 | MapAG33: incbin "..\maps\AG33.map.pck"  | include "..\maps\mapdata\AG33.asm"  
MapsBlockAG34:  equ   $71 | MapAG34: incbin "..\maps\AG34.map.pck"  | include "..\maps\mapdata\AG34.asm"  
MapsBlockAG35:  equ   $71 | MapAG35: incbin "..\maps\AG35.map.pck"  | include "..\maps\mapdata\AG35.asm"  
MapsBlockAG36:  equ   $71 | MapAG36: incbin "..\maps\AG36.map.pck"  | include "..\maps\mapdata\AG36.asm"  
MapsBlockAG37:  equ   $71 | MapAG37: incbin "..\maps\AG37.map.pck"  | include "..\maps\mapdata\AG37.asm"  
MapsBlockAG38:  equ   $71 | MapAG38: incbin "..\maps\AG38.map.pck"  | include "..\maps\mapdata\AG38.asm"  
MapsBlockAG39:  equ   $71 | MapAG39: incbin "..\maps\AG39.map.pck"  | include "..\maps\mapdata\AG39.asm"  
MapsBlockAG40:  equ   $71 | MapAG40: incbin "..\maps\AG40.map.pck"  | include "..\maps\mapdata\AG40.asm"  
MapsBlockAG41:  equ   $71 | MapAG41: incbin "..\maps\AG41.map.pck"  | include "..\maps\mapdata\AG41.asm"  
MapsBlockAG44:  equ   $71 | MapAG44: incbin "..\maps\AG44.map.pck"  | include "..\maps\mapdata\AG44.asm"  
MapsBlockAG48:  equ   $71 | MapAG48: incbin "..\maps\AG48.map.pck"  | include "..\maps\mapdata\AG48.asm"  
	ds		$c000-$,$ff
dephase

;
; block $72
;
phase	$8000

MapsBlockAH01:  equ   $72 | MapAH01: incbin "..\maps\AH01.map.pck"  | include "..\maps\mapdata\AH01.asm"  
MapsBlockAH02:  equ   $72 | MapAH02: incbin "..\maps\AH02.map.pck"  | include "..\maps\mapdata\AH02.asm"  
MapsBlockAH03:  equ   $72 | MapAH03: incbin "..\maps\AH03.map.pck"  | include "..\maps\mapdata\AH03.asm"  
MapsBlockAH08:  equ   $72 | MapAH08: incbin "..\maps\AH08.map.pck"  | include "..\maps\mapdata\AH08.asm"  
MapsBlockAH09:  equ   $72 | MapAH09: incbin "..\maps\AH09.map.pck"  | include "..\maps\mapdata\AH09.asm"  
MapsBlockAH10:  equ   $72 | MapAH10: incbin "..\maps\AH10.map.pck"  | include "..\maps\mapdata\AH10.asm"  
MapsBlockAH11:  equ   $72 | MapAH11: incbin "..\maps\AH11.map.pck"  | include "..\maps\mapdata\AH11.asm"  
MapsBlockAH16:  equ   $72 | MapAH16: incbin "..\maps\AH16.map.pck"  | include "..\maps\mapdata\AH16.asm"  
MapsBlockAH18:  equ   $72 | MapAH18: incbin "..\maps\AH18.map.pck"  | include "..\maps\mapdata\AH18.asm"  
MapsBlockAH22:  equ   $72 | MapAH22: incbin "..\maps\AH22.map.pck"  | include "..\maps\mapdata\AH22.asm"  
MapsBlockAH28:  equ   $72 | MapAH28: incbin "..\maps\AH28.map.pck"  | include "..\maps\mapdata\AH28.asm"  
MapsBlockAH29:  equ   $72 | MapAH29: incbin "..\maps\AH29.map.pck"  | include "..\maps\mapdata\AH29.asm"  
MapsBlockAH30:  equ   $72 | MapAH30: incbin "..\maps\AH30.map.pck"  | include "..\maps\mapdata\AH30.asm"  
MapsBlockAH33:  equ   $72 | MapAH33: incbin "..\maps\AH33.map.pck"  | include "..\maps\mapdata\AH33.asm"  
MapsBlockAH41:  equ   $72 | MapAH41: incbin "..\maps\AH41.map.pck"  | include "..\maps\mapdata\AH41.asm"  
MapsBlockAH44:  equ   $72 | MapAH44: incbin "..\maps\AH44.map.pck"  | include "..\maps\mapdata\AH44.asm"  
MapsBlockAH45:  equ   $72 | MapAH45: incbin "..\maps\AH45.map.pck"  | include "..\maps\mapdata\AH45.asm"  
MapsBlockAH46:  equ   $72 | MapAH46: incbin "..\maps\AH46.map.pck"  | include "..\maps\mapdata\AH46.asm"  
MapsBlockAH47:  equ   $72 | MapAH47: incbin "..\maps\AH47.map.pck"  | include "..\maps\mapdata\AH47.asm"  
MapsBlockAH48:  equ   $72 | MapAH48: incbin "..\maps\AH48.map.pck"  | include "..\maps\mapdata\AH48.asm"  
	ds		$c000-$,$ff
dephase

;
; block $73
;
phase	$8000
MapsBlockAI01:  equ   $73 | MapAI01: incbin "..\maps\AI01.map.pck"  | include "..\maps\mapdata\AI01.asm"  
MapsBlockAI03:  equ   $73 | MapAI03: incbin "..\maps\AI03.map.pck"  | include "..\maps\mapdata\AI03.asm"  
MapsBlockAI04:  equ   $73 | MapAI04: incbin "..\maps\AI04.map.pck"  | include "..\maps\mapdata\AI04.asm"  
MapsBlockAI11:  equ   $73 | MapAI11: incbin "..\maps\AI11.map.pck"  | include "..\maps\mapdata\AI11.asm"  
MapsBlockAI12:  equ   $73 | MapAI12: incbin "..\maps\AI12.map.pck"  | include "..\maps\mapdata\AI12.asm"  
MapsBlockAI14:  equ   $73 | MapAI14: incbin "..\maps\AI14.map.pck"  | include "..\maps\mapdata\AI14.asm"  
MapsBlockAI15:  equ   $73 | MapAI15: incbin "..\maps\AI15.map.pck"  | include "..\maps\mapdata\AI15.asm"  
MapsBlockAI16:  equ   $73 | MapAI16: incbin "..\maps\AI16.map.pck"  | include "..\maps\mapdata\AI16.asm"  
MapsBlockAI18:  equ   $73 | MapAI18: incbin "..\maps\AI18.map.pck"  | include "..\maps\mapdata\AI18.asm"  
MapsBlockAI22:  equ   $73 | MapAI22: incbin "..\maps\AI22.map.pck"  | include "..\maps\mapdata\AI22.asm"  
MapsBlockAI30:  equ   $73 | MapAI30: incbin "..\maps\AI30.map.pck"  | include "..\maps\mapdata\AI30.asm"  
MapsBlockAI31:  equ   $73 | MapAI31: incbin "..\maps\AI31.map.pck"  | include "..\maps\mapdata\AI31.asm"  
MapsBlockAI32:  equ   $73 | MapAI32: incbin "..\maps\AI32.map.pck"  | include "..\maps\mapdata\AI32.asm"  
MapsBlockAI33:  equ   $73 | MapAI33: incbin "..\maps\AI33.map.pck"  | include "..\maps\mapdata\AI33.asm"  
MapsBlockAI39:  equ   $73 | MapAI39: incbin "..\maps\AI39.map.pck"  | include "..\maps\mapdata\AI39.asm"  
MapsBlockAI40:  equ   $73 | MapAI40: incbin "..\maps\AI40.map.pck"  | include "..\maps\mapdata\AI40.asm"  
MapsBlockAI41:  equ   $73 | MapAI41: incbin "..\maps\AI41.map.pck"  | include "..\maps\mapdata\AI41.asm"  
MapsBlockAI44:  equ   $73 | MapAI44: incbin "..\maps\AI44.map.pck"  | include "..\maps\mapdata\AI44.asm"  
MapsBlockAI48:  equ   $73 | MapAI48: incbin "..\maps\AI48.map.pck"  | include "..\maps\mapdata\AI48.asm"  
MapsBlockAI49:  equ   $73 | MapAI49: incbin "..\maps\AI49.map.pck"  | include "..\maps\mapdata\AI49.asm"  
MapsBlockAI50:  equ   $73 | MapAI50: incbin "..\maps\AI50.map.pck"  | include "..\maps\mapdata\AI50.asm"  
	ds		$c000-$,$ff
dephase

;
; block $74
;
phase	$8000
MapsBlockAJ03:  equ   $74 | MapAJ03: incbin "..\maps\AJ03.map.pck"  | include "..\maps\mapdata\AJ03.asm"  
MapsBlockAJ04:  equ   $74 | MapAJ04: incbin "..\maps\AJ04.map.pck"  | include "..\maps\mapdata\AJ04.asm"  
MapsBlockAJ09:  equ   $74 | MapAJ09: incbin "..\maps\AJ09.map.pck"  | include "..\maps\mapdata\AJ09.asm"  
MapsBlockAJ10:  equ   $74 | MapAJ10: incbin "..\maps\AJ10.map.pck"  | include "..\maps\mapdata\AJ10.asm"  
MapsBlockAJ11:  equ   $74 | MapAJ11: incbin "..\maps\AJ11.map.pck"  | include "..\maps\mapdata\AJ11.asm"  
MapsBlockAJ14:  equ   $74 | MapAJ14: incbin "..\maps\AJ14.map.pck"  | include "..\maps\mapdata\AJ14.asm"  
MapsBlockAJ15:  equ   $74 | MapAJ15: incbin "..\maps\AJ15.map.pck"  | include "..\maps\mapdata\AJ15.asm"  
MapsBlockAJ18:  equ   $74 | MapAJ18: incbin "..\maps\AJ18.map.pck"  | include "..\maps\mapdata\AJ18.asm"  
MapsBlockAJ22:  equ   $74 | MapAJ22: incbin "..\maps\AJ22.map.pck"  | include "..\maps\mapdata\AJ22.asm"  
MapsBlockAJ29:  equ   $74 | MapAJ29: incbin "..\maps\AJ29.map.pck"  | include "..\maps\mapdata\AJ29.asm"  
MapsBlockAJ30:  equ   $74 | MapAJ30: incbin "..\maps\AJ30.map.pck"  | include "..\maps\mapdata\AJ30.asm"  
MapsBlockAJ39:  equ   $74 | MapAJ39: incbin "..\maps\AJ39.map.pck"  | include "..\maps\mapdata\AJ39.asm"  
MapsBlockAJ44:  equ   $74 | MapAJ44: incbin "..\maps\AJ44.map.pck"  | include "..\maps\mapdata\AJ44.asm"  
MapsBlockAJ45:  equ   $74 | MapAJ45: incbin "..\maps\AJ45.map.pck"  | include "..\maps\mapdata\AJ45.asm"  
MapsBlockAJ46:  equ   $74 | MapAJ46: incbin "..\maps\AJ46.map.pck"  | include "..\maps\mapdata\AJ46.asm"  
	ds		$c000-$,$ff
dephase

;
; block $75
;
phase	$8000
MapsBlockAK03:  equ   $75 | MapAK03: incbin "..\maps\AK03.map.pck"  | include "..\maps\mapdata\AK03.asm"  
MapsBlockAK04:  equ   $75 | MapAK04: incbin "..\maps\AK04.map.pck"  | include "..\maps\mapdata\AK04.asm"  
MapsBlockAK09:  equ   $75 | MapAK09: incbin "..\maps\AK09.map.pck"  | include "..\maps\mapdata\AK09.asm"  
MapsBlockAK14:  equ   $75 | MapAK14: incbin "..\maps\AK14.map.pck"  | include "..\maps\mapdata\AK14.asm"  
MapsBlockAK18:  equ   $75 | MapAK18: incbin "..\maps\AK18.map.pck"  | include "..\maps\mapdata\AK18.asm"  
MapsBlockAK19:  equ   $75 | MapAK19: incbin "..\maps\AK19.map.pck"  | include "..\maps\mapdata\AK19.asm"  
MapsBlockAK22:  equ   $75 | MapAK22: incbin "..\maps\AK22.map.pck"  | include "..\maps\mapdata\AK22.asm"  
MapsBlockAK23:  equ   $75 | MapAK23: incbin "..\maps\AK23.map.pck"  | include "..\maps\mapdata\AK23.asm"  
MapsBlockAK24:  equ   $75 | MapAK24: incbin "..\maps\AK24.map.pck"  | include "..\maps\mapdata\AK24.asm"  
MapsBlockAK27:  equ   $75 | MapAK27: incbin "..\maps\AK27.map.pck"  | include "..\maps\mapdata\AK27.asm"  
MapsBlockAK28:  equ   $75 | MapAK28: incbin "..\maps\AK28.map.pck"  | include "..\maps\mapdata\AK28.asm"  
MapsBlockAK29:  equ   $75 | MapAK29: incbin "..\maps\AK29.map.pck"  | include "..\maps\mapdata\AK29.asm"  
MapsBlockAK36:  equ   $75 | MapAK36: incbin "..\maps\AK36.map.pck"  | include "..\maps\mapdata\AK36.asm"  
MapsBlockAK37:  equ   $75 | MapAK37: incbin "..\maps\AK37.map.pck"  | include "..\maps\mapdata\AK37.asm"  
MapsBlockAK38:  equ   $75 | MapAK38: incbin "..\maps\AK38.map.pck"  | include "..\maps\mapdata\AK38.asm"  
MapsBlockAK39:  equ   $75 | MapAK39: incbin "..\maps\AK39.map.pck"  | include "..\maps\mapdata\AK39.asm"  
MapsBlockAK44:  equ   $75 | MapAK44: incbin "..\maps\AK44.map.pck"  | include "..\maps\mapdata\AK44.asm"  
MapsBlockAK45:  equ   $75 | MapAK45: incbin "..\maps\AK45.map.pck"  | include "..\maps\mapdata\AK45.asm"  
MapsBlockAK46:  equ   $75 | MapAK46: incbin "..\maps\AK46.map.pck"  | include "..\maps\mapdata\AK46.asm"  
	ds		$c000-$,$ff
dephase

;
; block $76
;
phase	$8000
MapsBlockAL04:  equ   $76 | MapAL04: incbin "..\maps\AL04.map.pck"  | include "..\maps\mapdata\AL04.asm"  
MapsBlockAL05:  equ   $76 | MapAL05: incbin "..\maps\AL05.map.pck"  | include "..\maps\mapdata\AL05.asm"  
MapsBlockAL06:  equ   $76 | MapAL06: incbin "..\maps\AL06.map.pck"  | include "..\maps\mapdata\AL06.asm"  
MapsBlockAL07:  equ   $76 | MapAL07: incbin "..\maps\AL07.map.pck"  | include "..\maps\mapdata\AL07.asm"  
MapsBlockAL08:  equ   $76 | MapAL08: incbin "..\maps\AL08.map.pck"  | include "..\maps\mapdata\AL08.asm"  
MapsBlockAL09:  equ   $76 | MapAL09: incbin "..\maps\AL09.map.pck"  | include "..\maps\mapdata\AL09.asm"  
MapsBlockAL11:  equ   $76 | MapAL11: incbin "..\maps\AL11.map.pck"  | include "..\maps\mapdata\AL11.asm"  
MapsBlockAL14:  equ   $76 | MapAL14: incbin "..\maps\AL14.map.pck"  | include "..\maps\mapdata\AL14.asm"  
MapsBlockAL19:  equ   $76 | MapAL19: incbin "..\maps\AL19.map.pck"  | include "..\maps\mapdata\AL19.asm"  
MapsBlockAL20:  equ   $76 | MapAL20: incbin "..\maps\AL20.map.pck"  | include "..\maps\mapdata\AL20.asm"  
MapsBlockAL24:  equ   $76 | MapAL24: incbin "..\maps\AL24.map.pck"  | include "..\maps\mapdata\AL24.asm"  
MapsBlockAL27:  equ   $76 | MapAL27: incbin "..\maps\AL27.map.pck"  | include "..\maps\mapdata\AL27.asm"  
MapsBlockAL28:  equ   $76 | MapAL28: incbin "..\maps\AL28.map.pck"  | include "..\maps\mapdata\AL28.asm"  
MapsBlockAL36:  equ   $76 | MapAL36: incbin "..\maps\AL36.map.pck"  | include "..\maps\mapdata\AL36.asm"  
MapsBlockAL39:  equ   $76 | MapAL39: incbin "..\maps\AL39.map.pck"  | include "..\maps\mapdata\AL39.asm"  
MapsBlockAL44:  equ   $76 | MapAL44: incbin "..\maps\AL44.map.pck"  | include "..\maps\mapdata\AL44.asm"  
	ds		$c000-$,$ff
dephase

;
; block $77
;
phase	$8000
MapsBlockAM02:  equ   $77 | MapAM02: incbin "..\maps\AM02.map.pck"  | include "..\maps\mapdata\AM02.asm"  
MapsBlockAM11:  equ   $77 | MapAM11: incbin "..\maps\AM11.map.pck"  | include "..\maps\mapdata\AM11.asm"  
MapsBlockAM13:  equ   $77 | MapAM13: incbin "..\maps\AM13.map.pck"  | include "..\maps\mapdata\AM13.asm"  
MapsBlockAM14:  equ   $77 | MapAM14: incbin "..\maps\AM14.map.pck"  | include "..\maps\mapdata\AM14.asm"  
MapsBlockAM16:  equ   $77 | MapAM16: incbin "..\maps\AM16.map.pck"  | include "..\maps\mapdata\AM16.asm"  
MapsBlockAM20:  equ   $77 | MapAM20: incbin "..\maps\AM20.map.pck"  | include "..\maps\mapdata\AM20.asm"  
MapsBlockAM21:  equ   $77 | MapAM21: incbin "..\maps\AM21.map.pck"  | include "..\maps\mapdata\AM21.asm"  
MapsBlockAM22:  equ   $77 | MapAM22: incbin "..\maps\AM22.map.pck"  | include "..\maps\mapdata\AM22.asm"  
MapsBlockAM23:  equ   $77 | MapAM23: incbin "..\maps\AM23.map.pck"  | include "..\maps\mapdata\AM23.asm"  
MapsBlockAM24:  equ   $77 | MapAM24: incbin "..\maps\AM24.map.pck"  | include "..\maps\mapdata\AM24.asm"  
MapsBlockAM36:  equ   $77 | MapAM36: incbin "..\maps\AM36.map.pck"  | include "..\maps\mapdata\AM36.asm"  
MapsBlockAM39:  equ   $77 | MapAM39: incbin "..\maps\AM39.map.pck"  | include "..\maps\mapdata\AM39.asm"  
MapsBlockAM40:  equ   $77 | MapAM40: incbin "..\maps\AM40.map.pck"  | include "..\maps\mapdata\AM40.asm"  
MapsBlockAM42:  equ   $77 | MapAM42: incbin "..\maps\AM42.map.pck"  | include "..\maps\mapdata\AM42.asm"  
MapsBlockAM43:  equ   $77 | MapAM43: incbin "..\maps\AM43.map.pck"  | include "..\maps\mapdata\AM43.asm"  
MapsBlockAM44:  equ   $77 | MapAM44: incbin "..\maps\AM44.map.pck"  | include "..\maps\mapdata\AM44.asm"  
	ds		$c000-$,$ff
dephase

;
; block $78
;
phase	$8000
MapsBlockAN02:  equ   $78 | MapAN02: incbin "..\maps\AN02.map.pck"  | include "..\maps\mapdata\AN02.asm"  
MapsBlockAN03:  equ   $78 | MapAN03: incbin "..\maps\AN03.map.pck"  | include "..\maps\mapdata\AN03.asm"  
MapsBlockAN04:  equ   $78 | MapAN04: incbin "..\maps\AN04.map.pck"  | include "..\maps\mapdata\AN04.asm"  
MapsBlockAN06:  equ   $78 | MapAN06: incbin "..\maps\AN06.map.pck"  | include "..\maps\mapdata\AN06.asm"  
MapsBlockAN07:  equ   $78 | MapAN07: incbin "..\maps\AN07.map.pck"  | include "..\maps\mapdata\AN07.asm"  
MapsBlockAN08:  equ   $78 | MapAN08: incbin "..\maps\AN08.map.pck"  | include "..\maps\mapdata\AN08.asm"  
MapsBlockAN10:  equ   $78 | MapAN10: incbin "..\maps\AN10.map.pck"  | include "..\maps\mapdata\AN10.asm"  
MapsBlockAN11:  equ   $78 | MapAN11: incbin "..\maps\AN11.map.pck"  | include "..\maps\mapdata\AN11.asm"  
MapsBlockAN12:  equ   $78 | MapAN12: incbin "..\maps\AN12.map.pck"  | include "..\maps\mapdata\AN12.asm"  
MapsBlockAN13:  equ   $78 | MapAN13: incbin "..\maps\AN13.map.pck"  | include "..\maps\mapdata\AN13.asm"  
MapsBlockAN14:  equ   $78 | MapAN14: incbin "..\maps\AN14.map.pck"  | include "..\maps\mapdata\AN14.asm"  
MapsBlockAN15:  equ   $78 | MapAN15: incbin "..\maps\AN15.map.pck"  | include "..\maps\mapdata\AN15.asm"  
MapsBlockAN16:  equ   $78 | MapAN16: incbin "..\maps\AN16.map.pck"  | include "..\maps\mapdata\AN16.asm"  
MapsBlockAN17:  equ   $78 | MapAN17: incbin "..\maps\AN17.map.pck"  | include "..\maps\mapdata\AN17.asm"  
MapsBlockAN18:  equ   $78 | MapAN18: incbin "..\maps\AN18.map.pck"  | include "..\maps\mapdata\AN18.asm"  
MapsBlockAN19:  equ   $78 | MapAN19: incbin "..\maps\AN19.map.pck"  | include "..\maps\mapdata\AN19.asm"  
MapsBlockAN20:  equ   $78 | MapAN20: incbin "..\maps\AN20.map.pck"  | include "..\maps\mapdata\AN20.asm"  
MapsBlockAN40:  equ   $78 | MapAN40: incbin "..\maps\AN40.map.pck"  | include "..\maps\mapdata\AN40.asm"  
MapsBlockAN41:  equ   $78 | MapAN41: incbin "..\maps\AN41.map.pck"  | include "..\maps\mapdata\AN41.asm"  
MapsBlockAN42:  equ   $78 | MapAN42: incbin "..\maps\AN42.map.pck"  | include "..\maps\mapdata\AN42.asm"  
MapsBlockAN47:  equ   $78 | MapAN47: incbin "..\maps\AN47.map.pck"  | include "..\maps\mapdata\AN47.asm"  
MapsBlockAN48:  equ   $78 | MapAN48: incbin "..\maps\AN48.map.pck"  | include "..\maps\mapdata\AN48.asm"  
MapsBlockAN49:  equ   $78 | MapAN49: incbin "..\maps\AN49.map.pck"  | include "..\maps\mapdata\AN49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $79
;
phase	$8000
MapsBlockAO03:  equ   $79 | MapAO03: incbin "..\maps\AO03.map.pck"  | include "..\maps\mapdata\AO03.asm"  
MapsBlockAO06:  equ   $79 | MapAO06: incbin "..\maps\AO06.map.pck"  | include "..\maps\mapdata\AO06.asm"  
MapsBlockAO08:  equ   $79 | MapAO08: incbin "..\maps\AO08.map.pck"  | include "..\maps\mapdata\AO08.asm"  
MapsBlockAO10:  equ   $79 | MapAO10: incbin "..\maps\AO10.map.pck"  | include "..\maps\mapdata\AO10.asm"  
MapsBlockAO11:  equ   $79 | MapAO11: incbin "..\maps\AO11.map.pck"  | include "..\maps\mapdata\AO11.asm"  
MapsBlockAO14:  equ   $79 | MapAO14: incbin "..\maps\AO14.map.pck"  | include "..\maps\mapdata\AO14.asm"  
MapsBlockAO17:  equ   $79 | MapAO17: incbin "..\maps\AO17.map.pck"  | include "..\maps\mapdata\AO17.asm"  
MapsBlockAO40:  equ   $79 | MapAO40: incbin "..\maps\AO40.map.pck"  | include "..\maps\mapdata\AO40.asm"  
MapsBlockAO46:  equ   $79 | MapAO46: incbin "..\maps\AO46.map.pck"  | include "..\maps\mapdata\AO46.asm"  
MapsBlockAO47:  equ   $79 | MapAO47: incbin "..\maps\AO47.map.pck"  | include "..\maps\mapdata\AO47.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7a
;
phase	$8000
MapsBlockAP03:  equ   $7a | MapAP03: incbin "..\maps\AP03.map.pck"  | include "..\maps\mapdata\AP03.asm"  
MapsBlockAP04:  equ   $7a | MapAP04: incbin "..\maps\AP04.map.pck"  | include "..\maps\mapdata\AP04.asm"  
MapsBlockAP05:  equ   $7a | MapAP05: incbin "..\maps\AP05.map.pck"  | include "..\maps\mapdata\AP05.asm"  
MapsBlockAP06:  equ   $7a | MapAP06: incbin "..\maps\AP06.map.pck"  | include "..\maps\mapdata\AP06.asm"  
MapsBlockAP08:  equ   $7a | MapAP08: incbin "..\maps\AP08.map.pck"  | include "..\maps\mapdata\AP08.asm"  
MapsBlockAP09:  equ   $7a | MapAP09: incbin "..\maps\AP09.map.pck"  | include "..\maps\mapdata\AP09.asm"  
MapsBlockAP10:  equ   $7a | MapAP10: incbin "..\maps\AP10.map.pck"  | include "..\maps\mapdata\AP10.asm"  
MapsBlockAP11:  equ   $7a | MapAP11: incbin "..\maps\AP11.map.pck"  | include "..\maps\mapdata\AP11.asm"  
MapsBlockAP14:  equ   $7a | MapAP14: incbin "..\maps\AP14.map.pck"  | include "..\maps\mapdata\AP14.asm"  
MapsBlockAP15:  equ   $7a | MapAP15: incbin "..\maps\AP15.map.pck"  | include "..\maps\mapdata\AP15.asm"  
MapsBlockAP17:  equ   $7a | MapAP17: incbin "..\maps\AP17.map.pck"  | include "..\maps\mapdata\AP17.asm"  
MapsBlockAP22:  equ   $7a | MapAP22: incbin "..\maps\AP22.map.pck"  | include "..\maps\mapdata\AP22.asm"  
MapsBlockAP32:  equ   $7a | MapAP32: incbin "..\maps\AP32.map.pck"  | include "..\maps\mapdata\AP32.asm"  
MapsBlockAP40:  equ   $7a | MapAP40: incbin "..\maps\AP40.map.pck"  | include "..\maps\mapdata\AP40.asm"  
MapsBlockAP41:  equ   $7a | MapAP41: incbin "..\maps\AP41.map.pck"  | include "..\maps\mapdata\AP41.asm"  
MapsBlockAP47:  equ   $7a | MapAP47: incbin "..\maps\AP47.map.pck"  | include "..\maps\mapdata\AP47.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7b
;
phase	$8000
MapsBlockAQ04:  equ   $7b | MapAQ04: incbin "..\maps\AQ04.map.pck"  | include "..\maps\mapdata\AQ04.asm"  
MapsBlockAQ06:  equ   $7b | MapAQ06: incbin "..\maps\AQ06.map.pck"  | include "..\maps\mapdata\AQ06.asm"  
MapsBlockAQ10:  equ   $7b | MapAQ10: incbin "..\maps\AQ10.map.pck"  | include "..\maps\mapdata\AQ10.asm"  
MapsBlockAQ11:  equ   $7b | MapAQ11: incbin "..\maps\AQ11.map.pck"  | include "..\maps\mapdata\AQ11.asm"  
MapsBlockAQ17:  equ   $7b | MapAQ17: incbin "..\maps\AQ17.map.pck"  | include "..\maps\mapdata\AQ17.asm"  
MapsBlockAQ20:  equ   $7b | MapAQ20: incbin "..\maps\AQ20.map.pck"  | include "..\maps\mapdata\AQ20.asm"  
MapsBlockAQ21:  equ   $7b | MapAQ21: incbin "..\maps\AQ21.map.pck"  | include "..\maps\mapdata\AQ21.asm"  
MapsBlockAQ22:  equ   $7b | MapAQ22: incbin "..\maps\AQ22.map.pck"  | include "..\maps\mapdata\AQ22.asm"  
MapsBlockAQ31:  equ   $7b | MapAQ31: incbin "..\maps\AQ31.map.pck"  | include "..\maps\mapdata\AQ31.asm"  
MapsBlockAQ32:  equ   $7b | MapAQ32: incbin "..\maps\AQ32.map.pck"  | include "..\maps\mapdata\AQ32.asm"  
MapsBlockAQ36:  equ   $7b | MapAQ36: incbin "..\maps\AQ36.map.pck"  | include "..\maps\mapdata\AQ36.asm"  
MapsBlockAQ39:  equ   $7b | MapAQ39: incbin "..\maps\AQ39.map.pck"  | include "..\maps\mapdata\AQ39.asm"  
MapsBlockAQ40:  equ   $7b | MapAQ40: incbin "..\maps\AQ40.map.pck"  | include "..\maps\mapdata\AQ40.asm"  
MapsBlockAQ41:  equ   $7b | MapAQ41: incbin "..\maps\AQ41.map.pck"  | include "..\maps\mapdata\AQ41.asm"  
MapsBlockAQ45:  equ   $7b | MapAQ45: incbin "..\maps\AQ45.map.pck"  | include "..\maps\mapdata\AQ45.asm"  
MapsBlockAQ46:  equ   $7b | MapAQ46: incbin "..\maps\AQ46.map.pck"  | include "..\maps\mapdata\AQ46.asm"  
MapsBlockAQ47:  equ   $7b | MapAQ47: incbin "..\maps\AQ47.map.pck"  | include "..\maps\mapdata\AQ47.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7c
;
phase	$8000
MapsBlockAR04:  equ   $7c | MapAR04: incbin "..\maps\AR04.map.pck"  | include "..\maps\mapdata\AR04.asm"  
MapsBlockAR05:  equ   $7c | MapAR05: incbin "..\maps\AR05.map.pck"  | include "..\maps\mapdata\AR05.asm"  
MapsBlockAR06:  equ   $7c | MapAR06: incbin "..\maps\AR06.map.pck"  | include "..\maps\mapdata\AR06.asm"  
MapsBlockAR11:  equ   $7c | MapAR11: incbin "..\maps\AR11.map.pck"  | include "..\maps\mapdata\AR11.asm"  
MapsBlockAR12:  equ   $7c | MapAR12: incbin "..\maps\AR12.map.pck"  | include "..\maps\mapdata\AR12.asm"  
MapsBlockAR17:  equ   $7c | MapAR17: incbin "..\maps\AR17.map.pck"  | include "..\maps\mapdata\AR17.asm"  
MapsBlockAR20:  equ   $7c | MapAR20: incbin "..\maps\AR20.map.pck"  | include "..\maps\mapdata\AR20.asm"  
MapsBlockAR31:  equ   $7c | MapAR31: incbin "..\maps\AR31.map.pck"  | include "..\maps\mapdata\AR31.asm"  
MapsBlockAR32:  equ   $7c | MapAR32: incbin "..\maps\AR32.map.pck"  | include "..\maps\mapdata\AR32.asm"  
MapsBlockAR36:  equ   $7c | MapAR36: incbin "..\maps\AR36.map.pck"  | include "..\maps\mapdata\AR36.asm"  
MapsBlockAR39:  equ   $7c | MapAR39: incbin "..\maps\AR39.map.pck"  | include "..\maps\mapdata\AR39.asm"  
MapsBlockAR40:  equ   $7c | MapAR40: incbin "..\maps\AR40.map.pck"  | include "..\maps\mapdata\AR40.asm"  
MapsBlockAR45:  equ   $7c | MapAR45: incbin "..\maps\AR45.map.pck"  | include "..\maps\mapdata\AR45.asm"  
MapsBlockAR46:  equ   $7c | MapAR46: incbin "..\maps\AR46.map.pck"  | include "..\maps\mapdata\AR46.asm"  
MapsBlockAR47:  equ   $7c | MapAR47: incbin "..\maps\AR47.map.pck"  | include "..\maps\mapdata\AR47.asm"  
MapsBlockAR48:  equ   $7c | MapAR48: incbin "..\maps\AR48.map.pck"  | include "..\maps\mapdata\AR48.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7d
;
phase	$8000
MapsBlockAS04:  equ   $7d | MapAS04: incbin "..\maps\AS04.map.pck"  | include "..\maps\mapdata\AS04.asm"  
MapsBlockAS12:  equ   $7d | MapAS12: incbin "..\maps\AS12.map.pck"  | include "..\maps\mapdata\AS12.asm"  
MapsBlockAS14:  equ   $7d | MapAS14: incbin "..\maps\AS14.map.pck"  | include "..\maps\mapdata\AS14.asm"  
MapsBlockAS15:  equ   $7d | MapAS15: incbin "..\maps\AS15.map.pck"  | include "..\maps\mapdata\AS15.asm"  
MapsBlockAS16:  equ   $7d | MapAS16: incbin "..\maps\AS16.map.pck"  | include "..\maps\mapdata\AS16.asm"  
MapsBlockAS17:  equ   $7d | MapAS17: incbin "..\maps\AS17.map.pck"  | include "..\maps\mapdata\AS17.asm"  
MapsBlockAS18:  equ   $7d | MapAS18: incbin "..\maps\AS18.map.pck"  | include "..\maps\mapdata\AS18.asm"  
MapsBlockAS19:  equ   $7d | MapAS19: incbin "..\maps\AS19.map.pck"  | include "..\maps\mapdata\AS19.asm"  
MapsBlockAS20:  equ   $7d | MapAS20: incbin "..\maps\AS20.map.pck"  | include "..\maps\mapdata\AS20.asm"  
MapsBlockAS27:  equ   $7d | MapAS27: incbin "..\maps\AS27.map.pck"  | include "..\maps\mapdata\AS27.asm"  
MapsBlockAS31:  equ   $7d | MapAS31: incbin "..\maps\AS31.map.pck"  | include "..\maps\mapdata\AS31.asm"  
MapsBlockAS32:  equ   $7d | MapAS32: incbin "..\maps\AS32.map.pck"  | include "..\maps\mapdata\AS32.asm"  
MapsBlockAS33:  equ   $7d | MapAS33: incbin "..\maps\AS33.map.pck"  | include "..\maps\mapdata\AS33.asm"  
MapsBlockAS34:  equ   $7d | MapAS34: incbin "..\maps\AS34.map.pck"  | include "..\maps\mapdata\AS34.asm"  
MapsBlockAS35:  equ   $7d | MapAS35: incbin "..\maps\AS35.map.pck"  | include "..\maps\mapdata\AS35.asm"  
MapsBlockAS36:  equ   $7d | MapAS36: incbin "..\maps\AS36.map.pck"  | include "..\maps\mapdata\AS36.asm"  
MapsBlockAS37:  equ   $7d | MapAS37: incbin "..\maps\AS37.map.pck"  | include "..\maps\mapdata\AS37.asm"  
MapsBlockAS40:  equ   $7d | MapAS40: incbin "..\maps\AS40.map.pck"  | include "..\maps\mapdata\AS40.asm"  
MapsBlockAS41:  equ   $7d | MapAS41: incbin "..\maps\AS41.map.pck"  | include "..\maps\mapdata\AS41.asm"  
MapsBlockAS42:  equ   $7d | MapAS42: incbin "..\maps\AS42.map.pck"  | include "..\maps\mapdata\AS42.asm"  
MapsBlockAS43:  equ   $7d | MapAS43: incbin "..\maps\AS43.map.pck"  | include "..\maps\mapdata\AS43.asm"  
MapsBlockAS44:  equ   $7d | MapAS44: incbin "..\maps\AS44.map.pck"  | include "..\maps\mapdata\AS44.asm"  
MapsBlockAS45:  equ   $7d | MapAS45: incbin "..\maps\AS45.map.pck"  | include "..\maps\mapdata\AS45.asm"  
MapsBlockAS48:  equ   $7d | MapAS48: incbin "..\maps\AS48.map.pck"  | include "..\maps\mapdata\AS48.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7e
;
phase	$8000
MapsBlockAT03:  equ   $7e | MapAT03: incbin "..\maps\AT03.map.pck"  | include "..\maps\mapdata\AT03.asm"  
MapsBlockAT04:  equ   $7e | MapAT04: incbin "..\maps\AT04.map.pck"  | include "..\maps\mapdata\AT04.asm"  
MapsBlockAT05:  equ   $7e | MapAT05: incbin "..\maps\AT05.map.pck"  | include "..\maps\mapdata\AT05.asm"  
MapsBlockAT06:  equ   $7e | MapAT06: incbin "..\maps\AT06.map.pck"  | include "..\maps\mapdata\AT06.asm"  
MapsBlockAT07:  equ   $7e | MapAT07: incbin "..\maps\AT07.map.pck"  | include "..\maps\mapdata\AT07.asm"  
MapsBlockAT08:  equ   $7e | MapAT08: incbin "..\maps\AT08.map.pck"  | include "..\maps\mapdata\AT08.asm"  
MapsBlockAT11:  equ   $7e | MapAT11: incbin "..\maps\AT11.map.pck"  | include "..\maps\mapdata\AT11.asm"  
MapsBlockAT12:  equ   $7e | MapAT12: incbin "..\maps\AT12.map.pck"  | include "..\maps\mapdata\AT12.asm"  
MapsBlockAT14:  equ   $7e | MapAT14: incbin "..\maps\AT14.map.pck"  | include "..\maps\mapdata\AT14.asm"  
MapsBlockAT17:  equ   $7e | MapAT17: incbin "..\maps\AT17.map.pck"  | include "..\maps\mapdata\AT17.asm"  
MapsBlockAT19:  equ   $7e | MapAT19: incbin "..\maps\AT19.map.pck"  | include "..\maps\mapdata\AT19.asm"  
MapsBlockAT20:  equ   $7e | MapAT20: incbin "..\maps\AT20.map.pck"  | include "..\maps\mapdata\AT20.asm"  
MapsBlockAT23:  equ   $7e | MapAT23: incbin "..\maps\AT23.map.pck"  | include "..\maps\mapdata\AT23.asm"  
MapsBlockAT27:  equ   $7e | MapAT27: incbin "..\maps\AT27.map.pck"  | include "..\maps\mapdata\AT27.asm"  
MapsBlockAT31:  equ   $7e | MapAT31: incbin "..\maps\AT31.map.pck"  | include "..\maps\mapdata\AT31.asm"  
MapsBlockAT32:  equ   $7e | MapAT32: incbin "..\maps\AT32.map.pck"  | include "..\maps\mapdata\AT32.asm"  
MapsBlockAT35:  equ   $7e | MapAT35: incbin "..\maps\AT35.map.pck"  | include "..\maps\mapdata\AT35.asm"  
MapsBlockAT37:  equ   $7e | MapAT37: incbin "..\maps\AT37.map.pck"  | include "..\maps\mapdata\AT37.asm"  
MapsBlockAT40:  equ   $7e | MapAT40: incbin "..\maps\AT40.map.pck"  | include "..\maps\mapdata\AT40.asm"  
MapsBlockAT45:  equ   $7e | MapAT45: incbin "..\maps\AT45.map.pck"  | include "..\maps\mapdata\AT45.asm"  
	ds		$c000-$,$ff
dephase

;
; block $7f
;
phase	$8000
MapsBlockAU03:  equ   $7f | MapAU03: incbin "..\maps\AU03.map.pck"  | include "..\maps\mapdata\AU03.asm"  
MapsBlockAU05:  equ   $7f | MapAU05: incbin "..\maps\AU05.map.pck"  | include "..\maps\mapdata\AU05.asm"  
MapsBlockAU06:  equ   $7f | MapAU06: incbin "..\maps\AU06.map.pck"  | include "..\maps\mapdata\AU06.asm"  
MapsBlockAU07:  equ   $7f | MapAU07: incbin "..\maps\AU07.map.pck"  | include "..\maps\mapdata\AU07.asm"  
MapsBlockAU08:  equ   $7f | MapAU08: incbin "..\maps\AU08.map.pck"  | include "..\maps\mapdata\AU08.asm"  
MapsBlockAU11:  equ   $7f | MapAU11: incbin "..\maps\AU11.map.pck"  | include "..\maps\mapdata\AU11.asm"  
MapsBlockAU14:  equ   $7f | MapAU14: incbin "..\maps\AU14.map.pck"  | include "..\maps\mapdata\AU14.asm"  
MapsBlockAU15:  equ   $7f | MapAU15: incbin "..\maps\AU15.map.pck"  | include "..\maps\mapdata\AU15.asm"  
MapsBlockAU17:  equ   $7f | MapAU17: incbin "..\maps\AU17.map.pck"  | include "..\maps\mapdata\AU17.asm"  
MapsBlockAU20:  equ   $7f | MapAU20: incbin "..\maps\AU20.map.pck"  | include "..\maps\mapdata\AU20.asm"  
MapsBlockAU21:  equ   $7f | MapAU21: incbin "..\maps\AU21.map.pck"  | include "..\maps\mapdata\AU21.asm"  
MapsBlockAU23:  equ   $7f | MapAU23: incbin "..\maps\AU23.map.pck"  | include "..\maps\mapdata\AU23.asm"  
MapsBlockAU24:  equ   $7f | MapAU24: incbin "..\maps\AU24.map.pck"  | include "..\maps\mapdata\AU24.asm"  
MapsBlockAU25:  equ   $7f | MapAU25: incbin "..\maps\AU25.map.pck"  | include "..\maps\mapdata\AU25.asm"  
MapsBlockAU26:  equ   $7f | MapAU26: incbin "..\maps\AU26.map.pck"  | include "..\maps\mapdata\AU26.asm"  
MapsBlockAU27:  equ   $7f | MapAU27: incbin "..\maps\AU27.map.pck"  | include "..\maps\mapdata\AU27.asm"  
MapsBlockAU28:  equ   $7f | MapAU28: incbin "..\maps\AU28.map.pck"  | include "..\maps\mapdata\AU28.asm"  
MapsBlockAU29:  equ   $7f | MapAU29: incbin "..\maps\AU29.map.pck"  | include "..\maps\mapdata\AU29.asm"  
MapsBlockAU31:  equ   $7f | MapAU31: incbin "..\maps\AU31.map.pck"  | include "..\maps\mapdata\AU31.asm"  
MapsBlockAU34:  equ   $7f | MapAU34: incbin "..\maps\AU34.map.pck"  | include "..\maps\mapdata\AU34.asm"  
MapsBlockAU35:  equ   $7f | MapAU35: incbin "..\maps\AU35.map.pck"  | include "..\maps\mapdata\AU35.asm"  
MapsBlockAU40:  equ   $7f | MapAU40: incbin "..\maps\AU40.map.pck"  | include "..\maps\mapdata\AU40.asm"  
MapsBlockAU41:  equ   $7f | MapAU41: incbin "..\maps\AU41.map.pck"  | include "..\maps\mapdata\AU41.asm"  
MapsBlockAU42:  equ   $7f | MapAU42: incbin "..\maps\AU42.map.pck"  | include "..\maps\mapdata\AU42.asm"  
MapsBlockAU43:  equ   $7f | MapAU43: incbin "..\maps\AU43.map.pck"  | include "..\maps\mapdata\AU43.asm"  
MapsBlockAU44:  equ   $7f | MapAU44: incbin "..\maps\AU44.map.pck"  | include "..\maps\mapdata\AU44.asm"  
MapsBlockAU45:  equ   $7f | MapAU45: incbin "..\maps\AU45.map.pck"  | include "..\maps\mapdata\AU45.asm"  
	ds		$c000-$,$ff
dephase

;
; block $80
;
phase	$8000
MapsBlockAV03:  equ   $80 | MapAV03: incbin "..\maps\AV03.map.pck"  | include "..\maps\mapdata\AV03.asm"  
MapsBlockAV06:  equ   $80 | MapAV06: incbin "..\maps\AV06.map.pck"  | include "..\maps\mapdata\AV06.asm"  
MapsBlockAV08:  equ   $80 | MapAV08: incbin "..\maps\AV08.map.pck"  | include "..\maps\mapdata\AV08.asm"  
MapsBlockAV09:  equ   $80 | MapAV09: incbin "..\maps\AV09.map.pck"  | include "..\maps\mapdata\AV09.asm"  
MapsBlockAV10:  equ   $80 | MapAV10: incbin "..\maps\AV10.map.pck"  | include "..\maps\mapdata\AV10.asm"  
MapsBlockAV11:  equ   $80 | MapAV11: incbin "..\maps\AV11.map.pck"  | include "..\maps\mapdata\AV11.asm"  
MapsBlockAV14:  equ   $80 | MapAV14: incbin "..\maps\AV14.map.pck"  | include "..\maps\mapdata\AV14.asm"  
MapsBlockAV17:  equ   $80 | MapAV17: incbin "..\maps\AV17.map.pck"  | include "..\maps\mapdata\AV17.asm"  
MapsBlockAV18:  equ   $80 | MapAV18: incbin "..\maps\AV18.map.pck"  | include "..\maps\mapdata\AV18.asm"  
MapsBlockAV20:  equ   $80 | MapAV20: incbin "..\maps\AV20.map.pck"  | include "..\maps\mapdata\AV20.asm"  
MapsBlockAV21:  equ   $80 | MapAV21: incbin "..\maps\AV21.map.pck"  | include "..\maps\mapdata\AV21.asm"  
MapsBlockAV23:  equ   $80 | MapAV23: incbin "..\maps\AV23.map.pck"  | include "..\maps\mapdata\AV23.asm"  
MapsBlockAV24:  equ   $80 | MapAV24: incbin "..\maps\AV24.map.pck"  | include "..\maps\mapdata\AV24.asm"  
MapsBlockAV25:  equ   $80 | MapAV25: incbin "..\maps\AV25.map.pck"  | include "..\maps\mapdata\AV25.asm"  
MapsBlockAV26:  equ   $80 | MapAV26: incbin "..\maps\AV26.map.pck"  | include "..\maps\mapdata\AV26.asm"  
MapsBlockAV27:  equ   $80 | MapAV27: incbin "..\maps\AV27.map.pck"  | include "..\maps\mapdata\AV27.asm"  
MapsBlockAV28:  equ   $80 | MapAV28: incbin "..\maps\AV28.map.pck"  | include "..\maps\mapdata\AV28.asm"  
MapsBlockAV29:  equ   $80 | MapAV29: incbin "..\maps\AV29.map.pck"  | include "..\maps\mapdata\AV29.asm"  
MapsBlockAV31:  equ   $80 | MapAV31: incbin "..\maps\AV31.map.pck"  | include "..\maps\mapdata\AV31.asm"  
MapsBlockAV34:  equ   $80 | MapAV34: incbin "..\maps\AV34.map.pck"  | include "..\maps\mapdata\AV34.asm"  
MapsBlockAV35:  equ   $80 | MapAV35: incbin "..\maps\AV35.map.pck"  | include "..\maps\mapdata\AV35.asm"  
MapsBlockAV39:  equ   $80 | MapAV39: incbin "..\maps\AV39.map.pck"  | include "..\maps\mapdata\AV39.asm"  
MapsBlockAV40:  equ   $80 | MapAV40: incbin "..\maps\AV40.map.pck"  | include "..\maps\mapdata\AV40.asm"  
MapsBlockAV44:  equ   $80 | MapAV44: incbin "..\maps\AV44.map.pck"  | include "..\maps\mapdata\AV44.asm"  
	ds		$c000-$,$ff
dephase

;
; block $81
;
phase	$8000
MapsBlockAW03:  equ   $81 | MapAW03: incbin "..\maps\AW03.map.pck"  | include "..\maps\mapdata\AW03.asm"  
MapsBlockAW04:  equ   $81 | MapAW04: incbin "..\maps\AW04.map.pck"  | include "..\maps\mapdata\AW04.asm"  
MapsBlockAW05:  equ   $81 | MapAW05: incbin "..\maps\AW05.map.pck"  | include "..\maps\mapdata\AW05.asm"  
MapsBlockAW06:  equ   $81 | MapAW06: incbin "..\maps\AW06.map.pck"  | include "..\maps\mapdata\AW06.asm"  
MapsBlockAW11:  equ   $81 | MapAW11: incbin "..\maps\AW11.map.pck"  | include "..\maps\mapdata\AW11.asm"  
MapsBlockAW12:  equ   $81 | MapAW12: incbin "..\maps\AW12.map.pck"  | include "..\maps\mapdata\AW12.asm"  
MapsBlockAW13:  equ   $81 | MapAW13: incbin "..\maps\AW13.map.pck"  | include "..\maps\mapdata\AW13.asm"  
MapsBlockAW14:  equ   $81 | MapAW14: incbin "..\maps\AW14.map.pck"  | include "..\maps\mapdata\AW14.asm"  
MapsBlockAW17:  equ   $81 | MapAW17: incbin "..\maps\AW17.map.pck"  | include "..\maps\mapdata\AW17.asm"  
MapsBlockAW20:  equ   $81 | MapAW20: incbin "..\maps\AW20.map.pck"  | include "..\maps\mapdata\AW20.asm"  
MapsBlockAW24:  equ   $81 | MapAW24: incbin "..\maps\AW24.map.pck"  | include "..\maps\mapdata\AW24.asm"  
MapsBlockAW27:  equ   $81 | MapAW27: incbin "..\maps\AW27.map.pck"  | include "..\maps\mapdata\AW27.asm"  
MapsBlockAW31:  equ   $81 | MapAW31: incbin "..\maps\AW31.map.pck"  | include "..\maps\mapdata\AW31.asm"  
MapsBlockAW37:  equ   $81 | MapAW37: incbin "..\maps\AW37.map.pck"  | include "..\maps\mapdata\AW37.asm"  
MapsBlockAW38:  equ   $81 | MapAW38: incbin "..\maps\AW38.map.pck"  | include "..\maps\mapdata\AW38.asm"  
MapsBlockAW39:  equ   $81 | MapAW39: incbin "..\maps\AW39.map.pck"  | include "..\maps\mapdata\AW39.asm"  
MapsBlockAW44:  equ   $81 | MapAW44: incbin "..\maps\AW44.map.pck"  | include "..\maps\mapdata\AW44.asm"  
	ds		$c000-$,$ff
dephase

;
; block $82
;
phase	$8000
MapsBlockAX01:  equ   $82 | MapAX01: incbin "..\maps\AX01.map.pck"  | include "..\maps\mapdata\AX01.asm"  
MapsBlockAX08:  equ   $82 | MapAX08: incbin "..\maps\AX08.map.pck"  | include "..\maps\mapdata\AX08.asm"  
MapsBlockAX09:  equ   $82 | MapAX09: incbin "..\maps\AX09.map.pck"  | include "..\maps\mapdata\AX09.asm"  
MapsBlockAX10:  equ   $82 | MapAX10: incbin "..\maps\AX10.map.pck"  | include "..\maps\mapdata\AX10.asm"  
MapsBlockAX17:  equ   $82 | MapAX17: incbin "..\maps\AX17.map.pck"  | include "..\maps\mapdata\AX17.asm"  
MapsBlockAX20:  equ   $82 | MapAX20: incbin "..\maps\AX20.map.pck"  | include "..\maps\mapdata\AX20.asm"  
MapsBlockAX24:  equ   $82 | MapAX24: incbin "..\maps\AX24.map.pck"  | include "..\maps\mapdata\AX24.asm"  
MapsBlockAX27:  equ   $82 | MapAX27: incbin "..\maps\AX27.map.pck"  | include "..\maps\mapdata\AX27.asm"  
MapsBlockAX31:  equ   $82 | MapAX31: incbin "..\maps\AX31.map.pck"  | include "..\maps\mapdata\AX31.asm"  
MapsBlockAX32:  equ   $82 | MapAX32: incbin "..\maps\AX32.map.pck"  | include "..\maps\mapdata\AX32.asm"  
MapsBlockAX33:  equ   $82 | MapAX33: incbin "..\maps\AX33.map.pck"  | include "..\maps\mapdata\AX33.asm"  
MapsBlockAX34:  equ   $82 | MapAX34: incbin "..\maps\AX34.map.pck"  | include "..\maps\mapdata\AX34.asm"  
MapsBlockAX36:  equ   $82 | MapAX36: incbin "..\maps\AX36.map.pck"  | include "..\maps\mapdata\AX36.asm"  
MapsBlockAX37:  equ   $82 | MapAX37: incbin "..\maps\AX37.map.pck"  | include "..\maps\mapdata\AX37.asm"  
MapsBlockAX44:  equ   $82 | MapAX44: incbin "..\maps\AX44.map.pck"  | include "..\maps\mapdata\AX44.asm"  
	ds		$c000-$,$ff
dephase

;
; block $83
;
phase	$8000
MapsBlockAY01:  equ   $83 | MapAY01: incbin "..\maps\AY01.map.pck"  | include "..\maps\mapdata\AY01.asm"  
MapsBlockAY02:  equ   $83 | MapAY02: incbin "..\maps\AY02.map.pck"  | include "..\maps\mapdata\AY02.asm"  
MapsBlockAY03:  equ   $83 | MapAY03: incbin "..\maps\AY03.map.pck"  | include "..\maps\mapdata\AY03.asm"  
MapsBlockAY06:  equ   $83 | MapAY06: incbin "..\maps\AY06.map.pck"  | include "..\maps\mapdata\AY06.asm"  
MapsBlockAY08:  equ   $83 | MapAY08: incbin "..\maps\AY08.map.pck"  | include "..\maps\mapdata\AY08.asm"  
MapsBlockAY20:  equ   $83 | MapAY20: incbin "..\maps\AY20.map.pck"  | include "..\maps\mapdata\AY20.asm"  
MapsBlockAY21:  equ   $83 | MapAY21: incbin "..\maps\AY21.map.pck"  | include "..\maps\mapdata\AY21.asm"  
MapsBlockAY22:  equ   $83 | MapAY22: incbin "..\maps\AY22.map.pck"  | include "..\maps\mapdata\AY22.asm"  
MapsBlockAY23:  equ   $83 | MapAY23: incbin "..\maps\AY23.map.pck"  | include "..\maps\mapdata\AY23.asm"  
MapsBlockAY24:  equ   $83 | MapAY24: incbin "..\maps\AY24.map.pck"  | include "..\maps\mapdata\AY24.asm"  
MapsBlockAY25:  equ   $83 | MapAY25: incbin "..\maps\AY25.map.pck"  | include "..\maps\mapdata\AY25.asm"  
MapsBlockAY26:  equ   $83 | MapAY26: incbin "..\maps\AY26.map.pck"  | include "..\maps\mapdata\AY26.asm"  
MapsBlockAY27:  equ   $83 | MapAY27: incbin "..\maps\AY27.map.pck"  | include "..\maps\mapdata\AY27.asm"  
MapsBlockAY28:  equ   $83 | MapAY28: incbin "..\maps\AY28.map.pck"  | include "..\maps\mapdata\AY28.asm"  
MapsBlockAY29:  equ   $83 | MapAY29: incbin "..\maps\AY29.map.pck"  | include "..\maps\mapdata\AY29.asm"  
MapsBlockAY30:  equ   $83 | MapAY30: incbin "..\maps\AY30.map.pck"  | include "..\maps\mapdata\AY30.asm"  
MapsBlockAY31:  equ   $83 | MapAY31: incbin "..\maps\AY31.map.pck"  | include "..\maps\mapdata\AY31.asm"  
MapsBlockAY34:  equ   $83 | MapAY34: incbin "..\maps\AY34.map.pck"  | include "..\maps\mapdata\AY34.asm"  
MapsBlockAY35:  equ   $83 | MapAY35: incbin "..\maps\AY35.map.pck"  | include "..\maps\mapdata\AY35.asm"  
MapsBlockAY36:  equ   $83 | MapAY36: incbin "..\maps\AY36.map.pck"  | include "..\maps\mapdata\AY36.asm"  
	ds		$c000-$,$ff
dephase

;
; block $84
;
phase	$8000
MapsBlockAZ02:  equ   $84 | MapAZ02: incbin "..\maps\AZ02.map.pck"  | include "..\maps\mapdata\AZ02.asm"  
MapsBlockAZ03:  equ   $84 | MapAZ03: incbin "..\maps\AZ03.map.pck"  | include "..\maps\mapdata\AZ03.asm"  
MapsBlockAZ04:  equ   $84 | MapAZ04: incbin "..\maps\AZ04.map.pck"  | include "..\maps\mapdata\AZ04.asm"  
MapsBlockAZ05:  equ   $84 | MapAZ05: incbin "..\maps\AZ05.map.pck"  | include "..\maps\mapdata\AZ05.asm"  
MapsBlockAZ06:  equ   $84 | MapAZ06: incbin "..\maps\AZ06.map.pck"  | include "..\maps\mapdata\AZ06.asm"  
MapsBlockAZ07:  equ   $84 | MapAZ07: incbin "..\maps\AZ07.map.pck"  | include "..\maps\mapdata\AZ07.asm"  
MapsBlockAZ08:  equ   $84 | MapAZ08: incbin "..\maps\AZ08.map.pck"  | include "..\maps\mapdata\AZ08.asm"  
MapsBlockAZ09:  equ   $84 | MapAZ09: incbin "..\maps\AZ09.map.pck"  | include "..\maps\mapdata\AZ09.asm"  
MapsBlockAZ21:  equ   $84 | MapAZ21: incbin "..\maps\AZ21.map.pck"  | include "..\maps\mapdata\AZ21.asm"  
MapsBlockAZ23:  equ   $84 | MapAZ23: incbin "..\maps\AZ23.map.pck"  | include "..\maps\mapdata\AZ23.asm"  
MapsBlockAZ24:  equ   $84 | MapAZ24: incbin "..\maps\AZ24.map.pck"  | include "..\maps\mapdata\AZ24.asm"  
MapsBlockAZ27:  equ   $84 | MapAZ27: incbin "..\maps\AZ27.map.pck"  | include "..\maps\mapdata\AZ27.asm"  
MapsBlockAZ31:  equ   $84 | MapAZ31: incbin "..\maps\AZ31.map.pck"  | include "..\maps\mapdata\AZ31.asm"  
MapsBlockAZ43:  equ   $84 | MapAZ43: incbin "..\maps\AZ43.map.pck"  | include "..\maps\mapdata\AZ43.asm"  
MapsBlockAZ45:  equ   $84 | MapAZ45: incbin "..\maps\AZ45.map.pck"  | include "..\maps\mapdata\AZ45.asm"  
MapsBlockAZ47:  equ   $84 | MapAZ47: incbin "..\maps\AZ47.map.pck"  | include "..\maps\mapdata\AZ47.asm"  
MapsBlockAZ49:  equ   $84 | MapAZ49: incbin "..\maps\AZ49.map.pck"  | include "..\maps\mapdata\AZ49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $85
;
phase	$8000
MapsBlockBA01:  equ   $85 | MapBA01: incbin "..\maps\BA01.map.pck"  | include "..\maps\mapdata\BA01.asm"  
MapsBlockBA02:  equ   $85 | MapBA02: incbin "..\maps\BA02.map.pck"  | include "..\maps\mapdata\BA02.asm"  
MapsBlockBA03:  equ   $85 | MapBA03: incbin "..\maps\BA03.map.pck"  | include "..\maps\mapdata\BA03.asm"  
MapsBlockBA06:  equ   $85 | MapBA06: incbin "..\maps\BA06.map.pck"  | include "..\maps\mapdata\BA06.asm"  
MapsBlockBA08:  equ   $85 | MapBA08: incbin "..\maps\BA08.map.pck"  | include "..\maps\mapdata\BA08.asm"  
MapsBlockBA19:  equ   $85 | MapBA19: incbin "..\maps\BA19.map.pck"  | include "..\maps\mapdata\BA19.asm"  
MapsBlockBA20:  equ   $85 | MapBA20: incbin "..\maps\BA20.map.pck"  | include "..\maps\mapdata\BA20.asm"  
MapsBlockBA21:  equ   $85 | MapBA21: incbin "..\maps\BA21.map.pck"  | include "..\maps\mapdata\BA21.asm"  
MapsBlockBA24:  equ   $85 | MapBA24: incbin "..\maps\BA24.map.pck"  | include "..\maps\mapdata\BA24.asm"  
MapsBlockBA27:  equ   $85 | MapBA27: incbin "..\maps\BA27.map.pck"  | include "..\maps\mapdata\BA27.asm"  
MapsBlockBA31:  equ   $85 | MapBA31: incbin "..\maps\BA31.map.pck"  | include "..\maps\mapdata\BA31.asm"  
MapsBlockBA32:  equ   $85 | MapBA32: incbin "..\maps\BA32.map.pck"  | include "..\maps\mapdata\BA32.asm"  
MapsBlockBA33:  equ   $85 | MapBA33: incbin "..\maps\BA33.map.pck"  | include "..\maps\mapdata\BA33.asm"  
MapsBlockBA34:  equ   $85 | MapBA34: incbin "..\maps\BA34.map.pck"  | include "..\maps\mapdata\BA34.asm"  
MapsBlockBA35:  equ   $85 | MapBA35: incbin "..\maps\BA35.map.pck"  | include "..\maps\mapdata\BA35.asm"  
MapsBlockBA36:  equ   $85 | MapBA36: incbin "..\maps\BA36.map.pck"  | include "..\maps\mapdata\BA36.asm"  
MapsBlockBA37:  equ   $85 | MapBA37: incbin "..\maps\BA37.map.pck"  | include "..\maps\mapdata\BA37.asm"  
MapsBlockBA39:  equ   $85 | MapBA39: incbin "..\maps\BA39.map.pck"  | include "..\maps\mapdata\BA39.asm"  
MapsBlockBA40:  equ   $85 | MapBA40: incbin "..\maps\BA40.map.pck"  | include "..\maps\mapdata\BA40.asm"  
MapsBlockBA41:  equ   $85 | MapBA41: incbin "..\maps\BA41.map.pck"  | include "..\maps\mapdata\BA41.asm"  
MapsBlockBA43:  equ   $85 | MapBA43: incbin "..\maps\BA43.map.pck"  | include "..\maps\mapdata\BA43.asm"  
MapsBlockBA44:  equ   $85 | MapBA44: incbin "..\maps\BA44.map.pck"  | include "..\maps\mapdata\BA44.asm"  
MapsBlockBA45:  equ   $85 | MapBA45: incbin "..\maps\BA45.map.pck"  | include "..\maps\mapdata\BA45.asm"  
MapsBlockBA46:  equ   $85 | MapBA46: incbin "..\maps\BA46.map.pck"  | include "..\maps\mapdata\BA46.asm"  
MapsBlockBA47:  equ   $85 | MapBA47: incbin "..\maps\BA47.map.pck"  | include "..\maps\mapdata\BA47.asm"  
MapsBlockBA48:  equ   $85 | MapBA48: incbin "..\maps\BA48.map.pck"  | include "..\maps\mapdata\BA48.asm"  
MapsBlockBA49:  equ   $85 | MapBA49: incbin "..\maps\BA49.map.pck"  | include "..\maps\mapdata\BA49.asm"  
	ds		$c000-$,$ff
dephase

;
; block $86
;
phase	$8000
MapsBlockBB01:  equ   $86 | MapBB01: incbin "..\maps\BB01.map.pck"  | include "..\maps\mapdata\BB01.asm"  
MapsBlockBB06:  equ   $86 | MapBB06: incbin "..\maps\BB06.map.pck"  | include "..\maps\mapdata\BB06.asm"  
MapsBlockBB08:  equ   $86 | MapBB08: incbin "..\maps\BB08.map.pck"  | include "..\maps\mapdata\BB08.asm"  
MapsBlockBB09:  equ   $86 | MapBB09: incbin "..\maps\BB09.map.pck"  | include "..\maps\mapdata\BB09.asm"  
MapsBlockBB10:  equ   $86 | MapBB10: incbin "..\maps\BB10.map.pck"  | include "..\maps\mapdata\BB10.asm"  
MapsBlockBB21:  equ   $86 | MapBB21: incbin "..\maps\BB21.map.pck"  | include "..\maps\mapdata\BB21.asm"  
MapsBlockBB23:  equ   $86 | MapBB23: incbin "..\maps\BB23.map.pck"  | include "..\maps\mapdata\BB23.asm"  
MapsBlockBB24:  equ   $86 | MapBB24: incbin "..\maps\BB24.map.pck"  | include "..\maps\mapdata\BB24.asm"  
MapsBlockBB27:  equ   $86 | MapBB27: incbin "..\maps\BB27.map.pck"  | include "..\maps\mapdata\BB27.asm"  
MapsBlockBB33:  equ   $86 | MapBB33: incbin "..\maps\BB33.map.pck"  | include "..\maps\mapdata\BB33.asm"  
MapsBlockBB37:  equ   $86 | MapBB37: incbin "..\maps\BB37.map.pck"  | include "..\maps\mapdata\BB37.asm"  
MapsBlockBB38:  equ   $86 | MapBB38: incbin "..\maps\BB38.map.pck"  | include "..\maps\mapdata\BB38.asm"  
MapsBlockBB39:  equ   $86 | MapBB39: incbin "..\maps\BB39.map.pck"  | include "..\maps\mapdata\BB39.asm"  
MapsBlockBB41:  equ   $86 | MapBB41: incbin "..\maps\BB41.map.pck"  | include "..\maps\mapdata\BB41.asm"  
MapsBlockBB49:  equ   $86 | MapBB49: incbin "..\maps\BB49.map.pck"  | include "..\maps\mapdata\BB49.asm"  
	ds		$c000-$,$ff
dephase





































;##################### GRAPHICS #####################
;##################### GRAPHICS #####################
;##################### GRAPHICS #####################
;##################### GRAPHICS #####################
;##################### GRAPHICS #####################

;
; block $87 - $88
;
VoodooWaspTilesBlock:  equ   $87
phase	$4000
  incbin "..\grapx\tilesheets\sVoodooWasp.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sVoodooWaspBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $89 - $8a
;
GoddessTilesBlock:  equ   $89
phase	$4000
  incbin "..\grapx\tilesheets\sGoddess.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sGoddessBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $8b - $8c
;
KarniMataTilesBlock:  equ   $8b
phase	$4000
  incbin "..\grapx\tilesheets\sKarniMata.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sKarniMataBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $8d - $8e
;
BlueTempleTilesBlock:  equ   $8d
phase	$4000
  incbin "..\grapx\tilesheets\sBlueTemple.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sBlueTempleBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $8f - $90
;
KonarkTilesBlock:  equ   $8f
phase	$4000
  incbin "..\grapx\tilesheets\sKonark.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sKonarkBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $91 - $92
;
BurialTilesBlock:  equ   $91
phase	$4000
  incbin "..\grapx\tilesheets\sBurial.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sBurialBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $93
;
Graphicsblock4:  equ   $93
phase	$8000
itemsKarniMataPage3:
  incbin "..\grapx\itemsKarniMataPage3.SC5",7,128 * 40 ;skip header, 40 lines
	ds		$c000-$,$ff
dephase

;
; block $94
;

  ds  $4000

;
; block $95 - $96
;
TeamNXTLogoTransparantGraphicsblock:  equ   $95
phase	$4000
  incbin "..\grapx\TeamNXTLogo\TransparantBlocks.SC5",7,200*128  ;skip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

;
; block $97 - $98
;
TeamNXTLogoNonTransparantGraphicsblock:  equ   $97
phase	$4000
  incbin "..\grapx\TeamNXTLogo\NonTransparantBlocks.SC5",7,200*128  ;kip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

;
; block $99 - $9a
;
BossAreaTilesBlock:  equ   $99
phase	$4000
  incbin "..\grapx\tilesheets\sBossArea.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sBossAreaBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $9b - $9c
;
F1MenuGraphicsBlock:  equ   $9b
phase	$4000
  incbin "..\grapx\F1Menu\F1Menu.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

;
; block $9d - $9e
;
PrimaryWeaponSelectGraphicsBlock:  equ   $9d
phase	$4000
  incbin "..\grapx\F1Menu\PrimaryWeaponSelectScreen.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

;
; block $9f - $a0
;
IceTempleTilesBlock:  equ   $9f
phase	$4000
  incbin "..\grapx\tilesheets\sIceTemple.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sIceTempleBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

;
; block $a1
;
NPCDialogueFontBlock:  equ   $a1
phase	$4000
;NPCDialogueFontAddress:
;  incbin "..\grapx\font\NPCDialogueFont.SC5",7,016 * 128      ;016 lines
NPCDialogueFontAndBackgroundAddress:
  incbin "..\grapx\font\FontAndBackground.SC5",7,075 * 128      ;068 lines
	ds		$8000-$,$ff
dephase

;
; block $a2
;
CharacterPortraitsBlock:  equ   $a2
phase	$4000
CharacterPortraits:
  incbin "..\grapx\font\CharacterPortraits.SC5",7,056 * 128      ;016 lines
	ds		$8000-$,$ff
dephase

;
; block $a3
;
WorldMapDataCopiedToRamBlock:  equ   $a3
phase	$8000
  include "WorldMapDataCopiedToRam.asm"
	ds		$c000-$,$ff
dephase



; block $a4 - $b4
  ds  $4000 * $11











; block $b5
BossGoatIdleAndWalkframelistblock:            equ $b5
phase	$8000
  include "..\grapx\BossGoat\IdleAndWalk\frames.lst" 
	ds		$c000-$,$ff

; block $b6
BossGoatIdleAndWalkspritedatablock:           equ $b6
phase	$0000
  incbin "..\grapx\BossGoat\IdleAndWalk\frames.dat"
	ds		$4000-$,$ff
dephase

; block $b7
BossGoatWalkAndAttackframelistblock:            equ $b7
phase	$8000
  include "..\grapx\BossGoat\WalkAndAttack\frames.lst" 
	ds		$c000-$,$ff

; block $b8
BossGoatWalkAndAttackspritedatablock:           equ $b8
phase	$0000
  incbin "..\grapx\BossGoat\WalkAndAttack\frames.dat"
	ds		$4000-$,$ff
dephase

; block $b9
BossGoatAttackframelistblock:            equ $b9
phase	$8000
  include "..\grapx\BossGoat\Attack\frames.lst" 
	ds		$c000-$,$ff

; block $ba
BossGoatAttackspritedatablock:           equ $ba
phase	$0000
  incbin "..\grapx\BossGoat\Attack\frames.dat"
	ds		$4000-$,$ff
dephase

; block $bb
BossGoatAttack2framelistblock:            equ $bb
phase	$8000
  include "..\grapx\BossGoat\Attack2\frames.lst" 
	ds		$c000-$,$ff

; block $bc
BossGoatAttack2spritedatablock:           equ $bc
phase	$0000
  incbin "..\grapx\BossGoat\Attack2\frames.dat"
	ds		$4000-$,$ff
dephase

; block $bd
BossGoatAttackAndHitframelistblock:            equ $bd
phase	$8000
  include "..\grapx\BossGoat\AttackAndHit\frames.lst" 
	ds		$c000-$,$ff

; block $be
BossGoatAttackAndHitspritedatablock:           equ $be
phase	$0000
  incbin "..\grapx\BossGoat\AttackAndHit\frames.dat"
	ds		$4000-$,$ff
dephase





; block $bf
BossGoatDyingframelistblock:            equ $bf
phase	$8000
  include "..\grapx\BossGoat\Dying\frames.lst" 
	ds		$c000-$,$ff

; block $c0
BossGoatDyingspritedatablock:           equ $c0
phase	$0000
  incbin "..\grapx\BossGoat\Dying\frames.dat"
	ds		$4000-$,$ff
dephase

; block $c1
BossGoatDying2framelistblock:            equ $c1
phase	$8000
  include "..\grapx\BossGoat\Dying2\frames.lst" 
	ds		$c000-$,$ff

; block $c2
BossGoatDying2spritedatablock:           equ $c2
phase	$0000
  incbin "..\grapx\BossGoat\Dying2\frames.dat"
	ds		$4000-$,$ff
dephase





; block $c3
;CharacterFacesframelistblock:            equ $c3
phase	$8000
;  include "..\grapx\CharacterFaces\frames.lst" 
	ds		$c000-$,$ff

; block $c4
;CharacterFacesspritedatablock:           equ $c4
phase	$0000
;  incbin "..\grapx\CharacterFaces\frames.dat"
	ds		$4000-$,$ff
dephase

; block $c5
ryuframelistblock:            equ $c5
phase	$8000
  include "..\grapx\ryu\spritesryuPage0\frames.lst" 
	ds		$c000-$,$ff
dephase
; block $c6
BossDemonframelistblock:            equ $c6
phase	$8000
  include "..\grapx\ryu\spritesryuPage1\frames.lst" 
	ds		$c000-$,$ff
dephase
; block $c7
BossDemonframelistblock2:            equ $c7
phase	$8000
  include "..\grapx\ryu\spritesryuPage2\frames.lst" 
	ds		$c000-$,$ff
dephase
; block $c8
BossDemonframelistblock3:            equ $c8
phase	$8000
  include "..\grapx\ryu\spritesryuPage3\frames.lst" 
	ds		$c000-$,$ff
dephase
; block $c9
BossDemonframelistblock4:            equ $c9
phase	$8000
  include "..\grapx\ryu\spritesryuPage4\frames.lst" 
	ds		$c000-$,$ff
dephase


; block $ca
ryuspritedatablock:           equ $ca
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage0\frames.dat"
	ds		$4000-$,$ff
dephase
; block $cb
BossDemonspritedatablock:           equ $cb
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage1\frames.dat"
	ds		$4000-$,$ff
dephase
; block $cc
BossDemonspritedatablock2:           equ $cc
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage2\frames.dat"
	ds		$4000-$,$ff
dephase
; block $cd
BossDemonspritedatablock3:           equ $cd
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage3\frames.dat"
	ds		$4000-$,$ff
dephase
; block $ce
BossDemonspritedatablock4:           equ $ce
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage4\frames.dat"
	ds		$4000-$,$ff
dephase

; block $cf
BossRoomframelistblock:            equ $cf
phase	$8000
  include "..\grapx\BossRoom\frames.lst" 
	ds		$c000-$,$ff

; block $d0
BossRoomspritedatablock:           equ $d0
phase	$0000
  incbin "..\grapx\BossRoom\frames.dat"
	ds		$4000-$,$ff
dephase

; block $d1
AreaSignsframelistblock:            equ $d1
phase	$8000
  include "..\grapx\AreaSigns\frames.lst" 
	ds		$c000-$,$ff

; block $d2
AreaSignsspritedatablock:           equ $d2
phase	$0000
  incbin "..\grapx\AreaSigns\frames.dat"
	ds		$4000-$,$ff
dephase




; block $d3
BossVoodooWaspIdleframelistblock:            equ $d3
phase	$8000
  include "..\grapx\BossVoodooWasp\Idle\frames.lst" 
	ds		$c000-$,$ff

; block $d4
BossVoodooWaspIdlespritedatablock:           equ $d4
phase	$0000
  incbin "..\grapx\BossVoodooWasp\Idle\frames.dat"
	ds		$4000-$,$ff
dephase

; block $d5
BossVoodooWaspHitframelistblock:            equ $d5
phase	$8000
  include "..\grapx\BossVoodooWasp\Hit\frames.lst" 
	ds		$c000-$,$ff

; block $d6
BossVoodooWaspHitspritedatablock:           equ $d6
phase	$0000
  incbin "..\grapx\BossVoodooWasp\Hit\frames.dat"
	ds		$4000-$,$ff
dephase



; block $d7
BossZombieCaterpillarIdleframelistblock:            equ $d7
phase	$8000
  include "..\grapx\BossZombieCaterpillar\Idle\frames.lst" 
	ds		$c000-$,$ff

; block $d8
BossZombieCaterpillarIdlespritedatablock:           equ $d8
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\Idle\frames.dat"
	ds		$4000-$,$ff
dephase

; block $d9
BossZombieCaterpillarAttackframelistblock:            equ $d9
phase	$8000
  include "..\grapx\BossZombieCaterpillar\attack\frames.lst" 
	ds		$c000-$,$ff

; block $da
BossZombieCaterpillarAttackspritedatablock:           equ $da
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\attack\frames.dat"
	ds		$4000-$,$ff
dephase

; block $db
BossZombieCaterpillarDyingPart1framelistblock:            equ $db
phase	$8000
  include "..\grapx\BossZombieCaterpillar\DyingPart1\frames.lst" 
	ds		$c000-$,$ff

; block $dc
BossZombieCaterpillarDyingPart1spritedatablock:           equ $dc
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\DyingPart1\frames.dat"
	ds		$4000-$,$ff
dephase

; block $dd
BossZombieCaterpillarDyingPart2framelistblock:            equ $dd
phase	$8000
  include "..\grapx\BossZombieCaterpillar\DyingPart2\frames.lst" 
	ds		$c000-$,$ff

; block $de
BossZombieCaterpillarDyingPart2spritedatablock:           equ $de
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\DyingPart2\frames.dat"
	ds		$4000-$,$ff
dephase








;
; block $df -----------------> Music
;
usas2repBlock:  equ   $df
  incbin "usas2.rep"
	ds		-$ and $3fff,$ff  ; pad to next multiple of $4000



totallenght:	Equ	$-Usas2
	ds		(8*$80000)-totallenght
