;This is at $4000 inside a block (movementpatternsblock) > no it's not, it's 8000
phase MovementPatterns1Address

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
;Altar1
;Altar2
;BossVoodooWasp
;BossZombieCaterpillar
;PlatformOmniDirectionally
;Teleport
;WaterfallScene
;BossDemon
;BossDemonBullet

ZombieSpawnPoint:
;v1=Zombie Spawn Timer
;v2=Max Number Of Zombies
;v3=Spawn Speed
;v4=Face direction
  ld    a,(framecounter)
  rrca
  ret   c

  ld    a,(ix+enemies_and_objects.v3)     ;spawn speed: 1=slow. anything else =fast
  cp    1
  jr    z,.Go
  dec   (ix+enemies_and_objects.v1)       ;v1=Zombie Spawn Timer
  .Go:
  dec   (ix+enemies_and_objects.v1)       ;v1=Zombie Spawn Timer
  ret   nz

  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  ld    bc,16                               ;all hardware sprites need to be put 16 pixel to the right
  add   hl,bc
  ld    c,(ix+enemies_and_objects.y)
  ld    b,(ix+enemies_and_objects.v2)       ;v2=Max Number Of Zombies
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Face direction
  cp    3
  ld    a,1
  jr    z,.HorizontalMovementSpeedSet
  ld    a,-1
  .HorizontalMovementSpeedSet:
  ex    af,af'

  .SearchEmptySlot:
  ld    de,lenghtenemytable
  
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  ld    a,b                                 ;Max Number Of Zombies
  cp    1
  ret   z
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  ld    a,b                                 ;Max Number Of Zombies
  cp    2
  ret   z
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  ld    a,b                                 ;Max Number Of Zombies
  cp    3
  ret   z
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  ret   nz
  
  .EmptySlotFound:
  ld    (ix+enemies_and_objects.alive?),-1 
  ld    (ix+enemies_and_objects.y),c
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
;  ld    (ix+enemies_and_objects.v3),1       ;v3=Vertical Movement
  ex    af,af'
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ld    (ix+enemies_and_objects.ny),32       ;ny
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

TemplateBoss:
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=attack pattern

;  ld    a,(ix+enemies_and_objects.y)        ;y object
;  ld    (Object1y),a
;  ld    a,(ix+enemies_and_objects.x)        ;x object
;  ld    (Object1x),a	

;  ld    hl,BossAreaVoodooWaspPalette
;  call  Setpalette	

;  call  CheckPlayerHitByBoss                ;Check if player gets hit by boss
  ;Check if boss gets hit by player
;  call  VoodooWaspCheckIfHit                ;call gets popped if dead. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
;  call  BossCheckIfDead                     ;Check if boss is dead, and if so set dying phase

  call  .HandlePhase                        ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,BossZombieCaterpillarIdle00
  jp    PutSf2Object3Frames                 ;CHANGES IX - puts object in 3 frames, Top, MIdle and then Bottom

  .HandlePhase:                            ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)


  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  


  ld    a,(HugeObjectFrame)
  cp    2
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a
  ret

;0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying
;Idle sitting
BossZombieCaterpillarIdle00:   dw ZombieCaterpillarIdleframe000 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle01:   dw ZombieCaterpillarIdleframe001 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle02:   dw ZombieCaterpillarIdleframe002 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle03:   dw ZombieCaterpillarIdleframe003 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle04:   dw ZombieCaterpillarIdleframe004 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle05:   dw ZombieCaterpillarIdleframe005 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle06:   dw ZombieCaterpillarIdleframe006 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle07:   dw ZombieCaterpillarIdleframe007 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle08:   dw ZombieCaterpillarIdleframe008 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle09:   dw ZombieCaterpillarIdleframe009 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle10:   dw ZombieCaterpillarIdleframe010 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle11:   dw ZombieCaterpillarIdleframe011 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle12:   dw ZombieCaterpillarIdleframe012 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle13:   dw ZombieCaterpillarIdleframe013 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle14:   dw ZombieCaterpillarIdleframe014 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle15:   dw ZombieCaterpillarIdleframe015 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle16:   dw ZombieCaterpillarIdleframe016 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle17:   dw ZombieCaterpillarIdleframe017 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

;Diving underground
BossZombieCaterpillarIdle18:   dw ZombieCaterpillarIdleframe018 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle19:   dw ZombieCaterpillarIdleframe019 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle20:   dw ZombieCaterpillarIdleframe020 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle21:   dw ZombieCaterpillarIdleframe021 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle22:   dw ZombieCaterpillarIdleframe022 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle23:   dw ZombieCaterpillarIdleframe023 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle24:   dw ZombieCaterpillarIdleframe024 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle25:   dw ZombieCaterpillarIdleframe025 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle26:   dw ZombieCaterpillarIdleframe026 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle27:   dw ZombieCaterpillarIdleframe027 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle28:   dw ZombieCaterpillarIdleframe028 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle29:   dw ZombieCaterpillarIdleframe029 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle30:   dw ZombieCaterpillarIdleframe030 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle31:   dw ZombieCaterpillarIdleframe031 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle32:   dw ZombieCaterpillarIdleframe032 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle33:   dw ZombieCaterpillarIdleframe033 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle34:   dw ZombieCaterpillarIdleframe034 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle35:   dw ZombieCaterpillarIdleframe035 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle36:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle37:   dw ZombieCaterpillarIdleframe036 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle38:   dw ZombieCaterpillarIdleframe037 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle39:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle40:   dw ZombieCaterpillarIdleframe038 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle41:   dw ZombieCaterpillarIdleframe039 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle42:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle43:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle44:   dw ZombieCaterpillarIdleframe040 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle45:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle46:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle47:   dw ZombieCaterpillarIdleframe041 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle48:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle49:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle50:   dw ZombieCaterpillarIdleframe042 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle51:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle52:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle53:   dw ZombieCaterpillarIdleframe043 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

;Attacking
BossZombieCaterpillarIdle54:   dw ZombieCaterpillarIdleframe044 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle55:   dw ZombieCaterpillarIdleframe044 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle56:   dw ZombieCaterpillarIdleframe044 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle57:   dw ZombieCaterpillarIdleframe045 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle58:   dw ZombieCaterpillarIdleframe045 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle59:   dw ZombieCaterpillarIdleframe045 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle60:   dw ZombieCaterpillarIdleframe046 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle61:   dw ZombieCaterpillarIdleframe046 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle62:   dw ZombieCaterpillarIdleframe046 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle63:   dw ZombieCaterpillarIdleframe047 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle64:   dw ZombieCaterpillarIdleframe047 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle65:   dw ZombieCaterpillarIdleframe047 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle66:   dw ZombieCaterpillarIdleframe048 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle67:   dw ZombieCaterpillarIdleframe048 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle68:   dw ZombieCaterpillarIdleframe049 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarIdle69:   dw ZombieCaterpillarIdleframe050 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle70:   dw ZombieCaterpillarIdleframe051 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock
BossZombieCaterpillarIdle71:   dw ZombieCaterpillarIdleframe052 | db BossZombieCaterpillarIdleframelistblock, BossZombieCaterpillarIdlespritedatablock

BossZombieCaterpillarAttack72:   dw ZombieCaterpillarAttackframe000 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack73:   dw ZombieCaterpillarAttackframe001 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack74:   dw ZombieCaterpillarAttackframe002 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack75:   dw ZombieCaterpillarAttackframe003 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack76:   dw ZombieCaterpillarAttackframe004 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack77:   dw ZombieCaterpillarAttackframe005 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack78:   dw ZombieCaterpillarAttackframe006 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack79:   dw ZombieCaterpillarAttackframe007 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack80:   dw ZombieCaterpillarAttackframe008 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack81:   dw ZombieCaterpillarAttackframe009 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack82:   dw ZombieCaterpillarAttackframe010 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack83:   dw ZombieCaterpillarAttackframe011 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack84:   dw ZombieCaterpillarAttackframe012 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack85:   dw ZombieCaterpillarAttackframe013 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack86:   dw ZombieCaterpillarAttackframe014 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack87:   dw ZombieCaterpillarAttackframe015 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack88:   dw ZombieCaterpillarAttackframe016 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack89:   dw ZombieCaterpillarAttackframe017 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack90:   dw ZombieCaterpillarAttackframe018 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack91:   dw ZombieCaterpillarAttackframe019 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack92:   dw ZombieCaterpillarAttackframe020 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack93:   dw ZombieCaterpillarAttackframe021 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack94:   dw ZombieCaterpillarAttackframe022 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack95:   dw ZombieCaterpillarAttackframe023 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

;hit
BossZombieCaterpillarAttack96:   dw ZombieCaterpillarAttackframe024 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack97:   dw ZombieCaterpillarAttackframe025 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack98:   dw ZombieCaterpillarAttackframe026 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack99:   dw ZombieCaterpillarAttackframe027 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack100:   dw ZombieCaterpillarAttackframe028 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack101:   dw ZombieCaterpillarAttackframe029 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack102:   dw ZombieCaterpillarAttackframe030 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack103:   dw ZombieCaterpillarAttackframe031 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack104:   dw ZombieCaterpillarAttackframe032 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack105:   dw ZombieCaterpillarAttackframe033 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack106:   dw ZombieCaterpillarAttackframe034 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack107:   dw ZombieCaterpillarAttackframe035 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

BossZombieCaterpillarAttack108:   dw ZombieCaterpillarAttackframe036 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack109:   dw ZombieCaterpillarAttackframe037 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock
BossZombieCaterpillarAttack110:   dw ZombieCaterpillarAttackframe038 | db BossZombieCaterpillarAttackframelistblock, BossZombieCaterpillarAttackspritedatablock

;Dying Part1
BossZombieCaterpillarAttack111:   dw ZombieCaterpillarDyingPart1frame000 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack112:   dw ZombieCaterpillarDyingPart1frame001 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack113:   dw ZombieCaterpillarDyingPart1frame002 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack114:   dw ZombieCaterpillarDyingPart1frame003 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack115:   dw ZombieCaterpillarDyingPart1frame004 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack116:   dw ZombieCaterpillarDyingPart1frame005 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack117:   dw ZombieCaterpillarDyingPart1frame006 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack118:   dw ZombieCaterpillarDyingPart1frame007 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack119:   dw ZombieCaterpillarDyingPart1frame008 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack120:   dw ZombieCaterpillarDyingPart1frame009 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack121:   dw ZombieCaterpillarDyingPart1frame010 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack122:   dw ZombieCaterpillarDyingPart1frame011 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack123:   dw ZombieCaterpillarDyingPart1frame012 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack124:   dw ZombieCaterpillarDyingPart1frame013 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack125:   dw ZombieCaterpillarDyingPart1frame014 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack126:   dw ZombieCaterpillarDyingPart1frame015 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack127:   dw ZombieCaterpillarDyingPart1frame016 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack128:   dw ZombieCaterpillarDyingPart1frame017 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack129:   dw ZombieCaterpillarDyingPart1frame018 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack130:   dw ZombieCaterpillarDyingPart1frame019 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack131:   dw ZombieCaterpillarDyingPart1frame020 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack132:   dw ZombieCaterpillarDyingPart1frame021 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack133:   dw ZombieCaterpillarDyingPart1frame021 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack134:   dw ZombieCaterpillarDyingPart1frame022 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack135:   dw ZombieCaterpillarDyingPart1frame023 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack136:   dw ZombieCaterpillarDyingPart1frame023 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack137:   dw ZombieCaterpillarDyingPart1frame024 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack138:   dw ZombieCaterpillarDyingPart1frame025 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack139:   dw ZombieCaterpillarDyingPart1frame025 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack140:   dw ZombieCaterpillarDyingPart1frame026 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack141:   dw ZombieCaterpillarDyingPart1frame027 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack142:   dw ZombieCaterpillarDyingPart1frame027 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack143:   dw ZombieCaterpillarDyingPart1frame028 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack144:   dw ZombieCaterpillarDyingPart1frame029 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack145:   dw ZombieCaterpillarDyingPart1frame029 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack146:   dw ZombieCaterpillarDyingPart1frame030 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack147:   dw ZombieCaterpillarDyingPart1frame031 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack148:   dw ZombieCaterpillarDyingPart1frame031 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack149:   dw ZombieCaterpillarDyingPart1frame032 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack150:   dw ZombieCaterpillarDyingPart1frame033 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack151:   dw ZombieCaterpillarDyingPart1frame034 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack152:   dw ZombieCaterpillarDyingPart1frame035 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

BossZombieCaterpillarAttack153:   dw ZombieCaterpillarDyingPart1frame036 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack154:   dw ZombieCaterpillarDyingPart1frame037 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock
BossZombieCaterpillarAttack155:   dw ZombieCaterpillarDyingPart1frame038 | db BossZombieCaterpillarDyingPart1framelistblock, BossZombieCaterpillarDyingPart1spritedatablock

;Dying Part2
BossZombieCaterpillarAttack156:   dw ZombieCaterpillarDyingPart2frame000 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack157:   dw ZombieCaterpillarDyingPart2frame001 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack158:   dw ZombieCaterpillarDyingPart2frame002 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack159:   dw ZombieCaterpillarDyingPart2frame003 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack160:   dw ZombieCaterpillarDyingPart2frame004 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack161:   dw ZombieCaterpillarDyingPart2frame005 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack162:   dw ZombieCaterpillarDyingPart2frame006 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack163:   dw ZombieCaterpillarDyingPart2frame007 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack164:   dw ZombieCaterpillarDyingPart2frame008 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack165:   dw ZombieCaterpillarDyingPart2frame009 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack166:   dw ZombieCaterpillarDyingPart2frame010 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack167:   dw ZombieCaterpillarDyingPart2frame011 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack168:   dw ZombieCaterpillarDyingPart2frame012 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack169:   dw ZombieCaterpillarDyingPart2frame013 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack170:   dw ZombieCaterpillarDyingPart2frame014 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack171:   dw ZombieCaterpillarDyingPart2frame015 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack172:   dw ZombieCaterpillarDyingPart2frame016 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack173:   dw ZombieCaterpillarDyingPart2frame017 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack174:   dw ZombieCaterpillarDyingPart2frame018 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack175:   dw ZombieCaterpillarDyingPart2frame019 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack176:   dw ZombieCaterpillarDyingPart2frame020 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack177:   dw ZombieCaterpillarDyingPart2frame021 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack178:   dw ZombieCaterpillarDyingPart2frame022 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack179:   dw ZombieCaterpillarDyingPart2frame023 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock

BossZombieCaterpillarAttack180:   dw ZombieCaterpillarDyingPart2frame024 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack181:   dw ZombieCaterpillarDyingPart2frame024 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock
BossZombieCaterpillarAttack182:   dw ZombieCaterpillarDyingPart2frame025 | db BossZombieCaterpillarDyingPart2framelistblock, BossZombieCaterpillarDyingPart2spritedatablock



BossAreaZombieCaterpillarPalette:
;nnnn  incbin "..\grapx\tilesheets\sBossAreaZombieCaterpillarPalette.PL" ;file palette 
  incbin "..\grapx\tilesheets\sBossAreaZombieCaterpillarDarkerPalette.PL" ;file palette 

BossZombieCaterpillar:
;v1-1=cles x at start of dive  
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=timer until attack

;  ld    a,(ix+enemies_and_objects.y)        ;y object
;  ld    (Object1y),a
;  ld    a,(ix+enemies_and_objects.x)        ;x object
;  ld    (Object1x),a	

  ld    hl,BossAreaZombieCaterpillarPalette
  call  Setpalette	

  call  CheckPlayerHitByZombieCaterpillar   ;Check if player gets hit by boss
  ;Check if boss gets hit by player
  call  ZombieCaterpillarCheckIfHit         ;call gets popped if hit. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
  call  ZombieCaterpillarCheckIfDead        ;Check if boss is dead, and if so set dying phase
  
  call  .HandlePhase                        ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,BossZombieCaterpillarIdle00
  jp    PutSf2Object3Frames                 ;CHANGES IX - puts object in 3 frames, Top, MIdle and then Bottom

  .HandlePhase:                            ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(HugeObjectFrame)
  cp    2
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  or    a
  jp    z,BossZombieCaterpillarAttack       ;0=attack
  dec   a
  jp    z,BossZombieCaterpillarIdle         ;1=Idle
  dec   a
  jp    z,BossZombieCaterpillarDiving       ;2=diving underground
  dec   a
  jp    z,BossZombieCaterpillarMoving       ;3=moving underground towards player
  dec   a
  jp    z,BossZombieCaterpillarHit          ;4=hit
  dec   a
  jp    z,BossZombieCaterpillarDead         ;5=dead
  dec   a
  jp    z,BossBlendingIntoBackgroundOnDeath ;6=blending into background (MovementPatternsFixedPage1.asm) in: v9=01
  ret

  BossZombieCaterpillarDead:
  ld    a,(Bossframecounter)
  rrca
  ret   c  
    
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,3
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    180                                 ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   c
  ld    (ix+enemies_and_objects.v8),6       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead, 6=blending into background)
  ld    (ix+enemies_and_objects.v9),011     ;v9=timer until next phase  
  ret  
    
  BossZombieCaterpillarHit:
  ld    a,(Bossframecounter)
  rrca
  ret   c  
    
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,3
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    111                                 ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   nz
  ld    (ix+enemies_and_objects.v7),18      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ret  
  
  BossZombieCaterpillarMoving:              ;moving underground towards player
  ld    b,6
  .loop:
  ld    a,(ix+enemies_and_objects.v1-1)     ;v1-1=cles x at start of dive  
  cp    (ix+enemies_and_objects.x)          ;x
  jr    z,.GoAttack
  jr    c,.Moveleft
  .MoveRight:
  inc   (ix+enemies_and_objects.x)          ;x
  djnz  .loop
  ret
  .MoveLeft:
  dec   (ix+enemies_and_objects.x)          ;x
  djnz  .loop
  ret
  .GoAttack:
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ld    (ix+enemies_and_objects.v7),54      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ;let the timer until attack depend on it's remaining health
  ld    a,(ix+enemies_and_objects.life)
  add   a,a
  add   a,a                                 ;*4
;  add   a,a                                 ;*8
  ld    (ix+enemies_and_objects.v9),a       ;v9=timer until attack
  ret
  
  BossZombieCaterpillarDiving:
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,3
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    54                                  ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   nz
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)

  ;set x where to attack
  ld    a,(ClesX)
  cp    54
  jr    nc,.biggerThan54
  ld    a,54
  .biggerThan54:  
  cp    220
  jr    c,.SmallerThan220
  ld    a,220
  .SmallerThan220:
  ld    (ix+enemies_and_objects.v1-1),a     ;v1-1=cles x at start of dive  
  ret  
  
  BossZombieCaterpillarIdle:
  ld    a,(Bossframecounter)
  rrca
  ret   c  

  call  .animate

  dec   (ix+enemies_and_objects.v9)         ;v9=timer until attack
  ret   nz
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ld    (ix+enemies_and_objects.v7),18      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret
  
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,3
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    18                                  ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   nz
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret  
  
  BossZombieCaterpillarAttack:
  ld    a,(Bossframecounter)
  rrca
  ret   c  

  xor   a
  ld    (freezecontrols?),a  

  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,3
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    96                                  ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   nz
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret  

ZombieCaterpillarCheckIfHit:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  cp    2
  ret   z
  cp    3
  ret   z
  cp    4
  ret   z
  cp    5
  ret   nc
  or    a
  jr    nz,.EndCheckPossibleToBeHit
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    54
  ret   c  
  .EndCheckPossibleToBeHit:

  ld    b,-40
  call  CheckPlayerPunchesBossWithYOffset   ;Check if player hit's enemy. in b=Y offset
  
 ; call  CheckPlayerPunchesBoss              ;Check if player hit's enemy
  
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit                ;Check if Boss is hit this very frame
  ret   nz

  pop   af                                  ;pop call  

  ld    (ix+enemies_and_objects.v7),93      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ret

ZombieCaterpillarCheckIfDead:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  cp    5
  ret   nc                                   ;don't check if boss is already dead

  ld    a,(ix+enemies_and_objects.life)
  dec   a
  ret   nz
;  call  ResetV1andV2  
  ld    (ix+enemies_and_objects.v8),5       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  ld    (ix+enemies_and_objects.v7),111     ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret

 
CheckPlayerHitByZombieCaterpillar:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  cp    3
  ret   nc                                  ;don't check for collision when boss is hit or dying or moving underground towards player

  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    54
  jr    nc,.Gocheck                         ;do check for collision when boss is attacking
  cp    18+18
  ret   nc                                  ;don't check for collision when boss has dove underground

  .Gocheck:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  or    a
  jr    nz,.EndCheckPossibleToBeHit
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    54+18
  ret   c  
  jr    nz,.EndCheckPossibleToBeHit
  ld    a,-50                               ;add to sy
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,54                               ;reduction to hitbox sx (left side)
  jp    CollisionEnemyPlayer.ObjectEntry

  .EndCheckPossibleToBeHit:
  ld    a,-50                               ;add to sy
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,30                               ;reduction to hitbox sx (left side)
  jp    CollisionEnemyPlayer.ObjectEntry
  





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

;  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=diamand idle, 1=freeze player flash screen, 2=diamond fading away, 3=close door, 4=stop restoring background)
;  cp    4
;  call  nz,restoreBackgroundObject1

  ;snap to sprite frame
  ld    bc,AltarGraphics00top

  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameAltar

  jp    PutSF2Object ;CHANGES IX 
;  ret

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
  and   7
  ret   nz
  ld    hl,.PutDoorInPage3                   ;put the door now also in page 3, so no background corruption can occur
  call  DoCopy
  ld    (ix+enemies_and_objects.Alive?),0
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),0  
  ld    (ix-(1*lenghtenemytable)+enemies_and_objects.Alive?),2  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,%0000 1000                        ;turn around player, facing right
	ld		(Controls),a
  ret

  .PutDoorInPage3:
	db    0,0,8*12,1
	db    0,0,8*12,3
	db    32,0,56,0
	db    0,0,$d0    

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
;  ld    a,(enemies_and_objects+enemies_and_objects.v7)
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

;  ld    a,(ix-(1*lenghtenemytable)+enemies_and_objects.v8)
;  cp    4
;  call  nz,restoreBackgroundObject2
  
  ;snap to sprite frame
  ld    bc,AltarGraphics00bottom
  ld    a,(ix-(1*lenghtenemytable)+enemies_and_objects.v7)
  call  SetFrameAltar
  call  PutSF2Object2 ;CHANGES IX 
  jp    switchpageSF2Engine



BossDemonBullet:
;v1=
;v2=Phase ( )
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Bullet Movement
;v8= 
  call  .HandlePhase                        ;(0=Hovering Towards player, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
;  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
	ld		a,DemonBossBulletblock              ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
  .HandlePhase:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=Bullet Movement
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  add   a,a                                 ;*8
  ld    hl,BulletMovementTable1
  ld    d,0
  ld    e,a
  add   hl,de
  ex    de,hl
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
  call  CheckOutOfMapSf2Engine                       ;remove sprite from play when leaving the map

  ;animate
  ld    a,(framecounter)
  and   15
  cp    4
  ld    hl,DemonBossBullet1_Char
  ret   c
  cp    8
  ld    hl,DemonBossBullet2_Char
  ret   c
  cp    12
  ld    hl,DemonBossBullet3_Char
  ret   c
  ld    hl,DemonBossBullet4_Char
  ret

BulletMovementTable1:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,-1,+2,  1,-1,+1
  db  128,0
BulletMovementTable2:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,-1,+2,  1,-0,+1
  db  128,0
BulletMovementTable3:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,-0,+2,  1,-1,+1
  db  128,0
BulletMovementTable4:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,-0,+2,  1,-0,+1
  db  128,0
BulletMovementTable5:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,-0,+2,  1,+1,+1
  db  128,0
BulletMovementTable6:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,+1,+2,  1,+0,+1
  db  128,0
BulletMovementTable7:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,+1,+2,  1,+1,+1
  db  128,0
BulletMovementTable8:  ;repeating steps(128 = end table/repeat), move y, move x
  db  2,+1,+2,  1,+2,+1
  db  128,0



;v1-2=backup v8 phase
;v1-1=backup v7 sprite frame
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=Bullet Movement
;v7=sprite frame
;v8=phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
;v9=timer until next phase
BossDemon:
  call  CheckPlayerHitByDemon                ;Check if player gets hit by boss
  call  BossDemonCheckIfHit                  ;Check if boss is hit, and if so set being hit phase
  ld    a,(HugeObjectFrame)
  cp    7-1                                   ;only handle phase when all 7 slices have been put
  call  z,.HandlePhase                        ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  call  .CheckBossDead                        ; check if boss is already dead. If so, just permanently show last frame. IF we just entered the room (then boss is in Idle, then ALSO set x to 94)
  ld    de,BossDemonIdle_0
  call  SetObjectXY                           ;non moving objects start at (0,0). Use this routine to set your own coordinates
  jp    PutSf2Object7Frames                   ;CHANGES IX - puts object in 7 frames

  .CheckBossDead:
  ;now we check if boss is already dead. If so, just permanently show last frame. IF we just entered the room (then boss is in Idle, then ALSO set x to 94)
  ld    a,(BossDead?)                       ;bit 0=demon, bit 1=voodoo wasp, bit 2=zombie caterpillar, bit 3=ice goat
  bit   0,a
  ret    z
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  or    a
  jr    nz,.EndCheckBossIdle
  ld    (ix+enemies_and_objects.x),94      ;boss x
  .EndCheckBossIdle:               
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameDeath+DemonTotalFramesDeath-1       ;v7=sprite frame
  ret

  .HandlePhase:
  call  BossDemonCheckIfDead

  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)         ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  or    a
  jp    z,BossDemonIdle
  dec   a
  jp    z,BossDemonWalking
  dec   a
  jp    z,BossDemonCleaveAttack
  dec   a
  jp    z,BossDemonHit
  dec   a
  jp    z,BossDemonDead
  dec   a
  jp    z,BossDemonShoot

  BossDemonDead:
  ;animate
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  cp    DemonStartingFrameDeath+DemonTotalFramesDeath
  ret   nz
  ld    a,(BossDead?)                       ;bit 0=demon, bit 1=voodoo wasp, bit 2=zombie caterpillar, bit 3=ice goat
  set   0,a
  ld    (BossDead?),a                       ;bit 0=demon, bit 1=voodoo wasp, bit 2=zombie caterpillar, bit 3=ice goat
  ret

  BossDemonCheckIfDead:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  cp    4
  ret   z                                   ;don't check if already dead

  ld    a,(ix+enemies_and_objects.life)
  dec   a
  ret   nz
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameDeath-1       ;v7=sprite frame
  ld    bc,SFX_bossdemondead
  jp    RePlayerSFX_PlayCh2

  BossDemonShoot:
  push  ix
  call  .HandleShoot
  pop   ix
  ret

  .HandleShoot:
  ;animate
  ld    b,DemonStartingFrameCasting
  ld    c,DemonStartingFrameCasting+DemonTotalFramesCasting
  call  BossDemonAnimate

  ret   nz                                  ;when the animation loops we shoot

  ld    a,(ix+enemies_and_objects.x)        ;store boss x
  add   a,58
  ld    b,a
  ld    a,(ix+enemies_and_objects.y)        ;store boss y
  add   a,68
  ld    c,a
  inc   (ix+enemies_and_objects.v6)         ;v6=Bullet Movement
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Bullet Movement
  cp    8                                   ;we shoot 8 bullets in 8 different directions
  jp    z,SetDemonIdle

  ld    de,lenghtenemytable
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptyObjectFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptyObjectFound
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  ret   nz

  .EmptyObjectFound:
  ld    (ix+enemies_and_objects.v7),a       ;v7=Bullet Movement
  ld    (ix+enemies_and_objects.Alive?),-1
  ld    (ix+enemies_and_objects.x),b        ;boss x
  ld    (ix+enemies_and_objects.x+1),0      ;boss x
  ld    (ix+enemies_and_objects.y),c        ;boss y
  ld    bc,SFX_bossdemonshoot
  jp    RePlayerSFX_PlayCh2

CheckPlayerHitByDemon:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  cp    4
  ret   z                                   ;don't check if boss is dead
  cp    2
  jr    z,.CleaveAttack

  .CheckBody:                               ;check if player is hit by body
  ld    (ix+enemies_and_objects.nx),60      ;nx
  ld    (ix+enemies_and_objects.ny),080     ;ny

  ld    a,(CollisionEnemyPlayer.SelfModifyingCodeCollisionSY)
  push  af

  ld    a,-60
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,30                               ;reduction to hitbox sx (left side)
  call  CollisionEnemyPlayer.ObjectEntry

  pop   af
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ret

  .CleaveAttack:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    DemonStartingFrameCleave+8
  jr    nz,.CheckBody

  ;check if player is hit by sword
  ld    (ix+enemies_and_objects.nx),60+90      ;nx
  ld    (ix+enemies_and_objects.ny),080     ;ny

  ld    a,(CollisionEnemyPlayer.SelfModifyingCodeCollisionSY)
  push  af

  ld    a,-80
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,30                               ;reduction to hitbox sx (left side)
  call  CollisionEnemyPlayer.ObjectEntry

  pop   af
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ret

  BossDemonCleaveAttack:
  ;animate
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame

  cp    DemonStartingFrameCleave+9
  jr    z,.ShakeScreen
  cp    DemonStartingFrameCleave+DemonTotalFramesCleave
  ret   nz
  jp    SetDemonIdle

  .ShakeScreen:
  ld    a,20
  ld    (ShakeScreen?),a
  ld    bc,SFX_bossdemoncleaveattack
  jp    RePlayerSFX_PlayCh2

  BossDemonWalking:
  ;animate
  ld    b,DemonStartingFrameWalk
  ld    c,DemonStartingFrameWalk+DemonTotalFramesWalk
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  call  z,BossDemonAnimate
  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  call  nz,BossDemonAnimateInReverse

  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    (ix+enemies_and_objects.x),a        ;x

  cp    100
  jr    z,SetDemonIdle
  cp    8*06
  ret   nz

  SetDemonIdle:
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameIdle   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase
  ret

  BossDemonHit:
  ;animate
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  cp    DemonStartingFrameHit+DemonTotalFramesHit
  ret   nz

  ;when the hit animation is finished, restore v7 and v8 as they were, to continue with previous phase
  ld    a,(ix+enemies_and_objects.v1-1)     ;backup v7=sprite frame
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ld    a,(ix+enemies_and_objects.v1-2)     ;backup v8 phase
  ld    (ix+enemies_and_objects.v8),a       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)

  cp    2                                   ;cleave attack ?
  jr    z,.BossWasAttackingCleave

  ;after being hit, there is a 50% chance that boss will cleave attack (even if NOT in range)
  ld    a,r
  rrca
  jp    c,.SetCleaveAttack  

  ;check if player is within cleave range, if so, boss will cleave attack
  ld    b,80                                ;b-> x distance
  ld    c,120                               ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  jr    nc,.OutOfCleaveRange

  .SetCleaveAttack:
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameCleave-1   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ret  

  .OutOfCleaveRange:                        ;when boss is hit, but out of cleave range, boss will shoot
  ;TO DO - the lower the Demon's health, the bigger the chance that he will shoot here
  ld    a,r
  rrca
  jp    c,SetDemonIdle

  ld    (ix+enemies_and_objects.v7),DemonStartingFrameCasting-1   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),5       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v6),-1      ;v6=Bullet Movement
  ret

  .BossWasAttackingCleave:                  ;before boss was hit, he was attacking with sword. If sword already landed on the floor, go to idle
  ld    a,(ix+enemies_and_objects.v7)
  cp    DemonStartingFrameCleave+8   ;v7=sprite frame 
  ret   c
  jp    SetDemonIdle

  BossDemonIdle:
  ;animate
  ld    b,DemonStartingFrameIdle
  ld    c,DemonStartingFrameIdle+DemonTotalFramesIdle
  call  BossDemonAnimate

  dec   (ix+enemies_and_objects.v9)         ;v9=timer until next phase
  ret   nz

  ld    a,r
  rrca
  jp    c,.SetDemonCleaveOrShoot

  ld    (ix+enemies_and_objects.v7),DemonStartingFrameWalk   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase

  ;set movement direction
  ld    (ix+enemies_and_objects.v4),+2      ;v4=Horizontal Movement
  ld    a,(ix+enemies_and_objects.x)        ;x
  cp    74
  ret   c
  ld    (ix+enemies_and_objects.v4),-2      ;v4=Horizontal Movement
  ret

  .SetDemonCleaveOrShoot:                   ;after coming out of idle, demon has a 50% chance to cleave (when player near) or shoot (when player far)
  ;check if player is within cleave range, if so, boss will cleave attack
  ld    b,120                                ;b-> x distance
  ld    c,120                               ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  jr    nc,.OutOfCleaveRange

  ld    (ix+enemies_and_objects.v7),DemonStartingFrameCleave-1   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ret  

  .OutOfCleaveRange:                        ;when boss is hit, but out of cleave range, boss will shoot
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameCasting-1   ;v7=sprite frame 
  ld    (ix+enemies_and_objects.v8),5       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v6),-1      ;v6=Bullet Movement
  ret

  BossDemonAmountFramesUnableToBeHitAfterBeingHit:  equ 14 ;09
  BossDemonCheckIfHit:
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit                ;Check if Boss was hit previous frame
  jr    z,.JustHit

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase
  cp    4
  ret   z                                   ;don't check if boss is dead
  cp    3
  ret   z                                   ;don't check if boss is hit
  cp    2
  jr    nz,.GoCheck                         ;don't check if boss is in the middle of cleave attack (when sword hits the ground)
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    DemonStartingFrameCleave+8
  ret   z
  .GoCheck:
  ld    a,(ix+enemies_and_objects.x)        ;x
  sub   a,16
  ld    (ix+enemies_and_objects.x),a        ;x
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,60
  ld    (ix+enemies_and_objects.y),a        ;y
  call  CheckPlayerPunchesEnemy             ;Check if player hits enemy
  ld    a,(ix+enemies_and_objects.y)        ;y
  sub   a,60
  ld    (ix+enemies_and_objects.y),a        ;y
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,16
  ld    (ix+enemies_and_objects.x),a        ;x
  ret

  .JustHit:
  ld    a,(HugeObjectFrame)
  cp    7-1                                 ;only handle phase when all 7 slices have been put
  ret   nz                                  ;wait for all 7 parts of the boss to be build up

  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v1-1),a     ;backup v7=sprite frame
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    (ix+enemies_and_objects.v1-2),a     ;backup v7=sprite frame

  dec   (ix+enemies_and_objects.hit?)
  ld    (ix+enemies_and_objects.hit?),BossDemonAmountFramesUnableToBeHitAfterBeingHit
  ld    (ix+enemies_and_objects.v7),DemonStartingFrameHit-1   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=idle, 1=walking, 2=cleave attack, 3=hit, 4=dead, 5=shoot)
  ld    bc,SFX_bossdemonbeinghit
  jp    RePlayerSFX_PlayCh2

  BossDemonAnimate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  inc   a
  cp    c                                   ;c=ending frame
  jr    nz,.notzero
  ld    a,b                                 ;b=starting frame
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

  BossDemonAnimateInReverse:
  dec   b
  dec   c

  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  dec   a
  cp    b                                   ;c=ending frame
  jr    nz,.notzero
  ld    a,c                                 ;b=starting frame
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

DemonStartingFrameIdle:   equ 00
DemonTotalFramesIdle:     equ (BossDemonWalk_0-BossDemonIdle_0)/4
;sprite 0-5 (7 slices)
BossDemonIdle_0:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_0_0
BossDemonIdle_1:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_1_0
BossDemonIdle_2:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_2_0
BossDemonIdle_3:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_3_0
BossDemonIdle_4:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_4_0
BossDemonIdle_5:
  db    BossDemonIdleNewframelistblock, BossDemonIdleNewspritedatablock | dw    BossDemonIdle_5_0

DemonStartingFrameWalk:   equ DemonStartingFrameIdle+DemonTotalFramesIdle
DemonTotalFramesWalk:     equ (BossDemonHit_0-BossDemonWalk_0)/4
;sprite 0-11 (7 slices)
BossDemonWalk_0:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_0_0
BossDemonWalk_1:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_1_0
BossDemonWalk_2:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_2_0
BossDemonWalk_3:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_3_0
BossDemonWalk_4:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_4_0
BossDemonWalk_5:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_5_0
BossDemonWalk_6:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_6_0
BossDemonWalk_7:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_7_0
BossDemonWalk_8:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_8_0
BossDemonWalk_9:
  db    BossDemonWalkNewframelistblock, BossDemonWalkNewspritedatablock | dw    BossDemonWalk_9_0

DemonStartingFrameHit:    equ DemonStartingFrameWalk+DemonTotalFramesWalk
DemonTotalFramesHit:      equ (BossDemonCleave_0-BossDemonHit_0)/4
;sprite 0-4 (7 slices)
BossDemonHit_0:
  db    BossDemonHitNewframelistblock, BossDemonHitNewspritedatablock | dw    BossDemonHit_0_0
BossDemonHit_1:
  db    BossDemonHitNewframelistblock, BossDemonHitNewspritedatablock | dw    BossDemonHit_1_0
BossDemonHit_2:
  db    BossDemonHitNewframelistblock, BossDemonHitNewspritedatablock | dw    BossDemonHit_2_0
BossDemonHit_3:
  db    BossDemonHitNewframelistblock, BossDemonHitNewspritedatablock | dw    BossDemonHit_3_0
BossDemonHit_4:
  db    BossDemonHitNewframelistblock, BossDemonHitNewspritedatablock | dw    BossDemonHit_4_0

DemonStartingFrameCleave:    equ DemonStartingFrameHit+DemonTotalFramesHit
DemonTotalFramesCleave:      equ (BossDemonCasting_0-BossDemonCleave_0)/4
BossDemonCleave_0:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_0_0
BossDemonCleave_1:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_1_0
BossDemonCleave_2:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_2_0
BossDemonCleave_3:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_3_0
BossDemonCleave_4:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_4_0
BossDemonCleave_5:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_5_0
BossDemonCleave_6:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_6_0
BossDemonCleave_7:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_7_0
BossDemonCleave_8:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_8_0
BossDemonCleave_9:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_9_0
BossDemonCleave_10:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_10_0
BossDemonCleave_11:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_11_0
BossDemonCleave_12:
  db    BossDemonCleaveframelistblock, BossDemonCleavespritedatablock | dw    BossDemonCleave_12_0

DemonStartingFrameCasting:   equ DemonStartingFrameCleave+DemonTotalFramesCleave
DemonTotalFramesCasting:     equ (BossDemonDeath_0-BossDemonCasting_0)/4
;sprite 0-11 (7 slices)
BossDemonCasting_0:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_0_0
BossDemonCasting_1:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_1_0
BossDemonCasting_2:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_2_0
BossDemonCasting_3:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_3_0
BossDemonCasting_4:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_4_0
BossDemonCasting_5:
  db    BossDemonCastingNewframelistblock, BossDemonCastingNewspritedatablock | dw    BossDemonCasting_5_0

DemonStartingFrameDeath:        equ DemonStartingFrameCasting+DemonTotalFramesCasting
DemonTotalFramesDeath:          equ (BossDemonEnd-BossDemonDeath_0)/4
;sprite 1-4 (7 slices)
BossDemonDeath_0:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_0_0
BossDemonDeath_1:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_1_0
BossDemonDeath_2:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_2_0
BossDemonDeath_3:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_3_0
BossDemonDeath_4:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_4_0
BossDemonDeath_5:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_5_0
BossDemonDeath_6:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_6_0
BossDemonDeath_7:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_7_0
BossDemonDeath_8:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_8_0
BossDemonDeath_9:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_9_0
BossDemonDeath_10:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_10_0
BossDemonDeath_11:
  db    BossDemonDeath0framelistblock, BossDemonDeath0spritedatablock | dw    BossDemonDeath0_11_0

BossDemonDeath_12:
  db    BossDemonDeath1framelistblock, BossDemonDeath1spritedatablock | dw    BossDemonDeath1_0_0
BossDemonDeath_13:
  db    BossDemonDeath1framelistblock, BossDemonDeath1spritedatablock | dw    BossDemonDeath1_1_0
BossDemonDeath_14:
  db    BossDemonDeath1framelistblock, BossDemonDeath1spritedatablock | dw    BossDemonDeath1_2_0

BossDemonDeath_15:
  db    BossDemonDeath2framelistblock, BossDemonDeath2spritedatablock | dw    BossDemonDeath2_2_0
BossDemonDeath_16:
  db    BossDemonDeath2framelistblock, BossDemonDeath2spritedatablock | dw    BossDemonDeath2_2_0
BossDemonDeath_17:
  db    BossDemonDeath2framelistblock, BossDemonDeath2spritedatablock | dw    BossDemonDeath2_2_0
BossDemonEnd:

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
  ld    e,(ix-(1*lenghtenemytable)+enemies_and_objects.v1)
  ld    hl,HugeSpiderBodyOffsets
  add   hl,de                                 ;use v1=Animation Counter of legs to find y+x offsets body

  ld    a,(ix-(1*lenghtenemytable)+enemies_and_objects.y)
  add   a,(hl)
  ld    (ix+enemies_and_objects.y),a          ;check y legs and set body accordingly
  
  ld    a,(ix-(1*lenghtenemytable)+enemies_and_objects.x)
  inc   hl
  add   a,(hl)
  ld    (ix+enemies_and_objects.x),a          ;check x legs and set body accordingly

  ;check if spider died
  ld    a,(ix-(1*lenghtenemytable)+enemies_and_objects.life)
  or    a
  jp    nz,VramObjectsTransparantCopies2
  ld    (ix+enemies_and_objects.Alive?),0
;  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  ret
  
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

  
AreaSign:                                 ;Displays the name of the world in screen when entering that world 
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=put line in all 3 pages
;v7=step
;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)
;v9=wait timer / bottom of area sign
  .HandlePhase:  
  ld    a,(ix+enemies_and_objects.v8)     ;v8=Phase (0=build up area sign line by line, 1=wait, 2=remove area sign line by line)
  or    a
  jr    z,PutAreaSignLine                 ;0=show area sign
  dec   a
  jr    z,WaitUntilRemoveAreaSign         ;1=wait
  RemoveAreaSign:                         ;2=remove area sign
  ld    a,2                               ;copy from page 2 (where the area sign is NOT displayed)
  ld    (FreeToUseFastCopy+sPage),a

  ld    a,(ix+enemies_and_objects.v7)     ;v7=step
  dec   a
  ld    (ix+enemies_and_objects.v7),a     ;v7=step
  jr    nz,.EndCheckEndPhase2
  ld    (ix+enemies_and_objects.alive?),0 ;end   
  ret
  .EndCheckEndPhase2:

  ;area sign height=48 pixels. area sign starts from the middle and gets build up 1 line per frame (up AND down)
  add   a,23
  add   a,(ix+enemies_and_objects.y)
  call  PutAreaSignLine.GoPutLine         ;put line going from the center to the bottom

  ;put line going from the center to the top
  ld    a,(ix+enemies_and_objects.y)
  add   a,24
  sub   a,(ix+enemies_and_objects.v7)     ;v7=step
  jp    PutAreaSignLine.GoPutLine         ;put line going from the center to the bottom

  WaitUntilRemoveAreaSign:
  ld    a,(ix+enemies_and_objects.v7)     ;v7=step
  inc   a
  ld    (ix+enemies_and_objects.v7),a     ;v7=step
  cp    140
  ret   nz
  ld    (ix+enemies_and_objects.v7),25    ;v7=step
  ld    (ix+enemies_and_objects.v8),2     ;v8=Phase (0=build up area sign line by line, 1=wait, 2=remove area sign line by line)
  ret

  PutAreaSignLine:
  ld    a,3                               ;copy from page 3 (where the area sign is displayed in total)
  ld    (FreeToUseFastCopy+sPage),a

  ld    a,(ix+enemies_and_objects.v7)     ;v7=step
  inc   a
  ld    (ix+enemies_and_objects.v7),a     ;v7=step
  cp    24+1
  jr    nz,.EndCheckEndPhase0
  ld    (ix+enemies_and_objects.v8),1     ;v8=Phase (0=build up area sign line by line, 1=wait, 2=remove area sign line by line)
  ret
  .EndCheckEndPhase0:

  ;area sign height=48 pixels. area sign starts from the middle and gets build up 1 line per frame (up AND down)
  add   a,23
  add   a,(ix+enemies_and_objects.y)
  call  .GoPutLine                        ;put line going from the center to the bottom

  ;put line going from the center to the top
  ld    a,(ix+enemies_and_objects.y)
  add   a,24
  sub   a,(ix+enemies_and_objects.v7)     ;v7=step

  .GoPutLine:
  ld    (FreeToUseFastCopy+sy),a
  ld    (FreeToUseFastCopy+dy),a

  ld    a,(ix+enemies_and_objects.x)
  ld    (FreeToUseFastCopy+sx),a
  ld    (FreeToUseFastCopy+dx),a
  xor   a                                 
  ;copy to page 0 (this page is permanently active)
  ld    (FreeToUseFastCopy+dPage),a  
  ld    a,200
  ld    (FreeToUseFastCopy+nx),a
  ld    a,1
  ld    (FreeToUseFastCopy+ny),a
  ld    hl,FreeToUseFastCopy
  jp    DoCopy

AppBlocksHandler:
;v1 = activate block timer
;v2 = activate block table step pointer
;v3 = skip first time closing block
  ld    a,(AmountOfAppearingBlocks)
  dec   a
  ld    b,255
  jr    z,.AmountOfBlocksFound
  dec   a
  ld    b,127
  jr    z,.AmountOfBlocksFound
  ld    b,63  
  .AmountOfBlocksFound:
  
  ld    a,(ix+enemies_and_objects.v1)     ;v1 = activate block timer
  inc   a
  and   b
  ld    (ix+enemies_and_objects.v1),a     ;v1 = activate block timer
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v2)     ;v2 = activate block table step pointer
  add   a,3
  ld    (ix+enemies_and_objects.v2),a     ;v2 = activate block table step pointer
  
  ld    hl,AppearingBlocksTable-3
  ld    d,0
  ld    e,a
  add   hl,de

  ld    a,(AmountOfAppearingBlocks)
  cp    3
  jr    c,.EndSkipFirstTimeCloseBlock
  ld    a,(ix+enemies_and_objects.v3)     ;v3 = skip first time closing block
  inc   a
  cp    3
  jp    z,.EndSkipFirstTimeCloseBlock
  ld    (ix+enemies_and_objects.v3),a     ;v3 = skip first time closing block
  cp    2
  ret   z
  .EndSkipFirstTimeCloseBlock:
  
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

;AppearingBlocksTable: ;dy, dx, appear(1)/dissapear(0)      255 = end
;  db    15*8,18*8,1, 07*8,20*8,0, 15*8,12*8,1, 07*8,26*8,0, 15*8,06*8,1, 15*8,18*8,0, 10*8,09*8,1, 15*8,12*8,0, 10*8,15*8,1, 15*8,06*8,0, 07*8,20*8,1
;  db    10*8,09*8,0, 07*8,26*8,1, 10*8,15*8,0
;  db    255

;  db    15*8,18*8,1, 23*8,18*8,0, 19*8,18*8,1, 15*8,18*8,0, 23*8,18*8,1, 19*8,18*8,0, 255

;  db    15*8,18*8,1, 19*8,18*8,1, 15*8,18*8,0, 19*8,18*8,0, 255

;  db    15*8,18*8,1, 15*8,18*8,0, 255

;  db    15*8,18*8,1, 07*8,20*8,0, 15*8,12*8,1, 07*8,26*8,0, 15*8,06*8,1, 15*8,18*8,0, 10*8,09*8,1, 15*8,12*8,0, 10*8,15*8,1, 15*8,06*8,0, 07*8,20*8,1
;  db    10*8,09*8,0, 07*8,26*8,1, 10*8,15*8,0
;  db    255

;AppearingBlocksTable: ;dy, dx, appear(1)/dissapear(0)      255 = end
;  db    14*8,14*8,1, 14*8,22*8,0, 14*8,16*8,1, 14*8,24*8,0, 14*8,18*8,1, 14*8,14*8,0, 14*8,20*8,1, 14*8,16*8,0, 14*8,22*8,1, 14*8,18*8,0, 14*8,24*8,1, 14*8,20*8,0
;  db    255

  
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
;v8=face left (0) or face right (1)  
;v9=Target Y
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
  cp    (ix+enemies_and_objects.v9)         ;v7=Target Y
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

BigStatueMouthClosedSx: equ 00
BigStatueMouthOpenSx:   equ 28
BigStatueMouth:
;v1=sx software sprite in Vram
;v9=face (3=right, 7=left, 0=random)
;v10=max number
  ld    a,216+000
  ld    (CopyObject+sy),a  
  ld    a,3
  ld    (CopyObject+spage),a


;  ld    (ix+enemies_and_objects.v1),BigStatueMouthOpenSx
;  ld    (ix+enemies_and_objects.v1),BigStatueMouthClosedSx


  call  OnlyPutVramObjectDontEraseFastCopy
  ld    a,1
  ld    (CopyObject+spage),a
  
  ;search for an open slot
  push  ix
  pop   iy
  ld    de,lenghtenemytable

  ld    a,(ix+enemies_and_objects.v10)  ;max number
  dec   a
  jr    z,.MaxNum1
  dec   a
  jr    z,.MaxNum2
  dec   a
  jr    z,.MaxNum3
  dec   a
  jr    z,.MaxNum4
  dec   a
  jr    z,.MaxNum5

  .MaxNum6:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  .MaxNum5:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  .MaxNum4:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  .MaxNum3:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  .MaxNum2:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  .MaxNum1:
  add   ix,de
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  ld    a,(framecounter)
  cp    60
  call  z,.CloseMouth
  ret
  
  .EmptySlotFound:
  ld    a,(framecounter)
  or    a
  call  z,.OpenMouth
  cp    60
  call  z,.CloseMouth
  cp    50
  ret   nz  
  ld    a,(iy+enemies_and_objects.v1)
  cp    BigStatueMouthOpenSx
  ret   nz

  ld    (ix+enemies_and_objects.alive?),-1 

  ld    a,(iy+enemies_and_objects.y)
  add   a,15
  ld    (ix+enemies_and_objects.y),a

  ld    a,(iy+enemies_and_objects.x)
  add   a,20
  ld    (ix+enemies_and_objects.x),a
  
  ld    (ix+enemies_and_objects.x+1),0
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ld    (ix+enemies_and_objects.v2),0       ;v2=Phase (0=walking slow, 1=attacking)
  ld    (ix+enemies_and_objects.v3),0       ;v3=Vertical Movement
  ld    (ix+enemies_and_objects.v4),0       ;v4=Horizontal Movement
  ld    (ix+enemies_and_objects.v5),0       ;v5=repeating steps
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to movement table

  ld    a,(iy+enemies_and_objects.v9)       ;v9=face (3=right, 7=left, 0=random)
  cp    3
  ld    b,+1
  jr    z,.FaceFound
  cp    7
  ld    b,-1
  jr    z,.FaceFound
  ld    a,r
  and   1
  jr    nz,.FaceFoundRandom
  ld    a,-1
  .FaceFoundRandom:
  ld    b,a
  .FaceFound:
  ld    (ix+enemies_and_objects.v8),b       ;v8=face left (-1) or face right (1)  
  ld    hl,CuteMiniBat
  ld    (ix+enemies_and_objects.movementpattern),l
  ld    (ix+enemies_and_objects.movementpattern+1),h
  ld    (ix+enemies_and_objects.nrsprites),72-(02*6)
  ld    (ix+enemies_and_objects.nrspritesSimple),2
  ld    (ix+enemies_and_objects.nrspritesTimes16),2*16
  ld    (ix+enemies_and_objects.life),1
  ret  

.OpenMouth:
  ld    (iy+enemies_and_objects.v1),BigStatueMouthOpenSx
  ret

.CloseMouth:
  ld    (iy+enemies_and_objects.v1),BigStatueMouthClosedSx
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
  jp    nz,VramObjectsTransparantCopies2

  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
  ;activate DrippingOoze in the pool
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),-1
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,4
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.x),a      
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,-25
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.y),a  
;  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  ret
      
  DrippingOozeGrowing:
  call  VramObjectsTransparantCopies2

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
  jp    VramObjectsTransparantCopies2

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
;v2=Active?
;v3=wait timer in case only 1 waterfall
;v4=Waterfall nr

  ld    b,WaterfallMouthYellowOpenSX
  ld    c,WaterfallMouthYellowClosedSX
  ld    d,WaterfallEyesYellowClosedSX
  ld    e,WaterfallEyesYellowOpenSX
  .EntryPointForGreyEyes:

  call  .CheckOpenEyes
  call  .CheckActivateWaterFall
  
  ld    a,216+32 
  ld    (CopyObject+sy),a  

  jp    VramObjectsTransparantCopies2

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
  ld    (ix+(1*lenghtenemytable)+enemies_and_objects.Alive?),1
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
  ld    (ix+enemies_and_objects.v2),0       ;v2=Active?
  
  ld    a,(AmountOfWaterfallsInCurrentRoom)
  inc   a
  ld    b,a
  ld    a,(CurrentActiveWaterfall)
  inc   a
  ld    (CurrentActiveWaterfall),a
  cp    b
  ret   nz
  ld    a,1
  ld    (CurrentActiveWaterfall),a
  ret

  .CheckOpenEyes:
  ld    a,(CurrentActiveWaterfall)
  cp    (ix+enemies_and_objects.v4)       ;v4=Waterfalls nr
  ret   nz

  ld    a,(ix+enemies_and_objects.v2)       ;v2=Active?
  or    a
  ret   nz                                  ;return if already active. Eyes are open when active

  ld    a,(AmountOfWaterfallsInCurrentRoom)
  dec   a
  jr    nz,.EndCheckOnly1Waterfall
  ld    a,(ix+enemies_and_objects.v3)       ;v3=wait timer in case only 1 waterfall
  inc   a
  and   63
  ld    (ix+enemies_and_objects.v3),a       ;v3=wait timer in case only 1 waterfall
  ret   nz
  .EndCheckOnly1Waterfall:

  ld    (ix+enemies_and_objects.v1),e
  ld    (ix+enemies_and_objects.v2),1       ;v2=Active?
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
;v6=Gravity timer
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
  jp    AnimateSprite                       ;uses V1

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

  ld    a,(ix-lenghtenemytable+enemies_and_objects.v4)  ;v4=Horizontal Movement
  or    a
  ld    hl,RightLancelotSwordSword
  ld    a,26                                ;sx
  jp    p,.SetVars
  ld    hl,LeftLancelotSwordSword
  xor   a
  .SetVars:
  ld    (ix+enemies_and_objects.v1),a       ;sx

  ld    a,(ix-lenghtenemytable+enemies_and_objects.v1)  ;v1=Animation Counter
  ld    e,a
  ld    d,0
  add   hl,de

  ld    a,216+32
  ld    (CopyObject+sy),a  

  ld    a,(ix-lenghtenemytable+enemies_and_objects.y)
  add   a,(hl)                              ;add to y
  ld    (ix+enemies_and_objects.y),a

  inc   hl
  ld    d,0
  ld    e,(hl)                              ;add to x
  bit   7,e
  jr    z,.EndNegativeCheck
  dec   d
  .EndNegativeCheck:

  ld    a,(ix-lenghtenemytable+enemies_and_objects.x)
  ld    l,a
  ld    a,(ix-lenghtenemytable+enemies_and_objects.x+1)
  ld    h,a
  add   hl,de
  
  ld    (ix+enemies_and_objects.x),l
  ld    (ix+enemies_and_objects.x+1),h

  ld    a,(ix-lenghtenemytable+enemies_and_objects.life)
  or    a
  jp    nz,VramObjectsTransparantCopies2
  ld    (ix+enemies_and_objects.Alive?),0
;  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  ret


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
;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping)
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

  call  TurnAroundAtScreenEdges

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
  jp    VramObjectsTransparantCopies2

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
  call  VramObjectsTransparantCopies2

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
  ld    (ix+enemies_and_objects.v3),3       ;v3=Vertical Movement
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

HugeBlock:

;  call  BackdropRed
;call .go
;  call  BackdropBlack
;ret

;.go:
;v1-2=box right (16 bit)
;v1-1=box right (16 bit)
;v1=0 normal total block, v1=1 top half, v1=2 bottom half
;v2=framenumber to handle this object on
;v3=y movement
;v4=x movement
;v5=SnapPlayer?
;v6=box left (16 bit)
;v7=box left (16 bit)
;v8=box top
;v9=box bottom

;when putting our first object, increase block frame counter
  ld    a,(ix+enemies_and_objects.v2)         ;v2=framenumber to handle this object on
  or    a
  jr    nz,.EndCheckFirstObject

  ld    a,(AmountOfSF2ObjectsCurrentRoom)
  ld    b,a

  ld    a,(HugeObjectFrame)
  inc   a
  cp    b
  jr    nz,.EndCheckLastFramePassed
  xor   a
  .EndCheckLastFramePassed:
  ld    (HugeObjectFrame),a
  .EndCheckFirstObject:
;/when putting our first object, increase frame counter

;check if this object has to be put this frame. If not, then only check collision with player
  ld    a,(HugeObjectFrame)
  cp    (ix+enemies_and_objects.v2)         ;v2=framenumber to handle this object on
  jp    nz,CheckCollisionObjectPlayer
;/check if this object has to be put this frame. If not, then only check collision with player

  call  .MovePlatForm               
  ld    a,(ix+enemies_and_objects.SnapPlayer?)
  or    a
  call  nz,MovePlayerAlongWithObject
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  RestoreBackgroundForObjectInCurrentFrame
  call  .AnimateHugeBlock

  push  ix
  call  PutSF2ObjectInCurrentFrame ;CHANGES IX   
  pop   ix

  ld    a,(AmountOfSF2ObjectsCurrentRoom)
  dec   a
  cp    (ix+enemies_and_objects.v2)         ;v2=framenumber to handle this object on  
  jp    z,switchpageSF2Engine               ;when last object of this frame is handled, switch page
  ret

  .MovePlatForm:
;  ld    a,(ix+enemies_and_objects.v10)        ;v10=speed
  call  MoveObjectHorizontallyAndVertically
  call  ChangeDirectionWhenOutOfBox
  ld    a,(ix+enemies_and_objects.y)          ;y object
  ld    (Object1y),a
  ld    a,(ix+enemies_and_objects.x)          ;x object
  ld    (Object1x),a
  ret

  .AnimateHugeBlock:
  ld    a,(ix+enemies_and_objects.v1)         ;v1=0 normal total block, v1=1 top half, v1=2 bottom half
  or    a
  ld    hl,.HugeBlockFrame
  jr    z,.HugeBlockVersionFound
  dec   a
  ld    hl,.HugeBlockTopHalfFrame
  jr    z,.HugeBlockVersionFound
  ld    hl,.HugeBlockBottomHalfFrame
  .HugeBlockVersionFound:
  
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

  .HugeBlockFrame:
  dw ryupage0frame000 | db ryuframelistblock, ryuspritedatablock
  .HugeBlockTopHalfFrame:
  dw ryupage0frame001 | db ryuframelistblock, ryuspritedatablock
  .HugeBlockBottomHalfFrame:
  dw ryupage0frame002 | db ryuframelistblock, ryuspritedatablock

RestoreBackgroundForObjectInCurrentFrame:
	ld    a,(HugeObjectFrame)
	or    a
	jp    z,restoreBackgroundObject1
	dec   a
	jp    z,restoreBackgroundObject2
	dec   a
	jp    z,restoreBackgroundObject3
	dec   a
	jp    z,restoreBackgroundObject4
	dec   a
	jp    z,restoreBackgroundObject5
	dec   a
	jp    z,restoreBackgroundObject6
	jp    restoreBackgroundObject7

PutSF2ObjectInCurrentFrame:
  ld    a,(HugeObjectFrame)
  or    a
  jp    z,PutSF2Object
  dec   a
  jp    z,PutSF2Object2
  dec   a
  jp    z,PutSF2Object3
  dec   a
  jp    z,PutSF2Object4
;  dec   a
;  jp    z,restoreBackgroundObject3
  jp    PutSF2Object5


SetObjectXY:                                  ;non moving objects start at (0,0). Use this routine to set your own coordinates
; call  MoveObjectHorizontallyAndVertically
;  call  ChangeDirectionWhenOutOfBox
  ld    a,(ix+enemies_and_objects.y)          ;y object
  ld    (Object1y),a
  ld    a,(ix+enemies_and_objects.x)          ;x object
  ld    (Object1x),a
  ret



WaterfallPalette:
  incbin "..\grapx\tilesheets\Waterfall.tiles.PL"
  
WaterfallScene:
  ld    hl,WaterfallPalette
  call  SetPalette

  ld    (ix+enemies_and_objects.x),70         ;x object
  ld    (ix+enemies_and_objects.y),73         ;y object

  call  SetObjectXY                           ;non moving objects start at (0,0). Use this routine to set your own coordinates
  call  RestoreBackgroundForObjectInCurrentFrame 

;  ld    (ix+enemies_and_objects.v7),0 ;13*5       ;v7=sprite frame

  ld    de,BossDemonIdle_0
  jp    PutSf2Object7Frames                   ;CHANGES IX - puts object in 7 frames



  ld    de,TeleportPart3AnimationFrames
;  ld    de,.EmptyFrames
  jp    PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, MIdle and then Bottom

;  .EmptyFrames:
;  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock
;  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock
;  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock
;  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock
;  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock


;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=already entered?(bit0)/activate ring(bit1)
;v10=unable to enter directly after exiting timer
Teleport:
  call  .CheckCollision                     ;check collision with player - and handle interaction of player with object 
  call  SetObjectXY                           ;non moving objects start at (0,0). Use this routine to set your own coordinates
  call  RestoreBackgroundForObjectInCurrentFrame 
  call  .Animate
  call  .CheckActivateRing
  call  PaletteAnimationTeleport
;  ld    (ix+enemies_and_objects.v7),13*5       ;v7=sprite frame

  ld    de,TeleportPart4AnimationFrames
  bit   0,(ix+enemies_and_objects.v9)       ;v9=already entered?(bit0)/activate ring(bit1)
  jp    nz,PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, MIdle and then Bottom
  ld    de,TeleportPart3AnimationFrames
  jp    PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, MIdle and then Bottom

  .CheckCollision:                          ;hitbox teleport=(120,100)-(150,130)
	ld		hl,(PlayerSpriteStand)
  ld    de,ExitTeleport
  or    a
  sbc   hl,de
  jr    nz,.EndCheckExitingTeleport
  ld    (ix+enemies_and_objects.v10),20     ;v10=unable to enter directly after exiting timer
  ret   z
  .EndCheckExitingTeleport:
  ld    a,(ix+enemies_and_objects.v10)      ;v10=unable to enter directly after exiting timer
  dec   a
  jr    z,.AbleToEnter
  ld    (ix+enemies_and_objects.v10),a      ;v10=unable to enter directly after exiting timer
  ret
  .AbleToEnter:

  bit   0,(ix+enemies_and_objects.v9)       ;v9=already entered?(bit0)/activate ring(bit1)
  ret   nz

  ld    a,(ClesY)
  sub   (ix+enemies_and_objects.y)        ;y portal
  cp    100-16
  ret   c

  ld    a,(ClesY)
  sub   (ix+enemies_and_objects.y)        ;y portal
  cp    130-16
  ret   nc

  ld    h,0
  ld    l,(ix+enemies_and_objects.x)       ;x portal
  ld    de,-16
  add   hl,de
  ld    de,(ClesX)                    ;hl: x player (165)
  or    a
  sbc   hl,de
  ret   nc

  ld    h,0
  ld    l,(ix+enemies_and_objects.x)       ;x portal
  ld    de,-16+30
  add   hl,de
  ld    de,(ClesX)                    ;hl: x player (165)
  or    a
  sbc   hl,de
  ret   c

  set   0,(ix+enemies_and_objects.v9)       ;v9=already entered?(bit0)/activate ring(bit1)

  xor   a
  ld    (PlayerAniCount),a
  ld    a,10                          ;we don't need the first 10 frames in which player floats up only
  ld    (PlayerAniCount+1),a
	ld		hl,EnterTeleport
	ld		(PlayerSpriteStand),hl
  ret

  .CheckActivateRing:
  ld    a,(HugeObjectFrame)
  or    a
  ret   nz

  res   0,(ix+enemies_and_objects.v9)       ;v9=already entered?(bit0)/activate ring(bit1)

	ld		hl,(PlayerSpriteStand)
	ld		de,EnterTeleport
  or    a
  sbc   hl,de
  jr    z,.ActivateRing

	ld		hl,(PlayerSpriteStand)
	ld		de,ExitTeleport
  or    a
  sbc   hl,de
  ret   nz

  .ActivateRing:
  set   0,(ix+enemies_and_objects.v9)       ;v9=already entered?(bit0)/activate ring(bit1)
  ret

  .Animate:
  ld    a,(HugeObjectFrame)
  or    a
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,5
  cp    16*5
  jr    nz,.notzero
  xor   a
  .notzero:  
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

  PaletteAnimationTeleport:
  ;in 3 steps
  ld    a,(framecounter)
  and   31

  cp    10
  ld    hl,.Anim1
  jr    c,.WriteColors

  cp    21
  ld    hl,.Anim2
  jr    c,.WriteColors

  ld    hl,.Anim3
  jr    .WriteColors

  ;in 4 steps
;  ld    a,(framecounter)
;  and   %0001 1000
;  ld    hl,.Anim1
;  jr    z,.WriteColors
;  cp    %0000 1000
;  ld    hl,.Anim2
;  jr    z,.WriteColors
;  cp    %0001 0000
;  ld    hl,.Anim3
;  jr    z,.WriteColors
;  ld    hl,.Anim2
  
  .WriteColors:
	xor		a                         ;start writing to palette color 0
  call  .WriteColor
	ld    a,6                       ;start writing to palette color 6
  call  .WriteColor
	ld    a,8                       ;start writing to palette color 8
  
  .WriteColor:
	di
	out		($99),a
	ld		a,16+128
	out		($99),a  
  
  ld    c,$9a
  outi                            ;red + blue
  outi                            ;green
  ei
  ret


  ;color0                 color 6         colo 8
  .Anim1:
  ;     R*16+B , G
  db    5*16+0,2        ,3*16+0,1        ,3*16+0,1
  .Anim2:
  db    3*16+0,1        ,5*16+0,2        ,3*16+0,1
  .Anim3:
  db    3*16+0,1        ,3*16+0,1        ,5*16+0,2

  TeleportPart4AnimationFrames:
  dw TeleportPart3frame080 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame081 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame082 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame083 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame084 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame085 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame086 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame087 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame088 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame089 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame090 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame091 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame092 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame093 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame094 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame095 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame096 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame097 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame098 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame099 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame100 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame101 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame102 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame103 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame104 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame105 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame106 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame107 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame108 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame109 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame110 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame111 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame112 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame113 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame114 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame115 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame116 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame117 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame118 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame119 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame120 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame121 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame122 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame123 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame124 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame125 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame126 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame127 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame128 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame129 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame130 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame131 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame132 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame133 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame134 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame135 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame136 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame137 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame138 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame139 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame140 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame141 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame142 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame143 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame144 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw ryupage0frame013 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame014 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame015 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame016 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame017 | db ryuframelistblock, ryuspritedatablock

  dw ryupage0frame018 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame019 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame020 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame021 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame022 | db ryuframelistblock, ryuspritedatablock

  dw ryupage0frame023 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame024 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame025 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame026 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame027 | db ryuframelistblock, ryuspritedatablock

  TeleportPart3AnimationFrames:
  dw TeleportPart3frame000 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame001 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame002 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame003 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame004 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame005 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame006 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame007 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame008 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame009 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame010 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame011 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame012 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame013 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame014 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame015 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame016 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame017 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame018 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame019 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame020 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame021 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame022 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame023 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame024 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame025 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame026 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame027 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame028 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame029 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame030 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame031 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame032 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame033 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame034 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame035 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame036 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame037 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame038 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame039 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame040 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame041 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame042 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame043 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame044 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame045 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame046 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame047 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame048 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame049 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame050 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame051 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame052 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame053 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame054 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame055 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame056 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame057 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame058 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame059 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame060 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame061 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame062 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame063 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame064 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame065 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame066 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame067 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame068 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame069 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame070 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame071 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame072 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame073 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame074 | db TeleportPart3framelistblock, TeleportPart3spritedatablock

  dw TeleportPart3frame075 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame076 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame077 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame078 | db TeleportPart3framelistblock, TeleportPart3spritedatablock
  dw TeleportPart3frame079 | db TeleportPart3framelistblock, TeleportPart3spritedatablock




;  TeleportPart2AnimationFrames:
;  dw TeleportPart2frame000 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame001 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame002 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame003 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame004 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame005 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame006 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame007 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame008 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame009 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame010 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame011 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame012 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame013 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame014 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame015 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame016 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame017 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame018 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame019 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame020 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame021 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame022 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame023 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame024 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame025 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame026 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame027 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame028 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame029 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame030 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame031 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame032 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame033 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame034 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame035 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame036 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame037 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame038 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame039 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame040 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame041 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame042 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame043 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame044 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame045 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame046 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame047 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame048 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame049 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame050 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame051 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame052 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame053 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame054 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame055 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame056 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame057 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame058 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame059 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame060 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame061 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame062 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame063 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame064 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame065 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame066 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame067 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame068 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame069 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame070 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame071 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame072 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame073 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame074 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame075 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame076 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame077 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame078 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame079 | db TeleportPart2framelistblock, TeleportPart2spritedatablock











;  TeleportPart1AnimationFrames:
;  dw TeleportPart1frame000 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame001 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame002 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame003 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame004 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame005 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame006 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame007 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame008 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame009 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame010 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame011 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame012 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame013 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame014 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame015 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame016 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame017 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame018 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame019 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame020 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame021 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame022 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame023 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame024 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame025 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame026 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame027 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame028 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame029 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame030 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame031 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame032 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame033 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame034 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame035 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame036 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame037 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame038 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame039 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame040 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame041 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame042 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame043 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame044 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame045 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame046 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame047 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame048 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame049 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame050 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame051 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame052 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame053 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame054 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame055 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame056 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame057 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame058 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame059 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart1frame060 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame061 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame062 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame063 | db TeleportPart1framelistblock, TeleportPart1spritedatablock
;  dw TeleportPart1frame064 | db TeleportPart1framelistblock, TeleportPart1spritedatablock

;  dw TeleportPart2frame080 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame081 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame082 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame083 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame084 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame085 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame086 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame087 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame088 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame089 | db TeleportPart2framelistblock, TeleportPart2spritedatablock

;  dw TeleportPart2frame085 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame086 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame087 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame088 | db TeleportPart2framelistblock, TeleportPart2spritedatablock
;  dw TeleportPart2frame089 | db TeleportPart2framelistblock, TeleportPart2spritedatablock


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
  ld    de,GlassBallMovementTable4
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
;  ld    b,a
;  srl   a
;  add   a,b                                 ;animation step * 3
add a,a
  ld    d,0
  ld    e,a
  add   hl,de
  
  ld    a,(ix+enemies_and_objects.y)        ;y
  and   %0000 1000
  jr    nz,.GoAnimate
;  ld    de,4 * 3
  ld    de,4 * 4
  add   hl,de
  .GoAnimate:
  
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


EmptyFrame:
  dw ryupage0frame012 | db ryuframelistblock, ryuspritedatablock

GlassBalHorizontalAnimation:
  dw ryupage0frame004 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame011 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame010 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame009 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame008 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame007 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame006 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame005 | db ryuframelistblock, ryuspritedatablock
;4 extra for when  y is 16 fold
  dw ryupage0frame004 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame011 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame010 | db ryuframelistblock, ryuspritedatablock
  dw ryupage0frame009  | db ryuframelistblock, ryuspritedatablock





LeftAndRightObjectMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    20,0,1, 20,0,-1, 128
  
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
;v2=Phase (0=walking slow, 1=jumping)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Jump to Which platform ? (1,2 or 3)
;v6=Gravity timer
;v7=Dont Check Land Platform First x Frames
;v8=Has Player Been Hit While on the outer right ladder?

  call  .HandlePlayerFallingOutOfScreenAfterDamaged

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
  
  .HandlePlayerFallingOutOfScreenAfterDamaged:
  bit   0,(ix+enemies_and_objects.v8)       ;v8=Has Player Been Hit While on the outer right ladder?
;  jp    nz,PopulateControls.FreezeControls
  jr    nz,.FreezeControls
  ld    a,(ShakeScreen?)
  or    a
  ret   z

  .CheckPlayerOnRightLadder:
  ld    hl,(ClesX)
  ld    de,275
  sbc   hl,de
  ret   c
  set   0,(ix+enemies_and_objects.v8)       ;v8=Has Player Been Hit?
  jp    CollisionEnemyPlayer.PlayerIsHit
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  .FreezeControls:
	ld		a,(Controls)
  and   %00001100                           ;only able to move right and left
	ld		(Controls),a
	ld		a,(NewPrContr)
  and   %00001100                           ;only able to move right and left
	ld		(NewPrContr),a
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
  jp    DamagePlayerIfNotJumping

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
  add   a,2                                 ;add 2, cuz framecounter starts at 255, in which case huge blob instantly jumps when entering room
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
  jp    nz,VramObjectsTransparantCopies2
  ld    (ix+enemies_and_objects.Alive?),0
;  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  ret

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
  jp    nz,VramObjectsTransparantCopies2

  ld    a,(hl)                              ;add to Y
  add   a,(ix+enemies_and_objects.y)
  ld    (ix+enemies_and_objects.y),a
  jp    VramObjectsTransparantCopies2

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

  ld    a,216
  ld    (CopyObject+sy),a  
  call  VramObjectsTransparantCopies2        ;put object in Vram/screen ;

  ld    h,0
  ld    l,(ix+enemies_and_objects.v7)       ;v7=reference to movement table (0, 8, 16, 24, 32, 40, 48, 56)
  ld    de,OctopussyBulletMovementTable1
  add   hl,de
  ex    de,hl
  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table

  call  RemoveSoftwareSpriteWhenOutOfScreen

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
  ld    a,1                                   ;Octopussy Bullet Slow Down Handler
  ld    (OctoPussyBulletSlowDownHandler),a
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
;v2 = reference to running table
;v3 = timer to go back to normal running speed again
  ld    a,(ix+enemies_and_objects.v2)
  or    a
  call  nz,.PlayerIsAffectedBySlowdown

  ld    a,(OctoPussyBulletSlowDownHandler)  ;player got hit by bullet ?
  or    a
  ret   z
;at this point player got hit by a bullet. We change to a slower movement table for player and lower player's starting jump speed
  xor   a
  ld    (OctoPussyBulletSlowDownHandler),a

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
;  ld    a,(framecounter)
;  and   7
;  jr    nz,.Animate
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

  ld    de,lenghtenemytable
  add   ix,de                               ;bullet 1
  
  bit   0,(ix+enemies_and_objects.Alive?)
  jr    z,.EmptySlotFound
  add   ix,de                               ;bullet 2
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

  HunchbackJumping:;
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
  jp    VramObjectsTransparantCopies2

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
  call  VramObjectsTransparantCopies2
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  jp    RemoveSoftwareSpriteWhenOutOfScreen

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
  
  jp    nz,VramObjectsTransparantCopies2
  ld    (ix+enemies_and_objects.alive?),0  
;  jp    VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
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

  bit   0,(ix+lenghtenemytable+enemies_and_objects.Alive?)
  ret   nz

  ld    (ix+enemies_and_objects.v2),1       ;v2=Phase (0=hanging in air, 1=attacking)
  ld    (ix+enemies_and_objects.v5),50      ;v5=Attack Timer

  set   0,(ix+lenghtenemytable+enemies_and_objects.Alive?)

  ld    l,(ix+enemies_and_objects.x)
  ld    h,(ix+enemies_and_objects.x+1)
  ld    de,-16
  add   hl,de
  ld    a,l
  ld    (ix+lenghtenemytable+enemies_and_objects.x),a
  ld    a,h
  ld    (ix+lenghtenemytable+enemies_and_objects.x+1),a

  ld    a,(ix+enemies_and_objects.y)
  add   a,6
  ld    (ix+lenghtenemytable+enemies_and_objects.y),a

  ld    (ix+lenghtenemytable+enemies_and_objects.v3),-1 ;vertical movement
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  ld    (ix+lenghtenemytable+enemies_and_objects.v4),a          
  ret  
  
DemontjeLeftAnimation:
  dw  LeftDemontjeBrown1_Char
  dw  LeftDemontjeBrown2_Char
  dw  LeftDemontjeBrown3_Char

DemontjeRightAnimation:
  dw  RightDemontjeBrown1_Char
  dw  RightDemontjeBrown2_Char
  dw  RightDemontjeBrown3_Char











;BatSpawner:
;v1=Y spawnpoint
;v2=max Y to add to Y spawnpoint
;v3=Previous Y spawn
;v4=wait timer
;  dec   (ix+enemies_and_objects.v4)         ;v4=wait timer
;  ret   nz
;  ld    (ix+enemies_and_objects.v4),100     ;v4=wait timer

;  ld    a,(ix+enemies_and_objects.v1)       ;v1=pointer to Y spawnpoint table
;  inc   a
;  and   15
;  ld    (ix+enemies_and_objects.v1),a       ;v1=pointer to Y spawnpoint table

;  .SearchEmptySlot:
;  ld    de,lenghtenemytable
  
;  add   ix,de
;  bit   0,(ix+enemies_and_objects.Alive?)
;  jr    z,.EmptySlotFound
;  add   ix,de
;  bit   0,(ix+enemies_and_objects.Alive?)
;  ret   nz
  
;  .EmptySlotFound:
;  ld    d,0
;  ld    e,a
;  ld    hl,.SpawnpointTable
;  add   hl,de
;  ld    a,(hl)
;  ld    (ix+enemies_and_objects.y),a  
;  ld    (ix+enemies_and_objects.alive?),-1 
;  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
;  ld    hl,Bat
;  ld    (ix+enemies_and_objects.movementpattern),l
;  ld    (ix+enemies_and_objects.movementpattern+1),h
;  ld    (ix+enemies_and_objects.nrsprites),72-(08*6)
;  ld    (ix+enemies_and_objects.nrspritesSimple),8
;  ld    (ix+enemies_and_objects.nrspritesTimes16),8*16
;  ld    (ix+enemies_and_objects.life),1
  
;  ld    hl,(ClesX)
;  ld    de,304/2
;  sbc   hl,de               ;take x Cles and subtract the x camera  
;  jr    c,.PlayerIsLeftSideOfMap

;  .PlayerIsLRightSideOfMap:
;  ld    (ix+enemies_and_objects.x),000
;  ld    (ix+enemies_and_objects.x+1),0
;  ld    (ix+enemies_and_objects.v4),2       ;v4=Horizontal Movement
;  ret  
  
;  .PlayerIsLeftSideOfMap:
;  ld    (ix+enemies_and_objects.x),060
;  ld    (ix+enemies_and_objects.x+1),1
;  ld    (ix+enemies_and_objects.v4),-2      ;v4=Horizontal Movement
;  ret

;.SpawnpointTable:
;  db    008,090,150,040, 100,166,020,120
;  db    060,110,140,080, 030,160,050,130
  
;Bat:
;v1=Animation Counter
;v2=
;v3=Vertical Movement
;v4=Horizontal Movement
;  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
;  exx                                       ;store hl. hl now points to color data
;  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
;  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
;	ld		a,BatSpriteblock                    ;set block at $a000, page 2 - block containing sprite data
;  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
;  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
;  ret
  
;  .HandlePhase:
;  call  .Move  
;  call  CheckOutOfMap

;  .Animate:
;  bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
;  ld    hl,BatRightAnimation
;  jp    z,.GoAnimate
;  ld    hl,BatLeftAnimation
;  .GoAnimate:
;  ld    b,03                                ;animate every x frames (based on framecounter)
;  ld    c,2 * 04                            ;04 animation frame addresses
;  jp    AnimateSprite                       ;out hl -> sprite character data to out to Vram

;  .Move:
;  call  MoveSpriteHorizontally
;  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
;  push  af
;  ld    (ix+enemies_and_objects.v4),0       ;v4=Horizontal Movement
;  ld    de,BatMovementTable
;  call  MoveObjectWithStepTableNew          ;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
;  pop   af
;  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
;  ret

;BatMovementTable:  ;repeating steps(128 = end table/repeat), move y, move x
;  db  05,-1,-0,  01,-0,-0,  02,-1,-0,  01,-0,-0,  01,-1,-0,  02,-0,-0
;  db  01,+1,-0,  01,-0,-0,  02,+1,-0,  01,-0,-0,  05,+1,-0,  02,-0,-0
;  db  02,+1,-0,  01,-0,-0,  01,+1,-0,  02,-0,-0,  01,-1,-0,  01,-0,-0,  02,-1,-0
;  db  128

;BatLeftAnimation:
;  dw  LeftBat1_Char
;  dw  LeftBat2_Char
;  dw  LeftBat3_Char
;  dw  LeftBat4_Char

;BatRightAnimation:
;  dw  RightBat1_Char
;  dw  RightBat2_Char
;  dw  RightBat3_Char
;  dw  RightBat4_Char

BoringEye:
;v1=Animation Counter
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

GlassballPipe:
  ld    hl,GlassballPipe_Char
  exx                                       ;store hl. hl now points to color data
  ld		a,GlassballPipeSpriteblock          ;set block at $a000, page 2 - block containing sprite data
  ld    e,(ix+enemies_and_objects.sprnrinspat)  ;sprite number * 16 (used for the character and color data in Vram)
  ld    d,(ix+enemies_and_objects.sprnrinspat+1)
  ret
  
Slime:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
  call  .HandlePhase                        ;0=moving, 1=waiting, 2=duck, 3=unduck) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
;  call  CheckPlayerPunchesEnemyOnlySitting  ;Check if player hit's enemy
;************ HIER MOETEN WE IETS NIEUWS VERZINNEN
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
;  ld    a,(EnableHitbox?)
;  or    a
;  ret   nz                                  ;check if player is still attacking
;************ HIER MOETEN WE IETS NIEUWS VERZINNEN

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

;  ld    a,(EnableHitbox?)
;  or    a
;  ret   z                                  ;check if player is attacking
;************ HIER MOETEN WE IETS NIEUWS VERZINNEN

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
  jp    z,VramObjectsTransparantCopies2
;  call  VramObjectsTransparantCopiesRemove  ;Only remove, don't put object in Vram/screen  
  dec   (ix+enemies_and_objects.v5)         ;v5=Static Timer
  ret   nz
  ld    (ix+enemies_and_objects.alive?),0  
  ret
  
  FireEyeFireBulletStatic:
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  VramObjectsTransparantCopies2        ;put object in Vram/screen  
  dec   (ix+enemies_and_objects.v5)         ;v5=Static Timer
  ret   nz
  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=moving, 1=static on floor, 3=fading out)  
  ld    (ix+enemies_and_objects.v5),040     ;v5=Static Timer
  ret

  FireEyeFireBulletMoving:
  call  CollisionObjectPlayer               ;Check if player is hit by Vram object
  call  VramObjectsTransparantCopies2        ;put object in Vram/screen
  call  .Gravity
  call  MoveSpriteHorizontallyAndVertically ;Add v3 to y. Add v4 to x (16 bit)
  call  RemoveSoftwareSpriteWhenOutOfScreen

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
FireEye:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=v3v4tablerotator
;v7=green fire eye(0) / grey fire eye(1)
  call  .HandlePhase                        ;(0=walking, 1=attacking) ;out hl -> sprite character data to out to Vram
  exx                                       ;store hl. hl now points to color data
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  call  CollisionEnemyPlayer                ;Check if player is hit by enemy
  ld    a,(ix+enemies_and_objects.v7)       ;v7=green fire eye(0) / grey fire eye(1)
  or    a
	ld		a,FireEyeGreenSpriteblock           ;set block at $a000, page 2 - block containing sprite data
	jr    z,.BlockSet
	ld		a,FireEyeGreySpriteblock            ;set block at $a000, page 2 - block containing sprite data
  .BlockSet:
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
  call  CheckOutOfMapVertically             ;remove sprite from play when leaving the map

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
  jr    z,.FloorFound
  cp    SpikeId-1
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  cp    LavaId-1
  ret   nz
  jp    CheckPlayerPunchesEnemy.EnemyDied
  
  .FloorFound:
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
  call  c,MoveSpriteHorizontallyWithoutTurningAroundAtEdges
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
  dec   a                                   ;check if zombie walks on ladder
  ret   z

  ld    (ix+enemies_and_objects.v2),2       ;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
  ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
  ret

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
    
Sf2Hugeobject1:                             ;movement pattern 3
;  ld    a,(HugeObjectFrame)
;  inc   a
;  ld    (HugeObjectFrame),a
;  jp    nz,CheckCollisionObjectPlayer

;  call  MoveSF2Object1
;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
;  call  restoreBackgroundObject1
;  call  PutSF2Object ;CHANGES IX   
  ret

Sf2Hugeobject2:                             ;movement pattern 4
;  ld    a,(HugeObjectFrame)
;  cp    1
;  jp    nz,CheckCollisionObjectPlayer
;
;  call  MoveSF2Object2
;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
;  call  restoreBackgroundObject2
;  call  PutSF2Object2 ;CHANGES IX   
  ret

Sf2Hugeobject3:                             ;movement pattern 5
;  ld    a,(HugeObjectFrame)
;  cp    2
;  jp    nz,CheckCollisionObjectPlayer

;  call  MoveSF2Object3
;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
;  call  restoreBackgroundObject3
;  call  PutSF2Object3 ;CHANGES IX   

;  ld    a,-1
;  ld    (HugeObjectFrame),a
;  call  switchpageSF2Engine  
  ret

NoneMovingObjectStepTable:  ;move x, move y (128 = end table/repeat)
  db  10,+0,+0
  db  128

;HugeBlockStepTable1:  ;repeating steps(128 = end table/repeat), move y, move x
;  db  50,+0,+2,  50,+2,+0,  50,+0,-2,  50,-2,+0
;  db  128

;HugeBlockStepTable2:  ;repeating steps(128 = end table/repeat), move y, move x
;  db  40,+0,+2,  40,+0,-2,  40,+0,-2,  40,+0,+2
;  db  128

;HugeBlockStepTable3:  ;repeating steps(128 = end table/repeat), move y, move x
;  db  10,+0,+2,  10,+1,+2,  10,+1,+1,  10,+2,+1,  10,+2,+0
;  db  10,+2,+0,  10,+2,-1,  10,+1,-1,  10,+1,-2,  10,+0,-2
;  db  10,+0,-2,  10,-1,-2,  10,-1,-1,  10,-2,-1,  10,-2,-0
;  db  10,-2,-0,  10,-2,+1,  10,-1,+1,  10,-1,+2,  10,-0,+2
;  db  128

;MoveSF2Object1:
;  ld    de,HugeBlockStepTable1
;  call  MoveObjectWithStepTable
;  ret
  
;MoveSF2Object2:
;  ld    de,HugeBlockStepTable2
;  call  MoveObjectWithStepTable
;  ret

;MoveSF2Object3:
;  ld    de,HugeBlockStepTable3
;  call  MoveObjectWithStepTable
;  ret


MovePlayerAlongWithObjectVertically:
  ld    a,(PlayerDead?)
  or    a
  ret   nz  
  ld    a,(ClesY)
  add   a,(ix+enemies_and_objects.v3)         ;y movement
  ld    (ClesY),a  
  ret

MovePlayerAlongWithObjectHorizontally:
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
  ret
  
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
  ret   z

;InitiatlizeOverview:
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
;  call  CheckActivateSwitch                 ;check if a switch needs to be (de)activated
;  ret

;CheckActivateSwitch:
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
;check stone 1 on switch right side
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.v9)
  ld    b,a
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,b

;  sub   a,16                              ;16x16 enemy = sub   a,16
;  sub   a,00                              ;stone = sub   a,00

  cp    (ix+enemies_and_objects.x)
  jp    nc,.CheckStone2
;check stone 1 on switch left side
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.v8)
  ld    b,a
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,b
;  add   a,08                              ;trampoline blob = sub   a,6
;  add   a,-2                              ;16x16 enemy = sub   a,16
;  add   a,00                              ;stone = add   a,14

  cp    (ix+enemies_and_objects.x)
  jp    c,.CheckStone2
;check stone 2 on switch y
  ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  jp    z,PlayerOrStoneOnSwitch

  .CheckStone2:
;check stone 2 on switch right side
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.v9)
  ld    b,a
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,b

;  sub   a,16                              ;16x16 enemy = sub   a,16
;  sub   a,00                              ;stone = sub   a,00

  cp    (ix+enemies_and_objects.x)
  jp    nc,.CheckStone3
;check stone 2 on switch left side
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.v8)
  ld    b,a
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,b
;  add   a,08                              ;trampoline blob = sub   a,6
;  add   a,-2                              ;16x16 enemy = sub   a,16
;  add   a,00                              ;stone = add   a,14


  cp    (ix+enemies_and_objects.x)
  jp    c,.CheckStone3
;check stone 2 on switch y
  ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
  add   a,16
  cp    (ix+enemies_and_objects.y)
  jp    z,PlayerOrStoneOnSwitch
  
  .CheckStone3:
;check stone 3 on switch right side
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.v9)
  ld    b,a
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  sub   a,b

;  sub   a,16                              ;16x16 enemy = sub   a,16
;  sub   a,00                              ;stone = sub   a,00

  cp    (ix+enemies_and_objects.x)
  jp    nc,.NotOnSwitch
;check stone 3 on switch left side
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.v8)
  ld    b,a
  ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
  add   a,b
;  add   a,08                              ;trampoline blob = sub   a,6
;  add   a,-2                              ;16x16 enemy = sub   a,16
;  add   a,00                              ;stone = add   a,14

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

  ld    l,(ix+enemies_and_objects.coordinates-2)
  ld    h,(ix+enemies_and_objects.coordinates-1)
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
  ld    l,(ix+enemies_and_objects.coordinates+0)
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
  ld    l,(ix+enemies_and_objects.coordinates-2)
  ld    h,(ix+enemies_and_objects.coordinates-1)
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

  ld    l,(ix+enemies_and_objects.coordinates+0)
  ld    h,(ix+enemies_and_objects.coordinates+1)
  ld    (hl),1

  ld    a,(ShowOverView?)
  inc   a
  cp    3
  ret   z
  ld    (ShowOverView?),a
  ret

PlatformOmniDirectionally:
;v1 = sx
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=snap player?
;v6=copy x (16bit)
;v7=copy x (16bit)
;v8=copy y
  ld    a,216 + 16
  ld    (CopyObject+sy),a  

  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object

  call  .animate                            ;rotate arrow (movement direction) when inactive, and set v3+v4 accordingly
  call  VramObjectsTransparantCopies2       ;put object in Vram/screen
  bit   0,(ix+enemies_and_objects.SnapPlayer?)
  ret   z
  ld    a,(framecounter)
  and   1
  ret   z

  call  .StoreCoordinates
  call  MoveObjectHorizontallyAndVertically

  ld    a,(ix+enemies_and_objects.x)
  cp    18
  jr    c,.RecallOldCoordinates
  cp    253
  jr    nc,.RecallOldCoordinates
  ld    a,(ix+enemies_and_objects.y)
  cp    32
  jr    c,.RecallOldCoordinates
  cp    200
  jr    nc,.RecallOldCoordinates


  call  .CheckCollisionObject               ;checks for collision wall and if found sets v7 (collided with wall?)
  jp    nz,MovePlayerAlongWithObject

  .RecallOldCoordinates:
  ld    a,(ix+enemies_and_objects.v6)       ;x
  ld    (ix+enemies_and_objects.x),a        ;x
  ld    a,(ix+enemies_and_objects.v7)       ;x
  ld    (ix+enemies_and_objects.x+1),a      ;x
  ld    a,(ix+enemies_and_objects.v8)       ;y
  ld    (ix+enemies_and_objects.y),a        ;y
  ret

  .StoreCoordinates:
  ld    a,(ix+enemies_and_objects.x)        ;x
  ld    (ix+enemies_and_objects.v6),a       ;x
  ld    a,(ix+enemies_and_objects.x+1)      ;x
  ld    (ix+enemies_and_objects.v7),a       ;x
  ld    a,(ix+enemies_and_objects.y)        ;y
  ld    (ix+enemies_and_objects.v8),a       ;y
  ret

  .animate:                                 ;rotate arrow (movement direction) when inactive
  bit   0,(ix+enemies_and_objects.SnapPlayer?)       ;become active?
  ret   nz

  ld    a,(framecounter)
  and   15
  ret   nz
  ld    a,(ix+enemies_and_objects.v1)       ;sx
  add   a,16
  and   127
  ld    (ix+enemies_and_objects.v1),a       ;sx
  ;set v3+v4 (Vertical+Horizontal Movement) based on direction of arrow
	srl		a                                   ;/2
	srl		a                                   ;/4
	srl		a                                   ;/8 (a=0,2,4,6,8,10,12,14)
  ld    d,0
  ld    e,a
  ld    hl,v3v4Table 
  add   hl,de
  ld    a,(hl)                              ;v3
  ld    (ix+enemies_and_objects.v3),a       ;Vertical Movement
  inc   hl
  ld    a,(hl)                              ;v4
  ld    (ix+enemies_and_objects.v4),a       ;Horizontal Movement    
  ret

  .CheckCollisionObject:                    ;checks for collision wall. out: z=collision found
  ;check if tip of head player touches a ceiling
  ld    a,-16                               ;add to y (y is expressed in pixels)
  ld    hl,+00                              ;add to x to check right side of sprite for collision
  call  .Docheck

  ;check if tip of platform touches a wall
  ld    a,+16                               ;add to y (y is expressed in pixels)
  ld    hl,+00                              ;add to x to check right side of sprite for collision
  call  .Docheck

  ;check if bottom of platform touches a wall
  ld    a,+32                               ;add to y (y is expressed in pixels)
  ld    hl,+00                              ;add to x to check right side of sprite for collision
  call  .Docheck
  ret

  .Docheck:
  call  CheckTileEnemyInHL                  ;out z=collision found with wall  
  jr    z,.ForegroundFound

  inc   hl
  inc   hl
  ld    a,(hl)                              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                                   ;1 = wall
  jr    z,.ForegroundFound
  ret

  .ForegroundFound:
  pop   bc                                  ;no need to do the other checks
  ret


v3v4Table:  db +00,-01, -01,-01, -01,+00, -01,+01, +00,+01, +01,+01, +01,+00, +01,-01

Platform:
;v1-2=box right (16 bit)
;v1-1=box right (16 bit)
;v1=sx software sprite in Vram
;v2=active?
;v3=y movement
;v4=x movement
;v5=SnapPlayer?
;v6=box left (16 bit)
;v7=box left (16 bit)
;v8=box top
;v9=box bottom
;v10=speed
  ld    a,216
  ld    (CopyObject+sy),a

  call  VramObjectsTransparantCopies2       ;put object in Vram/screen
  call  MovePlatForm
;  call  MovePlatFormHorizontally            ;move
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object

  ;set platform on when jumping on it
  bit   0,(ix+enemies_and_objects.v2)       ;v2=active?
  ret   nz                                  ;return if already on

  bit   0,(ix+enemies_and_objects.v5)       ;v5=SnapPlayer?
  ret   z                                   ;have we already snapped to this platform yet ?

  set   0,(ix+enemies_and_objects.v2)       ;v2=active?

  ld    a,(ix+enemies_and_objects.nx)
  cp    32
  jr    z,.BigPlatform

  .SmallPlatform:
  ld    (ix+enemies_and_objects.v1),096     ;v1=sx software sprite in Vram
  ret
  
  .BigPlatform:
  ld    (ix+enemies_and_objects.v1),032     ;v1=sx software sprite in Vram
  ret

MovePlatForm:
  bit   0,(ix+enemies_and_objects.v2)       ;v2=active?
  ret   z
  ld    a,(ix+enemies_and_objects.v10)      ;v10=speed
  dec   a
  ld    b,7
  jr    z,.SpeedSet
  dec   a
  ld    b,3
  jr    z,.SpeedSet
  dec   a
  ld    b,1
  jr    z,.SpeedSet
  ld    b,0
  .SpeedSet:

  ld    a,(framecounter)
  and   b
  ret   nz

  ld    a,(ix+enemies_and_objects.SnapPlayer?)
  or    a
  call  nz,MovePlayerAlongWithObject

;move object
  call  MoveObjectHorizontallyAndVertically
  call  ChangeDirectionWhenOutOfBox
  ret

ChangeDirectionWhenOutOfBox:
  ;check surpasses top side box
  ld    a,(ix+enemies_and_objects.y)        ;y
  sub   a,(ix+enemies_and_objects.v8)       ;v8=box top
  jr    c,.OutOfBoxChangeDirection

  ;check surpasses bottom side box
  ld    a,(ix+enemies_and_objects.v9)       ;v9=box bottom
  sub   a,(ix+enemies_and_objects.y)        ;y
  jr    c,.OutOfBoxChangeDirection

  ;check surpasses left side box
  ld    e,(ix+enemies_and_objects.v6)       ;v6 and v7=box left (16bit)
  ld    d,(ix+enemies_and_objects.v7)       ;v6 and v7=box left (16bit)
  ld    l,(ix+enemies_and_objects.x)        ;x
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  sbc   hl,de
  jr    c,.OutOfBoxChangeDirection

  ;check surpasses right side box
  ld    l,(ix+enemies_and_objects.v1-2)     ;v1-2 and v1-1=box right (16bit)
  ld    h,(ix+enemies_and_objects.v1-1)     ;v1-2 and v1-1=box right (16bit)
  ld    e,(ix+enemies_and_objects.x)        ;x
  ld    d,(ix+enemies_and_objects.x+1)      ;x
  sbc   hl,de
  jr    c,.OutOfBoxChangeDirection
  ret
  
  .OutOfBoxChangeDirection:
  ld    a,(ix+enemies_and_objects.v3)         ;v3=y movement
  neg
  ld    (ix+enemies_and_objects.v3),a         ;v3=y movement
  ld    a,(ix+enemies_and_objects.v4)         ;v4=x movement
  neg
  ld    (ix+enemies_and_objects.v4),a         ;v4=x movement
  ret

MoveObjectHorizontallyAndVertically:
  ld    a,(ix+enemies_and_objects.y)
  add   (ix+enemies_and_objects.v3)         ;v3=y movement
  ld    (ix+enemies_and_objects.y),a

  ld    a,(ix+enemies_and_objects.x)
  add   (ix+enemies_and_objects.v4)         ;v4=x movement
  ld    (ix+enemies_and_objects.x),a
  ret

VramObjectsPushingStone:
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
;  ld    a,%0000 0000      ;Copy from left to right
  xor   a
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs0
  cp    1*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs1
  cp    2*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs2
;  cp    3*32+31           ;x*32+31 (x=page)
;  jp    z,.RightSideCurrentPageIs3

  .RightSideCurrentPageIs3:
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+01         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs2:
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs1:
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs0:
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound



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
  jr    z,.CurrentPageIs0
  cp    1*32+31           ;x*32+31 (x=page)
  jr    z,.CurrentPageIs1
  cp    2*32+31           ;x*32+31 (x=page)
  jr    z,.CurrentPageIs2
;  cp    3*32+31           ;x*32+31 (x=page)
;  jp    z,.CurrentPageIs3

;We have to check now if object is within screen display
;for objects that are 16 pixels wide:
;If current page is page 0 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 1 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 2 then object can only be put if x=>16
;If current page is page 3 then object can only be put if x=>32

;for objects that are 32 pixels wide:
;If current page is page 0 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 1 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 2 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 3 then object can only be put if x=>16
  .CurrentPageIs3:
  ld    a,(ix+enemies_and_objects.nx)
  cp    32
  ld    b,16
  jr    z,.Check
  ld    b,32
  .Check:
  ld    a,(ix+enemies_and_objects.x)
  cp    b
  ret   c
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft

  .CurrentPageIs2:
  ld    a,(ix+enemies_and_objects.nx)
  cp    32
  jr    z,.EndCheck16PixWide
  ld    a,(ix+enemies_and_objects.x)
  cp    16
  ret   c
  .EndCheck16PixWide:
  ld    b,2               ;copy to page 2
  ld    c,1               ;clean object from vram data in page 3
  ld    d,-032            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft

  .CurrentPageIs1:
  ld    b,1               ;copy to page 1
  ld    c,0               ;clean object from vram data in page 2
  ld    d,-016            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft
    
  .CurrentPageIs0:
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000            ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
;  jp    .pagefoundLeft

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

;VramObjectsTransparantCopiesRemove:
;ret
;  ld    l,(ix+enemies_and_objects.ObjectNumber)
;  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
;  jp    docopy



;<--------------------------- 304 ------------------------->
;<-16-> <-------------------- 272 ------------------> <-16->



;|                   page 0              |     
;      |                  page 1               |     
;            |                 page 2                |
;                  |                page 3                 |
                  

;<-16-> <-------------------- 256 ------------ <-16-> <-16->

;      0                                        256            


OnlyPutVramObjectDontEraseFastCopy:
  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

  .ObjectOnRightSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0000      ;Copy from left to right
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    d,+000+01         ;dx offset CopyObject
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    d,-016+01         ;dx offset CopyObject
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    d,-032+01         ;dx offset CopyObject
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    d,-048+01         ;dx offset CopyObject
  jp    z,.pagefound

  .ObjectOnLeftSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  dec   a
  add   a,(ix+enemies_and_objects.nx)
  ld    (CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0100      ;Copy from right to left
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    d,+000            ;dx offset CopyObject
  jr    z,.pagefoundLeft

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    d,-016            ;dx offset CopyObject
  jr    z,.pagefoundLeft

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    d,-032            ;dx offset CopyObject
  jr    z,.pagefoundLeft

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    d,-048            ;dx offset CopyObject
  jr    z,.pagefoundLeft

.pagefoundLeft:
  ld    a,d
  add   a,(ix+enemies_and_objects.nx)
  ld    d,a
 
.pagefound:
  ld    a,b
  ld    (CopyObject+dpage),a  

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+enemies_and_objects.y)
  ld    (CopyObject+dy),a

  ld    a,(ix+enemies_and_objects.x)
  add   d
  ld    (CopyObject+dx),a
  
  ld    a,(ix+enemies_and_objects.nx)  
  ld    (CopyObject+nx),a  
  add   a,2                 ;we clean 2 more pixels, because we use fast copy ($D0) for cleaning, which is not pixel precise (Bitmap mode)

  ld    a,(ix+enemies_and_objects.ny)
  ld    (CopyObject+ny),a  

  ld    a,$d0
  ld    (CopyObject+copytype),a

;put object
  ld    hl,CopyObject
  jp    docopy

;This is an updated version in which the objects can now have an x between 15-254
VramObjectsTransparantCopies2:
  ld    l,(ix+enemies_and_objects.ObjectNumber)
  ld    h,(ix+enemies_and_objects.ObjectNumber+1)
  push  hl
  pop   iy                              ;which Clean Object (DoCopy) table do we use ?

  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

  .ObjectOnRightSideOfScreen:
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  ld    (CopyObject+sx),a               ;set sx
;  ld    a,%0000 0000                    ;Copy from left to right
  xor   a
  ld    (iy+copydirection),a            ;set copy direction
  ld    (CopyObject+copydirection),a

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs0
  cp    1*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs1
  cp    2*32+31           ;x*32+31 (x=page)
  jr    z,.RightSideCurrentPageIs2
;  cp    3*32+31           ;x*32+31 (x=page)
;  jp    z,.RightSideCurrentPageIs3

  .RightSideCurrentPageIs3:
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+01         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs2:
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs1:
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound

  .RightSideCurrentPageIs0:
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+01         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    .pagefound

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .ObjectOnLeftSideOfScreen:
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx (object sx in vram page)
  dec   a
  add   a,(ix+enemies_and_objects.nx)
  ld    (CopyObject+sx),a               ;set sx
  ld    a,%0000 0100                    ;Copy from right to left
  ld    (iy+copydirection),a
  ld    (CopyObject+copydirection),a    ;set copy direction

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  jr    z,.CurrentPageIs0
  cp    1*32+31           ;x*32+31 (x=page)
  jr    z,.CurrentPageIs1
  cp    2*32+31           ;x*32+31 (x=page)
  jr    z,.CurrentPageIs2
;  cp    3*32+31           ;x*32+31 (x=page)
;  jp    z,.CurrentPageIs3

;We have to check now if object is within screen display
;for objects that are 16 pixels wide:
;If current page is page 0 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 1 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 2 then object can only be put if x=>16
;If current page is page 3 then object can only be put if x=>32

;for objects that are 32 pixels wide:
;If current page is page 0 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 1 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 2 then object can only be put if x=>15 (but this is always the case, since that's our determined value)
;If current page is page 3 then object can only be put if x=>16
  .CurrentPageIs3:
;  ld    a,(ix+enemies_and_objects.nx)
;  cp    32
;  ld    b,16
;  jr    z,.Check
;  ld    b,32
;  .Check:
;  ld    a,(ix+enemies_and_objects.x)
;  cp    b
;  ret   c
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    a,-048            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft

  .CurrentPageIs2:
;  ld    a,(ix+enemies_and_objects.nx)
;  cp    32
;  jr    z,.EndCheck16PixWide
;  ld    a,(ix+enemies_and_objects.x)
;  cp    16
;  ret   c
;  .EndCheck16PixWide:
  ld    b,2               ;copy to page 2
  ld    c,1               ;clean object from vram data in page 3
  ld    a,-032            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft

  .CurrentPageIs1:
  ld    b,1               ;copy to page 1
  ld    c,0               ;clean object from vram data in page 2
  ld    a,-016            ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    .pagefoundLeft
    
  .CurrentPageIs0:
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    a,+000            ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
;  jp    .pagefoundLeft

.pagefoundLeft:
;  ld    a,d
  add   a,(ix+enemies_and_objects.nx)
  ld    d,a

  add   a,(ix+enemies_and_objects.x)
  cp    200               ;don't put object that is on the left side of screen if x>200 (that means it went out of screen on the left)
  ret   nc
 
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

  .PutObject:
  ld    (iy+restorebackground?),1  ;all background restores should be done simultaneously at start of frame (after vblank)
  
;  call  BackdropGreen
  ld    hl,CopyObject
  jp    docopy
;  call  BackdropBlack


	dephase
