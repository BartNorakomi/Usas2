;BossGoat
;PutSf2Object5Frames
;PutSf2Object4Frames
;SDMika
;RemoveScoreBoard
;BackupScoreBoard
;RestoreScoreBoard

RestoreScoreBoard:
  ld    a,(ix+enemies_and_objects.v9)       ;v9 wait x frames
  dec   a
  jr    z,.go
  ld    (ix+enemies_and_objects.v9),a       ;v9 wait x frames
  ret
  .go:

  ld    hl,RestoreScoreboard1Line
  call  DoCopy

  ld    a,(RestoreScoreboard1Line+sy)       ;sy
  inc   a
  ld    (RestoreScoreboard1Line+sy),a       ;sy

  ld    a,(RestoreScoreboard1Line+dy)       ;sy
  inc   a
  ld    (RestoreScoreboard1Line+dy),a       ;sy
  ret   nz
  jp    RemoveSprite

BackupScoreBoard:
  ld    hl,BackupScoreboard1Line
  call  DoCopy

  ld    a,(BackupScoreboard1Line+sy)       ;sy
  add   a,10
  ld    (BackupScoreboard1Line+sy),a       ;sy

  ld    a,(BackupScoreboard1Line+dy)       ;sy
  add   a,10
  ld    (BackupScoreboard1Line+dy),a       ;sy
  cp    40
  jp    nc,RemoveSprite
  ret

BackupScoreBoardToRam:
	ld		a,(slot.page2rom)	                  ; all RAM except page 2
	out		($a8),a	

;bank 1 at $4000
  ld		a,1
  out   ($fd),a          	                  ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 

  ld    hl,218*128                          ;page 0 - screen 5 start at y=218
	xor   a
;	call	SetVdp_Read	
;  ld    hl,$8000
;  ld    c,$98
;  ld    a,128/2                       ;backup 128 lines..
;  ld    b,0
;.loop:
;  inir
;  dec   a
;  jp    nz,.loop

;bank 2 at $8000
;  ld		a,2
;  out   ($fe),a          	            ;$ff = page 0 ($c000-$ffff) | $fe = page 1 ($8000-$bfff) | $fd = page 2 ($4000-$7fff) | $fc = page 3 ($0000-$3fff) 

;  ld    hl,$8000
;  ld    c,$98
;  ld    a,084/2                       ;backup remaining 84 lines..
;  ld    b,0
;.loop2:
;  inir
;  dec   a
;  jp    nz,.loop2
;  ret
	
	ld		a,(slot.page12rom)	                ; all RAM except page 1+2
	out		($a8),a	
  ret

RemoveScoreBoard:
  ld    a,(ix+enemies_and_objects.v9)       ;y black line
  inc   a
  cp    255
  jp    nc,RemoveSprite
  ld    (ix+enemies_and_objects.v9),a       ;y black line 
  ld    (RemoveScoreBoard1Line+dy),a  
  ld    hl,RemoveScoreBoard1Line
  jp    DoCopy

PutSf2Object2Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    2
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a
  or    a
  jr    z,.Part1
;  dec   a
;  jr    z,.Part2
  
  .Part2:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
  inc   a
  call  SetFrameBoss
  call  PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part1:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

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

;Idle 
SDMika00:   dw CharacterFacesframe000 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika01:   dw CharacterFacesframe001 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika02:   dw CharacterFacesframe002 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika03:   dw CharacterFacesframe003 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika04:   dw CharacterFacesframe004 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika05:   dw CharacterFacesframe005 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika06:   dw CharacterFacesframe006 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
SDMika07:   dw CharacterFacesframe007 | db CharacterFacesframelistblock, CharacterFacesspritedatablock






;PutSf2Object2Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    2
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a
  or    a
  jr    z,.Part1
  
  .Part2:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
  inc   a
  call  SetFrameBoss
  call  PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part1:
  ld    a,(RestoreBackgroundSF2Object?)
  or    a  
  call  nz,restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 








SDMika:
;v1-4=ScoreBoardVanishInward001 step 
;v1-3=sy and dy copy font and textbackground
;v1-2=backup v8 phase
;v1-1=backup v7 sprite frame
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=add to dx character (text to screen)
;v6=pointer to character (text to screen) 
;v7=sprite frame
;v8=phase
;v9=y black line
;v10=add to dy character (text to screen)
;  call  CheckPlayerHitByGoat                ;Check if player gets hit by boss
  ;Check if boss gets hit by player
;  call  GoatCheckIfHit                      ;call gets popped if hit. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
;  call  GoatCheckIfDead                     ;Check if boss is dead, and if so set dying phase
  
  call  .HandlePhase                        ;v8=Phase (0=waiting player, 1=walking, 2=attacking, 3=hit, 4=dead)

  ld    de,SDMika00
ret
  jp    PutSf2Object2Frames                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom




;  xor   a
;  ld    (screenpage),a                    ;set screen 0, so object gets put in page 1

;  push  ix
;  call  PutSF2Object                      ;in: b=frame list block, c=sprite data block. CHANGES IX 
;  pop   ix

;  ld    a,1
;  ld    (screenpage),a                    ;set screen 1, so player's weapons get put in page 1









  .HandlePhase:
  ld    a,1
  call  switchpageSF2Engine.SetPage         ;force page 1 to be the active page at all times

  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  or    a
  jp    z,SetFontAndBackground              ;0=set font and text background at (0,0) page 0
  dec   a
  jp    z,SDMikaWaitingPlayerNear           ;1=waiting player near and pressing trig-a
  dec   a 
  jp    z,SDMikaSwitchToTextBackground      ;2=remove scoreboard and show text background
  dec   a
  jp    z,SDMikaPutText                     ;3=put text
  dec   a
  jp    z,SDMikaRestoreScoreBoard           ;4=restore scoreboard
  dec   a
  jp    z,SDMikaRestoreBackground           ;5=restore scoreboard
  ret

SDMikaSwitchToTextBackground:
  ld    hl,LineIntNPCInteractions
  ld    (InterruptHandler.SelfmodyfyingLineIntRoutine),hl

  ld    a,(ix+enemies_and_objects.nx)       ;in/out scoreboard/text background timer
  inc   a
  ld    (ix+enemies_and_objects.nx),a       ;in/out scoreboard/text background timer
  cp    050  
  ld    b,+1                                ;vanish inward
  ld    c,00                                ;scoreboard
  jr    c,.set
  cp    100  
  ld    b,-1                                ;appear from the inside out
  ld    c,39                                ;text background
  jr    c,.set
  cp    150  
  ld    b,+1                                ;vanish inward
  ld    c,39                                ;text background
  jr    c,.set
  cp    200  
  ld    b,-1                                ;appear from the inside out
  ld    c,00                                ;scoreboard
  jr    c,.set

  .set:
  call  ScoreBoardTextBackgroundTransition  ;in: b=+1 (vanish inward), b=-1 (appear from the inside out), c=0 (vanish scoreboard), c=39 (vanish text background)
  ret
  
ScoreBoardTextBackgroundTransition:  
  ld    a,(ix+enemies_and_objects.v1-4)     ;ScoreBoardVanishInward001 step 
  add   a,b
  jr    nz,.EndCheckEndLeft
  ld    a,1
  .EndCheckEndLeft:
  cp    25
  jr    nz,.EndCheckEndRight
  ld    a,24
  .EndCheckEndRight:
    
  ld    (ix+enemies_and_objects.v1-4),a     ;ScoreBoardVanishInward001 step 
  ld    b,a                                 ;step in b

  ld    hl,ScoreBoardVanishInward001-39     ;scoreboard + 39*step
  ld    de,39
  .loop1:
  add   hl,de
  djnz  .loop1

  ld    de,NPCtableForR23
  ld    b,39                                ;39 lines
  .loop2:
  ld    a,(hl)
      
  cp    44+20
  jr    nc,.go
  add   a,c
  .go:
  
  ld    (de),a
  inc   hl
  inc   de
  inc   de
  djnz  .loop2  
  ret

SetFontAndBackground:
  ;set the font and text background block at address $4000 in page 1
	ld    a,NPCDialogueFontBlock
  call	block12

	xor   a
  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
	ld    hl,0 - 128
  ld    de,128
  .loop:
  add   hl,de
  djnz  .loop

	call	SetVdp_Write                        ;write font and background to (0,0) in page 0

  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
  ld    hl,NPCDialogueFontAndBackgroundAddress  - 128
  ld    de,128
  .loop2:
  add   hl,de
  djnz  .loop2

  ld    c,$98
  ld    b,128                               ;128 bytes = 1 line
  otir                                      ;copy line

  ld    a,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
  inc   a
  ld    (ix+enemies_and_objects.v1-3),a     ;v1-3=sy and dy copy font and textbackground
  cp    56                                  ;total height font and textbackground
  jr    nz,.EndCheckLastLineCopied
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  .EndCheckLastLineCopied:

  ;set the general movement pattern block at address $4000 in page 1
	ld    a,MovementPatternsFixedPage1block
  call	block12
  ret




  SDMikaRestoreBackground:
  ld    hl,RestoreBackgroundScoreboard1Line
  call  DoCopy

  ld    a,(RestoreBackgroundScoreboard1Line+sy)        ;sy
  inc   a
  ld    (RestoreBackgroundScoreboard1Line+sy),a        ;sy

  ld    a,(RestoreBackgroundScoreboard1Line+dy)        ;sy
  inc   a
  ld    (RestoreBackgroundScoreboard1Line+dy),a        ;sy
  cp    40
  ret   c
  xor   a
  ld    (freezecontrols?),a  
  ld    (ix+enemies_and_objects.v8),0       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)

  ld    a,(ix+enemies_and_objects.v11)
  inc   a
  and   3
  ld    (ix+enemies_and_objects.v11),a  
  
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
  add   a,2
  cp    8
  jr    nz,.go
  xor   a
  .go:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)
    
  ret

  SDMikaRestoreScoreBoard:                  ;3=restore scoreboard
  ld    hl,RestoreScoreboard1Line
  call  DoCopy

  ld    a,(RestoreScoreboard1Line+sy)       ;sy
  inc   a
  ld    (RestoreScoreboard1Line+sy),a       ;sy

  ld    a,(RestoreScoreboard1Line+dy)       ;sy
  inc   a
  ld    (RestoreScoreboard1Line+dy),a       ;sy
  ret   nz
  xor   a
  ld    (RestoreBackgroundScoreboard1Line+sy),a        ;sy
  ld    (RestoreBackgroundScoreboard1Line+dy),a        ;sy  
  ld    (ix+enemies_and_objects.v8),5       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  ret

  SDMikaPutText:
  ld    a,(ix+enemies_and_objects.v11)
  or    a  
  ld    hl,NPCDialogueText1
  jr    z,.go
  dec   a
  ld    hl,NPCDialogueText2
  jr    z,.go
  dec   a
  ld    hl,NPCDialogueText3
  jr    z,.go
  ld    hl,NPCDialogueText4
  .go:
  call  NPCDialogueputText

  cp    255                                 ;end text ?
  ret   nz

  xor   a                                   ;unfreeze controls
  ld    (freezecontrols?),a
  call  PopulateControls                    

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                                 ;space pressed ?

  ld    a,0                                 ;reset and freeze controls again
  ld    (Controls),a
  ld    (NewPrContr),a
  ld    a,1
  ld    (freezecontrols?),a

  ret   z                                   ;check if space is pressed
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  ret

  SDMikaRemoveScoreBoard:                   ;2=remove scoreboard
ret
  ld    a,(ix+enemies_and_objects.v9)       ;y black line
  inc   a
  cp    255
  jp    nc,.EndRemoveScoreBoard
  ld    (ix+enemies_and_objects.v9),a       ;y black line 
  ld    (RemoveScoreBoard1Line+dy),a  
  ld    hl,RemoveScoreBoard1Line
  jp    DoCopy
  .EndRemoveScoreBoard:
  ld    (ix+enemies_and_objects.v5),0       ;v5=add to dx character (text to screen)
  ld    (ix+enemies_and_objects.v10),0      ;v10=add to dy character (text to screen)
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to character (text to screen) 
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  ret

  SDMikaBackupScoreBoard:                   ;1=backup scoreboard
  ld    hl,BackupScoreboard1Line
  call  DoCopy

  ld    a,(BackupScoreboard1Line+sy)        ;sy
  inc   a
  ld    (BackupScoreboard1Line+sy),a        ;sy

  ld    a,(BackupScoreboard1Line+dy)        ;sy
  inc   a
  ld    (BackupScoreboard1Line+dy),a        ;sy
  cp    40
  ret   c
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  ld    (ix+enemies_and_objects.v9),217     ;y black line 
  ret

  SDMikaWaitingPlayerNear:    
  ld    (ix+enemies_and_objects.x),000      ;x character portrait (move out of screen)
  ld    b,90                                ;b-> x distance
  ld    c,140                               ;c-> y distance
  call  distancecheck16wide                 ;in: b,c->x,y distance between player and object,  out: carry->object within distance
  ret   nc
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a           ;space pressed ?
  ret   z
  
;  ld    (ix+enemies_and_objects.x),090      ;x character portrait (move into screen)
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=waiting player, 1=backup scoreboard, 2=remove scoreboard, 3=put text, 4=restore scoreboard, 5=restore background)
  ld    a,1
  ld    (freezecontrols?),a
  ret

NPCDialogueputText:
  ;set fontdata in page 1 in rom ($4000 - $7fff)
	ld    a,NPCDialogueFontBlock
  call	block12
    
  ld    e,(ix+enemies_and_objects.v6)       ;v6=pointer to character  
  ld    d,0
  add   hl,de
  ld    a,(hl)
  
  cp    $20                                 ;space
  jr    nz,.EndCheckSpace
  ld    a,$61 + 26
  .EndCheckSpace:

  cp    $3a                                 ;colon
  jr    nz,.EndCheckColon
  ld    a,$61 + 27
  .EndCheckColon:

  cp    $21                                 ;exclamation mark
  jr    nz,.EndCheckExclamationMark
  ld    a,$61 + 28
  .EndCheckExclamationMark:

  cp    $3f                                 ;question mark
  jr    nz,.EndCheckQuestionMark
  ld    a,$61 + 29
  .EndCheckQuestionMark:

  cp    $2c                                 ;comma
  jr    nz,.EndCheckComma
  ld    a,$61 + 30
  .EndCheckComma:

  cp    $2e                                 ;period
  jr    nz,.EndCheckPeriod
  ld    a,$61 + 31
  .EndCheckPeriod:

  cp    255                                 ;end text
  jr    z,.End

  cp    254                                 ;next line
  jr    nz,.EndCheckNextLine
  ld    (ix+enemies_and_objects.v5),0       ;v5=add to dx character
  ld    a,(ix+enemies_and_objects.v10)      ;v10=add to dy character (text to screen)
  add   a,5
  ld    (ix+enemies_and_objects.v10),a      ;v10=add to dy character (text to screen)  
  inc   (ix+enemies_and_objects.v6)         ;v6=pointer to character  
  inc   hl
  ld    a,(hl)
  .EndCheckNextLine:
  
  inc   (ix+enemies_and_objects.v6)         ;v6=pointer to character  

  sub   $61
  add   a,a                                 ;*2
  ld    d,0
  ld    e,a
  ld    hl,NPCDialogueCharacterData
  add   hl,de

  ld    c,(hl)                              ;Character Start X
  ld    b,0  
  inc   hl 
  ld    d,(hl)                              ;font lenght in bytes (1 byte is 2 pixels)

  ld    hl,NPCDialogueFontAddress           ;writing from this address in ROM
  add   hl,bc
  
  exx
  ld    hl,$6C00+896+2                     ;write to page 0 - screen 5 - bottom 40 pixels (scoreboard)  
  ld    d,(ix+enemies_and_objects.v10)      ;v10=add to dy character (text to screen)
  ld    e,(ix+enemies_and_objects.v5)       ;v5=add to dx character
  add   hl,de

  call  NPCDialoguePutCharacter

  ;set the general movement pattern block at address $4000 in page 1
	ld    a,MovementPatternsFixedPage1block
  call	block12
  ret

  .End:
  ;set the general movement pattern block at address $4000 in page 1
	ld    a,MovementPatternsFixedPage1block
  call	block12
  ld    a,255                               ;end
  ret

NPCDialogueText1:  
  db "mika: my name is mika",254
  db "i dont belong in this game",254
  db "but i dont give a shit",255

NPCDialogueText2:  
  db "mika: ehhhhhh",254
  db "can you fucking stop",254
  db "harrassing me buddy?",255

NPCDialogueText3:  
  db "mika: you think",254
  db "this is funny bro!?",255

NPCDialogueText4:  
  db "mika: thats it",254
  db "im calling the police.",254
  db "you freak",255  
  
;Character Start X, Lenght   A     B     C     D     E     F     G     H     I     J     K     L     M     N     O     P     Q     R     S     T     U     V     W     X     Y     Z     Space :     !     ?     ,     .
NPCDialogueCharacterData: db 000,4,004,4,008,4,012,4,016,4,020,4,024,4,028,4,032,2,034,4,038,4,042,4,046,4,050,4,054,4,058,4,062,4,066,4,070,4,074,4,078,4,082,4,086,4,090,4,094,4,098,4,102,3,105,2,107,2,109,4,113,2,115,2
NPCDialoguePutCharacter:
  ld    b,8                                 ;font height
  .loop:
  push  hl
	xor   a
	call	SetVdp_Write	
  pop   hl
  ld    de,128
  add   hl,de

  exx
  ld    c,$98
  ld    b,d                                 ;font lenght in bytes (1 byte is 2 pixels)
  push  hl
  otir                                      ;copy line
  pop   hl
  ld    bc,128
  add   hl,bc
  exx

  djnz  .loop
  
  exx
  ld    a,(ix+enemies_and_objects.v5)       ;v5=add to dx character
  add   a,d                                 ;add font lenght
  ld    (ix+enemies_and_objects.v5),a       ;v5=add to dx character
  ret

Transition001:
  db    +082-000,+082-002,+082-004,+082-006,+082-008,+082-010,+082-012,+082-014,+082-016,+082-018
  db    +082-020,+082-022,+082-024,+082-026,+082-028,+082-030,+082-032,+082-034,+082-036,+082-038
  db    +082-040,+082-042,+082-044,+082-046,+082-048,+082-050,+082-052,+082-054,+082-056,+082-058
  db    +082-060,+082-062,+082-064,+082-066,+082-068,+082-070,+082-072,+082-074,+082-076

Transition002:
;normal scoreboard
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000

Transition003:
;normal text background
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000

Transition004:
;black background line everywhere
  db    +083+039,+083+038,+083+037,+083+036,+083+035,+083+034,+083+033,+083+032,+083+031,+083+030
  db    +083+029,+083+028,+083+027,+083+026,+083+025,+083+024,+083+023,+083+022,+083+021,+083+020
  db    +083+019,+083+018,+083+017,+083+016,+083+015,+083+014,+083+013,+083+012,+083+011,+083+010
  db    +083+009,+083+008,+083+007,+083+006,+083+005,+083+004,+083+003,+083+002,+083+001

blackL01: equ +083+039
blackL02: equ +083+038
blackL03: equ +083+037
blackL04: equ +083+036
blackL05: equ +083+035
blackL06: equ +083+034
blackL07: equ +083+033
blackL08: equ +083+032
blackL09: equ +083+031
blackL10: equ +083+030
blackL11: equ +083+029
blackL12: equ +083+028
blackL13: equ +083+027
blackL14: equ +083+026
blackL15: equ +083+025
blackL16: equ +083+024
blackL17: equ +083+023
blackL18: equ +083+022
blackL19: equ +083+021
blackL20: equ +083+020
blackL21: equ +083+019
blackL22: equ +083+018
blackL23: equ +083+017
blackL24: equ +083+016
blackL25: equ +083+015
blackL26: equ +083+014
blackL27: equ +083+013
blackL28: equ +083+012
blackL29: equ +083+011
blackL30: equ +083+010
blackL31: equ +083+009
blackL32: equ +083+008
blackL33: equ +083+007
blackL34: equ +083+006
blackL35: equ +083+005
blackL36: equ +083+004
blackL37: equ +083+003
blackL38: equ +083+002
blackL39: equ +083+001

ScoreBoardVanishInward001:
;normal scoreboard
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000

ScoreBoardVanishInward002:
;normal scoreboard 001 pix inward
  db    blackL01,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001
  db    +044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001,+044-001
  db    +044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001
  db    +044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,+044+001,blackL39

ScoreBoardVanishInward003:
;normal scoreboard 002 pix inward
  db    blackL01,blackL02,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002
  db    +044-002,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002,+044-002
  db    +044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002
  db    +044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002,+044+002,blackL38,blackL39

ScoreBoardVanishInward004:
;normal scoreboard 003 pix inward
  db    blackL01,blackL02,blackL03,+044-003,+044-003,+044-003,+044-003,+044-003,+044-003,+044-003
  db    +044-003,+044-003,+044-003,+044-003,+044-003,+044-003,+044-003,+044-003,+044-003
  db    +044+003,+044+003,+044+003,+044+003,+044+003,+044+003,+044+003,+044+003,+044+003,+044+003
  db    +044+003,+044+003,+044+003,+044+003,+044+003,+044+003,+044+003,blackL37,blackL38,blackL39

ScoreBoardVanishInward005:
;normal scoreboard 004 pix inward
  db    blackL01,blackL02,blackL03,blackL04,+044-004,+044-004,+044-004,+044-004,+044-004,+044-004
  db    +044-004,+044-004,+044-004,+044-004,+044-004,+044-004,+044-004,+044-004,+044-004
  db    +044+004,+044+004,+044+004,+044+004,+044+004,+044+004,+044+004,+044+004,+044+004,+044+004
  db    +044+004,+044+004,+044+004,+044+004,+044+004,+044+004,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward006:
;normal scoreboard 005 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,+044-005,+044-005,+044-005,+044-005,+044-005
  db    +044-005,+044-005,+044-005,+044-005,+044-005,+044-005,+044-005,+044-005,+044-005
  db    +044+005,+044+005,+044+005,+044+005,+044+005,+044+005,+044+005,+044+005,+044+005,+044+005
  db    +044+005,+044+005,+044+005,+044+005,+044+005,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward007:
;normal scoreboard 006 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,+044-006,+044-006,+044-006,+044-006
  db    +044-006,+044-006,+044-006,+044-006,+044-006,+044-006,+044-006,+044-006,+044-006
  db    +044+006,+044+006,+044+006,+044+006,+044+006,+044+006,+044+006,+044+006,+044+006,+044+006
  db    +044+006,+044+006,+044+006,+044+006,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward008:
;normal scoreboard 007 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,+044-007,+044-007,+044-007
  db    +044-007,+044-007,+044-007,+044-007,+044-007,+044-007,+044-007,+044-007,+044-007
  db    +044+007,+044+007,+044+007,+044+007,+044+007,+044+007,+044+007,+044+007,+044+007,+044+007
  db    +044+007,+044+007,+044+007,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward009:
;normal scoreboard 008 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,+044-008,+044-008
  db    +044-008,+044-008,+044-008,+044-008,+044-008,+044-008,+044-008,+044-008,+044-008
  db    +044+008,+044+008,+044+008,+044+008,+044+008,+044+008,+044+008,+044+008,+044+008,+044+008
  db    +044+008,+044+008,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward010:
;normal scoreboard 009 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,+044-009
  db    +044-009,+044-009,+044-009,+044-009,+044-009,+044-009,+044-009,+044-009,+044-009
  db    +044+009,+044+009,+044+009,+044+009,+044+009,+044+009,+044+009,+044+009,+044+009,+044+009
  db    +044+009,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward011:
;normal scoreboard 010 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    +044-010,+044-010,+044-010,+044-010,+044-010,+044-010,+044-010,+044-010,+044-010
  db    +044+010,+044+010,+044+010,+044+010,+044+010,+044+010,+044+010,+044+010,+044+010,+044+010
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward012:
;normal scoreboard 011 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,+044-011,+044-011,+044-011,+044-011,+044-011,+044-011,+044-011,+044-011
  db    +044+011,+044+011,+044+011,+044+011,+044+011,+044+011,+044+011,+044+011,+044+011,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward013:
;normal scoreboard 012 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,+044-012,+044-012,+044-012,+044-012,+044-012,+044-012,+044-012
  db    +044+012,+044+012,+044+012,+044+012,+044+012,+044+012,+044+012,+044+012,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward014:
;normal scoreboard 013 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,+044-013,+044-013,+044-013,+044-013,+044-013,+044-013
  db    +044+013,+044+013,+044+013,+044+013,+044+013,+044+013,+044+013,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward015:
;normal scoreboard 014 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,+044-014,+044-014,+044-014,+044-014,+044-014
  db    +044+014,+044+014,+044+014,+044+014,+044+014,+044+014,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward016:
;normal scoreboard 015 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,+044-015,+044-015,+044-015,+044-015
  db    +044+015,+044+015,+044+015,+044+015,+044+015,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward017:
;normal scoreboard 016 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,+044-016,+044-016,+044-016
  db    +044+016,+044+016,+044+016,+044+016,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward018:
;normal scoreboard 017 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,+044-017,+044-017
  db    +044+017,+044+017,+044+017,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward019:
;normal scoreboard 018 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,+044-018
  db    +044+018,+044+018,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward020:
;normal scoreboard 019 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,blackL19
  db    +044+019,blackL21,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward021:  ;part where the white line becomes smaller
;normal scoreboard 019 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,blackL19
  db  blackL20+1,blackL21,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward022:
;normal scoreboard 019 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,blackL19
  db  blackL20+2,blackL21,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward023:
;normal scoreboard 019 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,blackL19
  db  blackL20+3,blackL21,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

ScoreBoardVanishInward024:  ;totally black part
;normal scoreboard 020 pix inward
  db    blackL01,blackL02,blackL03,blackL04,blackL05,blackL06,blackL07,blackL08,blackL09,blackL10
  db    blackL11,blackL12,blackL13,blackL14,blackL15,blackL16,blackL17,blackL18,blackL19
  db    blackL20,blackL21,blackL22,blackL23,blackL24,blackL25,blackL26,blackL27,blackL28,blackL29
  db    blackL30,blackL31,blackL32,blackL33,blackL34,blackL35,blackL36,blackL37,blackL38,blackL39

















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


