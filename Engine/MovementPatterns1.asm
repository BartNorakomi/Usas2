;This is at $4000 inside a block (movementpatternsblock)
;PlatformVertically              
;PlatformHorizontally            
;Sf2Hugeobject1                  
;Sf2Hugeobject2                  
;Sf2Hugeobject3                    
;PushingStone                       
;PushingPuzzleSwitch                
;PushingPuzzlOverview              
;RetardedZombie   
;GreenSpider                
;GreySpider

;Generic Enemy Routines ##############################################################################
CheckOutOfMap:  
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x  
  ld    de,304+16                           ;map width + offset
  xor   a
  sbc   hl,de
  ret   c
  ;out of map
  RemoveSprite:
  ld    (ix+enemies_and_objects.alive?),0  
  ld    (ix+enemies_and_objects.y),217      ;y  
  ret

MoveSpriteHorizontallyAndVertically:        ;Add v3 to y. Add v4 to x (16 bit)
  call  MoveSpriteVertically

  MoveSpriteHorizontally:                   ;Add v3 to y. Add v4 to x (16 bit)
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		6,a                                 ;F1 pressed ?
	ret   nz
	
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x

  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    e,a
  add   a,a                                 ;sign in carry flag
  sbc   a                                   ;high byto 0 or -1
  ld    d,a
  add   hl,de
  ld    (ix+enemies_and_objects.x),l  
  ld    (ix+enemies_and_objects.x+1),h      ;x
  ret

MoveSpriteVertically:                       ;Add v3 to y. Add v4 to x (16 bit)
  ld    a,(ix+enemies_and_objects.y)
  add   (ix+enemies_and_objects.v3)         ;v3=veritcal movement
  ld    (ix+enemies_and_objects.y),a  
  ret

CheckCollisionWallEnemy:                    ;checks for collision wall and if found invert horizontal movement
  ld    b,(ix+enemies_and_objects.ny)       ;add to y (y is expressed in pixels)
  ld    hl,-16                              ;add to x to check right side of sprite for collision

  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  jr    z,.MovingRight

  .MovingLeft:
  call  CheckTileEnemyInHL                  ;out z=collision found with wall  
  ret   nz
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

  .MovingRight:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  add   hl,de
  call  CheckTileEnemyInHL                  ;out z=collision found with wall  
  ret   nz
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret
  
CheckFloorEnemy:
  ld    a,(ix+enemies_and_objects.ny)       
  add   a,16
  ld    b,a                                 ;add to y (y is expressed in pixels)

  ld    e,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  bit   7,e
  jr    z,.MovingRight

  .MovingLeft:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  ld    hl,16
  sbc   hl,de                               ;hl = 16 - width
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  

  .MovingRight:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  sla   e                                   ;*2
  ld    hl,-48
  add   hl,de                               ;hl = -48 + width + width
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  

distancecheck:                              ;in: b,c->x,y distance between player and object,  out: carry->object within distance
;check x
;nx and ny are not included at this point
;  ld    a,(ix+enemies_and_objects.nx)       ;width object
;	srl		a                                   ;/2
;  ld    d,a

  ld    hl,(Clesx)                          ;hl = x player
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  
  sbc   hl,de
  ld    a,l
  jr    nc,.PlayerIsRightSideofObject
  neg
  .PlayerIsRightSideofObject:
  cp    b
  ret   nc
  
 ;/check x  
;check y
  ld    a,(Clesy)
  sub   (ix+enemies_and_objects.y)          ;y enemy/object
  jp    p,.endcheckpositive2
  neg
.endcheckpositive2:
  cp    c
;/check y  
  ret

checkFacingPlayer:                          ;out: c = object/enemy is facing player
  ld    hl,(Clesx)                          ;hl = x player  
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  jr    c,.PlayerIsLeftSideofObject
  
  .PlayerIsRightSideofObject:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ret   nz
  scf
  ret
  
  .PlayerIsLeftSideofObject:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ret   p
  scf
  ret
  
CollisionEnemyPlayer:
;check if player collides with left side of enemy/object
  ld    hl,(Clesx)                          ;hl = x player

  ld    bc,20-2                             ;reduce this value to reduce the hitbox size (on the left side)
  add   hl,bc

  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object

  or    a                                   ;reset flag
  sbc   hl,de
  ret   c

;check if player collides with right side of enemy/object
  ld    c,(ix+enemies_and_objects.nx)       ;width object

ld a,09-4 ;nx + 10                          ;reduce this value to reduce the hitbox size (on the right side)
add a,c
ld c,a

  sbc   hl,bc  
  ret   nc

;check if player collides with top side of enemy/object
  ld    a,(Clesy)                           ;a = y player
  add   a,11-4                              ;reduce this value to reduce the hitbox size (on the yop side)
  sub   (ix+enemies_and_objects.y)
  ret   c

;check if player collides with bottom side of enemy/object
  ld    c,(ix+enemies_and_objects.ny)       ;width object

ld e,a ;store a
ld a,20-4 ;ny + 20   ;if this is 20-8 it would be same reduction top as bottom, but at the bottom its better if there is less reduction                         ;reduce this value to reduce the hitbox size (on the left side)
add a,c
ld c,a
ld a,e

  sub   a,c
  ret   nc
  
  ld    a,(PlayerInvulnerable?)
  or    a
  ret   nz

  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_BeingHit
  jp    Set_R_BeingHit

BlinkDurationWhenHit: equ 31  
CheckPlayerPunchesEnemy:
  ld    a,(ix+enemies_and_objects.hit?)     ;reduce enemy is hit counter
  dec   a
  jp    m,.EndReduceHitTimer
  ld    (ix+enemies_and_objects.hit?),a
  ret                                       ;if enemy is  already hit, don't check if it's hit again
  .EndReduceHitTimer:
  
  ld    a,(EnableHitbox?)
  or    a
  ret   z

;check if enemy/object collides with hitbox left side
  ld    hl,(HitBoxSX)                       ;hl = x hitbox
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object

ld a,09-4 ;nx + 10                          ;reduce this value to reduce the hitbox size (on the right side)
add a,c
ld c,a
ld b,0

  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox top side
  ld    a,(HitBoxSY)                        ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c

;check if enemy/object collides with hitbox bottom side
  ld    c,(ix+enemies_and_objects.ny)       ;width object

ld e,a ;store a
ld a,20-4 ;ny + 20   ;if this is 20-8 it would be same reduction top as bottom, but at the bottom its better if there is less reduction                         ;reduce this value to reduce the hitbox size (on the left side)
add a,c
ld c,a
ld a,e

  sub   a,c
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  ret   nz
  ld    (ix+enemies_and_objects.hit?),00    ;stop blinking white when dead

  ld    a,(ix+enemies_and_objects.nrspritesSimple)
  cp    8
  jr    c,.ExplosionSmall  

  .ExplosionBig:
  ;Enemy dies
  ld    hl,ExplosionBig
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  
  ;x position of explosion is x - 8 + (nx/2)
  ld    a,(ix+enemies_and_objects.nx)
	srl		a                                   ;/2
  sub   16
  ld    d,0
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de
  ld    (ix+enemies_and_objects.x),l  
  ld    (ix+enemies_and_objects.x+1),h      ;x
  
  ;y position of explosion is y + ny - 16           
  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)
  sub   a,32
;  ld    (ix+enemies_and_objects.y),a

  ;backup y and move sprite out of screen
;  ld    a,(ix+enemies_and_objects.y)        ;y  
  ld    (ix+enemies_and_objects.v2),a       ;y backup
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.y),217      ;y
  ret
  
  .ExplosionSmall:
  ;Enemy dies
  ld    hl,ExplosionSmall
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  
  ;x position of explosion is x - 8 + (nx/2)
  ld    a,(ix+enemies_and_objects.nx)
	srl		a                                   ;/2
  sub   8
  ld    d,0
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de
  ld    (ix+enemies_and_objects.x),l  
  ld    (ix+enemies_and_objects.x+1),h      ;x
  
  ;y position of explosion is y + ny - 16
  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)
  sub   a,16
;  ld    (ix+enemies_and_objects.y),a

  ;backup y and move sprite out of screen
;  ld    a,(ix+enemies_and_objects.y)        ;y  
  ld    (ix+enemies_and_objects.v2),a       ;y backup
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.y),218      ;y
  ret
  
;/Generic Enemy Routines ##############################################################################
ExplosionBig:
;v1=Animation Counter
;v2=y backup
  ld    a,(ix+enemies_and_objects.v2)       ;y backup
  ld    (ix+enemies_and_objects.y),a        ;y    
  
  call  .Animate
  
	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)

  ld    (ix+enemies_and_objects.nrsprites),48-(08*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),8
  ld    (ix+enemies_and_objects.nrspritesTimes16),8*16
  ret

  .Animate: 
  ld    hl,ExplosionBigAnimation
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;05 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 05                              ;05 animation frame addresses
  ret   nz
  jp    RemoveSprite

ExplosionBigAnimation:
  dw  RedExplosionBig1_Char 
  dw  RedExplosionBig2_Char 
  dw  RedExplosionBig3_Char 
  dw  RedExplosionBig4_Char
  dw  RedExplosionBig5_Char
  dw  RedExplosionBig5_Char

ExplosionSmall:
;v1=Animation Counter
;v2=y backup
  ld    a,(ix+enemies_and_objects.v2)       ;y backup
  ld    (ix+enemies_and_objects.y),a        ;y    
  
  call  .Animate
  
	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)

  ld    (ix+enemies_and_objects.nrsprites),48-(02*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),2
  ld    (ix+enemies_and_objects.nrspritesTimes16),2*16
  ret

  .Animate: 
  ld    hl,ExplosionSmallAnimation
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 05                            ;04 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04                              ;04 animation frame addresses
  ret   nz
  jp    RemoveSprite

ExplosionSmallAnimation:
  dw  RedExplosionSmall1_Char 
  dw  RedExplosionSmall2_Char 
  dw  RedExplosionSmall3_Char 
  dw  RedExplosionSmall4_Char
  dw  RedExplosionSmall4_Char

ZombieSpawnPoint:
;v1=Zombie Spawn Timer
  ld    a,(framecounter)
  and   1
  ret   nz
  dec   (ix+enemies_and_objects.v1)       ;v1=Zombie Spawn Timer
  ret   nz

  push  ix
  call  .SearchEmptySlot
  pop   ix
  ret

  .SearchEmptySlot:
  ld    de,lenghtenemytable
  
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  ret   nz
  
  .EmptySlotFound:
  ld    (ix+enemies_and_objects.alive?),-1 
  ld    (ix+enemies_and_objects.y),24
  ld    (ix+enemies_and_objects.x),152
  ld    (ix+enemies_and_objects.x+1),0
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  ld    (ix+enemies_and_objects.v4),1       ;v4=Horizontal Movement
  ld    hl,RetardedZombie
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  ld    (ix+enemies_and_objects.nrsprites),48-(04*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),4
  ld    (ix+enemies_and_objects.nrspritesTimes16),4*16
  ld    (ix+enemies_and_objects.life),1
  ret
  
Grinder:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,GrinderSpriteblock                ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:                             ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  or    a
  jp    z,Grinderwalking

  GrinderAttacking:
  call  .Move
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  push  af
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  Grinderwalking.CheckFloor                         ;checks for floor. if not found invert direction
  ld    b,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  pop   af
  cp    b                                   ;if direction changed while attacking, end phase and go back to walking
  jr    nz,.EndPhase
  
  .Animate:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,GrinderRightAttackAnimation
  jp    p,.GoAnimate
  ld    hl,GrinderLeftAttackAnimation
  .GoAnimate:
  ld    b,15                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;05 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .Move:
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04
  ret   c
  cp    2 * 05
  jr    z,.EndPhase
  call  MoveSpriteHorizontally              ;easiest way to move twice as fast as walking
  jp    MoveSpriteHorizontally              ;easiest way to move twice as fast as walking
  .EndPhase:
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  Grinderwalking:
  call  .CheckIfHit                         ;if Grinder is hit and facing player he may initiate Phase 1 (attacking)
  call  .Move
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  
  .Animate:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,GrinderRightWalkAnimation
  jp    p,.GoAnimate
  ld    hl,GrinderLeftWalkAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 05                            ;05 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckIfHit:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if hit
  cp    BlinkDurationWhenHit
  ret   nz
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc
  ld    a,r
  rrca                                      ;out: c random 50% change
  ret   c
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  .Move:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    z,.NotHit
  ld    a,(framecounter)
  and   07
  call  z,MoveSpriteHorizontally            ;if hit, move once every 8 frames
  ret
  .NotHit:
  ld    a,(framecounter)
  and   3
  call  nz,MoveSpriteHorizontally           ;if not hit, move 3 out of 4 frames
  ret

  .CheckFloor:                              ;checks for floor. if not found invert direction
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   nz                                  ;return if background tile is NOT found
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

GrinderLeftAttackAnimation:
  dw  LeftGrinderAttack1_Char
  dw  LeftGrinderAttack1_Char
  dw  LeftGrinderAttack1_Char
  dw  LeftGrinderAttack1_Char
  dw  LeftGrinderAttack2_Char
  dw  LeftGrinderAttack2_Char
  
GrinderRightAttackAnimation:
  dw  RightGrinderAttack1_Char
  dw  RightGrinderAttack1_Char
  dw  RightGrinderAttack1_Char
  dw  RightGrinderAttack1_Char
  dw  RightGrinderAttack2_Char
  dw  RightGrinderAttack2_Char

GrinderLeftWalkAnimation:
  dw  LeftGrinderWalk1_Char
  dw  LeftGrinderWalk2_Char
  dw  LeftGrinderWalk3_Char
  dw  LeftGrinderWalk4_Char
  dw  LeftGrinderWalk5_Char
  
GrinderRightWalkAnimation:
  dw  RightGrinderWalk1_Char
  dw  RightGrinderWalk2_Char
  dw  RightGrinderWalk3_Char
  dw  RightGrinderWalk4_Char
  dw  RightGrinderWalk5_Char

GreenSpider:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=fast)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Grey Spider Slow Down Timer
;v6=Green Spider(0) / Grey Spider(1)
  call  .HandlePhase                        ;(0=walking slow, 1=fast) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl -> sprite character data to out to Vram
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Green Spider(0) / Grey Spider(1)
  or    a
	ld		a,GreenSpiderSpriteblock            ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
	ld		a,GreySpiderSpriteblock             ;set block at $a000, page 2 - block containing sprite data
  .BlockSet:
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret

  .HandlePhase:                             ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking slow, 1=fast)
  or    a
  jp    z,GreenSpiderWalkSlow
;  dec   a
;  jp    z,GreenSpiderWalkFast

  GreenSpiderWalkFast:
  call  MoveSpriteHorizontally
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  call  .DistanceToPlayerCheck              ;check if player is near, if so, move fasters and eyes become red
  
  .Animate:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,GreenSpiderRightWalkAnimation
  jp    p,.GoAnimate
  ld    hl,GreenSpiderLeftWalkAnimation
  .GoAnimate:
  ld    b,3                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .DistanceToPlayerCheck:
  bit   0,(ix+enemies_and_objects.v6)       ;v6=Green Spider(0) / Grey Spider(1)
  jr    z,.GreenSpider
  dec   (ix+enemies_and_objects.v5)         ;v5=Grey Spider Slow Down Timer
  jr    z,.WalkSlow
  ret
  .GreenSpider:

  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  jp    nc,.WalkSlow
  
  ld    b,99                                ;b-> x distance
  ld    c,40                                ;c-> y distance
  call  distancecheck                       ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   c
  .WalkSlow:
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking slow, 1=fast)
  ret

  GreenSpiderWalkSlow:
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  call  .DistanceToPlayerCheck              ;check if player is near, if so, move fasters and eyes become red
  
  .Animate:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,GreenSpiderOrangeEyesRightWalkAnimation
  jp    p,.GoAnimate
  ld    hl,GreenSpiderOrangeEyesLeftWalkAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .DistanceToPlayerCheck:
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc
  ld    b,99                                ;b-> x distance
  ld    c,40                                ;c-> y distance
  call  distancecheck                       ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking slow, 1=fast)
  ret

  .CheckFloor:                              ;checks for floor. if not found invert direction
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   nz                                  ;return if background tile is NOT found
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

GreenSpiderOrangeEyesLeftWalkAnimation:
  dw  LeftGreenSpiderOrangeEyesWalk1_Char 
  dw  LeftGreenSpiderOrangeEyesWalk2_Char 
  dw  LeftGreenSpiderOrangeEyesWalk3_Char 
  dw  LeftGreenSpiderOrangeEyesWalk4_Char
  
GreenSpiderOrangeEyesRightWalkAnimation:
  dw  RightGreenSpiderOrangeEyesWalk1_Char 
  dw  RightGreenSpiderOrangeEyesWalk2_Char 
  dw  RightGreenSpiderOrangeEyesWalk3_Char 
  dw  RightGreenSpiderOrangeEyesWalk4_Char
  
GreenSpiderLeftWalkAnimation:
  dw  LeftGreenSpiderWalk1_Char 
  dw  LeftGreenSpiderWalk2_Char 
  dw  LeftGreenSpiderWalk3_Char 
  dw  LeftGreenSpiderWalk4_Char

GreenSpiderRightWalkAnimation:
  dw  RightGreenSpiderWalk1_Char 
  dw  RightGreenSpiderWalk2_Char 
  dw  RightGreenSpiderWalk3_Char 
  dw  RightGreenSpiderWalk4_Char

RetardedZombie:
;v1=Animation Counter
;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait Timer
  call  .HandlePhase                        ;(0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)  ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
	ld		a,RetardZombieSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret

  .HandlePhase:                             ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  or    a
  jp    z,RetardedZombie_RisingFromGrave
  dec   a
  jp    z,RetardedZombie_Walking
  dec   a
  jp    z,RetardedZombie_Falling
  dec   a
  jp    z,RetardedZombie_Turning
  dec   a
  jp    z,RetardedZombie_Sitting

  RetardedZombie_Sitting:
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy  
  ld    hl,RetardZombieSittingAnimation
  ld    b,3                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 13                            ;02 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram  ret  

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 12
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)  
  ret

  RetardedZombie_Turning:
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy  
  call  .HandleWaitTimer
  
  ;end with out hl -> sprite character data to out to Vram
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightRetardZombieLookBack_Char
  ret   z
  ld    hl,LeftRetardZombieLookBack_Char
  ret

  .HandleWaitTimer:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Wait Timer
  inc   a
  and   31
  ld    (ix+enemies_and_objects.v5),a       ;v5=Wait Timer
  ret   nz
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  pop   af
  jp    RetardedZombie_Walking
  
  RetardedZombie_Falling:
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy  
  call  .IncreaseFallingSpeed
  call  MoveSpriteVertically  
  call  .CheckFloorFalling                  ;checks for collision wall and if found invert direction
;  jp    .Animate                            ;out hl -> sprite character data to out to Vram
  .Animate:
  ld    e,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  bit   7,e
  jr    z,.Right
  .Left:
  ld    hl,RetardZombieLeftFallingAnimation
  ld    b,1                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 02                            ;02 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram  ret  
  .Right:
  ld    hl,RetardZombieRightFallingAnimation
  ld    b,1                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 02                            ;02 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram  ret  
   
  .IncreaseFallingSpeed:
  ld    a,(framecounter)
  and   7
  ret   nz
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret
  
  .CheckFloorFalling:
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  ret   nz
  ld    (ix+enemies_and_objects.v2),4       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  ld    (ix+enemies_and_objects.v3),1       ;v3=Vertical Movement
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y
  ret
    
  RetardedZombie_RisingFromGrave:
  ld    hl,RetardZombieRisingFromGraveAnimation
  ld    b,3                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 26                            ;25 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 25                              ;25 animation frame addresses
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)    
  ret
      
  RetardedZombie_Walking:
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy  
  call  .CheckTurning  
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for collision Floor and if found fall
  call  CheckOutOfMap                       ;remove sprite from play when leaving the map
;  jr    nc,.Reset
  
  .Animate:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,RightRetardZombieWalkingAnimation
  jp    p,.GoAnimate
  ld    hl,LeftRetardZombieWalkingAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 07                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckTurning:
  ret
  ld    a,r
  or    a
  ret   nz
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)  
  ret

  .CheckFloor:
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  ret   z
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

RetardZombieSittingAnimation:
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting2_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting2_Char 
  dw  RetardZombieSitting1_Char 
  dw  RetardZombieSitting2_Char 
  dw  RetardZombieSitting2_Char 
  dw  RetardZombieSitting2_Char 
  
RetardZombieRightFallingAnimation:
  dw  RightRetardZombieFalling1_Char 
  dw  RightRetardZombieFalling2_Char 

RetardZombieLeftFallingAnimation:
  dw  LeftRetardZombieFalling1_Char 
  dw  LeftRetardZombieFalling2_Char 
  
RightRetardZombieWalkingAnimation:
  dw  RightRetardZombieWalk1_Char 
  dw  RightRetardZombieWalk2_Char 
  dw  RightRetardZombieWalk3_Char 
  dw  RightRetardZombieWalk4_Char 
  dw  RightRetardZombieWalk5_Char 
  dw  RightRetardZombieWalk6_Char 
  dw  RightRetardZombieWalk7_Char 

LeftRetardZombieWalkingAnimation:
  dw  LeftRetardZombieWalk1_Char 
  dw  LeftRetardZombieWalk2_Char 
  dw  LeftRetardZombieWalk3_Char 
  dw  LeftRetardZombieWalk4_Char 
  dw  LeftRetardZombieWalk5_Char 
  dw  LeftRetardZombieWalk6_Char 
  dw  LeftRetardZombieWalk7_Char 

RetardZombieRisingFromGraveAnimation:
  dw  RetardZombieRising1_Char  
  dw  RetardZombieRising2_Char  
  dw  RetardZombieRising3_Char  
  dw  RetardZombieRising4_Char  
  dw  RetardZombieRising5_Char  
  dw  RetardZombieRising6_Char  
  dw  RetardZombieRising7_Char  
  dw  RetardZombieRising8_Char  
  dw  RetardZombieRising9_Char  
  dw  RetardZombieRising10_Char  
  dw  RetardZombieRising11_Char  
  dw  RetardZombieRising12_Char  
  dw  RetardZombieRising13_Char  
  dw  RetardZombieRising14_Char  
  dw  RetardZombieRising15_Char  
  dw  RetardZombieRising16_Char  
  dw  RetardZombieRising17_Char  
  dw  RetardZombieRising18_Char  
  dw  RetardZombieRising19_Char  
  dw  RetardZombieRising20_Char  
  dw  RetardZombieRising21_Char  
  dw  RetardZombieRising22_Char   
  dw  RetardZombieRising23_Char  
  dw  RetardZombieRising24_Char  
  dw  RetardZombieRising25_Char
  dw  RetardZombieRising25_Char
    
Sf2Hugeobject1:                             ;movement pattern 3
  ld    a,(HugeObjectFrame)
  inc   a
  ld    (HugeObjectFrame),a
  jp    nz,CheckCollisionObjectPlayer

  call  MoveSF2Object1
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
;  call  BackdropOrange  
  call  restoreBackgroundObject1
  call  ObjectAnimation
  call  PutSF2Object
;  call  BackdropBlack
  ret

Sf2Hugeobject2:                             ;movement pattern 4
  ld    a,(HugeObjectFrame)
  cp    1
  jp    nz,CheckCollisionObjectPlayer

  call  MoveSF2Object2
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject2
;  call  ObjectAnimation
  call  PutSF2Object2
  ret

Sf2Hugeobject3:                             ;movement pattern 5
  ld    a,(HugeObjectFrame)
  cp    2
  jp    nz,CheckCollisionObjectPlayer

  call  MoveSF2Object3
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject3
;  call  ObjectAnimation
  call  PutSF2Object3

  ld    a,-1
  ld    (HugeObjectFrame),a
  call  switchpageSF2Engine  
  ret

NoneMovingObjectStepTable:  ;move x, move y (128 = end table/repeat)
  db  10,+0,+0
  db  128

HugeBlockStepTable1:  ;repeating steps(128 = end table/repeat), move y, move x
  db  50,+0,+2,  50,+2,+0,  50,+0,-2,  50,-2,+0
  db  128

HugeBlockStepTable2:  ;repeating steps(128 = end table/repeat), move y, move x
  db  40,+0,+2,  40,+0,-2,  40,+0,-2,  40,+0,+2
  db  128

HugeBlockStepTable3:  ;repeating steps(128 = end table/repeat), move y, move x
  db  10,+0,+2,  10,+1,+2,  10,+1,+1,  10,+2,+1,  10,+2,+0
  db  10,+2,+0,  10,+2,-1,  10,+1,-1,  10,+1,-2,  10,+0,-2
  db  10,+0,-2,  10,-1,-2,  10,-1,-1,  10,-2,-1,  10,-2,-0
  db  10,-2,-0,  10,-2,+1,  10,-1,+1,  10,-1,+2,  10,-0,+2
  db  128

MoveSF2Object1:
  ld    de,HugeBlockStepTable1
;  ld    de,NoneMovingObjectStepTable
  call  MoveObjectWithStepTable
  ret
  
MoveSF2Object2:
  ld    de,HugeBlockStepTable2
;  ld    de,NoneMovingObjectStepTable
  call  MoveObjectWithStepTable
  ret

MoveSF2Object3:
  ld    de,HugeBlockStepTable3
;  ld    de,NoneMovingObjectStepTable
  call  MoveObjectWithStepTable
  ret

MoveObjectWithStepTable:
  ;if repeating steps are not 0, go to movement object
  ld    a,(ix+enemies_and_objects.v1)         ;repeating steps
  dec   a
  ld    (ix+enemies_and_objects.v1),a         ;repeating steps
  jp    p,.moveObject
  
  .NextStep:
  ld    a,(ix+enemies_and_objects.v2)         ;pointer to movement table
  ld    h,0
  ld    l,a
  add   hl,de
  add   a,3
  ld    (ix+enemies_and_objects.v2),a         ;pointer to movement table
  
  ld    a,(hl)                                ;repeating steps(128 = end table/repeat)
  cp    128
  jr    nz,.EndCheckEndTable
  ld    (ix+enemies_and_objects.v2),+3        ;pointer to movement table
  ex    de,hl
  ld    a,(hl)

  .EndCheckEndTable:
  ld    (ix+enemies_and_objects.v1),a         ;repeating steps
  inc   hl
  ld    a,(hl)                                ;y movement
  ld    (ix+enemies_and_objects.v3),a         ;v3=y movement
  inc   hl
  ld    a,(hl)                                ;x movement
  ld    (ix+enemies_and_objects.v4),a         ;v4=x movement

  .moveObject:
  ld    a,(ix+enemies_and_objects.y)          ;y object
  add   a,(ix+enemies_and_objects.v3)         ;add y movement to y
  ld    (ix+enemies_and_objects.y),a          ;y object
  ld    (Object1y),a

  ld    a,(ix+enemies_and_objects.x)          ;x object
  add   a,(ix+enemies_and_objects.v4)         ;add x movement to x
  ld    (ix+enemies_and_objects.x),a          ;x object
  ld    (Object1x),a

  ;Move player along with object if standing on it
  ld    a,(ix+enemies_and_objects.SnapPlayer?)         ;x movement
;  ld    a,(SnapToPlatform?)
  or    a
  ret   z
  MovePlayerAlongWithObject:
  ld    a,(ix+enemies_and_objects.v4)         ;x movement
  or    a
  ld    d,0
  jp    p,.positive
  ld    d,255  
  .positive:
  ld    e,a

  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl  

  ld    a,(ClesY)
  add   a,(ix+enemies_and_objects.v3)         ;y movement
  ld    (ClesY),a  
  ret
  
PushingPuzzlOverview:
  ld    a,(ShowOverView?)
  or    a
  jr    nz,InitiatlizeOverview              ;when entering screen turn switches on or off
  ret

InitiatlizeOverview:
;When player enters screen show all switches in the overview that are on/off
 
  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  ld    d,0
  ld    e,(ix+enemies_and_objects.v7)       ;set which number ?
  add   hl,de

  call  .CheckSwitch

  ld    a,(ix+enemies_and_objects.v7)       ;set which number ?
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;set which number ?
  cp    (ix+enemies_and_objects.v6)         ;total nr of switches
  ret   nz
  
  ld    a,(ix+enemies_and_objects.x+1)      ;reset x coordinate switch
  ld    (ix+enemies_and_objects.x),a        ;x coordinate switch  
  
  ld    a,(ShowOverView?)
  dec   a
  ld    (ShowOverView?),a

  xor   a
  ld    (ix+enemies_and_objects.v7),a       ;set which number ?
  ret
  
  .CheckSwitch:
  ld    a,(hl)
  ld    b,128
  bit   7,a                                 ;on/off ?
  jr    z,.EndCheckOnOff
  ld    b,128+64
  .EndCheckOnOff:

  and   %0111 1111                          ;switch number (1-4)
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  add   a,a                                 ;*8
  add   a,a                                 ;*16
  add   a,b
  ld    (CopySwitch1+sx),a

  ld    a,(ix+enemies_and_objects.x)        ;x coordinate switch
  ld    (CopySwitch1+dx),a
  ld    a,(ix+enemies_and_objects.y)        ;y coordinate switch
  ld    (CopySwitch1+dy),a
  xor   a
  ld    (CopySwitch1+dPage),a

  ld    hl,CopySwitch1
  call  DoCopy

  ld    a,1
  ld    (CopySwitch1+dPage),a
  ld    a,(CopySwitch1+dx)
  sub   a,16
  ld    (CopySwitch1+dx),a

  ld    hl,CopySwitch1
  call  DoCopy

  ld    a,2
  ld    (CopySwitch1+dPage),a
  ld    a,(CopySwitch1+dx)
  sub   a,16
  ld    (CopySwitch1+dx),a

  ld    hl,CopySwitch1
  call  DoCopy

  ld    a,3
  ld    (CopySwitch1+dPage),a
  ld    a,(CopySwitch1+dx)
  sub   a,16
  ld    (CopySwitch1+dx),a

  ld    hl,CopySwitch1
  call  DoCopy
  
  ld    a,(ix+enemies_and_objects.y)        ;x coordinate switch
  add   a,4
  ld    (ix+enemies_and_objects.y),a        ;x coordinate switch  
  ld    a,(CopySwitch1+sy)                  ;sy
  add   a,4
  ld    (CopySwitch1+sy),a                  ;sy
  cp    232+16
  jp    z,.NextSwitch
  pop   af
  ret
  
  .NextSwitch:
  ld    a,(ix+enemies_and_objects.y)        ;x coordinate switch
  sub   a,16
  ld    (ix+enemies_and_objects.y),a        ;x coordinate switch  
  ld    a,(CopySwitch1+sy)                  ;sy
  sub   a,16
  ld    (CopySwitch1+sy),a                  ;sy
  
  ld    a,(ix+enemies_and_objects.x)        ;x coordinate switch
  add   a,16
  ld    (ix+enemies_and_objects.x),a        ;x coordinate switch  
  ret
  

PushingPuzzleSwitch:
  ld    a,(ix+enemies_and_objects.v1)       ;initialize?
  or    a
  jp    nz,InitiatlizeSwitch                ;when entering screen turn switch on or off

  call  CheckPlayerOrStoneOnSwitch          ;Check if player or stone are on switch, if yes, then turn switch on, if no, then turn switch off
  call  CheckActivateSwitch                 ;check if a switch needs to be (de)activated
  ret

CheckActivateSwitch:
  ld    a,(ix+enemies_and_objects.v4)       ;activate switch to turn on or off
  or    a
  ret   z

  ld    a,(ix+enemies_and_objects.v2)       ;switch number? (1-4)
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  add   a,a                                 ;*8
  add   a,a                                 ;*16
  ld    (ActivateSwitch+sx),a
  
  ld    a,(ix+enemies_and_objects.v3)       ;switch on?
  or    a
  jr    z,.EndCheckSwitchOn
  ld    a,(ActivateSwitch+sx)
  add   a,64
  ld    (ActivateSwitch+sx),a
  .EndCheckSwitchOn:

  ld    a,(ix+enemies_and_objects.x)        ;x coordinate switch
  ld    (ActivateSwitch+dx),a
  ld    a,(ix+enemies_and_objects.y)        ;y coordinate switch
  ld    (ActivateSwitch+dy),a

  ld    a,(ix+enemies_and_objects.v4)       ;activate switch to turn on  or off
  dec   a
  ld    b,a
  ;set sy + dy
  ld    a,(ActivateSwitch+dy)
  add   a,b
  ld    (ActivateSwitch+dy),a

  ld    a,232
  add   a,b
  ld    (ActivateSwitch+sy),a

  xor   a
  ld    (ActivateSwitch+dPage),a
  ld    hl,ActivateSwitch
  call  DoCopy

  ld    a,1
  ld    (ActivateSwitch+dPage),a
  ld    a,(ActivateSwitch+dx)
  sub   a,16
  ld    (ActivateSwitch+dx),a
  ld    hl,ActivateSwitch
  call  DoCopy

  ld    a,2
  ld    (ActivateSwitch+dPage),a
  ld    a,(ActivateSwitch+dx)
  sub   a,16
  ld    (ActivateSwitch+dx),a
  ld    hl,ActivateSwitch
  call  DoCopy

  ld    a,3
  ld    (ActivateSwitch+dPage),a
  ld    a,(ActivateSwitch+dx)
  sub   a,16
  ld    (ActivateSwitch+dx),a
  ld    hl,ActivateSwitch
  call  DoCopy

  ld    a,(ix+enemies_and_objects.v4)       ;activate switch to turn on  or off
  inc   a
  ld    (ix+enemies_and_objects.v4),a       ;activate switch to turn on  or off

  cp    16
  ret   nz
  ld    (ix+enemies_and_objects.v4),0       ;activate switch to turn on  or off  
  ret


CheckPlayerOrStoneOnSwitch:
;first check if player is standing on switch
  call  CheckCollisionObjectPlayer

  ld    a,(ix+enemies_and_objects.SnapPlayer?)  
  or    a
  jp    nz,PlayerOrStoneOnSwitch

  .CheckStone1:
;check stone 2 on switch right side
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,14
  cp    (ix+enemies_and_objects.x)
  jp    nc,.CheckStone2
;check stone 2 on switch left side
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,14
  cp    (ix+enemies_and_objects.x)
  jp    c,.CheckStone2
;check stone 2 on switch y
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  jp    z,PlayerOrStoneOnSwitch

  .CheckStone2:
;check stone 2 on switch right side
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,14
  cp    (ix+enemies_and_objects.x)
  jp    nc,.CheckStone3
;check stone 2 on switch left side
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,14
  cp    (ix+enemies_and_objects.x)
  jp    c,.CheckStone3
;check stone 2 on switch y
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  jp    z,PlayerOrStoneOnSwitch
  
  .CheckStone3:
;check stone 3 on switch right side
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,14
  cp    (ix+enemies_and_objects.x)
  jp    nc,.NotOnSwitch
;check stone 3 on switch left side
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,14
  cp    (ix+enemies_and_objects.x)
  jp    c,.NotOnSwitch
;check stone 3 on switch y
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  jp    z,PlayerOrStoneOnSwitch

.NotOnSwitch:  
  ;player or stone is not on switch, turn off switch
  ld    a,(ix+enemies_and_objects.v3)       ;switch on?
  or    a
  ret   z                                   ;return if switch is already off

  ;at this point Player or stone no longer stands on switch. From the right to the left, find this switch nr which is on in the PuzzleSwitchTable and turn it off

  ld    l,(ix+enemies_and_objects.coordinates+2)
  ld    h,(ix+enemies_and_objects.coordinates+3)
  ld    de,9
  add   hl,de
;  ld    hl,PuzzleSwitchTable2+9
  ld    b,10                                ;10 entries in table
  ld    a,(ix+enemies_and_objects.v2)       ;switch number? (1-4)
  set   7,a
  .loop:
  cp    (hl)
  jr    z,.SwitchFound
  dec   hl
  djnz  .loop

  .SwitchFound:
  ;if table entry corresponds with switch number, then turn switch off  
  res   7,(hl)                              ;this switch in the PuzzleSwitchTable is now on
  
  ld    (ix+enemies_and_objects.v3),0       ;switch on?
  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  ld    (hl),0  
  
  ld    (ix+enemies_and_objects.v4),1       ;activate switch to turn on  or off

  ld    a,(ShowOverView?)
  inc   a
  cp    3
  ret   z
  ld    (ShowOverView?),a
  ret

PlayerOrStoneOnSwitch:
;if switch is already on, no action needs to be taken
  ld    a,(ix+enemies_and_objects.v3)       ;switch on?
  or    a
  ret   nz

  ;at this point Player stands on switch. If this is the next free switch in the table, turn on switch.
  ld    l,(ix+enemies_and_objects.coordinates+2)
  ld    h,(ix+enemies_and_objects.coordinates+3)
;  ld    hl,PuzzleSwitchTable2
  ld    b,10                                ;10 entries in table
  .loop:
  bit   7,(hl)
  jr    z,.EmptyTableEntryFound
  inc   hl
  djnz  .loop
  ret

  .EmptyTableEntryFound:
  ;if table entry corresponds with switch number, then turn switch on
  ld    a,(hl)
  cp    (ix+enemies_and_objects.v2)         ;switch number? (1-4)
  ret   nz
  
  set   7,(hl)                              ;this switch in the PuzzleSwitchTable is now on

  ld    (ix+enemies_and_objects.v3),1       ;switch on?
  ld    (ix+enemies_and_objects.v4),1       ;activate switch to turn on  or off

  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  ld    (hl),1

  ld    a,(ShowOverView?)
  inc   a
  cp    3
  ret   z
  ld    (ShowOverView?),a
  ret

InitiatlizeSwitch:
;When player enters screen switch is in on or off position. Copy the correct position at the coordinates of the switch
  ld    (ix+enemies_and_objects.v1),0       ;initialize?

  ld    a,(ix+enemies_and_objects.v2)       ;switch number? (1-4)
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  add   a,a                                 ;*8
  add   a,a                                 ;*16
  ld    (CopySwitch2+sx),a

;check if switch was on or off / PuzzleSwitch1On?
  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)

  ld    a,(ShowOverView?)
  inc   a
  cp    3
  jr    z,.skip
  ld    (ShowOverView?),a
  .skip:

  ld    a,(hl)
  ld    (ix+enemies_and_objects.v3),a       ;switch on?
 
;  ld    a,(ix+enemies_and_objects.v3)       ;switch on?
  or    a
  jr    z,.EndCheckSwitchOn
  ld    a,(CopySwitch2+sx)
  add   a,64
  ld    (CopySwitch2+sx),a
  .EndCheckSwitchOn:

  ld    a,(ix+enemies_and_objects.x)        ;x coordinate switch
  ld    (CopySwitch2+dx),a
  ld    a,(ix+enemies_and_objects.y)        ;y coordinate switch
  ld    (CopySwitch2+dy),a
  xor   a
  ld    (CopySwitch2+dPage),a

  ld    hl,CopySwitch2
  call  DoCopy

  ld    a,1
  ld    (CopySwitch2+dPage),a
  ld    a,(CopySwitch2+dx)
  sub   a,16
  ld    (CopySwitch2+dx),a

  ld    hl,CopySwitch2
  call  DoCopy

  ld    a,2
  ld    (CopySwitch2+dPage),a
  ld    a,(CopySwitch2+dx)
  sub   a,16
  ld    (CopySwitch2+dx),a

  ld    hl,CopySwitch2
  call  DoCopy

  ld    a,3
  ld    (CopySwitch2+dPage),a
  ld    a,(CopySwitch2+dx)
  sub   a,16
  ld    (CopySwitch2+dx),a

  ld    hl,CopySwitch2
  call  DoCopy
  ret      

CheckFloorOrStonePushingStone:
  ;check left side
  ld    b,+32                               ;add y to check (y is expressed in pixels)
;  ld    de,+17                              ;add x to check (x is expressed in pixels)
  ld    de,+16                              ;add x to check (x is expressed in pixels)
  call  checktileObject                     ;out z=collision found with wall
  ret   z
  ;check right side
  ld    b,+32                               ;add y to check (y is expressed in pixels)
;  ld    de,+00                              ;add x to check (x is expressed in pixels)
  ld    de,+01                              ;add x to check (x is expressed in pixels)
  call  checktileObject                     ;out z=collision found with wall
  ret   z

  ;check y collision with object 1 (stone 1) top
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jp    z,.NoCollision1
  sub   a,17
  cp    (ix+enemies_and_objects.y)
  jp    nc,.NoCollision1

  ;check y collision with object 1 (stone 1) bottom
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  jp    c,.NoCollision1

  ;check x collision with object 1 (stone 1) check on the left side of this stone
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  jp    c,.NoCollision1

  ;check x collision with object 1 (stone 1) check on the right side of this stone
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   c

  .NoCollision1:
   
  ;check y collision with object 2 (stone 2) top
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jp    z,.NoCollision2
  sub   a,17
  cp    (ix+enemies_and_objects.y)
  jp    nc,.NoCollision2

  ;check y collision with object 2 (stone 2) bottom
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  jp    c,.NoCollision2

  ;check x collision with object 2 (stone 2) check on the left side of this stone
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  jp    c,.NoCollision2

  ;check x collision with object 2 (stone 2) check on the right side of this stone
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   c

  .NoCollision2:
  
  ;check y collision with object 3 (stone 3) top
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jp    z,.NoCollision3
  sub   a,17
  cp    (ix+enemies_and_objects.y)
  jp    nc,.NoCollision3

  ;check y collision with object 3 (stone 3) bottom
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  jp    c,.NoCollision3

  ;check x collision with object 3 (stone 3) check on the left side of this stone
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  jp    c,.NoCollision3

  ;check x collision with object 3 (stone 3) check on the right side of this stone
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   c

  .NoCollision3:
  ld    (ix+enemies_and_objects.v2),1       ;falling stone
  ld    a,(PlayerFacingRight?)              ;is player facing right ?
  or    a
  jp    z,Set_L_stand
  jp    Set_R_stand
  
checktileObject:                            ;same as checktile for player, but now for object
;get object X in tiles
  ld    l,(ix+enemies_and_objects.x)        ;x object
  ld    h,0
  add   hl,de
  ld    a,(ix+enemies_and_objects.y)        ;y object
  jp    CheckTile.XandYset

FallingStone:
  ld    (ix+enemies_and_objects.v4),+0      ;horizontal movement
  call  VramObjects                         ;put object in Vram/screen
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object. Out: b=255 collision right side of object. b=254 collision left side of object. Uses v5/snapplayer?
  call  AccelerateFall
  call  MoveObject                          ;adds v3 to y, adds v4 to x. x+y are 8 bit
  call  CheckFloorFallingStone              ;check collision with floor
  call  CheckCollisionStone1                ;check collision with other stones while falling
  call  CheckCollisionStone2                ;check collision with other stones while falling
  call  CheckCollisionStone3                ;check collision with other stones while falling
  ret

CheckCollisionStone1:
  ;check y collision with object 1 (stone 1) top
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  ret   z
  sub   a,16
  cp    (ix+enemies_and_objects.y)
  ret   nc
  ;check y collision with object 1 (stone 1) bottom
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  ret   c

  ;check x collision with object 1 (stone 1) check on the left side of this stone
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  ret   c

  ;check x collision with object 1 (stone 1) check on the right side of this stone
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   nc

  ;other stone found, snap to stone
  ld    a,(ix+enemies_and_objects.y)        ;y object
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y object
  
  ld    (ix+enemies_and_objects.v2),0       ;0=pushing stone, 1=falling stone
  ret
  
CheckCollisionStone2:
  ;check y collision with object 2 (stone 2) top
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  ret   z
  sub   a,16
  cp    (ix+enemies_and_objects.y)
  ret   nc
  ;check y collision with object 2 (stone 2) bottom
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  ret   c
  
  ;check x collision with object 2 (stone 2) check on the left side of this stone
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  ret   c

  ;check x collision with object 2 (stone 2) check on the right side of this stone
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   nc

  ;other stone found, snap to stone
  ld    a,(ix+enemies_and_objects.y)        ;y object
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y object
  
  ld    (ix+enemies_and_objects.v2),0       ;0=pushing stone, 1=falling stone
  ret
    
CheckCollisionStone3:
  ;check y collision with object 3 (stone 3) top
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  ret   z
  sub   a,16
  cp    (ix+enemies_and_objects.y)
  ret   nc
  ;check y collision with object 3 (stone 3) bottom
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,17
  cp    (ix+enemies_and_objects.y)
  ret   c

  ;check x collision with object 3 (stone 3) check on the left side of this stone
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,17
  cp    (ix+enemies_and_objects.x)
  ret   c

  ;check x collision with object 3 (stone 3) check on the right side of this stone
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,15 -33
  cp    (ix+enemies_and_objects.x)
  ret   nc

  ;other stone found, snap to stone
  ld    a,(ix+enemies_and_objects.y)        ;y object
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y object
  
  ld    (ix+enemies_and_objects.v2),0       ;0=pushing stone, 1=falling stone
  ret

CheckFloorFallingStone:                     ;if a floor is found, snap to tile, and change back to pushing stone
  ld    b,+32                               ;add y to check (y is expressed in pixels)
  ld    de,+08                              ;add x to check (x is expressed in pixels)
  call  checktileObject                     ;out z=collision found with wall
  ret   nz
  
  ;floor found, snap to floor
  ld    a,(ix+enemies_and_objects.y)        ;y object
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y object
  
  ld    (ix+enemies_and_objects.v2),0       ;pushing stone
  ld    (ix+enemies_and_objects.v3),1       ;vertical movement
  ld    (ix+enemies_and_objects.v6),0       ;v6 acceleration timer
  ret

AccelerateFall:
  ld    a,(ix+enemies_and_objects.v6)       ;v6 acceleration timer
  inc   a
  and   3
  ld    (ix+enemies_and_objects.v6),a
  ret   nz
  ld    a,(ix+enemies_and_objects.v3)       ;vertical movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a
  ret
 
MoveObject:                                 ;adds v3 to y, adds v4 to x. x+y are 8 bit
  ld    a,(ix+enemies_and_objects.y)        ;y object
  add   a,(ix+enemies_and_objects.v3)       ;add y movement to y
  ld    (ix+enemies_and_objects.y),a        ;y object

  ld    a,(ix+enemies_and_objects.x)        ;x object
  add   a,(ix+enemies_and_objects.v4)       ;add x movement to x
  ld    (ix+enemies_and_objects.x),a        ;x object
  ret
  
SetCoordinatesPuzzlePushingStones:
  ld    (ix+enemies_and_objects.v7),1       ;Puzzle pushing stones can resume the coordinates they had last time player entered screen

  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  
  ld    a,(hl)
  ld    (ix+enemies_and_objects.y),a        ;y object
  inc   hl
  ld    a,(hl)
  ld    (ix+enemies_and_objects.x),a        ;x object
  ret

StoreCoordinatesPuzzlePushingStones:
  ld    l,(ix+enemies_and_objects.coordinates)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  
  ld    a,(ix+enemies_and_objects.y)        ;y object
  ld    (hl),a
  inc   hl
  ld    a,(ix+enemies_and_objects.x)        ;x object
  ld    (hl),a
  ret
  
PushingStone:
  ld    a,(ix+enemies_and_objects.v7)       ;Puzzle pushing stones can resume the coordinates they had last time player entered screen
  or    a
  jp    z,SetCoordinatesPuzzlePushingStones
  ld    a,(ix+enemies_and_objects.v7)       ;Puzzle pushing stones can resume the coordinates they had last time player entered screen
  dec   a
  call  z,StoreCoordinatesPuzzlePushingStones

  ld    a,(ix+enemies_and_objects.v2)       ;falling stone?
  or    a
  jp    nz,FallingStone

  call  CheckFloorOrStonePushingStone       ;Check if Stone is still on a platform or on top of another stone. If not, stone falls. Out z=collision found

  call  VramObjects                         ;put object in Vram/screen
  call  MoveStoneWhenPushed                 ;check if stoned needs to be moved
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object. Out: b=255 collision right side of object. b=254 collision left side of object
  inc   b
  jp    z,.CollisionRightSide               ;if you collide with a pushing stone from the right side and you are running, then change to pushing pose; if you are pushing, then move stone
  inc   b 
  jp    z,.CollisionLeftSide                ;if you collide with a pushing stone from the left side and you are running, then change to pushing pose; if you are pushing, then move stone
  ret

  .CollisionRightSide:
;if you collide with a pushing stone from the right side and you are running, then change to pushing pose
	ld		de,(PlayerSpriteStand)
	ld		hl,Lrunning
  sbc   hl,de
  jp    z,Set_L_Push
;if you collide with a pushing stone from the right side and you are pushing, then move stone
	ld		hl,Lpushing
  xor   a
  sbc   hl,de
  ret   nz

  ;unable to push stone if there is another stone lying on top of this one
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z

  ld    (ix+enemies_and_objects.v4),-1      ;horizontal movement
  ret

  .CollisionLeftSide:
;if you collide with a pushing stone from the left side and you are running, then change to pushing pose
	ld		de,(PlayerSpriteStand)
	ld		hl,Rrunning
  sbc   hl,de
  jp    z,Set_R_Push
;if you collide with a pushing stone from the left side and you are pushing, then move stone
	ld		hl,Rpushing
  xor   a
  sbc   hl,de
  ret   nz

  ;unable to push stone if there is another stone lying on top of this one
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  ret   z

  ld    (ix+enemies_and_objects.v4),+1      ;horizontal movement    
  ret

;When Stone is not moving set x coordinate to odd. The reason we do that is that when copying the block x coordinate is even, and we then can use a fast copy instruction
SetOddX:
  set   0,(ix+enemies_and_objects.x)
  ret

MoveStoneWhenPushed:
  ld    a,(framecounter)
  and   1
  ret   nz

  ld    a,(ix+enemies_and_objects.v4)       ;v4=horizontal movement. Return if 0
  ld    (ix+enemies_and_objects.v4),+0    
  or    a
  jp    z,SetOddX
;  ret   z
  
	ld		hl,Rpushing                         ;check if we are pushing Right
	ld		de,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jp    z,.MovingRight

	ld		hl,Lpushing                         ;check if we are pushing Left
  xor   a
  sbc   hl,de
  ret   nz
  
  .MovingLeft:
  call  CheckCollisionOtherStonesLeft       ;out: z= collision found
  ret   z
  
  ;if Pushing Stone moves left, check if it hits wall on the left side
  ld    b,YaddFeetPlayer-1                  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-31               ;add to x to check right side of player for collision (player moved right)
  call  checktile                           ;out z=collision found with wall
  ret   z
  dec   (ix+enemies_and_objects.x)          ;move pushing stone left
  ret

  .MovingRight:
  call  CheckCollisionOtherStonesRight      ;out: z= collision found
  ret   z
    
  ;if Pushing Stone moves right, check if it hits wall on the right side
  ld    b,YaddFeetPlayer-1                  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer+16               ;add to x to check left side of player for collision (player moved left)
  call  checktile                           ;out z=collision found with wall
  ret   z
  inc   (ix+enemies_and_objects.x)          ;move pushing stone right
  ret

CheckCollisionOtherStonesLeft:              ;out: z= collision found
  ;check collision with object 1 (stone 1)
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jr    nz,.EndCheckStone1
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,18
  cp    (ix+enemies_and_objects.x)
  ret   z
  .EndCheckStone1:

  ;check collision with object 2 (stone 2)
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jr    nz,.EndCheckStone2
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,18
  cp    (ix+enemies_and_objects.x)
  ret   z
  .EndCheckStone2:

  ;check collision with object 3 (stone 3)
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  ret   nz
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,18
  cp    (ix+enemies_and_objects.x)
  ret

CheckCollisionOtherStonesRight:             ;out: z= collision found
  ;check collision with object 1 (stone 1)
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jr    nz,.EndCheckStone1
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,-18
  cp    (ix+enemies_and_objects.x)
  ret   z
  .EndCheckStone1:
  
  ;check collision with object 2 (stone 2)
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  jr    nz,.EndCheckStone2  
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,-18
  cp    (ix+enemies_and_objects.x)
  ret   z
  .EndCheckStone2:
    
  ;check collision with object 3 (stone 3)
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.y)
  ret   nz  
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,-18
  cp    (ix+enemies_and_objects.x)
  ret

PlatformHorizontally:
;v1 = sx
;v3=Vertical Movement
;v4=Horizontal Movement
  call  VramObjectsTransparantCopies        ;put object in Vram/screen
  call  MovePlatFormHorizontally            ;move
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  ret
  
PlatformVertically:
  call  VramObjectsTransparantCopies        ;put object in Vram/screen
  call  MovePlatFormVertically              ;move
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  ret

MovePlatFormVertically:
  ld    a,(framecounter)
  and   1
  ret   nz

  ld    a,(ix+enemies_and_objects.SnapPlayer?)
  or    a
  call  nz,MovePlayerAlongWithObject

;move object
  ld    a,(ix+enemies_and_objects.y)
  add   (ix+enemies_and_objects.v3)
  ld    (ix+enemies_and_objects.y),a  
  cp    180
  jr    z,.ChangeDirection
  cp    40
  ret   nz

  .ChangeDirection:
  ld    a,(ix+enemies_and_objects.v3)
  neg
  ld    (ix+enemies_and_objects.v3),a
  ret

MovePlatFormHorizontally:
  ld    a,(framecounter)
  and   3
  ret   nz

  ld    a,(ix+enemies_and_objects.SnapPlayer?)
  or    a
  call  nz,MovePlayerAlongWithObject

;move object
  ld    a,(ix+enemies_and_objects.x)
  add   (ix+enemies_and_objects.v4)
  ld    (ix+enemies_and_objects.x),a  
  cp    254
  jr    z,.ChangeDirection
  cp    17+16     ;17 for 32 pix wide objects, 17+16 for 16 pix wide objects
  ret   nz

  .ChangeDirection:
  ld    a,(ix+enemies_and_objects.v4)
  neg
  ld    (ix+enemies_and_objects.v4),a
  ret

VramObjects:
;first clean the object
;  call  BackdropRed

;which Clean Object (DoCopy) table do we use ?
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  push  hl
  call  docopy
  pop   iy

  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

  .ObjectOnRightSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0000      ;Copy from left to right
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+01         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound


  .ObjectOnLeftSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  dec   a
  add   a,(ix+enemies_and_objects.nx)
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0100      ;Copy from right to left
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000            ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,0               ;clean object from vram data in page 2
  ld    d,-016            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,1               ;clean object from vram data in page 3
  ld    d,-032            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

.pagefoundLeft:
  ld    a,d
  add   a,(ix+enemies_and_objects.nx)
  ld    d,a
 
.pagefound:
  ld    a,b
  ld    (CopyObject+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+enemies_and_objects.y)
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyObject+dy),a

  ld    a,(ix+enemies_and_objects.x)
  add   d
  ld    (CopyObject+dx),a
  ld    (iy+dx),a
  add   e
  ld    (iy+sx),a
  
  ld    a,(ix+enemies_and_objects.nx)  
  ld    (CopyObject+nx),a  
  add   a,2                 ;we clean 2 more pixels, because we use fast copy ($D0) for cleaning, which is not pixel precise (Bitmap mode)
  ld    (iy+nx),a  

  ld    a,(ix+enemies_and_objects.ny)
  ld    (CopyObject+ny),a  
  ld    (iy+ny),a  

;With this little routine, we switch sy between even and uneven dx to simulate fluent pixel per pixel movement, when in fact we only move per 2 pixels. Copy instruction should be $d0
;  ld    a,(CopyObject+dx)
;  and   %0000 0001
;  ld    a,216
;  jr    z,.setSy
;  ld    a,216+16
;  .setSy:
;  ld    (CopyObject+sy),a
;  ld    a,$d0
;  ld    (CopyObject+copytype),a

;this routine switches between fast copies (when x is even) and slow copies (when x is odd)
  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen2

.ObjectOnRightSideOfScreen2:
  ld    a,(CopyObject+dx)
  and   %0000 0001
  ld    a,$d0
  jr    z,.setCopyType
  ld    a,$90
  jp    .setCopyType

.ObjectOnLeftSideOfScreen2:
  ld    a,(CopyObject+dx)
  and   %0000 0001
  ld    a,$90
  jr    z,.setCopyType
  ld    a,$d0
  .setCopyType:
  ld    (CopyObject+copytype),a

;put object
  ld    hl,CopyObject
  call  docopy
;  call  BackdropGreen
;  ld    hl,CopyObject
;  call  docopy
;  call  BackdropBlack
  ret

VramObjectsTransparantCopies:
;first clean the object
;  call  BackdropRed

;which Clean Object (DoCopy) table do we use ?
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  push  hl
  call  docopy
  pop   iy

  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

  .ObjectOnRightSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0000      ;Copy from left to right
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+01         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound


  .ObjectOnLeftSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  dec   a
  add   a,(ix+enemies_and_objects.nx)
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0100      ;Copy from right to left
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000            ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,0               ;clean object from vram data in page 2
  ld    d,-016            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,1               ;clean object from vram data in page 3
  ld    d,-032            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

.pagefoundLeft:
  ld    a,d
  add   a,(ix+enemies_and_objects.nx)
  ld    d,a
 
.pagefound:
  ld    a,b
  ld    (CopyObject+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+enemies_and_objects.y)
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyObject+dy),a

  ld    a,(ix+enemies_and_objects.x)
  add   d
  ld    (CopyObject+dx),a
  ld    (iy+dx),a
  add   e
  ld    (iy+sx),a
  
  ld    a,(ix+enemies_and_objects.nx)  
  ld    (CopyObject+nx),a  
  add   a,2                 ;we clean 2 more pixels, because we use fast copy ($D0) for cleaning, which is not pixel precise (Bitmap mode)
  ld    (iy+nx),a  

  ld    a,(ix+enemies_and_objects.ny)
  ld    (CopyObject+ny),a  
  ld    (iy+ny),a  

  ld    a,$98
  ld    (CopyObject+copytype),a

;put object
  ld    hl,CopyObject
  call  docopy
;  call  BackdropGreen
;  ld    hl,CopyObject
;  call  docopy
;  call  BackdropBlack
  ret  