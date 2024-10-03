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
  call  WaitForInterrupt              ;if SF2 engine: Wait for Vblank | if normal engine: wait for lineint
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
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 

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
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 

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
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 

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
  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 
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



  dephase
