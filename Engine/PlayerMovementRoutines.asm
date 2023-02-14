;Rstanding,Lstanding,Rsitting,Lsitting,Rrunning,Lrunning,Jump,ClimbDown,ClimbUp,Climb,RAttack,LAttack,ClimbStairsLeftUp, ClimbStairsRightUp, RPushing, LPushing, RRolling, LRolling, RBeingHit, LBeingHit
;RSitPunch, LSitPunch, Dying, Charging, LBouncingBack, RBouncingBack, LMeditate, RMeditate, LShootArrow, RShootArrow, LSitShootArrow, RSitShootArrow, LShootFireball, RShootFireball, LSilhouetteKick, RSilhouetteKick
;LShootIce, RShootIce, LShootEarth, RShootEarth, LShootWater, RShootWater, DoNothing, LSwordAttack, RSwordAttack, LDaggerAttack, RDaggerAttack, LAxeAttack, RAxeAttack, LSpearAttack, RSpearAttack

;SetPrimaryWeaponHitBoxLeftSitting,SetPrimaryWeaponHitBoxRightSitting,SetPrimaryWeaponHitBoxLeftStanding,SetPrimaryWeaponHitBoxRightStanding

SetPrimaryWeaponHitBoxLeftSitting:
  ;activate primary weapon - which enables it's hitbox detection with enemies
  ld    a,1
  ld    (PrimaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,20+12              ;normal engine
  jr    z,.engineFound
  ld    bc,04+12              ;SF2 engine 
  .engineFound:
  ld    hl,(ClesX)
  sbc   hl,bc                 ;adjust x starting placement projectile
  jr    nc,.SetX
  ld    hl,0
  .SetX:
  ld    (PrimaryWeaponX),hl
  ld    bc,16
  add   hl,bc
  ld    (PrimaryWeaponXRightSide),hl
  ld    a,(ClesY)
  add   a,6
  ld    (PrimaryWeaponY),a
  add   a,16
  ld    (PrimaryWeaponYBottom),a
    
  ld    a,16
  ld    (PrimaryWeaponNY),a
  ld    a,16
  ld    (PrimaryWeaponNx),a
  ret

SetPrimaryWeaponHitBoxRightSitting:
  ;activate primary weapon - which enables it's hitbox detection with enemies
  ld    a,1
  ld    (PrimaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,20                 ;normal engine
  jr    z,.engineFound
  ld    bc,04                 ;SF2 engine 
  .engineFound:
  ld    hl,(ClesX)
  sbc   hl,bc                 ;adjust x starting placement projectile
  jr    nc,.SetX
  ld    hl,0
  .SetX:
  ld    (PrimaryWeaponX),hl
  ld    bc,16
  add   hl,bc
  ld    (PrimaryWeaponXRightSide),hl
  ld    a,(ClesY)
  add   a,6
  ld    (PrimaryWeaponY),a
  add   a,16
  ld    (PrimaryWeaponYBottom),a
    
  ld    a,16
  ld    (PrimaryWeaponNY),a
  ld    a,16
  ld    (PrimaryWeaponNx),a
  ret

SetPrimaryWeaponHitBoxLeftStanding:
  ;activate primary weapon - which enables it's hitbox detection with enemies
  ld    a,1
  ld    (PrimaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,20+12              ;normal engine
  jr    z,.engineFound
  ld    bc,04+12              ;SF2 engine 
  .engineFound:
  ld    hl,(ClesX)
  sbc   hl,bc                 ;adjust x starting placement projectile
  jr    nc,.SetX
  ld    hl,0
  .SetX:
  ld    (PrimaryWeaponX),hl
  ld    bc,16
  add   hl,bc
  ld    (PrimaryWeaponXRightSide),hl
  ld    a,(ClesY)
  ld    (PrimaryWeaponY),a
  add   a,16
  ld    (PrimaryWeaponYBottom),a
    
  ld    a,16
  ld    (PrimaryWeaponNY),a
  ld    a,16
  ld    (PrimaryWeaponNx),a
  ret

SetPrimaryWeaponHitBoxRightStanding:
  ;activate primary weapon - which enables it's hitbox detection with enemies
  ld    a,1
  ld    (PrimaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,20                 ;normal engine
  jr    z,.engineFound
  ld    bc,04                 ;SF2 engine 
  .engineFound:
  ld    hl,(ClesX)
  sbc   hl,bc                 ;adjust x starting placement projectile
  jr    nc,.SetX
  ld    hl,0
  .SetX:
  ld    (PrimaryWeaponX),hl
  ld    bc,16
  add   hl,bc
  ld    (PrimaryWeaponXRightSide),hl
  ld    a,(ClesY)
  ld    (PrimaryWeaponY),a
  add   a,16
  ld    (PrimaryWeaponYBottom),a
    
  ld    a,16
  ld    (PrimaryWeaponNY),a
  ld    a,16
  ld    (PrimaryWeaponNx),a
  ret

LShootWater:
  ld    b,-WaterWeaponSpeed
  jp    LShootElementalWeapon
  
RShootWater:
  ld    b,WaterWeaponSpeed
  jp    RShootElementalWeapon
  
LShootEarth:
  ld    b,-EarthWeaponSpeed
  jp    LShootElementalWeapon
  
RShootEarth:
  ld    b,EarthWeaponSpeed
  jp    RShootElementalWeapon
  
LShootIce:
  ld    b,-IceWeaponSpeed
  jp    LShootElementalWeapon
  
RShootIce:
  ld    b,IceWeaponSpeed
  jp    RShootElementalWeapon

LShootFireball:
  ld    b,-FireballSpeed
  jp    LShootElementalWeapon

RShootFireball:
  ld    b,FireballSpeed
  jp    RShootElementalWeapon
    
LShootElementalWeapon:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,-38
  add   hl,de
  jp    nc,.Set_L_Stand

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,-294
  add   hl,de
  jp    c,BruteForceMovementLeft

;Animate
  ld    hl,LeftShootFireballAnimation
  call  AnimateShootFireball  ;animate

  ld    a,(PlayerAniCount)
  cp    2 * 14
  jp    z,.Set_L_Stand  
  cp    2 * 10
  ret   nz

  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  jp    SetLShootElementalWeapon

  .Set_L_Stand:
	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
  xor   a
  sbc   hl,de
  jp    nz,Set_L_Stand         ;if you were standing, go back to standing pose  
  xor   a
  ld    (ShootMagicWhileJump?),a
  ld    (PlayerAniCount),a
  ret  
  
RShootElementalWeapon:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,11
  xor   a
  sbc   hl,de
  jp    c,BruteForceMovementRight

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-37-12
  xor   a
  sbc   hl,de
  jp    nc,.Set_R_Stand

;Animate
  ld    hl,RightShootFireballAnimation
  call  AnimateShootFireball             ;animate

  ld    a,(PlayerAniCount)
  cp    2 * 14
  jp    z,.Set_R_Stand  
  cp    2 * 10
  ret   nz

  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  jp    SetRShootElementalWeapon

  .Set_R_Stand:
	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
  xor   a
  sbc   hl,de
  jp    nz,Set_R_Stand         ;if you were standing, go back to standing pose  
  xor   a
  ld    (ShootMagicWhileJump?),a
  ld    (PlayerAniCount),a
  ret  

SetLShootElementalWeapon:
  ld    a,b
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    de,-26                ;normal engine
  jr    z,.engineFound
  ld    de,-21                ;SF2 engine  
  .engineFound:

  ld    hl,(ClesX)
  add   hl,de                 ;adjust x starting placement projectile
  ld    a,l
  bit   0,h
  jr    z,.SetX
  ld    a,255
  .SetX:
  ld    (SecundaryWeaponX),a
  ld    a,(ClesY)
  ld    (SecundaryWeaponY),a
  add   a,11
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,11
  ld    (SecundaryWeaponNY),a
  ld    a,216+29
  ld    (SecundaryWeaponSY),a
  ret

SetRShootElementalWeapon:
  ld    a,b
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,20                  ;normal engine
  jr    z,.engineFound
  ld    b,04                  ;SF2 engine 
  .engineFound:
  ld    a,(ClesX)
  sub   a,b                   ;adjust x starting placement projectile
  jr    nc,.SetX
  xor   a
  .SetX:
  ld    (SecundaryWeaponX),a
  ld    a,(ClesY)
  ld    (SecundaryWeaponY),a
  add   a,11
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,11
  ld    (SecundaryWeaponNY),a
  ld    a,216+29
  ld    (SecundaryWeaponSY),a
  ret

AnimateShootFireball:
  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jp    AnimateRun.SetPlayerAniCount

LeftShootFireballAnimation:
  dw  PlayerSpriteData_Char_LeftPunch1a 
  dw  PlayerSpriteData_Char_LeftPunch1a 
  dw  PlayerSpriteData_Char_LeftPunch1b 
  dw  PlayerSpriteData_Char_LeftPunch1c 
  dw  PlayerSpriteData_Char_LeftPunch1c
  dw  PlayerSpriteData_Char_LeftPunch1c 
  dw  PlayerSpriteData_Char_LeftPunch1c
  dw  PlayerSpriteData_Char_LeftPunch1d 
  dw  PlayerSpriteData_Char_LeftCharge2
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  
RightShootFireballAnimation:
  dw  PlayerSpriteData_Char_RightPunch1a 
  dw  PlayerSpriteData_Char_RightPunch1a 
  dw  PlayerSpriteData_Char_RightPunch1b 
  dw  PlayerSpriteData_Char_RightPunch1c 
  dw  PlayerSpriteData_Char_RightPunch1c
  dw  PlayerSpriteData_Char_RightPunch1c 
  dw  PlayerSpriteData_Char_RightPunch1c
  dw  PlayerSpriteData_Char_RightPunch1d 
  dw  PlayerSpriteData_Char_RightCharge2
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5

BruteForceMovementLeft:
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
  and   %1111 0011                  ;reset left or right pressed
	ld		(Controls),a

  ld    hl,(clesx)
  ld    de,-2
  add   hl,de
  ld    (clesx),hl
  ret
  
BruteForceMovementRight:
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
  and   %1111 0011                  ;reset left or right pressed
	ld		(Controls),a	

  ld    hl,(clesx)
  ld    de,+2
  add   hl,de
  ld    (clesx),hl
  ret

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  3, 4*8, 0
                                                   ;positioning for the SW sprites:
LeftSittingPresentBowAnimation:                   ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftSitShootArrow1 | db 002,012+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftSitShootArrow2 | db 002,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftSitShootArrow3 | db 002,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftSitShootArrow4 | db 002,014+63,013,003,216+19,028

LSitShootArrow:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    de,30                 ;left edge
  ld    bc,284                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeftWhenSitting
;Animate
  ld    hl,LeftSittingPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetLSitShootArrow
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX



SetLSitShootArrow:
  ;put weapon
  ld    a,-ArrowSpeed
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-29                ;normal engine
  jr    z,.engineFound
  ld    b,-24                ;SF2 engine  
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a
  
  ld    a,(ClesY)
  add   a,7
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+17
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a
  jp    Set_L_Sit 

;animate every x frames, amount of frames * 2, left(0) or Left(1)
  db  3, 4*8, 1
                                                   ;positioning for the SW sprites:
RightSittingPresentBowAnimation:                   ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightSitShootArrow1 | db 002,010+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightSitShootArrow2 | db 002,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightSitShootArrow3 | db 002,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightSitShootArrow4 | db 002,008+50,013,003,216+19,030

RSitShootArrow:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    de,11                 ;left edge
  ld    bc,264                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRightWhenSitting
  
;Animate
  ld    hl,RightSittingPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetRSitShootArrow
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX

SetRSitShootArrow:
  ;put weapon
  ld    a,ArrowSpeed
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-11                ;normal engine
  jr    z,.engineFound
  ld    b,7                   ;SF2 engine. If this value is lower than 7, an arrow is not put in screen when standing on the left edge of the screen
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a
  
  ld    a,(ClesY)
  add   a,7
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+16
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a
  jp    Set_R_Sit  

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  3, 4*8, 0
                                        ;positioning for the SW sprites:
LeftPresentBowAnimation:                       ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftShootArrow1 | db -04,011+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftShootArrow2 | db -04,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftShootArrow3 | db -04,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftShootArrow4 | db -04,014+63,013,003,216+19,028

LShootArrow:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    de,30                 ;left edge
  ld    bc,284                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    hl,LeftPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetLShootArrow
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX

SetLShootArrow:
  ;put weapon
  ld    a,-ArrowSpeed
  ld    (SecundaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-29                ;normal engine
  jr    z,.engineFound
  ld    b,-24                ;SF2 engine  
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a
  ld    a,(ClesY)
  inc   a
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a

  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+17
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a
  jp    Set_L_Stand  

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  3, 4*8, 1
                                        ;positioning for the SW sprites:
RightPresentBowAnimation:                       ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightShootArrow1 | db -04,011+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightShootArrow2 | db -04,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightShootArrow3 | db -04,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightShootArrow4 | db -04,008+50,013,003,216+19,030

RShootArrow:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
 
  ld    de,11                 ;left edge
  ld    bc,264                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    hl,RightPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetRShootArrow
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128                       ;bow animation
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX

SetRShootArrow:
  ;put weapon
  ld    a,ArrowSpeed
  ld    (SecundaryWeaponActive?),a
  
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-11                ;normal engine
  jr    z,.engineFound
  ld    b,7                   ;SF2 engine. If this value is lower than 7, an arrow is not put in screen when standing on the left edge of the screen
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a
  ld    a,(ClesY)
  inc   a
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+16
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a
  jp    Set_R_Stand  

RSilhouetteKickAnimateTable:
  db    0,1,0,0,1,1, 3,3,2,2,3, 1,1,1,0,1,1, 3,3,2,3,3, 1,0,0,1,1,1, 3,2,2,3,2, 1,0,1
;LSilhouetteKickAnimateTable:
;  db    1,1,1,1,1,1, 3,3,3,3,3, 1,1,1,1,1,1, 3,3,3,3,3, 1,1,1,1,1,1, 3,3,3,3,3, 1,1,1

LSilhouetteKick:
  call  .CheckPassThroughWall       ;if there is a wall in front of player and player would be able to end up at the other side, then set PlayerAniCount+1 to 255
  call  SetPrimaryWeaponHitBoxLeftStanding
  call  .Animate
  
  ;horizontal movement    
  ld    de,-2                       ;horizontal movement speed
  ld    a,(PlayerAniCount+1)        ;255 = unobstructed movement is allowed
  inc   a
  jr    nz,.NormalMovement
  .UnobstructedMovement:
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl  
  ret
  .NormalMovement:
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc
  jp    .endSilhouettekick          ;on collision change to L_Stand and allow jumping

  .Animate:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    32
  jp    z,.endSilhouettekick        ;on collision change to L_Stand and allow jumping
  ld    hl,RSilhouetteKickAnimateTable-1
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)                      ;0=high kick, 1=silhouette high kick, 2=low kick, 3=silhouette low kick
  or    a
  ld    hl,PlayerSpriteData_Char_LeftHighKick
	jr    z,.setCharacter
	dec   a
  ld    hl,PlayerSpriteData_Char_LeftSilhouetteHighKick
	jr    z,.setCharacter
	dec   a
  ld    hl,PlayerSpriteData_Char_LeftLowKick
	jr    z,.setCharacter
  ld    hl,PlayerSpriteData_Char_LeftSilhouetteLowKick
	.setCharacter:
	ld		(standchar),hl  
  ret

  .endSilhouettekick:               ;on collision change to L_Stand and allow jumping
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
  and   %1111 1110                  ;reset up
	ld		(Controls),a
  jp    Set_L_stand                 ;on collision change to L_Stand  

  .CheckPassThroughWall:
  ld    a,(PlayerAniCount+1)
  or    a
  ret   nz
  inc   a
  ld    (PlayerAniCount+1),a

  ld    hl,(ClesX)
  ld    de,70
  sbc   hl,de
  ret   c                           ;passing through wall disabled when x<70

  ld    hl,(ClesX)
  push  hl
  call  .GoCheck
  pop   hl
  ld    (ClesX),hl
  ret
  
  .GoCheck:
  ld    de,-48                      ;move player 48 pixels to the right and then check for a wall
  add   hl,de
  ld    (ClesX),hl

  ld    de,-2                       ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   c                           ;return if there is a wall, in this case player cannot move through a wall prior to the end location
  ld    de,-14                      ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   c                           ;return if there is a wall, in this case player cannot move through a wall prior to the end location
  
  ld    a,255
  ld    (PlayerAniCount+1),a        ;there is no wall at the end location, so allow player to move to a wall prior to the end location
  ret

RSilhouetteKick:
  call  .CheckPassThroughWall       ;if there is a wall in front of player and player would be able to end up at the other side, then set PlayerAniCount+1 to 255
  call  SetPrimaryWeaponHitBoxRightStanding
  call  .Animate
  
  ;horizontal movement    
  ld    de,2                        ;horizontal movement speed
  ld    a,(PlayerAniCount+1)        ;255 = unobstructed movement is allowed
  inc   a
  jr    nz,.NormalMovement
  .UnobstructedMovement:
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl  
  ret
  .NormalMovement:
;  call  .CheckJustPassedThroughWall ;check if player just passed through a wall and is now at the other side of wall. If so, then change to R_stand
  
  
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc                          ;not carry = no collision with wall
  jp    .endSilhouettekick          ;on collision change to R_Stand and allow jumping

  .Animate:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    32
  jp    z,.endSilhouettekick        ;on collision change to R_Stand and allow jumping
  ld    hl,RSilhouetteKickAnimateTable-1
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)                      ;0=high kick, 1=silhouette high kick, 2=low kick, 3=silhouette low kick
  or    a
  ld    hl,PlayerSpriteData_Char_RightHighKick
	jr    z,.setCharacter
	dec   a
  ld    hl,PlayerSpriteData_Char_RightSilhouetteHighKick
	jr    z,.setCharacter
	dec   a
  ld    hl,PlayerSpriteData_Char_RightLowKick
	jr    z,.setCharacter
  ld    hl,PlayerSpriteData_Char_RightSilhouetteLowKick
	.setCharacter:
	ld		(standchar),hl  
  ret

  .endSilhouettekick:               ;on collision change to R_Stand and allow jumping
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
  and   %1111 1110                  ;reset up
	ld		(Controls),a
  jp    Set_R_stand                 ;on collision change to R_Stand  

  .CheckPassThroughWall:
  ld    a,(PlayerAniCount+1)
  or    a
  ret   nz
  inc   a
  ld    (PlayerAniCount+1),a

  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    de,230
  jr    z,.setMaxX
  ld    de,184
  .setMaxX:
  ld    hl,(ClesX)
  sbc   hl,de
  ret   nc                          ;passing through wall disabled when x>230 for normal engine and x>184 for SF2 engine

  ld    hl,(ClesX)
  push  hl
  call  .GoCheck
  pop   hl
  ld    (ClesX),hl
  ret
  
  .GoCheck:
  ld    de,48                       ;move player 48 pixels to the right and then check for a wall
  add   hl,de
  ld    (ClesX),hl

  ld    de,2                        ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   c                           ;return if there is a wall, in this case player cannot move through a wall prior to the end location
  ld    de,14                       ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   c                           ;return if there is a wall, in this case player cannot move through a wall prior to the end location
  
  ld    a,255
  ld    (PlayerAniCount+1),a        ;there is no wall at the end location, so allow player to move to a wall prior to the end location
  ret

RMeditate:
  ld    hl,RightMeditateAnimation - 2
  call  AnimateMeditating           ;animate

  ld    a,(PlayerAniCount+1)
  cp    121-1
  call  z,Set_R_stand               ;at end of meditate change to L_Stand
  jr    LMeditate.VerticalMovement

LMeditate:
  ld    hl,LeftMeditateAnimation - 2
  call  AnimateMeditating           ;animate

  ld    a,(PlayerAniCount+1)
  cp    121-1
  call  z,Set_L_stand               ;at end of meditate change to L_Stand

  .VerticalMovement:
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  and   31
  ld    e,a
  ld    d,0
  ld    hl,VerticalMovementWhileMeditateTable
  add   hl,de
  ld    a,(clesY)
  add   a,(hl)
  ld    (clesY),a

  ld    b,0
  ld    a,(PlayerAniCount+1)
  cp    10
  jr    nc,.EndCheckSmallerThan6
  ld    b,-1
  .EndCheckSmallerThan6:
  cp    110
  jr    c,.EndCheckBiggerThan26
  ld    b,1
  .EndCheckBiggerThan26:
  ld    a,(clesY)
  add   a,b
  ld    (clesY),a
  
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop after running
  
VerticalMovementWhileMeditateTable:
  db    -0,-1,-0,-1,-1,-0,-1,-0
  db    -0,-1,-0,-0,-0,-1,-0,-0
  db    +0,+0,+1,+0,+0,+0,+1,+0
  db    +0,+1,+0,+1,+1,+0,+1,+0
  
LeftMeditateAnimation:
  dw  PlayerSpriteData_Char_LeftMeditate1 
  dw  PlayerSpriteData_Char_LeftMeditate2 

  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate5 
  dw  PlayerSpriteData_Char_LeftMeditate6
  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate5 
  dw  PlayerSpriteData_Char_LeftMeditate6
  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate2
  dw  PlayerSpriteData_Char_LeftMeditate2 
  
RightMeditateAnimation:
  dw  PlayerSpriteData_Char_RightMeditate1 
  dw  PlayerSpriteData_Char_RightMeditate2 

  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate6
  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate6
  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate2
  dw  PlayerSpriteData_Char_RightMeditate2 

;  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
RBouncingBack:
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement

  ld    a,0
  ld    (RunningTablePointer),a
  call  MovePlayerLeft.skipFacingDirection
    
  ld    hl,RightRollingAnimation
  call  AnimateRolling             ;animate
  ret

LBouncingBack:
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement

  ld    a,RunningTablePointerRunRightEndValue-4
  ld    (RunningTablePointer),a
  call  MovePlayerRight.skipFacingDirection
    
  ld    hl,LeftRollingAnimation
  call  AnimateRolling             ;animate
  ret

Charging:
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.RCharging

  .LCharging:
  ld    hl,LeftChargeAnimation
  call  AnimateCharging
  ld    a,(PlayerAniCount)
  cp    2 * 11                      ;check 10th frame
  jr    z,endChargeLeft             ;at end of charge change to L_Stand

  call  SetPrimaryWeaponHitBoxLeftStanding
  
  ;horizontal movement
  ld    a,(PlayerAniCount)
  cp    2 * 04                      ;start moving after the 3d frame
  ret   c
    
  ld    de,-4                       ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc
  jr    endChargeLeft               ;on collision change to R_Stand

  .RCharging:
  ld    hl,RightChargeAnimation
  call  AnimateCharging
  ld    a,(PlayerAniCount)
  cp    2 * 11                      ;check 10th frame
  jp    z,endChargeRight            ;at end of charge change to R_Stand

  call  SetPrimaryWeaponHitBoxRightStanding
  
  ;horizontal movement
  ld    a,(PlayerAniCount)
  cp    2 * 04                      ;start moving after the 3d frame
  ret   c
    
  ld    de,4                        ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc
;  jr    endChargeRight              ;on collision change to R_Stand

  endChargeRight:
	ld		a,(Controls)
  and   %1111 1110                  ;reset up
	ld		(Controls),a
  jp    Set_R_stand                 ;on collision change to R_Stand  

  endChargeLeft:
	ld		a,(Controls)
  and   %1111 1110                  ;reset up
	ld		(Controls),a
  jp    Set_L_stand                 ;on collision change to R_Stand  

LeftChargeAnimation:
  dw  PlayerSpriteData_Char_LeftCharge1 
  dw  PlayerSpriteData_Char_LeftCharge1 
  dw  PlayerSpriteData_Char_LeftCharge2 
  dw  PlayerSpriteData_Char_LeftCharge3 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge6 
  dw  PlayerSpriteData_Char_LeftCharge7 
  dw  PlayerSpriteData_Char_LeftCharge8 
  dw  PlayerSpriteData_Char_LeftCharge8 
  
RightChargeAnimation:
  dw  PlayerSpriteData_Char_RightCharge1 
  dw  PlayerSpriteData_Char_RightCharge1 
  dw  PlayerSpriteData_Char_RightCharge2 
  dw  PlayerSpriteData_Char_RightCharge3 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge5 
  dw  PlayerSpriteData_Char_RightCharge6 
  dw  PlayerSpriteData_Char_RightCharge7 
  dw  PlayerSpriteData_Char_RightCharge8 
  dw  PlayerSpriteData_Char_RightCharge8 
  
Dying:  
  ld    a,(framecounter)
  and   %0000 1000
	ld		hl,PlayerSpriteData_Char_Dying1
  jr    z,.Setchar
	ld		hl,PlayerSpriteData_Char_Dying2
  .Setchar:
	ld		(standchar),hl

;  ld    a,1
  ld    a,(PlayerDead?)
  inc   a
  ld    (PlayerDead?),a
  ret   nz

  call  Set_R_stand
  
  ld    hl,36
  ld    (ClesX),hl
  ld    a,80
  ld    (ClesY),a
  
  ld    hl,MapA04Data       ;area sign
  ld    (WorldMapPointer),hl

  pop   hl                  ;pop the call to this routine
  call  CameraEngine304x216.setR18R19R23andPage  

  xor   a
  ld    (CheckNewPressedControlUpForDoubleJump),a
  call  DisableLineint	
  jp    PlayLogo

LSitPunch:
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
    
  call  SetPrimaryWeaponHitBoxLeftSitting
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,18
  ld    (PlayerAniCount),a
  .EndCheckSpace:
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftSitPunch1
  cp    2
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch2
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch3
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch2
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch1
  .setSprite:
	ld		(standchar),hl
	
	cp    21
	ret   nz
  
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_L_Sit
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_SitPunch
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_L_SitPunch
	jp		Set_L_Attack
  
RSitPunch:
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  SetPrimaryWeaponHitBoxRightSitting
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,18
  ld    (PlayerAniCount),a
  .EndCheckSpace:

  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightSitPunch1
  cp    2
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch2
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch3
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch2
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch1
  .setSprite:
	ld		(standchar),hl

	cp    21
	ret   nz
  
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_R_Sit
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_SitPunch
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_R_SitPunch
	jp		Set_R_Attack

LAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  SetPrimaryWeaponHitBoxLeftStanding
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,20
  ld    (PlayerAniCount),a
  .EndCheckSpace:
  
  ld    a,(AttackRotator)
  or    a
  jp    z,LAttack2
  dec   a
  jp    z,LAttack3
  dec   a
  jp    z,LAttack2
  jp    LAttack3

LAttack3:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch2a
  cp    4
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2b
  cp    7
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2b
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2a
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
	
	.CheckInitiateNewAttack:   
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_L_Stand
  xor   a
  ld    (InitiateNewAttack?),a

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_L_SitPunch
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_Attack
	jp		Set_L_Attack

LAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch1a
  cp    03
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1b
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1c
  cp    08
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2c
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1f
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1g
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1h
  cp    24
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz

  jp    LAttack3.CheckInitiateNewAttack

;LAttack1:
;  ld    a,(PlayerAniCount)
;  inc   a
;  ld    (PlayerAniCount),a

;  ld    hl,PlayerSpriteData_Char_LeftHighKick
;	ld		(standchar),hl
	
;	cp    15
;	ret   nz
;  jp    Set_L_Stand

;LAttack0:
;  ld    a,(PlayerAniCount)
;  inc   a
;  ld    (PlayerAniCount),a

;  ld    hl,PlayerSpriteData_Char_LeftLowKick
;	ld		(standchar),hl
	
;	cp    15
;	ret   nz
;  jp    Set_L_Stand





SWspriteSetNYNXSYSX:
  ;set ny,nx,sy,sx and store addy and addx
  inc   hl                  ;addy
  ;set y
  ld    a,(ClesY)
  add   a,(hl)              ;Addy
;  ld    (ix+1),a            ;y
  ld    (PrimaryWeaponY),a  ;y
  ld    b,a
  ;set y
  
  inc   hl                  ;subx
  ld    e,(hl)              ;subx
  inc   hl                  ;ny
  ld    a,(hl)
;  ld    (ix+7),a            ;ny
  ld    (PrimaryWeaponNY),a ;ny
  add   a,b  
  ld    (PrimaryWeaponYBottom),a
  
  inc   hl                  ;nx
  ld    a,(hl)
;  ld    (ix+8),a            ;nx
  ld    (PrimaryWeaponNX),a ;nx
  ld    c,a
  inc   hl                  ;sy
  ld    a,(hl)
;  ld    (ix+4),a            ;sy  
  ld    (PrimaryWeaponSY),a ;sy
  inc   hl                  ;sx
  ld    a,(hl)
;  ld    (ix+5),a            ;IceWeaponSX_RightSide
  ld    (PrimaryWeaponSX_RightSide),a ;WeaponSX_RightSide
;  add   a,(ix+8)            ;add nx to determine at what point we should copy when copying from right to left
  add   a,c                 ;add nx to determine at what point we should copy when copying from right to left
  dec   a                   ;add nx - 1
;  ld    (ix+6),a            ;IceWeaponSX_LeftSide
  ld    (PrimaryWeaponSX_LeftSide),a ;WeaponSX_LeftSide

  ;set x
  ld    a,(scrollEngine)    ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    z,.engineFound
  ld    a,-17               ;in the SF2 engine, we move all objects 16 pixels more to the left
  .engineFound:  
  inc   a
  add   a,e                 ;SubX
  ld    d,0
  ld    e,a
  ld    hl,(ClesX)
  or    a                   ;reset carry
  sbc   hl,de               ;adjust x starting placement projectile
  ld    e,50
  add   hl,de               ;move 50 pixels to the right
;  ld    a,l
;  bit   0,h
;  jr    z,.SetX
;  ld    a,255
  .SetX:
  ld    (PrimaryWeaponX),hl ;x
  ld    b,0
  add   hl,bc               ;add nx to determine the right side
  ld    (PrimaryWeaponXRightSide),hl ;x  
  ret

AnimatePlayerStopAtEnd:           ;animates player, when end of table is reached, player goes to stand or sit pose
  ld    a,(framecounter)          ;animate every 4 frames
  and   (hl)                      ;animate every x frames
  ex    af,af'

  inc   hl                        ;amount of frames * 2  
  ld    b,(hl)
  inc   hl                        ;left(0) or right(1)
  ld    c,(hl)  
  inc   hl                        ;start sprite data

  ld    a,(PlayerAniCount)
  call  .SetPlayerCharacter

  ex    af,af'
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,8                       ;8 bytes used for pointer to sprite frame address
  ld    (PlayerAniCount),a
  cp    b                         ;amount of frames * 2
  ret   nz

  xor   a
  ld    (PrimaryWeaponActive?),a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PlayerAniCount),a

	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
  xor   a
  sbc   hl,de
  ret   z                         ;return at this point when jumping
  
  ld    a,c                       ;when not jumping switch to stand pose
  or    a
  jp    z,Set_L_Stand
  jp    Set_R_Stand

  .SetPlayerCharacter:  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
    
	ld		(standchar),de
  ret	

AnimatePrimaryAttackWhileJumping: ;animates player, when end of table is reached, player goes to stand or sit pose
  ld    a,(framecounter)          ;animate every 4 frames
  and   (hl)                      ;animate every x frames
  ex    af,af'

  inc   hl                        ;amount of frames * 2  
  ld    b,(hl)
  inc   hl                        ;left(0) or right(1)
  ld    c,(hl)  
  inc   hl                        ;start sprite data

  ld    a,(PlayerAniCount)
  call  .SetPlayerCharacter

  ex    af,af'
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,8                       ;8 bytes used for pointer to sprite frame address
  ld    (PlayerAniCount),a
  cp    b                         ;amount of frames * 2
  ret   nz

  .end:
  xor   a
  ld    (PrimaryWeaponActive?),a    
  ld    (PlayerAniCount),a     
  ret
  
  .SetPlayerCharacter:  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
    
	ld		(standchar),de
  ret	



;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 12*8, 0
                                        ;positioning for the SW sprites:
LeftSwordAttackAnimation:               ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftPunch2b | db 008,040+50,006,012,216+34,106
  dw  PlayerSpriteData_Char_LeftPunch2b | db 008,040+50,006,012,216+34,106
  dw  PlayerSpriteData_Char_LeftPunch2b | db 008,040+50,006,012,216+34,106
  
  dw  PlayerSpriteData_Char_LeftPunch2c | db 002,045+50,010,016,216+09,112
  dw  PlayerSpriteData_Char_LeftPunch2c | db 002,045+50,010,016,216+09,112
  dw  PlayerSpriteData_Char_LeftPunch2c | db 002,045+50,010,016,216+09,112

  dw  PlayerSpriteData_Char_LeftPunch2d | db 002,042+50,009,012,216+10,100
  dw  PlayerSpriteData_Char_LeftPunch2d | db 002,042+50,009,012,216+10,100
  dw  PlayerSpriteData_Char_LeftPunch2d | db 002,042+50,009,012,216+10,100

  dw  PlayerSpriteData_Char_LeftPunch2a | db 003,028+50,005,007,216+24,134
  dw  PlayerSpriteData_Char_LeftPunch2a | db 003,028+50,005,007,216+24,134
  dw  PlayerSpriteData_Char_LeftPunch2a | db 003,028+50,005,007,216+24,134

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 11*8, 0                        
                                        ;positioning for the SW sprites:
LeftDaggerVersion1AttackAnimation:      ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftPunch3a | db 004,030+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3a | db 004,030+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3a | db 004,030+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3a | db 004,030+50,005,009,216+24,203

  dw  PlayerSpriteData_Char_LeftPunch3c | db 004,035+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3c | db 004,035+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3c | db 004,035+50,005,009,216+24,203 
  dw  PlayerSpriteData_Char_LeftPunch3c | db 004,035+50,005,009,216+24,203

  dw  PlayerSpriteData_Char_LeftPunch3b | db 004,033+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3b | db 004,033+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch3b | db 004,033+50,005,009,216+24,203

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 10*8, 0
                                        ;positioning for the SW sprites:  
LeftDaggerVersion2AttackAnimation:      ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftPunch1h | db 007,025+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1h | db 007,025+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1h | db 007,025+50,005,009,216+24,203
  
  dw  PlayerSpriteData_Char_LeftPunch1e | db 003,036+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1e | db 003,036+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1e | db 003,036+50,005,009,216+24,203

  dw  PlayerSpriteData_Char_LeftPunch1f | db 005,034+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1f | db 005,034+50,005,009,216+24,203

  dw  PlayerSpriteData_Char_LeftPunch1g | db 006,029+50,005,009,216+24,203
  dw  PlayerSpriteData_Char_LeftPunch1g | db 006,029+50,005,009,216+24,203

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 11*8, 0
                                             ;positioning for the SW sprites:  
LeftSpearAttackAnimation:                    ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftSpearAttack1 | db 002,037+50,005,013,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack2 | db 003,039+50,005,015,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack3 | db 004,043+50,005,019,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack4 | db 002,050+50,005,026,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack1 | db 002,037+50,005,013,216+24,172
  dw  PlayerSpriteData_Char_LeftSpearAttack1 | db 002,037+50,005,013,216+24,172

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 14*8, 0
                                        ;positioning for the SW sprites:  
LeftAxeAttackAnimation:                 ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftCharge7 | db 006,011+50,009,012,216+21,084 
  dw  PlayerSpriteData_Char_LeftCharge7 | db 006,011+50,009,012,216+21,084
  dw  PlayerSpriteData_Char_LeftCharge7 | db 006,011+50,009,012,216+21,084
   
  dw  PlayerSpriteData_Char_LeftCharge4 | db -15,016+50,010,012,216+21,116
  dw  PlayerSpriteData_Char_LeftCharge4 | db -15,016+50,010,012,216+21,116

  dw  PlayerSpriteData_Char_LeftCharge3 | db -15,033+50,013,012,216+21,107
  dw  PlayerSpriteData_Char_LeftCharge3 | db -15,033+50,013,012,216+21,107

  dw  PlayerSpriteData_Char_LeftCharge5 | db 001,036+50,010,012,216+30,093
  dw  PlayerSpriteData_Char_LeftCharge5 | db 001,036+50,010,012,216+30,093
  dw  PlayerSpriteData_Char_LeftCharge5 | db 001,036+50,010,012,216+30,093
  dw  PlayerSpriteData_Char_LeftCharge5 | db 001,036+50,010,012,216+30,093

  dw  PlayerSpriteData_Char_LeftCharge7 | db 004,031+50,010,010,216+30,083
  dw  PlayerSpriteData_Char_LeftCharge7 | db 004,031+50,010,010,216+30,083
  dw  PlayerSpriteData_Char_LeftCharge7 | db 004,031+50,010,010,216+30,083




;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 12*8, 1
                                        ;positioning for the SW sprites:
RightSwordAttackAnimation:               ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightPunch2b | db 008,006+50,008,012,216+32,116
  dw  PlayerSpriteData_Char_RightPunch2b | db 008,006+50,008,012,216+32,116
  dw  PlayerSpriteData_Char_RightPunch2b | db 008,006+50,008,012,216+32,116
  
  dw  PlayerSpriteData_Char_RightPunch2c | db 002,003+50,010,016,216+00,100
  dw  PlayerSpriteData_Char_RightPunch2c | db 002,003+50,010,016,216+00,100
  dw  PlayerSpriteData_Char_RightPunch2c | db 002,003+50,010,016,216+00,100

  dw  PlayerSpriteData_Char_RightPunch2d | db 002,002+50,009,012,216+00,116
  dw  PlayerSpriteData_Char_RightPunch2d | db 002,002+50,009,012,216+00,116
  dw  PlayerSpriteData_Char_RightPunch2d | db 002,002+50,009,012,216+00,116

  dw  PlayerSpriteData_Char_RightPunch2a | db 003,011+50,005,007,216+24,128
  dw  PlayerSpriteData_Char_RightPunch2a | db 003,011+50,005,007,216+24,128
  dw  PlayerSpriteData_Char_RightPunch2a | db 003,011+50,005,007,216+24,128

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 11*8, 1                        
                                        ;positioning for the SW sprites:
RightDaggerVersion1AttackAnimation:      ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightPunch3a | db 004,011+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3a | db 004,011+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3a | db 004,011+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3a | db 004,011+50,005,009,216+24,229

  dw  PlayerSpriteData_Char_RightPunch3c | db 004,006+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3c | db 004,006+50,005,009,216+24,229 
  dw  PlayerSpriteData_Char_RightPunch3c | db 004,006+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3c | db 004,006+50,005,009,216+24,229

  dw  PlayerSpriteData_Char_RightPunch3b | db 004,008+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3b | db 004,008+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch3b | db 004,008+50,005,009,216+24,229

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 10*8, 1
                                        ;positioning for the SW sprites:  
RightDaggerVersion2AttackAnimation:      ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightPunch1h | db 007,016+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1h | db 007,016+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1h | db 007,016+50,005,009,216+24,229
  
  dw  PlayerSpriteData_Char_RightPunch1e | db 003,005+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1e | db 003,005+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1e | db 003,005+50,005,009,216+24,229

  dw  PlayerSpriteData_Char_RightPunch1f | db 005,007+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1f | db 005,007+50,005,009,216+24,229

  dw  PlayerSpriteData_Char_RightPunch1g | db 006,012+50,005,009,216+24,229
  dw  PlayerSpriteData_Char_RightPunch1g | db 006,012+50,005,009,216+24,229

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 11*8, 1
                                             ;positioning for the SW sprites:  
RightSpearAttackAnimation:                    ;  addy,subx   , ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightSpearAttack1 | db 005,024+50,005,013,216+24,192
  dw  PlayerSpriteData_Char_RightSpearAttack2 | db 003,008+50,005,015,216+24,190
  dw  PlayerSpriteData_Char_RightSpearAttack3 | db 004,008+50,005,019,216+24,186
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack4 | db 002,008+50,005,026,216+24,179
  dw  PlayerSpriteData_Char_RightSpearAttack1 | db 002,025+50,005,013,216+24,192
  dw  PlayerSpriteData_Char_RightSpearAttack1 | db 002,025+50,005,013,216+24,192

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  1, 14*8, 1
                                        ;positioning for the SW sprites:  
RightAxeAttackAnimation:                 ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightCharge7 | db 006,032+50,009,012,216+21,073
  dw  PlayerSpriteData_Char_RightCharge7 | db 006,032+50,009,012,216+21,073
  dw  PlayerSpriteData_Char_RightCharge7 | db 006,032+50,009,012,216+21,073
   
  dw  PlayerSpriteData_Char_RightCharge4 | db -15,027+50,013,012,216+21,107
  dw  PlayerSpriteData_Char_RightCharge4 | db -15,027+50,013,012,216+21,107

  dw  PlayerSpriteData_Char_RightCharge3 | db -15,010+50,010,012,216+21,116
  dw  PlayerSpriteData_Char_RightCharge3 | db -15,010+50,010,012,216+21,116

  dw  PlayerSpriteData_Char_RightCharge5 | db 001,008+50,010,011,216+20,096
  dw  PlayerSpriteData_Char_RightCharge5 | db 001,008+50,010,011,216+20,096
  dw  PlayerSpriteData_Char_RightCharge5 | db 001,008+50,010,011,216+20,096
  dw  PlayerSpriteData_Char_RightCharge5 | db 001,008+50,010,011,216+20,096

  dw  PlayerSpriteData_Char_RightCharge7 | db 004,012+50,010,010,216+30,073
  dw  PlayerSpriteData_Char_RightCharge7 | db 004,012+50,010,010,216+30,073
  dw  PlayerSpriteData_Char_RightCharge7 | db 004,012+50,010,010,216+30,073
 
CheckPrimaryWeaponEdgesFacingLeft:
  ld    a,(SecundaryWeaponActive?)
  or    a
  jr    nz,.Set_L_Stand       ;don't user primary weapon when secundary weapon is active

  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  jr    nz,.Set_L_Stand       ;don't user primary weapon when secundary weapon is active
  
  ld    a,(ClesY)
  cp    200
  jr    nc,.Set_L_Stand       ;don't user primary weapon when y>199 or scoreboard graphics can be erased
  cp    20
  jr    c,.Set_L_Stand        ;don't user primary weapon when y>199 or scoreboard graphics can be erased

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    nz,.SF2Engine         ;minimal border check in the SF2 engine

  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  xor   a
  sbc   hl,de
  jr    c,.Set_L_Stand
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  xor   a
  sbc   hl,bc
  jr    nc,.BruteForceMovementLeft
  .setPrimaryWeaponActive:
  ld    a,1                   ;activate primary weapon
  ld    (PrimaryWeaponActive?),a	  
  ret
  .BruteForceMovementLeft:
  pop     af                  ;pop the call
  jp    BruteForceMovementLeft
  .Set_L_Stand:
  pop     af                  ;pop the call
;  ld    a,(PrimaryWeaponActivatedWhileJumping?)
;  or    a
;  jp    z,Set_L_Stand         ;if you were standing, go back to standing pose

	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
  xor   a
  sbc   hl,de
  jp    nz,Set_L_Stand         ;if you were standing, go back to standing pose
  
  xor   a                     ;if you were jumping, dont change pose, but stop primary weapon
  ld    (ShootArrowWhileJump?),a	
  ld    (PrimaryWeaponActivatedWhileJumping?),a	
  ld    (PrimaryWeaponActive?),a	
  ld    (PlayerAniCount),a
  ret

  .SF2Engine:                 ;this little routine is added, cuz otherwise when standing on the edge of the screen, the primary weapon can go through the edge and appear on the other side of the screen
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  ld    de,20
  sbc   hl,de
  jr    c,.Set_L_Stand
  jp    .setPrimaryWeaponActive

CheckPrimaryWeaponEdgesFacingRight:
  ld    a,(SecundaryWeaponActive?)
  or    a
  jr    nz,.Set_R_Stand       ;don't user primary weapon when secundary weapon is active

  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  jr    nz,.Set_R_Stand       ;don't user primary weapon when secundary weapon is active

  ld    a,(ClesY)
  cp    200
  jr    nc,.Set_R_Stand       ;don't user primary weapon when y>199 or scoreboard graphics can be erased
  cp    20
  jr    c,.Set_R_Stand        ;don't user primary weapon when y>199 or scoreboard graphics can be erased

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    nz,.SF2Engine         ;minimal border check in the SF2 engine

  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  xor   a
  sbc   hl,de
  jr    c,.BruteForceMovementRight
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  xor   a
  sbc   hl,bc
  jr    nc,.Set_R_Stand
  .setPrimaryWeaponActive:
  ld    a,1                   ;activate primary weapon
  ld    (PrimaryWeaponActive?),a	  
  ret
  .BruteForceMovementRight:
  pop     af                  ;pop the call
  jp    BruteForceMovementRight
  .Set_R_Stand:
  pop     af                  ;pop the call

	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
  xor   a
  sbc   hl,de
  jp    nz,Set_R_Stand         ;if you were standing, go back to standing pose

  xor   a                     ;if you were jumping, dont change pose, but stop primary weapon
  ld    (ShootArrowWhileJump?),a	
  ld    (PrimaryWeaponActivatedWhileJumping?),a	
  ld    (PrimaryWeaponActive?),a
  ld    (PlayerAniCount),a  
  ret

  .SF2Engine:                 ;this little routine is added, cuz otherwise when standing on the edge of the screen, the primary weapon can go through the edge and appear on the other side of the screen
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    bc,240                ;right edge
  sbc   hl,bc
  jr    nc,.Set_R_Stand
  jp    .setPrimaryWeaponActive

CheckPrimaryWeaponEdgesFacingLeftWhenSitting:
  ld    a,(SecundaryWeaponActive?)
  or    a
  jr    nz,.Set_L_Sit         ;don't user primary weapon when secundary weapon is active

  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  jr    nz,.Set_L_Sit         ;don't user primary weapon when secundary weapon is active
  
  ld    a,(ClesY)
  cp    200
  jr    nc,.Set_L_Sit         ;don't user primary weapon when y>199 or scoreboard graphics can be erased
  cp    20
  jr    c,.Set_L_Sit          ;don't user primary weapon when y>199 or scoreboard graphics can be erased

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    nz,.SF2Engine         ;minimal border check in the SF2 engine

  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  xor   a
  sbc   hl,de
  jr    c,.Set_L_Sit
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  xor   a
  sbc   hl,bc
  jr    nc,.BruteForceMovementLeft
  .setPrimaryWeaponActive:
  ld    a,1                   ;activate primary weapon
  ld    (PrimaryWeaponActive?),a	  
  ret
  .BruteForceMovementLeft:
  pop     af                  ;pop the call
  jp    BruteForceMovementLeft
  .Set_L_Sit:
  pop     af                  ;pop the call
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jp    z,Set_L_Sit           ;if you were standing, go back to standing pose
  xor   a                     ;if you were jumping, dont change pose, but stop primary weapon
  ld    (PrimaryWeaponActivatedWhileJumping?),a	
  ld    (PrimaryWeaponActive?),a	
  ld    (PlayerAniCount),a
  ret

  .SF2Engine:                 ;this little routine is added, cuz otherwise when standing on the edge of the screen, the primary weapon can go through the edge and appear on the other side of the screen
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  ld    de,20
  sbc   hl,de
  jr    c,.Set_L_Sit
  jp    .setPrimaryWeaponActive

CheckPrimaryWeaponEdgesFacingRightWhenSitting:
  ld    a,(SecundaryWeaponActive?)
  or    a
  jr    nz,.Set_R_Sit         ;don't user primary weapon when secundary weapon is active

  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  jr    nz,.Set_R_Sit         ;don't user primary weapon when secundary weapon is active

  ld    a,(ClesY)
  cp    200
  jr    nc,.Set_R_Sit         ;don't user primary weapon when y>199 or scoreboard graphics can be erased
  cp    20
  jr    c,.Set_R_Sit          ;don't user primary weapon when y>199 or scoreboard graphics can be erased

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    nz,.SF2Engine         ;minimal border check in the SF2 engine

  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont use weapon
  xor   a
  sbc   hl,de
  jr    c,.BruteForceMovementRight
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  xor   a
  sbc   hl,bc
  jr    nc,.Set_R_Sit
  .setPrimaryWeaponActive:
  ld    a,1                   ;activate primary weapon
  ld    (PrimaryWeaponActive?),a	  
  ret
  .BruteForceMovementRight:
  pop     af                  ;pop the call
  jp    BruteForceMovementRight
  .Set_R_Sit:
  pop     af                  ;pop the call
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jp    z,Set_R_Sit           ;if you were standing, go back to standing pose
  xor   a                     ;if you were jumping, dont change pose, but stop primary weapon
  ld    (PrimaryWeaponActivatedWhileJumping?),a	
  ld    (PrimaryWeaponActive?),a
  ld    (PlayerAniCount),a  
  ret
  
  .SF2Engine:                 ;this little routine is added, cuz otherwise when standing on the edge of the screen, the primary weapon can go through the edge and appear on the other side of the screen
  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    bc,240                ;right edge
  sbc   hl,bc
  jr    nc,.Set_R_Sit
  jp    .setPrimaryWeaponActive





  









LDaggerAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,38                 ;left edge
  ld    bc,280                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    a,(DaggerRandomizer)
	rrca                        ;check bit 0
  ld    hl,LeftDaggerVersion1AttackAnimation-3
  jr    c,.goAnimate
  ld    hl,LeftDaggerVersion2AttackAnimation-3
  .goAnimate:
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX
  
RDaggerAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,16                 ;left edge
  ld    bc,265                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    a,(DaggerRandomizer)
	rrca                        ;check bit 0
  ld    hl,RightDaggerVersion1AttackAnimation-3
  jr    c,.goAnimate
  ld    hl,RightDaggerVersion2AttackAnimation-3
  .goAnimate:
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX

LSwordAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,46                 ;left edge
  ld    bc,282                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    hl,LeftSwordAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX
  
RSwordAttack:  
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,11                 ;left edge
  ld    bc,255                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    hl,RightSwordAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX

LAxeAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,40                 ;left edge
  ld    bc,268                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    hl,LeftAxeAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX
  
RAxeAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,36                 ;left edge
  ld    bc,267                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    hl,RightAxeAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX
  
LSpearAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,52                 ;left edge
  ld    bc,294                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    hl,LeftSpearAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX
  
RSpearAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  .skipEndMovePlayer:

  ld    de,26                 ;left edge
  ld    bc,255                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    hl,RightSpearAttackAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose
  jp    SWspriteSetNYNXSYSX

RAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  SetPrimaryWeaponHitBoxRightStanding
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,20
  ld    (PlayerAniCount),a
  .EndCheckSpace:

;  jp    RAttack3

  ld    a,(AttackRotator)
  or    a
  jp    z,RAttack2
  dec   a
  jp    z,RAttack3
  dec   a
  jp    z,RAttack2
  jp    RAttack3

RAttack3:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch2a
  cp    4
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2b
  cp    7
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2b
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2a
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
	
	.CheckInitiateNewAttack:   
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_R_Stand
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_R_SitPunch
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_Attack
	jp		Set_R_Attack

RAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch1a
  cp    03
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1b
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1c
  cp    08
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2c
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1f
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1g
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1h
  cp    24
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz

  jp    RAttack3.CheckInitiateNewAttack

;RAttack1:
;  ld    a,(PlayerAniCount)
;  inc   a
;  ld    (PlayerAniCount),a

;  ld    hl,PlayerSpriteData_Char_RightHighKick
;	ld		(standchar),hl
	
;	cp    15
;	ret   nz
;  jp    Set_R_Stand

;RAttack0:
;  ld    a,(PlayerAniCount)
;  inc   a
;  ld    (PlayerAniCount),a

;  ld    hl,PlayerSpriteData_Char_RightLowKick
;	ld		(standchar),hl
	
;	cp    15
;	ret   nz
;  jp    Set_R_Stand


;RunningTablePointerWhenHit:           ds  1       ;this variable is used to decide how player moves when hit
;RunningTablePointer:                  db  18 ;12
;RunningTablePointerCenter:            equ 18 ;12
;RunningTablePointerRightEnd:          equ 38 ;26
;RunningTablePointerRunLeftEndValue:   equ 6
;RunningTablePointerRunRightEndValue:  equ 32 ;20
;RunningTable1:
;       [run  L]                   C                   [run  R]
;  dw    -1,-1,-1,-1,-1,-1,-1,-1,-1,0,+1,+1,+1,+1,+1,+1,+1,+1,+1
;  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2

CheckMoveHorizontallyWhenHitFaceLeft:     
  ld    a,RunningTablePointerRunRightEndValue-2
  ld    (RunningTablePointer),a      
  ld    a,(RunningTablePointerWhenHit)
  sub   5
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl3
  jr    c,CheckMoveHorizontallyWhenHitFaceRight.TableFound
  sub   11
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl2
  jr    c,CheckMoveHorizontallyWhenHitFaceRight.TableFound
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl1
  jp    CheckMoveHorizontallyWhenHitFaceRight.TableFound
  
CheckMoveHorizontallyWhenHitFaceRight:  
  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a
  ld    a,(RunningTablePointerWhenHit)
  sub   25
  ld    hl,.MoveTabl1
  jr    c,.TableFound
  sub   07
  ld    hl,.MoveTabl2
  jr    c,.TableFound
  ld    hl,.MoveTabl3
  .TableFound:
  
  ld    a,(framecounter)
  and   3
  ld    d,0
  ld    e,a
  add   hl,de
  
  ld    a,(hl)
  or    a
  ret
  .MoveTabl1:   db 0,0,0,1 ;00-24
  .MoveTabl2:   db 0,1,0,1 ;25-36
  .MoveTabl3:   db 1,1,1,1 ;36->

LBeingHit:
  call  CheckMoveHorizontallyWhenHitFaceLeft                         ;out: z-> don't move
  call  nz,MovePlayerRight.skipFacingDirection
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;    
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    24
;  jp    z,Set_L_Stand  
  jp    z,Set_Fall

  ld    hl,PlayerSpriteData_Char_LeftBeingHit1
  cp    08
  jp    c,.SetCharacter
  cp    16
  jp    nc,.SetCharacter
  ld    hl,PlayerSpriteData_Char_LeftBeingHit2
  .SetCharacter:
	ld		(standchar),hl

  ld    a,075                                       ;75 frames invulnerable after being hit
  ld    (PlayerInvulnerable?),a
  ret

RBeingHit:
  call  CheckMoveHorizontallyWhenHitFaceRight                         ;out: z-> don't move
  call  nz,MovePlayerLeft.skipFacingDirection
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;    
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    24
;  jp    z,Set_R_Stand  
  jp    z,Set_Fall
  
  ld    hl,PlayerSpriteData_Char_RightBeingHit1
  cp    08
  jp    c,.SetCharacter
  cp    16
  jp    nc,.SetCharacter
  ld    hl,PlayerSpriteData_Char_RightBeingHit2
  .SetCharacter:
	ld		(standchar),hl

  ld    a,075                                       ;75 frames invulnerable after being hit
  ld    (PlayerInvulnerable?),a
  ret

RRolling:
  call  SetPrimaryWeaponHitBoxRightSitting

  ld    a,(PlayerAniCount+1)
  inc   a
  cp    100
  jp    z,.endRollingRight          ;end rolling after 100 frames
  ld    (PlayerAniCount+1),a
  cp    4
  jp    c,.Sit                      ;the first 4 frames show sitting pose
  .ContinueRollingWhenCollisionTopFound:

  ld    hl,RightRollingAnimation
  call   AnimateRolling             ;animate

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadderWhileRolling;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit  

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		0,a                         ;cursor up pressed ?
	jr		nz,.UpPressed
    
	ld		a,(Controls)
	bit		1,a                         ;cursor down pressed ?
	jp		nz,.DownPressed             ;check stairs or ladders
	bit		3,a                         ;cursor right pressed ?
	jp		nz,MovePlayerRight
	bit		2,a                         ;cursor left pressed ?
	jp		nz,Set_L_Rolling.SkipPlayerAniCount
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop when not moving horizontally

  .DownPressed:                     ;check stairs or ladders
  call  CheckClimbStairsDown  
  jp    RSitting.CheckLadder

  .UpPressed:                       ;jump and check stairs or ladders

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2         ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z

  xor   a                             ;deactivate hitbox that rolling uses if you jump while rolling
  ld    (PrimaryWeaponActive?),a    
	call  Set_jump
  call  CheckClimbLadderUp	
	jp    CheckClimbStairsUp    

  .sit:
  ld    de,PlayerSpriteData_Char_RightSitting  
	ld		(standchar),de
  ret

  .endRollingRight:
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.ContinueRollingWhenCollisionTopFound

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.ContinueRollingWhenCollisionTopFound

  jp    Set_R_Stand                 ;end rolling after 100 frames
  
  .Set_Fall:                        ;there is a little bug when falling from an object after rolling where players gets snapped back on top of the object. So move player 2 pixels to the right when falling
  ;if this turns out to be annoying, then add the above check and only inc/dec hl if there is a ceiling at eye height
  ld    hl,(clesx)
  inc   hl    
  inc   hl    
  inc   hl    
  inc   hl    
  ld    (clesx),hl  
  jp    Set_Fall

LRolling:
  call  SetPrimaryWeaponHitBoxLeftSitting

  ld    a,(PlayerAniCount+1)
  inc   a
  cp    100
  jp    z,.endRollingLeft           ;end rolling after 100 frames
  ld    (PlayerAniCount+1),a
  cp    4
  jp    c,.Sit                      ;the first 4 frames show sitting pose
  
  .ContinueRollingWhenCollisionTopFound:
  ld    hl,LeftRollingAnimation
  call   AnimateRolling             ;animate

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadderWhileRolling;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit  

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		0,a                         ;cursor up pressed ?
	jr		nz,.UpPressed
    
	ld		a,(Controls)
	bit		1,a                         ;cursor down pressed ?
	jp		nz,.DownPressed             ;check stairs or ladders
	bit		2,a                         ;cursor left pressed ?
	jp		nz,MovePlayerLeft 
	bit		3,a                         ;cursor right pressed ?
	jp		nz,Set_R_Rolling.SkipPlayerAniCount
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop when not moving horizontally

  .DownPressed:                     ;check stairs or ladders
  call  CheckClimbStairsDown  
  jp    RSitting.CheckLadder

  .UpPressed:                       ;jump and check stairs or ladders
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2         ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z

  xor   a                             ;deactivate hitbox that rolling uses if you jump while rolling
  ld    (PrimaryWeaponActive?),a  
	call  Set_jump
  call  CheckClimbLadderUp	
	jp    CheckClimbStairsUp    

  .sit:
  ld    de,PlayerSpriteData_Char_LeftSitting  
	ld		(standchar),de
  ret

  .endRollingLeft:
  
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.ContinueRollingWhenCollisionTopFound

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.ContinueRollingWhenCollisionTopFound  
  
  jp    Set_L_Stand                 ;end rolling after 100 frames
  
  .Set_Fall:                        ;there is a little bug when falling from an object after rolling where players gets snapped back on top of the object. So move player 2 pixels to the right when falling
  ;if this turns out to be annoying, then add the above check and only inc/dec hl if there is a ceiling at eye height
  ld    hl,(clesx)
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  ld    (clesx),hl  
  jp    Set_Fall
      
LeftRollingAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftRolling1 
  dw  PlayerSpriteData_Char_LeftRolling2 
  dw  PlayerSpriteData_Char_LeftRolling3 
  dw  PlayerSpriteData_Char_LeftRolling4 
  dw  PlayerSpriteData_Char_LeftRolling5 
  dw  PlayerSpriteData_Char_LeftRolling6 
  dw  PlayerSpriteData_Char_LeftRolling7 
  dw  PlayerSpriteData_Char_LeftRolling8 
  dw  PlayerSpriteData_Char_LeftRolling9 
  dw  PlayerSpriteData_Char_LeftRolling10 
  dw  PlayerSpriteData_Char_LeftRolling11 
  dw  PlayerSpriteData_Char_LeftRolling12 
    
RightRollingAnimation:
  dw  PlayerSpriteData_Char_RightRolling1 
  dw  PlayerSpriteData_Char_RightRolling2 
  dw  PlayerSpriteData_Char_RightRolling3 
  dw  PlayerSpriteData_Char_RightRolling4 
  dw  PlayerSpriteData_Char_RightRolling5 
  dw  PlayerSpriteData_Char_RightRolling6 
  dw  PlayerSpriteData_Char_RightRolling7 
  dw  PlayerSpriteData_Char_RightRolling8 
  dw  PlayerSpriteData_Char_RightRolling9 
  dw  PlayerSpriteData_Char_RightRolling10 
  dw  PlayerSpriteData_Char_RightRolling11
  dw  PlayerSpriteData_Char_RightRolling12
  


RPushing:
;  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall
;  .EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;

;  ld    a,(NewPrContr)
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,.UpPressed

;	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_L_attack3


	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		3,a           ;cursor right pressed ?
;	jp		nz,.PushingLeft
;  jp    Set_L_Stand
	jp		z,Set_R_Stand
  
  .PushingLeft:
  call  MovePlayerRight     ;out: c-> collision detected
;  jp    c,Set_R_stand       ;on collision change to R_Stand
  
;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall  
;  .EndCheckSnapToPlatform:
  
  ld    hl,RightPushingAnimation
  jp    AnimatePushing  

  .DownPressed:
	call	Set_R_sit
  call  CheckClimbStairsDown  
  ret

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp	
	call  CheckClimbStairsUp    
  ret
  
LPushing:
;  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall
;  .EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;

;  ld    a,(NewPrContr)
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,.UpPressed

;	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_L_attack3


	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
;	jp		nz,.PushingLeft
;  jp    Set_L_Stand
	jp		z,Set_L_Stand
  
  .PushingLeft:
  call  MovePlayerLeft      ;out: c-> collision detected
;  jp    c,Set_R_stand       ;on collision change to R_Stand
  
;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall  
;  .EndCheckSnapToPlatform:
  
  ld    hl,LeftPushingAnimation
  jp    AnimatePushing  

  .DownPressed:
	call	Set_L_sit
  call  CheckClimbStairsDown  
  ret

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp	
	call  CheckClimbStairsUp    
  ret

LeftPushingAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftPush1 
  dw  PlayerSpriteData_Char_LeftPush2 
  dw  PlayerSpriteData_Char_LeftPush3 
  dw  PlayerSpriteData_Char_LeftPush4 
  dw  PlayerSpriteData_Char_LeftPush5 
  dw  PlayerSpriteData_Char_LeftPush6 
  dw  PlayerSpriteData_Char_LeftPush7 
  dw  PlayerSpriteData_Char_LeftPush8 
  dw  PlayerSpriteData_Char_LeftPush9 
    
RightPushingAnimation:
  dw  PlayerSpriteData_Char_RightPush1 
  dw  PlayerSpriteData_Char_RightPush2 
  dw  PlayerSpriteData_Char_RightPush3 
  dw  PlayerSpriteData_Char_RightPush4 
  dw  PlayerSpriteData_Char_RightPush5 
  dw  PlayerSpriteData_Char_RightPush6 
  dw  PlayerSpriteData_Char_RightPush7 
  dw  PlayerSpriteData_Char_RightPush8 
  dw  PlayerSpriteData_Char_RightPush9 

ClimbStairsRightUp:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.ClimbUp
	bit		1,a           ;cursor down pressed ?
	jp		nz,.ClimbDown
	bit		2,a           ;cursor left pressed ?
	jp		nz,.ClimbDown
	bit		3,a           ;cursor right pressed ?
	jp		nz,.ClimbUp

;  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
;	jp		Set_L_stand
  ret

  .ClimbDown:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    z,.PlayerFacingLeft

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,-6
  add   hl,de
  ld    (ClesX),hl
  
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl  
  .PlayerFacingLeft:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
      
  ld    a,(ClesY)
  inc   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  dec   hl
  ld    (ClesX),hl

  ld    hl,LeftRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing down, if not, then run left
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+13   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ;check if there are still stairs when climbing down, if not, then run left
  ld    b,YaddFeetPlayer+08    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+05   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc
  
  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_L_Run
  

  .ClimbUp:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.PlayerFacingRight

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,+6
  add   hl,de
  ld    (ClesX),hl

	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl  
  .PlayerFacingRight:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  
  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  inc   hl
  ld    (ClesX),hl

  ld    hl,RightRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer+07    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+0   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc
  
  ld    a,RunningTablePointerRunRightEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_R_Run


ClimbStairsLeftUp:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.ClimbUp
	bit		1,a           ;cursor down pressed ?
	jp		nz,.ClimbDown
	bit		2,a           ;cursor left pressed ?
	jp		nz,.ClimbUp
	bit		3,a           ;cursor right pressed ?
	jp		nz,.ClimbDown

;  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
;	jp		Set_L_stand
  ret

  .ClimbDown:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.PlayerFacingRight

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,6
  add   hl,de
  ld    (ClesX),hl
  
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl  
  .PlayerFacingRight:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
      
  ld    a,(ClesY)
  inc   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  inc   hl
  ld    (ClesX),hl

  ld    hl,RightRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing down, if not, then run right
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ;check if there are still stairs when climbing down, if not, then run right
  ld    b,YaddFeetPlayer+08    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+10   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc

  ld    a,RunningTablePointerRunRightEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_R_Run

  .ClimbUp:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    z,.PlayerFacingLeft

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,-6
  add   hl,de
  ld    (ClesX),hl

	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl  
  .PlayerFacingLeft:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  
  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  dec   hl
  ld    (ClesX),hl

  ld    hl,LeftRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+7   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer+07    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+15   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc

  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_L_Run  
  

ClimbUpMovementTable:
  db    -0,-0,-0,-1
  db    -1,-1,-2,-2
  db    -2,-3,-3,-3
  db    -3,-2,-1,+0
  db    +0,+1,+2,+2
  db    +0,+0,+0,+0,-100
ClimbUp:                          ;jump of the top of the ladder onto the platform above/ end climb
  ld    a,(PlayerAniCount+1)
  ld    d,0
  ld    e,a
  ld    hl,ClimbUpMovementTable
  add   hl,de

  ld    a,(Clesy)
  add   a,(hl)
  ld    (Clesy),a

;animate
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  and   3
  ret   nz
    
  ld    hl,ClimbuPAnimation-2  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 06                    ;05 frame addresses
  jr    z,.EndClimbUp
  ld    (PlayerAniCount),a
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)    
	ld		(standchar),de
  ret	

  .EndClimbUp:   
  ld    a,(PlayerFacingRight?)
  or    a
  jp    nz,Set_R_Stand
  jp    Set_L_Stand
    
ClimbuPAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_Climbing9 
  dw  PlayerSpriteData_Char_Climbing10 
  dw  PlayerSpriteData_Char_Climbing11
  dw  PlayerSpriteData_Char_Climbing12
  dw  PlayerSpriteData_Char_Climbing13

FloorFoundWhileClimbing:    ;floor below player is found, go to R_stand or L_stand
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_stand
  jp    Set_R_stand

Climb:
  call  CheckFloor          ;out: z-> floor, c-> no floor. check if there is floor under the player
  jr    z,FloorFoundWhileClimbing
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		2,a           ;cursor left pressed ?
	jp		nz,.LeftPressed
	bit		3,a           ;cursor right pressed ?
	jp		nz,.RightPressed

 ;check for a ladder when climbing up. If no ladder is found, jump off the top of the ladder
  ld    b,YaddFeetPlayer-20 ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2 ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jp    nz,Set_ClimbUp

  ld    b,0           ;vertical movement
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		z,.EndCheckUpPressed
  dec   b
.EndCheckUpPressed:
	bit		1,a           ;cursor down pressed ?
	jp		z,.EndCheckDownPressed
  inc   b
.EndCheckDownPressed:

  ld    a,b
  or    a
  ret   z

  ld    a,(Clesy)
  add   a,b
  ld    (Clesy),a
  call  AnimateClimbing
  ret

.RightPressed:
  call  Set_Fall
  ld    a,RunningTablePointerRightEnd-2
  ld    (RunningTablePointer),a
  ret

.LeftPressed:
  call  Set_Fall
  xor   a
  ld    (RunningTablePointer),a
  ret

ClimbDown:
  ld    a,(Clesy)
  inc   a
  ld    (Clesy),a

  call  AnimateClimbing
  ld    a,(PlayerAniCount+1)
  cp    32
  jp    z,Set_Climb               ;only if we are in ClimbDown, jump to Set_Climb at frame 32.
  ret

AnimateClimbing:
;animate
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  and   7                         ;animate every 8 frames
  ret   nz
    
  ld    hl,ClimbAnimation  
  ld    a,(PlayerAniCount)
  inc   a
  and   7
  ld    (PlayerAniCount),a
  add   a,a                       ;2 bytes used for pointer to sprite frame address

  ld    d,0
  ld    e,a
  add   hl,de

  ld    e,(hl)
  inc   hl
  ld    d,(hl)    
	ld		(standchar),de
  ret	
   
ClimbAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_Climbing1 
  dw  PlayerSpriteData_Char_Climbing2 
  dw  PlayerSpriteData_Char_Climbing3 
  dw  PlayerSpriteData_Char_Climbing4 
  dw  PlayerSpriteData_Char_Climbing5 
  dw  PlayerSpriteData_Char_Climbing6 
  dw  PlayerSpriteData_Char_Climbing7 
  dw  PlayerSpriteData_Char_Climbing8 
  
MoveHorizontallyWhileJump:
  ld    b,0                 ;horizontal movement

	ld		a,(Controls)
	bit		2,a                 ;cursor left pressed ?
  jp    z,.EndCheckLeftPressed
  dec   b
  .EndCheckLeftPressed:
	bit		3,a           ;cursor right pressed ?
  jp    z,.EndCheckRightPressed
  inc   b
  .EndCheckRightPressed:

  ld    a,b
  or    a
  jp    m,MovePlayerLeft
  jp    z,EndMovePlayerHorizontally
  jp    MovePlayerRight

AnimateWhileJump:
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,.AnimateJumpFacingLeft

.AnimateJumpFacingRight:
  ld    a,(ShootArrowWhileJump?)
  or    a
  jp    nz,ShootArrowWhileJumpRight

  ld    a,(ShootMagicWhileJump?)
  or    a
  jp    nz,RShootWater

  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jp    nz,.PrimaryAttackWhileJumpRight

  ld    a,(DoubleJumpAvailable?)
  or    a
  jp    z,.RollingJumpRight

  ld    a,(JumpSpeed)
  add   a,2
	ld		hl,PlayerSpriteData_Char_RightJump1
	jp    m,.SetRightJumpAnimationFrame  
  cp    3
	ld		hl,PlayerSpriteData_Char_RightJump2
	jr    c,.SetRightJumpAnimationFrame  
	.LastJumpFrameRight:
	ld		hl,PlayerSpriteData_Char_RightJump3
	.SetRightJumpAnimationFrame:
	ld		(standchar),hl
  ret

.PrimaryAttackWhileJumpRight:
  ld    a,(CurrentPrimaryWeapon)                ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
  or    a
  jp    z,RSpearAttack.skipEndMovePlayer
  dec   a
  jp    z,RSwordAttack.skipEndMovePlayer
  dec   a
  jp    z,RDaggerAttack.skipEndMovePlayer
  dec   a
  jp    z,RAxeAttack.skipEndMovePlayer
  dec   a
  jr    z,.HandleKickWhileJumpRightAnimation
  
  .HandleKickWhileJumpRightAnimation:
  ;activate primary weapon, enable it's hitbox detection with enemies
  call  SetPrimaryWeaponHitBoxRightStanding

  ld    a,(PrimaryWeaponActivatedWhileJumping?)                ;kicking while jumping has a certain duration. If PrimaryWeaponActive? reaches 0 the kick ends
  dec   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a

  sub   KickWhileJumpDuration-2                 ;only set kicking pose once, so it doesn't change from highkick to lowkick mid air
  ret   nz
  ld    a,(JumpSpeed)
  or    a
	ld		hl,PlayerSpriteData_Char_RightHighKick
	jp    m,.GoKickRight
	ld		hl,PlayerSpriteData_Char_RightLowKick	
	.GoKickRight:
	ld		(standchar),hl
  ret
 
.RollingJumpRight:
  ld    a,(JumpSpeed)
  sub   a,5
  jp    p,.LastJumpFrameRight
  
  ld    hl,RightRollingAnimation
  jp    AnimateRolling  
  ret

.AnimateJumpFacingLeft:
  ld    a,(ShootArrowWhileJump?)
  or    a
  jp    nz,ShootArrowWhileJumpLeft

  ld    a,(ShootMagicWhileJump?)
  or    a
  jp    nz,LShootWater

  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jp    nz,.PrimaryAttackWhileJumpLeft

  ld    a,(DoubleJumpAvailable?)
  or    a
  jp    z,.RollingJumpLeft

  ld    a,(JumpSpeed)
  add   a,2
	ld		hl,PlayerSpriteData_Char_LeftJump1
	jp    m,.SetLeftJumpAnimationFrame  
  cp    3
	ld		hl,PlayerSpriteData_Char_LeftJump2
	jr    c,.SetLeftJumpAnimationFrame  
	.LastJumpFrameLeft:
	ld		hl,PlayerSpriteData_Char_LeftJump3
	.SetLeftJumpAnimationFrame:
	ld		(standchar),hl
  ret

.PrimaryAttackWhileJumpLeft:
  ld    a,(CurrentPrimaryWeapon)                ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
  or    a
  jp    z,LSpearAttack.skipEndMovePlayer
  dec   a
  jp    z,LSwordAttack.skipEndMovePlayer
  dec   a
  jp    z,LDaggerAttack.skipEndMovePlayer
  dec   a
  jp    z,LAxeAttack.skipEndMovePlayer
  dec   a
  jr    z,.HandleKickWhileJumpLeftAnimation
  
  .HandleKickWhileJumpLeftAnimation:
  ;activate primary weapon, enable it's hitbox detection with enemies  
  call  SetPrimaryWeaponHitBoxLeftStanding

  ld    a,(PrimaryWeaponActivatedWhileJumping?)                ;kicking while jumping has a certain duration. If PrimaryWeaponActive? reaches 0 the kick ends
  dec   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a

  sub   KickWhileJumpDuration-2                 ;only set kicking pose once, so it doesn't change from highkick to lowkick mid air
  ret   nz
  ld    a,(JumpSpeed)
  or    a
	ld		hl,PlayerSpriteData_Char_LeftHighKick
	jp    m,.GoKickLeft
	ld		hl,PlayerSpriteData_Char_LeftLowKick	
	.GoKickLeft:
	ld		(standchar),hl
  ret
  
.RollingJumpLeft:
  ld    a,(JumpSpeed)
  sub   a,5
  jp    p,.LastJumpFrameLeft

  ld    hl,LeftRollingAnimation
  jp    AnimateRolling  

;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  3, 4*8, 0
                                                    ;positioning for the SW sprites:
LeftJumpingPresentBowAnimation:                    ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_LeftJumpShootArrow1 | db -04,011+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftJumpShootArrow2 | db -04,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftJumpShootArrow3 | db -04,014+63,013,003,216+19,028
  dw  PlayerSpriteData_Char_LeftJumpShootArrow4 | db -04,014+63,013,003,216+19,028  
  
ShootArrowWhileJumpLeft:
  ld    de,30                 ;left edge
  ld    bc,284                ;right edge
  call  CheckPrimaryWeaponEdgesFacingLeft
;Animate
  ld    hl,LeftJumpingPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetLShootArrowWhenJumping
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX

SetLShootArrowWhenJumping:
  ;put weapon
  ld    a,-ArrowSpeed
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-29                ;normal engine
  jr    z,.engineFound
  ld    b,-24                ;SF2 engine  
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a

  ld    a,(ClesY)
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+17
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a
  .end:
  xor   a
  ld    (ShootArrowWhileJump?),a
  ret  
  
  
  
  
  
  
  
  
  
  
  
  
;animate every x frames, amount of frames * 2, left(0) or right(1)
  db  3, 4*8, 1
                                                    ;positioning for the SW sprites:
RightJumpingPresentBowAnimation:                    ;  addy,subx, ny ,nx ,sy   ,sx
  dw  PlayerSpriteData_Char_RightJumpShootArrow1 | db -05,011+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightJumpShootArrow2 | db -05,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightJumpShootArrow3 | db -05,008+50,013,003,216+19,030
  dw  PlayerSpriteData_Char_RightJumpShootArrow4 | db -05,008+50,013,003,216+19,030  
  
ShootArrowWhileJumpRight:
  ld    de,11                 ;left edge
  ld    bc,264                ;right edge
  call  CheckPrimaryWeaponEdgesFacingRight
;Animate
  ld    hl,RightJumpingPresentBowAnimation-3
  call  AnimatePlayerStopAtEnd      ;animates player, when end of table is reached, player goes to stand or sit pose

  ld    a,(PrimaryWeaponActive?)    ;check if bow animation ended, if so, shoot arrow
  or    a
  jp    z,SetRShootArrowWhenJumping
  
  ;little hackjob here, set PrimaryWeaponActive to 128 for the bow animation (not to conflict with punch on HandlePlayerWeapons:) 
  ld    a,128
  ld    (PrimaryWeaponActive?),a    ;check if bow animation ended, if so, shoot arrow
  jp    SWspriteSetNYNXSYSX


SetRShootArrowWhenJumping:
  ;put weapon
  ld    a,ArrowSpeed
  ld    (SecundaryWeaponActive?),a

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    b,-11                ;normal engine
  jr    z,.engineFound
  ld    b,7                   ;SF2 engine. If this value is lower than 7, an arrow is not put in screen when standing on the left edge of the screen
  .engineFound:
  
  ld    a,(ClesX)
  add   a,b
  ld    (SecundaryWeaponX),a
  
  ld    a,(ClesY)
  ld    (SecundaryWeaponY),a
  ld    (SecundaryWeaponYBottom),a
    
  ld    a,1
  ld    (SecundaryWeaponNY),a
  ld    a,216+16
  ld    (SecundaryWeaponSY),a
  ld    a,030
  ld    (SecundaryWeaponSX_RightSide),a
  ld    a,030+15
  ld    (SecundaryWeaponSX_LeftSide),a

  xor   a
  ld    (ShootArrowWhileJump?),a
  ret
  
CheckSnapToStairsWhileJump:
;check if there are stairs when pressing up, if so climb the stairs.
;[Check ladder going Right UP]
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08-08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  jp    z,.stairsfoundrightup

;  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+08   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  sub   3                   ;check for tilenr 4=stairsleftup
;  ret   nz

  ;now do the same check, but 1 tile to the right
  inc   hl                  ;1 tile to the right
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  sub   4                   ;check for tilenr 4=stairsleftup
  ret   nz

.stairsfoundleftup:  
  pop   af                    ;pop the call  

	call  Set_Stairs_Climb_LeftUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    a,(ClesY)
  and   %1111 1000
  dec   a
  ld    (ClesY),a

  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z
  
  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret  

.stairsfoundrightup:
  pop   af                    ;pop the call  

	call  Set_Stairs_Climb_RightUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    a,(ClesY)
  and   %1111 1000
  dec   a
  ld    (ClesY),a

  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08-08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   z
  
  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret  

Jump:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;  call  .HandlePrimaryAttackHitboxWhileJump        ;if player kicks in the air, enable hitbox and set hixbox coordinates
  call  AnimateWhileJump
  call  MoveHorizontallyWhileJump
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump
  call  .VerticalMovement
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump

  ld    a,(NewPrContr)
	bit		4,a           ;trig a pressed ?
	jp    nz,.SetPrimaryAttackWhileJump
	bit		5,a           ;trig b pressed ?
	jp    nz,.SetShootMagicWhileJump
	bit		0,a           ;cursor up pressed ?
	jp    nz,.CheckJumpOrClimbLadder  ;while jumping player can double jump can snap to a ladder and start climbing
  ret

.SetPrimaryAttackWhileJump:             ;trigger a pressed
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  ret   nz                              ;wait for previous primary attack to end

  ld    a,(CurrentPrimaryWeapon)        ;0=punch/kick, 1=sword, 2=dagger, 3=axe, 4=spear
  or    a
  jr    z,.SkipCheckSecundaryWeaponActive

  ld    a,(SecundaryWeaponActive?)      ;wait for secundary weapon to end
  or    a
  ret   nz
  .SkipCheckSecundaryWeaponActive:

  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  ret   nz

  ld    a,KickWhileJumpDuration         ;this is only used in case kicking, otherwise a=1 is sufficient
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  xor   a
  ld    (PlayerAniCount),a
  ret

.SetShootMagicWhileJump:
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  ret   nz                              ;don't shoot secundary attack when primary attack is busy

  ld    a,(CurrentMagicWeapon)        ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  cp    4
  jr    z,.Arrow
  cp    5
  jr    z,.Shootmagic
  cp    7
  ret   c
  cp    10
  ret   nc

  .Shootmagic:
  ld    a,(ShootMagicWhileJump?)      ;don't shoot if already shooting
  or    a
  ret   nz

  xor   a
  ld    (PlayerAniCount),a  
  ld    a,1
  ld    (ShootMagicWhileJump?),a  
  ret

  .Arrow:
  ld    a,(ShootArrowWhileJump?)
  or    a
  ret   nz                            ;don't shoot if already presenting bow
  ld    a,(SecundaryWeaponActive?)
  or    a
  ret   nz                            ;don't shoot if arrow is already in play

  xor   a
  ld    (PlayerAniCount),a    
  ld    a,1
  ld    (ShootArrowWhileJump?),a
  ret

.VerticalMovement:
  ;as soon as up is released, player stops jumping up. This way the jump height can be controlled
  ld    hl,JumpSpeed
  bit   7,(hl)
  jr    z,.EndCheckUpPressed  ;check if jump speed is positive
  
	ld		a,(Controls)
	rrca                        ;cursor up pressed ?
  jr    c,.EndCheckUpPressed
  
  ld    a,(framecounter)
  rrca
  jr    c,.EndCheckUpPressed

  inc   (hl)                  ;increase JumpSpeed if we don't press up, if JumpSpeed is negative and we don't press up 
  .EndCheckUpPressed:

	ld		a,(PlayerAniCount+1)
	inc   a
	cp    GravityTimer
	jr    nz,.set
  ld    a,(hl)
  inc   a
  cp    MaxDownwardFallSpeed+1
  jr    z,.maxfound
  ld    (hl),a
  .maxfound:

	xor   a
	.set:
	ld		(PlayerAniCount+1),a

  ;unable to jump through the top of the screen
;  ld    a,(Clesy)
;  cp    9
;  jp    nc,.EndCheckTopOfScreen
;  ld    a,(hl)              ;if vertical JumpSpeed is negative then and y<9 then skip vertical movement
;  or    a
;  jp    m,.SkipverticalMovement
;  .EndCheckTopOfScreen:
  ;/unable to jump through the top of the screen
  
  ;move player y
  ld    a,(Clesy)
  add   a,(hl)
  ld    (Clesy),a
  .SkipverticalMovement:

  ld    a,(hl)              ;if vertical JumpSpeed is negative then CheckPlatformAbove. If it's positive then CheckPlatformBelow
  or    a
  jp    m,.CheckPlatformAbove
  ret   z

;XaddLeftPlayer:           equ 00 - 8
;XaddRightPlayer:          equ 15 - 8

;-6      5


  .CheckPlatformBelow:        ;check platform below


  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,+3-8 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToPlatformBelow  

  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFoundUnderLeftFoot1

  inc   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.SnapToPlatformBelow  


;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,-5 ;XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToPlatformBelow

  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFoundUnderRightFoot1

  sub   4                   ;check for tilenr 6=lava
  ret   nz

  .LavaFound:
;  ld    a,(ClesY)           ;don't check lava in top of screen
 ; cp    20
 ; ret   c
  ld    a,(ClesY)           ;don't check lava in bottom of screen
  cp    $c0                
  ret   nc
  jp    Set_Dying


  
;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  dec   a                   ;check for tilenr 2=ladder 
;  jr    z,.LadderFound

;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  dec   a                   ;check for tilenr 2=ladder 
;  jr    z,.LadderFound
;  scf
;  ret




;while falling a ladder tile is found at player's feet. 
;check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderRightFoot1:               
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-0-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.LadderFoundUnderRightFoot2

  ld    b,YaddFeetPlayer-9  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-0-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow

;check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderRightFoot2:
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-0+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   nz

  ld    b,YaddFeetPlayer-9    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-0+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow
;  ret   z
  ret







;while falling a ladder tile is found at player's feet. 
;check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderLeftFoot1:               
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-8-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.LadderFoundUnderLeftFoot2

  ld    b,YaddFeetPlayer-9  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-8-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow

;check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderLeftFoot2:
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-8+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   nz

  ld    b,YaddFeetPlayer-9    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-8+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

  .SnapToPlatformBelow:
  ld    a,(Clesy)           ;on collision snap y player to platform below and switch standing
  and   %1111 1000
  dec   a
  ld    (Clesy),a

;  ld    a,1                 ;reset kicking while jumping
;  ld    (KickWhileJump?),a  
;  xor   a
;  ld    (EnableHitbox?),a 
 
  pop   af                  ;pop the call to .VerticalMovement, this way no further checks are done
 
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_stand       ;on collision change to L_Stand  
  jp    Set_R_stand         ;on collision change to R_Stand    

  .CheckPlatformAbove:    
;check platform above
  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-3  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToCeilingAbove

;  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+3   ;add x to check (x is expressed in pixels)
;  ld    de,-5
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToCeilingAbove

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   nz
 
  .SnapToCeilingAbove:
  ld    a,(Clesy)           ;on collision snap y player to ceiling above
  and   %1111 1000
  add   a,6
  ld    (Clesy),a
  ret

  .CheckJumpOrClimbLadder: 
  call  CheckClimbLadderUp  ;out: PlayerSpriteStand->Climb if ladder found

	ld		hl,(PlayerSpriteStand)
	ld		de,Climb
  xor   a
  sbc   hl,de
  jr    nz,.CheckDoubleJump

	ld		hl,PlayerSpriteData_Char_Climbing1
	ld		(standchar),hl
  jp    Set_Climb_AndResetAniCount
   
  .CheckDoubleJump:
  ld    a,(DoubleJumpAvailable?)
  or    a
  ret   z

  ld    a,(ShootArrowWhileJump?)
  or    a
  jr    nz,.DontAllowDoubleJump   ;don't allow double jump when already presenting bow  
  ld    a,(ShootMagicWhileJump?)  ;don't allow double jump when shooting magic mid air
  or    a
  jr    z,.EndCheckShootMagicWhileJump

  .DontAllowDoubleJump:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
  res   0,a 
  ld    (Controls),a
  ret
  .EndCheckShootMagicWhileJump:
  
  xor   a
  ld    (DoubleJumpAvailable?),a
  jp    Set_jump.SkipTurnOnDoubleJump

AnimateMeditating:
  ld    a,(framecounter)          ;animate every 4 frames
  and   07
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jr    AnimateRun.SetPlayerAniCount

AnimateCharging:
  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jr    AnimateRun.SetPlayerAniCount
  
AnimateRolling:
;  ld    a,(framecounter)          ;animate every 4 frames
;  and   3
;  ret   z
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 12                    ;12 frame addresses
  jr    nz,AnimateRun.SetPlayerAniCount
  jr    AnimateRun.reset
  
AnimatePushing:
  ld    a,(framecounter)          ;animate every 4 frames
  and   7
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 09                    ;09 frame addresses
  jr    nz,AnimateRun.SetPlayerAniCount
  jr    AnimateRun.reset

AnimateRun:
  ld    a,(framecounter)          ;animate every 4 frames
  and   3
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 10                    ;10 frame addresses
  jr    nz,.SetPlayerAniCount
  .reset:
  xor   a
  .SetPlayerAniCount:
  ld    (PlayerAniCount),a
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
    
	ld		(standchar),de
;	ld    hl,PlayerSpriteData_Colo_LeftRun1-PlayerSpriteData_Char_LeftRun1
;	add   hl,de
;	ld		(standcol),hl
  ret	
   
LeftRunAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftRun2 
  dw  PlayerSpriteData_Char_LeftRun3 
  dw  PlayerSpriteData_Char_LeftRun4 
  dw  PlayerSpriteData_Char_LeftRun5 
  dw  PlayerSpriteData_Char_LeftRun6 
  dw  PlayerSpriteData_Char_LeftRun7 
  dw  PlayerSpriteData_Char_LeftRun8 
  dw  PlayerSpriteData_Char_LeftRun9 
  dw  PlayerSpriteData_Char_LeftRun10
  dw  PlayerSpriteData_Char_LeftRun1 
    
RightRunAnimation:
  dw  PlayerSpriteData_Char_RightRun7 
  dw  PlayerSpriteData_Char_RightRun8 
  dw  PlayerSpriteData_Char_RightRun9 
  dw  PlayerSpriteData_Char_RightRun10
  dw  PlayerSpriteData_Char_RightRun1 
  dw  PlayerSpriteData_Char_RightRun2 
  dw  PlayerSpriteData_Char_RightRun3 
  dw  PlayerSpriteData_Char_RightRun4 
  dw  PlayerSpriteData_Char_RightRun5 
  dw  PlayerSpriteData_Char_RightRun6 

CheckClimbStairsDown:
  call  .StairsGoingLeftUp
  
.StairsGoingRightUp:
;check if there are stairs when pressing down, if so climb the stairs. Check if there is a tile below left foot AND right foot
;[Check stairs going RIGHT UP]
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-04   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  jp    z,.stairsfound1

  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+02   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 6 pixels further to the left. If stairs found, then move player 6 pixels to the right, so we have the same x value for check 1 and 2
  ld    de,6
  add   hl,de
  ld    (ClesX),hl

  .stairsfound1:      
	call  Set_Stairs_Climb_RightUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,-16 + 18
  add   hl,de
  ld    (ClesX),hl

;  ld    a,(Clesy)
;  add   a,18 - 18
;  ld    (Clesy),a
  
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-4   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   nz
  
  ld    hl,(ClesX)          ;sub 8 pixels to player in case we snapped too much to the right
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret


.StairsGoingLeftUp:
;check if there are stairs when pressing down, if so climb the stairs. Check if there is a tile below left foot AND right foot
;[Check stairs going LEFT UP]
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  jp    z,.stairsfound

  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+14   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 6 pixels further to the left. If stairs found, then move player 6 pixels to the right, so we have the same x value for check 1 and 2
  ld    de,6
  add   hl,de
  ld    (ClesX),hl

  .stairsfound:      
	call  Set_Stairs_Climb_LeftUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,6
  add   hl,de
  ld    (ClesX),hl
;  ld    a,(Clesy)
;  add   a,0
;  ld    (Clesy),a
  
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz
  
  ld    hl,(ClesX)          ;sub 8 pixels to player in case we snapped too much to the right
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret

CheckClimbStairsUp:
  call  .StairsGoingLeftUp

.StairsGoingRightUp:
;check if there are stairs when pressing up, if so climb the stairs. Check if there is a tile above left foot AND right foot
;[Check ladder going Right UP]
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+04   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  jp    z,.stairsfound1

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+12   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 8 pixels further than the 1st check. If stairs is found, move player 8 pixels to the right.
  ld    de,8
  add   hl,de
  ld    (ClesX),hl

  .stairsfound1:  
  
	call  Set_Stairs_Climb_RightUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

;after snapping to an x position, player is either 8 pixels left of stairs, ON the stairs, or 8 pixels right of stairs
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   z
;  jr    z,.snaptostairs
  
  ld    hl,(ClesX)          ;add 8 pixels to player in case we snapped too much to the left
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl

;.snaptostairs:
;  ld    hl,(ClesX)
;  ld    de,6
;  add   hl,de
;  ld    (ClesX),hl
  ret

.StairsGoingLeftUp:
;check if there are stairs when pressing up, if so climb the stairs. Check if there is a tile above left foot AND right foot
;[Check ladder going LEFT UP]
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  jp    z,.stairsfound

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz

  .stairsfound:  
	call  Set_Stairs_Climb_LeftUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz
  
  ld    hl,(ClesX)          ;add 8 pixels to player in case we snapped too much to the left
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret

CheckClimbLadderUp:;
;check if there is a ladder when pressing up, if so climb the ladder. Check if there is a tile above left foot AND right foot
  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+6   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jp    z,.ladderfound

  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-7  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   nz

  .ladderfound:
	call  Set_Climb

  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ;after snapping player could be 1 tile too much to theright. Check again for ladder under right foot. If not, then move 1 tile to the left
  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.NowCheckLeft

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  sbc   hl,de
  ld    (ClesX),hl
  ret

  .NowCheckLeft:
  ;after snapping player could be 1 tile too much to the left. Check again for ladder under left foot. If not, then move 1 tile to the right
  ld    b,YaddFeetPlayer-20   ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   z

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret





    