phase	f1MenuAddress ;at $4000 page 1

F2MenuRoutine:
  ld    a,(MapObtained?)
  or    a
  ret   z
  
  call  ScreenOff
  call  DisableLineint	
  call  .BackupPage0InRam              ;store Vram data of page 0 in ram

;  call  CameraEngine304x216.setR18R19R23andPage  
  call  putF2MenuGraphicsInScreen
  ld    a,0*32 + 31                   ;a->x*32+31 (x=page)
  call  setpage
  call  .SpritesOff
  call  ScreenOn



  ld    a,(slot.page1rom)            ;all RAM except page 1
  out   ($a8),a

;bank 2 at $8000
  ld		a,2
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) _ $fe = page 1 ($8000-$bfff) _ $fd = page 2 ($4000-$7fff) _ $fc = page 3 ($0000-$3fff) 

;.stop: jp .stop

;print worldmap
  ld    de,0000                 ;startroom
  ld    bc,50+256*50            ;width, height, b=x, c=y
  ld    hl,0                    ;vram coordinate (start printing map: x,y)
  call  putwm

;print player in current room
  ld    hl,0                    ;vram coordinate (start printing map: x,y)
  ld    de,(WorldMapPositionY)
  call  putwmp                  ;print the player room [DE]


  .F2MenuLoop:
  halt
  call  PopulateControls
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		7,a           ;F2 pressed ?
  jr    z,.F2MenuLoop

  call  ScreenOff
  call  .SpritesOn
  call  .RestorePage0InVram            ;restore the vram data the was stored in ram earlier
  call  .SetR14ValueTo5                ;register 14 sets VRAM address to read/write to/from. This value is only set once per frame ingame, we assume it's set to $05 at all times, so set it back when going back to the game
  call  SetInterruptHandler           ;set Lineint and Vblank  
  call  WaitForInterrupt              ;if SF2 engine: Wait for Vblank _ if normal engine: wait for lineint
  call  ScreenOn
  ret


.SetR14ValueTo5:
  di                                  ;register 14 sets VRAM address to read/write to/from. This value is only set once per frame ingame, we assume it's set to $05 at all times, so set it back when going back to the game
  ld    a,$05
	out   ($99),a       ;set bits 15-17
	ld    a,14+128
  ei
	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)
  ret


.SpritesOn:
  ld    a,(VDP_8)             ;sprites on
  and   %11111101
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
  ei
  out   ($99),a
  ret

.SpritesOff:
  ld    a,(VDP_8)         ;sprites off
  or    %00000010
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
  ei
  out   ($99),a
  ret
  
.BackupPage0InRam:                     ;store Vram data of page 0 in ram:
;bank 1 at $8000
  ld		a,1
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) _ $fe = page 1 ($8000-$bfff) _ $fd = page 2 ($4000-$7fff) _ $fc = page 3 ($0000-$3fff) 

  ld    hl,$0000                      ;page 0 - screen 5 
	xor   a
	call	SetVdp_Read	
  ld    hl,$8000
  ld    c,$98
  ld    a,128/2                       ;backup 128 lines..
  ld    b,0
.loop:
  inir
  dec   a
  jp    nz,.loop

;bank 2 at $8000
  ld		a,2
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) _ $fe = page 1 ($8000-$bfff) _ $fd = page 2 ($4000-$7fff) _ $fc = page 3 ($0000-$3fff) 

  ld    hl,$8000
;  ld    c,$98
  ld    a,084/2                       ;backup remaining 84 lines..
  ld    b,0
.loop2:
  inir
  dec   a
  jp    nz,.loop2
  ret



.RestorePage0InVram:                   ;restore the vram data the was stored in ram earlier
  ld    a,(slot.page1rom)             ;all RAM except page 1
  out   ($a8),a

;bank 1 at $8000
  ld		a,1
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) _ $fe = page 1 ($8000-$bfff) _ $fd = page 2 ($4000-$7fff) _ $fc = page 3 ($0000-$3fff) 

  ld    hl,$0000                      ;page 0 - screen 5 
	xor   a
	call	SetVdp_Write	
	ld		hl,$8000
  ld    c,$98
  ld    a,128/2                       ;copy 212 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1    

;bank 2 at $8000
  ld		a,2
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) _ $fe = page 1 ($8000-$bfff) _ $fd = page 2 ($4000-$7fff) _ $fc = page 3 ($0000-$3fff) 
	ld		hl,$8000
;  ld    c,$98
  ld    a,084/2                       ;copy remaining 84 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1    



putF2MenuGraphicsInScreen:
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a
  ld    a,F2MenuGraphicsBlock ;block to copy from
  .go:
  call  block34
  
  ld    hl,$0000                      ;page 0 - screen 5 
	xor   a
	call	SetVdp_Write	
	ld		hl,$8000
  ld    c,$98
  ld    a,128/2                       ;copy 212 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1    

  ld    a,F2MenuGraphicsBlock+1 ;block to copy from
  call  block34

	ld		hl,$8000
;  ld    c,$98
  ld    a,084/2                       ;copy remaining 84 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1   














;----- Worldmap functions -----
;worldmap, ruin, room -> 4x4 block
;newwm : create an empty map in RAM at [HL]
;newwmr: create room [DE] with type [A] on the map
;getwmr: get worldmap room [DE]
;setwmr: set worldmap room [DE] properties [A]
;delwmr: reset worldmap room [DE] properties
;enawmr: enable room [DE] - keep properties
;diswmr: disable room [DE] -keep properties
;typwmr: set room [DE] type [A]
;rwmr:   add right-connection at room [DE]
;bwmr:   add bottom-connection at room [DE]
;putwm:  print (a part of) the worldmap [DE][BC]
;putwmr: print one worldmap room [HL][DE][C]
;putwmp: print the player room [DE]


; VDP command register offsets
_CMDSX: EQU   0
_CMDSY: EQU   2
_CMDDX: EQU   4
_CMDDY: EQU   6
_CMDNX: EQU   8
_CMDNY: EQU   10
_CMDCL: EQU   12
_CMDAR: EQU   13
_CMDCM: EQU   14

;Create new world map
;in: HL=adr
NEWWM:  LD    (WMADR),HL
        LD    BC,_WMROW*_WMCOL
        PUSH  HL
        POP   DE
        INC   DE
        LD    (HL),0
        LDIR
        AND   A               ;signal no error
        RET

;Initialize a room
;in: DE=roomXXYY, A=roomtype
NEWWMR: EX    AF,AF'
        CALL  GETWMR
        RET   C
        BIT   7,A
        RET   NZ              ;already active
        EX    AF,AF'
        CALL  GETRC
        OR    $80             ;enable
        LD    (HL),A
        RET


;Get worldmap room
;in: DE=room XXYY
;out:HL=roomAdr,A=value
;    Cy=error
GETWMR: ;LD    A,E             ;check boundaries, skip for speed
;       CP    _WMROW
;       CCF
;       RET   C
;       LD    A,D
;       CP    _WMCOL
;       CCF
;       RET   C

        PUSH  BC
        PUSH  DE
        LD    A,D
        LD    H,_WMCOL        ;y*ncol
        CALL  MUL8
        LD    E,A             ;add X
        ADD   HL,DE
        LD    DE,(WMADR)
        ADD   HL,DE           ;cy=0
        LD    A,(HL)
        POP   DE
        POP   BC

        RET

;set room properties
;in: DE=XXYY room, A=roomValue
SETWMR: EX    AF,AF'
        CALL  GETWMR
        RET   C
        EX    AF,AF'
        LD    (HL),A
        AND   A
        RET

;Remove (reset) room [DE] from the world map
DELWMR: XOR   A               ;default roomtype
        CALL  GETRC
        JP    SETWMR

;Enable room [DE]
ENAWMR: CALL  GETWMR
        RET   C
        SET   7,(HL)
        RET
;Disable room [DE]
DISWMR: CALL  GETWMR
        RET   C
        RES   7,(HL)
        RET

;Set roomtype [DE]=[A]
TYPWMR: EX    AF,AF'
        CALL  GETWMR
        RET   C
        PUSH  BC
        AND   $F0
        LD    C,A
        EX    AF,AF'
        CALL  GETRC
        OR    C
        LD    (HL),A
        POP   BC
        RET

;get room color [A]
GETRC:  PUSH  HL
        LD    HL,WMRCOL
        ADD   A,L
        LD    L,A
        LD    A,0
        ADC   A,H
        LD    H,A
        LD    A,(HL)
        POP   HL
        RET

;add room [DE] connector on the right-side
RWMR:   CALL  GETWMR
        RET   C
        SET   4,(HL)
        RET
;add room [DE] connector on the bottom
BWMR:   CALL  GETWMR
        RET   C
        SET   5,(HL)
        RET

;put player room on the map
;in: DE=roomXXYY, HL=XXYY dest offset
PUTWMP: CALL  PWMINI
        RET   C
        LD    C,_PCOL         ;white
        JP    PUTWMR

;Put (part of) the worldmap on screen
;in: DE=roomXXYY, HL=XXYY dest offset, BC=WWHH
PUTWM:  CALL  PWMINI
        RET   C

        LD    A,B             ;swap BC
        LD    B,C             ;b=num rows
        LD    C,B             ;c=num cols
PWM.1:  PUSH  BC
        LD    B,C
        PUSH  HL
        PUSH  DE
PWM.0:  PUSH  BC
        LD    A,(HL)          ;roomData
        BIT   7,A
        JP    Z,PWM.2
        AND   15
        LD    C,A
        CALL  PUTWMR
PWM.2:  INC   HL
        LD    A,D
        ADD   A,4
        LD    D,A
        POP   BC
        DJNZ  PWM.0
        POP   DE
        LD    A,E
        ADD   A,4
        LD    E,A
        POP   HL
        LD    BC,_WMCOL
        ADD   HL,BC
        POP   BC
        DJNZ  PWM.1
        RET

;init PrintWorldMap
;in:  DE=roomXXYY
;out: HL=roomAdr, DE=screenPos
PWMINI: LD    A,D             ;room X start position
        ADD   A,A             ;x2
        ADD   A,A             ;x4
        LD    D,A
        LD    A,E             ;room Y start position
        ADD   A,A             ;x2
        ADD   A,A             ;x4
        LD    E,A
        ADD   HL,DE           ;add offset
        PUSH  HL
        CALL  GETWMR          ;HL=adr
        POP   DE
        RET


;Print one room blk of 4x4
;in: HL=blockDataPointer, DE=XXYY, C=room color
;1110
;1111
;1110
;0100
PUTWMR: LD    A,$F0           ;HMMC
        LD    (_HMMC+_CMDCM),A
;       XOR   A
;       LD    (_HMMC+_CMDDX+1),A
;       LD    (_HMMC+_CMDDY+1),A
        LD    A,D             ;x
        LD    (_HMMC+_CMDDX),A
        LD    A,E             ;y
        LD    (_HMMC+_CMDDY),A

        LD    A,C             ;colors
        RLCA
        RLCA
        RLCA
        RLCA
        LD    B,A

;first 3 bytes always on
        OR    C
        CALL  HMMC            ;row 0
        LD    A,B
        OUT   ($9B),A
        OR    C
        OUT   ($9B),A         ;row 1
;right exit
        LD    A,B
        BIT   4,(HL)
        JR    Z,PWMR.0
        OR    _WMRC0          ;exit is always def room color
PWMR.0: OUT   ($9B),A
        LD    A,B
        OR    C
        OUT   ($9B),A         ;row 2
;bottom exit
        LD    A,B
        OUT   ($9B),A
        BIT   5,(HL)
        LD    A,0
        JR    Z,PWMR.1
        OR    _WMRC0          ;exit is always def room color
PWMR.1: OUT   ($9B),A
        XOR   A               ;empty pixels
        OUT   ($9B),A
        RET

;High speed move CPU to VRAM
HMMC:   EX    AF,AF'
        LD    A,(_HMMC+_CMDCM) ;cmd activated yet?
        AND   A
        JP    NZ,HMMC.0
        EX    AF,AF'
        RET
HMMC.0: EX    AF,AF'           ;first time, activate the cmd
        LD    (_HMMC+_CMDCL),A
        PUSH  BC
        PUSH  HL
        LD    HL,_HMMC+_CMDDX
        LD    A,36
        LD    B,11
        CALL  CMDVDP
        POP   HL
        POP   BC
        DI
        LD    A,44 OR $80
        OUT   ($99),A
        LD    A,17 OR $80
        EI
        OUT   ($99),A
        XOR   A               ;signal activation for next time
        LD    (_HMMC+_CMDCM),A
        RET

;Multiply 8-bit values
;In:  Multiply H with E
;Out: HL = result
MUL8:   LD    D,0
        LD    L,D
        LD    B,8
MUL8.0: ADD   HL,HL
        JP    NC,MUL8.1
        ADD   HL,DE
MUL8.1: DJNZ  MUL8.0
        RET

;Wait for VDP command is ready
QCES:   LD    A,2
        CALL  RDSTAT
        RRCA
        JP    C,QCES
        RET

;read VDP status register
RDSTAT: DI
        OUT   ($99),A
        LD    A,128+15
        OUT   ($99),A
        LD    A,0
        IN    A,($99)
        EX    AF,AF'
        LD    A,0
        OUT   ($99),A
        LD    A,15 OR $80
        EI
        OUT   ($99),A
        EX    AF,AF'
        RET

;Command VDP
;In : A , First VDP register (b5-b0) + AII (b7)
;     B , Number of registers to write
;     HL, Register value table
CMDVDP: ;PUSH  AF
        ;CALL  QCES
        ;POP   AF
        DI
        OUT   ($99),A
        LD    A,17 OR $80
        EI
        OUT   ($99),A
        LD    C,$9B
        OTIR
        RET









  dephase
