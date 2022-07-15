;at $4000 page 1
F1MenuRoutine:
  jp    CheckIfF1MenuIsAccessable
  F1MenuIsAccessable:
  call  ScreenOff
  call  DisableLineint	
  call  BackupPage0InRam              ;store Vram data of page 0 in ram
;  call  CameraEngine304x216.setR18R19R23andPage  
  call  putF1MenuGraphicsInScreen
  ld    a,0*32 + 31                   ;a->x*32+31 (x=page)
  call  setpage
  call  SpritesOff
  call  ScreenOn
  .F1MenuLoop:
  halt
  call  PopulateControls
  call  EraseWeaponBox                ;erase the tag from the active weapon's box
  call  SelectWeapon                  ;checks left - right - up - down - and selects that weapon
  call  SetWeaponBox                  ;tag the active weapon's box
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		6,a           ;F1 pressed ?
  jr    z,.F1MenuLoop

  call  ScreenOff
  call  SetElementalWeaponInVram      ;if an elemental weapon is selected, load it's graphics into Vram
  call  SpritesOn
  call  RestorePage0InVram            ;restore the vram data the was stored in ram earlier
  call  SetInterruptHandler           ;set Lineint and Vblank  
  call  WaitForInterrupt              ;if SF2 engine: Wait for Vblank | if normal engine: wait for lineint
  call  ScreenOn
  ret

SetElementalWeaponInVram:
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  cp    5
	ld		hl,ElementalWeapons+11*128+64 ;start copying from this address in rom
  jp    z,.ShootFire
  cp    7
	ld		hl,ElementalWeapons+000       ;start copying from this address in rom
  jp    z,.ShootIce
  cp    8
	ld		hl,ElementalWeapons+11*128    ;start copying from this address in rom
  jp    z,.ShootEarth
  cp    9
	ld		hl,ElementalWeapons+064       ;start copying from this address in rom
  jp    z,.ShootWater
  ret

  .ShootFire:
  .ShootIce:
  .ShootEarth:
  .ShootWater:
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a
  ld    a,Graphicsblock5              ;block to copy from
  call  block34
  
;	ld		hl,ElementalWeapons           ;start copying from this address in rom
  ld    de,64  
  exx
  ld    hl,$fac0                      ;start copying to this address in Vram -> page 3 - screen 5 - copy to (128,245)
  ld    de,128
  ld    b,11                          ;total height
.loop:
	ld    a,1
	push  hl
	call	SetVdp_Write
	pop   hl
  add   hl,de                         ;start copying to this address in Vram
  exx
  ld    c,$98
  ld    b,64                          ;copy 128 lines
  otir
  add   hl,de                         ;start copying from this address in rom
  exx
  djnz  .loop
  ret

EraseWeaponBox:
  xor   a
  ld    (FreeToUseFastCopy+sx),a
  ld    (FreeToUseFastCopy+sy),a
  
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  sub   7
  jr    nc,.NotCarry
  add   a,7
  .NotCarry:
  add   a,a                           ;*2
  add   a,a                           ;*4
  ld    b,a
  add   a,a                           ;*8
  add   a,a                           ;*16
  add   a,a                           ;*32
  add   a,b                           ;*36
  add   a,18
  ld    (FreeToUseFastCopy+dx),a
  
  ld    hl,FreeToUseFastCopy
  call  docopy
  ret


SetWeaponBox:
  ld    a,210
  ld    (FreeToUseFastCopy+sx),a
  ld    a,49
  ld    (FreeToUseFastCopy+sy),a
  
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  sub   7
  ld    d,074+56                      ;dy
  jr    nc,.NotCarry
  ld    d,074                         ;dy
  add   a,7
  .NotCarry:
  add   a,a                           ;*2
  add   a,a                           ;*4
  ld    b,a
  add   a,a                           ;*8
  add   a,a                           ;*16
  add   a,a                           ;*32
  add   a,b                           ;*36
  add   a,18
  ld    (FreeToUseFastCopy+dx),a
  ld    a,d
  ld    (FreeToUseFastCopy+dy),a
  
  ld    hl,FreeToUseFastCopy
  call  docopy
  ret

SpritesOn:
  ld    a,(VDP_8)             ;sprites on
  and   %11111101
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
  ei
  out   ($99),a
  ret

SpritesOff:
  ld    a,(VDP_8)         ;sprites off
  or    %00000010
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
  ei
  out   ($99),a
  ret
  
BackupPage0InRam:                     ;store Vram data of page 0 in ram:
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

;
;Set VDP port #98 to start reading at address AHL (17-bit)
;
SetVdp_Read:  rlc     h
              rla
              rlc     h
              rla
              srl     h
              srl     h
              di
              out     ($99),a         ;set bits 15-17
              ld      a,14+128
              out     ($99),a
              ld      a,l             ;set bits 0-7
              nop
              out     ($99),a
              ld      a,h             ;set bits 8-14
              ei                      ; + read access
              out     ($99),a
              ret

RestorePage0InVram:                   ;restore the vram data the was stored in ram earlier
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

putF1MenuGraphicsInScreen:
  ld    a,(slot.page12rom)            ;all RAM except page 1+2
  out   ($a8),a
  ld    a,F1MenuGraphicsBlock ;block to copy from
  call  block34
  
  ld    hl,$0000                      ;page 0 - screen 5 
	xor   a
	call	SetVdp_Write	
	ld		hl,$8000
  ld    c,$98
  ld    a,128/2                       ;copy 212 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1    

  ld    a,F1MenuGraphicsBlock+1 ;block to copy from
  call  block34

	ld		hl,$8000
;  ld    c,$98
  ld    a,084/2                       ;copy remaining 84 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1   

CheckIfF1MenuIsAccessable:
  ld    a,(ArrowActive?)
  or    a
  ret   nz
  ld    a,(FireballActive?)
  or    a
  ret   nz
  ld    a,(IceWeaponActive?)
  or    a
  ret   nz  
  ld    a,(EarthWeaponActive?)
  or    a
  ret   nz 
  ld    a,(WaterWeaponActive?)
  or    a
  ret   nz   
  ld    a,(ShootArrowWhileJump?)
  or    a
  ret   nz

	ld		hl,(PlayerSpriteStand)
	ld		de,LShootArrow
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,RShootArrow
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,LSitShootArrow
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,RSitShootArrow
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,LShootFireball
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,RShootFireball
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,LShootFireball
  xor   a
  sbc   hl,de
  ret   z
	ld		hl,(PlayerSpriteStand)
	ld		de,RShootFireball
  xor   a
  sbc   hl,de
  ret   z
  jp    F1MenuIsAccessable

SelectWeapon:                         ;just set the next magic weapon
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		3,a           ;right pressed ?
  jr    nz,.Right
	bit		2,a           ;left pressed ?
  jr    nz,.Left
	bit		1,a           ;down pressed ?
  jr    nz,.Down
	bit		0,a           ;up pressed ?
  jr    nz,.Up

  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  jr    .EndTableCheck                ;just set the current weapon

.Up:
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  sub   a,7
  ret   c
  jr    .EndTableCheck

.Down:
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  add   a,7
  cp    14
  ret   nc
  jr    .EndTableCheck

.Left:
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  dec   a
  cp    255  
  ret   z
  cp    6
  ret   z
  jr    .EndTableCheck
  
.Right:
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  inc   a
  cp    7
  ret   z
  cp    14
  ret   z
  .EndTableCheck:
  ld    (CurrentMagicWeapon),a
    
  ld    hl,.JumpTableMagicSkillsRightStanding
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Rrunning.MagicWeaponRightSelfModifyingJump
  ld    bc,3
  ldir

  ld    hl,.JumpTableMagicSkillsRightStanding
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Rstanding.MagicWeaponRightSelfModifyingJump
  ld    bc,3
  ldir

  ld    hl,.JumpTableMagicSkillRightSitting
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Rsitting.MagicWeaponRightSelfModifyingJump
  ld    bc,3
  ldir

  ld    hl,.JumpTableMagicSkillsLeftStanding
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Lstanding.MagicWeaponLeftSelfModifyingJump
  ld    bc,3
  ldir

  ld    hl,.JumpTableMagicSkillsLeftStanding
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Lrunning.MagicWeaponLeftSelfModifyingJump
  ld    bc,3
  ldir

  ld    hl,.JumpTableMagicSkillsLeftSitting
  call  .CurrentMagicWeaponTimes3InDE
  add   hl,de
  ld    de,Lsitting.MagicWeaponLeftSelfModifyingJump
  ld    bc,3
  ldir
  ret

.CurrentMagicWeaponTimes3InDE:
  ld    a,(CurrentMagicWeapon)
  
  ld    b,a
  add   a,a                           ;*2
  add   a,b                           ;*3
  ld    d,0
  ld    e,a
  ret

.JumpTableMagicSkillsLeftStanding:
  nop | nop | nop                     ;magic 0 (nothing)
  jp		nz,Set_L_Rolling              ;magic 1 rolling)
  jp		nz,Set_Charging               ;magic 2 (charging)
  jp		nz,Set_L_Meditate             ;magic 3 (meditate)
  jp		nz,Set_L_ShootArrow           ;magic 4 (shoot arrow)
  jp		nz,Set_L_ShootFireball        ;magic 5 (shoot fireball)
  jp		nz,Set_L_SilhouetteKick       ;magic 6 (silhouette kick)
  jp		nz,Set_L_ShootIce             ;magic 7 (shoot ice)
  jp		nz,Set_L_ShootEarth           ;magic 8 (shoot earth)
  jp		nz,Set_L_ShootWater           ;magic 9 (shoot water)
  nop | nop | nop                     ;magic 10 (nothing)
  nop | nop | nop                     ;magic 11 (nothing)
  nop | nop | nop                     ;magic 12 (nothing)
  nop | nop | nop                     ;magic 13 (nothing)
  
.JumpTableMagicSkillsRightStanding:
  nop | nop | nop                     ;magic 0 (nothing)
  jp		nz,Set_R_Rolling              ;magic 1 rolling)
  jp		nz,Set_Charging               ;magic 2 (charging)
  jp		nz,Set_R_Meditate             ;magic 3 (meditate)
  jp		nz,Set_R_ShootArrow           ;magic 4 (shoot arrow)
  jp		nz,Set_R_ShootFireball        ;magic 5 (shoot fireball)
  jp		nz,Set_R_SilhouetteKick       ;magic 6 (silhouette kick)
  jp		nz,Set_R_ShootIce             ;magic 7 (shoot ice)
  jp		nz,Set_R_ShootEarth           ;magic 8 (shoot earth)
  jp		nz,Set_R_ShootWater           ;magic 9 (shoot water)
  nop | nop | nop                     ;magic 10 (nothing)
  nop | nop | nop                     ;magic 11 (nothing)
  nop | nop | nop                     ;magic 12 (nothing)
  nop | nop | nop                     ;magic 13 (nothing)

.JumpTableMagicSkillsLeftSitting:
  nop | nop | nop                     ;magic 0 (nothing)
  jp		nz,Set_L_Rolling              ;magic 1 rolling)
  jp		nz,Set_Charging               ;magic 2 (charging)
  jp		nz,Set_L_Meditate             ;magic 3 (meditate)
  jp		nz,Set_L_SitShootArrow        ;magic 4 (shoot arrow)
  jp		nz,Set_L_ShootFireball        ;magic 5 (shoot fireball)
  jp		nz,Set_L_SilhouetteKick       ;magic 6 (silhouette kick)
  jp		nz,Set_L_ShootIce             ;magic 7 (shoot ice)
  jp		nz,Set_L_ShootEarth           ;magic 8 (shoot earth)
  jp		nz,Set_L_ShootWater           ;magic 9 (shoot water)
  nop | nop | nop                     ;magic 10 (nothing)
  nop | nop | nop                     ;magic 11 (nothing)
  nop | nop | nop                     ;magic 12 (nothing)
  nop | nop | nop                     ;magic 13 (nothing)

.JumpTableMagicSkillRightSitting:
  nop | nop | nop                     ;magic 0 (nothing)
  jp		nz,Set_R_Rolling              ;magic 1 rolling)
  jp		nz,Set_Charging               ;magic 2 (charging)
  jp		nz,Set_R_Meditate             ;magic 3 (meditate)
  jp		nz,Set_R_SitShootArrow        ;magic 4 (shoot arrow)
  jp		nz,Set_R_ShootFireball        ;magic 5 (shoot fireball)
  jp		nz,Set_R_SilhouetteKick       ;magic 6 (silhouette kick)
  jp		nz,Set_R_ShootIce             ;magic 7 (shoot ice)
  jp		nz,Set_R_ShootEarth           ;magic 8 (shoot earth)
  jp		nz,Set_R_ShootWater           ;magic 9 (shoot water)
  nop | nop | nop                     ;magic 10 (nothing)
  nop | nop | nop                     ;magic 11 (nothing)
  nop | nop | nop                     ;magic 12 (nothing)
  nop | nop | nop                     ;magic 13 (nothing)
  