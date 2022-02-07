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
;HugeBlob
;HugeBlobSWsprite
;OP_SlowDownHandler

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
  
CheckFloorEnemy:  
  ld    hl,-16
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
  
CollisionObjectPlayer:  
  ld    hl,(Clesx)                          ;hl = x player
  ld    bc,20-2-16                          ;reduce this value to reduce the hitbox size (on the left side)
  jp    CollisionEnemyPlayer.ObjectEntry
  
  CollisionEnemyPlayer:
;check if player collides with left side of enemy/object
  ld    hl,(Clesx)                          ;hl = x player
  ld    bc,20-2                             ;reduce this value to reduce the hitbox size (on the left side)

  .ObjectEntry:
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

CheckPlayerPunchesEnemyOnlySitting:
  ld    a,(HitBoxSY)                        ;a = y hitbox
  push  af
  sub   a,9
  ld    (HitBoxSY),a                        ;a = y hitbox
  call  CheckPlayerPunchesEnemy
  pop   af
  ld    (HitBoxSY),a                        ;a = y hitbox
  ret

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
  ret
  
  .ExplosionSmall:
  ;Enemy dies
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
  
  call  .Animate
  
	ld		a,RedExplosionSpriteblock           ;set block at $a000, page 2 - block containing sprite data
  exx                                       ;store hl. hl now points to color data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)

  ld    (ix+enemies_and_objects.nrsprites),72-(08*6)
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


HugeBlob:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
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

  .Animate:
  ld    hl,HugeBlobAnimation
  ld    b,07                                ;animate every x frames (based on framecounter)
  ld    c,2 * 07                            ;07 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram
  
HugeBlobAnimation:
  dw  HugeBlob1_Char
  dw  HugeBlob2_Char
  dw  HugeBlob3_Char
  dw  HugeBlob4_Char
  dw  HugeBlob5_Char
  dw  HugeBlob6_Char
  dw  HugeBlob7_Char

OctopussyBullet:                            ;forced on object positions 1-4
;v1 = sx
;v2=Phase (0=moving, 1=static on floor, 3=fading out)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=reference to movement table (0, 8, 16, 24, 32, 40, 48, 56)
  .HandlePhase:
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

  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
  jp    nz,VramObjectsTransparantCopies     ;put object in Vram/screen
  call  VramObjectsTransparantCopiesRemoveAndClearBuffer  ;Clear buffer, so that next time the CleanOb is called buffer is empty
  ld    (ix+enemies_and_objects.Alive?),0  
  ret

.Playerwashit:
  call  VramObjectsTransparantCopiesRemoveAndClearBuffer  ;Clear buffer, so that next time the CleanOb is called buffer is empty
  ld    (ix+enemies_and_objects.Alive?),0
  ld    a,1
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
  ld    a,(ix+enemies_and_objects.v6)       ;v6 wait until shooting again
  dec   a
  jr    z,.OctoMayShoot
  ld    (ix+enemies_and_objects.v6),a       ;v6 wait until shooting again
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
  cp    2 * 05
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
  ld    c,2 * 06                            ;06 animation frame addresses
  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

  HunchbackWaiting:
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    hl,RightHunchback3_Char
  jp    z,.DirectionFound
  ld    hl,LeftHunchback3_Char
  .DirectionFound:

  dec   (ix+enemies_and_objects.v5)         ;v5=Wait timer
  ret   nz
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping)  
  ret

  HunchbackStandingStill:
  ld    a,r
  and   63
  jp    nz,.Animate
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=standing still, 1=waiting, 2=initiate jump, 3=jumping) 
  ld    (ix+enemies_and_objects.v5),20      ;v5=Wait timer
    
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
  dw  LeftHunchback1_Char
  dw  LeftHunchback2_Char
  dw  LeftHunchback3_Char  
  dw  LeftHunchback4_Char
  dw  LeftHunchback5_Char
  dw  LeftHunchback6_Char

RightHunchbackJumpingAnimation:
  dw  RightHunchback1_Char
  dw  RightHunchback2_Char
  dw  RightHunchback3_Char
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

SxDemontjeBullet1: equ 146
SxDemontjeBullet2: equ 146+11
SxDemontjeBullet3: equ 146+11+11
DemontjeBullet:
;v1 = sx
;v2=Phase (0=moving)
;v3=Vertical Movement
;v4=Horizontal Movement
  call  .Animate
  ld    (ix+enemies_and_objects.v1),a       ;sx

  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  .Gravity
  call  .CheckCollisionForeground
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)

  .Animate:
  ld    a,(framecounter)
  and   15
  sub   8
  ld    a,SxDemontjeBullet1
  ret   c
  ld    a,SxDemontjeBullet2
  ret

;  ld    a,(framecounter)
;  and   31
;  sub   8
;  ld    b,SxDemontjeBullet1
;  ret   c
;  sub   8
;  ld    b,SxDemontjeBullet2
;  ret   c
;  sub   8
;  ld    b,SxDemontjeBullet3
;  ret   c
;  ld    b,SxDemontjeBullet2
;  ret

  .CheckCollisionForeground:
  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
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
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemyOnlySitting  ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,SlimeSpriteblock                  ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v2)       ;v2=Phase (0=moving, 1=static on floor, 3=duck)
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

  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=static on floor, 2=duck, 3=unduck)
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
  ld    (ix+enemies_and_objects.v2),3       ;v2=Phase (0=moving, 1=static on floor, 2=duck, 3=unduck)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

  SlimeWaiting:
  call  SlimeMoving.DistanceToPlayerCheck   ;check if player is near and attacks, DUCK !

  call  .Animate  
  dec   (ix+enemies_and_objects.v5)         ;v5=Wait timer
  ret   nz
  
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=moving, 1=static on floor, 2=duck, 3=unduck)
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
  jp     AnimateSprite                       ;out hl -> sprite character data to out to Vram

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
  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=moving, 1=static on floor, 2=duck, 3=unduck)
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
  
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=moving, 1=static on floor, 2=duck, 3=unduck)
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
  call  .Animate
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

  call  CheckFloorEnemy                     ;checks for floor, out z=collision found with floor
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
  call  docopy
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