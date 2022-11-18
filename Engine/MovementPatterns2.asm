;BossGoat
;PutSf2Object5Frames
;PutSf2Object4Frames

PutSf2Object5Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    5
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a
  or    a
  jr    z,.Part1
  dec   a
  jr    z,.Part2
  dec   a
  jr    z,.Part3
  dec   a
  jr    z,.Part4

  .Part5:
  call  .move
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject5
  call  v7x5
  inc   hl
  inc   hl
  inc   hl
  inc   hl
  call  SetFrameBossGoat
  call  PutSF2Object5                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part4:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject4
  call  v7x5
  inc   hl
  inc   hl
  inc   hl
  call  SetFrameBossGoat
  jp    PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part3:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject3
  call  v7x5
  inc   hl
  inc   hl
  call  SetFrameBossGoat
  jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part2:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject2
  call  v7x5
  inc   hl
  call  SetFrameBossGoat
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part1:  
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject1
  call  v7x5
  call  SetFrameBossGoat
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

  .move:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  dec   a
  ret   nz                                  ;1=walking  
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,(ix+enemies_and_objects.v6)       ;v6=Movement Direction  
  ld    (ix+enemies_and_objects.x),a        ;x
  ret

v7x5:
  ld    a,(ix+enemies_and_objects.v7)
  ld    b,0
  ld    c,a
  add   a,a                                 ;*2

  ld    h,0
  ld    l,a

  add   hl,hl                                 ;*4
  add   hl,bc                                ;*5
  ret

SetFrameBossGoat:
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


PutSf2Object4Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    4
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a

  or    a  
  jr    z,.Part1
  dec   a
  jr    z,.Part2
  dec   a
  jr    z,.Part3

  .Part4:
  call  restoreBackgroundObject4
  ld    a,(ix+enemies_and_objects.v7)
  add   a,3
  call  SetFrameBoss
  call  PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part3:
  call  restoreBackgroundObject3
  ld    a,(ix+enemies_and_objects.v7)
  add   a,2
  call  SetFrameBoss
  jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part2:
  call  restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
  inc   a
  call  SetFrameBoss
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part1:
  call  restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

CheckPlayerHitByGoat:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  cp    4
  ret   z                                   ;don't check if boss is dead
;  cp    3
;  ret   z                                   ;don't check if boss is hit
  cp    2
  jr    z,.attacking

  .CheckArms:                               ;when Goat is idle and walking, check arms and body separately
  ;check arms
  ld    (ix+enemies_and_objects.nx),106     ;nx
  ld    (ix+enemies_and_objects.ny),080     ;ny
  xor   a
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,50                               ;reduction to hitbox sx (left side)
  call  CollisionEnemyPlayer.ObjectEntry

  .CheckBody:                               ;when Goat is idle and walking, check arms and body separately
  ;check body
  ld    (ix+enemies_and_objects.nx),52      ;nx
  ld    (ix+enemies_and_objects.ny),124     ;ny
  xor   a
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,30                               ;reduction to hitbox sx (left side)
  jp    CollisionEnemyPlayer.ObjectEntry

  .attacking:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    145/5
  jr    nz,.CheckArms

  .IcePeakAttack:                           ;there is one frame when Ice Peak Hits the ground in which hitbox extends far to the left
  ld    (ix+enemies_and_objects.nx),82      ;nx
  ld    a,15                                ;add to sy
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,110                              ;reduction to hitbox sx (left side)
  jp    CollisionEnemyPlayer.ObjectEntry

GoatCheckIfHit:
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit                ;Check if Boss was hit previous frame
  jr    z,.JustHit
 
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  cp    4
  ret   z                                   ;don't check if boss is dead
  cp    3
  ret   z                                   ;don't check if boss is hit

  ld    a,(framecounter)
  rrca
  jp    c,.CheckTorso                       ;Check if player hit's enemy

  ;check arms
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,30
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    (ix+enemies_and_objects.ny),060     ;ny  
  ld    (ix+enemies_and_objects.nx),110     ;nx
  ld    a,(ix+enemies_and_objects.x)        ;x
  sub   a,26
  ld    (ix+enemies_and_objects.x),a        ;x
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy
  ld    a,(ix+enemies_and_objects.y)        ;y
  sub   a,30
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    (ix+enemies_and_objects.ny),124     ;ny
  ld    (ix+enemies_and_objects.nx),082     ;nx
  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,26
  ld    (ix+enemies_and_objects.x),a        ;x
  ret

  ;check torso
  .CheckTorso:  
  ld    a,(ix+enemies_and_objects.y)        ;y
  add   a,06
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    a,(ix+enemies_and_objects.x)        ;x
  sub   a,04
  ld    (ix+enemies_and_objects.x),a        ;x

  ld    (ix+enemies_and_objects.ny),134     ;ny
  ld    (ix+enemies_and_objects.nx),078     ;nx
  call  CheckPlayerPunchesEnemy             ;Check if player hit's enemy

  ld    a,(ix+enemies_and_objects.y)        ;y
  sub   a,06
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    (ix+enemies_and_objects.ny),124     ;ny
  ld    (ix+enemies_and_objects.nx),082     ;nx

  ld    a,(ix+enemies_and_objects.x)        ;x
  add   a,04
  ld    (ix+enemies_and_objects.x),a        ;x
  ret


  .JustHit:
  ld    a,(HugeObjectFrame)
  cp    4
  ret   nz                                  ;wait for all 5 parts of the boss to be build up

  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v1-1),a     ;backup v7=sprite frame
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v1-2),a     ;backup v7=sprite frame

  dec   (ix+enemies_and_objects.hit?)
  ld    (ix+enemies_and_objects.v7),210/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ret

GoatCheckIfDead:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  cp    4
  ret   z                                   ;don't check if boss is already dead

  ld    a,(ix+enemies_and_objects.life)
  dec   a
  ret   nz

  ld    (ix+enemies_and_objects.v7),240/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v9),011     ;blending into background (MovementPatternsFixedPage1.asm) in: v9=008
  ret
  
BossGoat:
;v1-2=backup v8 phase
;v1-1=backup v7 sprite frame
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=Movement Direction  
;v7=sprite frame
;v8=phase
;v9=timer until next phase
  call  CheckPlayerHitByGoat                ;Check if player gets hit by boss
  ;Check if boss gets hit by player
  call  GoatCheckIfHit                      ;call gets popped if hit. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
  call  GoatCheckIfDead                     ;Check if boss is dead, and if so set dying phase
  
  call  .HandlePhase                        ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)

  ld    de,BossGoatIdleAndWalk00
  jp    PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom

  .HandlePhase:
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(HugeObjectFrame)
  cp    4
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  or    a
  jp    z,BossGoatIdle                      ;0=attack
  dec   a
  jp    z,BossGoatWalking                   ;1=walking
  dec   a
  jp    z,BossGoatAttacking                 ;2=attacking
  dec   a
  jp    z,BossGoatHit                       ;3=hit
  dec   a
  jp    z,BossGoatDead                      ;3=dead
  ret

  BossGoatDead:
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  inc   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    280/5
  jr    z,.ShakeWhenDead
  cp    300/5
  ret   nz  
  ld    (ix+enemies_and_objects.v7),295/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)

  ;as soon as boss is dead, and no longer moving or changing frame, stop restoring background during 3 frames, so boss will be visible in all pages. After that put Boss ALSO (for 1 frame) in page 3
  ;after that put boss (for 3 frames) normally again
  jp    BossBlendingIntoBackgroundOnDeath   ;blending into background (MovementPatternsFixedPage1.asm) in: v9=008
  
  .ShakeWhenDead:
  ld    a,30
  ld    (ShakeScreen?),a
  ret  
    

  BossGoatHit:    
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  inc   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    245/5                               
  ret   nz

  ;when the hit animation is finished, restore v7 and v8 as they were, to continue with previous phase
  ld    a,(ix+enemies_and_objects.v1-1)     ;backup v7=sprite frame
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ld    a,(ix+enemies_and_objects.v1-2)     ;backup v8 phase
  ld    (ix+enemies_and_objects.v8),a       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)

  cp    2                                   ;small exception when goat was attacking
  ret   nz
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    140/5
  ret   c                                   ;if goat was at the past part of the attack, then cancel the attack and go Idle

  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),000/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase
  ret  
  
  BossGoatAttacking:
  call  .animate
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    145/5
  ret   nz
  ld    a,30
  ld    (ShakeScreen?),a
  jp    DamagePlayerIfNotJumping
  
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  inc   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    215/5                               
  ret   nz
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),000/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase
  ret  
  
  BossGoatWalking:
  call  .animate

  dec   (ix+enemies_and_objects.v9)         ;v9=timer until next phase
  ret   nz
  .endWalking:
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),110/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase
  ret
  
  .animate:
  bit   7,(ix+enemies_and_objects.v6)       ;v6=Movement Direction    
  jr    z,.MoveRight

  .MoveLeft:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  inc   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    110/5                               
  ret   nz
  ld    (ix+enemies_and_objects.v7),050/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ret  

  .MoveRight:
  ld    a,(ix+enemies_and_objects.life)
  cp    10
  jr    nc,.skipBoundaryRightSideException
  ld    a,(ix+enemies_and_objects.x)        ;x
  cp    140
  jr    nc,.endWalkingTurnAround
  .skipBoundaryRightSideException:
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  dec   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    045/5                               
  ret   nz
  ld    (ix+enemies_and_objects.v7),105/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ret  

  .endWalkingTurnAround:
  ld    a,(ix+enemies_and_objects.v6)       ;v6=Movement Direction    
  neg
  ld    (ix+enemies_and_objects.v6),a       ;v6=Movement Direction
  jr    .endWalking
  

  BossGoatIdle:
;  ld    a,(Bossframecounter)
;  rrca
;  ret   c  

  call  .animate
  dec   (ix+enemies_and_objects.v9)         ;v9=timer until next phase
  ret   nz
  ld    (ix+enemies_and_objects.v7),105/5   ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v9),020     ;v9=timer until next phase

  ld    a,(ix+enemies_and_objects.x)        ;x
  cp    120
  jr    c,.MoveRight
  cp    160
  ret   c
  ld    (ix+enemies_and_objects.v6),-2      ;v6=Movement Direction    
  ret

  .MoveRight:
  ld    (ix+enemies_and_objects.v6),+2      ;v6=Movement Direction  
  ret

  
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  inc   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  cp    050/5                               
  ret   nz
  ld    (ix+enemies_and_objects.v7),000/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  ret  
  
;Idle 
BossGoatIdleAndWalk00:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk01:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk02:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk03:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk04:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk05:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk06:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk07:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk08:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk09:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk10:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk11:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk12:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk13:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk14:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk15:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk16:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk17:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk18:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk19:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk20:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk21:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk22:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk23:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk24:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk25:   dw GoatIdleAndWalkframe005 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk26:   dw GoatIdleAndWalkframe006 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk27:   dw GoatIdleAndWalkframe007 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk28:   dw GoatIdleAndWalkframe008 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk29:   dw GoatIdleAndWalkframe009 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk30:   dw GoatIdleAndWalkframe010 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk31:   dw GoatIdleAndWalkframe011 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk32:   dw GoatIdleAndWalkframe012 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk33:   dw GoatIdleAndWalkframe013 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk34:   dw GoatIdleAndWalkframe014 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk35:   dw GoatIdleAndWalkframe015 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk36:   dw GoatIdleAndWalkframe016 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk37:   dw GoatIdleAndWalkframe017 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk38:   dw GoatIdleAndWalkframe018 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk39:   dw GoatIdleAndWalkframe019 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk40:   dw GoatIdleAndWalkframe020 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk41:   dw GoatIdleAndWalkframe021 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk42:   dw GoatIdleAndWalkframe022 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk43:   dw GoatIdleAndWalkframe023 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk44:   dw GoatIdleAndWalkframe024 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk45:   dw GoatIdleAndWalkframe025 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk46:   dw GoatIdleAndWalkframe026 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk47:   dw GoatIdleAndWalkframe027 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk48:   dw GoatIdleAndWalkframe028 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk49:   dw GoatIdleAndWalkframe029 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

;Walk
BossGoatIdleAndWalk50:   dw GoatIdleAndWalkframe030 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk51:   dw GoatIdleAndWalkframe031 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk52:   dw GoatIdleAndWalkframe032 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk53:   dw GoatIdleAndWalkframe033 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk54:   dw GoatIdleAndWalkframe034 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk55:   dw GoatIdleAndWalkframe035 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk56:   dw GoatIdleAndWalkframe036 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk57:   dw GoatIdleAndWalkframe037 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk58:   dw GoatIdleAndWalkframe038 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk59:   dw GoatIdleAndWalkframe039 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk60:   dw GoatIdleAndWalkframe040 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk61:   dw GoatIdleAndWalkframe041 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk62:   dw GoatIdleAndWalkframe042 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk63:   dw GoatIdleAndWalkframe043 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk64:   dw GoatIdleAndWalkframe044 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk65:   dw GoatIdleAndWalkframe045 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk66:   dw GoatIdleAndWalkframe046 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk67:   dw GoatIdleAndWalkframe047 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk68:   dw GoatIdleAndWalkframe048 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk69:   dw GoatIdleAndWalkframe049 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk70:   dw GoatIdleAndWalkframe050 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk71:   dw GoatIdleAndWalkframe051 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk72:   dw GoatIdleAndWalkframe052 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk73:   dw GoatIdleAndWalkframe053 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk74:   dw GoatIdleAndWalkframe054 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk75:   dw GoatIdleAndWalkframe055 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk76:   dw GoatIdleAndWalkframe056 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk77:   dw GoatIdleAndWalkframe057 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk78:   dw GoatIdleAndWalkframe058 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk79:   dw GoatIdleAndWalkframe059 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk80:   dw GoatIdleAndWalkframe060 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk81:   dw GoatIdleAndWalkframe061 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk82:   dw GoatIdleAndWalkframe062 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk83:   dw GoatIdleAndWalkframe063 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk84:   dw GoatIdleAndWalkframe064 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk85:   dw GoatIdleAndWalkframe065 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk86:   dw GoatIdleAndWalkframe066 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk87:   dw GoatIdleAndWalkframe067 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk88:   dw GoatIdleAndWalkframe068 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk89:   dw GoatIdleAndWalkframe069 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk90:   dw GoatIdleAndWalkframe070 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk91:   dw GoatIdleAndWalkframe071 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk92:   dw GoatIdleAndWalkframe072 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk93:   dw GoatIdleAndWalkframe073 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk94:   dw GoatIdleAndWalkframe074 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk95:   dw GoatIdleAndWalkframe075 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk96:   dw GoatIdleAndWalkframe076 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk97:   dw GoatIdleAndWalkframe077 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk98:   dw GoatIdleAndWalkframe078 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk99:   dw GoatIdleAndWalkframe079 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatWalkAndAttack100:   dw GoatWalkAndAttackframe000 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack101:   dw GoatWalkAndAttackframe001 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack102:   dw GoatWalkAndAttackframe002 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack103:   dw GoatWalkAndAttackframe003 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack104:   dw GoatWalkAndAttackframe004 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack105:   dw GoatWalkAndAttackframe005 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack106:   dw GoatWalkAndAttackframe006 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack107:   dw GoatWalkAndAttackframe007 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack108:   dw GoatWalkAndAttackframe008 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack109:   dw GoatWalkAndAttackframe009 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

;attack
BossGoatWalkAndAttack110:   dw GoatWalkAndAttackframe010 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack111:   dw GoatWalkAndAttackframe011 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack112:   dw GoatWalkAndAttackframe012 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack113:   dw GoatWalkAndAttackframe013 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack114:   dw GoatWalkAndAttackframe014 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack115:   dw GoatWalkAndAttackframe015 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack116:   dw GoatWalkAndAttackframe016 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack117:   dw GoatWalkAndAttackframe017 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack118:   dw GoatWalkAndAttackframe018 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack119:   dw GoatWalkAndAttackframe019 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack120:   dw GoatWalkAndAttackframe020 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack121:   dw GoatWalkAndAttackframe021 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack122:   dw GoatWalkAndAttackframe022 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack123:   dw GoatWalkAndAttackframe023 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack124:   dw GoatWalkAndAttackframe024 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack125:   dw GoatWalkAndAttackframe025 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack126:   dw GoatWalkAndAttackframe026 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack127:   dw GoatWalkAndAttackframe027 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack128:   dw GoatWalkAndAttackframe028 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack129:   dw GoatWalkAndAttackframe029 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack130:   dw GoatWalkAndAttackframe030 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack131:   dw GoatWalkAndAttackframe031 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack132:   dw GoatWalkAndAttackframe032 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack133:   dw GoatWalkAndAttackframe033 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack134:   dw GoatWalkAndAttackframe034 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack135:   dw GoatWalkAndAttackframe035 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack136:   dw GoatWalkAndAttackframe036 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack137:   dw GoatWalkAndAttackframe037 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack138:   dw GoatWalkAndAttackframe038 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack139:   dw GoatWalkAndAttackframe039 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack140:   dw GoatWalkAndAttackframe040 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack141:   dw GoatWalkAndAttackframe041 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack142:   dw GoatWalkAndAttackframe042 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack143:   dw GoatWalkAndAttackframe043 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack144:   dw GoatWalkAndAttackframe044 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatAttack145:   dw GoatAttackframe000 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack146:   dw GoatAttackframe001 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack147:   dw GoatAttackframe002 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack148:   dw GoatAttackframe003 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack149:   dw GoatAttackframe004 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack150:   dw GoatAttackframe005 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack151:   dw GoatAttackframe005 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack152:   dw GoatAttackframe006 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack153:   dw GoatAttackframe007 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack154:   dw GoatAttackframe008 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack155:   dw GoatAttackframe009 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack156:   dw GoatAttackframe009 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack157:   dw GoatAttackframe010 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack158:   dw GoatAttackframe011 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack159:   dw GoatAttackframe024 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack160:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack161:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack162:   dw GoatAttackframe013 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack163:   dw GoatAttackframe014 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack164:   dw GoatAttackframe025 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack165:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack166:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack167:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack168:   dw GoatAttackframe016 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack169:   dw GoatAttackframe017 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack170:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack171:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack172:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack173:   dw GoatAttackframe019 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack174:   dw GoatAttackframe020 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack175:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack176:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack177:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack178:   dw GoatAttackframe022 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack179:   dw GoatAttackframe023 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack2180:   dw GoatAttack2frame000 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2181:   dw GoatAttack2frame000 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2182:   dw GoatAttack2frame001 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2183:   dw GoatAttack2frame002 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2184:   dw GoatAttack2frame003 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2185:   dw GoatAttack2frame004 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2186:   dw GoatAttack2frame004 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2187:   dw GoatAttack2frame005 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2188:   dw GoatAttack2frame006 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2189:   dw GoatAttack2frame007 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2190:   dw GoatAttack2frame008 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2191:   dw GoatAttack2frame009 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2192:   dw GoatAttack2frame010 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2193:   dw GoatAttack2frame011 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2194:   dw GoatAttack2frame012 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2195:   dw GoatAttack2frame013 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2196:   dw GoatAttack2frame014 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2197:   dw GoatAttack2frame015 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2198:   dw GoatAttack2frame016 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2199:   dw GoatAttack2frame017 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2200:   dw GoatAttack2frame018 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2201:   dw GoatAttack2frame019 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2202:   dw GoatAttack2frame020 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2203:   dw GoatAttack2frame021 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2204:   dw GoatAttack2frame022 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2205:   dw GoatAttack2frame023 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2206:   dw GoatAttack2frame023 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2207:   dw GoatAttack2frame024 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2208:   dw GoatAttack2frame025 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2209:   dw GoatAttack2frame026 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttackAndHit210:   dw GoatAttackAndHitframe000 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit211:   dw GoatAttackAndHitframe001 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit212:   dw GoatAttackAndHitframe002 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit213:   dw GoatAttackAndHitframe003 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit214:   dw GoatAttackAndHitframe004 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

;Hit
BossGoatAttackAndHit215:   dw GoatAttackAndHitframe005 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit216:   dw GoatAttackAndHitframe006 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit217:   dw GoatAttackAndHitframe007 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit218:   dw GoatAttackAndHitframe008 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit219:   dw GoatAttackAndHitframe009 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit220:   dw GoatAttackAndHitframe010 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit221:   dw GoatAttackAndHitframe011 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit222:   dw GoatAttackAndHitframe012 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit223:   dw GoatAttackAndHitframe013 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit224:   dw GoatAttackAndHitframe014 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit225:   dw GoatAttackAndHitframe015 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit226:   dw GoatAttackAndHitframe016 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit227:   dw GoatAttackAndHitframe017 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit228:   dw GoatAttackAndHitframe018 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit229:   dw GoatAttackAndHitframe019 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit230:   dw GoatAttackAndHitframe020 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit231:   dw GoatAttackAndHitframe021 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit232:   dw GoatAttackAndHitframe022 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit233:   dw GoatAttackAndHitframe023 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit234:   dw GoatAttackAndHitframe024 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit235:   dw GoatAttackAndHitframe025 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit236:   dw GoatAttackAndHitframe026 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit237:   dw GoatAttackAndHitframe027 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit238:   dw GoatAttackAndHitframe028 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit239:   dw GoatAttackAndHitframe029 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
              ;This frame is last frame of hit, but ALSO first frame of Dying
BossGoatAttackAndHit240:   dw GoatAttackAndHitframe030 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit241:   dw GoatAttackAndHitframe031 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit242:   dw GoatAttackAndHitframe032 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit243:   dw GoatAttackAndHitframe033 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit244:   dw GoatAttackAndHitframe034 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

;Dying (actually 2nd frame)
BossGoatDying245:   dw GoatDyingframe000 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying246:   dw GoatDyingframe001 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying247:   dw GoatDyingframe002 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying248:   dw GoatDyingframe003 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying249:   dw GoatDyingframe004 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying250:   dw GoatDyingframe005 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying251:   dw GoatDyingframe006 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying252:   dw GoatDyingframe007 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying253:   dw GoatDyingframe008 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying254:   dw GoatDyingframe009 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying255:   dw GoatDyingframe010 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying256:   dw GoatDyingframe011 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying257:   dw GoatDyingframe012 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying258:   dw GoatDyingframe013 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying259:   dw GoatDyingframe014 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying260:   dw GoatDyingframe015 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying261:   dw GoatDyingframe016 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying262:   dw GoatDyingframe017 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying263:   dw GoatDyingframe018 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying264:   dw GoatDyingframe019 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
;--------------------------------------------------------------------------------------------------------;
BossGoatDying2265:   dw GoatDying2frame000 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2266:   dw GoatDying2frame001 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2267:   dw GoatDying2frame002 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2268:   dw GoatDying2frame003 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2269:   dw GoatDying2frame004 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2270:   dw GoatDying2frame005 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2271:   dw GoatDying2frame005 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2272:   dw GoatDying2frame006 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2273:   dw GoatDying2frame007 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2274:   dw GoatDying2frame008 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2275:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2276:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2277:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2278:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2279:   dw GoatDying2frame010 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2280:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2281:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2282:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2283:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2284:   dw GoatDying2frame012 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2285:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2286:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2287:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2288:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2289:   dw GoatDying2frame014 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2290:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2291:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2292:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2293:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2294:   dw GoatDying2frame016 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2295:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2296:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2297:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2298:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2299:   dw GoatDying2frame018 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock


