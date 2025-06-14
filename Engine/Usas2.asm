		fname	"..\Usas2.rom",0	;Append code to existing Usas2.Rom file

;Debug stuff
LoadSamples?: equ 1
MusicOn?:   equ 1
LogoOn?:    equ 0
PlayerCanJumpThroughTopOfScreen?: equ 0

; GLobals
RomSize: 				equ 8*1024*1024 ;8MB
RomBlockSize:			equ 16*1024	;16KB
RomStartAddress:		equ $4000
RomBlockLayout:	equ 0
.Base: EQU 0
.Game: EQU 1
.CutScene: EQU 9
.AnchoredData: EQU 13
.FloatingData: EQU 128
.VGM: EQU 256
.Misc: EQU 384

engaddr:				equ	$03e
loaderAddress:			equ	$4000
enginepage3addr:		equ	$c000
f1MenuAddress:			equ	$4000
PlayerMovementRoutinesAddress:	equ $4000
MovementPatterns1Address:	equ $8000
movementpatterns2Address:	equ $8000
MovementPatternsFixedPage1Address:	equ $4000
teamNXTlogoAddress:		equ $8000

DSM:					equ 0
.segmentSize:			equ 128
.blockSize:				equ 16*1024
.firstBlock:			equ 128 ;0xb7
.numBlocks:				equ 128 ;73
.indexBlock:			equ 0	;offset of firstblock
.indexBaseAdr:			equ 0x0000 ;offset in page

worldMapIndex:			equ 0
.block:					equ dsm.firstblock+dsm.indexblock
.adr:					equ dsm.indexBaseAdr
.numRec:				equ 1024
.recLen:				equ 4

dataTypeIndex:			equ 0
.dsmSegment:			equ 32
.block:					equ dsm.firstblock+dsm.indexblock
.Adr:					equ dsm.indexBaseAdr +.dsmSegment*dsm.segmentSize
.numRec:				equ 32
.reclen:				equ 2

dataType: EQU 0
.default: EQU 0
.Tileset: EQU 1
.Palette: EQU 2
.TiledMap: EQU 3
.Room: EQU 4
.RoomPacked: EQU 5
.TiledTileSet: EQU 6
.TiledTileSetImage: EQU 7
.ImageSc5: EQU 8
.ImageBmp: EQU 9
.areasignpacked: EQU 10

ruinId:					equ 0
.Polux: EQU 1
.Lemniscate: EQU 2
.BosStenenWater: EQU 3
.Pegu: EQU 4
.Bio: EQU 5
.KarniMata: EQU 6
.Konark: EQU 7
.Verhakselaar: EQU 8
.Taxilla: EQU 9
.EuderusSet: EQU 10
.Akna: EQU 11
.Fate: EQU 12
.Sepa: EQU 13
.undefined14: EQU 14
.Chi: EQU 15
.Sui: EQU 16
.Grot: EQU 17
.Tiwanaku: EQU 18
.Aggayu: EQU 19
.Ka: EQU 20
.Genbu: EQU 21
.Fuu: EQU 22
.Indra: EQU 23
.Morana: EQU 24



; ##### MAIN #####
	org		RomStartAddress
Usas2:		dw	"AB",init,0,0,0,0,0,0

; this is one-time only... can be overwritten with game stuff after it's done
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
	
	; The engine only does primary slot selection via I/O port $a8.
	; To still support having the game ROM and/or RAM in subslots,
	; it pre-sets the subslot for RAM and ROM in the secondary slot
	; register by enabling them once through the BIOS, which will
	; set up the secondary slot register appropriately.
	; Note: The game ROM and RAM can not be in the same primary slot.
	ld		a,(page2ram)
	ld		h,$80  ; pre-set RAM secondary slot register in page 2
	call	$24
	
	ld		a,(romSlot)
	ld		h,$80  ; pre-set ROM secondary slot register in page 2
	call	$24
	
	ld		a,(page1ram)
	ld		h,$40  ; pre-set RAM secondary slot register in page 1
	call	$24
	
	ld		a,(romSlot)
	ld		h,$40  ; pre-set ROM secondary slot register in page 1
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

; Initialize USAS2
init:
;init video
		ld    a,15        	;black
		ld		($f3e9),A	;foreground color 
		ld		($f3ea),a	;background color 
		ld		($f3eb),a	;border color

		; ld    a,15        ;start write to this palette color (15)
		; di
		; out		($99),a
		; ld		a,16+128
		; out		($99),a
		; xor		a
		; out		($9a),a
		; ei
		; out		($9a),a

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

;SpriteInitialize:
		ld		a,(vdp_0+1)
		or		2			;sprites 16*16
		ld		(vdp_0+1),a
		di
		out		($99),a
		ld		a,1+128
		ei
		out		($99),a

;init memory
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
	ld		hl,tempisr		;set LNI
	ld		de,$38
	ld		bc,6
	ldir

	ld		hl,engine	;move code to page 0
	ld		de,engaddr
	ld		bc,enlength
	ldir

	ld		hl,enginepage3	;move code to page 3
	ld		de,enginepage3addr
	ld		bc,enginepage3length
	ldir

;  call  enablesupermarioworldinterrupt
;	ld		a,loaderblock
;	call	block34			        ;at address $8000 / page 2
;  jp    $8000 ;loader.address      ;set loader in page 2 and jp to it

if MusicOn?
	call  initializeVGMRePlay
endif
if LogoOn?
  jp    PlayLogo
endif
	jp startThegame


; temp ISR
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


;[CODE blocks]
;  boot, enginepage3, enginepage0
engineRomBlock: 			equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
EnginePage3RomStartAddress:	equ $-RomStartAddress
enginepage3:				include	"enginepage3.asm"
enginepage3RomEndAddress:	EQU $-1-RomStartAddress
EnginePage0RomStartAddress:	equ $-RomStartAddress
engine:						include	"engine.asm"	
enginepage0RomEndAddress: 	equ $-1-RomStartAddress
;							ds	2*RomBlockSize - $ and $3fff,$ff		; fill remainder of blocks 00-01
engineRomBlockLength:		equ $-RomStartAddress-EnginePage3RomStartAddress
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

F1Menublock:				equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$02
f1MenuRomStartAddress:		equ $-RomStartAddress
							include	"F1Menu.asm"	
; f1MenuRomEndAddress:		equ $-1-RomStartAddress
; f1MenuBlockLength:			equ $-RomStartAddress-f1MenuRomStartAddress
;							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
F2Menublock:				equ F1Menublock ;($-RomStartAddress) and (romsize-1) /RomBlockSize ;$02
; f2MenuRomStartAddress:		equ $-RomStartAddress
							include	"F2Menu.asm"	
f2MenuRomEndAddress:		equ $-1-RomStartAddress
; f2MenuBlockLength:			equ $-RomStartAddress-f2MenuRomStartAddress
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

Loaderblock:  				equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$03
loaderRomStartAddress:		equ $-RomStartAddress
							include	"loader.asm"
loaderRomEndAddress:		equ $-1-loaderAddress
loaderBlockLength:			equ $-RomStartAddress-loaderRomStartAddress
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

PlayerMovementRoutinesBlock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$04
PlayerMovementRomStartAddress:	equ $-RomStartAddress
								include "PlayerMovementRoutines.asm"  
PlayerMovementBlockLength:		equ $-RomStartAddress-PlayerMovementRomStartAddress
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

movementpatterns1block:			equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$05
movementPat1RomStartAddress:	equ $-RomStartAddress
								include "MovementPatterns1.asm"
movementPat1BlockLength:		equ $-RomStartAddress-movementPat1RomStartAddress
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

MovementPatternsFixedPage1block:	equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$6
movementPatFixedRomStartAddress:	equ $-RomStartAddress
									include "MovementPatternsFixedPage1.asm"
movementPatFixedBlockLength:		equ $-RomStartAddress-movementPatFixedRomStartAddress
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

movementpatterns2block:			equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$7
movementPat2RomStartAddress:	equ $-RomStartAddress
								include "MovementPatterns2.asm"
movementPat2BlockLength:		equ $-RomStartAddress-movementPat2RomStartAddress
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Skip block to #9
forg RomBlockLayout.CutScene*romblocksize | org RomBlockLayout.CutScene*romblocksize+RomStartAddress
teamNXTlogoblock:			equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$8
teamNXTlogoRomStartAddress:	equ $-RomStartAddress
							phase	teamNXTlogoAddress
							include "teamNXTlogo.asm"
							dephase
teamNXTlogoBlockLength:		equ $-RomStartAddress-teamNXTlogoRomStartAddress
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


;Skip block to #13
forg RomBlockLayout.AnchoredData*romblocksize | org RomBlockLayout.AnchoredData*romblocksize+RomStartAddress

;[GFX blocks]
GraphicsSc5DataStartBlock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ; $60
GraphicsSc5DataRomStartAddress:	equ $-RomStartAddress
								include "GraphicsSc5Data.asm"
GraphicsSc5DataBlockLength:		equ $-RomStartAddress-GraphicsSc5DataRomStartAddress

SpriteDataStartBlock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ; $7c
SpriteDataRomStartAddress:	equ $-RomStartAddress
							include "SpriteData.asm"
SpriteDataBlockLength:		equ $-RomStartAddress-SpriteDataRomStartAddress

BossSpritesDataStartBlock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
BossSpritesDataRomStartAddress:	equ $-RomStartAddress
								include "BossSpriteData.asm"
BossSpritesDataBlockLength:		equ $-RomStartAddress-BossSpritesDataRomStartAddress


;Skip block to #256
forg RomBlockLayout.VGM*romblocksize | org RomBlockLayout.VGM*romblocksize+RomStartAddress

;[VGM blocks]
usas2sfx1repBlock:				equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
usas2sfx1repRomStartAddress:	equ $-RomStartAddress
								phase	$0000
								incbin "usas2sfx1.rep"
								dephase
usas2sfx1repBlockLength:		equ $-RomStartAddress-usas2sfx1repRomStartAddress
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

usas2sfx2repBlock:				equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
usas2sfx2repRomStartAddress:	equ $-RomStartAddress
								phase	$0000
								incbin "usas2sfx2.rep"
								dephase
usas2sfx2repBlockLength:		equ $-RomStartAddress-usas2sfx2repRomStartAddress
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

usas2repBlock:				equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
usas2repRomStartAddress:	equ $-RomStartAddress
							phase	$0000
							incbin "usas2.rep"
							dephase
usas2repBlockLength:		equ $-RomStartAddress-usas2repRomStartAddress
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


lastblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;$ and $ffc000/RomBlockSize
totallenght:	Equ	$-Usas2
