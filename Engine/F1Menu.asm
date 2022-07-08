F1MenuRoutine:
  ld    a,(ArrowActive?)
  or    a
  ret   nz
  ld    a,(FireballActive?)
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

  call  ChangeMagicWeapon
  call  DisableLineint	
;  call  CameraEngine304x216.setR18R19R23andPage  



  call  SetInterruptHandler           ;set Lineint and Vblank  
  call  WaitForInterrupt              ;if SF2 engine: Wait for Vblank | if normal engine: wait for lineint
  ret

ChangeMagicWeapon:                    ;just set the next magic weapon
  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick
  inc   a
  cp    7
  jr    nz,.EndTableCheck
  xor   a
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

.JumpTableMagicSkillsRightStanding:
  nop | nop | nop
  jp		nz,Set_R_Rolling
  jp		nz,Set_Charging
  jp		nz,Set_R_Meditate
  jp		nz,Set_R_ShootArrow
  jp		nz,Set_R_ShootFireball
  jp		nz,Set_R_SilhouetteKick

.JumpTableMagicSkillsLeftStanding:
  nop | nop | nop
  jp		nz,Set_L_Rolling
  jp		nz,Set_Charging
  jp		nz,Set_L_Meditate
  jp		nz,Set_L_ShootArrow
  jp		nz,Set_L_ShootFireball
  jp		nz,Set_L_SilhouetteKick

.JumpTableMagicSkillsLeftSitting:
  nop | nop | nop
  jp		nz,Set_L_Rolling
  jp		nz,Set_Charging
  jp		nz,Set_L_Meditate
  jp		nz,Set_L_SitShootArrow
  jp		nz,Set_L_ShootFireball
  jp		nz,Set_L_SilhouetteKick

.JumpTableMagicSkillRightSitting:
  nop | nop | nop
  jp		nz,Set_R_Rolling
  jp		nz,Set_Charging
  jp		nz,Set_R_Meditate
  jp		nz,Set_R_SitShootArrow
  jp		nz,Set_R_ShootFireball
  jp		nz,Set_R_SilhouetteKick