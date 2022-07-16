;This is at $4000 inside a block (movementpatternsblock)
;PlatformVertically              
;PlatformHorizontally            
;Sf2Hugeobject1                  
;Sf2Hugeobject2                  
;Sf2Hugeobject3                    
;PushingStone                       
;PushingPuzzleSwitch                
;PushingPuzzlOverview              
;ZombieSpawnPoint
;RetardedZombie   
;GreenSpider                
;GreySpider
;Grinder
;Wasp
;Landstrider
;FireEyeGrey
;FireEyeGreen
;FireEyeFireBullet
;Slime
;Beetle
;Treeman
;BoringEye
;BatSpawner
;Bat
;Demontje
;DemontjeBullet
;Hunchback
;Scorpion
;Octopussy
;OctopussyBullet
;HugeBlob
;HugeBlobSWsprite
;OP_SlowDownHandler
;GlassBall1
;GlassBall2
;SensorTentacles
;YellowWasp
;SnowballThrower
;Snowball
;TrampolineBlob
;Lancelot
;LancelotSword
;BlackHoleAlien
;BlackHoleBaby
;Waterfall
;WaterfallEyesYellow
;WaterfallEyesGrey
;WaterfallMouth
;DrippingOoze
;DrippingOozeDrop
;BigStatueMouth
;CuteMiniBat
;PlayerReflection
;AppearingBlocks
;DisappearingBlocks
;AppBlocksHandler
;AreaSign
;HugeSpiderBody
;HugeSpiderLegs
;KonarkPaletteObject
;BossDemon1
;BossDemon2
;BossDemon3
;Altar1
;Altar2

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

CheckArrowHitsEnemy:
;check if enemy/object collides with hitbox arrow left side
  ld    hl,(ArrowX)                         ;hl = x hitbox

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 14                          ;sf2 engine
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,16                                ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox arrow top side
  ld    a,(ArrowY)                          ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c  

;check if enemy/object collides with hitbox arrow bottom side
  sub   a,(ix+enemies_and_objects.ny)       ;width object
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (ArrowActive?),a                    ;remove arrow when enemy is hit
  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret
  
CheckFireballHitsEnemy:
;check if enemy/object collides with hitbox arrow left side
  ld    hl,(FireballX)                      ;hl = x hitbox

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 18                          ;sf2 engine
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,11                                ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox arrow top side
  ld    a,(FireballY)                       ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c  

;check if enemy/object collides with hitbox arrow bottom side
  sub   a,(ix+enemies_and_objects.ny)       ;width object
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (FireballActive?),a                    ;remove arrow when enemy is hit
  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret

CheckIceWeaponHitsEnemy:
;check if enemy/object collides with hitbox arrow left side
  ld    hl,(IceWeaponX)                      ;hl = x hitbox

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 18                          ;sf2 engine
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,11                                ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox arrow top side
  ld    a,(IceWeaponY)                       ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c  

;check if enemy/object collides with hitbox arrow bottom side
  sub   a,(ix+enemies_and_objects.ny)       ;width object
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (IceWeaponActive?),a                    ;remove arrow when enemy is hit
  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret

CheckEarthWeaponHitsEnemy:
;check if enemy/object collides with hitbox arrow left side
  ld    hl,(EarthWeaponX)                      ;hl = x hitbox

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 18                          ;sf2 engine
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,11                                ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox arrow top side
  ld    a,(EarthWeaponY)                       ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c  

;check if enemy/object collides with hitbox arrow bottom side
  sub   a,(ix+enemies_and_objects.ny)       ;width object
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (EarthWeaponActive?),a                    ;remove arrow when enemy is hit
  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret

CheckWaterWeaponHitsEnemy:
;check if enemy/object collides with hitbox arrow left side
  ld    hl,(WaterWeaponX)                      ;hl = x hitbox

  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 18                          ;sf2 engine
  .engineFound:

  add   hl,bc
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de
  ret   c

;check if enemy/object collides with hitbox arrow right side
  ld    c,(ix+enemies_and_objects.nx)       ;width object
  ld    a,11                                ;reduce this value to reduce the hitbox size (on the right side)
  add   a,c
  ld    c,a
  sbc   hl,bc  
  ret   nc

;check if enemy/object collides with hitbox arrow top side
  ld    a,(WaterWeaponY)                       ;a = y hitbox
  sub   (ix+enemies_and_objects.y)
  ret   c  

;check if enemy/object collides with hitbox arrow bottom side
  sub   a,(ix+enemies_and_objects.ny)       ;width object
  ret   nc

  ;Enemy hit                                ;blink white for 31 frames when hit
  xor   a
  ld    (WaterWeaponActive?),a                    ;remove arrow when enemy is hit
  
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ret
  
CheckPlayerPunchesEnemyDemon:
  ld    hl,(ClesX)
  ld    de,35 + 8
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 6 - 60
  ld    (HitBoxSY),a
  
  ld    a,(FireballY)                       ;a = y hitbox
  sub   a,60
  ld    (FireballY),a                       ;a = y hitbox
  ld    a,(ArrowY)                          ;a = y hitbox
  sub   a,60
  ld    (ArrowY),a                          ;a = y hitbox
  call  CheckPlayerPunchesEnemy
  ld    a,(FireballY)                       ;a = y hitbox
  add   a,60
  ld    (FireballY),a                       ;a = y hitbox
  ld    a,(ArrowY)                          ;a = y hitbox
  add   a,60
  ld    (ArrowY),a                          ;a = y hitbox
  ret
;  jp    CheckPlayerPunchesEnemy

BlinkDurationWhenHit: equ 31  
CheckPlayerPunchesEnemy:
  ld    a,(ArrowActive?)
  or    a
  call  nz,CheckArrowHitsEnemy

  ld    a,(FireballActive?)
  or    a
  call  nz,CheckFireballHitsEnemy
  
  ld    a,(IceWeaponActive?)
  or    a
  call  nz,CheckIceWeaponHitsEnemy

  ld    a,(EarthWeaponActive?)
  or    a
  call  nz,CheckEarthWeaponHitsEnemy

  ld    a,(WaterWeaponActive?)
  or    a
  call  nz,CheckWaterWeaponHitsEnemy

  
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
;  ret   nz
  dec   (ix+enemies_and_objects.v1)       ;v1=Zombie Spawn Timer
  ret   nz

;  push  ix
;  call  .SearchEmptySlot
;  pop   ix
;  ret

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
  ld    (ix+enemies_and_objects.nrsprites),72-(04*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),4
  ld    (ix+enemies_and_objects.nrspritesTimes16),4*16
  ld    (ix+enemies_and_objects.life),1
  ret

Template:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BeetleSpriteblock                 ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
    
  .HandlePhase:
  ld    hl,RightBeetleWalk1_Char
  ret


AltarGraphics00top:       dw BossRoomframe000 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics01top:       dw BossRoomframe002 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics02top:       dw BossRoomframe004 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics03top:       dw BossRoomframe006 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics04top:       dw BossRoomframe008 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics05top:       dw BossRoomframe010 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics06top:       dw BossRoomframe012 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics07top:       dw BossRoomframe014 | db BossRoomframelistblock, BossRoomspritedatablock

AltarGraphics08top:       dw BossRoomframe016 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics09top:       dw BossRoomframe018 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics10top:       dw BossRoomframe020 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics11top:       dw BossRoomframe022 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics12top:       dw BossRoomframe024 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics13top:       dw BossRoomframe026 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics14top:       dw BossRoomframe028 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics15top:       dw BossRoomframe030 | db BossRoomframelistblock, BossRoomspritedatablock

AltarGraphics16top:       dw BossRoomframe032 | db BossRoomframelistblock, BossRoomspritedatablock

AltarGraphics00bottom:    dw BossRoomframe001 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics01bottom:    dw BossRoomframe003 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics02bottom:    dw BossRoomframe005 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics03bottom:    dw BossRoomframe007 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics04bottom:    dw BossRoomframe009 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics05bottom:    dw BossRoomframe011 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics06bottom:    dw BossRoomframe013 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics07bottom:    dw BossRoomframe015 | db BossRoomframelistblock, BossRoomspritedatablock

AltarGraphics08bottom:    dw BossRoomframe017 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics09bottom:    dw BossRoomframe019 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics10bottom:    dw BossRoomframe021 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics11bottom:    dw BossRoomframe023 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics12bottom:    dw BossRoomframe025 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics13bottom:    dw BossRoomframe027 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics14bottom:    dw BossRoomframe029 | db BossRoomframelistblock, BossRoomspritedatablock
AltarGraphics15bottom:    dw BossRoomframe031 | db BossRoomframelistblock, BossRoomspritedatablock

AltarGraphics16bottom:    dw BossRoomframe032 | db BossRoomframelistblock, BossRoomspritedatablock

Altar1:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame  
;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)
;v9=FlashScreen Counter
  ld    a,(HugeObjectFrame)
  inc   a
  and   1
  ld    (HugeObjectFrame),a
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  ret   nz

  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  call  .HandlePhase                        ;(0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)

  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=close door, 4=stop restoring background)
  cp    4
  call  nz,restoreBackgroundObject1


;  ld    (ix+enemies_and_objects.v7),1       ;v7=sprite frame


  ;snap to sprite frame
  ld    bc,AltarGraphics00top
  call  SetFrameAltar
  call  PutSF2Object ;CHANGES IX 
  ret

  .HandlePhase:  
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=close door, 4=stop restoring background)
  or    a
  jp    z,DiamondIdle                       ;phase 0
  dec   a
  jp    z,FreezePlayerFlashScreen           ;phase 1
  dec   a
  jp    z,DiamondFadingAway                 ;phase 2
  dec   a
  jp    z,CloseDoor                         ;phase 3
  dec   a
  jp    z,StopRestoringBackground           ;phase 4
  ret

  StopRestoringBackground:
  ld    a,(ix+enemies_and_objects.v9)       ;v9=FlashScreen Counter / var counter
  inc   a
  ld    (ix+enemies_and_objects.v9),a       ;v9=FlashScreen Counter / var counter
  and   3
  ret   nz
  ld    (ix+enemies_and_objects.Alive?),0
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),0  
  ret
  

  CloseDoor:
  ld    a,(Bossframecounter)
  and   1
  ret   nz
    
  ;SetTilesInTileMap:
  ld    hl,MapData + (34 * 12)              ;door starts at (0,12)
  ld    b,7                                 ;door height
  ld    de,34-1                             ;next doortile on next row - screenwidth is 32, but mapwidth is 34
  .loop:
  ld    (hl),1                              ;hard foreground
  inc   hl
  ld    (hl),1                              ;hard foreground
  add   hl,de
  djnz  .loop  
  
  ld    a,(ix+enemies_and_objects.x)        ;slowly close door
  inc   a
  ld    (ix+enemies_and_objects.x),a        ;slowly close door
  cp    16
  ret   nz
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)    
  xor   a
  ld    (freezecontrols?),a  
  ret

  DiamondFadingAway:
  ld    a,(Bossframecounter)
  and   3
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  and   15
  jr    z,.End
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret
  .End:
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)    
  ld    (ix+enemies_and_objects.v7),16      ;v7=sprite frame 
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.x),000  
  ld    (ix+enemies_and_objects.x),000      ;set x door at the left most part of screen (it is now out of screen)
  ld    (ix+enemies_and_objects.y),8*12     ;set y door at the room entrance

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,%0000 0100                        ;turn around player, facing door
	ld		(Controls),a
  ret

  FreezePlayerFlashScreen:
  call  DiamondIdle.animate
  ld    a,1
  ld    (freezecontrols?),a

	ld		hl,DoNothing
	ld		(PlayerSpriteStand),hl
  
  ld    a,15                                ;start write to this palette color (15)
  di
	out		($99),a
	ld		a,16+128  
	out		($99),a

  ld    a,(Bossframecounter)
  and   1
  ld    a,255
  jr    z,.SetColor
  xor   a
  .SetColor:
  out   ($9a),a
  out   ($9a),a
  ei
  or    a
  ret   nz
  dec   (ix+enemies_and_objects.v9)         ;v9=FlashScreen Counter
  ret   nz
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)    

	ld		hl,Jump
	ld		(PlayerSpriteStand),hl
  ret
  
  DiamondIdle:
  call  .animate

  ;distance check
  ld    hl,(Clesx)                          ;hl = x player
  ld    de,92                               ;de = x enemy/object  
  sbc   hl,de
  ret   c
  ld    e,58                                ;de = x enemy/object  
  sbc   hl,de
  ret   nc

  ld    a,(Clesy)                           ;hl = x player
  sub   a,150                               ;a = x enemy/object  
  ret   nc
  ld    a,(Clesy)                           ;hl = x player
  sub   a,050                               ;a = x enemy/object  
  ret   c

  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=turn around player, 4=door closing)  
  ret

  .animate:    
  ld    a,(Bossframecounter)
  and   3
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  and   7
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

SetFrameAltar:
  ld    a,(enemies_and_objects+enemies_and_objects.v7)
  ld    l,a                                 ;v7=sprite frame
  ld    h,0
  add   hl,hl                               ;*2
  add   hl,hl                               ;*4
  add   hl,bc                               ;frame * 4 + frame address

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

Altar2:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  ret   nz

  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  call  restoreBackgroundObject2
  
  ;snap to sprite frame
  ld    bc,AltarGraphics00bottom
  call  SetFrameAltar
  call  PutSF2Object2 ;CHANGES IX 
  jp    switchpageSF2Engine

SetFrameBossDemon:
  ld    a,(enemies_and_objects+enemies_and_objects.v7)
  ld    l,a                                 ;v7=sprite frame
  ld    h,0
  add   hl,hl                               ;*2
  add   hl,hl                               ;*4
  ld    e,l
  ld    d,h
  add   hl,hl                               ;*8
  add   hl,de                               ;*12
  add   hl,bc                               ;frame * 12 + frame address

  SetFrameSF2Object:
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
  
SnapToBossDemon1:
  ld    a,(enemies_and_objects+enemies_and_objects.x)
  ld    (Object1x),a
  ld    a,(enemies_and_objects+enemies_and_objects.y)
  ld    (Object1y),a
  ret

;sprite 0-5
BossDemonIdle00:   dw ryupage1frame000 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle01:   dw ryupage1frame001 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle02:   dw ryupage1frame002 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle03:   dw ryupage1frame003 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle04:   dw ryupage1frame004 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle05:   dw ryupage1frame005 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle06:   dw ryupage1frame006 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle07:   dw ryupage1frame007 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle08:   dw ryupage1frame008 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle09:   dw ryupage1frame009 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle10:   dw ryupage1frame010 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle11:   dw ryupage1frame011 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle12:   dw ryupage1frame012 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle13:   dw ryupage1frame013 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle14:   dw ryupage1frame014 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle15:   dw ryupage1frame015 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle16:   dw ryupage1frame016 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonIdle17:   dw ryupage1frame017 | db BossDemonframelistblock, BossDemonspritedatablock

;sprite 6-15
BossDemonWalk00:   dw ryupage1frame018 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk01:   dw ryupage1frame019 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk02:   dw ryupage1frame020 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk03:   dw ryupage1frame021 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk04:   dw ryupage1frame022 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk05:   dw ryupage1frame023 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk06:   dw ryupage1frame024 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk07:   dw ryupage1frame025 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk08:   dw ryupage1frame026 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk09:   dw ryupage1frame027 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk10:   dw ryupage1frame028 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk11:   dw ryupage1frame029 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk12:   dw ryupage1frame030 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk13:   dw ryupage1frame031 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk14:   dw ryupage1frame032 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk15:   dw ryupage1frame033 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk16:   dw ryupage1frame034 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk17:   dw ryupage1frame035 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk18:   dw ryupage1frame036 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk19:   dw ryupage1frame037 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk20:   dw ryupage1frame038 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk21:   dw ryupage1frame039 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk22:   dw ryupage1frame040 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk23:   dw ryupage1frame041 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk24:   dw ryupage1frame042 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk25:   dw ryupage1frame043 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk26:   dw ryupage1frame044 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk27:   dw ryupage1frame045 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk28:   dw ryupage1frame046 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonWalk29:   dw ryupage1frame047 | db BossDemonframelistblock, BossDemonspritedatablock

;sprite 16-28
BossDemonAttack00:   dw ryupage2frame000 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack01:   dw ryupage2frame001 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack02:   dw ryupage2frame002 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack03:   dw ryupage2frame003 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack04:   dw ryupage2frame004 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack05:   dw ryupage2frame005 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack06:   dw ryupage2frame006 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack07:   dw ryupage2frame007 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack08:   dw ryupage2frame008 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack09:   dw ryupage2frame009 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack10:   dw ryupage2frame010 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack11:   dw ryupage2frame011 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack12:   dw ryupage2frame012 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack13:   dw ryupage2frame013 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack14:   dw ryupage2frame014 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack15:   dw ryupage2frame015 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack16:   dw ryupage2frame016 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack17:   dw ryupage2frame017 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack18:   dw ryupage2frame018 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack19:   dw ryupage2frame019 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack20:   dw ryupage2frame020 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack21:   dw ryupage2frame021 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack22:   dw ryupage2frame022 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack23:   dw ryupage2frame023 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack24:   dw ryupage2frame024 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack25:   dw ryupage2frame025 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack26:   dw ryupage2frame026 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack27:   dw ryupage2frame027 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack28:   dw ryupage2frame028 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack29:   dw ryupage2frame029 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack30:   dw ryupage2frame030 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack31:   dw ryupage2frame031 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack32:   dw ryupage2frame032 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack33:   dw ryupage2frame033 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack34:   dw ryupage2frame034 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack35:   dw ryupage2frame035 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack36:   dw ryupage2frame036 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack37:   dw ryupage2frame037 | db BossDemonframelistblock2, BossDemonspritedatablock2
BossDemonAttack38:   dw ryupage2frame038 | db BossDemonframelistblock2, BossDemonspritedatablock2

;sprite 29-33
BossDemonHit00:   dw ryupage1frame048 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit01:   dw ryupage1frame049 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit02:   dw ryupage1frame050 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit03:   dw ryupage1frame051 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit04:   dw ryupage1frame052 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit05:   dw ryupage1frame053 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit06:   dw ryupage1frame054 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit07:   dw ryupage1frame055 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit08:   dw ryupage1frame056 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit09:   dw ryupage1frame057 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit10:   dw ryupage1frame058 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit11:   dw ryupage1frame059 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit12:   dw ryupage1frame060 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit13:   dw ryupage1frame061 | db BossDemonframelistblock, BossDemonspritedatablock
BossDemonHit14:   dw ryupage1frame062 | db BossDemonframelistblock, BossDemonspritedatablock

;sprite 34-54
BossDemonDead00:   dw ryupage3frame000 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead01:   dw ryupage3frame001 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead02:   dw ryupage3frame002 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead03:   dw ryupage3frame003 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead04:   dw ryupage3frame004 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead05:   dw ryupage3frame005 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead06:   dw ryupage3frame006 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead07:   dw ryupage3frame007 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead08:   dw ryupage3frame008 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead09:   dw ryupage3frame009 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead10:   dw ryupage3frame010 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead11:   dw ryupage3frame011 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead12:   dw ryupage3frame012 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead13:   dw ryupage3frame013 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead14:   dw ryupage3frame014 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead15:   dw ryupage3frame015 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead16:   dw ryupage3frame016 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead17:   dw ryupage3frame017 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead18:   dw ryupage3frame018 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead19:   dw ryupage3frame019 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead20:   dw ryupage3frame020 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead21:   dw ryupage3frame021 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead22:   dw ryupage3frame022 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead23:   dw ryupage3frame023 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead24:   dw ryupage3frame024 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead25:   dw ryupage3frame025 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead26:   dw ryupage3frame026 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead27:   dw ryupage3frame027 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead28:   dw ryupage3frame028 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead29:   dw ryupage3frame029 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead30:   dw ryupage3frame030 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead31:   dw ryupage3frame031 | db BossDemonframelistblock3, BossDemonspritedatablock3
BossDemonDead32:   dw ryupage3frame032 | db BossDemonframelistblock3, BossDemonspritedatablock3

BossDemonDead33:   dw ryupage4frame000 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead34:   dw ryupage4frame001 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead35:   dw ryupage4frame002 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead36:   dw ryupage4frame003 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead37:   dw ryupage4frame004 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead38:   dw ryupage4frame005 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead39:   dw ryupage4frame006 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead40:   dw ryupage4frame007 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead41:   dw ryupage4frame008 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead42:   dw ryupage4frame009 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead43:   dw ryupage4frame010 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead44:   dw ryupage4frame011 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead45:   dw ryupage4frame012 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead46:   dw ryupage4frame013 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead47:   dw ryupage4frame014 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead48:   dw ryupage4frame015 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead49:   dw ryupage4frame016 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead50:   dw ryupage4frame017 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead51:   dw ryupage4frame018 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead52:   dw ryupage4frame019 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead53:   dw ryupage4frame020 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead54:   dw ryupage4frame021 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead55:   dw ryupage4frame022 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead56:   dw ryupage4frame023 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead57:   dw ryupage4frame024 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead58:   dw ryupage4frame025 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead59:   dw ryupage4frame026 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead60:   dw ryupage4frame027 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead61:   dw ryupage4frame028 | db BossDemonframelistblock4, BossDemonspritedatablock4
BossDemonDead62:   dw ryupage4frame029 | db BossDemonframelistblock4, BossDemonspritedatablock4

BossDemonWalkLeftMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    40,0,-2, 128
BossDemonWalkRightMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    40,0,+2, 128

  
BossDemon1:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=move left (-1) or right (0)
  ld    a,(HugeObjectFrame)
  inc   a
  and   3
  ld    (HugeObjectFrame),a
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  ret   nz

;  call  BackdropOrange  
  call  restoreBackgroundObject1

  call  .HandlePhase                        ;(0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)

  ld    bc,BossDemonIdle00
  call  SetFrameBossDemon
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
;  ld    b,(hl)                              ;frame list block
;  inc   hl
;  ld    c,(hl)                              ;sprite data block
;  ret  
  
  
  .HandlePhase:                             ;(0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  or    a
  jp    z,BossDemonIdle
  dec   a
  jp    z,BossDemonWalking
  dec   a
  jp    z,BossDemonAttacking
  dec   a
  jp    z,BossDemonHit
  dec   a
  jp    z,BossDemonDead
    
  BossDemonDead:
  ld    a,(Bossframecounter)
  and   1
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    54                                  ;sprite 34-54 are dead
  jr    z,.LastSprite
  inc   a
  .LastSprite:  
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret
  
  BossDemonHit:
  ld    a,(Bossframecounter)
  and   1
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  cp    34                                  ;sprite 29-33 are hit
  jr    nz,.notzero

  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table      
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ret
  
  .notzero:  
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret
  
  
  BossDemonAttacking:
  call  .CollisionObjectPlayerDemonAttacking
    
  ld    a,(Bossframecounter)
  and   1
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  cp    28                                  ;sprite 16-28 are attacking
  jr    nz,.notzero




;  ld    (ix+enemies_and_objects.v7),16      ;v7=sprite frame
;ret


  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table      
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ret    
  .notzero:  
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

  .CollisionObjectPlayerDemonAttacking:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    24
  jp    nz,CollisionObjectPlayerDemon       ;Check if player is hit by Vram object                            
  ld    a,(ix+enemies_and_objects.x)        ;x
  sub   a,74
  ld    (ix+enemies_and_objects.x),a        ;x
  call  CollisionObjectPlayerDemon          ;Check if player is hit by Vram object                            
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,74
  ld    (ix+enemies_and_objects.x),a        ;x
  ret
  
  BossDemonWalking:
  bit   7,(ix+enemies_and_objects.v9)       ;v9=move left (-1) or right (0)
  ld    de,BossDemonWalkLeftMovementTable
  jr    nz,.GoMove
  ld    de,BossDemonWalkRightMovementTable
  .GoMove:
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit

  call  CollisionObjectPlayerDemon         ;Check if player is hit by Vram object                            
  call  CheckPlayerPunchesEnemyDemon       ;Check if player hit's enemy

  ld    a,(ix+enemies_and_objects.x)        ;x
  cp    116
  jr    nz,.endcheckStartAttacking
  ld    (ix+enemies_and_objects.v7),16      ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v9),0       ;v9=move left (-1) or right (0)
  ret  
  .endcheckStartAttacking:

  cp    8*26 + 2
  jr    nz,.endcheckStartBackToIdle
  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table    
  ld    (ix+enemies_and_objects.v7),00      ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v9),-1      ;v9=move left (-1) or right (0)
  ret  
  .endcheckStartBackToIdle:

  call  BossDemonCheckIfDead                ;call gets popped if dead
  call  BossDemonCheckIfHit                 ;call gets popped if hit

  ld    a,(Bossframecounter)
  and   1
  ret   nz
    
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  cp    16                                  ;sprite 6-15 are walking
  jr    nz,.notzero
  ld    a,6
  .notzero:  
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

  BossDemonIdle:
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
  call  CollisionObjectPlayerDemon         ;Check if player is hit by Vram object                            
  call  CheckPlayerPunchesEnemyDemon       ;Check if player hit's enemy
  
  ld    a,r
  and   31
  jr    nz,.EndCheckStartWalking
  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table    
  ld    (ix+enemies_and_objects.v7),6       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ret
  .EndCheckStartWalking:

  call  BossDemonCheckIfDead                ;call gets popped if dead
  call  BossDemonCheckIfHit                 ;call gets popped if hit

  ;animate
  ld    a,(Bossframecounter)
  and   3
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  cp    6                                   ;sprite 0-5 are idle
  jr    nz,.notzero
  xor   a
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

  BossDemonCheckIfHit:
  ld    a,(ix+enemies_and_objects.hit?)
  or    a
  ret   z
  pop   af                                  ;pop call  
  ld    (ix+enemies_and_objects.hit?),0
  ld    (ix+enemies_and_objects.v7),29      ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ret

  BossDemonCheckIfDead:
  ld    a,(ix+enemies_and_objects.life)
  dec   a
  ret   nz
  pop   af                                  ;pop call
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    a,34
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

BossDemon2:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  ret   nz
;  jp    nz,CheckCollisionObjectPlayer  

  call  SnapToBossDemon1

;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject2
  
  ;snap to sprite frame
  ld    bc,BossDemonIdle00+4
  call  SetFrameBossDemon
  jp    PutSF2Object2 ;CHANGES IX 

BossDemon3:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  ret   nz
;  jp    nz,CheckCollisionObjectPlayer  

  call  SnapToBossDemon1

;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject3

  ;snap to sprite frame
  ld    bc,BossDemonIdle00+8
  call  SetFrameBossDemon
  call  PutSF2Object3 ;CHANGES IX 
  jp    switchpageSF2Engine

KonarkPaletteObject:
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = speed
  inc   a
  and   3
  ld    (ix+enemies_and_objects.v1),a     ;v1 = speed
  ret   nz

  ld    a,(ix+enemies_and_objects.v2)     ;v2 = amount of steps
  inc   a
  and   15
  ld    (ix+enemies_and_objects.v2),a     ;v2 = amount of steps
  
  
  ld    hl,KonarkBrighterPalette1
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette2
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette2
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette3
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette3
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette3
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette2
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette2
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette1
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette1
  jp    z,setpalette

  dec   a
  ld    hl,KonarkBrighterPalette1
  jp    z,setpalette
  
  ld    hl,KonarkPalette
  jp    setpalette

HugeSpiderLegs:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,HugeSpiderSpriteblock             ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
    
  .HandlePhase:
  ld    hl,HugeSpiderAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 12                            ;12 animation frame addresses
  jp    AnimateSprite    

HugeSpiderAnimation:
  dw  HugeSpider1_Char
  dw  HugeSpider2_Char
  dw  HugeSpider3_Char
  dw  HugeSpider4_Char
  dw  HugeSpider5_Char
  dw  HugeSpider6_Char
  dw  HugeSpider7_Char
  dw  HugeSpider8_Char
  dw  HugeSpider9_Char
  dw  HugeSpider10_Char
  dw  HugeSpider11_Char
  dw  HugeSpider12_Char

HugeSpiderBody:
;v1 = sx
;v2=Phase (0=moving)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Explosion Animation Counter
  ld    a,216
  ld    (CopyObject+sy),a  
  ld    a,3
  ld    (CopyObject+sPage),a 

  .HandlePhase:
  ld    d,0
  ld    e,(ix+(1*lenghtenemytable)+enemies_and_objects.v1)
  ld    hl,HugeSpiderBodyOffsets
  add   hl,de                                 ;use v1=Animation Counter of legs to find y+x offsets body

  ld    a,(ix+(1*lenghtenemytable)+enemies_and_objects.y)
  add   a,(hl)
  ld    (ix+enemies_and_objects.y),a          ;check y legs and set body accordingly
  
  ld    a,(ix+(1*lenghtenemytable)+enemies_and_objects.x)
  inc   hl
  add   a,(hl)
  ld    (ix+enemies_and_objects.x),a          ;check x legs and set body accordingly

  ;check if spider died
  ld    a,(ix+(1*lenghtenemytable)+enemies_and_objects.life)
  or    a
  jp    nz,VramObjectsTransparantCopies
  ld    (ix+enemies_and_objects.Alive?),0
  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  
HugeSpiderBodyOffsets:  ;y, x
  db    +01,-16,  +01,-16,  +02,-16,  +03,-17, +02,-18, +01,-17, +01,-16, +01,-16,  +02,-16,  +02,-17,  +02,-18, +01,-17

WorldTextStepTable:  ;repeating steps(128 = end table/repeat), move y, move x
  db  1,-00,+0
  db  1,-17,+0,  1,-14,+0,  1,-11,+0,  1,-08,+0,  1,-05,+0,  1,-04,+0,  1,-03,+0,  1,-02,+0,  1,-01,+0,   127,-00,+0
  db  1,+01,+0,  1,+02,+0,  1,+03,+0,  1,+04,+0,  1,+05,+0,  1,+08,+0,  1,+11,+0,  1,+14,+0,  1,+17,+0,  1,+1,+0,   127,-00,+0
  db  128

WorldTextStepTable2:  ;repeating steps(128 = end table/repeat), move y, move x
  db  1,-1,+0
  db  128

  
TextKarniMata:
  dw AreaSignsframe000 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe001 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe002 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe003 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe004 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe005 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe006 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe007 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe008 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe009 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe010 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe011 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe012 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe013 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe014 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe015 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe016 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe017 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe018 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe019 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe020 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe021 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe022 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe023 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe024 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe025 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe026 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe027 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe028 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe029 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe030 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe031 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe032 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe033 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe034 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe035 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe036 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe037 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe038 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe039 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe040 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe041 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe042 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe043 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe044 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe045 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe046 | db AreaSignsframelistblock, AreaSignsspritedatablock
  dw AreaSignsframe047 | db AreaSignsframelistblock, AreaSignsspritedatablock


AreaSign:                                 ;Displays the name of the world in screen when entering that world
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=put line in all 3 pages
;v7=sprite frame
;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)
;v9=wait timer
  .HandlePhase:  
  ld    a,(ix+enemies_and_objects.v8)     ;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)
  or    a
  jp    z,PutAreaSignLine                 ;0=put a new line for 3 frames
  dec   a
  jp    z,AreaSignwait                    ;1=wait
  dec   a
  jp    z,RemoveAreaSign                  ;2=remote all the lines in all the pages

  RemoveAreaSign:
  ld    a,(framecounter)
  rrca
  ret   c
  
  ld    a,(ix+enemies_and_objects.y)      ;y object  
  ld    (RestoreBackgroundObject1Page0+sY),a
  ld    (RestoreBackgroundObject1Page0+dY),a
  inc   a
  cp    200
  ret   z
  ld    (ix+enemies_and_objects.y),a    ;y object    

  ld    a,36
  ld    (RestoreBackgroundObject1Page0+sX),a
  ld    (RestoreBackgroundObject1Page0+dX),a
  ld    a,200
  ld    (RestoreBackgroundObject1Page0+nX),a
  ld    hl,RestoreBackgroundObject1Page0
  call  DoCopy                            ;restore page 0   
  xor   a
  ld    (screenpage),a                    ;let's use only page 0 for removing sign
  add   a,31
  ld    (PageOnNextVblank),a
  ret

  AreaSignwait:
  dec   (ix+enemies_and_objects.v9)       ;v9=wait timer
  ret   nz
  ld    (ix+enemies_and_objects.v8),2     ;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)   
  ret

  PutAreaSignLine:
  dec   (ix+enemies_and_objects.v6)       ;v6=put line in all 3 pages 
  jr    nz,.EndCheckNextLine
  ld    (ix+enemies_and_objects.v6),3     ;v6=put line in all 3 pages
  inc   (ix+enemies_and_objects.v7)       ;v7=sprite frame
  ld    a,(ix+enemies_and_objects.v7)     ;v7=sprite frame - check for last frame
  cp    48
  jp    nz,.EndCheckNextLine
  ld    (ix+enemies_and_objects.v8),1     ;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages) 
  ret
  .EndCheckNextLine:
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable           ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  ld    bc,TextKarniMata
  call  SetFrameAltar                     ;in: hl->frame. out: b=frame list block, c=sprite data block  
  call  PutSF2Object                      ;in: b=frame list block, c=sprite data block. CHANGES IX 
  call  switchpageSF2Engine  
  ret  

AppBlocksHandler:  
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = activate block timer
  inc   a
  and   63
  ld    (ix+enemies_and_objects.v1),a     ;v1 = activate block timer
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v2)     ;v2 = activate block table step pointer
  add   a,3
  ld    (ix+enemies_and_objects.v2),a     ;v2 = activate block table step pointer
  
  ld    hl,AppearingBlocksTable-3
  ld    d,0
  ld    e,a
  add   hl,de
  
  ld    a,(hl)                            ;dy
  cp    255
  jr    nz,.NotEndTable
  ld    (ix+enemies_and_objects.v2),3     ;v2 = activate block table step pointer
  ld    hl,AppearingBlocksTable
  ld    a,(hl)
  .NotEndTable:
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v2),a
  inc   hl
  ld    a,(hl)                            ;dx
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v3),a
  inc   hl
  ld    a,(hl)
  or    a
  ld    hl,DisappearingBlocks
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v4),240-16  ;sx
  jr    z,.activate
  ld    hl,AppearingBlocks
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v4),128+16  ;sx
  .activate:
  ;activate (Dis)appearing Blocks
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.movementpattern),l
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.movementpattern+1),h
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),1
  ret

AppearingBlocksTable: ;dy, dx, appear(1)/dissapear(0)      255 = end
  db    15*8,18*8,1, 07*8,20*8,0, 15*8,12*8,1, 07*8,26*8,0, 15*8,06*8,1, 15*8,18*8,0, 10*8,09*8,1, 15*8,12*8,0, 10*8,15*8,1, 15*8,06*8,0, 07*8,20*8,1
  db    10*8,09*8,0, 07*8,26*8,1, 10*8,15*8,0
  db    255
  
AppearingBlocks:
;v1 = dPage
;v2 = dy
;v3 = dx
;v4 = sx
  ld    c,1
  ld    a,(ix+enemies_and_objects.v4)     ;v4 = sx  
  cp    176
  call  z,SetTilesInTileMap

  call  .init                             ;initialize variables for block

  ;put block in page 0,1,2+3
  call  .PutBlock
  
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = dPage
  and   7
  ret   nz

  ld    a,(ix+enemies_and_objects.v4)     ;v4 = sx  
  add   a,16
  ld    (ix+enemies_and_objects.v4),a     ;v4 = sx  
  ret   nz  
  ld    (ix+enemies_and_objects.alive?),0 ;end   
  ret
  
  .PutBlock:
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = dPage
  inc   a
  ld    (ix+enemies_and_objects.v1),a     ;v1 = dPage
  and   3
  ld    (CopyObject+dPage),a 
  add   a,a                               ;*2
  add   a,a                               ;*4
  add   a,a                               ;*8
  add   a,a                               ;*16
  ld    b,a

  ld    a,(ix+enemies_and_objects.v3)     ;v3 = dx
  sub   a,b
  ld    (CopyObject+dx),a  

  ;put object
  ld    hl,CopyObject
  jp    docopy

  .init:
  ;initialize variables for block
  ld    a,216
  ld    (CopyObject+sy),a  
  
  ld    a,(ix+enemies_and_objects.v4)     ;v4 = sx  
  ld    (CopyObject+sx),a  

  ld    a,(ix+enemies_and_objects.v2)     ;v2 = dy
  sub   a,4
  ld    (CopyObject+dy),a  
  ld    a,16
  ld    (CopyObject+nx),a
  ld    a,24
  ld    (CopyObject+ny),a 
  ld    a,3
  ld    (CopyObject+sPage),a 
  xor   a
  ld    (CopyObject+copydirection),a
  ld    a,$d0
  ld    (CopyObject+copytype),a
  ret

DisappearingBlocks:
;v1 = dPage
;v2 = dy
;v3 = dx
;v4 = sx
  ld    c,0
  ld    a,(ix+enemies_and_objects.v4)     ;v4 = sx  
  cp    160
  call  z,SetTilesInTileMap

  call  AppearingBlocks.init

  ;put block in page 0,1,2+3
  call  AppearingBlocks.PutBlock
  
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = dPage
  and   7
  ret   nz

  ld    a,(ix+enemies_and_objects.v4)     ;v4 = sx  
  sub   a,16
  ld    (ix+enemies_and_objects.v4),a     ;v4 = sx  
  cp    128 - 16
  ret   nz  
  ld    (ix+enemies_and_objects.alive?),0 ;end   
  ret

  SetTilesInTileMap:
  ;v2 = dy
  ;v3 = dx
  ld    a,(ix+enemies_and_objects.v2)     ;v2 = dy
	srl		a                                 ;/2
	srl		a                                 ;/4
	srl		a                                 ;/8
  ld    b,a
  
  ld    de,40
  ld    hl,0
  
  .loop:
  add   hl,de
  djnz  .loop

  ld    a,(ix+enemies_and_objects.v3)     ;v3 = dx
	srl		a                                 ;/2
	srl		a                                 ;/4
	srl		a                                 ;/8
  ld    e,a
  add   hl,de
  
  ld    de,MapData
  add   hl,de
  ld    (hl),c                            ;hardforeground / hardbackground
  inc   hl
  ld    (hl),c                            ;hardforeground / hardbackground
;  ld    de,39
;  add   hl,de
;  ld    (hl),c                            ;hardforeground / hardbackground
;  inc   hl
;  ld    (hl),c                            ;hardforeground  / hardbackground 
  ret
  
PlayerReflection:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
;  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
;  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,PlayerReflectionSpriteblock        ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
    
  .HandlePhase:
  .SetX:
  ld    hl,(ClesX)
  ld    de,08
  add   hl,de
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h
  
  .SetY:
  ;Player Y = $b7 when standing on the ground
  ld    a,(ClesY)
  cp    $b7 - 16
  jr    nc,.go
  ld    a,$b7 - 20
  .go:
  neg
  add   $7f
  ld    (ix+enemies_and_objects.y),a
  
  .Animate:
  ld    iy,ReflPlayerSpriteData_Char_RightStand
  ld    bc,ReflPlayerSpriteData_Char_LeftStand - ReflPlayerSpriteData_Char_RightStand

  ld    hl,(standchar)
  ld    de,PlayerSpriteData_Char_RightStand
  xor   a
  sbc   hl,de
  jr    z,.SpriteFound
  add   iy,bc
  ld    de,PlayerSpriteData_Char_LeftStand - PlayerSpriteData_Char_RightStand

  ld    a,25
  .loop:
  sbc   hl,de
  jr    z,.SpriteFound
  add   iy,bc
  dec   a
  jr    nz,.loop

  .SpriteFound:
  push  iy
  pop   hl
  ret

CuteMiniBat:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Target Y
;v8=face left (0) or face right (1)  
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,CuteMiniBatSpriteblock            ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
    
  .HandlePhase:
  call  .CheckTurnAround                    ;turn around at the left and right edge of screen
  call  .MoveToTargetY                      ;Move Towards Target Y
  call  .Move
    
  .Animate:
  bit   7,(ix+enemies_and_objects.v8)       ;v8=face left (0) or face right (1)  
  ld    hl,RightCuteMiniBat
  jp    z,.GoAnimate
  ld    hl,LeftCuteMiniBat
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 03                            ;06 animation frame addresses
  jp    AnimateSprite  

  .CheckTurnAround:                         ;turn around at the left and right edge of screen
  ld    a,(ix+enemies_and_objects.x)
  cp    20
  jr    c,.MoveRight
  cp    40
  ret   c
  bit   0,(ix+enemies_and_objects.x+1)
  ret   z
  .MoveLeft:
  ld    (ix+enemies_and_objects.v8),-1      ;v8=face left (0) or face right (1)  
  ret  
  .MoveRight:
  bit   0,(ix+enemies_and_objects.x+1)
  ret   nz
  ld    (ix+enemies_and_objects.v8),1       ;v8=face left (0) or face right (1)  
  ret
  
  .MoveToTargetY:
  ld    a,r
  and   15
  ret   nz
  
  ld    a,(ix+enemies_and_objects.y)
  cp    (ix+enemies_and_objects.v7)         ;v7=Target Y
  jr    nc,.MoveUp
  inc   (ix+enemies_and_objects.y)
  ret
  .MoveUp:
  dec   (ix+enemies_and_objects.y)
  ret

  .Move:
  ld    de,MiniBatMovementTableRight1
  bit   7,(ix+enemies_and_objects.v8)       ;v8=face left (0) or face right (1)  
  jp    z,MoveObjectWithStepTableNew        ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  jp    MoveObjectWithStepTableNewMirroredX ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table

MiniBatMovementTableRight1:                 ;repeating steps(128 = end table/repeat), move y, move x
  db  03,+0,+1,  01,+0,+0,  01,+1,+1,  01,+0,+1,  01,+0,+0
  db  03,+0,+1,  01,-1,+1,  03,+0,+1,  01,+0,+0,  02,-1,+1
  db  03,+1,+1,  01,-1,-0,  02,-1,+1,  01,-0,-0,  02,+1,+1
  db  01,-0,-0,  01,-0,+1,  01,-1,+0,  01,+1,+0,  02,-0,+0,  01,+1,+0
  db  128

LeftCuteMiniBat:
  dw  LeftCuteMiniBat1_Char
  dw  LeftCuteMiniBat2_Char
  dw  LeftCuteMiniBat3_Char

RightCuteMiniBat:
  dw  RightCuteMiniBat1_Char
  dw  RightCuteMiniBat2_Char
  dw  RightCuteMiniBat3_Char

BigStatueMouthOpenSx: equ 0
BigStatueMouthClosedSx: equ 14
BigStatueMouth:
  ld    a,3
  ld    (CopyObject+spage),a
  ld    a,216+21
  ld    (CopyObject+sy),a  

  ld    a,(framecounter)
  cp    60
  jr    nz,.EndCheckCloseMouth
  ld    (ix+enemies_and_objects.v1),BigStatueMouthClosedSx  
  .EndCheckCloseMouth:

  call  VramObjectsTransparantCopies
  call  .CheckOpenMouth
  ret
  
  .CheckOpenMouth:  
  ld    a,(framecounter)
  or    a
  ret   nz
  
  .SearchEmptySlot:
  push  ix
  pop   iy
  ld    de,lenghtenemytable
  
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
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
  ld    (iy+enemies_and_objects.v1),BigStatueMouthOpenSx  
  
  ld    (ix+enemies_and_objects.alive?),-1 

  ld    a,(iy+enemies_and_objects.y)
  sub   a,2
  ld    (ix+enemies_and_objects.y),a

  ld    a,(iy+enemies_and_objects.x)
  add   a,15
  ld    (ix+enemies_and_objects.x),a
  
  ld    (ix+enemies_and_objects.x+1),0
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    hl,CuteMiniBat
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  ld    (ix+enemies_and_objects.nrsprites),72-(02*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),2
  ld    (ix+enemies_and_objects.nrspritesTimes16),2*16
  ld    (ix+enemies_and_objects.life),1
  ret  
  
  
SXDrippingOoze1:  equ 149
SXDrippingOoze2:  equ 149+5
SXDrippingOoze3:  equ 149+5+5
SXDrippingOoze4:  equ 149+5+5+5

DrippingOozeDrop:
;v1=sx
;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
;v3=Vertical Movement
;v4=Grow Duration
;v5=Wait FOr Respawn Counter
;v8=Y spawn
;v9=X spawn
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object

  ld    a,216+32 
  ld    (CopyObject+sy),a  

  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
  or    a
  jp    z,DrippingOozeGrowing
  dec   a
  jp    z,DrippingOozeFalling
  
  DrippingOozeWaitingForRespawn:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Wait FOr Respawn Counter
  inc   a
  ld    (ix+enemies_and_objects.v5),a       ;v5=Wait FOr Respawn Counter
  cp    64
  ret   nz
  ld    (ix+enemies_and_objects.v5),0       ;v5=Wait FOr Respawn Counter

  ld    (ix+enemies_and_objects.v1),SXDrippingOoze1  
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Y spawn  
  ld    (ix+enemies_and_objects.y),a        ;y  

  ld    a,r
  rrca
  ld    a,(ix+enemies_and_objects.v9)       ;v9=X spawn 
  jr    c,.SetX
  add   a,19
  .SetX:
  ld    (ix+enemies_and_objects.x),a        ;x  
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)  
  ld    (ix+enemies_and_objects.v4),0       ;v4=Grow Duration
  ret
  
  DrippingOozeFalling:
  ld    (ix+enemies_and_objects.v1),SXDrippingOoze4
  call  MoveSpriteVertically                ;Add v3 to y
  call  CheckFloorEnemyObject               ;checks for floor, out z=collision found with floor
  jp    nz,VramObjectsTransparantCopies

  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
  ;activate DrippingOoze in the pool
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),-1
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,4
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.x),a      
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,-25
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.y),a  
  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
      
  DrippingOozeGrowing:
  call  VramObjectsTransparantCopies

  ld    a,(ix+enemies_and_objects.v4)       ;v4=Grow Duration
  inc   a
  ld    (ix+enemies_and_objects.v4),a       ;v4=Grow Duration
  cp    50
  ret   c
  ld    (ix+enemies_and_objects.v1),SXDrippingOoze2
  cp    100
  ret   c
  ld    (ix+enemies_and_objects.v1),SXDrippingOoze3
  cp    150
  ret   c
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
  ret
  
DrippingOoze:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 15
  call  c,CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,DrippingOozeSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
    
  .Animate:
  ld    hl,DrippingOozeAnimation
  ld    b,01                                ;animate every x frames (based on framecounter)
  ld    c,2 * 20                            ;06 animation frame addresses
  call  AnimateSprite  

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 19
  ret   nz
  ld    (ix+enemies_and_objects.v1),00      ;v1=Animation Counter
  jp    RemoveSprite
    
DrippingOozeAnimation:
  dw  DrippingOoze1_Char
  dw  DrippingOoze1_Char
  dw  DrippingOoze2_Char
  dw  DrippingOoze3_Char
  dw  DrippingOoze4_Char
  dw  DrippingOoze5_Char
  dw  DrippingOoze6_Char
  dw  DrippingOoze7_Char
  dw  DrippingOoze8_Char
  dw  DrippingOoze9_Char
  dw  DrippingOoze10_Char
  dw  DrippingOoze11_Char
  dw  DrippingOoze12_Char
  dw  DrippingOoze13_Char
  dw  DrippingOoze14_Char
  dw  DrippingOoze15_Char
  dw  DrippingOoze16_Char
  dw  DrippingOoze17_Char
  dw  DrippingOoze18_Char
  dw  DrippingOoze18_Char
  
WaterfallMouth:
  ld    a,216+32 
  ld    (CopyObject+sy),a  
  jp    VramObjectsTransparantCopies

WaterfallEyesYellowClosedSX: equ 67 
WaterfallEyesYellowOpenSX: equ 53 
WaterfallMouthYellowClosedSX: equ 119 
WaterfallMouthYellowOpenSX: equ 109 

WaterfallEyesGreyClosedSX: equ 95 
WaterfallEyesGreyOpenSX: equ 81
WaterfallMouthGreyClosedSX: equ 139 
WaterfallMouthGreyOpenSX: equ 129 

WaterfallEyesGrey:
  ld    b,WaterfallMouthGreyOpenSX
  ld    c,WaterfallMouthGreyClosedSX
  ld    d,WaterfallEyesGreyClosedSX
  ld    e,WaterfallEyesGreyOpenSX
  jp    WaterfallEyesYellow.EntryPointForGreyEyes
  
WaterfallEyesYellow:
;v1=sx
;v2=Active Timer
;v3=Wait Timer
;v4=Amount of Waterfalls
;v5=Last Waterfalls Activated
;v6=Y waterfall 1
;v7=x waterfall 1
;v8=Y waterfall 2
;v9=x waterfall 2
;v10=Y waterfall 3
;v11=x waterfall 3

  ld    b,WaterfallMouthYellowOpenSX
  ld    c,WaterfallMouthYellowClosedSX
  ld    d,WaterfallEyesYellowClosedSX
  ld    e,WaterfallEyesYellowOpenSX
  .EntryPointForGreyEyes:

  call  .OpenEyes
  call  .CheckActivateWaterFall
  
  ld    a,216+32 
  ld    (CopyObject+sy),a  

  jp    VramObjectsTransparantCopies

  .CheckActivateWaterFall:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Active Timer
  or    a
  ret   z
  inc   a
  ld    (ix+enemies_and_objects.v2),a       ;v2=Active Timer
  jr    z,.CloseEyes

  cp    20
  jr    z,.OpenMouth

  cp    40
  ret   nz
  .ActivateWaterFall:
  ld    (ix+(2*lenghtenemytable)+enemies_and_objects.Alive?),-1

  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,19
  ld    (ix+(2*lenghtenemytable)+enemies_and_objects.x),a      
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,13
  ld    (ix+(2*lenghtenemytable)+enemies_and_objects.y),a     
  ret

  .OpenMouth:
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v1),b
  
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,21-19
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.x),a      
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,20-8
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.y),a     
  ret

  .CloseEyes:
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.v1),c

  ld    (ix+enemies_and_objects.v1),d
  ld    (ix+enemies_and_objects.v2),0       ;v2=Active Timer
  ret

  .OpenEyes:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Active Timer
  or    a
  ret   nz                                  ;return if already active. Eyes are open when active
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Wait Timer
  dec   a
;  and   127
  ld    (ix+enemies_and_objects.v3),a       ;v3=Wait Timer
  ret   nz
  ld    (ix+enemies_and_objects.v3),200     ;v3=Wait Timer

  ld    (ix+enemies_and_objects.v1),e
  ld    (ix+enemies_and_objects.v2),1       ;v2=Active Timer

  ld    a,(ix+enemies_and_objects.v5)       ;v5=Last Waterfalls Activated
  inc   a
  cp    (ix+enemies_and_objects.v4)         ;v4=Amount of Waterfalls
  jr    nz,.SetWaterFall
  xor   a
  .SetWaterFall:
  ld    (ix+enemies_and_objects.v5),a       ;v5=Last Waterfalls Activated
  jr    z,.SetWaterFall1
  dec   a
  jr    z,.SetWaterFall2

  .SetWaterFall3:
  ld    a,(ix+enemies_and_objects.v11)      ;x waterfall 3
  ld    (ix+enemies_and_objects.x),a        ;x
  ld    a,(ix+enemies_and_objects.v10)      ;y waterfall 3
  ld    (ix+enemies_and_objects.y),a        ;y  
  ret
  
  .SetWaterFall2:
  ld    a,(ix+enemies_and_objects.v9)       ;x waterfall 2
  ld    (ix+enemies_and_objects.x),a        ;x
  ld    a,(ix+enemies_and_objects.v8)       ;y waterfall 2
  ld    (ix+enemies_and_objects.y),a        ;y
  ret

  .SetWaterFall1:
  ld    a,(ix+enemies_and_objects.v7)       ;x waterfall 1
  ld    (ix+enemies_and_objects.x),a        ;x
  ld    a,(ix+enemies_and_objects.v6)       ;y waterfall 1
  ld    (ix+enemies_and_objects.y),a        ;y
  ret

Waterfall:
;v1=Animation Counter
;v2=Phase (0=Waterfall Start, 1=Waterfalling, 2=Waterfall End)
;v3=
;v4=
;v5=Animation Counter
  call  .HandlePhase                        ;(0=Waterfall Start, 1=Waterfalling, 2=Waterfall End) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,WaterfallSpriteblock              ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
    
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Waterfall Start, 1=Waterfalling, 2=Waterfall End)
  or    a
  jp    z,WaterfallStart
  dec   a
  jp    z,Waterfalling
  
  WaterfallEnd:
  ld    hl,WaterfallEndAnimation
  ld    b,00                                ;animate every x frames (based on framecounter)
  ld    c,2 * 10                            ;06 animation frame addresses
  call  AnimateSprite  
  
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 09
  ret   nz
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=Waterfall Start, 1=Waterfalling, 2=Waterfall End) 
  ld    (ix+enemies_and_objects.v1),-2      ;v1=Animation Counter
  jp    RemoveSprite

  EndWaterFalling:  equ 170
  Waterfalling:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Animation Counter
  inc   a
  ld    (ix+enemies_and_objects.v5),a       ;v5=Animation Counter
  cp    EndWaterFalling
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v1),-2      ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=Waterfall Start, 1=Waterfalling, 2=Waterfall End) 
  ld    (ix+enemies_and_objects.v5),0       ;v5=Animation Counter

  .Animate:
  ld    hl,WaterfallAnimation
  ld    b,00                                ;animate every x frames (based on framecounter)
  ld    c,2 * 08                            ;06 animation frame addresses
  jp    AnimateSprite  
  
  WaterfallStart:
  ld    hl,WaterfallStartAnimation
  ld    b,00                                ;animate every x frames (based on framecounter)
  ld    c,2 * 08                            ;06 animation frame addresses
  call  AnimateSprite  
  
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 07
  ret   nz  
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Waterfall Start, 1=Waterfalling, 2=Waterfall End) 
  ld    (ix+enemies_and_objects.v1),-2      ;v1=Animation Counter
  ret
  
WaterfallEndAnimation:
  dw  WaterfallEnd1_Char
  dw  WaterfallEnd1_Char
  dw  WaterfallEnd2_Char
  dw  WaterfallEnd3_Char
  dw  WaterfallEnd4_Char
  dw  WaterfallEnd5_Char
  dw  WaterfallEnd6_Char
  dw  WaterfallEnd7_Char
  dw  WaterfallEnd8Empty_Char
  dw  WaterfallEnd8Empty_Char

WaterfallStartAnimation:
  dw  WaterfallStart1_Char
  dw  WaterfallStart2_Char
  dw  WaterfallStart3_Char
  dw  WaterfallStart4_Char
  dw  WaterfallStart5_Char
  dw  WaterfallStart6_Char
  dw  WaterfallStart7_Char
  dw  WaterfallStart7_Char
  
WaterfallAnimation:
  dw  Waterfall1_Char
  dw  Waterfall2_Char
  dw  Waterfall3_Char
  dw  Waterfall4_Char
  dw  Waterfall5_Char
  dw  Waterfall6_Char
  dw  Waterfall7_Char
  dw  Waterfall8_Char
  
BlackHoleBaby:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BlackHoleBabySpriteblock          ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping) 
  or    a
  jp    z,BlackHoleBabyWalking
  
  BlackHoleBabyJumping:
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  call  .Gravity
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction / out z=collision found with wall  
  call  .CheckFloor                         ;checks for collision Floor and if found fall
  
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    de,RightBlackHoleBaby4_Char
  ld    hl,RightBlackHoleBaby2_Char
  jp    z,.DirectionFound
  ld    de,LeftBlackHoleBaby4_Char
  ld    hl,LeftBlackHoleBaby2_Char
  .DirectionFound:
  bit   7,(ix+enemies_and_objects.v3)       ;v3=Vertical movement
  ret   z
  ex    de,hl
  ret

  .Gravity:
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Gravity timer
  inc   a
  and   7
  ld    (ix+enemies_and_objects.v6),a       ;v6=Gravity timer
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret

  .CheckFloor:                              ;checks for floor. if not found invert direction
  bit   7,(ix+enemies_and_objects.v3)       ;v3=Vertical movement
  ret   nz
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   z                                   ;return if background tile is found

  ld    (ix+enemies_and_objects.v6),0       ;v6=Gravity timer / reset every time you snap to floor

  ;snap to platform
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping) 
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret
   
  BlackHoleBabyWalking:  
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    nz,.EndMove
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  .EndMove:
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  ld    a,r
  and   15
  jr    nz,.Animate
  ld    a,(ix+enemies_and_objects.x)
  and   %0000 1111
  jr    nz,.Animate
  
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=BlackHoleBaby Walking, 1=BlackHoleBaby Jumping)  
  ld    (ix+enemies_and_objects.v3),-2      ;v3=Vertical Movement
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightBlackHoleBabyWalk
  jp    z,.GoAnimate
  ld    hl,LeftBlackHoleBabyWalk
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite  

LeftBlackHoleBabyWalk:
  dw  LeftBlackHoleBaby1_Char
  dw  LeftBlackHoleBaby2_Char
  dw  LeftBlackHoleBaby3_Char
  dw  LeftBlackHoleBaby4_Char
  dw  LeftBlackHoleBaby5_Char
  dw  LeftBlackHoleBaby6_Char

RightBlackHoleBabyWalk:
  dw  RightBlackHoleBaby1_Char
  dw  RightBlackHoleBaby2_Char
  dw  RightBlackHoleBaby3_Char
  dw  RightBlackHoleBaby4_Char
  dw  RightBlackHoleBaby5_Char
  dw  RightBlackHoleBaby6_Char

BlackHoleAlien:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BlackHoleAlienSpriteblock         ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  call  .Move
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightBlackHoleAlienWalk
  jp    z,.GoAnimate
  ld    hl,LeftBlackHoleAlienWalk
  .GoAnimate:
  ld    b,15                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite  

  .Move:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    z,.EndCheckHit
  ld    a,(framecounter)
  and   03
  jp    z,MoveSpriteHorizontally
  ret

  .EndCheckHit:
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  ret


LeftBlackHoleAlienWalk:
  dw  LeftBlackHoleAlien1_Char
  dw  LeftBlackHoleAlien2_Char
  dw  LeftBlackHoleAlien3_Char
  dw  LeftBlackHoleAlien4_Char
  dw  LeftBlackHoleAlien5_Char
  dw  LeftBlackHoleAlien6_Char

RightBlackHoleAlienWalk:
  dw  RightBlackHoleAlien1_Char
  dw  RightBlackHoleAlien2_Char
  dw  RightBlackHoleAlien3_Char
  dw  RightBlackHoleAlien4_Char
  dw  RightBlackHoleAlien5_Char
  dw  RightBlackHoleAlien6_Char

LancelotSword:
;v1=sx
;v4=Horizontal Movement
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object

  ld    a,(enemies_and_objects+enemies_and_objects.v4)  ;v4=Horizontal Movement
  or    a
  ld    hl,RightLancelotSwordSword
  ld    a,26                                ;sx
  jp    p,.SetVars
  ld    hl,LeftLancelotSwordSword
  xor   a
  .SetVars:
  ld    (ix+enemies_and_objects.v1),a       ;sx

  ld    a,(enemies_and_objects+enemies_and_objects.v1)  ;v1=Animation Counter
  ld    e,a
  ld    d,0
  add   hl,de

  ld    a,216+32
  ld    (CopyObject+sy),a  

  ld    a,(enemies_and_objects+enemies_and_objects.y)
  add   a,(hl)                              ;add to y
  ld    (ix+enemies_and_objects.y),a

  inc   hl
  ld    d,0
  ld    e,(hl)                              ;add to x
  bit   7,e
  jr    z,.EndNegativeCheck
  dec   d
  .EndNegativeCheck:

  ld    a,(enemies_and_objects+enemies_and_objects.x)
  ld    l,a
  ld    a,(enemies_and_objects+enemies_and_objects.x+1)
  ld    h,a
  add   hl,de
  
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h

  ld    a,(enemies_and_objects+enemies_and_objects.life)
  or    a
  jp    nz,VramObjectsTransparantCopies
  ld    (ix+enemies_and_objects.Alive?),0
  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  

LeftLancelotSwordSword:
                        ;add to y, add to x
                        db  19-00  ,   -40-00
                        db  19+02  ,   -40-01
                        db  19+01  ,   -40-02
                        db  19-01  ,   -40-03
                        db  19-01  ,   -40-04
                        db  19+02  ,   -40-03
                        db  19-00  ,   -40-02
                        db  19-01  ,   -40-01

RightLancelotSwordSword:
                        ;add to y, add to x
                        db  19-00  ,   -40-00 + 35
                        db  19+02  ,   -40+01 + 35
                        db  19+01  ,   -40+02 + 35
                        db  19-01  ,   -40+03 + 35
                        db  19-01  ,   -40+04 + 35
                        db  19+02  ,   -40+03 + 35
                        db  19-00  ,   -40+02 + 35
                        db  19-01  ,   -40+01 + 35

Lancelot:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Shield hit timer
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy

  bit   1,(ix+enemies_and_objects.v5)       ;v5=Shield hit timer  
	ld		a,LancelotSpriteblock               ;set block at $a000, page 2 - block containing sprite data
  jr    z,.SetSpriteBlock
	ld		a,LancelotShieldHitSpriteblock      ;set block at $a000, page 2 - block containing sprite data
  .SetSpriteBlock:
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  call  .CheckFacingPlayer                  ;if lancelot faces player, lancelot can die. Otherwise not.
  call  .CheckAbleToBeHit                   ;after shield has been hit, Shield Hit Timer is on. in that period you can't hit lancelot
  call  .CheckIfShieldHasBeenHit            ;check if shield has been hit, if so set Shield Hit Timer
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightLancelot
  jp    z,.GoAnimate
  ld    hl,LeftLancelot
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 08                            ;06 animation frame addresses
  jp    AnimateSprite  

  .CheckFacingPlayer:                       ;if lancelot faces player, lancelot can die. Otherwise not.
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ld    (ix+enemies_and_objects.life),1     ;able to kill Lancelot
  ret   c
  ld    (ix+enemies_and_objects.life),255   ;unable to kill Lancelot
  ret

  .CheckIfShieldHasBeenHit:                 ;check if shield has been hit, if so set Shield Hit Timer
  ld    a,(ix+enemies_and_objects.hit?)
  ld    (ix+enemies_and_objects.hit?),0     ;reset hit, so Lancelot doesn't blink white when hit from behind
  or    a
  ret   z
  ld    (ix+enemies_and_objects.v5),40      ;v5=Shield hit timer
  ret

  .CheckAbleToBeHit:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Shield hit timer
  dec   a
  jp    z,CheckPlayerPunchesEnemy           ;Check if player hit's enemy
  ld    (ix+enemies_and_objects.v5),a       ;v5=Shield hit timer
  ret

LeftLancelot:
  dw  LeftLancelot1_Char
  dw  LeftLancelot2_Char
  dw  LeftLancelot3_Char
  dw  LeftLancelot4_Char
  dw  LeftLancelot5_Char
  dw  LeftLancelot6_Char
  dw  LeftLancelot7_Char
  dw  LeftLancelot8_Char

RightLancelot:
  dw  RightLancelot1_Char
  dw  RightLancelot2_Char
  dw  RightLancelot3_Char
  dw  RightLancelot4_Char
  dw  RightLancelot5_Char
  dw  RightLancelot6_Char
  dw  RightLancelot7_Char
  dw  RightLancelot8_Char

TrampolineBlob:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Unable to be hit duration
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Unable to be hit duration
  dec   a
  jr    z,.AbleToHitAgain
  ld    (ix+enemies_and_objects.v5),a       ;v5=Unable to be hit duration
  jr    .EndCheckPlayerPunchesEnemy
  .AbleToHitAgain:  
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  .EndCheckPlayerPunchesEnemy:

  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
	ld		a,TrampolineBlobSpriteblock         ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping) 
  or    a
  jp    z,TrampolineBlobMoving
  
  TrampolineBlobJumping:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	call  .CheckHit
	
	ld		a,(JumpSpeed)
	or    a
	jp    p,.Animate
	ld		a,(Controls)
  or    %0000 0001
	ld		(Controls),a
	
  .Animate:
  ld    hl,TrampolineBlobJumpAnimation
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 10                            ;10 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 09
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping)  
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ret   nz
  ld    (ix+enemies_and_objects.v1),2* 03   ;v1=Animation Counter. This makes it so blob also moves in between jumps when going left
  ret

  .CheckHit:
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit-4
  ret   nz
  ld    (ix+enemies_and_objects.hit?),0
  ld    (ix+enemies_and_objects.life),255   ;unable to kill Trampoline Blob
  ret

  TrampolineBlobMoving:  
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
  call  .Move
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  call  .CheckHit                           ;if Blob is hit, cancel blinking white, and invert direction
  call  .CheckPlayerJumpsOnTrampoline       ;if player jumps on trampoline player is launched in the air, and blob changed to Phase 1
  
  .Animate:
  ld    hl,TrampolineBlobMoveAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 08                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckPlayerJumpsOnTrampoline:            ;if player jumps on trampoline player is launched in the air, and blob changed to Phase 1
  ld    b,16                                ;b-> x distance
  ld    c,14                                ;c-> y distance
  call  distancecheck24wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc

	ld		hl,(PlayerSpriteStand)
	ld    de,Jump
  xor   a
  sbc   hl,de
  ret   nz

  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping)  

  call  Set_jump
;	ld    a,(StartingJumpSpeed)
;	sub   a,2  
  ld    a,-7
	ld		(JumpSpeed),a
	
	ld		a,(Controls)                        ;up pressed
  or    %0000 0001
	ld		(Controls),a	
  ret

  .CheckHit:
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit-4
  ret   nz
  ld    (ix+enemies_and_objects.hit?),0
  ld    (ix+enemies_and_objects.life),255   ;unable to kill Trampoline Blob
  ld    (ix+enemies_and_objects.v5),40      ;v5=Unable to be hit duration

  ld    a,(PlayerFacingRight?)
  or    a
  jr    z,.PlayerFacesLeft

  .PlayerFacesRight:
  ld    (ix+enemies_and_objects.v4),+1      ;v4=Horizontal Movement
  ld    (ix+enemies_and_objects.v1),2* 03   ;v1=Animation Counter. This makes it so blob also moves in between jumps when going left
  ret

  .PlayerFacesLeft:
  ld    (ix+enemies_and_objects.v4),-1      ;v4=Horizontal Movement  
  ld    (ix+enemies_and_objects.v1),0* 03   ;v1=Animation Counter
  ret
  
  .Move:
  ld    a,(framecounter)
  and   1
  ret   z

  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  jr    z,.MovingRight

  .MovingLeft:    
  cp    2 * 01
  jp    z,MoveSpriteHorizontally
  cp    2 * 02
  jp    z,MoveSpriteHorizontally
  cp    2 * 03
  jp    z,MoveSpriteHorizontally
  cp    2 * 04
  jp    z,MoveSpriteHorizontally
  ret
  
  .MovingRight:
  cp    2 * 04
  jp    z,MoveSpriteHorizontally
  cp    2 * 05
  jp    z,MoveSpriteHorizontally
  cp    2 * 06
  jp    z,MoveSpriteHorizontally
  cp    2 * 07
  jp    z,MoveSpriteHorizontally
  ret

TrampolineBlobMoveAnimation:
  dw  TrampolineBlob1_Char
  dw  TrampolineBlob2_Char
  dw  TrampolineBlob3_Char
  dw  TrampolineBlob4_Char
  dw  TrampolineBlob5_Char
  dw  TrampolineBlob6_Char
  dw  TrampolineBlob7_Char
  dw  TrampolineBlob8_Char
  
TrampolineBlobJumpAnimation:
  dw  TrampolineBlobJump1_Char
  dw  TrampolineBlobJump1_Char
  dw  TrampolineBlobJump2_Char
  dw  TrampolineBlobJump3_Char
;  dw  TrampolineBlobJump4_Char
  dw  TrampolineBlobJump5_Char
  dw  TrampolineBlobJump6_Char
  dw  TrampolineBlobJump3_Char  
;  dw  TrampolineBlobJump7_Char
  dw  TrampolineBlobJump8_Char
  dw  TrampolineBlobJump9_Char
  dw  TrampolineBlobJump9_Char
  
SxSnowball: equ 241
Snowball:
;v1=sx
;v2=Phase (0=Snowball Moving, 1=Snowball Splashing) 
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Explosion Animation Counter
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Snowball Moving, 1=Snowball Splashing) 
  or    a
  jp    z,SnowballMoving

  SnowballSplashing:
  ld    a,216
  ld    (CopyObject+sy),a  
  call  .Animate                            ;out hl -> sprite character data to out to Vram

  ld    hl,SxDemontjeBulletTable
  ld    d,0
  ld    e,(ix+enemies_and_objects.v5)       ;v5=Explosion Animation Counter
  add   hl,de
  
  ld    a,(hl)                              ;sx
  ld    (ix+enemies_and_objects.v1),a       ;sx
  inc   hl  
  ld    a,(hl)                              ;nx + ny
  ld    (ix+enemies_and_objects.nx),a       ;nx  
  ld    (ix+enemies_and_objects.ny),a       ;ny  
  jp    VramObjectsTransparantCopies

  .Animate:
  ld    a,(framecounter)
  and   7
  ret   nz
  call  .MoveObject1PixelRightAndDown
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Explosion Animation Counter
  add   a,2
  ld    (ix+enemies_and_objects.v5),a       ;v5=Explosion Animation Counter
  cp    2 * 4
  ret   nz

  pop   af                                  ;pop the call and remove bullet
  ld    (ix+enemies_and_objects.alive?),0  
  ld    (ix+enemies_and_objects.v5),0       ;v5=Explosion Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=bullet, 1=explosion) 
  ld    (ix+enemies_and_objects.nx),15      ;nx  
  ld    (ix+enemies_and_objects.ny),04      ;ny  
  ld    (ix+enemies_and_objects.v1),SxSnowball
  jp    VramObjectsTransparantCopiesRemoveAndClearBuffer

  .MoveObject1PixelRightAndDown:
  inc   (ix+enemies_and_objects.y)          ;y
  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  inc   hl
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h
  ret
  
  SnowballMoving:
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
;  call  .Gravity
;  call  .CheckCollisionForeground
  call  MoveSpriteHorizontally              ;Add v4 to x (16 bit)

  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    a,216+04
  jr    z,.SetSY
  ld    a,216
  .SetSY:
  ld    (CopyObject+sy),a
  call  VramObjectsTransparantCopies

  .CheckCollisionForeground:
  call  CheckFloorEnemyObject               ;checks for floor, out z=collision found with floor
  ret   nz
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Snowball Moving, 1=Snowball Splashing) 
  ld    a,(ix+enemies_and_objects.y) 
  sub   a,4
  ld    (ix+enemies_and_objects.y),a 
  ret
  
SnowballThrower:
;v1=Animation Counter
;v2=Phase (0=Walking, 1=Throwing)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,SnowballThrowerSpriteblock        ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Walking, 1=Throwing)  
  or    a
  jp    z,SnowballThrowerWalking

  SnowballThrowerThrowing:  

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightSnowbalThrowerAttack
  jp    z,.GoAnimate
  ld    hl,LeftSnowbalThrowerAttack
  .GoAnimate:
  ld    b,15                                ;animate every x frames (based on framecounter)
  ld    c,2 * 08                            ;06 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 03
  jr    z,.ThrowSnowBallOne
  cp    2 * 06
  jr    z,.ThrowSnowBallTwo
  cp    2 * 07
  ret   nz

  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=Walking, 1=Throwing)  
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  .ThrowSnowBallOne:
  ld    a,(framecounter)
  and   15
  ret   nz

  push  hl                                  ;hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.Alive?+(lenghtenemytable*1)),1
  ld    a,(ix+enemies_and_objects.y)
  add   a,13+4
  ld    (ix+enemies_and_objects.y+(lenghtenemytable*1)),a

  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  ld    de,-14
  add   hl,de
  ld    (ix+enemies_and_objects.x+(lenghtenemytable*1)),l
  ld    (ix+enemies_and_objects.x+1+(lenghtenemytable*1)),h
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  add   a,a                                 ;*2
  ld    (ix+enemies_and_objects.v4+(lenghtenemytable*1)),a
  pop   hl                                  ;hl -> sprite character data to out to Vram
  ret

  .ThrowSnowBallTwo:
  ld    a,(framecounter)
  and   15
  ret   nz

  push  hl                                  ;hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.Alive?+(lenghtenemytable*2)),1
  ld    a,(ix+enemies_and_objects.y)
  add   a,19+2
  ld    (ix+enemies_and_objects.y+(lenghtenemytable*2)),a

  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  ld    de,-14
  add   hl,de
  ld    (ix+enemies_and_objects.x+(lenghtenemytable*2)),l
  ld    (ix+enemies_and_objects.x+1+(lenghtenemytable*2)),h
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  add   a,a                                 ;*2
  ld    (ix+enemies_and_objects.v4+(lenghtenemytable*2)),a
  pop   hl                                  ;hl -> sprite character data to out to Vram
  ret

  SnowballThrowerWalking:
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  call  .CheckThrow

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightSnowbalThrowerWalk
  jp    z,.GoAnimate
  ld    hl,LeftSnowbalThrowerWalk
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckThrow:
  ld    a,(ix+enemies_and_objects.x)
  cp    120
  jr    nc,.EndCheckSmallerThan120
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ret   nz                                  ;dont throw when x<120 and looking left
  .EndCheckSmallerThan120:

  ld    a,(ix+enemies_and_objects.x)
  cp    200
  jr    c,.EndCheckBiggerThan200
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ret   z                                   ;dont throw when x>200 and looking right
  .EndCheckBiggerThan200:

  ld    a,r
  and   31
  ret   nz
  
  bit   0,(ix+enemies_and_objects.Alive?+(lenghtenemytable*1))
  ret   nz
  bit   0,(ix+enemies_and_objects.Alive?+(lenghtenemytable*2))
  ret   nz

  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Walking, 1=Throwing)  
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret
  
LeftSnowbalThrowerAttack:
  dw  LeftSnowballThrowerAttack1_Char
  dw  LeftSnowballThrowerAttack2_Char
  dw  LeftSnowballThrowerAttack3_Char
  dw  LeftSnowballThrowerAttack4_Char
  dw  LeftSnowballThrowerAttack5_Char
  dw  LeftSnowballThrowerAttack6_Char
  dw  LeftSnowballThrowerAttack7_Char
  dw  LeftSnowballThrowerAttack7_Char

RightSnowbalThrowerAttack:
  dw  RightSnowballThrowerAttack1_Char
  dw  RightSnowballThrowerAttack2_Char
  dw  RightSnowballThrowerAttack3_Char
  dw  RightSnowballThrowerAttack4_Char
  dw  RightSnowballThrowerAttack5_Char
  dw  RightSnowballThrowerAttack6_Char
  dw  RightSnowballThrowerAttack7_Char
  dw  RightSnowballThrowerAttack7_Char

LeftSnowbalThrowerWalk:
  dw  LeftSnowballThrower1_Char
  dw  LeftSnowballThrower2_Char
  dw  LeftSnowballThrower3_Char
  dw  LeftSnowballThrower4_Char
  dw  LeftSnowballThrower5_Char
  dw  LeftSnowballThrower6_Char

RightSnowbalThrowerWalk:
  dw  RightSnowballThrower1_Char
  dw  RightSnowballThrower2_Char
  dw  RightSnowballThrower3_Char
  dw  RightSnowballThrower4_Char
  dw  RightSnowballThrower5_Char
  dw  RightSnowballThrower6_Char




YellowWasp:
;v1=Animation Counter
;v2=Phase (0=Hovering Towards player, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=attack duration
;v8=face left (0) or face right (1) 
  call  .HandlePhase                        ;(0=Hovering Towards player, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,YellowWaspSpriteblock             ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Hanging, 1=Attacking)  
  or    a
  jp    z,YellowWaspHoveringTowardsPlayer

  YellowWaspAttacking:
  call  WaspFlyingInPlace.faceplayerSkipRandomness ;v8=face left (0) or face right (1)  
  ld    de,WaspMovementTable
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  call  .Animate

  ld    a,(ix+enemies_and_objects.v7)       ;v7=attack duration
  inc   a
  and   63
  ld    (ix+enemies_and_objects.v7),a       ;v7=attack duration
  ret   nz
  ld    (ix+enemies_and_objects.v2),+0      ;v2=Phase (0=Hovering Towards player, 1=attacking)
  ret

  .Animate:
  bit   0,(ix+enemies_and_objects.v8)       ;v8=face left (0) or face right (1)  
  ld    hl,RightYellowWasp
  jp    z,.GoAnimate
  ld    hl,LeftYellowWasp
  .GoAnimate:
  ld    b,0                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram
  
  YellowWaspHoveringTowardsPlayer:
  call  .HoverTowardsPlayer
  call  WaspFlyingInPlace.faceplayerSkipRandomness ;v8=face left (0) or face right (1)  
  call  .CheckAttack
  jp    YellowWaspAttacking.Animate         ;out hl -> sprite character data to out to Vram

  .CheckAttack:
  ld    a,r
;  or    a
  and   31
  ret   nz
  ld    (ix+enemies_and_objects.v2),+1      ;v2=Phase (0=Hovering Towards player, 1=attacking)
  ret

  .HoverTowardsPlayer:
  ld    a,(framecounter)
  rrca
  jr    c,.HoverHorizontallyTowardsPlayer

  .HoverVerticallyTowardsPlayer:
  ;Protect Wasp from flying out of screen top
  ld    a,(ix+enemies_and_objects.y)  
  cp    18
  jr    nc,.EndCheckLowerThan18
  ld    (ix+enemies_and_objects.y),18  
  .EndCheckLowerThan18:
  ;/Protect Wasp from flying out of screen top

  ld    a,r
  and   3
  ld    (ix+enemies_and_objects.v3),+1      ;v3=Vertical Movement
  jp    z,MoveSpriteVertically
  dec   a
  ld    (ix+enemies_and_objects.v3),-1      ;v3=Vertical Movement
  jp    z,MoveSpriteVertically
    
  ld    a,(ClesY)
  sub   a,60
  ld    (ix+enemies_and_objects.v3),-1      ;v3=Vertical Movement
  jp    c,MoveSpriteVertically
  sub   a,(ix+enemies_and_objects.y)  
  jp    c,MoveSpriteVertically
  ld    (ix+enemies_and_objects.v3),+1      ;v3=Vertical Movement
  jp    MoveSpriteVertically
  
  .HoverHorizontallyTowardsPlayer:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    de,40 + 6
  jr    nz,.Go
  ld    de,-30
  .Go:

  ld    a,r
  and   3
  ld    (ix+enemies_and_objects.v4),+1      ;v3=Vertical Movement
  jp    z,MoveSpriteHorizontally
  dec   a
  ld    (ix+enemies_and_objects.v4),-1      ;v3=Vertical Movement
  jp    z,MoveSpriteHorizontally

  ld    hl,(Clesx)                          ;hl = x player  
  add   hl,de
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de                              
  ld    (ix+enemies_and_objects.v4),+1      ;v4=Horizontal Movement
  jp    nc,MoveSpriteHorizontally
  ld    (ix+enemies_and_objects.v4),-1      ;v4=Horizontal Movement
  jp    MoveSpriteHorizontally

  .Faceplayer:
  ld    hl,(Clesx)                          ;hl = x player  
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de                               ;make sure wasp always faces player
  ld    (ix+enemies_and_objects.v4),+1      ;v4=Horizontal Movement
  ret   nc
  ld    (ix+enemies_and_objects.v4),-1      ;v4=Horizontal Movement
  ret

LeftYellowWasp:
  dw  LeftYellowWasp1_Char
  dw  LeftYellowWasp2_Char
  dw  LeftYellowWasp3_Char
  dw  LeftYellowWasp4_Char
;  dw  LeftYellowWasp5_Char
;  dw  LeftYellowWasp6_Char
;  dw  LeftYellowWasp7_Char
;  dw  LeftYellowWasp8_Char

RightYellowWasp:
  dw  RightYellowWasp1_Char
  dw  RightYellowWasp2_Char
  dw  RightYellowWasp3_Char
  dw  RightYellowWasp4_Char
;  dw  RightYellowWasp5_Char
;  dw  RightYellowWasp6_Char
;  dw  RightYellowWasp7_Char
;  dw  RightYellowWasp8_Char
  
  
SensorTentacles:
;v1=Animation Counter
;v2=Phase (0=Hanging, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Gravity timer
;v8=Starting Y
;v9=wait until attack timer 
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,SensorTentaclesSpriteblock        ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Hanging, 1=Attacking)  
  or    a
  jp    z,SensorTentaclesHanging
  
  SensorTentaclesAttacking:
  call  MoveSpriteVertically
  call  .CheckBacktoPhase0
  call  .Gravity
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  or    a
  ld    hl,SensorTentaclesAttack1_Char
  ret   p
  ld    hl,SensorTentaclesAttack2_Char
  ret

  .CheckBacktoPhase0:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Starting Y
  cp    (ix+enemies_and_objects.y)          ;y
  ret   c
  ld    (ix+enemies_and_objects.y),a        ;y
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=Hanging, 1=Attacking)  
  ld    (ix+enemies_and_objects.v5),0       ;v5=repeating steps
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to movement table 
  ld    (ix+enemies_and_objects.v7),0       ;v7=Gravity timer
  ret

  .Gravity:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=Gravity timer
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;v7=Gravity timer
  cp    11
  ret   nz
  ld    (ix+enemies_and_objects.v7),0       ;v7=Gravity timer
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  dec   a
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret  
   
  SensorTentaclesHanging:  
  ld    de,SensorTentaclesMovementTable
  ld    a,(framecounter)
  and   3
  call  z,MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  call  .DistanceCheck

  .Animate:
  ld    hl,SensorTentaclesAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

.DistanceCheck:
  ld    b,60                                ;b-> x distance
  ld    c,180                               ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc 

  ld    a,(ix+enemies_and_objects.v9)       ;v9=wait until attack timer 
  dec   a
  and   63
  ld    (ix+enemies_and_objects.v9),a       ;v9=wait until attack timer 
  ret   nz

  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Hanging, 1=Attacking)  

  bit   0,(ix+enemies_and_objects.v8)       ;v8=Starting Y
  ld    (ix+enemies_and_objects.v3),3       ;v3=Vertical Movement
  ret   z
  ld    (ix+enemies_and_objects.v3),4       ;v3=Vertical Movement
  ret
  
SensorTentaclesMovementTable:  ;repeating steps(128 = end table/repeat), move y, move x
  db  01,-0,-0,  01,-1,-0,  02,+0,-0,  01,+1,-0,  01,+0,-0 
  db  01,-0,-0,  01,+1,-0,  02,+0,-0,  01,-1,-0,  01,+0,-0 
  db  128
  
SensorTentaclesAnimation:
  dw  SensorTentacles1_Char
  dw  SensorTentacles5_Char
  dw  SensorTentacles2_Char
  dw  SensorTentacles3_Char
  dw  SensorTentacles4_Char
  dw  SensorTentacles5_Char

GlassBall1:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable1
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject1
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object ;CHANGES IX   
  ret
  
GlassBall2:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable1
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject2
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object2 ;CHANGES IX   
  ret

GlassBall3:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable2
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject1
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object ;CHANGES IX     
  ret
  
GlassBall4:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable3
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject2
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object2 ;CHANGES IX   
  ret

GlassBall5:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable4
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject1
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object  ;CHANGES IX    
  ret
  
GlassBall6:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v6)         ;v6=active on which frame ?  
  jp    nz,CheckCollisionObjectPlayer
  ld    de,GlassBallMovementTable2
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject2
  call  AnimateGlassBall
  call  RemoveGlassBallWhenOutOfScreen
  call  PutSF2Object2 ;CHANGES IX   
  ret

RemoveGlassBallWhenOutOfScreen:
  ld    a,(ix+enemies_and_objects.x)
  cp    250
  ret   c
  ld    hl,EmptyFrame
  call  AnimateGlassBall.GoAnimate
  ld    a,(ix+enemies_and_objects.x)
  cp    252
  ret   c
  ld    (ix+enemies_and_objects.Alive?),0

  ld    (ix+enemies_and_objects.y),8*03
  ld    (ix+enemies_and_objects.x),8*31
  ld    (ix+enemies_and_objects.v1),0
  ld    (ix+enemies_and_objects.v2),0
  ld    (ix+enemies_and_objects.v3),0
  ld    (ix+enemies_and_objects.v4),0
  ld    (ix+enemies_and_objects.v5),0
  ret

GlassBallActivator:
;v1=Activation Timer
  call  .ActivateGlassBall

  ld    a,(HugeObjectFrame)
  inc   a
  and   1
  ld    (HugeObjectFrame),a

  call  z,switchpageSF2Engine  
  ret

  .ActivateGlassBall:
  ld    a,(ix+enemies_and_objects.v1)
  dec   a
  ld    (ix+enemies_and_objects.v1),a
  ret   nz
;  ld    (ix+enemies_and_objects.v1),255
  
  xor   a
  ld    hl,enemies_and_objects
  cp    (hl)
  jr    z,.EmptySlotFound
  ld    hl,enemies_and_objects+lenghtenemytable
  cp    (hl)
  ret   nz

  .EmptySlotFound:
  ld    (hl),2
  ret

AnimateGlassBall:
  ld    hl,GlassBalHorizontalAnimation
  ld    a,(ix+enemies_and_objects.x)        ;x
  and   %0000 1110
  ld    b,a
  srl   a
  add   a,b                                 ;animation step * 3
  ld    d,0
  ld    e,a
  add   hl,de
  
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %0000 1000
  jr    nz,.GoAnimate
  ld    de,4 * 3
  add   hl,de
  .GoAnimate:
  
  ld    a,(hl)
  ld    (Player1Frame),a
  inc   hl
  ld    a,(hl)
  ld    (Player1Frame+1),a
  inc   hl
  ld    a,(hl)
  ld    (Player1Frame+2),a
  ret

EmptyFrame:
  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock

GlassBalHorizontalAnimation:
  dw ryupage0frame004 | db 1
  dw ryupage0frame011 | db 1
  dw ryupage0frame010 | db 1
  dw ryupage0frame009 | db 1
  dw ryupage0frame008 | db 1
  dw ryupage0frame007 | db 1
  dw ryupage0frame006 | db 1
  dw ryupage0frame005 | db 1
;4 extra for when  y is 16 fold
  dw ryupage0frame004 | db 1
  dw ryupage0frame011 | db 1
  dw ryupage0frame010 | db 1
  dw ryupage0frame009 | db 1

LeftAndRightObjectMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    20,0,1, 20,0,-1, 128
  
NonMovingObjectMovementTable:
  db    127,0,0, 128

GlassBallMovementTable1:  ;repeating steps(128 = end table/repeat), move y, move x
  db  115,+0,-2, 015,+8,-0, 124,+0,+2
  db  128

GlassBallMovementTable2:  ;repeating steps(128 = end table/repeat), move y, move x
  db  32,+0,+2, 032,+0,-2
  db  128

GlassBallMovementTable3:  ;repeating steps(128 = end table/repeat), move y, move x
  db  32,+0,-2, 032,+0,+2
  db  128

GlassBallMovementTable4:  ;repeating steps(128 = end table/repeat), move y, move x
  db  115,+0,-2, 016,+8,-0, 088,+0,+2, 088,+0,-2, 088,+0,+2, 088,+0,-2, 088,+0,+2, 088,+0,-2, 088,+0,+2, 088,+0,-2, 088,+0,+2, 088,+0,-2, 088,+0,+2, 088,+0,-2, 124,+0,+2
  db  128


HugeBlob:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Jump to Which platform ? (1,2 or 3)
;v6=Gravity timer
;v7=Dont Check Land Platform First x Frames
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  bit   1,(ix+enemies_and_objects.hit?)         ;check if enemy is hit ? If so, out white sprite
	ld		a,HugeBlobWhiteSpriteblock          ;set block at $a000, page 2 - block containing sprite data
  ret   nz
	ld		a,HugeBlobSpriteblock               ;set block at $a000, page 2 - block containing sprite data
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=Jumping)  
  or    a
  jp    z,HugeBlobWalking
  
  HugeBlobJumping:
  call  MoveSpriteVertically
  call  .Gravity
  call  .CheckLandOnPlatform

  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  or    a
  ld    (ix+enemies_and_objects.v1),4 * 02  ;v1=Animation Counter
  ld    hl,HugeBlob5_Char
  ret   m
  ld    (ix+enemies_and_objects.v1),5 * 02  ;v1=Animation Counter
  ld    hl,HugeBlob6_Char
  ret

  .CheckLandOnPlatform:  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=Dont Check Land Platform First x Frames
  dec   a
  jr    z,.ReadyToCheck
  ld    (ix+enemies_and_objects.v7),a       ;v7=Dont Check Land Platform First x Frames
  ret
  .ReadyToCheck:

  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  or    a
  ret   m
  
  call  .CheckFloor                         ;checks for floor. if found switch to walking phase
  ret
  
  .CheckFloor:                              ;checks for floor. if not found invert direction
  call  CheckFloorEnemyObjectLeftSide       ;checks for floor, out z=collision found with floor
  jr    z,.ForegroundFound
  inc   hl
  inc   hl
  ld    a,(hl)                              ;we check a tile, but also 2 tiles to the right of that tile
  dec   a                                   ;1 = wall  
  ret   nz

  .ForegroundFound:                         ;both tiles are foreground so lets snap and continue walking
  ;snap to platform
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=Jumping)
  ld    a,30
  ld    (ShakeScreen?),a 
  call  .DamagePlayerIfNotJumping
  ret    

  .DamagePlayerIfNotJumping:
	ld		hl,Jump
	ld		de,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  ret   z
  jp    CollisionEnemyPlayer.PlayerIsHit

  .Gravity:
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Gravity timer
  inc   a
  and   3
  ld    (ix+enemies_and_objects.v6),a       ;v6=Gravity timer
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret

  HugeBlobWalking:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    z,.EndCheckHit
  ld    a,(framecounter)
  and   03
  call  z,MoveSpriteHorizontally
  jp    .endMove
  .EndCheckHit:

  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  .endMove:

  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckJump
  call  .SetPlayerSpriteToSpr12
  
  .Animate:
  ld    hl,HugeBlobAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 07                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckJump:
  ;distance check: we only check if player is with x range
;  ld    b,60                                ;b-> x distance
;  ld    c,100                               ;c-> y distance
;  call  distancecheck46wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
;  ret   nc 
  ;we are now within x distance of HugeBlob

  ld    a,(framecounter)                    ;jump every 128 frames
  and   127
  ret   nz
  
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=Jumping)  
  ld    (ix+enemies_and_objects.v7),28      ;v7=Dont Check Land Platform First x Frames

  ;check which platform HugeBlob is on 
  ld    a,(ix+enemies_and_objects.y)        ;y
  cp    8*19
  jr    z,.HugeBlobIsOnPlatform3
  cp    8*11
  jr    z,.HugeBlobIsOnPlatform2
  cp    8*03

  .HugeBlobIsOnPlatform1:
  ld    (ix+enemies_and_objects.v3),-2      ;v3=Vertical Movement
  ret
  
  .HugeBlobIsOnPlatform2:
  ld    a,r
  rrca
  ld    (ix+enemies_and_objects.v3),-6      ;v3=Vertical Movement
  ret   c
  ld    (ix+enemies_and_objects.v3),-2      ;v3=Vertical Movement
  ret
  
  .HugeBlobIsOnPlatform3:
  ld    (ix+enemies_and_objects.v3),-6      ;v3=Vertical Movement
  ret
  
  .SetPlayerSpriteToSpr12:
  ;set player sprites to spritenumber 12 for char and color address
  ld    a,$7b-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddress),a
  ld    a,$75-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddress),a
  ld    a,$73-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddressMirror),a
  ld    a,$6d-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddressMirror),a
  ;set player sprites to spritenumber 28 for spatposition
  ld    hl,spat+(12 * 2)
  ld    (Apply32bitShift.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerLeftSideOfScreen.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerRightSideOfScreen.SelfmodyfyingSpataddressPlayer),hl    
  ret
  
HugeBlobAnimation:
  dw  HugeBlob1_Char
  dw  HugeBlob2_Char
  dw  HugeBlob3_Char
  dw  HugeBlob4_Char
  dw  HugeBlob5_Char
  dw  HugeBlob6_Char
  dw  HugeBlob7_Char

HugeBlobSWsprite:
  ld    a,3
  ld    (CopyObject+spage),a

  ld    a,(enemies_and_objects+enemies_and_objects.v1)  ;v1=Animation Counter
  or    a
  ld    hl,HugeBlobSwSprite1
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite2
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite3
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite4
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite5
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite6
  jr    z,.SetCoordinates
  sub   2
  ld    hl,HugeBlobSwSprite7
  .SetCoordinates:
  ld    a,(hl)                              ;sx
  ld    (ix+enemies_and_objects.v1),a
  inc   hl
  ld    a,(hl)                              ;nx
  ld    (ix+enemies_and_objects.nx),a
  inc   hl
  ld    a,(hl)                              ;ny
  ld    (ix+enemies_and_objects.ny),a

  ld    a,(enemies_and_objects+enemies_and_objects.y)

  inc   hl
  add   a,(hl)                              ;add to y
  ld    (ix+enemies_and_objects.y),a

  inc   hl
  ld    d,0
  ld    e,(hl)                              ;add to x

  ld    a,(enemies_and_objects+enemies_and_objects.x)
  ld    l,a
  ld    a,(enemies_and_objects+enemies_and_objects.x+1)
  ld    h,a
  add   hl,de

  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h
  
  ld    a,(enemies_and_objects+enemies_and_objects.life)
  or    a
  jp    nz,VramObjectsTransparantCopies
  ld    (ix+enemies_and_objects.Alive?),0
  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
                        ;sx,nx,ny,  add to y, add to x
HugeBlobSwSprite1:  db  000,14,21,    33-5  ,   15
HugeBlobSwSprite2:  db  014,16,19,    33-3  ,   15
HugeBlobSwSprite3:  db  030,16,16,    33    ,   15
HugeBlobSwSprite4:  db  046,08,32,    33-16 ,   15+6
HugeBlobSwSprite5:  db  054,06,32,    33-16 ,   15+8
HugeBlobSwSprite6:  db  060,05,32,    33-16 ,   15+6
HugeBlobSwSprite7:  db  065,08,32,    33-16 ,   15+2

                            ;Sx  ,sy,   ,ny ,addtoY
SxOctopussyBulletTable: 
                        db  154  ,216   ,06,  -2
                        db  154  ,216+6 ,07,  -1
                        db  170  ,216   ,05,  +2
                        db  170  ,216+5 ,04,  +1
OctopussyBullet:                            ;forced on object positions 1-4
;v1=sx
;v2=Phase (0=Moving, 1=Splashing) 
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=reference to movement table (0, 8, 16, 24, 32, 40, 48, 56)
;v8=Explosion Animation Counter
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Moving, 1=Splashing)  
  or    a
  jp    z,BulletMoving
  
  BulletSplashing:
  call  .Animate                            ;out hl -> sprite character data to out to Vram

  ld    hl,SxOctopussyBulletTable
  ld    d,0
  ld    e,(ix+enemies_and_objects.v8)       ;v8=Explosion Animation Counter
  add   hl,de
  
  ld    a,(hl)                              ;sx
  ld    (ix+enemies_and_objects.v1),a       ;sx
  inc   hl  
  ld    a,(hl)                              ;sy
  ld    (CopyObject+sy),a    
  inc   hl  
  ld    a,(hl)                              ;ny
  ld    (ix+enemies_and_objects.ny),a       ;ny  
  ld    (ix+enemies_and_objects.nx),16      ;nx  
  inc   hl  

  ld    a,(framecounter)
  and   7
  jp    nz,VramObjectsTransparantCopies

  ld    a,(hl)                              ;add to Y
  add   a,(ix+enemies_and_objects.y)
  ld    (ix+enemies_and_objects.y),a
  jp    VramObjectsTransparantCopies

  .Animate:
  ld    a,(framecounter)
  and   7
  ret   nz

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Explosion Animation Counter
  add   a,4
  ld    (ix+enemies_and_objects.v8),a       ;v8=Explosion Animation Counter
  cp    4 * 4
  ret   nz

  pop   af                                  ;pop the call and remove bullet
  ld    (ix+enemies_and_objects.alive?),0  
  ld    (ix+enemies_and_objects.v8),0       ;v8=Explosion Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=Moving, 1=Splashing) 
  ld    (ix+enemies_and_objects.nx),08      ;nx  
  ld    (ix+enemies_and_objects.ny),08      ;ny    
  ld    (ix+enemies_and_objects.v1),146
  jp    VramObjectsTransparantCopiesRemoveAndClearBuffer


  BulletMoving:  
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object / out h=128 if hit
  ld    a,h
  cp    128
  jp    z,.Playerwashit

  ld    h,0
  ld    l,(ix+enemies_and_objects.v7)       ;v7=reference to movement table (0, 8, 16, 24, 32, 40, 48, 56)
  ld    de,OctopussyBulletMovementTable1
  add   hl,de
  ex    de,hl
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table

  ld    a,216
  ld    (CopyObject+sy),a  
  call  VramObjectsTransparantCopies        ;put object in Vram/screen ;
  call  CheckFloorEnemyObject               ;checks for floor, out z=collision found with floor
  ret   nz
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Moving, 1=Splashing)  

  inc   (ix+enemies_and_objects.y) 
  inc   (ix+enemies_and_objects.y)    
  ld    a,(ix+enemies_and_objects.x)
  sub   a,4
  ld    (ix+enemies_and_objects.x),a
  ret

  .Playerwashit:
  call  VramObjectsTransparantCopiesRemoveAndClearBuffer  ;Clear buffer, so that next time the CleanOb is called buffer is empty
  ld    (ix+enemies_and_objects.Alive?),0
  ld    a,1                                   ;Octopussy Bullet Slow Down Handler v1 = player got hit by bullet
  ld    (lenghtenemytable*4+enemies_and_objects+enemies_and_objects.v1),a
  ret

NormalRunningTable:
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
;SlowRunningTable1:
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
SlowRunningTable1:
  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
SlowRunningTable2:
  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
SlowRunningTable3:
  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1

;RunningTable1
;StartingJumpSpeed:        db -5 ;equ -5    ;initial starting jump take off speed
;StartingJumpSpeedWhenHit: db -4 ;equ -5    ;initial starting jump take off speed
OP_SlowDownHandler:                         ;forced on object position 5
;v1 = player got hit by bullet
;v2 = reference to running table
;v3 = timer to go back to normal running speed again
  ld    a,(ix+enemies_and_objects.v2)
  or    a
  call  nz,.PlayerIsAffectedBySlowdown

  bit   0,(ix+enemies_and_objects.v1)       ;v1 = player got hit by bullet
  ret   z
;at this point player got hit by a bullet. We change to a slower movement table for player and lower player's starting jump speed
  res   0,(ix+enemies_and_objects.v1)       ;reset v1 = player got hit by bullet
  ld    (ix+enemies_and_objects.v3),180     ;reset v3 = timer to enable stacking

  ld    a,(ix+enemies_and_objects.v2)
  inc   a
  cp    4
  jr    nc,.SetRunningTable
  ld    (ix+enemies_and_objects.v2),a
  .SetRunningTable:
  ld    a,(ix+enemies_and_objects.v2)
  or    a
  ld    hl,NormalRunningTable
  ld    b,-5                                ;starting jump speed
  jr    z,.TableFound
  dec   a
  ld    hl,SlowRunningTable1
  ld    b,-4                                ;starting jump speed
  jr    z,.TableFound
  dec   a
  ld    hl,SlowRunningTable2
  ld    b,-3                                ;starting jump speed
  jr    z,.TableFound
  dec   a
  ld    hl,SlowRunningTable3
  ld    b,-3                                ;starting jump speed
;  jr    z,.TableFound
;  ld    hl,SlowRunningTable4
  .TableFound:
  
  ld    a,b
  ld    (StartingJumpSpeed),a
  inc   a
  ld    (StartingJumpSpeedWhenHit),a
  
  ld    de,RunningTable1
  ld    bc,RunningTableLenght
  ldir
  ret

.PlayerIsAffectedBySlowdown:
  dec   (ix+enemies_and_objects.v3)         ;v3 = timer to go back to normal running speed again
  ret   nz
  ld    (ix+enemies_and_objects.v3),180     ;reset v3 = timer
  dec   (ix+enemies_and_objects.v2)         ;v2 = reference to running table
  jp    .SetRunningTable


OctopussyBulletMovementTable1:  ;repeating steps(128 = end table/repeat), move y, move x
  db  03,+1,-1,  03,+1,-1 
  db  128 ,255
OctopussyBulletMovementTable2:  ;repeating steps(128 = end table/repeat), move y, move x
  db  02,+1,-1,  01,+1,-0
  db  128 ,255
OctopussyBulletMovementTable3:  ;repeating steps(128 = end table/repeat), move y, move x
  db  01,+1,-1,  02,+1,-0
  db  128 ,255
OctopussyBulletMovementTable4:  ;repeating steps(128 = end table/repeat), move y, move x
  db  01,+1,-1,  03,+1,-0
  db  128 ,255
OctopussyBulletMovementTable5:  ;repeating steps(128 = end table/repeat), move y, move x
  db  01,+1,+1,  03,+1,+0
  db  128 ,255
OctopussyBulletMovementTable6:  ;repeating steps(128 = end table/repeat), move y, move x
  db  01,+1,+1,  02,+1,+0
  db  128 ,255
OctopussyBulletMovementTable7:  ;repeating steps(128 = end table/repeat), move y, move x
  db  02,+1,+1,  01,+1,+0
  db  128 ,255
OctopussyBulletMovementTable8:  ;repeating steps(128 = end table/repeat), move y, move x
  db  03,+1,+1
  db  128 ,255

Octopussy:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack phase duration
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,OctopussySpriteblock              ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=Floating in air, 1=Shooting)  
  or    a
  jp    z,OctopussyFloatingInAir
  
  OctopussyShooting:
  dec   (ix+enemies_and_objects.v5)         ;v5=Attack phase duration
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=Floating in air, 1=Shooting)  
  ld    (ix+enemies_and_objects.v6),20      ;v6 wait until shooting again
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightOctopussyAttack_Char
  ret   z
  ld    hl,LeftOctopussyAttack_Char
  ret
  
  
  OctopussyFloatingInAir:
  call  .Faceplayer
  call  .DistanceCheck                      ;out: carry->object within distance
  jr    c,.Near

  .AnimateFar:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightOctopussyAnimation
  jp    z,.GoAnimate
  ld    hl,LeftOctopussyAnimation
  jp    .GoAnimate

  .Near:                                    ;Player is near, so shoot bullets every x frames

  ld    a,r                                 ;shoot at random
  and   1
  jr    z,.OctoMayShoot


;  ld    a,(ix+enemies_and_objects.v6)       ;v6 wait until shooting again
;  dec   a
;  jr    z,.OctoMayShoot
;  ld    (ix+enemies_and_objects.v6),a       ;v6 wait until shooting again
  jp    .Animate
  
  .OctoMayShoot:
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04
  jr    nz,.Animate

;this could be used if we have 2 octo's in screen and one is 1 tile higher than the other. If we have only 1 octo, remove this code so he shoots faster
  ld    a,(framecounter)
  and   7
  jr    nz,.Animate
;this could be used if we have 2 octo's in screen and one is 1 tile higher than the other. If we have only 1 octo, remove this code so he shoots faster

  push  ix
  call  .CreateBullet                       ;out zero=bullet is shot
  pop   ix
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=Floating in air, 1=Shooting)  
  ld    (ix+enemies_and_objects.v5),16      ;v5=Attack phase duration
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightOctopussyEyesOpenAnimation
  jp    z,.GoAnimate
  ld    hl,LeftOctopussyEyesOpenAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CreateBullet:
;  ld    a,r
;  and   1
;  ret   nz

  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    de,-10                              ;x spwanpoint of bullet depends on which direction Octopussy is facing
  jp    p,.Set
  ld    de,-16                              ;x spwanpoint of bullet depends on which direction Octopussy is facing
  .Set:
  
  ld    a,(ix+enemies_and_objects.y)
  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)

  add   hl,de

  ld    ix,enemies_and_objects
  ld    de,lenghtenemytable
  
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
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
  ld    (ix+enemies_and_objects.Alive?),1

  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h

  add   a,8
  ld    (ix+enemies_and_objects.y),a
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=splashing on floor)  
  ld    (ix+enemies_and_objects.v5),0       ;v5=repeating steps 
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to movement table

  ld    a,r
  and   %0011 1000                          ;8 fold 
  ld    (ix+enemies_and_objects.v7),a       ;v7=reference to movement table (0, 8, 16, 24, 32, 40, 48, 56)
  xor   a                                   ;set zero flag
  ret  

  .DistanceCheck:
  ld    b,60                                ;b-> x distance
  ld    c,110                               ;c-> y distance
  jp    distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  
  .Faceplayer:
  ld    a,r
  and   31
  ret   nz
  ld    hl,(Clesx)                          ;hl = x player  
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de                               ;make sure wasp always faces player
  ld    (ix+enemies_and_objects.v4),+1      ;v4=Horizontal Movement
  ret   nc
  ld    (ix+enemies_and_objects.v4),-1      ;v4=Horizontal Movement
  ret

LeftOctopussyAnimation:
  dw  LeftOctopussy1_Char
  dw  LeftOctopussy2_Char
  dw  LeftOctopussy3_Char
  dw  LeftOctopussy4_Char
  dw  LeftOctopussy5_Char
  dw  LeftOctopussy6_Char
  
RightOctopussyAnimation:
  dw  RightOctopussy1_Char
  dw  RightOctopussy2_Char
  dw  RightOctopussy3_Char
  dw  RightOctopussy4_Char
  dw  RightOctopussy5_Char
  dw  RightOctopussy6_Char
  
LeftOctopussyEyesOpenAnimation:
  dw  LeftOctopussyEyesOpen1_Char
  dw  LeftOctopussyEyesOpen2_Char
  dw  LeftOctopussyEyesOpen3_Char
  dw  LeftOctopussyEyesOpen4_Char
  dw  LeftOctopussyEyesOpen5_Char
  dw  LeftOctopussyEyesOpen6_Char
  
RightOctopussyEyesOpenAnimation:
  dw  RightOctopussyEyesOpen1_Char
  dw  RightOctopussyEyesOpen2_Char
  dw  RightOctopussyEyesOpen3_Char
  dw  RightOctopussyEyesOpen4_Char
  dw  RightOctopussyEyesOpen5_Char
  dw  RightOctopussyEyesOpen6_Char


Scorpion:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Rattle timer / Wait before Rattle again Timer
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,ScorpionSpriteblock               ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=rattletail, 2=attacking) 
  or    a
  jp    z,ScorpionWalking
  dec   a
  jp    z,ScorpionRattlingTail
  dec   a
  jp    z,ScorpionAttacking

  ScorpionAttackingPart2:
  dec   (ix+enemies_and_objects.v5)
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=rattletail, 2=attacking, 3=attacking part 2) 
  ld    (ix+enemies_and_objects.v5),80      ;v5=Rattle timer

  ld    hl,LeftScorpionWalk1_Char
  ld    a,(ix+enemies_and_objects.x)
  add   a,15
  ld    (ix+enemies_and_objects.x),a

  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement

  ret   nz
  ld    hl,RightScorpionWalk1_Char
  ld    a,(ix+enemies_and_objects.x)
  sub   a,15+15
  ld    (ix+enemies_and_objects.x),a
  ret

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LeftScorpionAttack2_Char
  ret   nz
  ld    hl,RightScorpionAttack2_Char
  ret

  ScorpionAttacking:
  dec   (ix+enemies_and_objects.v5)
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=walking, 1=rattletail, 2=attacking, 3=attacking part 2) 
  ld    (ix+enemies_and_objects.v5),10      ;v5=Rattle timer

  ld    hl,LeftScorpionAttack2_Char
  ld    a,(ix+enemies_and_objects.x)
  sub   a,15
  ld    (ix+enemies_and_objects.x),a

  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement

  ret   nz
  ld    hl,RightScorpionAttack2_Char
  ld    a,(ix+enemies_and_objects.x)
  add   a,15+15
  ld    (ix+enemies_and_objects.x),a
  ret

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LeftScorpionAttack1_Char
  ret   nz
  ld    hl,RightScorpionAttack1_Char
  ret
  
  ScorpionRattlingTail:
  dec   (ix+enemies_and_objects.v5)
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=walking, 1=rattletail, 2=attacking) 
  ld    (ix+enemies_and_objects.v5),06      ;v5=Rattle timer

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,ScorpionRightRattleAnimation
  jp    z,.GoAnimate
  ld    hl,ScorpionLeftRattleAnimation
  .GoAnimate:
  ld    b,1                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ScorpionWalking:
  ld    a,(framecounter)
  and   1
  call  nz,MoveSpriteHorizontally           ;if not hit, move 3 out of 4 frames
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  call  .CheckAttack
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,ScorpionRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,ScorpionLeftWalkAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckAttack:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Rattle timer
  dec   a
  jr    z,.go
  ld    (ix+enemies_and_objects.v5),a       ;v5=Rattle timer
  ret
  
  .go:
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc

  ld    b,28                                ;b-> x distance
  ld    c,40                                ;c-> y distance
  call  distancecheck24wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc
;
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=rattletail, 2=attacking) 
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v5),40      ;v5=Rattle timer
  ret

  .CheckFloor:                              ;checks for floor. if not found invert direction
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   nz                                  ;return if background tile is NOT found
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret  

ScorpionLeftAttackAnimation:
  dw  LeftScorpionAttack1_Char
  dw  LeftScorpionAttack2_Char
  dw  LeftScorpionAttack2_Char
  
ScorpionRightAttackAnimation:
  dw  RightScorpionAttack1_Char
  dw  RightScorpionAttack2_Char
  dw  RightScorpionAttack2_Char

ScorpionLeftRattleAnimation:
  dw  LeftScorpionWalk1_Char
  dw  LeftScorpionRattle2_Char
  dw  LeftScorpionRattle3_Char
  dw  LeftScorpionRattle2_Char
  
ScorpionRightRattleAnimation:
  dw  RightScorpionWalk1_Char
  dw  RightScorpionRattle2_Char
  dw  RightScorpionRattle3_Char
  dw  RightScorpionRattle2_Char

ScorpionLeftWalkAnimation:
  dw  LeftScorpionWalk1_Char
  dw  LeftScorpionWalk2_Char
  dw  LeftScorpionWalk3_Char
  dw  LeftScorpionWalk4_Char
  
ScorpionRightWalkAnimation:
  dw  RightScorpionWalk1_Char
  dw  RightScorpionWalk2_Char
  dw  RightScorpionWalk3_Char
  dw  RightScorpionWalk4_Char
  
Hunchback:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
;v6=Gravity timer
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,HunchbackSpriteblock              ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping) 
  or    a
  jp    z,HunchbackStandingStill
  dec   a
  jp    z,HunchbackWaiting
  dec   a
  jp    z,HunchbackInitiateJump

  HunchbackJumping:
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  call  .Gravity
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction / out z=collision found with wall  
  call  .CheckFloor                         ;checks for collision Floor and if found fall
  
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    de,RightHunchback7_Char
  ld    hl,RightHunchback8_Char
  jp    z,.DirectionFound
  ld    de,LeftHunchback7_Char
  ld    hl,LeftHunchback8_Char
  .DirectionFound:
  bit   7,(ix+enemies_and_objects.v3)       ;v3=Vertical movement
  ret   z
  ex    de,hl
  ret

  .Gravity:
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Gravity timer
  inc   a
  and   7
  ld    (ix+enemies_and_objects.v6),a       ;v6=Gravity timer
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret

  .CheckFloor:                              ;checks for floor. if not found invert direction
  bit   7,(ix+enemies_and_objects.v3)       ;v3=Vertical movement
  ret   nz
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   z                                   ;return if background tile is found

  ld    (ix+enemies_and_objects.v6),0       ;v6=Gravity timer / reset every time you snap to floor

  ;snap to platform
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %1111 1000
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping)  
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   c
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

  HunchbackInitiateJump:
  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 02
  jp    nz,.Animate
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping)  
  ld    (ix+enemies_and_objects.v3),-3      ;v3=Vertical Movement

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightHunchbackJumpingAnimation
  jp    z,.GoAnimate
  ld    hl,LeftHunchbackJumpingAnimation
  .GoAnimate:
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 03                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  HunchbackWaiting:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightHunchback4_Char
  jp    z,.DirectionFound
  ld    hl,LeftHunchback4_Char
  .DirectionFound:

  dec   (ix+enemies_and_objects.v5)         ;v5=Wait timer
  ret   nz
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping)  
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  HunchbackStandingStill:
  ld    a,r
  and   63
  jp    nz,.Animate

  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping) 
  ld    (ix+enemies_and_objects.v5),40      ;v5=Wait timer
    
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightHunchbackStandingAnimation
  jp    z,.GoAnimate
  ld    hl,LeftHunchbackStandingAnimation
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;03 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

LeftHunchbackJumpingAnimation:
  dw  LeftHunchback4_Char
  dw  LeftHunchback5_Char
  dw  LeftHunchback6_Char

RightHunchbackJumpingAnimation:
  dw  RightHunchback4_Char
  dw  RightHunchback5_Char
  dw  RightHunchback6_Char

LeftHunchbackStandingAnimation:
  dw  LeftHunchback1_Char
  dw  LeftHunchback2_Char
  dw  LeftHunchback3_Char
  dw  LeftHunchback2_Char
  
RightHunchbackStandingAnimation:
  dw  RightHunchback1_Char
  dw  RightHunchback2_Char
  dw  RightHunchback3_Char
  dw  RightHunchback2_Char

SxDemontjeBullet1: equ 193
SxDemontjeBullet2: equ 193+11
SxDemontjeBullet3: equ 193+11+11
SxDemontjeBullet4: equ 193+11+11+11
SxDemontjeBullet5: equ 193+11+11+11+7
SxDemontjeBullet6: equ 193+11+11+11+7+5

                            ;Sx               ,nx + ny
SxDemontjeBulletTable:  db  SxDemontjeBullet3 ,11
                        db  SxDemontjeBullet4 ,07
                        db  SxDemontjeBullet5 ,05
                        db  SxDemontjeBullet6 ,03

DemontjeBullet:
;v1 = sx
;v2=Phase (0=moving)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Explosion Animation Counter
  ld    a,216
  ld    (CopyObject+sy),a  

  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=bullet, 1=explosion) 
  or    a
  jp    z,DemontjeBulletMoving

  DemontjeBulletExploding:
  call  .Animate                            ;out hl -> sprite character data to out to Vram

  ld    hl,SxDemontjeBulletTable
  ld    d,0
  ld    e,(ix+enemies_and_objects.v5)       ;v5=Explosion Animation Counter
  add   hl,de
  
  ld    a,(hl)                              ;sx
  ld    (ix+enemies_and_objects.v1),a       ;sx
  inc   hl  
  ld    a,(hl)                              ;nx + ny
  ld    (ix+enemies_and_objects.nx),a       ;nx  
  ld    (ix+enemies_and_objects.ny),a       ;ny  
  jp    VramObjectsTransparantCopies

  .Animate:
  ld    a,(framecounter)
  and   7
  ret   nz
  call  .MoveObject1PixelRightAndDown
  ld    a,(ix+enemies_and_objects.v5)       ;v5=Explosion Animation Counter
  add   a,2
  ld    (ix+enemies_and_objects.v5),a       ;v5=Explosion Animation Counter
  cp    2 * 4
  ret   nz

  pop   af                                  ;pop the call and remove bullet
  ld    (ix+enemies_and_objects.alive?),0  
  ld    (ix+enemies_and_objects.v5),0       ;v5=Explosion Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=bullet, 1=explosion) 
  ld    (ix+enemies_and_objects.nx),11      ;nx  
  ld    (ix+enemies_and_objects.ny),11      ;ny  
  ld    (ix+enemies_and_objects.v1),SxDemontjeBullet1
  jp    VramObjectsTransparantCopiesRemoveAndClearBuffer

  .MoveObject1PixelRightAndDown:
  inc   (ix+enemies_and_objects.y)          ;y
  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  inc   hl
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h
  ret
  
  DemontjeBulletMoving:
  call  .Animate                            ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),a       ;sx
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  .Gravity
  call  .CheckCollisionForeground
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  jp    VramObjectsTransparantCopies

  .Animate:
  ld    a,(framecounter)
  and   15
  sub   8
  ld    a,SxDemontjeBullet1
  ret   c
  ld    a,SxDemontjeBullet2
  ret

  .CheckCollisionForeground:
  call  CheckFloorEnemyObject               ;checks for floor, out z=collision found with floor
  ret   nz
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=bullet, 1=explosion) 
  ret
  
  jp    nz,VramObjectsTransparantCopies
  call  VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  ld    (ix+enemies_and_objects.alive?),0  
  ret

  .Gravity:
  ld    a,(framecounter)
  and   15
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret

Demontje:
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy

  ld    a,(ix+enemies_and_objects.v7)       ;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  or    a
	ld		b,DemontjeGreenSpriteblock          ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
  dec   a
	ld		b,DemontjeRedSpriteblock            ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
  dec   a
	ld		b,DemontjeBrownSpriteblock          ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
	ld		b,DemontjeGreySpriteblock           ;set block at $a000, page 2 - block containing sprite data
  .BlockSet:
  ld    a,b

  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=hanging in air, 1=attacking)
  or    a
  jp    z,DemontjeHangingInAir

  DemontjeAttacking:
  dec   (ix+enemies_and_objects.v5)         ;v5=Attack Timer
  jr    nz,.Animate
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=hanging in air, 1=attacking)  

  .Animate:
  ld    e,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  bit   7,e
  ld    hl,RightDemontjeBrown4_Char
  ret   z
  ld    hl,LeftDemontjeBrown4_Char
  ret

  DemontjeHangingInAir:
  call  .DistanceCheck                      ;If player is near and if facing player and if bullet is free, then attack

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,DemontjeRightAnimation
  jp    z,.GoAnimate
  ld    hl,DemontjeLeftAnimation
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 03                            ;03 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .DistanceCheck:                           ;If player is near and if facing player and if bullet is free, then attack
  ld    a,r
  and   15
  ret   nz
  
  ld    b,80                                ;b-> x distance
  ld    c,80                                ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc

  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc

  ld    a,(enemies_and_objects+enemies_and_objects.Alive?)
  or    a
  ret   nz

  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=hanging in air, 1=attacking)
  ld    (ix+enemies_and_objects.v5),50      ;v5=Attack Timer

  ld    a,1
  ld    (enemies_and_objects+enemies_and_objects.Alive?),a

  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  ld    de,-16
  add   hl,de
  ld    a,l
  ld    (enemies_and_objects+enemies_and_objects.x),a
  ld    a,h
  ld    (enemies_and_objects+enemies_and_objects.x+1),a

  ld    a,(ix+enemies_and_objects.y)
  add   a,6
  ld    (enemies_and_objects+enemies_and_objects.y),a

  ld    a,-1                                ;v3=Vertical Movement
  ld    (enemies_and_objects+enemies_and_objects.v3),a
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    (enemies_and_objects+enemies_and_objects.v4),a          
  ret  
  
DemontjeLeftAnimation:
  dw  LeftDemontjeBrown1_Char
  dw  LeftDemontjeBrown2_Char
  dw  LeftDemontjeBrown3_Char

DemontjeRightAnimation:
  dw  RightDemontjeBrown1_Char
  dw  RightDemontjeBrown2_Char
  dw  RightDemontjeBrown3_Char











BatSpawner:
;v1=Y spawnpoint
;v2=max Y to add to Y spawnpoint
;v3=Previous Y spawn
;v4=wait timer
  dec   (ix+enemies_and_objects.v4)         ;v4=wait timer
  ret   nz
  ld    (ix+enemies_and_objects.v4),100     ;v4=wait timer

  ld    a,(ix+enemies_and_objects.v1)       ;v1=pointer to Y spawnpoint table
  inc   a
  and   15
  ld    (ix+enemies_and_objects.v1),a       ;v1=pointer to Y spawnpoint table

  .SearchEmptySlot:
  ld    de,lenghtenemytable
  
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  ret   nz
  
  .EmptySlotFound:
  ld    d,0
  ld    e,a
  ld    hl,.SpawnpointTable
  add   hl,de
  ld    a,(hl)
  ld    (ix+enemies_and_objects.y),a  
  ld    (ix+enemies_and_objects.alive?),-1 
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    hl,Bat
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  ld    (ix+enemies_and_objects.nrsprites),72-(08*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),8
  ld    (ix+enemies_and_objects.nrspritesTimes16),8*16
  ld    (ix+enemies_and_objects.life),1
  
  ld    hl,(ClesX)
  ld    de,304/2
  sbc   hl,de               ;take x Cles and subtract the x camera  
  jr    c,.PlayerIsLeftSideOfMap

  .PlayerIsLRightSideOfMap:
  ld    (ix+enemies_and_objects.x),000
  ld    (ix+enemies_and_objects.x+1),0
;  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase ( )
  ld    (ix+enemies_and_objects.v4),2       ;v4=Horizontal Movement
  ret  
  
  .PlayerIsLeftSideOfMap:
  ld    (ix+enemies_and_objects.x),060
  ld    (ix+enemies_and_objects.x+1),1
;  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
;  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase ( )
  ld    (ix+enemies_and_objects.v4),-2      ;v4=Horizontal Movement
  ret

.SpawnpointTable:
  db    008,090,150,040, 100,166,020,120
  db    060,110,140,080, 030,160,050,130
  
Bat:
;v1=Animation Counter
;v2=
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BatSpriteblock                    ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  call  .Move  
  call  CheckOutOfMap

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,BatRightAnimation
  jp    z,.GoAnimate
  ld    hl,BatLeftAnimation
  .GoAnimate:
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .Move:
  call  MoveSpriteHorizontally
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  push  af
  ld    (ix+enemies_and_objects.v4),0       ;v4=Horizontal Movement
  ld    de,BatMovementTable
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  pop   af
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

BatMovementTable:  ;repeating steps(128 = end table/repeat), move y, move x
  db  05,-1,-0,  01,-0,-0,  02,-1,-0,  01,-0,-0,  01,-1,-0,  02,-0,-0
  db  01,+1,-0,  01,-0,-0,  02,+1,-0,  01,-0,-0,  05,+1,-0,  02,-0,-0
  db  02,+1,-0,  01,-0,-0,  01,+1,-0,  02,-0,-0,  01,-1,-0,  01,-0,-0,  02,-1,-0
  db  128

BatLeftAnimation:
  dw  LeftBat1_Char
  dw  LeftBat2_Char
  dw  LeftBat3_Char
  dw  LeftBat4_Char

BatRightAnimation:
  dw  RightBat1_Char
  dw  RightBat2_Char
  dw  RightBat3_Char
  dw  RightBat4_Char

BoringEye:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Green (0) / Red(1)
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BoringEyeRedSpriteblock           ;set block at $a000, page 2 - block containing sprite data

  ld    a,(ix+enemies_and_objects.v7)       ;v7=Green (0) / Red(1)
  or    a
	ld		a,BoringEyeGreenSpriteblock         ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
	ld		a,BoringEyeRedSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  .BlockSet:

  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    de,BoringEyeMovementTable           ;Hovering up and down
  ld    a,(framecounter)
  rrca
  call  c,MoveObjectWithStepTableNewMirrorX   ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table

  .Animate:
  ld    hl,BoringEyeAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

BoringEyeMovementTable:  ;repeating steps(128 = end table/repeat), move y, move x  (Hovering up and down)
  db  03,-1,-0,  01,-0,-0,  02,-1,-0,  01,-0,-0,  01,-1,-0,  02,-0,-0
  db  01,+1,-0,  01,-0,-0,  02,+1,-0,  01,-0,-0,  03,+1,-0,  02,-0,-0
  db  02,+1,-0,  01,-0,-0,  01,+1,-0,  02,-0,-0,  01,-1,-0,  01,-0,-0,  02,-1,-0
  db  128


BoringEyeAnimation:
  dw  BoringEyeRed1_Char
  dw  BoringEyeRed2_Char
  dw  BoringEyeRed3_Char
  dw  BoringEyeRed4_Char
  
;RemoveWhenOutOfScreen:
;  or    a                                   ;reset carry
;  ld    e,(ix+enemies_and_objects.x)
;  ld    d,(ix+enemies_and_objects.x+1)
;  ld    hl,300
;  sbc   hl,de
;  jr    c,.TurnLeft

;  ld    hl,14
;  sbc   hl,de
;  ret   c

;  .TurnRight:
;  ld    (ix+enemies_and_objects.v4),+1       ;v4=Horizontal Movement
;  ret
  
;  .TurnLeft:
;  ld    (ix+enemies_and_objects.v4),-1       ;v4=Horizontal Movement
;  ret
  
TurnWhenOutOfScreen:
  or    a                                   ;reset carry
  ld    e,(ix+enemies_and_objects.x)
  ld    d,(ix+enemies_and_objects.x+1)
  ld    hl,300
  sbc   hl,de
  jr    c,.TurnLeft

  ld    hl,14
  sbc   hl,de
  ret   c

  .TurnRight:
  ld    (ix+enemies_and_objects.v4),+1       ;v4=Horizontal Movement
  ret
  
  .TurnLeft:
  ld    (ix+enemies_and_objects.v4),-1       ;v4=Horizontal Movement
  ret

Beetle:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=movement table. 0=Table 1 (Circling ClockWise) 1=Table 1 (Circling CounterClockwise)      
;v8=face left (-0) or face right (1)
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,BeetleSpriteblock                 ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=flying, )
  or    a
  jp    z,BeetleWalking
  dec   a
  jp    z,BeetleFlying
  dec   a

  BeetleFlying:
  call  .Movement
  call  CheckOutOfMap
  ld    a,(ix+enemies_and_objects.v3)       ;v3=y movement
  or    a
  jr    z,.EndFloorCheck                   ;don't perform floor check when y movement is negative
  jp    m,.EndFloorCheck                   ;don't perform floor check when y movement is negative
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  call  z,.FloorFoundGoWalk
  .EndFloorCheck:
    
  .Animate:
  bit   0,(ix+enemies_and_objects.v8)       ;face left (0) or face right (1)
  ld    hl,BeetleRightFlyAnimation
  jr    z,.GoAnimate
  ld    hl,BeetleLeftFlyAnimation
  .GoAnimate:
  ld    b,01                                ;animate every x frames (based on framecounter)
  ld    c,2 * 02                            ;02 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .FloorFoundGoWalk:
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=flying, )
  ld    (ix+enemies_and_objects.v3),0       ;v3=Vertical Movement
  ld    (ix+enemies_and_objects.v5),0       ;v5=repeating steps
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to movement table

  bit   0,(ix+enemies_and_objects.v8)       ;face left (0) or face right (1)
  ld    (ix+enemies_and_objects.v4),+1      ;v4=Horizontal Movement
  ret   z
  ld    (ix+enemies_and_objects.v4),-1      ;v4=Horizontal Movement
  ret    

  .Movement:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    z,.EndCheckHit
  ld    a,(framecounter)
  and   03
  ret   nz
  .EndCheckHit:
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=movement table. 0=Table 1 (Circling CounterClockwise) 1=Table 1 (Circling ClockWise)      
  or    a
  jr    z,.Movement0
  dec   a
  jr    z,.Movement1
  dec   a
  jr    z,.Movement2

  .Movement3:
  ld    de,BeetleMovementTable2             ;Flying away from player, then diving towards
  call  MoveObjectWithStepTableNewMirrorX   ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  ret
  
  .Movement2:
  ld    de,BeetleMovementTable2             ;Flying away from player, then diving towards
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  ret
  
  .Movement1:
  call  WaspFlyingInPlace.faceplayerSkipRandomness
  ld    de,BeetleMovementTable1             ;Circling 1 or 2 times then stop
  call  MoveObjectWithStepTableNewMirrorX   ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  ret
  
  .Movement0:
  call  WaspFlyingInPlace.faceplayerSkipRandomness
  ld    de,BeetleMovementTable1             ;Circling 1 or 2 times then stop
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  ret

  BeetleWalking:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  jr    z,.EndCheckHit
  ld    a,(framecounter)
  and   03
  call  z,MoveSpriteHorizontally
  jp    .endMove
  .EndCheckHit:

  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally
  .endMove:
  call  TurnWhenOutOfScreen
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  call  .DistanceCheck

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,BeetleRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,BeetleLeftWalkAnimation
  .GoAnimate:
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .DistanceCheck:
  ld    b,70                                ;b-> x distance
  ld    c,60                                ;c-> y distance
  call  distancecheck ;SlightlyMoreToRight    ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc  
  ld    a,r
  and   63
  ret   nz

  call  WaspFlyingInPlace.faceplayerSkipRandomness

  ld    a,(framecounter)
  rrca
  jr    c,.SetAttack1

  .SetAttack0:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    a,2
  jr    z,.GoSetAttack0
  inc   a
  .GoSetAttack0:
  ld    (ix+enemies_and_objects.v7),a       ;v7=movement table. 0=Table 1 (Circling ClockWise) 1=Table 1 (Circling CounterClockwise)      
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=flying, )
  ret  

  .SetAttack1:
  ld    a,(ix+enemies_and_objects.y)        ;y
  sub   a,3
  ld    (ix+enemies_and_objects.y),a        ;y
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    a,0
  jr    z,.GoSetAttack1
  inc   a
  .GoSetAttack1:
  ld    (ix+enemies_and_objects.v7),a       ;v7=movement table. 0=Table 1 (Circling ClockWise) 1=Table 1 (Circling CounterClockwise)      
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=flying, )
  ret  

BeetleMovementTable2:  ;repeating steps(128 = end table/repeat), move y, move x  (Flying away from player, then diving towards)
  db  03,-1,-0,  03,-1,-1,  03,-2,-0,  03,-2,-1,  03,-2,-0
  db  03,-3,-1,  03,-3,-0,  03,-3,-1,  03,-2,-0,  03,-1,-1,  100,+0,-0

  db  03,+1,-1,  03,+1,-2,  03,+2,-3,  03,+2,-2,  03,+3,-1
  db  03,+3,+0,  03,+2,+1,  06,+1,+2,  40,+1,+4
  db  128

BeetleMovementTable1:  ;repeating steps(128 = end table/repeat), move y, move x  (Circling 1 or 2 times then stop)
  db  03,+0,-2,  03,-1,-2,  03,-1,-1,  03,-2,-1,  03,-2,-0
  db  03,-2,-0,  03,-2,+1,  03,-1,+1,  03,-1,+2,  03,-0,+2
  db  03,+0,+2,  03,+1,+2,  03,+1,+1,  03,+2,+1,  03,+2,+0
  db  03,+2,+0,  03,+2,-1,  03,+1,-1,  03,+1,-2,  03,+0,-2,  01,+1,-2
  db  128

BeetleLeftFlyAnimation:
  dw  LeftBeetleFly1_Char
  dw  LeftBeetleFly2_Char

BeetleRightFlyAnimation:
  dw  RightBeetleFly1_Char
  dw  RightBeetleFly2_Char

BeetleLeftWalkAnimation:
  dw  LeftBeetleWalk1_Char
  dw  LeftBeetleWalk2_Char
  dw  LeftBeetleWalk3_Char
  dw  LeftBeetleWalk4_Char

BeetleRightWalkAnimation:
  dw  RightBeetleWalk1_Char
  dw  RightBeetleWalk2_Char
  dw  RightBeetleWalk3_Char
  dw  RightBeetleWalk4_Char
  
Slime:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
  call  .HandlePhase                        ;0=moving, 1=waiting, 2=duck, 3=unduck) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemyOnlySitting  ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,SlimeSpriteblock                  ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  or    a
  jp    z,SlimeMoving
  dec   a
  jp    z,SlimeWaiting
  dec   a
  jp    z,SlimeDucking

  SlimeUnDucking:
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,SlimeRightUnDuckAnimation
  jp    z,.GoAnimate
  ld    hl,SlimeLeftUnDuckAnimation
  .GoAnimate:
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;07 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 03
  ret   nz

  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  SlimeDucking:
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,SlimeRightDuckAnimation
  jp    z,.GoAnimate
  ld    hl,SlimeLeftDuckAnimation
  .GoAnimate:
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;07 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 03
  ret   nz
  ld    (ix+enemies_and_objects.v1),2 * 02  ;v1=Animation Counter
  ld    a,(EnableHitbox?)
  or    a
  ret   nz                                  ;check if player is still attacking
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  SlimeWaiting:
  call  SlimeMoving.DistanceToPlayerCheck   ;check if player is near and attacks, DUCK !

  call  .Animate                            ;out hl -> sprite character data to out to Vram  
  dec   (ix+enemies_and_objects.v5)         ;v5=Wait timer
  ret   nz
  
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,SlimeRightWalkAnimation
  jp    nz,.GoAnimate
  ld    hl,SlimeLeftWalkAnimation
  .GoAnimate:
  ld    b,15                                ;animate every x frames (based on framecounter)
  ld    c,2 * 03                            ;07 animation frame addresses
  jp     AnimateSprite                      ;out hl -> sprite character data to out to Vram

  SlimeMoving:
  call  .DistanceToPlayerCheck              ;check if player is near and attacks, DUCK !
  ld    a,(framecounter)
  and   3
  call  z,MoveSpriteHorizontally
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  push  af                                  ;store movement direction
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  GreenSpiderWalkSlow.CheckFloor      ;checks for floor. if not found invert direction
  ld    b,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  pop   af                                  ;check if slime changed direction. If so change to Phase 1
  cp    b
  jr    z,.Animate
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  ld    (ix+enemies_and_objects.v5),50      ;v5=Wait timer
  jp    SlimeWaiting.Animate

  .DistanceToPlayerCheck:
  ld    b,26                                ;b-> x distance
  ld    c,08                                ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc

  ld    a,(EnableHitbox?)
  or    a
  ret   z                                   ;check if player is attacking

	ld		de,(PlayerSpriteStand)              ;don't duck if player is charging
	ld		hl,Charging
  xor   a
  sbc   hl,de
  ret   z
  
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase v2=Phase (0=moving, 1=waiting, 2=duck, 3=unduck)
  ret

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,SlimeRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,SlimeLeftWalkAnimation
  .GoAnimate:
  ld    b,15                                ;animate every x frames (based on framecounter)
  ld    c,2 * 03                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

SlimeLeftUnDuckAnimation:
  dw  LeftSlime1_Char
  dw  LeftSlime2_Char
  dw  LeftSlime3_Char
  dw  LeftSlime3_Char

SlimeRightUnDuckAnimation:
  dw  RightSlime1_Char
  dw  RightSlime2_Char
  dw  RightSlime3_Char
  dw  RightSlime3_Char

SlimeLeftDuckAnimation:
  dw  LeftSlime3_Char
  dw  LeftSlime2_Char
  dw  LeftSlime1_Char
  dw  LeftSlime1_Char

SlimeRightDuckAnimation:
  dw  RightSlime3_Char
  dw  RightSlime2_Char
  dw  RightSlime1_Char
  dw  RightSlime1_Char

SlimeLeftWalkAnimation:
  dw  LeftSlime4_Char
  dw  LeftSlime5_Char
  dw  LeftSlime6_Char
   
SlimeRightWalkAnimation:
  dw  RightSlime4_Char
  dw  RightSlime5_Char
  dw  RightSlime6_Char

SxFlame1: equ 128
SxFlame2: equ 128+6
SxFlame3: equ 128+6+6
FireEyeFireBullet:
;v1 = sx
;v2=Phase (0=moving, 1=static on floor, 3=fading out)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Static Timer
  call  .Animate                            ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),b       ;sx
  call  .HandlePhase                        ;(0=moving, 1=static on floor, 3=fading out)
  ret

  .Animate:
  ld    a,(framecounter)
  and   15
  sub   4
  ld    b,SxFlame1
  ret   c
  sub   4
  ld    b,SxFlame3
  ret   c
  sub   4
  ld    b,SxFlame2
  ret   c
  ld    b,SxFlame3
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=moving, 1=static on floor, 3=fading out)
  or    a
  jp    z,FireEyeFireBulletMoving
  dec   a
  jp    z,FireEyeFireBulletStatic

  FireEyeFireBulletFadingOut:
  ld    a,(framecounter)
  and   3
  jp    z,VramObjectsTransparantCopies
  call  VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  dec   (ix+enemies_and_objects.v5)         ;v5=Static Timer
  ret   nz
  ld    (ix+enemies_and_objects.alive?),0  
  ret
  
  FireEyeFireBulletStatic:
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  VramObjectsTransparantCopies        ;put object in Vram/screen  
  dec   (ix+enemies_and_objects.v5)         ;v5=Static Timer
  ret   nz
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=moving, 1=static on floor, 3=fading out)  
  ld    (ix+enemies_and_objects.v5),040     ;v5=Static Timer
  ret

  FireEyeFireBulletMoving:
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  VramObjectsTransparantCopies        ;put object in Vram/screen
  call  .Gravity
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)

  call  CheckFloorEnemyObject               ;checks for floor, out z=collision found with floor
  ret   nz                                  ;return if background tile is NOT found
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=moving, 1=static on floor, 3=fading out)  
  ld    (ix+enemies_and_objects.v5),050     ;v5=Static Timer
  ret
  
  .Gravity:
  ld    a,(framecounter)
  and   7
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v3)       ;v3=Vertical Movement
  inc   a
  cp    5
  ret   z
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  ret

FireEyeGreen:
FireEyeGrey:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=v3v4tablerotator
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,FireEyeGreenSpriteblock            ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  call  .CheckShootFire                     ;every x frames fire will be shot from eye

  .Animate:
  ld    hl,FireEyeAnimation
  ld    b,03                                ;animate every x frames (based on framecounter)
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram  ret

  .CheckShootFire:
  ld    a,(framecounter)
  and   63
  ret   nz
  
  push  ix
  call  .SearchEmptySlot
  pop   ix
  ret

  .SearchEmptySlot:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=v3v4tablerotator
  inc   a
  and   15
  ld    (ix+enemies_and_objects.v5),a       ;v5=v3v4tablerotator
  ld    b,(ix+enemies_and_objects.x)        ;x
  ld    c,(ix+enemies_and_objects.y)        ;y
  
  ld    de,lenghtenemytable
  
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
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
  ld    (ix+enemies_and_objects.alive?),1 
  ld    (ix+enemies_and_objects.y),c ;8*18
  dec   b | dec   b | dec   b
  ld    (ix+enemies_and_objects.x),b ;8*21
  ld    (ix+enemies_and_objects.x+1),0
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=static on floor, 3=fading out)

  ;set v3 + v4 at random
  add   a,a                                 ;v5=v3v4tablerotator a=0,2,4,6,8,10,12,14 ,16,18,20,22,24,26,28,30
  ld    hl,.v3v4Table
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)
  ld    (ix+enemies_and_objects.v3),a       ;v3=Vertical Movement
  inc   hl
  ld    a,(hl)
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

.v3v4Table: ;v3, v4
  db    -1,+1, -2,-1, -5,+1, -4,-1 
  db    -1,+1, -1,-1, -4,+1, -3,-1 
  db    -2,+1, -1,-1, -5,+1, -4,-1 
  db    -3,+1, -2,-1, -5,+1, -5,-1 

FireEyeAnimation:
  dw  FireEyeGrey1_Char
  dw  FireEyeGrey2_Char
  dw  FireEyeGrey3_Char
  dw  FireEyeGrey4_Char
  dw  FireEyeGrey5_Char
  dw  FireEyeGrey6_Char
  
Landstrider:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=unable to hit timer
;v6=Grow Timer
;v7=move up once when growing flag
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  ld    a,(ix+enemies_and_objects.v5)       ;v5=unable to hit timer
  or    a
  call  z,CheckPlayerPunchesEnemy           ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,LandstriderSpriteblock            ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking) ;out hl -> sprite character data to out to Vram
  or    a
  jp    z,LandstriderWalking
  dec   a
  jp    z,LandstriderDucking
  dec   a
  jp    z,LandstriderDucked
  dec   a
  jp    z,LandstriderUnDucking
  dec   a
  jp    z,LandstriderGrowing
  dec   a
  jp    z,LandstriderGrowingTall

  LandstriderBigWalking:
  ld    (ix+enemies_and_objects.v5),0       ;v5=unable to hit timer
  call  .walking
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  LandstriderWalking.CheckFloor       ;checks for floor. if not found invert direction
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LandstriderBigRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,LandstriderBigLeftWalkAnimation
  .GoAnimate:
  ld    b,15                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .walking:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if hit
  or    a
  jr    z,.EndCheckHit
  ld    a,(framecounter)
  and   07
  jp    z,MoveSpriteHorizontally            ;move once every 8 frames when hit
  ret
  
  .EndCheckHit:
  ld    a,(framecounter)
  and   07
  cp    1
  ret   z
  ld    a,(framecounter)
  rrca
  ret   nc
  jp    MoveSpriteHorizontally            ;move once every 2 frames  


  LandstriderGrowingTall:                   ;we now switch to 4 sprite mode, Landstrider is now a young adult, ready to take on the world
  call  LandstriderDucked.ShortWhiteBlinkWhenHit
  ld    (ix+enemies_and_objects.nrsprites),72-(04*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),4
  ld    (ix+enemies_and_objects.nrspritesTimes16),4*16  
  call  .MoveUpWhenGrowing

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LandstriderRightGrowingTallAnimation
  jp    z,.GoAnimate
  ld    hl,LandstriderLeftGrowingTallAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 05                            ;04 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),6       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking)  
  ld    (ix+enemies_and_objects.life),2
  ld    a,(ix+enemies_and_objects.y)
  add   a,4
  ld    (ix+enemies_and_objects.y),a
  ld    (ix+enemies_and_objects.ny),32
  ret

  .MoveUpWhenGrowing:
  ld    a,(ix+enemies_and_objects.v7)       ;move up once when growing flag
  or    a
  ld    (ix+enemies_and_objects.v7),1       ;move up once when growing flag
  call  z,.MoveUp
  
  ld    a,(framecounter)
  and   7
  ret   nz
  .MoveUp:
  ld    a,(ix+enemies_and_objects.y)
  sub   a,4
  ld    (ix+enemies_and_objects.y),a
  ret

  LandstriderGrowing:
  call  LandstriderDucked.ShortWhiteBlinkWhenHit
  call  LandstriderUnDucking
  ld    (ix+enemies_and_objects.life),10
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking)  
  or    a
  ret   nz
  ld    (ix+enemies_and_objects.v2),5       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking)  
  ld    (ix+enemies_and_objects.v5),0       ;v5=repeating steps
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to movement table
  ret
  
  LandstriderUnDucking:
  ld    (ix+enemies_and_objects.life),1
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LandstriderRightUnDuckAnimation
  jp    z,.GoAnimate
  ld    hl,LandstriderLeftUnDuckAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 05                            ;04 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 04
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking)  
  ret

  LandstriderDucked:
  call  .ShortWhiteBlinkWhenHit
  call  .DistanceCheck                      ;if player moves away, Landstriker will UnDuck
  call  .ReduceGrowTime                     ;after a while go to Grow phase
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  or    a
  ld    hl,RightLandstriderDuck4_Char
  ret   p
  ld    hl,LeftLandstriderDuck4_Char
  ret

  .ReduceGrowTime:
  dec   (ix+enemies_and_objects.v6)         ;v6=Grow Timer
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),4       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v5),0       ;v5=unable to hit timer
  ret  
  
  .ShortWhiteBlinkWhenHit:
  ld    a,(ix+enemies_and_objects.v5)       ;v5=unable to hit timer
  dec   a
  jp    m,.EndReduceUnableToHitTimer
  ld    (ix+enemies_and_objects.v5),a       ;v5=unable to hit timer
  .EndReduceUnableToHitTimer:

  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit-4
  ret   nz
  ld    (ix+enemies_and_objects.hit?),0
  ld    (ix+enemies_and_objects.v5),20       ;v5=unable to hit timer
  ret
  
  .DistanceCheck:
  ld    b,40                                ;b-> x distance
  ld    c,60                                ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   c
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v5),0       ;v5=unable to hit timer
  ret  

  LandstriderDucking:
  call  LandstriderDucked.ShortWhiteBlinkWhenHit  
  ld    (ix+enemies_and_objects.life),15
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LandstriderRightDuckAnimation
  jp    z,.GoAnimate
  ld    hl,LandstriderLeftDuckAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  call  AnimateSprite                       ;out hl -> sprite character data to out to Vram

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  cp    2 * 03
  ret   nz
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking)  
  ld    (ix+enemies_and_objects.v6),250     ;v6=Grow Timer
  ret

  LandstriderWalking:
  ld    a,(framecounter)
  rrca
  call  c,MoveSpriteHorizontally            ;move once every 2 frames  
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  call  .DistanceCheck                      ;check if near player. if so Duck
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,LandstriderRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,LandstriderLeftWalkAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .DistanceCheck:
  ld    b,40                                ;b-> x distance
  ld    c,60                                ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc

  ld    a,(ix+enemies_and_objects.v1)       ;v1=Animation Counter
  or    a
  ret   z
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=ducking, 2=ducked, 3=unduck, 4=growing, 5=growing tall, 6=Big walking) ;out hl -> sprite character data to out to Vram
  ret  

  .CheckFloor:                              ;checks for floor. if not found invert direction
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  inc   a                                   ;check for background tile (0=background, 1=hard foreground, 2=ladder, 3=lava.)
  ret   nz                                  ;return if background tile is NOT found
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

LandstriderLeftGrowingTallAnimation:
  dw  LeftLandstriderGrow1_Char
  dw  LeftLandstriderGrow2_Char
  dw  LeftLandstriderGrow3_Char
  dw  LeftBigLandstrider3_Char
  dw  LeftBigLandstrider3_Char

LandstriderRightGrowingTallAnimation:
  dw  RightLandstriderGrow1_Char
  dw  RightLandstriderGrow2_Char
  dw  RightLandstriderGrow3_Char
  dw  RightBigLandstrider3_Char
  dw  RightBigLandstrider3_Char

LandstriderLeftUnDuckAnimation:
  dw  LeftLandstriderDuck4_Char
  dw  LeftLandstriderDuck3_Char
  dw  LeftLandstriderDuck2_Char
  dw  LeftLandstriderDuck1_Char
  dw  LeftLandstriderDuck1_Char
   
LandstriderRightUnDuckAnimation:
  dw  RightLandstriderDuck4_Char
  dw  RightLandstriderDuck3_Char
  dw  RightLandstriderDuck2_Char
  dw  RightLandstriderDuck1_Char
  dw  RightLandstriderDuck1_Char

LandstriderLeftDuckAnimation:
  dw  LeftLandstriderDuck1_Char
  dw  LeftLandstriderDuck2_Char
  dw  LeftLandstriderDuck3_Char
  dw  LeftLandstriderDuck4_Char
  dw  LeftLandstriderDuck4_Char
   
LandstriderRightDuckAnimation:
  dw  RightLandstriderDuck1_Char
  dw  RightLandstriderDuck2_Char
  dw  RightLandstriderDuck3_Char
  dw  RightLandstriderDuck4_Char
  dw  RightLandstriderDuck4_Char
  
LandstriderLeftWalkAnimation:
  dw  LeftLandstrider1_Char
  dw  LeftLandstrider2_Char
  dw  LeftLandstrider3_Char
  dw  LeftLandstrider4_Char
   
LandstriderRightWalkAnimation:
  dw  RightLandstrider1_Char
  dw  RightLandstrider2_Char
  dw  RightLandstrider3_Char
  dw  RightLandstrider4_Char

LandstriderBigLeftWalkAnimation:
  dw  LeftBigLandstrider1_Char
  dw  LeftBigLandstrider2_Char
  dw  LeftBigLandstrider3_Char
  dw  LeftBigLandstrider4_Char

LandstriderBigRightWalkAnimation:
  dw  RightBigLandstrider1_Char
  dw  RightBigLandstrider2_Char
  dw  RightBigLandstrider3_Char
  dw  RightBigLandstrider4_Char
  
Wasp:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Repeating Steps
;v6=Pointer To Movement Table
;v7=Green Wasp(0) / Brown Wasp(1)
;v8=face left (-0) or face right (1)
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
  ld    a,(ix+enemies_and_objects.v7)       ;v7=Green Wasp(0) / Brown Wasp(1)
  or    a
	ld		a,GreenWaspSpriteblock              ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
	ld		a,BrownWaspSpriteblock              ;set block at $a000, page 2 - block containing sprite data
  .BlockSet:
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret

  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=WaspFlyingInPlace, 1=attacking) ;out hl -> sprite character data to out to Vram
  or    a
  jp    z,WaspFlyingInPlace

;  WaspAttacking:
;  ret

  WaspFlyingInPlace:
  call  .faceplayer
  ld    de,WaspMovementTable
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table

  .Animate:                                 ;out hl -> sprite character data to out to Vram
  bit   0,(ix+enemies_and_objects.v8)       ;face left (0) or face right (1)
  ld    hl,RightGreenWaspAnimation
  jr    z,.GoAnimate
  ld    hl,LeftGreenWaspAnimation
  .GoAnimate:
  ld    b,00                                ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .faceplayer:
  ld    a,r
  and   31
  ret   nz
  .faceplayerSkipRandomness:
  ld    hl,(Clesx)                          ;hl = x player  
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
  sbc   hl,de                               ;make sure wasp always faces player
  ld    (ix+enemies_and_objects.v8),-0      ;face left (0) or face right (1)
  ret   nc
  ld    (ix+enemies_and_objects.v8),+1      ;face left (0) or face right (1)
  ret

MoveObjectWithStepTableNewMirrorX:
  dec   (ix+enemies_and_objects.v5)         ;repeating steps
  jp    p,.moveObject
  
  .NextStep:
  ld    a,(ix+enemies_and_objects.v6)         ;pointer to movement table
  ld    h,0
  ld    l,a
  add   hl,de
  add   a,3
  ld    (ix+enemies_and_objects.v6),a         ;pointer to movement table
  
  ld    a,(hl)                                ;repeating steps(128 = end table/repeat)
  cp    128
  jr    nz,.EndCheckEndTable
  ld    (ix+enemies_and_objects.v6),+3        ;pointer to movement table
  ex    de,hl
  ld    a,(hl)

  .EndCheckEndTable:
  ld    (ix+enemies_and_objects.v5),a         ;repeating steps
  inc   hl
  ld    a,(hl)                                ;y movement
  ld    (ix+enemies_and_objects.v3),a         ;v3=y movement
  inc   hl
  ld    a,(hl)                                ;x movement
  neg
  ld    (ix+enemies_and_objects.v4),a         ;v4=x movement

  .moveObject:
  ld    a,(ix+enemies_and_objects.y)          ;y object
  add   a,(ix+enemies_and_objects.v3)         ;add y movement to y
  ld    (ix+enemies_and_objects.y),a          ;y object

  ;8 bit
;  ld    a,(ix+enemies_and_objects.x)          ;x object
;  add   a,(ix+enemies_and_objects.v4)         ;add x movement to x
;  ld    (ix+enemies_and_objects.x),a          ;x object

  ;16 bit
  ld    a,(ix+enemies_and_objects.v4)         ;x movement
  or    a
  ld    d,0
  jp    p,.positive
  dec   d
  .positive:
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)          ;x object
  ld    h,(ix+enemies_and_objects.x+1)        ;x object
  add   hl,de
  ld    (ix+enemies_and_objects.x),l          ;x object
  ld    (ix+enemies_and_objects.x+1),h        ;x object
  ret  




MoveObjectWithStepTableNewMirroredX:
  dec   (ix+enemies_and_objects.v5)         ;repeating steps
  jp    p,.moveObject
  
  .NextStep:
  ld    a,(ix+enemies_and_objects.v6)         ;pointer to movement table
  ld    h,0
  ld    l,a
  add   hl,de
  add   a,3
  ld    (ix+enemies_and_objects.v6),a         ;pointer to movement table
  
  ld    a,(hl)                                ;repeating steps(128 = end table/repeat)
  cp    128
  jr    nz,.EndCheckEndTable
  ld    (ix+enemies_and_objects.v6),+3        ;pointer to movement table
  ex    de,hl
  ld    a,(hl)

  .EndCheckEndTable:
  ld    (ix+enemies_and_objects.v5),a         ;repeating steps
  inc   hl
  ld    a,(hl)                                ;y movement
  ld    (ix+enemies_and_objects.v3),a         ;v3=y movement
  inc   hl
  ld    a,(hl)                                ;x movement
  neg
  ld    (ix+enemies_and_objects.v4),a         ;v4=x movement

  .moveObject:
  ld    a,(ix+enemies_and_objects.y)          ;y object
  add   a,(ix+enemies_and_objects.v3)         ;add y movement to y
  ld    (ix+enemies_and_objects.y),a          ;y object

  ;8 bit
;  ld    a,(ix+enemies_and_objects.x)          ;x object
;  add   a,(ix+enemies_and_objects.v4)         ;add x movement to x
;  ld    (ix+enemies_and_objects.x),a          ;x object

  ;16 bit
  ld    a,(ix+enemies_and_objects.v4)         ;x movement
  or    a
  ld    d,0
  jp    p,.positive
  dec   d
  .positive:
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)          ;x object
  ld    h,(ix+enemies_and_objects.x+1)        ;x object
  add   hl,de
  ld    (ix+enemies_and_objects.x),l          ;x object
  ld    (ix+enemies_and_objects.x+1),h        ;x object
  ret
  
  
  
  
  
  
MoveObjectWithStepTableNew:                 ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  dec   (ix+enemies_and_objects.v5)         ;repeating steps
  jp    p,.moveObject
  
  .NextStep:
  ld    a,(ix+enemies_and_objects.v6)         ;pointer to movement table
  ld    h,0
  ld    l,a
  add   hl,de
  add   a,3
  ld    (ix+enemies_and_objects.v6),a         ;pointer to movement table
  
  ld    a,(hl)                                ;repeating steps(128 = end table/repeat)
  cp    128
  jr    nz,.EndCheckEndTable
  ld    (ix+enemies_and_objects.v6),+3        ;pointer to movement table
  ex    de,hl
  ld    a,(hl)

  .EndCheckEndTable:
  ld    (ix+enemies_and_objects.v5),a         ;repeating steps
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

  ;8 bit
;  ld    a,(ix+enemies_and_objects.x)          ;x object
;  add   a,(ix+enemies_and_objects.v4)         ;add x movement to x
;  ld    (ix+enemies_and_objects.x),a          ;x object

  ;16 bit
  ld    a,(ix+enemies_and_objects.v4)         ;x movement
  or    a
  ld    d,0
  jp    p,.positive
  dec   d
  .positive:
  ld    e,a
  ld    l,(ix+enemies_and_objects.x)          ;x object
  ld    h,(ix+enemies_and_objects.x+1)        ;x object
  add   hl,de
  ld    (ix+enemies_and_objects.x),l          ;x object
  ld    (ix+enemies_and_objects.x+1),h        ;x object
  ret  

WaspMovementTable:  ;repeating steps(128 = end table/repeat), move y, move x
  db  03,+0,+2,  03,+1,+2,  03,+1,+1,  03,+2,+1,  03,+2,+0
  db  03,+2,+0,  03,+2,-1,  03,+1,-1,  03,+1,-2,  03,+0,-2
  db  03,+0,-2,  03,-1,-2,  03,-1,-1,  03,-2,-1,  03,-2,-0
  db  03,-2,-0,  03,-2,+1,  03,-1,+1,  03,-1,+2,  03,-0,+2
  db  128

LeftGreenWaspAnimation:
  dw  LeftGreenWasp1_Char
  dw  LeftGreenWasp2_Char
  dw  LeftGreenWasp3_Char
  dw  LeftGreenWasp4_Char
  
RightGreenWaspAnimation:
  dw  RightGreenWasp1_Char
  dw  RightGreenWasp2_Char
  dw  RightGreenWasp3_Char
  dw  RightGreenWasp4_Char
   
Treeman:   
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Being Hit Duration
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,TreemanSpriteblock                ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:                             ;out hl -> sprite character data to out to Vram
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=walking, 1=attacking, 2=hit) ;out hl -> sprite character data to out to Vram
  or    a
  jp    z,Treemanwalking
  dec   a
  jp    z,TreemanAttacking

  TreemanHit:
  call  .CheckWalkAgain?
  call  .GoAttack?

  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightTreemanHit_Char
  ret   z
  ld    hl,LeftTreemanHit_Char
  ret

  .GoAttack?:
  call  checkFacingPlayer                   ;out: c = object/enemy is facing player
  ret   nc
  ld    a,r
  and   63
  ret   nz
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=walking, 1=attacking, 2=hit) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  .CheckWalkAgain?:
  dec   (ix+enemies_and_objects.v5)         ;v5=Being Hit Duration
  ret   nz
  ld    a,(ix+enemies_and_objects.hit?)     ;check if hit
  or    a
  jr    z,.NotHit
  ld    (ix+enemies_and_objects.v5),30      ;v5=Being Hit Duration
  ret
  .NotHit:
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=attacking, 2=hit) ;out hl -> sprite character data to out to Vram 
  ret
  
  TreemanAttacking:
  call  .Move
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  push  af
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  Treemanwalking.CheckFloor                         ;checks for floor. if not found invert direction
  ld    b,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  pop   af
  cp    b                                   ;if direction changed while attacking, end phase and go back to walking
  jr    nz,.EndPhase
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,TreemanRightAttackAnimation
  jp    z,.GoAnimate
  ld    hl,TreemanLeftAttackAnimation
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
  call  .Animate                            ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=attacking, 2=hit) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  Treemanwalking:
  call  .CheckIfHit                         ;if Treeman is hit and facing player he may initiate Phase 1 (attacking)
  call  .Move
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,TreemanRightWalkAnimation
  jp    z,.GoAnimate
  ld    hl,TreemanLeftWalkAnimation
  .GoAnimate:
  ld    b,7                                 ;animate every x frames (based on framecounter)
  ld    c,2 * 04                            ;04 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  .CheckIfHit:
  bit   0,(ix+enemies_and_objects.hit?)     ;check if hit
  ret   z
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=walking, 1=attacking, 2=hit) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v5),30      ;v5=Being Hit Duration
  ret

  .Move:
  ld    a,(ix+enemies_and_objects.hit?)     ;check if enemy is hit ? If so, out white sprite
  or    a
  ret   nz
  ld    a,(framecounter)
  and   1
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

TreemanLeftAttackAnimation:
  dw  LeftTreemanAttack1_Char
  dw  LeftTreemanAttack1_Char
  dw  LeftTreemanAttack1_Char
  dw  LeftTreemanAttack1_Char
  dw  LeftTreemanAttack2_Char
  dw  LeftTreemanAttack2_Char
  
TreemanRightAttackAnimation:
  dw  RightTreemanAttack1_Char
  dw  RightTreemanAttack1_Char
  dw  RightTreemanAttack1_Char
  dw  RightTreemanAttack1_Char
  dw  RightTreemanAttack2_Char
  dw  RightTreemanAttack2_Char

TreemanLeftWalkAnimation:
  dw  LeftTreemanWalk1_Char
  dw  LeftTreemanWalk2_Char
  dw  LeftTreemanWalk3_Char
  dw  LeftTreemanWalk4_Char
  
TreemanRightWalkAnimation:
  dw  RightTreemanWalk1_Char
  dw  RightTreemanWalk2_Char
  dw  RightTreemanWalk3_Char
  dw  RightTreemanWalk4_Char
   
Grinder:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .HandlePhase                        ;  ;out hl -> sprite character data to out to Vram
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
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,GrinderRightAttackAnimation
  jp    z,.GoAnimate
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
  call  .Animate                            ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  Grinderwalking:
  call  .CheckIfHit                         ;if Grinder is hit and facing player he may initiate Phase 1 (attacking)
  call  .Move
  call  CheckCollisionWallEnemy             ;checks for collision wall and if found invert direction
  call  .CheckFloor                         ;checks for floor. if not found invert direction
  
  .Animate:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,GrinderRightWalkAnimation
  jp    z,.GoAnimate
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
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,GreenSpiderRightWalkAnimation
  jp    z,.GoAnimate
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
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,GreenSpiderOrangeEyesRightWalkAnimation
  jp    z,.GoAnimate
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
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightRetardZombieWalkingAnimation
  jp    z,.GoAnimate
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
  call  CheckFloorUnderBothFeetEnemy        ;checks for floor, out z=collision found with floor
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
  call  PutSF2Object ;CHANGES IX   
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
  call  PutSF2Object2 ;CHANGES IX   
  ret

Sf2Hugeobject3:                             ;movement pattern 5
  ld    a,(HugeObjectFrame)
  cp    2
  jp    nz,CheckCollisionObjectPlayer

  call  MoveSF2Object3
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  restoreBackgroundObject3
;  call  ObjectAnimation
  call  PutSF2Object3 ;CHANGES IX   

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
  
  MovePlayerAlongWithObject:
  ld    a,(PlayerDead?)
  or    a
  ret   nz  
  
  ld    a,(ix+enemies_and_objects.v4)         ;x movement
  or    a
  ld    d,0
  jp    p,.positive
  dec   d  
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

VramObjectsTransparantCopiesRemoveAndClearBuffer:
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  push  hl
;  call  docopy
  pop   iy

  xor   a
  ld    (iy+sPage),a
  ld    (iy+dPage),a
  ld    (iy+sx),a
  ld    (iy+dx),a
  ld    (iy+sy),a
  ld    (iy+dy),a
  ret

VramObjectsTransparantCopiesRemove:
ret
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  jp    docopy

VramObjectsTransparantCopies:
;first clean the object
;  call  BackdropRed

;which Clean Object (DoCopy) table do we use ?
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  push  hl
;  call  docopy
  pop   iy
  ld    (iy+restorebackground?),1  ;all background restores should be done simultaneously at start of frame (after vblank)

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