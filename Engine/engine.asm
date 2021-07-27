LevelEngine:
  ld    a,(framecounter)
  inc   a
  ld    (framecounter),a

;  ld    a,1
;  ld    hl,vblankflag
;.checkflag:
;  cp    (hl)
;  jp    nc,.checkflag

;  ld    (hl),0

;  call  putStarFoxSprite
  call  PopulateControls
  call  moveCamera                ;sets R18 and R23
  call  SetXBorderMaskingSprites
  call  putspattovram
  call  swap_spat_col_and_char_table

  ld    a,0           
  ld    hl,vblankintflag
.checkflag:
  cp    (hl)
  jr    z,.checkflag
.endcheckflag:  
  ld    (hl),0
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		6,a           ;F1 pressed ?
  jr    nz,.LoadnextMap
  
  jp    LevelEngine

.LoadnextMap:
  call  DisableLineint
  
;	.loop: jp .loop
	
  jp    loadGraphics

DisableLineint:
  di
  
; set temp ISR
	ld		hl,tempisr2
	ld		de,$38
	ld		bc,6
	ldir

  ld    a,(vdp_0)           ;set ei1
  and   %1110 1111          ;ei1 checks for lineint and vblankint
  ld    (vdp_0),a           ;ei0 (which is default at boot) only checks vblankint
;  di
  out   ($99),a
  ld    a,128
;  ei
  out   ($99),a

  ld    a,0
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  out   ($99),a
  
  ei

  ret

tempisr2:	
	push	af
	in		a,($99)             ;check and acknowledge vblank int (ei0 is set)
	pop		af
	ei	
	ret  


vblankintflag:  db  0
InterruptHandler:
  push  af
  push  bc
  push  de
  push  hl
  exx
  ex    af,af'
  push  af
  push  bc
  push  de
  push  hl
  push  ix
  
  ld    a,1               ;set s#1
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge line interrupt
  rrca
  jp    c,lineint ;lineint detected, so jp to that routine

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge vblank interrupt
  rlca
  jp    c,vblank  ;vblank detected, so jp to that routine
 
  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
  pop   af 
  ei
  ret

;on vblank we set page 2
;we set horizontal and vertical screen adjust
;we set status register 0
vblank:
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a

  ld    a,(VDP_8)         ;sprites on
  and   %11111101
  ld    (VDP_8),a
  out   ($99),a
  ld    a,8+128
  out   ($99),a

   
;  ld    a,2*32+31         ;set page 2
;  out   ($99),a
;  ld    a,2+128
;  out   ($99),a

;R#18 (register 18) uses bits 3 - 0 for horizontal screen adjust
;MSB  7   6   5   4   3   2   1   0
;R#18 v3  v2  v1  v0  h3  h2  h1  h0
;h can have a value from 0 - 15 and the screen adjusts horizontally according to the table below
;     7   6   5   4   3   2   1   0   15  14  13  12  11  10  9   8
;H  left                       centre  
;  ld    a,0               ;set horizontal screen adjust
;  out   ($99),a
;  ld    a,18+128
;  out   ($99),a

;  ld    a,0               ;set vertical screen adjust
;  out   ($99),a
;  ld    a,23+128
;  out   ($99),a

;If you have a split and are changing the vertical scrollregister (r#23) on it,
;then you should always re-set the splitline (r#19). This because the splitline
;is calculated from line 0 in the VRAM, and not from line 0 of the screen. 
;In order to set the splitline to the ‘screenline’ it’s easiest to simply add 
;the value of r#23 to it.
;  ld    a,lineintheight
;  out   ($99),a
;  ld    a,19+128            ;set lineinterrupt height
;  out   ($99),a

;  ld    a,(VDP_8)         ;sprites off
;  or    %00000010
;  ld    (VDP_8),a
;  out   ($99),a
;  ld    a,8+128
;  out   ($99),a

;  xor   a                 ;set s#0
;  out   ($99),a
;  ld    a,15+128
;  out   ($99),a

;  ld    a,1               ;lineint flag gets set
;  ld    (Worldmapvblankintflag),a  

;this flag sais we can now swap horizontal& vertical offset 
;we can swap page and we can swap sprite tables
;  ld    a,(swaptablesonvblank?)
;  or    a
;  jr    z,.end
;  call  Worldmapswap_spat_col_and_char_table

;  ld    a,(currentpage)
;  ld    (newlineintpage),a

;  ld    a,(horizontalscreenoffset)              ;prepare horizontal screen adjust for next frame
;  ld    (newlineinthoroff),a

;  ld    a,(verticalscreenoffset)               ;set vertical screen adjust
;  ld    (newlineintveroff),a
  
  ld    a,1               ;lineint flag gets set
  ld    (vblankintflag),a  

;  xor   a
;  ld    (swaptablesonvblank?),a


;.end:

  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
  pop   af 
  ei
  ret

;on the lineint we turn the screen off at the end of the line using polling for HR
;then we switch between page 0+1
;we set horizontal and vertical adjust
;and we turn screen on again at the end of the line
;we play music and set s#0 again
lineint:  
  ld    a,2               ;Set Status register #2
  out   ($99),a
  ld    a,15+128          ;we are about to check for HR
  out   ($99),a

;  ld    hl,linesplitvariables

;PREPARE ALL THESE INSTRUCTION TO BE EXECUTED WITH OUTI'S AFTER THE POLLING
;  ld    a,(newlineintpage)
;  ld    (hl),a
;  ld    a,2+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(newlineinthoroff)              ;prepare horizontal screen adjust for next frame
;  ld    (hl),a
;  ld    a,18+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(newlineintveroff)               ;set vertical screen adjust
;  ld    d,a
;  ld    (hl),a
;  ld    a,23+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,d
;  add   a,worldmaplineintheight
;  ld    (hl),a
;  ld    a,19+128            ;set lineinterrupt height  
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(VDP_0+1)       ;screen on
;  or    %0100'0000
;  ld    (hl),a
;  ld    a,1+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl
;/PREPARE ALL THESE INSTRUCTION TO BE EXECUTED WITH OUTI'S AFTER THE POLLING

;  ld    hl,linesplitvariables
;  ld    c,$99


  ;screen always gets turned on/off at the END of the line
  ld    a,(VDP_0+1)       ;screen off
  and   %1011 1111
  out   ($99),a
  ld    a,1+128
  out   ($99),a
 ;so after turning off the screen wait till the end of HBLANK, then perform actions
 
  ld    b,%0010 0000      ;bit to check for HBlank detection
.Waitline1:
  in    a,($99)           ;Read Status register #2
  and   b                 ;wait until start of HBLANK
  jr    nz,.Waitline1

.Waitline2:
  in    a,($99)           ;Read Status register #2
  and   b                 ;wait until end of HBLANK
  jr    z,.Waitline2 

  ld    a,0*32+31         ;set page 0
  out   ($99),a
  ld    a,2+128
  out   ($99),a

  ld    a,0               ;set horizontal screen adjust
  out   ($99),a
  ld    a,18+128
  out   ($99),a

  ld    a,44               ;set vertical screen adjust
  out   ($99),a
  ld    a,23+128
  out   ($99),a

  ld    a,(VDP_8)         ;sprites off
  or    %00000010
  ld    (VDP_8),a
  out   ($99),a
  ld    a,8+128
  out   ($99),a

  
.Waitline3:
;  in    a,($99)           ;Read Status register #2
;  and   b                 ;wait until end of HBLANK
;  jr    z,.Waitline3

;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi

  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a

;  ld    a,3
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  call  handlemusicint     ;handle this from page3 or else!!

;  ld    a,4
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  in    a,($a8)
;  push  af                  ;store current RAM/ROM page settings
;  ld    a,(slot.page12rom)        ;all RAM except page 1+2
;  out   ($a8),a         

;  call  handlesfxint

;  ld    a,7
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  ld a,(lineintflag)
;  inc a
;  ld (lineintflag),a

;  pop   af                  ;recall RAM/ROM page setting
;  out   ($a8),a         

  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
  pop   af 
  ei
  ret  















CameraX:          db  0
CameraY:          db  0
CameraSpeed:      db  0
HorizontalOffset: ds  1
;R#18 (register 18) uses bits 3 - 0 for horizontal screen adjust
;MSB  7   6   5   4   3   2   1   0
;R#18 v3  v2  v1  v0  h3  h2  h1  h0
;h can have a value from 0 - 15 and the screen adjusts horizontally according to the table below
;     7   6   5   4   3   2   1   0   15  14  13  12  11  10  9   8

R18ConversionTable: 
db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7

moveCamera:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
  jr    z,.endcheckSpacepressed
  ld    a,(CameraSpeed)
  inc   a
  and   7
  ld    (CameraSpeed),a
  .endcheckSpacepressed:

  ld    b,0           ;horizontal camera movent
  ld    c,0           ;vertical camera movent

  ld    a,(Controls)
	bit		3,a           ;right pressed ?
  jr    z,.endcheckRightpressed
  inc   b
  .endcheckRightpressed:
	bit		2,a           ;left pressed ?
  jr    z,.endcheckLeftpressed
  dec   b
  .endcheckLeftpressed:
	bit		1,a           ;down pressed ?
  jr    z,.endcheckDownpressed
  inc   c
  .endcheckDownpressed:
	bit		0,a           ;up pressed ?
  jr    z,.endcheckUppressed
  dec   c
  .endcheckUppressed:

  ld    a,(CameraSpeed)
  ld    d,a

  .cameraspeedloop:
  ld    a,(CameraY)
  add   a,c
  jp    m,.negativeYValue
  cp    45
  jr    nc,.maxYRangeFound
  ld    (CameraY),a
  .negativeYValue:
  .maxYRangeFound:

  ld    a,(CameraX)
  add   a,b
  jp    m,.negativeValue
  cp    64
  jr    nc,.maxRangeFound
  ld    (CameraX),a
  .negativeValue:
  .maxRangeFound:
 
  dec   d
  jp    p,.cameraspeedloop
 
  ld    a,(CameraX)
  and   %0000 1111
  ld    d,0
  ld    e,a
  ld    hl,R18ConversionTable
  add   hl,de
  ld    a,(hl)
  di
  out   ($99),a
  ld    a,18+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  di
  out   ($99),a
  ld    a,23+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  ld    b,a
  ld    a,lineintheight
  add   a,b
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  out   ($99),a


  ;set page. page 0=camerax 0-15 page 1=camerax 16-31 page 2=camerax 32-47 page 3=camerax 48-63
  ld    a,(CameraX)
  ld    b,0*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,1*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,2*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,3*32+31           ;x*32+31 (x=page)
  jp    setpage
  
;*************************************************************
; met $7f, $bf en $ff in $9000 wordt de SCC voorgeschakeld
; ascii8 blokken:
; $5000 -> $6000 -> 
; $7000 -> $6800 -> 
; $9000 -> $7000 -> 
; $b000 -> $7800 -> 
;*************************************************************

setpage:              ;in a->x*32+31 (x=page)
  ld    a,b
  ld    (currentpage),a
  di
  out   ($99),a
  ld    a,2+128
  ei
  out   ($99),a
  ret

block1:
	di
	ld    (memblocks.1),a
	ld    ($5000),a
	ei
	ret

block2:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	ei
	ret

block3:		
	di
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block4:		
	di
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

block12:	
	di
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	ei
	ret

block23:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block34:	
	di
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

block123:	
	di
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block234:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

block1234:	 
  di
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
	ei
	ret

swap_spat_col_and_char_table:
	ld		a,(vdp_0+6)     ;check current sprite character table
  cp    %0010 1111      ;spr chr table at $17800 now ?
  ld    hl,$6c00        ;spr color table $16c00
  ld    de,$7400        ;spr color table buffer $17400
	ld		a,%1101 1111    ;spr att table to $16e00    
	ld		b,%0010 1110    ;spr chr table to $17000
  jp    z,.setspritetables
  ld    hl,$7400        ;spr color table $17400
  ld    de,$6c00        ;spr color table buffer $16c00
	ld		a,%1110 1111    ;spr att table to $17600
	ld		b,%0010 1111    ;spr chr table to $17800

.setspritetables:
	di
	ld		(vdp_0+5),a
	out		($99),a		;spr att table to $17600
	ld		a,5+128
	out		($99),a
	ld		a,$02     ;%0000 0010
	ld		(vdp_8+3),a
	out		($99),a
	ld		a,11+128
	out		($99),a
	
	ld		a,b
	ld		(vdp_0+6),a
	out		($99),a		;spr chr table to $17800
	ld		a,6+128
	ei
	out		($99),a

  ld    bc,$200
  ld    (sprcoltableaddress),hl
  add   hl,bc
  ld    (spratttableaddress),hl
  add   hl,bc
  ld    (sprchatableaddress),hl
  ex    de,hl
  ld    (invissprcoltableaddress),hl
  add   hl,bc
  ld    (invisspratttableaddress),hl
  add   hl,bc
  ld    (invissprchatableaddress),hl
  ret

;putStarFoxSprite:
;	ld		a,(slot.page12rom)	;all RAM except page 1+2
;	out		($a8),a	
	
;	ld		hl,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
;	ld		a,1
;	call	SetVdp_Write	

;	ld		a,StarFoxSpritesBlock
;	call	block1234		        ;set blocks in page 1/2

;	ld		hl,StarFoxShipSprite1Color
;	ld		c,$98
;	call	outix128
;	call	outix128
;	call	outix128            ;12 sprites (12 * 32 = 384 bytes)
;	call	outix128
;	call	outix128
;	call	outix128
;	call	outix128
;	call	outix128            ;32 sprites (32 * 32 = 384 bytes)

;	ld		hl,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
;	ld		a,1
;	call	SetVdp_Write

;  ld    a,15
;  ld    b,0
;  ld    c,2
;  .loop:
;  out   ($98),a
;  djnz  .loop
;  dec   c
;  jr    nz,.loop
;  ret

SetXBorderMaskingSprites:
  ld    hl,spat+1           ;y sprite 1
  ld    de,4
  ld    b,16                ;amount of sprites
  
  ld    a,(CameraX)
  and   %0000 1111
  add   a,15
  ld    c,2
  .loop:
  ld    (hl),a
  add   hl,de
  djnz  .loop

  add   a,225
  ld    b,16
  dec   c
  jr    nz,.loop
  ret

ScreenOff:
  ld    a,(VDP_0+1)       ;screen off
  and   %1011 1111
  di
  out   ($99),a
  ld    a,1+128
  ei
  out   ($99),a
  ret

ScreenOn:
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  di
  out   ($99),a
  ld    a,1+128
  ei
  out   ($99),a
  ret

putspattovram:
	ld		hl,(invisspratttableaddress)		;sprite attribute table in VRAM ($17600)
	ld		a,1
	call	SetVdp_Write	
	ld		hl,spat			;sprite attribute table
  ld    c,$98
	call	outix128
  ret

spat:						;sprite attribute table
	db		000,000,000,0	,016,000,004,0	,032,000,008,0	,048,000,012,0
	db		064,000,016,0	,080,000,020,0	,096,000,024,0	,112,000,028,0
	db		128,000,032,0	,144,000,036,0	,160,000,040,0	,176,000,044,0
	db		192,000,048,0	,208,000,052,0	,224,000,056,0	,240,000,060,0
	
	db		000,000,064,0	,016,000,068,0	,032,000,072,0	,048,000,076,0
	db		064,000,080,0	,080,000,084,0	,096,000,088,0	,112,000,092,0
	db		128,000,096,0	,144,000,100,0	,160,000,104,0	,176,000,108,0
	db		192,000,112,0	,208,000,116,0	,224,000,120,0	,240,000,124,0

outix128:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix96:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix80:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi
outix64:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix32:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix16:	
	outi	outi	outi	outi	outi	outi	outi	outi
outix8:	
	outi	outi	outi	outi	outi	outi	outi	outi	
	ret