	phase	MovementPatternsFixedPage1Address

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
;BossBlendingIntoBackgroundOnDeath
;SetObjectXY
;MoveObjectWithStepTableNew

;v3=y movement, v4=x movement, v5=repeating steps, v6=pointer to movement table
MoveObjectWithStepTableNew:
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
  ld    (ix+enemies_and_objects.vMove),a         ;v3=y movement
  inc   hl
  ld    a,(hl)                                ;x movement
  ld    (ix+enemies_and_objects.hMove),a         ;v4=x movement

.moveObject:
  ld    a,(ix+enemies_and_objects.y)          ;y object
  add   a,(ix+enemies_and_objects.vMove)         ;add y movement to y
  ld    (ix+enemies_and_objects.y),a          ;y object

  ;8 bit
;  ld    a,(ix+enemies_and_objects.x)          ;x object
;  add   a,(ix+enemies_and_objects.v4)         ;add x movement to x
;  ld    (ix+enemies_and_objects.x),a          ;x object

  ;16 bit
  ld    a,(ix+enemies_and_objects.hMove)         ;x movement
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


;Set SF2 frame position
;in:	IX=objectRecord
;		DE=XXYY offset
SetSf2ObjectXY:  ;non moving objects start at (0,0). Use this routine to set your own coordinates
; call  MoveObjectHorizontallyAndVertically
;  call  ChangeDirectionWhenOutOfBox
		ld		a,(ix+enemies_and_objects.y)          ;y object
		add		a,e
		ld		(Object1y),a
		ld		a,(ix+enemies_and_objects.x)          ;x object
		add		a,d
		ld		(Object1x),a
		ret

BossBlendingIntoBackgroundOnDeath:          ;blending into background (MovementPatternsFixedPage1.asm) in: v9=008
  ;as soon as boss is dead, and no longer moving or changing frame, stop restoring background during 3 frames, so boss will be visible in all pages. After that put Boss ALSO (for 1 frame) in page 3
  ;after that put boss (for 3 frames) normally again
  ld    a,(ix+enemies_and_objects.v9)       ;v9=timer until next phase
  dec   a                                   ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v9),a       ;v9=timer until next phase
  cp    8
  ret   nc

  xor   a
  ld    (RestoreBackgroundSF2Object?),a

  ld    a,(ix+enemies_and_objects.v9)       ;v9=timer until next phase
  or    a
;  dec   a                                   ;amount of frames per animation step
;  ld    (ix+enemies_and_objects.v9),a       ;v9=timer until next phase
  jr    z,.RemoveObject
  cp    4
  ld    a,3
  jr    z,.putBoss
  xor   a                                   ;put boss normally
  .putBoss:
  ld    (PutObjectInPage3?),a               ;the last frame before we remove boss, put boss in page 3, so boss now becomes a part of the background.
  ret  
  .RemoveObject:
  ld    (ix+enemies_and_objects.Alive?),0   ;remove object
  ret  
  
DamagePlayerIfNotJumping:
	ld		hl,Jump
	ld		de,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  ret   z

	ld		hl,LMeditate
	ld		de,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  ret   z

	ld		hl,RMeditate
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
;	cp    3
	and	  3
;	jr    nz,.SetFrame
;	xor   a
;.SetFrame:
	ld    (HugeObjectFrame),a
;  or    a  
	jr    z,.Top
	dec   a
	jr    z,.Middle

.Bottom:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject3
	ld    a,(ix+enemies_and_objects.v7)
	add   a,2
	call  SetFrameBoss
	call  PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine
  
.Middle:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
	ld    a,(ix+enemies_and_objects.v7)
	inc   a
	call  SetFrameBoss
	jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Top:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
	ld    a,(ix+enemies_and_objects.v7)
	call  SetFrameBoss
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 





PutSf2Object4FramesNew:
	ld    a,(HugeObjectFrame)
	inc   a
	cp    4
	jr    nz,.SetFrame
	xor   a
	.SetFrame:
	ld    (HugeObjectFrame),a
  or    a
	jp    z,.Part1
	dec   a
	jp    z,.Part2
	dec   a
	jp    z,.Part3
	dec   a
	jp    z,.Part4

.Part4:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject4
  call  MultV7Times4
	call  PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine

.Part3:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject3
  call  MultV7Times4
	jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
  call  MultV7Times4
	jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
  call  MultV7Times4

  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 







PutSf2Object5Frames:
	ld    a,(HugeObjectFrame)
	inc   a
	cp    5
  .entry:
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
	dec   a
	jr    z,.Part5
	dec   a
	jr    z,.Part6

.Part7:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject7
	ld    a,(ix+enemies_and_objects.v7)
	add   a,6
	call  SetFrameBoss
	jp    PutSF2Object7                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part6:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject6
	ld    a,(ix+enemies_and_objects.v7)
	add   a,5
	call  SetFrameBoss
	jp    PutSF2Object6                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part5:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject5
	ld    a,(ix+enemies_and_objects.v7)
	add   a,4
	call  SetFrameBoss
	jp    PutSF2Object5                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part4:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject4
	ld    a,(ix+enemies_and_objects.v7)
	add   a,3
	call  SetFrameBoss
	jp    PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part3:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject3
	ld    a,(ix+enemies_and_objects.v7)
	add   a,2
	call  SetFrameBoss
	jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
	ld    a,(ix+enemies_and_objects.v7)
	inc   a
	call  SetFrameBoss
	jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
	ld    a,(ix+enemies_and_objects.v7)
	call  SetFrameBoss
	call  PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine



PutSf2Object1FramesObjectNr1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
  call  MultV7Times4
  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

PutSf2Object1FramesObjectNr2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
  call  MultV7Times4
  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object2                        ;in: b=frame list block, c=sprite data block. CHANGES IX 





PutSf2Object3FramesNew:
	ld    a,(HugeObjectFrame)
	inc   a
	cp    3
	jr    nz,.SetFrame
	xor   a
	.SetFrame:
	ld    (HugeObjectFrame),a
  or    a
	jp    z,.Part1
	dec   a
	jp    z,.Part2
	dec   a
	jp    z,.Part3

.Part3:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject3
  call  MultV7Times4
	call  PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine

.Part2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
  call  MultV7Times4
	jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
  call  MultV7Times4

  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 


PutSf2Object2FramesNew:
	ld    a,(HugeObjectFrame)
	inc   a
	cp    2
	jr    nz,.SetFrame
	xor   a
	.SetFrame:
	ld    (HugeObjectFrame),a
  or    a
	jp    z,.Part1
	dec   a
	jp    z,.Part2

.Part2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
  call  MultV7Times4
	call  PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine
  
.Part1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
  call  MultV7Times4

  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

PutSf2Object7Frames:
	ld    a,(HugeObjectFrame)
	inc   a
	cp    7
	jr    nz,.SetFrame
	xor   a
	.SetFrame:
	ld    (HugeObjectFrame),a
  or    a
	jp    z,.Part1
	dec   a
	jp    z,.Part2
	dec   a
	jp    z,.Part3
	dec   a
	jp    z,.Part4
	dec   a
	jp    z,.Part5
	dec   a
	jp    z,.Part6

.Part7:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject7
  call  MultV7Times4
	call  PutSF2Object7                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
	jp    switchpageSF2Engine

.Part6:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject6
  call  MultV7Times4
	jp    PutSF2Object6                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part5:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject5
  call  MultV7Times4
	jp    PutSF2Object5                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part4:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject4
  call  MultV7Times4
	jp    PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 

.Part3:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject3
  call  MultV7Times4
	jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part2:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject2
  call  MultV7Times4
	jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
.Part1:
	ld    a,(RestoreBackgroundSF2Object?)
	or    a  
	call  nz,restoreBackgroundObject1
  call  MultV7Times4

  inc   hl
	ld    a,(hl)
	ld    (Player1Frame),a                    ;only on slice 1 we need to set the address of this slice
	inc   hl                                  ;all consecutive slices are set at the end of their previous slice in engine.asm (when exiting the blitloop at .exit:)
	ld    a,(hl)
	ld    (Player1Frame+1),a
	jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

MultV7Times4:                               ;each frame= 4 bytes
	ld    l,(ix+enemies_and_objects.v7)       ;v7=sprite frame
	ld    h,0                                 ;hl=sprite frame
  add   hl,hl                               ;*2
  add   hl,hl                               ;*4
  add   hl,de                               ;add starting address of first frame
	ld    b,(hl)                              ;frame list block
	inc   hl
	ld    c,(hl)                              ;sprite data block
  ret

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
  ret ;????????????????????????????????????????????????

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

CheckOutOfMapSf2Engine:
  ld    a,(ix+enemies_and_objects.y)  
  cp    212
  jr    nc,RemoveSprite

  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x  
  ld    de,256+16                           ;map width + offset
  xor   a
  sbc   hl,de
  ret   c
  jr    RemoveSprite

KeepMonsterInScreen:                 ;if monster was to leave the screen, move him back inside
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x  
  ld    de,20                           ;map width + offset
  xor   a
  sbc   hl,de
	jr		c,.MonsterIsInLeftEdge

	ld		a,(RoomMap.width)						;32 or 38
	cp		32
	ld		de,256-20
	jr		z,.widthFound
	ld		de,304-20
	.widthFound:	
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x  
  xor   a
  sbc   hl,de
	ret		c
	
	.MonsterIsInRightEdge:
  ld    (ix+enemies_and_objects.x),e
  ld    (ix+enemies_and_objects.x+1),d
  ret

	.MonsterIsInLeftEdge:
  ld    (ix+enemies_and_objects.x),e
  ret

;20241007;ro;refactored
CheckCeilingEnemy:							;out: z=foreground found
		ld	 de,0 ;x-offset
		ld    b,0 ;y-offset
		call checkTileObject
		dec	 A
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

CheckOutOfMapVertically:
  ld    a,(ix+enemies_and_objects.y)  
  cp    200 ;%%%%% if we increase this number we get issues with spriteflicker in room AV17. If we DON'T increase this number zombies dont die or properly fall out of screen ? where was it ? room AW24 maybe ?
  ret   c
  jr    RemoveSprite

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

  call  TurnAroundAtScreenEdges  

  MoveSpriteHorizontallyWithoutTurningAroundAtEdges:                   ;Add v3 to y. Add v4 to x (16 bit)	
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

TurnAroundAtScreenEdges:
  ld    e,(ix+enemies_and_objects.x)
  ld    d,(ix+enemies_and_objects.x+1)
  ld    hl,20                               ;turn around when x<20
  sbc   hl,de
  jr    nc,.TurnAround

  ;272-width=240 for SF2 engine 32 wide
  ;272-width=256 for SF2 engine 16 wide

  ;320-width=288 for normal engine 32 wide
  ;320-width=304 for normal engine 16 wide
  
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    hl,320                              ;normal engine x right border=320
  jr    z,.SetRightBorder
  ld    hl,272                              ;SF2 engine x right border=272
  .SetRightBorder:

  ld    b,0
  ld    c,(ix+enemies_and_objects.nx)
  or    a
  sbc   hl,bc
  
;  ld    hl,240                              ;turn around when x>300
  sbc   hl,de
  ret   nc

  .TurnAround:
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
  neg
  ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
  ret

RemoveSoftwareSpriteWhenOutOfScreen:        ;for now only handles out of screen at the bottom (so we dont overwrite scoreboard)
		ld    a,(ix+enemies_and_objects.y)        ;y
		add   a,(ix+enemies_and_objects.ny)       ;ny
		cp    216 ;218
		ret   c
		ld    (ix+enemies_and_objects.alive?),0
		ret


;checks for collision wall and if found invert horizontal movement
;ro: so it does two(2) things
;in:	IX
CheckCollisionWallEnemy:
		ld    a,(ix+enemies_and_objects.ny)       ;add to y (y is expressed in pixels)
		; add   a,8                                 ;this checks exactly at the feet of the enemy
		sub 	8		
		ld	 b,A
		; ld    hl,-16                              ;add to x to check right side of sprite for collision
		ld	 de,-16
		bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
		; jr    z,.MovingRight
		jr    nz,.movingLeft
		ld	 h,0
		ld	 l,(ix+enemies_and_objects.nx)
		add	 hl,de
		ex	 de,hl
.MovingLeft:
		; call  CheckTileEnemyInHL                  ;out z=collision found with wall  
		call  checkTileObject  
		dec	 A
		ret   nz
		ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
		neg
		ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
		ret
; .MovingRight:
; 		; ld    d,0
; 		; ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
; 		; add   hl,de
; 		; call CheckTileEnemyInHL                  ;out z=collision found with wall  
; 		ld	 h,0
; 		ld	 l,(ix+enemies_and_objects.nx)
; 		add	 hl,de
; 		ex	 de,hl
; 		call  checkTileObject  
; 		dec	 a
; 		ret   nz
; 		ld    a,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
; 		neg
; 		ld    (ix+enemies_and_objects.v4),a       ;v4=Horizontal Movement
; 		ret

; ;same as CheckCollisionWallEnemy but using v8 as x-move face  >> NOT USED
; CheckCollisionWallEnemyV8x:                  ;checks for collision wall and if found invert horizontal movement
;   ld    a,(ix+enemies_and_objects.ny)       ;add to y (y is expressed in pixels)
;   ld    hl,-16                              ;add to x to check right side of sprite for collision
;   bit   7,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
;   jr    z,.MovingRight
;   .MovingLeft:
;   call  CheckTileEnemyInHL                  ;out z=collision found with wall  
;   ret   nz
;   ld    a,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
;   neg
;   ld    (ix+enemies_and_objects.v8),a       ;v4=Horizontal Movement
;   ret
;   .MovingRight:
;   ld    d,0
;   ld    e,(ix+enemies_and_objects.nx)       ;add to x to check right side of sprite for collision
;   add   hl,de
;   call  CheckTileEnemyInHL                  ;out z=collision found with wall  
;   ret   nz
;   ld    a,(ix+enemies_and_objects.v8)       ;v4=Horizontal Movement
;   neg
;   ld    (ix+enemies_and_objects.v8),a       ;v4=Horizontal Movement
;   ret


;Used for Zombie, to check if he is completely without floor under him
;ro: no just for the zombie, eh (also coin and all other object that can fall)
;20241007;ro;refactored
CheckFloorUnderBothFeetEnemy:               
		ld	 de,-16 ;x-offset
		ld	 b,(ix+enemies_and_objects.ny)  ;y-offset
		bit	 7,(ix+enemies_and_objects.v4)	;v4=Horizontal Movement
		jr	 z,.MovingRight	;right
		ld	 h,0			;left
		ld	 l,(ix+enemies_and_objects.nx)	;add to x to check right side of sprite for collision
		add	 hl,de
		add	 hl,hl	;0 if nx=16, 32 if nx=32, 64 if nx=48 formula=(nx-16) *2
		ex 	de,hl
.MovingRight:
		call checkTileObject
		dec	 A
		ret

; only for   HugeBlobJumping:
CheckFloorEnemyObjectLeftSide:
		ld	 de,0	;x-offset
		ld	 b,(ix+enemies_and_objects.ny)  ;y-offset
		jp	 checkTileObject
		; ld    hl,0
		; ld    a,(ix+enemies_and_objects.ny)       
		; add   a,16
		; jp    CheckTileEnemyInHL                  ;out z=collision found with wall  


CheckFloorEnemyObject:
		;ld    hl,0
		ld 	de,0
		jp    CheckFloorEnemy.ObjectEntry

;20241007;ro;refactored
CheckFloorEnemy:
		ld	 de,-16 ;x-offset
.ObjectEntry:
		ld    b,(ix+enemies_and_objects.ny)       
		bit   7,(ix+enemies_and_objects.v4)       ;v4=Horizontal Movement
		jp	 nz,.l0	;=left
		ld	 h,0	;=right
		ld	 l,(ix+enemies_and_objects.nx)
		add	 hl,de
		ex	 de,hl
.l0:	call checkTileObject
		dec	 A
		ret

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
  
;CheckPlayerPunchesEnemyOnlySitting:
;  ld    a,(HitBoxSY)                        ;a = y hitbox
;  push  af
;  sub   a,9
;  ld    (HitBoxSY),a                        ;a = y hitbox
;  call  CheckPlayerPunchesEnemy
;  pop   af
;  ld    (HitBoxSY),a                        ;a = y hitbox
;  ret

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

  ld    a,(scrollEngine)                    ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,32                               ;normal engine
  jr    z,.engineFound
  ld    bc,32 - 16                          ;sf2 engine (46 - 14 for arrows)
  .engineFound:
  add   hl,bc                               ;right side of primary weapon (inclusing offset)

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

  sbc   hl,de
  ret   nc
  
  .hit:  
  ld    a,1
  ld    (EnemyHitByPrimairyAttack?),a       ;0=hit by secundary attack, 1=hit by primary attack
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied

  ld    bc,SFX_enemyhit
  call  RePlayerSFX_PlayCh2

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
  ld    hl,(SecundaryWeaponX)               ;hl = x hitbox
  ld    a,(scrollEngine)                    ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    bc,46                               ;normal engine
  jr    z,.engineFound
  ld    bc,46 - 16                          ;sf2 engine (46 - 14 for arrows)
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
  ld    (SecundaryWeaponActive?),a          ;remove arrow when enemy is hit

  ld    a,MagicWeaponDurationValue
  ld    (MagicWeaponDuration),a  
  
  .hit:
  ld    a,0
  ld    (EnemyHitByPrimairyAttack?),a       ;0=hit by secundary attack, 1=hit by primary attack

  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit    
  dec   (ix+enemies_and_objects.life)
  jp    z,CheckPlayerPunchesEnemy.EnemyDied
  ld    bc,SFX_enemyhit
  jp    RePlayerSFX_PlayCh2

CheckPlayerPunchesBossWithYOffset:                ;in b=Y offset
  ld    a,(PrimaryWeaponY)                        ;a = y top phitbox
  add   a,b
  ld    (PrimaryWeaponY),a                        ;a = y top phitbox
  ld    a,(PrimaryWeaponYBottom)                  ;a = y bot hitbox
  add   a,b
  ld    (PrimaryWeaponYBottom),a                  ;a = y bot hitbox
  
  ld    a,(SecundaryWeaponY)                      ;a = y top hitbox
  add   a,b
  ld    (SecundaryWeaponY),a                      ;a = y top hitbox
  ld    a,(SecundaryWeaponYBottom)                ;a = y bot hitbox
  add   a,b
  ld    (SecundaryWeaponYBottom),a                ;a = y bot hitbox

  push  bc
  call  CheckPlayerPunchesEnemy
  pop   bc

  ld    a,(PrimaryWeaponY)                        ;a = y top phitbox
  sub   a,b
  ld    (PrimaryWeaponY),a                        ;a = y top phitbox
  ld    a,(PrimaryWeaponYBottom)                  ;a = y bot hitbox
  sub   a,b
  ld    (PrimaryWeaponYBottom),a                  ;a = y bot hitbox
  
  ld    a,(SecundaryWeaponY)                      ;a = y top hitbox
  sub   a,b
  ld    (SecundaryWeaponY),a                      ;a = y top hitbox
  ld    a,(SecundaryWeaponYBottom)                ;a = y bot hitbox
  sub   a,b
  ld    (SecundaryWeaponYBottom),a                ;a = y bot hitbox
  ret
  
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
	jp    nz,CheckPrimaryWeaponHitsEnemy
	ret
  
;Enemy dies
.EnemyDied:
	ld    (ix+enemies_and_objects.hit?),00    ;stop blinking white when dead
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
	;ld    (ix+enemies_and_objects.y),a

;backup y and move sprite out of screen
	;ld    a,(ix+enemies_and_objects.y)        ;y  
	ld    (ix+enemies_and_objects.v2),a       ;y backup
	ld    (ix+enemies_and_objects.v1),0       ;v1=Animation Counter
	ld    (ix+enemies_and_objects.y),217      ;y

;remove all sprite y's from spat. This way any remaining sprites from the object before the explosion will get removed properly
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
	ld    bc,SFX_enemyexplosionbig
	jp    RePlayerSFX_PlayCh2
  
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
	ld    bc,SFX_enemyexplosionsmall
	jp    RePlayerSFX_PlayCh2

  
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

  jp    RemoveSprite ;COMMENT THIS OUT TO PUT COIN

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
  ld    bc,SFX_coin
  jp    RePlayerSFX_PlayCh2

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
  













;PushStone falling
FallingStone:
		ld		(ix+enemies_and_objects.v4),+0      ;horizontal movement
		call	VramObjectsPushingStone             ;put object in Vram/screen
		call	CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object. Out: b=255 collision right side of object. b=254 collision left side of object. Uses v5/snapplayer?
		call	.AccelerateFall
		call	MoveObject                          ;adds v3 to y, adds v4 to x. x+y are 8 bit
		call	.CheckFloorFallingStone              ;check collision with floor
		call	.checkCollisionWithOtherStones
		ret

.checkCollisionWithOtherStones:
		ld		a,(AmountOfPushingStonesInCurrentRoom)
		and		a
		ret		z
		ld		c,(ix+enemies_and_objects.y)
		ld		b,(ix+enemies_and_objects.x)
		ld		hl,0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y
		call	.CheckCollisionStone1                ;check collision with other stones while falling
		ret		c
		ld		a,(AmountOfPushingStonesInCurrentRoom)
		cp		1
		ret		z
		ld		hl,1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y
		call	.CheckCollisionStone1                ;check collision with other stones while falling
		ret		c
		ld		a,(AmountOfPushingStonesInCurrentRoom)
		cp		2
		ret		z
		ld		hl,2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y
		call	.CheckCollisionStone1                ;check collision with other stones while falling
		; ld		hl,2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y
		; call  CheckCollisionStone1                ;check collision with other stones while falling
		; call  CheckCollisionStone2                ;check collision with other stones while falling
		; call  CheckCollisionStone3                ;check collision with other stones while falling
		ret

;out: C=true
.CheckCollisionStone1:
;check y collision with object 1 (stone 1) top
		ld		a,(hl)	;ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp		C	;(ix+enemies_and_objects.y)
		ret		z
		sub		a,16
		cp		C	;(ix+enemies_and_objects.y)
		ret		nc
;check y collision with object 1 (stone 1) bottom
		ld		a,(hl)	;ld		a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		add		a,17
		cp		C	;(ix+enemies_and_objects.y)
		ccf
		ret		nc
;check x collision with object 1 (stone 1) check on the left side of this stone
		inc		hl
		ld		a,(hl)	;ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add		a,17
		cp		B	;(ix+enemies_and_objects.x)
		ccf
		ret		nc
;check x collision with object 1 (stone 1) check on the right side of this stone
		ld		a,(hl)	;ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add		a,15 -33
		cp		B	;(ix+enemies_and_objects.x)
		ret		nc
 ;other stone found, snap to stone
.collissionWithOtherStone:
		ld    a,(ix+enemies_and_objects.y)        ;y object
		and   %1111 1000
		ld    (ix+enemies_and_objects.y),a        ;y object
		ld    (ix+enemies_and_objects.v2),0       ;phase=idle
		scf
		ret

; CheckCollisionStone2:
; 		ld    a,(AmountOfPushingStonesInCurrentRoom)
; 		cp    1
; 		ret   z
; ;check y collision with object 2 (stone 2) top
; 		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
; 		cp    (ix+enemies_and_objects.y)
; 		ret   z
; 		sub   a,16
; 		cp    (ix+enemies_and_objects.y)
; 		ret   nc
; ;check y collision with object 2 (stone 2) bottom
; 		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
; 		add   a,17
; 		cp    (ix+enemies_and_objects.y)
; 		ret   c
; ;check x collision with object 2 (stone 2) check on the left side of this stone
; 		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
; 		add   a,17
; 		cp    (ix+enemies_and_objects.x)
; 		ret   c
; ;check x collision with object 2 (stone 2) check on the right side of this stone
; 		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
; 		add   a,15 -33
; 		cp    (ix+enemies_and_objects.x)
; 		ret   nc
; 		jp		fallingstone.collissionWithOtherStone
    
; CheckCollisionStone3:
; 		ld    a,(AmountOfPushingStonesInCurrentRoom)
; 		cp    3
; 		ret   nz
; ;check y collision with object 3 (stone 3) top
; 		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
; 		cp    (ix+enemies_and_objects.y)
; 		ret   z
; 		sub   a,16
; 		cp    (ix+enemies_and_objects.y)
; 		ret   nc
; ;check y collision with object 3 (stone 3) bottom
; 		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
; 		add   a,17
; 		cp    (ix+enemies_and_objects.y)
; 		ret   c
; ;check x collision with object 3 (stone 3) check on the left side of this stone
; 		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
; 		add   a,17
; 		cp    (ix+enemies_and_objects.x)
; 		ret   c
; ;check x collision with object 3 (stone 3) check on the right side of this stone
; 		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
; 		add   a,15 -33
; 		cp    (ix+enemies_and_objects.x)
; 		ret   nc
; 		jp		fallingstone.collissionWithOtherStone

;if a floor is found, snap to tile, and change back to pushing stone
.CheckFloorFallingStone:
		ld		b,16			;deltaY
		ld		de,+08			;deltaX
		call	checktileObject	;out: z=collision found with wall, A=tileClass-1
		dec		A	;
		ret		nz
;floor found, snap to floor
		ld    a,(ix+enemies_and_objects.y)        ;y object
		and   %1111 1000
		ld    (ix+enemies_and_objects.y),a        ;y object
		ld    (ix+enemies_and_objects.v2),0       ;state=idle
		ld    (ix+enemies_and_objects.v3),1       ;vertical movement
		ld    (ix+enemies_and_objects.v6),0       ;v6 acceleration timer
		ret

.AccelerateFall:
		ld    a,(ix+enemies_and_objects.v6)       ;v6 acceleration timer
		inc   a
		and   3
		ld    (ix+enemies_and_objects.v6),a
		ret   nz
		ld    a,(ix+enemies_and_objects.v3)       ;vertical movement
		inc   a
		cp    5	;max velocity
		ret   z
		ld    (ix+enemies_and_objects.v3),a
		ret
 
;adds v3 to y, adds v4 to x. x+y are 8 bit
MoveObject:
		ld    a,(ix+enemies_and_objects.y)        ;y object
		add   a,(ix+enemies_and_objects.v3)       ;add y movement to y
		ld    (ix+enemies_and_objects.y),a        ;y object

		ld    a,(ix+enemies_and_objects.x)        ;x object
		add   a,(ix+enemies_and_objects.v4)       ;add x movement to x
		ld    (ix+enemies_and_objects.x),a        ;x object
		ret
  
SetCoordinatesPuzzlePushingStones:          ;if v7=0 then set coordinates
		ld    l,(ix+enemies_and_objects.tableRecordPointer)
		ld    h,(ix+enemies_and_objects.tableRecordPointer+1)
		ld    a,(hl)
		ld    (ix+enemies_and_objects.y),a        ;y object
		inc   hl
		ld    a,(hl)
		ld    (ix+enemies_and_objects.x),a        ;x object
		ld    (ix+enemies_and_objects.v7),1       ;mark postision restored for this room
		ret

;Push Stone Handler
PushingStone:
		ld		a,1	
		ld		(CopyObject+sPage),a 
		; ld    a,216		;!! ro: should be in the object001Table, like .sx
		ld		a,Object001Table.sy
		ld		(CopyObject+sy),a
		ld		a,(ix+enemies_and_objects.v7)       ;posision initializer for THIS room
		and		a
		jr		z,SetCoordinatesPuzzlePushingStones
;Store Coordinates Puzzle Pushing Stones
		ld    l,(ix+enemies_and_objects.tableRecordPointer)
		ld    h,(ix+enemies_and_objects.tableRecordPointer+1)
		ld    a,(ix+enemies_and_objects.y)
		ld    (hl),a
		inc   hl
		ld    a,(ix+enemies_and_objects.x)
		ld    (hl),a

;phase
		ld    a,(ix+enemies_and_objects.v2)       ;falling stone?
		or    a
		jp    nz,FallingStone

		call  CheckFloorOrStonePushingStone       ;Check if Stone is still on a platform or on top of another stone. If not, stone falls. Out z=collision found

		call  VramObjectsPushingStone             ;put object in Vram/screen

		call  MoveStoneWhenPushed                 ;check if stoned needs to be moved
		call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object. Out: b=255 collision right side of object. b=254 collision left side of object
		inc   b
		jp    z,.CollisionRightSide               ;if you collide with a pushing stone from the right side and you are running, then change to pushing pose; if you are pushing, then move stone
		inc   b 
		jp    z,.CollisionLeftSide                ;if you collide with a pushing stone from the left side and you are running, then change to pushing pose; if you are pushing, then move stone
;at this point there is no collision
		ld    a,(ix+enemies_and_objects.v4)       ;if there is no collision set horizontal movement to 0
		or    a
		ret   z
		ld    a,(framecounter)
		and   1
		ret   z
		ld    (ix+enemies_and_objects.v4),+0      ;if there is no collision set horizontal movement to 0

		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		jr    nz,.right
.left:	dec   (ix+enemies_and_objects.x)
		set   0,(ix+enemies_and_objects.x)
		ret
.right:	set   0,(ix+enemies_and_objects.x)
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
;!! ro: this is buggy, it should check ONLY stones
		; ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z
		; ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z
		; ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z

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
;!! ro: this is buggy, it should check ONLY stones
		; ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z
		; ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z
		; ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		; add   a,16
		; cp    (ix+enemies_and_objects.y)
		; ret   z

		ld    (ix+enemies_and_objects.v4),+1      ;horizontal movement    
		ret

; ;When Stone is not moving set x coordinate to odd. The reason we do that is that when copying the block x coordinate is even, and we then can use a fast copy instruction
; SetOddX:
; 	  ret

MoveStoneWhenPushed:
		ld    a,(framecounter)
		and   1
		ret   nz

		ld    a,(ix+enemies_and_objects.v4)       ;v4=horizontal movement. Return if 0
		or    a
		ret   z

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
		;ld    b,YaddFeetPlayer-1                  ;add y to check (y is expressed in pixels)
		;ld    de,XaddRightPlayer-31               ;add to x to check right side of player for collision (player moved right)
		;call  checktile                           ;out z=collision found with wall
		ld	 de,0	;20241005;ro;check stone and not the player
		ld	 a,8
		call checktileObject
		dec a		
		ret   z
		dec   (ix+enemies_and_objects.x)          ;move pushing stone left
		ret
.MovingRight:
		call  CheckCollisionOtherStonesRight      ;out: z= collision found
		ret   z

		;if Pushing Stone moves right, check if it hits wall on the right side
		; ld    b,YaddFeetPlayer-1                  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer+16               ;add to x to check left side of player for collision (player moved left)
		; call  checktile                           ;out z=collision found with wall
		ld	 de,17	;20241005;ro;check stone and not the player
		ld	 a,8
		call checktileObject
		dec A
		ret   z
		inc   (ix+enemies_and_objects.x)          ;move pushing stone right
		ret

CheckCollisionOtherStonesLeft:              ;out: z= collision found
		ld    a,(AmountOfPushingStonesInCurrentRoom)
		dec   a
		jr    z,.EndCheckStone2
		dec   a
		jr    z,.EndCheckStone3
;check collision with object 3 (stone 3)
		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		jr    nz,.EndCheckStone3
		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,18
		cp    (ix+enemies_and_objects.x)
		ret   z
.EndCheckStone3:
;check collision with object 2 (stone 2)
		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		jr    nz,.EndCheckStone2
		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,18
		cp    (ix+enemies_and_objects.x)
		ret   z
.EndCheckStone2:
;check collision with object 1 (stone 1)
		ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		ret   nz
		ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,18
		cp    (ix+enemies_and_objects.x)
		ret

CheckCollisionOtherStonesRight:             ;out: z= collision found
		ld    a,(AmountOfPushingStonesInCurrentRoom)
		dec   a
		jr    z,.EndCheckStone2
		dec   a
		jr    z,.EndCheckStone3
;check collision with object 3 (stone 3)
		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		jr    nz,.EndCheckStone3
		ld    a,(2*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,-18
		cp    (ix+enemies_and_objects.x)
		ret   z
.EndCheckStone3:
;check collision with object 2 (stone 2)
		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		jr    nz,.EndCheckStone2  
		ld    a,(1*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,-18
		cp    (ix+enemies_and_objects.x)
		ret   z
.EndCheckStone2:
;check collision with object 1 (stone 1)
		ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.y)
		cp    (ix+enemies_and_objects.y)
		jr    nz,.EndCheckStone1
		ld    a,(0*lenghtenemytable+enemies_and_objects+enemies_and_objects.x)
		add   a,-18
		cp    (ix+enemies_and_objects.x)
		ret   z
.EndCheckStone1:
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
		;  ld    de,+17                              ;add x to check (x is expressed in pixels)
		;ld    b,+32                               ;add y to check (y is expressed in pixels)
		ld	 b,16 ;20241005;ro;refactored
		ld	 de,+16                              ;add x to check (x is expressed in pixels)
		call checktileObject                     ;out z=collision found with wall
		dec	 A
		ret	 z
;check right side
		;ld    b,+32                               ;add y to check (y is expressed in pixels)
		ld	 b,16 ;20241005;ro;refactored
		;  ld    de,+00                              ;add x to check (x is expressed in pixels)
		ld	 de,+01                              ;add x to check (x is expressed in pixels)
		call checktileObject                     ;out z=collision found with wall
		dec	 a
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



dephase
