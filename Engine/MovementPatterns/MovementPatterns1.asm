;This is at $4000 inside a block (movementpatternsblock)
movementpatternaddress:
  jp    PlatformVertically                  ;movement pattern 1   
  jp    PlatformHorizontally                ;movement pattern 2   
  jp    Sf2Hugeobject1                      ;movement pattern 3
  jp    Sf2Hugeobject2                      ;movement pattern 4
  jp    Sf2Hugeobject3                      ;movement pattern 5
  jp    PushingStone                        ;movement pattern 6
  jp    PushingStonePuzzleSwitch            ;movement pattern 7
  jp    PushingStonePuzzleOverview          ;movement pattern 8


Sf2Hugeobject1:                             ;movement pattern 3
  ld    a,(HugeObjectFrame)
  inc   a
  ld    (HugeObjectFrame),a
  jp    nz,CheckCollisionObjectPlayer

  call  MoveSF2Object1
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  call  BackdropOrange  
  call  restoreBackgroundObject1
  call  ObjectAnimation
  call  PutSF2Object
  call  BackdropBlack
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
  
PushingStonePuzzleOverview:
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
  

PushingStonePuzzleSwitch:
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
  call  BackdropRed

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
  call  BackdropGreen
;  ld    hl,CopyObject
;  call  docopy
;  call  BackdropBlack
  ret

VramObjectsTransparantCopies:
;first clean the object
  call  BackdropRed

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
  call  BackdropGreen
;  ld    hl,CopyObject
;  call  docopy
;  call  BackdropBlack
  ret  