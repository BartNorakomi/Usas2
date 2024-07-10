phase	movementpatterns2Address

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

PutSf2Object5FramesGoat:
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

;ld    (ix+enemies_and_objects.v7),155/5

SetFrameBossGoat:
  add   hl,hl                               ;*2
  add   hl,hl                               ;*4
  add   hl,de                               ;frame * 12 + frame address

  .SetFrameSF2Object:

;ld hl,BossGoatAttack159
  
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
;SDMika00:   dw CharacterFacesframe000 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika01:   dw CharacterFacesframe001 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika02:   dw CharacterFacesframe002 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika03:   dw CharacterFacesframe003 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika04:   dw CharacterFacesframe004 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika05:   dw CharacterFacesframe005 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika06:   dw CharacterFacesframe006 | db CharacterFacesframelistblock, CharacterFacesspritedatablock
;SDMika07:   dw CharacterFacesframe007 | db CharacterFacesframelistblock, CharacterFacesspritedatablock






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


















































































Y_Portrait_Mika: equ 048
X_Portrait_Mika: equ 074
SDMika:
;v1-5=pointer for button rotator
;v1-4=ScoreBoardVanishInward001 step 
;v1-3=sy and dy copy font and textbackground
;v1-2=x white line dissapearing inward left side
;v1-1=x white line dissapearing inward right side
;v1=dy top part of white line
;v2=dy bottom part of white line
;v3=top border of portrait backdrop
;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)  
;v5=add to dx character (text to screen)
;v6=pointer to character (text to screen) 
;v7=pointer to WhiteSquareOutlines table
;v8=phase
;v9=y black line
;v10=add to dy character (text to screen)
  .HandlePhase:
  ld    a,1
  call  SetSF2DisplayPage         ;force page 1 to be the active page at all times

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
  or    a
  jp    z,SetFontAndBackground              ;0=set text background and font at (0,0) page 0, and copy of the empty text background at (0,66)
  dec   a
  jp    z,SetCharacterPortraits             ;1=set the character portrait at (0,114)
  dec   a
  jp    z,SDMikaWaitingPlayerNear           ;2=waiting player near and pressing trig-a
  dec   a 
  jp    z,SDMikaSwitchToTextBackground      ;3=remove scoreboard and show text background AND ***** DisplayCharacterPortrait *****
  dec   a
  jp    z,SDMikaPutText                     ;4=put text AND *** MouthMovement and EyesMovement
  dec   a
  jp    z,SDMikaSwitchToScoreboard          ;5=restore scoreboard AND ***** RemoveCharacterPortrait *****
  ret

FillCharacter8x8Block:
  db    000,000,105,000   ;sx,--,sy,spage
  db    050,000,048,001   ;dx,--,dy,dpage
  db    056,000,056,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

FillCharacter8x8BlockWhiteOutline:
  db    056,000,048+105,000   ;sx,--,sy,spage
  db    050,000,048,001   ;dx,--,dy,dpage
  db    008,000,008,000   ;nx,--,ny,--
  db    000,%0000 0000,$98       ;fast copy -> Copy from right to left     

RemoveCharacterPortrait:                    ;this routine is executed during SDMikaSwitchToScoreboard
  ld    a,(ix+enemies_and_objects.v4)       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)
  sub   4
  jp    z,.WhiteLineVerticallyInward        ;4 
  dec   a
  jp    z,.WhiteLineHorizontallyInward      ;5 
  ret

.WhiteLineVerticallyInward:
;from top to middle
  ;first put the white line
  ld    a,002
  ld    (FreeToUseFastCopy+sx),a
  ld    a,000
  ld    (FreeToUseFastCopy+sy),a

;  ld    a,(ix+enemies_and_objects.v2)       ;dy bottom part of white line
  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  inc   a
  ld    (FreeToUseFastCopy+dy),a

  ld    a,001
  ld    (FreeToUseFastCopy+ny),a
  ld    a,56
  ld    (FreeToUseFastCopy+nx),a
  ld    a,0
  ld    (FreeToUseFastCopy+sPage),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ;then recover the line above the white line
  ld    a,(FreeToUseFastCopy+dx)
  ld    (FreeToUseFastCopy+sx),a

  ld    a,(ix+enemies_and_objects.v1)       ;v1=dy top part of white line
  ld    (FreeToUseFastCopy+dy),a
  ld    (FreeToUseFastCopy+sy),a
  ld    a,2
  ld    (FreeToUseFastCopy+sPage),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy
  
  ld    a,(ix+enemies_and_objects.v1)       ;dy
  inc   a
  ld    (ix+enemies_and_objects.v1),a       ;dy
  
;from bottom to middle
  ;first put the white line
  ld    a,002
  ld    (FreeToUseFastCopy+sx),a
  ld    a,000
  ld    (FreeToUseFastCopy+sy),a

  ld    a,(ix+enemies_and_objects.v2)       ;v1=dy top part of white line
  ld    (FreeToUseFastCopy+dy),a

  ld    a,0
  ld    (FreeToUseFastCopy+sPage),a
  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ;then recover the line below the white line
  ld    a,(FreeToUseFastCopy+dx)
  ld    (FreeToUseFastCopy+sx),a

  ld    a,(ix+enemies_and_objects.v2)       ;v2=dy bottom part of white line
  inc   a
  ld    (FreeToUseFastCopy+dy),a
  ld    (FreeToUseFastCopy+sy),a
  ld    a,2
  ld    (FreeToUseFastCopy+sPage),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy
  
  ld    a,(ix+enemies_and_objects.v2)       ;dy
  dec   a
  ld    (ix+enemies_and_objects.v2),a       ;dy

  cp    Y_Portrait_Mika+26
  ret   nz
  ld    (ix+enemies_and_objects.v4),5       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)

  ld    a,(FreeToUseFastCopy+dx)
  ld    (ix+enemies_and_objects.v1-2),a     ;v1-2=x white line dissapearing inward left side
  add   a,56-8
  ld    (ix+enemies_and_objects.v1-1),a     ;v1-1=x white line dissapearing inward right side
  ret

.WhiteLineHorizontallyInward:
  ;then recover 8 pixels left side
  ld    a,8
  ld    (FreeToUseFastCopy+nx),a

  ld    a,(ix+enemies_and_objects.v1-2)     ;v1-2=x white line dissapearing inward left side
  ld    (FreeToUseFastCopy+sx),a
  ld    (FreeToUseFastCopy+dx),a

  ld    a,(ix+enemies_and_objects.v2)       ;dy bottom part of white line
  inc   a
  ld    (FreeToUseFastCopy+dy),a
  ld    (FreeToUseFastCopy+sy),a
  ld    a,2
  ld    (FreeToUseFastCopy+sPage),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ;then recover 8 pixels right side
  ld    a,(ix+enemies_and_objects.v1-1)     ;v1-1=x white line dissapearing inward right side
  ld    (FreeToUseFastCopy+sx),a
  ld    (FreeToUseFastCopy+dx),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ld    a,(ix+enemies_and_objects.v1-2)     ;v1-2=x white line dissapearing inward left side
  add   a,3
  ld    (ix+enemies_and_objects.v1-2),a     ;v1-2=x white line dissapearing inward left side
  ld    a,(ix+enemies_and_objects.v1-1)     ;v1-1=x white line dissapearing inward right side
  sub   a,3
  ld    (ix+enemies_and_objects.v1-1),a     ;v1-1=x white line dissapearing inward right side
  ret

DisplayCharacterPortrait:                   ;this routine is executed during SDMikaSwitchToTextBackground
  xor   a
  ld    (FreeToUseFastCopy+sPage),a
  ld    a,1
  ld    (FreeToUseFastCopy+dPage),a

  ld    a,(ix+enemies_and_objects.v4)       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)
  or    a
  jp    z,.SetVariables                     ;0 SetVariables
  dec   a
  jp    z,.WhiteLine                        ;1 WhiteLine
  dec   a
  jp    z,.StretchWhiteLine                 ;2 StretchWhiteLine up and down
  dec   a
  jp    z,.FillCharacter                    ;3 FillCharacter
  ret
  
  .FillCharacter:
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  call  .RepeatThisRoutine
  
  .RepeatThisRoutine:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=pointer to WhiteSquareOutlines table
  inc   a
  ld    (ix+enemies_and_objects.v7),a       ;v7=pointer to WhiteSquareOutlines table
 
;set character portrait in 4x4 blocks
  ld    a,(ix+enemies_and_objects.v7)       ;v7=pointer to WhiteSquareOutlines table
  ld    d,0
  ld    e,a
  ld    hl,.dydxtable-2
  add   hl,de                               
  add   hl,de   
  ld    a,114                               ;add to sy; character portrait is in page 0 at (0,114)
  add   a,(hl)                              ;add to relative dy
;  inc   a
  ld    (FreeToUseFastCopy+sy),a
  inc   hl                                  ;relative dx
  ld    a,(hl)
  ld    (FreeToUseFastCopy+sx),a

  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  inc   a
  ld    (FreeToUseFastCopy+dy),a
  ld    a,004
  ld    (FreeToUseFastCopy+ny),a
  ld    (FreeToUseFastCopy+nx),a

  ld    a,074-28
  ld    (FreeToUseFastCopy+dx),a

  ld    d,0
  ld    e,(ix+enemies_and_objects.v7)       ;v7=pointer to WhiteSquareOutlines table
  ld    hl,.dydxtable-2
  add   hl,de                               ;dy
  add   hl,de                               
  ld    a,(FreeToUseFastCopy+dy)
  add   a,(hl)
  ld    (FreeToUseFastCopy+dy),a
  inc   hl                                  ;dx
  ld    a,(FreeToUseFastCopy+dx)
  add   a,(hl)
  ld    (FreeToUseFastCopy+dx),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ld    a,(ix+enemies_and_objects.v7)       ;v7=pointer to WhiteSquareOutlines table
  cp    193
  ret   c
  ld    (ix+enemies_and_objects.v4),4       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)

;  ld    a,(FreeToUseFastCopy+dx)
;  sub   a,52
;  ld    (FreeToUseFastCopy+dx),a
  ret
  
  .dydxtable: ;relative y, relative x
;circular appearance of character portrait
  db  024,024, 024,028, 028,024, 028,028, 024,024, 024,028, 028,024, 028,028
  db  020,024, 020,028, 032,024, 032,028, 024,020, 024,032, 028,020, 028,032
  db  020,020, 016,024, 016,028, 020,032, 032,020, 032,032, 036,024, 036,028
  db  012,024, 016,032, 024,036, 032,036, 040,028, 036,020, 028,016, 020,016
  db  012,028, 020,036, 028,036, 036,032, 040,024, 032,016, 024,016, 016,020
  db  008,028, 016,036, 024,040, 032,040, 040,032, 044,024, 036,016, 028,012
  db  012,032, 020,040, 028,040, 036,036, 044,028, 040,020, 032,012, 024,012
  db  020,012, 008,024, 008,032, 020,044, 032,044, 044,032, 044,020, 032,008
  db  016,016, 012,020, 012,036, 024,044, 036,040, 048,028, 040,016, 024,008
  db  004,028, 016,040, 028,044, 040,036, 048,024, 036,012, 028,008, 020,008
  db  016,012, 008,020, 008,036, 024,048, 040,040, 052,024, 036,008, 020,004
  db  012,016, 004,024, 012,040, 028,048, 044,036, 048,020, 032,004, 016,008
  db  000,028, 016,044, 032,048, 048,032, 044,016, 028,004, 012,012, 004,020
  db  004,032, 020,048, 036,044, 052,028, 040,012, 024,004, 008,016, 000,024
  db  000,032, 012,044, 024,052, 036,048, 048,036, 048,016, 036,004, 024,000
  db  004,036, 016,048, 028,052, 040,044, 052,032, 044,012, 032,000, 020,000
  db  008,040, 020,052, 032,052, 044,040, 052,020, 040,008, 028,000, 016,004
  db  012,008, 008,012, 004,016, 000,020, 000,036, 016,052, 048,040, 044,008
  db  004,040, 036,052, 052,036, 040,004, 012,004, 000,040, 040,052, 052,012
  db  008,044, 040,048, 052,016, 036,000, 008,008, 004,044, 044,048, 048,008
  db  012,048, 044,044, 048,012, 016,000, 004,012, 008,048, 048,044, 044,004
  db  012,052, 052,040, 040,000, 008,004, 000,016, 000,044, 048,048, 044,000
  db  012,000, 004,008, 000,012, 004,048, 052,044, 008,000, 000,048, 052,048
  db  008,052, 052,008, 004,004, 004,052, 052,004, 004,000, 000,052, 052,000
  db  044,052, 048,004, 000,008, 048,052, 048,000, 000,004, 052,052, 000,000
    
;line by line top down appearance of character portrait
;  db  000,000, 000,004, 000,008, 000,012, 000,016, 000,020, 000,024, 000,028, 000,032, 000,036, 000,040, 000,044, 000,048, 000,052 
;  db  004,000, 004,004, 004,008, 004,012, 004,016, 004,020, 004,024, 004,028, 004,032, 004,036, 004,040, 004,044, 004,048, 004,052 
;  db  008,000, 008,004, 008,008, 008,012, 008,016, 008,020, 008,024, 008,028, 008,032, 008,036, 008,040, 008,044, 008,048, 008,052 
;  db  012,000, 012,004, 012,008, 012,012, 012,016, 012,020, 012,024, 012,028, 012,032, 012,036, 012,040, 012,044, 012,048, 012,052 
;  db  016,000, 016,004, 016,008, 016,012, 016,016, 016,020, 016,024, 016,028, 016,032, 016,036, 016,040, 016,044, 016,048, 016,052 
;  db  020,000, 020,004, 020,008, 020,012, 020,016, 020,020, 020,024, 020,028, 020,032, 020,036, 020,040, 020,044, 020,048, 020,052 
;  db  024,000, 024,004, 024,008, 024,012, 024,016, 024,020, 024,024, 024,028, 024,032, 024,036, 024,040, 024,044, 024,048, 024,052 
;  db  028,000, 028,004, 028,008, 028,012, 028,016, 028,020, 028,024, 028,028, 028,032, 028,036, 028,040, 028,044, 028,048, 028,052 
;  db  032,000, 032,004, 032,008, 032,012, 032,016, 032,020, 032,024, 032,028, 032,032, 032,036, 032,040, 032,044, 032,048, 032,052 
;  db  036,000, 036,004, 036,008, 036,012, 036,016, 036,020, 036,024, 036,028, 036,032, 036,036, 036,040, 036,044, 036,048, 036,052 
;  db  040,000, 040,004, 040,008, 040,012, 040,016, 040,020, 040,024, 040,028, 040,032, 040,036, 040,040, 040,044, 040,048, 040,052 
;  db  044,000, 044,004, 044,008, 044,012, 044,016, 044,020, 044,024, 044,028, 044,032, 044,036, 044,040, 044,044, 044,048, 044,052 
;  db  048,000, 048,004, 048,008, 048,012, 048,016, 048,020, 048,024, 048,028, 048,032, 048,036, 048,040, 048,044, 048,048, 048,052 
;  db  052,000, 052,004, 052,008, 052,012, 052,016, 052,020, 052,024, 052,028, 052,032, 052,036, 052,040, 052,044, 052,048, 052,052, 052,040, 052,044, 052,048, 052,052

  .StretchWhiteLine:
  ;start by creating the portrait backdrop. From the middle outward up
  ld    a,054
  ld    (FreeToUseFastCopy+sy),a
  ld    a,142
  ld    (FreeToUseFastCopy+sx),a

  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  ld    (FreeToUseFastCopy+dy),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy

  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  dec   a
  ld    (ix+enemies_and_objects.v1),a       ;dy top part of white line

  ;now from the middle outward down
  ld    a,053
  ld    (FreeToUseFastCopy+sy),a

  ld    a,(ix+enemies_and_objects.v2)       ;dy bottom part of white line
  ld    (FreeToUseFastCopy+dy),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy
    
  ld    a,(ix+enemies_and_objects.v2)       ;dy bottom part of white line
  inc   a
  ld    (ix+enemies_and_objects.v2),a       ;dy bottom part of white line

  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  cp    (ix+enemies_and_objects.v3)         ;v3=top border of portrait backdrop
  ret   nz
  ld    (ix+enemies_and_objects.v4),3       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)  
  ret

  .WhiteLine:
  ld    a,002
  ld    (FreeToUseFastCopy+sx),a
  ld    a,000
  ld    (FreeToUseFastCopy+sy),a

  ld    a,(ix+enemies_and_objects.v1)       ;dy
  ld    (FreeToUseFastCopy+dy),a
  ld    a,001
  ld    (FreeToUseFastCopy+ny),a

  ld    a,(FreeToUseFastCopy+dx)
  sub   a,4
  ld    (FreeToUseFastCopy+dx),a
  ld    a,(FreeToUseFastCopy+nx)
  add   a,8
  ld    (FreeToUseFastCopy+nx),a

  ld    hl,FreeToUseFastCopy
  call  DoCopy  

  ld    a,(FreeToUseFastCopy+nx)
  cp    56
  ret   nz
  ld    (ix+enemies_and_objects.v4),2       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block) 

  xor   a
  ld    (FreeToUseFastCopy+sx),a
  ld    a,056
  ld    (FreeToUseFastCopy+nx),a
  ld    a,002
  ld    (FreeToUseFastCopy+ny),a

  ld    a,(ix+enemies_and_objects.v1)       ;dy top part of white line
  ld    (ix+enemies_and_objects.v2),a       ;dy bottom part of white line
  dec   (ix+enemies_and_objects.v1)         ;dy top part of white line
  dec   (ix+enemies_and_objects.v1)         ;dy top part of white line
  sub   29
  ld    (ix+enemies_and_objects.v3),a       ;top border of portrait backdrop
  ret

  .SetVariables:
  ld    (ix+enemies_and_objects.v1),Y_Portrait_Mika+28     ;dy middle of portrait backdrop
  ld    a,X_Portrait_Mika
  ld    (FreeToUseFastCopy+dx),a            ;dx middle of portrait backdrop
  ld    a,000
  ld    (FreeToUseFastCopy+nx),a
  ld    (ix+enemies_and_objects.v4),1       ;v4=Character Portrait Buildup Phase (0=set variables, 1=show white line outward, 2=stretch out white line up and down, 3=fill in character block by block)
  ret

CopyEmptyTextbackgroundOverNormalTextBackground:
  db    002,000,075+2,000   ;sx,--,sy,spage
  db    002,000,002,000   ;dx,--,dy,dpage
  db    252,000,036,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

  SDMikaSwitchToScoreboard:                 ;3=restore scoreboard  
  call  RemoveCharacterPortrait

  ld    a,(ix+enemies_and_objects.nx)       ;in/out scoreboard/text background timer
  inc   a
  ld    (ix+enemies_and_objects.nx),a       ;in/out scoreboard/text background timer
  cp    150  
  ld    b,+1                                ;vanish inward
  ld    c,39                                ;text background
  jp    c,ScoreBoardTextBackgroundTransition
  cp    200  
  ld    b,-1                                ;appear from the inside out
  ld    c,00                                ;scoreboard
  jp    c,ScoreBoardTextBackgroundTransition

  xor   a
  ld    (freezecontrols?),a  
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
  ld    (ix+enemies_and_objects.nx),0       ;in/out scoreboard/text background timer

  ld    a,(ix+enemies_and_objects.v11)
  inc   a
  and   7
  ld    (ix+enemies_and_objects.v11),a    

  ld    hl,CopyEmptyTextbackgroundOverNormalTextBackground
  call  DoCopy

  ld    a,3
  ld    (CopyCharacter+dx),a
  ld    (CopyCharacter+dy),a
  ld    (ix+enemies_and_objects.v6),0       ;v6=pointer to character  
  ret  

  SDMikaPutText:
  call  CheckVdpReady                       ;out: c=vdp busy, nc=vdp ready
  ret   c
  
  call  ShowNormalTextBackground
  
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
  dec   a
  ld    hl,NPCDialogueText4
  jr    z,.go
  dec   a
  ld    hl,NPCDialogueText5
  jr    z,.go
  dec   a
  ld    hl,NPCDialogueText6
  jr    z,.go
  dec   a
  ld    hl,NPCDialogueText7
  jr    z,.go
  ld    hl,NPCDialogueText8
  .go:
  call  NPCDialogueputText
  call  EyesMovement
  ret

  SDMikaSwitchToTextBackground:
  call  DisplayCharacterPortrait
  
  ld    hl,LineIntNPCInteractions
  ld    (InterruptHandler.SelfmodyfyingLineIntRoutine),hl

  ld    a,(ix+enemies_and_objects.nx)       ;in/out scoreboard/text background timer
  inc   a
  ld    (ix+enemies_and_objects.nx),a       ;in/out scoreboard/text background timer
  cp    050  
  ld    b,+1                                ;vanish inward
  ld    c,00                                ;scoreboard
  jr    c,ScoreBoardTextBackgroundTransition
  cp    090  
  ld    b,-1                                ;appear from the inside out
  ld    c,39                                ;text background
  jr    c,ScoreBoardTextBackgroundTransition
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
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

  SetCharacterPortraits:                    ;set the character portrait at (0,114)
	ld    a,CharacterPortraitsBlock
  call	block12

  ;set dy
  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
	xor   a
	ld    hl,128 * 114 - 128
  ld    de,128
  .loop:
  add   hl,de
  djnz  .loop
	call	SetVdp_Write                        ;write font and background to (0,0) in page 0

  ;set sy
  ;add the extra text background below all the rest
  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
  ld    hl,CharacterPortraits  - 128
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
  cp    56+1                                ;total height font character portraits
  jr    nz,.EndCheckLastLineCopied
  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
  .EndCheckLastLineCopied:

  ;set the general movement pattern block at address $4000 in page 1
	ld    a,MovementPatternsFixedPage1block
  call	block12
  ret
  
  SetFontAndBackground:                     ;set text background and font at (0,0) page 0, and copy of the text background at (0,66)
	ld    a,NPCDialogueFontBlock
  call	block12

  ;set dy
  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
	xor   a
	ld    hl,0 - 128
  ld    de,128
  .loop:
  add   hl,de
  djnz  .loop
	call	SetVdp_Write                        ;write font and background to (0,0) in page 0

  ;set sy
  ;add the extra text background below all the rest
  ld    b,(ix+enemies_and_objects.v1-3)     ;v1-3=sy and dy copy font and textbackground
  ld    a,b
  cp    67+9
  jr    c,.go
  sub   66+9
  ld    b,a
  .go:
  ;/add the extra text background below all the rest

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
  cp    67+39+9                             ;total height font and text-background
  jr    nz,.EndCheckLastLineCopied
  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
  ld    (ix+enemies_and_objects.v1-3),1     ;v1-3=sy and dy copy font and textbackground
  .EndCheckLastLineCopied:

  ;set the general movement pattern block at address $4000 in page 1
	ld    a,MovementPatternsFixedPage1block
  call	block12
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
  
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)
  ld    (ix+enemies_and_objects.v4),0       ;v4
  ld    (ix+enemies_and_objects.v7),0       ;v7
  ld    a,1
  ld    (freezecontrols?),a
  ret

CheckVdpReady:
  ld    a,32
  di
  out   ($99),a
  ld    a,17+128
  ei
  out   ($99),a
  ld    c,$9b

  ld    a,2
  di
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)
  rra
  ld    a,0
  out   ($99),a
  ld    a,15+128
  ei
  out   ($99),a
  ret
  
;                  SX,NX:    A     B     C     D     E     F     G     H     I     J     K     L     M     N     O     P     Q     R     S     T     U     V     W     X     Y     Z
NPCDialogueCharacDataBig: db 000,6,005,6,011,6,017,6,023,6,029,6,035,6,041,6,045,2,047,6,053,6,059,6,065,6,071,6,077,6,083,6,089,6,095,6,101,6,107,6,113,6,119,6,125,6,131,6,137,6,143,6
;                  SX,NX:    a     b     c     d     e     f     g     h     i     j     k     l     m     n     o     p     q     r     s     t     u     v     w     x     y     z     Space :     !     ?     ,     .     ;     '     "
NPCDialogueCharDataSmall: db 000,6,006,6,011,6,017,6,023,6,029,6,035,6,041,6,004,2,047,5,052,6,052,2,058,6,064,6,070,6,076,6,081,6,087,6,093,6,099,6,105,6,111,6,117,6,123,6,129,6,135,6,233,4,215,2,231,2,225,6,212,3,210,2,217,3,220,2,222,3
NPCDialogueputText:                         ;in: HL -> NPCDialogueText1    
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

  cp    $3b                                 ;semi colon
  jr    nz,.EndCheckSemiColon
  ld    a,$61 + 32
  .EndCheckSemiColon:

  cp    $27                                 ;quotation mark
  jr    nz,.EndCheckQuotationMark
  ld    a,$61 + 33
  .EndCheckQuotationMark:

  cp    255                                 ;end text
  jp    nz,.EndCheckInteractionFinished
  call  CloseMouth
  call  .CheckTriggerA                      ;check if space is pressed. out: nz if pressed
  jp    z,ShowButton
  ld    (ix+enemies_and_objects.v8),5       ;v8=Phase (0=set text background and font, 1=set character portrait, 2=wait player, 3=show text backdrop, 4=put text, 5=restore scoreboard)

  ld    hl,RemovebuttonPressed
  call  DoCopy
  ret
  .EndCheckInteractionFinished:

  cp    254                                 ;next line
  jp    nz,.EndCheckNextLine
  ld    a,(CopyCharacter+dy)                ;prepare dx+dy for next line
  add   a,11
  ld    (CopyCharacter+dy),a
  ld    a,3
  ld    (CopyCharacter+dx),a
  inc   (ix+enemies_and_objects.v6)         ;v6=pointer to character  
  inc   hl
  ld    a,(hl)
  .EndCheckNextLine:

  cp    253                                 ;clear text field
  jr    nz,.EndCheckClearText
  call  CloseMouth
  call  .CheckTriggerA                      ;check if space is pressed. out: nz if pressed
  jp    z,ShowButton
  ret   z
  ld    a,3                                 ;set dx and dy for new text to come
  ld    (CopyCharacter+dx),a
  ld    (CopyCharacter+dy),a
  inc   (ix+enemies_and_objects.v6)         ;v6=pointer to character  
  push  hl
  ld    hl,CopyEmptyTextbackgroundOverNormalTextBackground
  call  DoCopy
  call  ShowEmptyTextBackground  
  pop   hl  
  ret
  .EndCheckClearText:
  
  inc   (ix+enemies_and_objects.v6)         ;v6=pointer to character  

  cp    $61
  jr    nc,.EndCheckCapitalLetters
  ;Capital letters
  sub   $41
  add   a,a                                 ;*2
  ld    d,0
  ld    e,a
  ld    hl,NPCDialogueCharacDataBig
  add   hl,de
  ld    a,044
  ld    (CopyCharacter+sy),a  
  ld    a,009
  ld    (CopyCharacter+ny),a  
  jr    .go
  .EndCheckCapitalLetters:

  cp    $61 + 26
  jr    c,.EndCheckSymbols
  ;Symbols
  sub   $61
  add   a,a                                 ;*2
  ld    d,0
  ld    e,a
  ld    hl,NPCDialogueCharDataSmall
  add   hl,de
  ld    a,044
  ld    (CopyCharacter+sy),a  
  ld    a,009
  ld    (CopyCharacter+ny),a  
  jr    .go 
  .EndCheckSymbols:

  ;Small letters
  sub   $61
  add   a,a                                 ;*2
  ld    d,0
  ld    e,a
  ld    hl,NPCDialogueCharDataSmall
  add   hl,de
  ld    a,044+9
  ld    (CopyCharacter+sy),a  
  ld    a,013
  ld    (CopyCharacter+ny),a  

  .go:
  ld    a,(hl)                              ;Character Start X
  ld    (CopyCharacter+sx),a
  inc   hl 
  ld    a,(hl)                              ;nx
  ld    (CopyCharacter+nx),a

  ld    hl,CopyCharacter
  call  DoCopy

  ld    a,(CopyCharacter+nx)                ;prepare dx for next character
  inc   a
  ld    b,a                                 ;nx + 1
  ld    a,(CopyCharacter+dx)
  add   a,b
  ld    (CopyCharacter+dx),a

  call  MouthMovement
  ret

  .CheckTriggerA:                           ;check if space is pressed. out: nz if pressed
  push  de
  push  hl
  
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

  pop   hl
  pop   de
  ret

EyesMovement:
  ld    hl,FreeToUseFastCopy2

  xor   a
  ld    (FreeToUseFastCopy2+sPage),a
  ld    a,1
  ld    (FreeToUseFastCopy2+dPage),a

  ld    a,Y_Portrait_Mika
  add   a,31
  ld    (FreeToUseFastCopy2+dy),a
  
  ld    a,X_Portrait_Mika
  add   a,-12
  ld    (FreeToUseFastCopy2+dx),a

  ld    a,022
  ld    (FreeToUseFastCopy2+nx),a
  ld    a,006
  ld    (FreeToUseFastCopy2+ny),a
  ld    a,056
  ld    (FreeToUseFastCopy2+sx),a

  ld    a,105+9                             ;sy closed eyes
  ld    (FreeToUseFastCopy2+sy),a

  ld    a,(framecounter)
  cp    1
  jp    z,DoCopy
  cp    8
  ld    a,111+9                             ;sy open eyes
  ld    (FreeToUseFastCopy2+sy),a
  jp    z,DoCopy
  ret

MouthMovement:
  ld    hl,FreeToUseFastCopy2

  xor   a
  ld    (FreeToUseFastCopy2+sPage),a
  ld    a,1
  ld    (FreeToUseFastCopy2+dPage),a

  ld    a,Y_Portrait_Mika
  add   a,42
  ld    (FreeToUseFastCopy2+dy),a
  
  ld    a,X_Portrait_Mika
  add   a,-04
  ld    (FreeToUseFastCopy2+dx),a

  ld    a,006
  ld    (FreeToUseFastCopy2+nx),a
  ld    a,006
  ld    (FreeToUseFastCopy2+ny),a
  ld    a,117+9
  ld    (FreeToUseFastCopy2+sy),a

  ld    a,056                               ;sx mouth open
  ld    (FreeToUseFastCopy2+sx),a
  ld    a,(framecounter)
  and   7
  cp    4
  jp    c,DoCopy
  ld    a,062                               ;sx mouth closed
  ld    (FreeToUseFastCopy2+sx),a
  jp    DoCopy

CloseMouth:
  ld    hl,FreeToUseFastCopy2

  xor   a
  ld    (FreeToUseFastCopy2+sPage),a
  ld    a,1
  ld    (FreeToUseFastCopy2+dPage),a

  ld    a,Y_Portrait_Mika
  add   a,42
  ld    (FreeToUseFastCopy2+dy),a
  
  ld    a,X_Portrait_Mika
  add   a,-04
  ld    (FreeToUseFastCopy2+dx),a

  ld    a,006
  ld    (FreeToUseFastCopy2+nx),a
  ld    a,006
  ld    (FreeToUseFastCopy2+ny),a
  ld    a,117+9
  ld    (FreeToUseFastCopy2+sy),a

  ld    a,062                               ;sx mouth closed
  ld    (FreeToUseFastCopy2+sx),a
  jp    DoCopy

;Y_Portrait_Mika: equ 048
;X_Portrait_Mika: equ 074


ShowNormalTextBackground:
  ld    hl,NormalTextBackground             ;show normal Text Background
  jr    ShowEmptyTextBackground.entry

ShowEmptyTextBackground:
  ;show empty Text Background
  ld    hl,EmptyTextBackground              ;show empty Text Background
  .entry:
  ld    de,NPCtableForR23
  ld    b,39
  .loop:
  ld    a,(hl)  
  ld    (de),a
  inc   hl
  inc   de
  inc   de
  djnz  .loop
  ret

ShowButton:
  ld    a,(framecounter)
  and   3
  ret   nz

  ld    a,(ix+enemies_and_objects.v1-5)     ;v1-5=pointer for button rotator
  inc   a
  cp    28
  jr    nz,.SetPointer
  xor   a
  .SetPointer:
  ld    (ix+enemies_and_objects.v1-5),a     ;v1-5=pointer for button rotator
  cp    9
  jr    c,.Top
  .Bottom:  
  sub   a,9
  ld    b,a                                 ;*1
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  ld    c,a
  add   a,a                                 ;*8
  add   a,c                                 ;*12
  add   a,b                                 ;*13
  ld    (FreeToUseFastCopy2+sx),a  
  ld    a,066
  ld    (FreeToUseFastCopy2+sy),a
  jr    .go

  .Top:
  ld    b,a                                 ;*1
  add   a,a                                 ;*2
  add   a,a                                 ;*4
  ld    c,a
  add   a,a                                 ;*8
  add   a,c                                 ;*12
  add   a,b                                 ;*13
  add   a,141
  ld    (FreeToUseFastCopy2+sx),a  
  ld    a,057
  ld    (FreeToUseFastCopy2+sy),a
  
  .go:
  ld    a,027
  ld    (FreeToUseFastCopy2+dy),a
  ld    a,240
  ld    (FreeToUseFastCopy2+dx),a
  ld    a,009
  ld    (FreeToUseFastCopy2+ny),a
  ld    a,013
  ld    (FreeToUseFastCopy2+nx),a  
  xor   a
  ld    (FreeToUseFastCopy2+sPage),a
  ld    (FreeToUseFastCopy2+dPage),a

  ld    a,$90
  ld    (FreeToUseFastCopy2+copytype),a
  ld    hl,FreeToUseFastCopy2
  call  DoCopy
  ld    a,$D0
  ld    (FreeToUseFastCopy2+copytype),a
  ret

;ShowYellowButton1:
;  db    142,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    008,000,007,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left   

;ShowYellowButton2:
;  db    142+8,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    008,000,007,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left   

;ShowYellowButton3:
;  db    142+16,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    008,000,007,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left   

;ShowYellowButton4:
;  db    142+24,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    008,000,007,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left   

;ShowYellowButton5:
;  db    142+32,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    008,000,007,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left   

;ShowbuttonPressed:
;  db    182,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    012,000,011,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

;ShowbuttonUnPressed:
;  db    194,000,053,000   ;sx,--,sy,spage
;  db    240,000,027,000   ;dx,--,dy,dpage
;  db    012,000,011,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

RemovebuttonPressed:
  db    240,000,027+066,000   ;sx,--,sy,spage
  db    240,000,027,000   ;dx,--,dy,dpage
  db    013,000,009,000   ;nx,--,ny,--
  db    000,%0000 0000,$90       ;fast copy -> Copy from right to left     
 
;253=clear screen, 254 = next line, 255=end
NPCDialogueText2:  
  db "STOP... TOUCHING ME!!",254
  db "HELP!!!",254
  db "What's wrong with you?",253

  db "You: Oh sorry. I thought you",254
  db "were someone else; some hot chick",253

  db "Mika: My name is Mika.",254
  db "I dont belong in this game,",254
  db "but i dont give a shit!",253

  db "Little test here. All OK",254
  db "Terminating NPC INTERACTION",255

NPCDialogueText1:  
  db "Mika: ehhhhhh",254
  db "can you fucking stop",254
  db "harrassing me buddy?",255

NPCDialogueText3:  
  db "Mika: you think",254
  db "this is funny bro!?",255

NPCDialogueText4:  
  db "Mika: thats it",254
  db "im calling the police.",254
  db "you freak",255  

NPCDialogueText5:  
  db "Mika: 'STOP TOUCHING ME!!'",254
  db "You:  'grrrr...'",254
  db "Mika: 'what's wrong with you?'",255

NPCDialogueText6:  
  db "Mika: ''Buddy, listen.''",254
  db "Who the fuck are you ?",253

  db "You: I'm your worst nightmare",254
  db "and I will never stop tormenting you!",254
  db "hahahahahahhaah   ",253

  db "Mika: Dude, get a life",254
  db "idiot....",255

NPCDialogueText7:  
  db "Mika: Wanna buy some guns?",255

NPCDialogueText8:  
  db "Is your name: Robert, Maarten, Rieks,",254
  db "Ritchie, Bart or Laurens ?",255
  
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

;Transition001:
;  db    +082-000,+082-002,+082-004,+082-006,+082-008,+082-010,+082-012,+082-014,+082-016,+082-018
;  db    +082-020,+082-022,+082-024,+082-026,+082-028,+082-030,+082-032,+082-034,+082-036,+082-038
;  db    +082-040,+082-042,+082-044,+082-046,+082-048,+082-050,+082-052,+082-054,+082-056,+082-058
;  db    +082-060,+082-062,+082-064,+082-066,+082-068,+082-070,+082-072,+082-074,+082-076

;Transition002:
;normal scoreboard
;  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
;  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
;  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000
;  db    +044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000,+044+000

;Transition004:
;black background line everywhere
;  db    +083+039,+083+038,+083+037,+083+036,+083+035,+083+034,+083+033,+083+032,+083+031,+083+030
;  db    +083+029,+083+028,+083+027,+083+026,+083+025,+083+024,+083+023,+083+022,+083+021,+083+020
;  db    +083+019,+083+018,+083+017,+083+016,+083+015,+083+014,+083+013,+083+012,+083+011,+083+010
;  db    +083+009,+083+008,+083+007,+083+006,+083+005,+083+004,+083+003,+083+002,+083+001

NormalTextBackground:
;normal text background
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000
  db    +083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000,+083+000

EmptyTextBackground:
;empty text background
  db    +092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066
  db    +092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066
  db    +092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066
  db    +092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066,+092+066

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

;  ld    (ix+enemies_and_objects.v7),175/5   ;v7=sprite frame (0= idle, 50=walk, 110=attacking, 215-245=hit, 240-299 = dying)

  ld    de,BossGoatIdleAndWalk00
  jp    PutSf2Object5FramesGoat                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom

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
BossGoatAttack159:   dw GoatAttackframe022 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack160:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack161:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack162:   dw GoatAttackframe013 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack163:   dw GoatAttackframe014 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack164:   dw GoatAttackframe023 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

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
BossGoatAttack178:   dw GoatIdleAndWalkframe080 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatAttack179:   dw GoatWalkAndAttackframe045 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

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





;Idle sitting
BossVoodooWaspIdle00:   dw VoodooWaspIdleframe000 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle01:   dw VoodooWaspIdleframe001 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle02:   dw VoodooWaspIdleframe002 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle03:   dw VoodooWaspIdleframe003 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle04:   dw VoodooWaspIdleframe004 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle05:   dw VoodooWaspIdleframe005 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle06:   dw VoodooWaspIdleframe006 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle07:   dw VoodooWaspIdleframe007 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle08:   dw VoodooWaspIdleframe008 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle09:   dw VoodooWaspIdleframe009 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle10:   dw VoodooWaspIdleframe010 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle11:   dw VoodooWaspIdleframe011 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle12:   dw VoodooWaspIdleframe012 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle13:   dw VoodooWaspIdleframe013 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle14:   dw VoodooWaspIdleframe014 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle15:   dw VoodooWaspIdleframe015 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle16:   dw VoodooWaspIdleframe016 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle17:   dw VoodooWaspIdleframe017 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock

;Idle flying
BossVoodooWaspIdle18:   dw VoodooWaspIdleframe018 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle19:   dw VoodooWaspIdleframe019 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle20:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle21:   dw VoodooWaspIdleframe021 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle22:   dw VoodooWaspIdleframe022 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle23:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle24:   dw VoodooWaspIdleframe024 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle25:   dw VoodooWaspIdleframe025 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle26:   dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle27:   dw VoodooWaspIdleframe027 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle28:   dw VoodooWaspIdleframe028 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle29:   dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock

;attacking
BossVoodooWaspIdle30:   dw VoodooWaspIdleframe030 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle31:   dw VoodooWaspIdleframe031 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle32:   dw VoodooWaspIdleframe032 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle33:   dw VoodooWaspIdleframe033 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle34:   dw VoodooWaspIdleframe034 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle35:   dw VoodooWaspIdleframe035 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle36:   dw VoodooWaspIdleframe036 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle37:   dw VoodooWaspIdleframe037 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle38:   dw VoodooWaspIdleframe038 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle39:   dw VoodooWaspIdleframe039 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle40:   dw VoodooWaspIdleframe040 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle41:   dw VoodooWaspIdleframe041 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle42:   dw VoodooWaspIdleframe042 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle43:   dw VoodooWaspIdleframe043 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle44:   dw VoodooWaspIdleframe044 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle45:   dw VoodooWaspIdleframe045 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle46:   dw VoodooWaspIdleframe046 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle47:   dw VoodooWaspIdleframe047 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle48:   dw VoodooWaspIdleframe048 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle49:   dw VoodooWaspIdleframe049 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle50:   dw VoodooWaspIdleframe050 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle51:   dw VoodooWaspIdleframe051 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle52:   dw VoodooWaspIdleframe052 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle53:   dw VoodooWaspIdleframe053 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock

;being hit
BossVoodooWaspHit54:   dw VoodooWaspHitframe000 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit55:   dw VoodooWaspHitframe001 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit56:   dw VoodooWaspHitframe002 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit57:   dw VoodooWaspHitframe003 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit58:   dw VoodooWaspHitframe004 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit59:   dw VoodooWaspHitframe005 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit60:   dw VoodooWaspHitframe006 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit61:   dw VoodooWaspHitframe007 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit62:   dw VoodooWaspHitframe008 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit63:   dw VoodooWaspHitframe009 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit64:   dw VoodooWaspHitframe010 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit65:   dw VoodooWaspHitframe011 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit66:   dw VoodooWaspHitframe012 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit67:   dw VoodooWaspHitframe013 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit68:   dw VoodooWaspHitframe014 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock

;dying
BossVoodooWaspHit69:   dw VoodooWaspHitframe015 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit70:   dw VoodooWaspHitframe016 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit71:   dw VoodooWaspHitframe017 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit72:   dw VoodooWaspHitframe018 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit73:   dw VoodooWaspHitframe019 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit74:   dw VoodooWaspHitframe020 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit75:   dw VoodooWaspHitframe021 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit76:   dw VoodooWaspHitframe022 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit77:   dw VoodooWaspHitframe023 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit78:   dw VoodooWaspHitframe024 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit79:   dw VoodooWaspHitframe025 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock
BossVoodooWaspHit80:   dw VoodooWaspHitframe026 | db BossVoodooWaspHitframelistblock, BossVoodooWaspHitspritedatablock

;Idle flying bottom part
BossVoodooWaspIdle81:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle82:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle83:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle84:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle85:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle86:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle87:   dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle88:   dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle89:   dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle90:   dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle91:   dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle92:   dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock

;Idle flying middle and bottom part
BossVoodooWaspIdle93:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle94:   dw VoodooWaspIdleframe019 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle95:   dw VoodooWaspIdleframe020 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle96:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle97:   dw VoodooWaspIdleframe022 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle98:   dw VoodooWaspIdleframe023 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle99:   dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle100:  dw VoodooWaspIdleframe025 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle101:  dw VoodooWaspIdleframe026 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle102:  dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle103:  dw VoodooWaspIdleframe028 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock
BossVoodooWaspIdle104:  dw VoodooWaspIdleframe029 | db BossVoodooWaspIdleframelistblock, BossVoodooWaspIdlespritedatablock

BossAreaVoodooWaspPalette:
  incbin "..\grapx\tilesheets\sBossAreaVoodooWaspPalette.PL" ;file palette 

ResetV1andV2:
  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table
  ret

VoodooWaspEnterScreenMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    127,1,0, 128
VoodooWaspAttackPattern1MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,+3, 003,+5,+2, 003,+5,+1, 040,+5,+0
VoodooWaspAttackPattern2MovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    003,-5,-0, 003,-5,-1, 003,-5,-2, 040,-5,-3
VoodooWaspAttackPattern2bMovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    006,-5,-0, 003,-5,-2, 040,-5,-2

VoodooWaspAttackPattern3MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,+0, 003,+5,-1, 003,+5,-2, 040,+5,-3
VoodooWaspAttackPattern4MovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    003,-5,+0, 003,-5,+1, 003,-5,+2, 040,-5,+3

VoodooWaspAttackPattern5MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,-3, 003,+5,-4, 003,+5,-5, 040,+5,-6
VoodooWaspAttackPattern6MovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    003,-5,+3, 003,-5,+4, 003,-5,+5, 040,-5,+6

VoodooWaspAttackPattern7MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,-6, 003,+5,-7, 003,+5,-8, 040,+5,-9
VoodooWaspAttackPattern7bMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,-5, 003,+5,-6, 003,+5,-6, 040,+5,-7
VoodooWaspAttackPattern8MovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    003,-5,+6, 003,-5,+7, 003,-5,+8, 040,-5,+9
VoodooWaspAttackPattern8bMovementTable: ;repeating steps(128 = end table/repeat), move y, move x  
  db    003,-5,+5, 003,-5,+6, 003,-5,+6, 040,-5,+7

VoodooWaspAttackPattern9MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 003,+5,+3, 003,+5,+4, 003,+4,+3, 003,+3,+2, 003,+2,+1, 003,+1,+0, 003,+0,-2, 003,+0,-3, 003,+0,-4, 003,+0,-5, 003,+0,-6, 013,+0,-7
  db    003,-5,+5, 003,-5,+6, 003,-5,+7, 040,-3,+7

VoodooWaspAttackPattern10MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    030,+0,+0, 040,+3,+2

VoodooWaspAttackPattern11MovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    040,-3,-2

VoodooWaspFallingDownMovementTable: ;repeating steps(128 = end table/repeat), move y, move x
  db    040,+6,+0, 128

BossCheckIfDead:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  cp    4
  ret   z                                   ;don't check if boss is already dead

  ld    a,(ix+enemies_and_objects.life)
  dec   a
  ret   nz
  call  ResetV1andV2  
  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),69      ;v7=sprite frame
  ld    (ix+enemies_and_objects.v9),011     ;v8=blending into background (MovementPatternsFixedPage1.asm) in: v9=011
  ret

CheckPlayerHitByBoss:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  cp    4
  ret   z                                   ;don't check if boss is dead

  ld    a,-50                               ;add to sy
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,30                               ;reduction to hitbox sx (left side)
  call  CollisionEnemyPlayer.ObjectEntry
  ret

VoodooWaspCheckIfHit:
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
  cp    4
  ret   z                                   ;don't check if boss is dead

  ld    b,-55
  call  CheckPlayerPunchesBossWithYOffset   ;Check if player hit's enemy. in b=Y offset
  
  ld    a,(ix+enemies_and_objects.hit?)
  cp    BlinkDurationWhenHit                ;Check if Boss is hit this very frame
  ret   nz

  pop   af                                  ;pop call  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  ld    (ix+enemies_and_objects.v1-1),a     ;backup v7=sprite frame
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v1-2),a     ;backup v7=sprite frame

  ld    (ix+enemies_and_objects.v7),54      ;v7=sprite frame
  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ret

BossVoodooWasp:
;v1-2=backup v8 phase
;v1-1=backup v7 sprite frame
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=attack pattern
;face player upwards when Voodoo Wasp enters
  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  cp    5
  jr    nz,.EndCheckVoodooWaspEnterScreen
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    30
  jr    c,.EndCheckVoodooWaspEnterScreen
	ld		hl,PlayerSpriteData_Char_RightStandLookUp
	ld		(standchar),hl

  ld    a,(ix+enemies_and_objects.y)        ;y object
  ld    (Object1y),a
  ld    a,(ix+enemies_and_objects.x)        ;x object
  ld    (Object1x),a	

  ld    hl,BossAreaVoodooWaspPalette
  call  Setpalette	
  .EndCheckVoodooWaspEnterScreen:
;/face player upwards when Voodoo Wasp enters 

  call  CheckPlayerHitByBoss                ;Check if player gets hit by boss
  ;Check if boss gets hit by player
  call  VoodooWaspCheckIfHit                ;call gets popped if dead. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
  call  BossCheckIfDead                     ;Check if boss is dead, and if so set dying phase

  call  .HandlePhase                        ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)

  ld    de,BossVoodooWaspIdle00
  jp    PutSf2Object3Frames                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom

  .HandlePhase:                            ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    a,(HugeObjectFrame)
  cp    2
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  or    a
;  jp    z,BossVoodooWaspIdleSitting         ;0=idle sitting
  dec   a
  jp    z,BossVoodooWaspIdleFlying          ;1=idle flying
  dec   a
;  jp    z,BossVoodooWaspAttacking           ;2=attacking
  dec   a
  jp    z,BossVoodooWaspBeingHit            ;3=hit
  dec   a
  jp    z,BossVoodooWaspDying               ;4=dead
  dec   a
  jp    z,BossVoodooWaspEnterScreen         ;5=enter screen
  dec   a
  jp    z,BossVoodooWaspAttackPattern1      ;6=attack pattern 1 flying down
  dec   a
  jp    z,BossVoodooWaspAttackPattern2      ;7=attack pattern 2 attacking
  dec   a
  jp    z,BossVoodooWaspAttackPattern3      ;8=attack pattern 3 flying back up
  dec   a
  jp    z,BossVoodooWaspAttackPattern4      ;9=attack pattern 4 flying down
  dec   a
  jp    z,BossVoodooWaspIdleSitting2        ;10=idle sitting2
  dec   a
  jp    z,BossVoodooWaspAttackPattern5      ;11=attack pattern 5 flying back up
  dec   a
  jp    z,BossVoodooWaspAttackPattern6      ;12=attack pattern 6 flying in a clockwise circle
  dec   a
  jp    z,BossVoodooWaspAttackPattern7      ;13=attack pattern 7 flying down to sit on the platform in the middle
  dec   a
  jp    z,BossVoodooWaspAttackPattern8      ;14=attack pattern 8 flying back up
  ret

  BossVoodooWaspAttackPattern8:             ;14=attack pattern 8 flying back up
  call  BossVoodooWaspIdleFlying.animate

  ld    de,VoodooWaspAttackPattern11MovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    0
  ret   nz

  call  ResetV1andV2
  call  VoodooWaspChooseNewAttackPattern
  ld    (ix+enemies_and_objects.x),$b0      ;x starting position
;  ld    (ix+enemies_and_objects.y),0        ;y starting position
  ret

  BossVoodooWaspAttackPattern7:             ;13=attack pattern 7 flying down to sit on the platform in the middle
  call  BossVoodooWaspIdleFlying.animate

  ld    de,VoodooWaspAttackPattern10MovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    30
  ret   c

  call  ResetV1andV2  
;  ld    (ix+enemies_and_objects.y),102      ;y
  ld    (ix+enemies_and_objects.v8),10      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame
  ret

  VoodooWaspChooseNewAttackPattern:
  ld    a,r
  and   3
  ld    (ix+enemies_and_objects.v8),6       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v9),0       ;v9=attack pattern

  ret   z
  ld    (ix+enemies_and_objects.v8),13      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  dec   a
  ret   z
  ld    (ix+enemies_and_objects.v8),12      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  dec   a
  ret   z
  ld    (ix+enemies_and_objects.v8),9       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    a,(clesX)
  cp    50
  ld    (ix+enemies_and_objects.v9),3       ;v9=attack pattern
  ret   c
  cp    100
  ld    (ix+enemies_and_objects.v9),2       ;v9=attack pattern
  ret   c
  cp    150
  ld    (ix+enemies_and_objects.v9),1       ;v9=attack pattern
  ret   c
  ld    (ix+enemies_and_objects.v9),0       ;v9=attack pattern
  ret

  BossVoodooWaspAttackPattern6:             ;12=attack pattern 6 flying in a clockwise circle
  call  BossVoodooWaspIdleFlying.animate

  ld    de,VoodooWaspAttackPattern9MovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    250
  ret   c

  call  ResetV1andV2
  call  VoodooWaspChooseNewAttackPattern
  ld    (ix+enemies_and_objects.x),$b0      ;x starting position
  ld    (ix+enemies_and_objects.y),0        ;y starting position
  ret

  BossVoodooWaspAttackPattern5:             ;flying back up
  call  BossVoodooWaspIdleFlying.animate

  ld    a,(ix+enemies_and_objects.v9)       ;v9=attack pattern
  or    a
  ld    de,VoodooWaspAttackPattern2bMovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern4MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern6MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern8bMovementTable
  jr    z,.MovementPatternFound  
  .MovementPatternFound:  
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    0
  ret   nz

  call  ResetV1andV2
  call  VoodooWaspChooseNewAttackPattern
  ld    (ix+enemies_and_objects.x),$b0      ;x starting position
  ret

  BossVoodooWaspIdleSitting2:
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
  
  ld    (ix+enemies_and_objects.nx),70      ;width when sitting

  ld    a,(ix+enemies_and_objects.hit?)
  or    a
  jr    nz,.FlyBackUp
  
  ;animate
  ld    a,(Bossframecounter)
  and   1
  ret   nz
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
  cp    18                                  ;sprite 18,21,24,27 are idle flying
  jr    nz,.notzero

  ld    a,r
  and   7
  ld    a,00
  jr    nz,.notzero

  .FlyBackUp:
  ld    a,(ix+enemies_and_objects.y)        ;y
  cp    102
  jr    z,.VoodooWaspSittingOnBottomFloor
  
  .VoodooWaspSittingOnPlatform:
  ld    (ix+enemies_and_objects.nx),52      ;width when flying
  ld    (ix+enemies_and_objects.v8),14      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  call  ResetV1andV2
  ld    a,18
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

  .VoodooWaspSittingOnBottomFloor:
  ld    (ix+enemies_and_objects.nx),52      ;width when flying
  ld    (ix+enemies_and_objects.v8),11      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.y),100       ;y
  call  ResetV1andV2
  ld    a,18
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

  BossVoodooWaspAttackPattern4:             ;flying down
  call  BossVoodooWaspIdleFlying.animate

  ld    a,(ix+enemies_and_objects.v9)       ;v9=attack pattern
  or    a
  ld    de,VoodooWaspAttackPattern1MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern3MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern5MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern7bMovementTable
  jr    z,.MovementPatternFound  
  .MovementPatternFound:  
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    100
  ret   nz

  call  ResetV1andV2  
  ld    (ix+enemies_and_objects.y),102      ;y
  ld    (ix+enemies_and_objects.v8),10      ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    (ix+enemies_and_objects.v7),0       ;v7=sprite frame
  ret

  BossVoodooWaspAttackPattern3:             ;flying back up
  call  BossVoodooWaspIdleFlying.animate

  ld    a,(ix+enemies_and_objects.v9)       ;v9=attack pattern
  or    a
  ld    de,VoodooWaspAttackPattern2MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern4MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern6MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern8MovementTable
  jr    z,.MovementPatternFound  
  .MovementPatternFound:  
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    0
  ret   nz

  call  ResetV1andV2
  ld    (ix+enemies_and_objects.v8),6       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)

  ld    a,(ix+enemies_and_objects.v9)       ;v9=attack pattern
  inc   a
  ld    (ix+enemies_and_objects.v9),a       ;v9=attack pattern
  cp    4
  ret   nz

  call  VoodooWaspChooseNewAttackPattern
  ld    (ix+enemies_and_objects.x),$b0      ;x starting position
  ret
  
  BossVoodooWaspAttackPattern2:             ;attacking
  ld    a,(Bossframecounter)
  rrca
  ret   c
  
  ;when Voodoo Wasp attack, move his hitbox slightly to the left
  ld    a,-50                               ;add to sy
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ld    bc,40                               ;reduction to hitbox sx (left side)
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    54-15
  call  z,CollisionEnemyPlayer.ObjectEntry
  
  ;animate
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
  cp    54                                  ;sprite 18,21,24,27 are idle flying
  jr    nz,.notzero
  ld    (ix+enemies_and_objects.v8),8       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  call  ResetV1andV2
  ld    a,18
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

  BossVoodooWaspAttackPattern1:             ;flying down
  call  BossVoodooWaspIdleFlying.animate

  ld    a,(ix+enemies_and_objects.v9)       ;v9=attack pattern
  or    a
  ld    de,VoodooWaspAttackPattern1MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern3MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern5MovementTable
  jr    z,.MovementPatternFound
  dec   a
  ld    de,VoodooWaspAttackPattern7MovementTable
  jr    z,.MovementPatternFound  
  .MovementPatternFound:  
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(ix+enemies_and_objects.y)       ;y
  cp    80
  ret   nz

  ld    (ix+enemies_and_objects.v8),7       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ret

  BossVoodooWaspEnterScreen:
  ld    de,VoodooWaspEnterScreenMovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
  
  ;animate
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
  cp    93                                  ;sprite 18,21,24,27 are idle flying
  jr    z,.Sub12
  cp    105                                 ;sprite 18,21,24,27 are idle flying
  jr    z,.Sub12
  cp    30                                  ;sprite 18,21,24,27 are idle flying
  jr    nz,.DontSub12
  .Sub12:
  sub   a,12
  .DontSub12:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame

  ld    a,(ix+enemies_and_objects.y)        ;y Voodoo Wasp
  cp    -44
  jr    z,.BottomPartFullyInScreen
  cp    -12
  jr    z,.BottomAndMiddlePartFullyInScreen
  cp    0
  ret   nz
  call  ResetV1andV2
  jp    VoodooWaspChooseNewAttackPattern

  .BottomAndMiddlePartFullyInScreen:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  sub   a,75
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  xor   a
  ld    (freezecontrols?),a  
  ret  

  .BottomPartFullyInScreen:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,12
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

  BossVoodooWaspDying:
  ld    de,VoodooWaspFallingDownMovementTable
  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
  
  ld    a,(ix+enemies_and_objects.y)        ;y
  cp    98
  jr    c,.EndCheckBottomReached
  ld    a,98
  .EndCheckBottomReached:
  ld    (ix+enemies_and_objects.y),a        ;y

  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  cp    78
  jp    z,BossBlendingIntoBackgroundOnDeath ;blending into background (MovementPatternsFixedPage1.asm) in: v9=008
    
  ;animate
  ld    a,(Bossframecounter)
  and   7
  ret   nz  
  
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
;  cp    81                                  ;sprite 18,21,24,27 are idle flying
;  ret   z
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

  BossVoodooWaspBeingHit:
  ld    (ix+enemies_and_objects.hit?),BlinkDurationWhenHit-20
  
  ;animate
  ld    a,(Bossframecounter)
  and   1
  ret   nz
    
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
  cp    69                                  ;sprite 18,21,24,27 are idle flying
  jr    nz,.notzero

  ld    a,(ix+enemies_and_objects.v1-1)     ;backup v7=sprite frame
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ld    a,(ix+enemies_and_objects.v1-2)     ;backup v7=sprite frame
  ld    (ix+enemies_and_objects.v8),a       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ret
  
;  ld    a,54
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret  

;  BossVoodooWaspAttacking:
  ;animate
;  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
;  add   a,3
;  cp    54                                  ;sprite 18,21,24,27 are idle flying
;  jr    nz,.notzero
;  ld    a,30
;  .notzero:
;  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
;  ret  

  BossVoodooWaspIdleFlying:
  call  .animate

;  ld    a,(ix+enemies_and_objects.v9)       ;v9=wait timer
;  inc   a
;  and   31
;  ld    (ix+enemies_and_objects.v9),a       ;v9=wait timer
;  ret   nz
;  call  ResetV1andV2
;  ld    (ix+enemies_and_objects.v8),6       ;v8=Phase (0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
;  ret  

  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
  add   a,3
  cp    30                                  ;sprite 18,21,24,27 are idle flying
  jr    nz,.notzero
  ld    a,18
  .notzero:
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
  ret

;  BossVoodooWaspIdleSitting:
;  ld    de,NonMovingObjectMovementTable
;  call  MoveObjectWithStepTable            ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  
;  call  CollisionObjectPlayerDemon         ;Check if player is hit by Vram object                            
;  call  CheckPlayerPunchesEnemyDemon       ;Check if player hit's enemy
  
;  ld    a,r
;  and   31
;  jr    nz,.EndCheckStartWalking
;  ld    (ix+enemies_and_objects.v1),0       ;v1=repeating steps
;  ld    (ix+enemies_and_objects.v2),0       ;v2=pointer to movement table    
;  ld    (ix+enemies_and_objects.v7),6       ;v7=sprite frame
;  ld    (ix+enemies_and_objects.v8),1       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
;  ret
;  .EndCheckStartWalking:

;  call  BossDemonCheckIfDead                ;call gets popped if dead
;  call  BossDemonCheckIfHit                 ;call gets popped if hit

  ;animate
;  ld    a,(Bossframecounter)
;  and   1
;  ret   nz
  
;  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame
;  add   a,3
;  cp    18                                  ;sprite 18,21,24,27 are idle flying
;  jr    nz,.notzero
;  ld    a,00
;  .notzero:
;  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
;  ret  

;  BossDemonCheckIfHit:
;  ld    a,(ix+enemies_and_objects.hit?)
;  or    a
;  ret   z
;  pop   af                                  ;pop call  
;  ld    (ix+enemies_and_objects.hit?),0
;  ld    (ix+enemies_and_objects.v7),29      ;v7=sprite frame
;  ld    (ix+enemies_and_objects.v8),3       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
;  ret

;  BossDemonCheckIfDead:
;  ld    a,(ix+enemies_and_objects.life)
;  dec   a
;  ret   nz
;  pop   af                                  ;pop call
;  ld    (ix+enemies_and_objects.v8),4       ;v8=Phase (0=idle, 1=walking, 2=attacking, 3=hit, 4=dead)
;  ld    a,34
;  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame
;  ret

	dephase
	