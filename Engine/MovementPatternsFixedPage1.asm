;CheckOutOfMap
;MoveSpriteHorizontallyAndVertically
;CheckCollisionWallEnemy
;CheckCollisionWallEnemyV8
;CheckFloorUnderBothFeetEnemy
;CheckFloorEnemyObjectLeftSide
;CheckFloorEnemyObject
;CheckFloorEnemy
;distancecheck46wide
;distancecheck24wide
;distancecheck16wide
;distancecheck
;checkFacingPlayer
;CheckPlayerPunchesEnemyOnlySitting
;CheckPrimaryWeaponHitsEnemy
;CheckSecundaryWeaponHitsEnemy
;CheckPlayerPunchesBoss
;CheckPlayerPunchesEnemyDemon
;CheckPlayerPunchesEnemy
;ExplosionBig
;ExplosionSmall
;PutCoin
;Coin
;FallingStone
;AccelerateFall
;MoveObject
;PushingStone
;InitiatlizeSwitch
;checktileObject
;AnimateSprite
;MoveObjectWithStepTable
;SetFrameBoss
;PutSf2Object3Frames
;NonMovingObjectMovementTable
;DamagePlayerIfNotJumping

DamagePlayerIfNotJumping:
	ld		hl,Jump
	ld		de,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  ret   z
  jp    CollisionEnemyPlayer.PlayerIsHit


NonMovingObjectMovementTable:
  db    127,0,0, 128

PutSf2Object3Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    3
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a

  or    a  
  jr    z,.Top
  dec   a
  jr    z,.Middle

  .Bottom:
  call  restoreBackgroundObject3
  ld    a,(ix+enemies_and_objects.v7)
  add   a,2
  call  SetFrameBoss
  call  PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine
  
  .Middle:
  call  restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
  inc   a
  call  SetFrameBoss
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Top:
  call  restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

SetFrameBoss:
  ld    l,a                                 ;v7=sprite frame
  ld    h,0                                  ;hl=sprite frame
  add   hl,hl                               ;*2
  add   hl,hl                               ;*4
  add   hl,de                               ;frame * 12 + frame address

  .SetFrameSF2Object:
  ld    a,(hl)
  ld    (Player1Frame),a
  inc   hl
  ld    a,(hl)
  ld    (Player1Frame+1),a
  inc   hl
  ld    b,(hl)                              ;frame list block
  inc   hl
  ld    c,(hl)                              ;sprite data block
  ret

MoveObjectWithStepTable:
  ;if repeating steps are not 0, go to movement object
;  ld    a,(ix+enemies_and_objects.v1)         ;repeating steps
;  dec   a
;  ld    (ix+enemies_and_objects.v1),a         ;repeating steps
  dec   (ix+enemies_and_objects.v1)           ;repeating steps
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

AnimateSprite:
  ld    a,(framecounter)                    ;animate every x frames
  and   b
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  jp    nz,.SetAnimationCounter
  add   a,2                                 ;2 bytes used for pointer to sprite frame address
  cp    c                                   ;amount of frame addresses
  jP    nz,.SetAnimationCounter
  xor   a
  .SetAnimationCounter:
  ld    (ix+enemies_and_objects.v1),a       ;v1=Animation Counter
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
  ex    de,hl                               ;out hl -> sprite character data to out to Vram
  ret	

;Generic Enemy/Object Routines ##############################################################################
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
  ld    (ix+enemies_and_objects.y),217+2    ;y  
  ret

MoveSpriteHorizontallyAndVertically:        ;Add v3 to y. Add v4 to x (16 bit)
  call  MoveSpriteVertically

  MoveSpriteHorizontally:                   ;Add v3 to y. Add v4 to x (16 bit)
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;	ld		a,(Controls)
;	bit		6,a                                 ;F1 pressed ?
;	ret   nz
	
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
  ld    a,(ix+enemies_and_objects.ny)       ;add to y (y is expressed in pixels)
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

CheckCollisionWallEnemyV8:                  ;checks for collision wall and if found invert horizontal movement
  ld    a,(ix+enemies_and_objects.ny)       ;add to y (y is expressed in pixels)
  ld    hl,-16                              ;add to x to check right side of sprite for collision
  bit   7,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
  jr    z,.MovingRight
  .MovingLeft:
  call  CheckTileEnemyInHL                  ;out z=collision found with wall  
  ret   nz
  ld    a,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v8),a       ;v4=Horizontal Movement
  ret
  .MovingRight:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  add   hl,de
  call  CheckTileEnemyInHL                  ;out z=collision found with wall  
  ret   nz
  ld    a,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v8),a       ;v4=Horizontal Movement
  ret

CheckFloorUnderBothFeetEnemy:               ;Used for Zombie, to check if he is completely without floor under him
  ld    hl,-16
  ld    a,(ix+enemies_and_objects.ny)       
  add   a,16
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  jr    z,.MovingRight
  .MovingLeft:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  add   hl,de
  add   hl,hl                               ;0 if nx=16, 32 if nx=32, 64 if nx=48 formula=(nx-16) *2
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  
  .MovingRight:
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  
  
CheckFloorEnemyObjectLeftSide:
  ld    hl,0
  ld    a,(ix+enemies_and_objects.ny)       
  add   a,16
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  
CheckFloorEnemyObject:
  ld    hl,0
  jp    CheckFloorEnemy.ObjectEntry
CheckFloorEnemy:  
  ld    hl,-16  
  .ObjectEntry:
  ld    a,(ix+enemies_and_objects.ny)       
  add   a,16
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  jr    z,.MovingRight
  .MovingLeft:
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  
  .MovingRight:
  ld    d,0
  ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
  add   hl,de
  jp    CheckTileEnemyInHL                  ;out z=collision found with wall  

distancecheck46wide:                        ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ld    hl,(Clesx)                          ;hl = x player
  ld    de,09-15
  add   hl,de
  jp    distancecheck.go

distancecheck24wide:                        ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ld    hl,(Clesx)                          ;hl = x player
  ld    de,09-4
  add   hl,de
  jp    distancecheck.go

distancecheck16wide:           ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ld    hl,(Clesx)                          ;hl = x player
  ld    de,09
  add   hl,de
  jp    distancecheck.go
distancecheck:                              ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ld    hl,(Clesx)                          ;hl = x player
  .go:
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
  
CheckPlayerPunchesEnemyOnlySitting:
  ld    a,(HitBoxSY)                        ;a = y hitbox
  push  af
  sub   a,9
  ld    (HitBoxSY),a                        ;a = y hitbox
  call  CheckPlayerPunchesEnemy
  pop   af
  ld    (HitBoxSY),a                        ;a = y hitbox
  ret

CheckPrimaryWeaponHitsEnemy:
  cp    128                                 ;presenting bow
  ret   z

;if the bottom of the weapon is above the top of the enemy = no hit
  ld    a,(PrimaryWeaponYBottom)
  sub   (ix+enemies_and_objects.y)
  ret   c  

;if the top of the weapon is below the bottom of the enemy = no hit
  ld    a,(PrimaryWeaponY)
  ld    b,a
  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)       ;y+ny=bottom of enemy
  sub   a,b
  ret   c

;if the right side of the weapon is left from the left side of the enemy = no hit
  ld    hl,(PrimaryWeaponXRightSide)        ;hl = x hitbox
  ld    bc,32
  add   hl,bc                               ;right side of primary weapon (inclusing offset)
  
;Moet deze code er misschien TOCH in voor de SF2 engine ?
;  ld    a,(scrollEngine)                    ;1= 304x216 engine  2=256x216 SF2 engine
;  dec   a
;  ld    bc,46                               ;normal engine
;  jr    z,.engineFound
;  ld    bc,46 - 16                          ;sf2 engine (46 - 14 for arrows)
;  .engineFound:
;  add   hl,bc                               ;right side of primary weapon (inclusing offset)
  
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;if the left side of the weapon is right from the right side of the enemy = no hit
  ld    h,0
  ld    l,(ix+enemies_and_objects.nx)       ;width object
  add   hl,de                               ;de: right side of enemy/object 
  ex    de,hl

  ld    hl,(PrimaryWeaponX)                 ;hl = x hitbox 
  add   hl,bc                               ;left side of primary weapon (inclusing weird)

;  ld    a,(scrollEngine)                    ;1= 304x216 engine  2=256x216 SF2 engine
;  dec   a
;  ld    bc,46                               ;normal engine
;  jr    z,.engineFound2
;  ld    bc,46 - 16                          ;sf2 engine (46 - 14 for arrows)
;  .engineFound2:
;  add   hl,bc                               ;left side of primary weapon (inclusing offset for engine type)

  sbc   hl,de
  ret   nc
  
  
  jp    CheckSecundaryWeaponHitsEnemy.hit


CheckSecundaryWeaponHitsEnemy:
;if the bottom of the weapon is above the top of the enemy = no hit
  ld    a,(SecundaryWeaponYBottom)
  sub   (ix+enemies_and_objects.y)
  ret   c  

;if the top of the weapon is below the bottom of the enemy = no hit
  ld    a,(SecundaryWeaponY)
  ld    b,a
  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)       ;y+ny=bottom of enemy
  sub   a,b
  ret   c

;check if enemy/object collides with hitbox arrow left side
  ld    hl,(SecundaryWeaponX)                      ;hl = x hitbox
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 18                          ;sf2 engine (46 - 14 for arrows)
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,11    ;16 for arrows              ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (SecundaryWeaponActive?),a                    ;remove arrow when enemy is hit

  ld    a,MagicWeaponDurationValue
  ld    (MagicWeaponDuration),a  
  
  .hit:  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret
  
CheckPlayerPunchesBoss:
CheckPlayerPunchesEnemyDemon:
  ld    hl,(ClesX)
  
  ;adjust hitbox when facing left or right (this only applies to bossfights)
  ld    a,(PlayerFacingRight?)
  or    a
  ld    de,43
  jr    nz,.PlayerFacingDirectionFound
  ld    de,43-34  
  .PlayerFacingDirectionFound:
  
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 6 - 60
  ld    (HitBoxSY),a
  
  ld    a,(SecundaryWeaponY)                       ;a = y hitbox
  sub   a,60
  ld    (SecundaryWeaponY),a                       ;a = y hitbox
  call  CheckPlayerPunchesEnemy
  ld    a,(SecundaryWeaponY)                       ;a = y hitbox
  add   a,60
  ld    (SecundaryWeaponY),a                       ;a = y hitbox
  ret
;  jp    CheckPlayerPunchesEnemy

BlinkDurationWhenHit: equ 31  
CheckPlayerPunchesEnemy:  
  ld    a,(ix+enemies_and_objects.hit?)     ;reduce enemy is hit counter
  dec   a
  jp    m,.EndReduceHitTimer
  ld    (ix+enemies_and_objects.hit?),a
  ret                                       ;if enemy is  already hit, don't check if it's hit again
  .EndReduceHitTimer:
 
  ld    a,(SecundaryWeaponActive?)
  or    a
  call  nz,CheckSecundaryWeaponHitsEnemy

  ld    a,(PrimaryWeaponActive?)
  or    a
  call  nz,CheckPrimaryWeaponHitsEnemy

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
  jr    z,.EnemyDied
  
	ld		de,(PlayerSpriteStand)
	ld		hl,Charging
  xor   a
  sbc   hl,de
  ret   nz

  ;At this point you hit an enemy with a charge attack, but enemy didn't die. Player now bounces backwards.
  ld    a,(PlayerFacingRight?)
  or    a
  jp    nz,Set_R_BouncingBack
  jp    Set_L_BouncingBack
  
  .EnemyDied:
  ld    (ix+enemies_and_objects.hit?),00    ;stop blinking white when dead

  ;Enemy dies
  ld    a,(ix+enemies_and_objects.nrspritesSimple)
  cp    8
  jr    c,.ExplosionSmall  

  .ExplosionBig:
  ld    hl,ExplosionBig
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  
  ;x position of explosion is x - 16 + (nx/2)
  ld    a,(ix+enemies_and_objects.nx)
	srl		a                                   ;/2
  ld    d,0
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de
  ld    de,-16
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

  ;we remove all sprite y's from spat. This way any remaining sprites from the object before the explosion will get removed properly
  ld    l,(ix+enemies_and_objects.spataddress)
  ld    h,(ix+enemies_and_objects.spataddress+1)
  ld    b,(ix+enemies_and_objects.nrspritesSimple)
  .loop:
  ld    (hl),217
  inc   hl
  inc   hl
  djnz  .loop
  
  ld    (ix+enemies_and_objects.nrsprites),72-(08*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),8
  ld    (ix+enemies_and_objects.nrspritesTimes16),8*16  
  ret
  
  .ExplosionSmall:
  ld    hl,ExplosionSmall
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  
  ;x position of explosion is x - 8 + (nx/2)
  ld    a,(ix+enemies_and_objects.nx)
	srl		a                                   ;/2
  ld    d,0
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de
  ld    de,-8
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
    
  call  .Animate                            ;out hl -> sprite character data to out to Vram
  
	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret

  .Animate: 
  ld    hl,ExplosionBigAnimation
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;05 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 05                              ;05 animation frame addresses
  ret   nz
;  jp    RemoveSprite

  push  hl
  ld    l,(ix+enemies_and_objects.x)        ;v1=Animation Counter
  ld    h,(ix+enemies_and_objects.x+1)      ;v1=Animation Counter
  ld    de,10
  add   hl,de
  ld    (ix+enemies_and_objects.x),l        ;v1=Animation Counter
  ld    (ix+enemies_and_objects.x+1),h      ;v1=Animation Counter
  pop   hl
  
  jp    PutCoin

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

  call  .Animate                            ;out hl -> sprite character data to out to Vram
  
	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)

  ld    (ix+enemies_and_objects.nrsprites),72-(02*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),2
  ld    (ix+enemies_and_objects.nrspritesTimes16),2*16
  ret

  .Animate: 
  ld    hl,ExplosionSmallAnimation
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 05                            ;05 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04                              ;04 animation frame addresses
  ret   nz
;  jp    RemoveSprite

PutCoin:
  ld    de,Coin
  ld    (ix+enemies_and_objects.movementpattern),e
  ld    (ix+enemies_and_objects.movementpattern+1),d
  ld    (ix+enemies_and_objects.v2),0       ;v2=Coin Phase (0=falling, 1=lying still, 2=flying towards player)
  ld    (ix+enemies_and_objects.v3),3       ;v3=Vertical Movement
  ld    (ix+enemies_and_objects.v4),0       ;v4=Horizontal Movement
  ld    (ix+enemies_and_objects.nx),16      ;width coin
  ld    (ix+enemies_and_objects.ny),16      ;height coin

  ;backup y and move sprite out of screen
  ld    a,(ix+enemies_and_objects.y)        ;y  
  ld    (ix+enemies_and_objects.v7),a       ;y backup
  ld    (ix+enemies_and_objects.y),217      ;y

ld a,r
and 3
  ld    (ix+enemies_and_objects.v8),a       ;v8=coin type (0=I, 1=V, 2=X)
  ret

ExplosionSmallAnimation:
  dw  RedExplosionSmall1_Char 
  dw  RedExplosionSmall2_Char 
  dw  RedExplosionSmall3_Char 
  dw  RedExplosionSmall4_Char
  dw  RedExplosionSmall4_Char

Coin:
;v1=Animation Counter
;v2=Phase (0=falling, 1=lying still, 2=flying towards player)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer until able to fly towards player
;v6=Wait timer until disappear
;v7=y backup
;v8=coin type (0=I, 1=V, 2=X)
  call  .HandlePhase                        ;(0=falling, 1=lying still, 2=flying towards player) 

  ld    (ix+enemies_and_objects.nrsprites),72-(02*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),2
  ld    (ix+enemies_and_objects.nrspritesTimes16),2*16

  ld    a,(ix+enemies_and_objects.v7)       ;y backup
  or    a
  jr    z,.YRestored
  ld    (ix+enemies_and_objects.y),a        ;y  
  ld    (ix+enemies_and_objects.v7),0       ;y backup
  .YRestored:

	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret

  .Animate: 
  ld    a,(ix+enemies_and_objects.v8)       ;v8=coin type (0=I, 1=V, 2=X)
  or    a
  ld    hl,CoinIAnimation
  jr    z,.CoinTypeFound
  dec   a
  ld    hl,CoinVAnimation
  jr    z,.CoinTypeFound
  ld    hl,CoinXAnimation
  .CoinTypeFound:

  ld    b,3                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=falling, 1=lying still, 2=flying towards player) 
  or    a
  jp    z,CoinFalling
  dec   a
  jp    z,CoinLyingStill
  dec   a
  jp    z,CoinFlyingTowardsPlayer
;  dec   a
;  jp    z,CoinAfterglow
  
  CoinAfterglow:
  ld    hl,CoinAfterglowAnimation
  ld    b,3                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 21                            ;06 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 20
  ret   nz
  jp    RemoveSprite
  
  CoinFlyingTowardsPlayer:
  call  CheckPickUpCoin                     ;check for collision between player and coin and removes coin from play when picked up  
  call  CoinMoveTowardsPlayer
  ret

  CoinLyingStill:
  call  CheckPickUpCoin                     ;check for collision between player and coin and removes coin from play when picked up
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Wait timer until able to fly towards player
  dec   a
  jr    z,.CheckCoinNearPlayer
  ld    (ix+enemies_and_objects.v5),a       ;v5=Wait timer until able to fly towards player
  jp    Coin.Animate                        ;out hl -> sprite character data to out to Vram
;  ret

  .CheckCoinNearPlayer:                     ;Check if coin is near player, if so fly towards player
  ld    b,08+40                             ;b-> x distance
  ld    c,16+00                             ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  jr    nc,.EndCheckNearCoin
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=falling, 1=lying still, 2=flying towards player)
  
  .EndCheckNearCoin:
  call  Coin.Animate                        ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Wait timer until disappear
  dec   a
  ld    (ix+enemies_and_objects.v6),a       ;v6=Wait timer until disappear
  jp    z,RemoveSprite
  cp    70
  ret   nc
  ld    a,(framecounter)
  and   3
  ret   nz
  ld    hl,CoinEmpty_Char
  ret

  CoinFalling:
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  call  .CheckFloor                         ;checks for collision Floor and if found fall
  call  CheckPickUpCoin                     ;check for collision between player and coin and removes coin from play when picked up


  ld    a,(ix+enemies_and_objects.y)        ;y
  cp    210
  jr    c,.SkipSetTopInScreen
  ld    (ix+enemies_and_objects.y),0        ;y
  .SkipSetTopInScreen:


  jp    Coin.Animate                        ;out hl -> sprite character data to out to Vram
;  ret

  .CheckFloor:                              ;checks for floor. 
  call  CheckFloorUnderBothFeetEnemy        ;checks for floor, out z=collision found with floor - This is used for the Zombie, but works very well for the coin as well
  ret   nz

  ;snap to platform
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %1111 1000
;  add   a,2
  ld    (ix+enemies_and_objects.y),a        ;y
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=falling, 1=lying still, 2=flying towards player)
  ld    (ix+enemies_and_objects.v5),90      ;v5=Wait timer until able to fly towards player
  ld    (ix+enemies_and_objects.v6),220     ;v6=Wait timer until disappear
  ret

  CoinMoveTowardsPlayer:
  ;set y movement in b
  ld    a,(ClesY)

;  sub   a,8 - 7
  dec   a
  
  ld    b,(ix+enemies_and_objects.y)        ;y
  sub   a,b
  ld    b,-1
  jr    c,.EndCheckY
  ld    b,+1    
  .EndCheckY:
  jp    p,.EndCheckYPositive
  neg
  .EndCheckYPositive:
  cp    6
  jr    nc,.EndCheckYSmallerThan6
  ld    b,0
  .EndCheckYSmallerThan6:
  ;/set y movement in b

  ;set x movement in e
  ld    hl,(ClesX)
  ld    de,8
  add   hl,de

  ld    e,(ix+enemies_and_objects.x)        ;y
  ld    d,(ix+enemies_and_objects.x+1)      ;y
  sbc   hl,de
  ld    de,-1
  jr    c,.EndCheckX
  ld    de,+1    
  .EndCheckX:

  ld    a,l
  jp    p,.EndCheckXPositive
  neg
  .EndCheckXPositive:
  cp    6
  jr    nc,.EndCheckXSmallerThan6
  ld    de,0
  .EndCheckXSmallerThan6:
  ;/set x movement in e
  
  
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,b
  add   a,b
  ld    (ix+enemies_and_objects.y),a        ;y 

  ld    l,(ix+enemies_and_objects.x)        ;x
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de
  add   hl,de
  ld    (ix+enemies_and_objects.x),l        ;x
  ld    (ix+enemies_and_objects.x+1),h      ;x

;       de=-1   de=0  de=+1
;b=-1   LU      U     RU
;b=-0   L             R
;b=+1   LD      D     RD

  ld    a,b
  inc   a                                   ;b=0, 1 or 2
  add   a,a                                 ;*2
  ld    c,a
  add   a,a                                 ;*4
  add   a,c                                 ;*6
  ld    b,0
  ld    c,a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=coin type (0=I, 1=V, 2=X)
  or    a
  ld    hl,CoinITable
  jr    z,.CoinTypeFound
  dec   a
  ld    hl,CoinVTable
  jr    z,.CoinTypeFound
  ld    hl,CoinXTable
  .CoinTypeFound:

  inc   de                                  ;de=0, 1 or 2
  add   hl,de
  add   hl,de
  add   hl,bc
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
  ex    de,hl
  ret
  
  CoinITable:
  dw    CoinILU_Char,CoinIU_Char,CoinIRU_Char
  dw    CoinIL_Char,CoinIL_Char,CoinIR_Char
  dw    CoinILD_Char,CoinID_Char,CoinIRD_Char

  CoinVTable:
  dw    CoinVLU_Char,CoinVU_Char,CoinVRU_Char
  dw    CoinVL_Char,CoinVL_Char,CoinVR_Char
  dw    CoinVLD_Char,CoinVD_Char,CoinVRD_Char
  
  CoinXTable:
  dw    CoinXLU_Char,CoinXU_Char,CoinXRU_Char
  dw    CoinXL_Char,CoinXL_Char,CoinXR_Char
  dw    CoinXLD_Char,CoinXD_Char,CoinXRD_Char
  
  CheckPickUpCoin:
  ld    b,08                                ;b-> x distance
  ld    c,16                                ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc 

  ld    (ix+enemies_and_objects.v1),00      ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=falling, 1=lying still, 2=flying towards player, 3=coin afterglow)
  ret

CoinIAnimation:
  dw  CoinI1_Char
  dw  CoinI2_Char
  dw  CoinI3_Char
  dw  CoinI4_Char
  dw  CoinI5_Char
  dw  CoinI6_Char

CoinVAnimation:
  dw  CoinV1_Char
  dw  CoinV2_Char
  dw  CoinV3_Char
  dw  CoinV4_Char
  dw  CoinV5_Char
  dw  CoinV6_Char

CoinXAnimation:
  dw  CoinX1_Char
  dw  CoinX2_Char
  dw  CoinX3_Char
  dw  CoinX4_Char
  dw  CoinX5_Char
  dw  CoinX6_Char
  
CoinAfterglowAnimation:
  dw  CoinAfterglow1_Char
  dw  CoinAfterglow2_Char
  dw  CoinAfterglow3_Char
  dw  CoinAfterglow4_Char
  dw  CoinAfterglow5_Char
  dw  CoinAfterglow6_Char
  dw  CoinAfterglow7_Char
  dw  CoinAfterglow8_Char
  dw  CoinAfterglow9_Char
  dw  CoinAfterglow10_Char
  dw  CoinAfterglow11_Char
  dw  CoinAfterglow12_Char
  dw  CoinAfterglow13_Char
  dw  CoinAfterglow14_Char
  dw  CoinAfterglow15_Char
  dw  CoinAfterglow16_Char
  dw  CoinAfterglow17_Char
  dw  CoinAfterglow18_Char
  dw  CoinAfterglow19_Char
  dw  CoinAfterglow20_Char
  dw  CoinAfterglow20_Char
  














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

  