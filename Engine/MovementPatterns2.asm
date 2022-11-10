;BossGoat

PutSf2Object5Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    5
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a

  jr    z,.Part1
  dec   a
  jr    z,.Part2
  dec   a
  jr    z,.Part3
  dec   a
  jr    z,.Part4

  .Part5:
  call  restoreBackgroundObject5
  ld    a,(ix+enemies_and_objects.v7)
  add   a,4
  call  SetFrameBoss
  call  PutSF2Object5                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part4:
  call  restoreBackgroundObject4
  ld    a,(ix+enemies_and_objects.v7)
  add   a,3
  call  SetFrameBoss
  jp    PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part3:
  call  restoreBackgroundObject3
  ld    a,(ix+enemies_and_objects.v7)
  add   a,2
  call  SetFrameBoss
  jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part2:
  call  restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
;  add   a,1
  inc   a
  call  SetFrameBoss
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part1:
  call  restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
;  add   a,0
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 



;0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying
;Idle sitting
BossGoatIdle00:   dw GoatIdleframe000 | db BossGoatIdleframelistblock, BossGoatIdlespritedatablock
BossGoatIdle01:   dw GoatIdleframe000 | db BossGoatIdleframelistblock, BossGoatIdlespritedatablock
BossGoatIdle02:   dw GoatIdleframe000 | db BossGoatIdleframelistblock, BossGoatIdlespritedatablock
BossGoatIdle03:   dw GoatIdleframe000 | db BossGoatIdleframelistblock, BossGoatIdlespritedatablock
BossGoatIdle04:   dw GoatIdleframe000 | db BossGoatIdleframelistblock, BossGoatIdlespritedatablock



BossGoat:
;v1-1=
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=timer until attack
ret
;  call  CheckPlayerHitByZombieCaterpillar   ;Check if player gets hit by boss
  ;Check if boss gets hit by player
;  call  ZombieCaterpillarCheckIfHit         ;call gets popped if hit. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
;  call  ZombieCaterpillarCheckIfDead        ;Check if boss is dead, and if so set dying phase
  
  call  .HandlePhase                        ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,BossGoatIdle00
  jp    PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom

  .HandlePhase:                            ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
ret

  ld    a,(HugeObjectFrame)
  cp    4
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  or    a
  jp    z,BossGoatIdle                      ;0=attack
  dec   a
  ret
  
  BossGoatIdle:
;  ld    a,(Bossframecounter)
;  rrca
;  ret   c  

;  call  .animate

;  dec   (ix+enemies_and_objects.v9)         ;v9=timer until attack
;  ret   nz
;  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
;  ld    (ix+enemies_and_objects.v7),18      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret
  
;  .animate:
;  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
;  add   a,3
;  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
;  cp    18                                  ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
;  ret   nz
;  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
;  ret  
  
  

