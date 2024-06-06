phase	loaderAddress	;20240525;ro;moved from usas2.asm to this file

loader:
	call screenoff
	call ReSetVariables
	call SwapSpatColAndCharTable2
	call SwapSpatColAndCharTable
	call SwapSpatColAndCharTable2
	call PopulateControls			;this allows for a double jump as soon as you enter a new map
	ld de,(WorldMapPositionY) 			;WorldMapPositionX/Y:  
	call getRoom
;	call SetEngineType
	;call  SetTilesInVram				;copies all the tiles to Vram
;	ld	a,RuinId.KarniMata		 		;ruinId (temp)
;	ld a,Ruinid.Lemniscate
 ret
	ld a,Ruinid.Pegu
;	ld a,(UnpackedRoomFile+roomDataBlock.mapid)
;	and #1f
	call getPalette
	call SetMapPalette
  ret


ObjectTestData: 

;db 11,0,0,$28,$a0,$44,16,3,3,0 ;small platform on
;db 0

;db 12,0,0,$28,$70,$44,16,3,3,1 ;small lighter platform on
;db 12,0,0,$28,$a0,$44,16,3,3,0 ;small lighter platform off

;db 57,0,0,$28,$80,$44,16,3,3,1 ;big platform on
;db 57,0,0,$28,$b0,$44,16,3,3,0 ;big platform off

;db 0


;db 16,100/2,100 ;omni directional platform (PlatformOmniDirectionally)
;db 16,140/2,140 ;omni directional platform (PlatformOmniDirectionally)
;db 0

;db 20,120/2,80,3,0,6 ;id,x,y,face, speed, amount of bats (BigStatueMouth bat spawner)
;db 0

;db 62,16/2,100,3,1,2  ;id,x,y,face,speed,max zombies (ZombieSpawnPoint)
;db 11,0,0,$28,$a0,$44,16,3,3,1 ;platform


;db 1,80/2,80 ;id,x,y (pushing stone)
;db 1,140/2,80 ;id,x,y (pushing stone)
;db 1,180/2,80 ;,0 ;id,x,y (pushing stone)
;db 0

;db $96,32/2,$b8,03,01 ;slime (TrampolineBlob) (id,x,y,face,speed) 
;db 0

;db 128,96/2,$98 ;huge blob (HugeBlob) (id,x,y,face,speed) 
;db 0

;db 129,96/2,$b0,03,01 ;huge spider (HugeSpiderLegs) (id,x,y,face,speed) 
;db 0

;db 130,40/2,$78,03,01 ;lancelot (Lancelot) (id,x,y,face,speed) 
;db 130,96/2,$a8,03,01 ;lancelot (Lancelot) (id,x,y,face,speed) 
;db 0

;db 131,96/2,$a8,03,01 ;black hole alien (BlackHoleAlien) (id,x,y,face,speed) 
;db 0

;db 132,100/2,$98 ;green fire eye (FireEye) (id,x,y,face,speed) 
;db 0

;db 133,130/2,$98 ;grey fire eye (FireEye) (id,x,y,face,speed) 
;db 0

;db 134,96/2,$a8,03,01 ;knife thrower (SnowballThrower) (id,x,y,face,speed) 
;db 134,130/2,$68,03,01 ;knife thrower (SnowballThrower) (id,x,y,face,speed) 
;db 0

;db $86,$5c/2,$58,03,01 ;knife thrower (SnowballThrower) (id,x,y,face,speed) 
;db 0


;db 135,80/2,$78 ;octopussy (Octopussy) (id,x,y,face,speed) 
;db 135,110/2,$78 ;octopussy (Octopussy) (id,x,y,face,speed) 
;db 0


;db 154,100/2,$78,03,1 ;green demontje (Demontje) (id,x,y,face,speed) 
;db 0

;db 155,200/2,$78,03,1 ;red demontje (Demontje) (id,x,y,face,speed) 
;db 0

;db 156,140/2,$98,07,1 ;brown demontje (Demontje) (id,x,y,face,speed) 
;db 0

;db 157,200/2,$68,07,1 ;grey demontje (Demontje) (id,x,y,face,speed) 
;db 0

;db 136,96/2,$a8,03,01 ;grinder (Grinder) (id,x,y,face,speed) 
;db 0

;db 137,96/2,$a8,03,01 ;treeman (Treeman) (id,x,y,face,speed) 
;db 0

;db 138,96/2,$a8,07,01 ;hunchback (Hunchback) (id,x,y,face,speed) 
;db 138,120/2,$98,07,01 ;hunchback (Hunchback) (id,x,y,face,speed) 
;db 0

;db 139,96/2,$a8,03,01 ;scorpion (Scorpion) (id,x,y,face,speed) 
;db 0

;db 140,140/2,$b0,03,01 ;beetle (Beetle) (id,x,y,face,speed) 
;db 0

;db 141,140/2,$b8,03,01 ;green spider (GreenSpider) (id,x,y,face,speed) 
;db 0

;db 142,140/2,$b8,03,01 ;green spider (GreenSpider) (id,x,y,face,speed) 
;db 0

;db 144,140/2,$b8 ;green boring eye (BoringEye) (id,x,y,face,speed) 
;db 0

;db 145,160/2,$b8 ;red boring eye (BoringEye) (id,x,y,face,speed) 
;db 0

;db 146,140/2,$b8,03,01 ;black hole alien baby (BlackHoleBaby) (id,x,y,face,speed) 
;db 0

;db 148,140/2,$b8,03,01 ;landstrider (LandStrider) (id,x,y,face,speed) 
;db 0

;db 149,140/2,$68 ;sensor tentacles (SensorTentacles) (id,x,y,face,speed) 
;db 0

;db 151,180/2,$68 ;green circling wasp (Wasp) (id,x,y,face,speed) 
;db 0

;db 152,140/2,$68 ;brown circling wasp (Wasp) (id,x,y,face,speed) 
;db 0

;db 153,140/2,$68 ;yellow wasp (YellowWasp) (id,x,y,face,speed) 
;db 0

;db 61,4 ;id,balnr (
;db 61,5 ;id,balnr (
;db 0

;db 61,1 ;id,balnr (
;db 61,2 ;id,balnr (
;db 0

;db 159,240/2,$98 ;,03,01 ;glassball pipe (GlassballPipe) (id,x,y,face,speed) 
;db 0

;db 158,140/2,$a8,03,01 ;black slime (Slime) (id,x,y,face,speed) 
;db 158,140/2,$b8,03,01 ;black slime (Slime) (id,x,y,face,speed) 

;db 0

;db 4,$28,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 2,$58,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 2,$68,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 4,$48,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 

;db 0

;db 2,$28,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 2,$38,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 2,$48,$48  ;poison drops (DrippingOozeDrop) (id,x,y) 
;db 0


;db 62,16/2,100,3,1,4,0  ;id,x,y,face,speed,max zombies (ZombieSpawnPoint)
;db 15,76,30,0  ;id, x,y (retracting platforms)
;db 15,76,40,0
;db 0 ;3 retracting platforms (AppBlocksHandler)
;db 11,0,0,$28,$a0,$44,16,3,3,1 ;platform
;db 11,0,0,$28,$b0,$44,16,3,3,1
;db $96,32/2,$80,03,01 ;slime
;db $96,$24,$30,03,01
;db 0

;db 5,0 (area sign)
;db 255,0  ;(teleport)

;db $0a,$00,$00,56/2,88-16,$48,$30,$03,$01,$01 ;Huge Block (ix,relativex,relativey,xbox,ybox,widthbox,heightbox,face,speed,active)
;db 0

;db $0a,$00,$70,$14,$20,$40,$a0,$03,$01,$01 ;Huge Block (ix,relativex,relativey,xbox,ybox,widthbox,heightbox,face,speed,active)
;db $0a,$10,$60,$14,$20,$40,$a0,$03,$02,$01 ;Huge Block (ix,relativex,relativey,xbox,ybox,widthbox,heightbox,face,speed,active)
;db $0a,$20,$50,$14,$20,$40,$a0,$03,$03,$01 ;Huge Block (ix,relativex,relativey,xbox,ybox,widthbox,heightbox,face,speed,active)
;db $0a,$30,$40,$14,$20,$40,$a0,$03,$04,$01 ;Huge Block (ix,relativex,relativey,xbox,ybox,widthbox,heightbox,face,speed,active)
;db 153,140/2,$68 ;yellow wasp (YellowWasp) (id,x,y,face,speed) 
;db 0

;db 200,100,100,0    ;WaterfallBoss, x,y

SetObjects:                             ;after unpacking the map to ram, all the object data is found at the end of the mapdata. Convert this into the object/enemytables
;set test objects
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    de,UnpackedRoomFile.tiledata+38*27*2  ;room object data list
  jr    z,.ObjectAddressFound
  ld    de,UnpackedRoomFile.tiledata+32*27*2  ;room object data list
  .ObjectAddressFound:

;  ld    de,ObjectTestData

  push  de
;.CheckObjects: jp .CheckObjects
;halt

  xor   a
  ld    (AmountOfPushingStonesInCurrentRoom),a
  ld    (AmountOfPoisonDropsInCurrentRoom),a
  ld    (AmountOfWaterfallsInCurrentRoom),a
  ld    (AmountOfSF2ObjectsCurrentRoom),a
  ld    a,1
  ld    (CurrentActiveWaterfall),a
  call	clearEnemyTable
  ld    hl,CleanOb1                     ;refers to the cleanup table for 1st object. we can place 3 objects max. CleanOb1, CleanOb2 and CleanOb3 are their tables

  ld    a,(scrollEngine)                ;1= 304x216 engine, 2=256x216 SF2 engine, 3=256x216 SF2 engine sprite split ON 
  cp    2
  ld    b,12+10                         ;first hardware object sprite nr (sprite 0-11 are border masking sprites, after this start the hardware sprite objects)
  jp    z,.EngineTypeFound
  ld    b,12                            ;first hardware object sprite nr (sprite 0-11 are border masking sprites, after this start the hardware sprite objects)
  .EngineTypeFound:
  exx                                   ;keep CleanOb1 address untouched

  pop   ix
;  ld    ix,UnpackedRoomFile.tiledata+38*27*2  ;room object data list
;  ld    ix,UnpackedRoomFile.tiledata+32*27*2  ;room object data list

  ld    iy,enemies_and_objects          ;start object table in iy


  .loop:
  ld    a,(ix)
  or    a
  ret   z                               ;0=end room object list
  call  .SetObject
  add   ix,de                           ;add the lenght of current object data to ix, and set next object in ix
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table
  jp    .loop                           ;go handle next object
  
  .SetObject:
  cp    1
  jp    z,.Object001                    ;pushing stone
  cp    2
  jp    z,.Object002                    ;waterfall yellow statue
  cp    3
  jp    z,.Object003                    ;waterfall grey statue
  cp    4
  jp    z,.Object004                    ;poison drops (DrippingOozeDrop)
  cp    5
  jp    z,.Object005                    ;area sign (AreaSign)
  cp    6
  jp    z,.Object006                    ;teleport room (Teleport)
  cp    7
  jp    z,.Object007                    ;waterfall scene (WaterfallScene)
  cp    10
  jp    z,.Object010                    ;huge block (HugeBlock)
  cp    11
  jp    z,.Object011                    ;small moving platform on (standard dark grey)
  cp    12
  jp    z,.Object012                    ;small moving platform (lighter version)
  cp    15
  jp    z,.Object015                    ;retracting platforms
  cp    16
  jp    z,.Object016                    ;omni directional platform (PlatformOmniDirectionally)
  cp    20
  jp    z,.Object020                    ;bat spawner (BigStatueMouth)
  cp    57
  jp    z,.Object057                    ;big moving platform
  cp    61
  jp    z,.Object061                    ;glass ball (GlassBallActivator)
  cp    62
  jp    z,.Object062                    ;zombie spawn point
;  cp    143
;  jp    z,.Object143                    ;retarded zombie
  cp    128
  jp    z,.Object128                    ;huge blob (HugeBlob)
  cp    129
  jp    z,.Object129                    ;huge spider (HugeSpiderLegs)
  cp    130
  jp    z,.Object130                    ;lancelot (Lancelot)
  cp    131
  jp    z,.Object131                    ;black hole alien (BlackHoleAlien)
  cp    132
  jp    z,.Object132                    ;green fire eye (FireEye)
  cp    133
  jp    z,.Object133                    ;grey fire eye (FireEye)
  cp    134
  jp    z,.Object134                    ;knife thrower (SnowballThrower)
  cp    135
  jp    z,.Object135                    ;octopussy (Octopussy)
  cp    136
  jp    z,.Object136                    ;grinder (Grinder)
  cp    137
  jp    z,.Object137                    ;treeman (Treeman)
  cp    138
  jp    z,.Object138                    ;hunchback (Hunchback)
  cp    139
  jp    z,.Object139                    ;scorpion (Scorpion)
  cp    140
  jp    z,.Object140                    ;beetle (Beetle)
  cp    141
  jp    z,.Object141                    ;green spider (GreenSpider)
  cp    142
  jp    z,.Object142                    ;grey spider (GreenSpider)
  cp    144
  jp    z,.Object144                    ;green boring eye (BoringEye)
  cp    145
  jp    z,.Object145                    ;red boring eye (BoringEye)
  cp    146
  jp    z,.Object146                    ;black hole alien baby (BlackHoleBaby)
  ;147 = bat
  cp    148
  jp    z,.Object148                    ;landstrider (LandStrider)
  cp    149
  jp    z,.Object149                    ;sensor tentacles (SensorTentacles)
  cp    150
  jp    z,.Object150                    ;trampoline blob
  cp    151
  jp    z,.Object151                    ;green circling wasp (Wasp)
  cp    152
  jp    z,.Object152                    ;brown circling wasp (Wasp)
  cp    153
  jp    z,.Object153                    ;yellow wasp (YellowWasp)
  cp    154
  jp    z,.Object154                    ;green demontje (Demontje)
  cp    155
  jp    z,.Object155                    ;red demontje (Demontje)
  cp    156
  jp    z,.Object156                    ;brown demontje (Demontje)
  cp    157
  jp    z,.Object157                    ;grey demontje (Demontje)
  cp    158
  jp    z,.Object158                    ;black slime (Slime)
  cp    159
  jp    z,.Object159                    ;glassball pipe (GlassballPipe)
  ret


  .Object007:                           ;waterfall scene (WaterfallScene)
;jp .Object007
  ld    hl,Object007Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1           ;1 object(s)
  ldir

  ;put waterfall backdrop in all 4 pages
  ld    a,0
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$0000 + (032*128) + (040/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (112*256) + (176/2)        ;(ny*256) + (nx/2)
  ld    a,WaterfallSceneBlock1              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  ld    a,0
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + (032*128) + (040/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (112*256) + (176/2)        ;(ny*256) + (nx/2)
  ld    a,WaterfallSceneBlock2              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  ld    a,1
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$0000 + (032*128) + (040/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (112*256) + (176/2)        ;(ny*256) + (nx/2)
  ld    a,WaterfallSceneBlock3              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  ld    a,1
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + (032*128) + (040/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (112*256) + (176/2)        ;(ny*256) + (nx/2)
  ld    a,WaterfallSceneBlock4              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  ld    de,Object007Table.lenghtobjectdata
  ret   

  .Object006:                           ;teleport room (Teleport)
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=already entered?(bit0)/activate ring(bit1)
;v10=activate ring flicker
  ld    hl,Object006Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1           ;1 object(s)
  ldir

  ;set x
  ld    a,(ix+Object020Table.x)
  add   a,16                             ;10 pix to the right
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object020Table.y)
  sub   72
  ld    (iy+enemies_and_objects.y),a

  ld    de,Object006Table.lenghtobjectdata
  ret    




  .Object001:                           ;pushing stone (PushingStone)
;v1=sx
;v2=falling stone?
;v3=y movement
;v4=x movement
;v7=set/store coord
;v9=special width for Pushing Stone Puzzle Switch
;v1-2= coordinates in pushing stone table (PuzzleBlocks1Y, PuzzleBlocks2Y etc)
  call  .SetPushingStoneInEnemyTable
  
  ;now we have to check if this block is already present in the pushing block table
  ld    hl,PuzzleBlocks1Y+3
  .CheckBlock:
  ld    a,(hl)                          ;room y
  or    a
  jr    z,.NotYetPresent
  ld    b,a
  ld    a,(WorldMapPositionY)
  cp    b
  jr    nz,.ThisBlockBelongsInADifferentRoom
  dec   hl
  ld    a,(hl)                          ;room x
  ld    b,a
  inc   hl
  ld    a,(WorldMapPositionX)
  cp    b
  jr    nz,.ThisBlockBelongsInADifferentRoom
  dec   hl
  dec   hl
  dec   hl

  .AlreadyPresent:                      ;when a block is already in the table, set table coordinates in v1-2 and take x,y from table and feed it into the object
  ld    (iy+enemies_and_objects.v1-2),l ;set coordinates in pushing stone table (PuzzleBlocks1Y, PuzzleBlocks2Y etc)
  ld    (iy+enemies_and_objects.v1-1),h

  ld    a,(ix+Object001Table.lenghtobjectdata)
  cp    1                               ;check if next object is another pushing stone
  ld    de,Object001Table.lenghtobjectdata
  ret   nz

  ld    de,Object001Table.lenghtobjectdata
  add   ix,de                           ;add the lenght of current object data to ix, and set next object in ix
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  call  .SetPushingStoneInEnemyTable
    
  ld    de,4
  add   hl,de                           ;next block in pushing block table
  jr    .AlreadyPresent                 ;now loop this routine and look for more pushing stones in this room

  .ThisBlockBelongsInADifferentRoom:
  ld    de,4
  add   hl,de                           ;next block in pushing block table
  jr    .CheckBlock
    
  .NotYetPresent:
  call  .SetRoomYXStoneXYAndTableAddress 

  ld    a,(ix+Object001Table.lenghtobjectdata)
  cp    1                               ;check if next object is another pushing stone
  ld    de,Object001Table.lenghtobjectdata
  ret   nz

  ld    de,Object001Table.lenghtobjectdata
  add   ix,de                           ;add the lenght of current object data to ix, and set next object in ix
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  call  .SetPushingStoneInEnemyTable
    
  ld    de,7
  add   hl,de                           ;room y for next block in pushing block table
  jr    .NotYetPresent                  ;now loop this routine and look for more pushing stones in this room

  .SetRoomYXStoneXYAndTableAddress:
  ;set room y
  ld    a,(WorldMapPositionY)
  ld    (hl),a

  ;set room x
  dec   hl
  ld    a,(WorldMapPositionX)
  ld    (hl),a

  ;set stone x
  dec   hl
  ld    a,(ix+Object150Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  set   0,a                             ;pushing stones need to have an odd x value
  ld    (hl),a

  ;set stone y
  dec   hl
  ld    a,(ix+Object150Table.y)
  ld    (hl),a

  ld    (iy+enemies_and_objects.v1-2),l ;set coordinates in pushing stone table (PuzzleBlocks1Y, PuzzleBlocks2Y etc)
  ld    (iy+enemies_and_objects.v1-1),h
  ret

  .SetPushingStoneInEnemyTable:
  push  hl
  ld    hl,Object001Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir                                  ;copy enemy table
  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  ld    a,(AmountOfPushingStonesInCurrentRoom)
  inc   a
  ld    (AmountOfPushingStonesInCurrentRoom),a

  pop   hl
  ret

  .SetAlive?BasedOnEngineType:
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ret   z
  ld    (iy+enemies_and_objects.Alive?),2
  ret

  .Object061:                           ;glass ball (GlassBallActivator)
  ld    a,(ix+Object061Table.ballnr)
  cp    4
  jr    nc,.SetGlassBall4

  .SetGlassBall1:
  ld    hl,GlassBall1Data
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*3           ;3 objects (2 balls and 1 ball activator)
  ldir

  ld    de,lenghtenemytable*2           ;lenght 2 objects in object table
  add   iy,de                           ;next object in object table

  ld    de,Object061Table.lenghtobjectdata*2
  ret    
  
  .SetGlassBall4:
  ld    hl,GlassBall5Data
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*3           ;3 objects (2 balls and 1 ball activator)
  ldir

  ld    de,lenghtenemytable*2           ;lenght 2 objects in object table
  add   iy,de                           ;next object in object table

  ld    de,Object061Table.lenghtobjectdata*2
  ret    


  .Object003:                           ;waterfall grey statue (WaterfallEyesGrey)
  ld    hl,Object003Table.eyes
  jr    .EntryForObject003

  .Object002:                           ;waterfall yellow statue (WaterfallEyesYellow)
;v1=sx
;v2=Active Timer
;v3=wait timer in case only 1 waterfall
;v4=Waterfall nr
  ld    hl,Object002Table.eyes
  .EntryForObject003:
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir                                  ;copy enemy table

  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  ;set x
  ld    a,(ix+Object002Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  add   a,8
  ld    (iy+enemies_and_objects.x),a    ;x waterfall

  ;set y
  ld    a,(ix+Object002Table.y)
  add   a,3
  ld    (iy+enemies_and_objects.y),a    ;Y waterfall

  ld    a,(AmountOfWaterfallsInCurrentRoom)
  inc   a
  ld    (AmountOfWaterfallsInCurrentRoom),a
  ld    (iy+enemies_and_objects.v4),a   ;v4=Waterfall nr
  dec   a
  jr    z,.EndCheckActivationMomentWaterfall
  exx                                   ;a 2nd or 3d waterfall uses the same sprite position as the 1st, sprite size=8, so decrease b with 8
  ld    a,b
  sub   a,8
  ld    b,a
  exx  
  .EndCheckActivationMomentWaterfall:

  ;next object (mouth)
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  ld    hl,Object002Table.mouth
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir                                  ;copy enemy table

  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  call  .WaterfallSprite                ;we also need to set a waterfall hardware sprite
  
  ld    de,Object002Table.lenghtobjectdata
  ret

  .WaterfallSprite:                     ;we also need to set a waterfall hardware sprite
  ld    hl,Object002Table.water         ;we also need to set a waterfall hardware sprite
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
  ret


  .Object004:                           ;poison drops (DrippingOozeDrop)
;v1=sx
;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
;v3=Vertical Movement
;v4=Grow Duration
;v5=Wait FOr Respawn Counter
;v8=Y spawn
;v9=X spawn
  ld    hl,Object004Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir                                  ;copy enemy table

  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  ;set x
  ld    a,(ix+Object004Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  add   a,3
  ld    (iy+enemies_and_objects.v9),a   ;v9=X spawn

  ;set y
  ld    a,(ix+Object004Table.y)
  add   a,03                            ;32 pix down
  ld    (iy+enemies_and_objects.v8),a   ;v8=Y spawn

  ;if there is a second Poison Drop object, then the activation timer should increase, so the poison drops don't spawn at the same time
  ld    a,(AmountOfPoisonDropsInCurrentRoom)
  inc   a
  ld    (AmountOfPoisonDropsInCurrentRoom),a
  dec   a
  jr    z,.EndCheckMultiPoisonDrops
  ld    (iy+enemies_and_objects.v5),180 ;v5=Wait FOr Respawn Counter 
  exx                                   ;a 2nd poison drop uses the same sprite position as the 1st, sprite size=4, so decrease b with 4
  ld    a,b
  sub   a,4
  ld    b,a
  exx
  .EndCheckMultiPoisonDrops:
  
  call  .AddSplashSprite                ;we also need to set a splashing hardware sprite, when drop hits the ooze pool
  
  ld    de,Object004Table.lenghtobjectdata
  ret

  .AddSplashSprite:                     ;we also need to set a splashing hardware sprite, when drop hits the ooze pool
  ld    hl,Object004Table.Splash        ;we also need to set a splashing hardware sprite, when drop hits the ooze pool
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
  ret

  .Object005:                           ;area sign (AreaSign)
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=put line in all 3 pages
;v7=sprite frame
;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)
;v9=wait timer / bottom of area sign
  ld    hl,Object005Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1           ;1 objects
  ldir

  ld    a,(PreviousRuin)
  ld    b,a                             ;current ruin ID
	ld    a,(UnpackedRoomFile+roomDataBlock.mapid)
	and   $1f
  cp    b
  jr    z,.DontSetAreaSign              ;if current ruin ID is the same as previous ruin ID, then don't set area sign in play

  push  ix
  push  iy
dec a ;REMOVE LATER, song#7 for konark doesnt exist yet
  call  CheckSwitchNextSong.EndCheckLastSong
  pop   iy
  pop   ix

  call  ResetPushStones

  ld    de,Object005Table.lenghtobjectdata
  ret   
  
  .DontSetAreaSign:
  ld    (iy+enemies_and_objects.Alive?),0
  ld    de,Object005Table.lenghtobjectdata
  ret   

  .Object062:                           ;zombie spawn point (ZombieSpawnPoint)
;v1=Zombie Spawn Timer
;v2=Max Number Of Zombies
;v3=Spawn Speed
;v4=Face direction
  ld    hl,Object062Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir

  call  .SetAlive?BasedOnEngineType

  ;set x
  ld    a,(ix+Object062Table.x)
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object062Table.y)
  ld    (iy+enemies_and_objects.y),a

  ;set Max Number Of Zombies
  ld    a,(ix+Object062Table.MaxNum)
  ld    (iy+enemies_and_objects.v2),a

  ;set Zombies spawn speed
  ld    a,(ix+Object062Table.speed)
  ld    (iy+enemies_and_objects.v3),a

  ;set Zombies face direction
  ld    a,(ix+Object062Table.face)
  ld    (iy+enemies_and_objects.v4),a

  call  .SetGfxZombieSpawnPoint

  ld    b,(ix+Object062Table.MaxNum)
  .addZombieLoop:
  push  bc
  call  .AddZombie                      ;adds a zombie to the room's object table
  pop   bc
  djnz  .addZombieLoop

  ld    de,Object062Table.lenghtobjectdata
  ret  
  
  .AddZombie:                           ;add a zombie to the room's object table 
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  ld    hl,Object143Table               ;zombie
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
  ret

  .SetGfxZombieSpawnPoint:
  ld    a,-1
  ld    (FreeToUseFastCopy+dpage),a
  ld    de,00                           ;x offset for spawnpoint in page 0
  call  .SetZombieSpawnPointInThisPage
  ld    de,16                           ;x offset for spawnpoint in page 1
  call  .SetZombieSpawnPointInThisPage
  ld    de,32                           ;x offset for spawnpoint in page 2
  call  .SetZombieSpawnPointInThisPage
  ld    de,48                           ;x offset for spawnpoint in page 3
;  call  .SetZombieSpawnPointInThisPage
;  ret
    
  .SetZombieSpawnPointInThisPage:
  ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jr    z,.SetZombieSpawnPointNormalEngine
  ld    de,00
  .SetZombieSpawnPointNormalEngine:
  
  ld    a,(FreeToUseFastCopy+dpage)
  inc   a
  ld    (FreeToUseFastCopy+dpage),a

  ld    l,(iy+enemies_and_objects.x)
  ld    h,(iy+enemies_and_objects.x+1)
  or    a
  sbc   hl,de
  ld    a,h
  or    a
  ret   nz
  ld    a,l
  ld    (FreeToUseFastCopy+dx),a

  ld    a,0
  ld    (FreeToUseFastCopy+sx),a
  ld    a,216+32
  ld    (FreeToUseFastCopy+sy),a

  ld    a,(iy+enemies_and_objects.y)
  ld    (FreeToUseFastCopy+dy),a
  ld    a,3
  ld    (FreeToUseFastCopy+spage),a
  ld    a,16
  ld    (FreeToUseFastCopy+nx),a
  ld    a,08
  ld    (FreeToUseFastCopy+ny),a
  ld    a,$98
  ld    (FreeToUseFastCopy+copytype),a
  call  .CopyRowOf8PixelsHigh
  call  .CopyRowOf8PixelsHigh
  call  .CopyRowOf8PixelsHigh
  call  .CopyRowOf8PixelsHigh
  ld    a,$d0
  ld    (FreeToUseFastCopy+copytype),a
  ret
  .CopyRowOf8PixelsHigh:
  ld    hl,FreeToUseFastCopy
  call  DoCopy
  ld    a,(FreeToUseFastCopy+sx)
  add   a,16
  ld    (FreeToUseFastCopy+sx),a
  ld    a,(FreeToUseFastCopy+dy)
  add   a,8
  ld    (FreeToUseFastCopy+dy),a
  ret
   
  .Object015:                           ;retracting platform  
  ld    hl,Object015Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*2
  ldir    

  ;retracting platform has 3 different situations:
  ;1=only 1 retracting platform in total: animation will be platform1 on, platform1 off
  ;2=only 2 retracting platforms in total: animation will be platform1 on, platform2 on, platform1 off, platform2 off
  ;3=3 or more retracting platforms in total: animation will be platform1 on, platform3 off, platform2 on, platform1 off, platform3 on, platform2 off (this concept can then be used for more than 3)
  
  ;first let's find total amount of retracting platforms
  ld    b,1                             ;amount of retracting platforms
  ld    de,Object015Table.lenghtobjectdata
  push  ix
  call  .FindTotalAmountOfRetractingPlatforms
  pop   ix

  ld    a,b
  ld    (AmountOfAppearingBlocks),a
  dec   a                               ;only 1 platform ?
;  jp    z,.MoreThan2RetractingPlatforms ;only 1 platform uses the same placement routin as more than 2
  jp    z,.Only1RetractingPlatform ;only 1 platform uses the same placement routin as more than 2
  dec   a                               ;only 2 platforms ?
  jp    z,.Only2RetractingPlatforms

  .MoreThan2RetractingPlatforms:  
  push  iy
  ld    iy,AppearingBlocksTable
  push  iy
  .PlatformLoop:
  ld    a,(ix+Object015Table.y)
  ld    l,a
  ld    (iy+0),a                        ;y block 1 (block turns on)
  ld    (iy+9),a                        ;y block 1 (block turns off)
  ld    a,(ix+Object015Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    h,a
  ld    (iy+1),a                        ;x block 1 (block turns on)
  ld    (iy+2),1                        ;block 1 on
  ld    (iy+10),a                       ;x block 1 (block turns off)
  ld    (iy+11),0                       ;block 1 off

  ld    de,Object015Table.lenghtobjectdata
  add   ix,de                           ;next object
  ld    de,6
  add   iy,de                           ;next block that turns on in list

  djnz  .PlatformLoop
  ld    (iy+0),255                      ;end list

  pop   iy  
  ld    (iy+3),l                        ;y last block (block turns on)
  ld    (iy+4),h                        ;x last block (block turns on)
  ld    (iy+5),0                        ;off
  pop   iy
  
  ld    de,Object015Table.lenghtobjectdata
  ret  

  .Only2RetractingPlatforms:  
  ld    a,1
  ld    (AppearingBlocksTable+2),a
  ld    (AppearingBlocksTable+5),a
  xor   a
  ld    (AppearingBlocksTable+8),a
  ld    (AppearingBlocksTable+11),a
  ld    a,255
  ld    (AppearingBlocksTable+12),a

  ld    a,(ix+Object015Table.y)
  ld    (AppearingBlocksTable+0),a
  ld    (AppearingBlocksTable+6),a
  ld    a,(ix+Object015Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+1),a
  ld    (AppearingBlocksTable+7),a

  ld    de,Object015Table.lenghtobjectdata
  add   ix,de                           ;next retracting platform

  ld    a,(ix+Object015Table.y)
  ld    (AppearingBlocksTable+3),a
  ld    (AppearingBlocksTable+9),a
  ld    a,(ix+Object015Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+4),a
  ld    (AppearingBlocksTable+10),a

  ld    de,Object015Table.lenghtobjectdata
  ret

  .Only1RetractingPlatform:
  ld    a,1
  ld    (AppearingBlocksTable+2),a
  xor   a
  ld    (AppearingBlocksTable+5),a
  ld    a,255
  ld    (AppearingBlocksTable+6),a

  ld    a,(ix+Object015Table.y)
  ld    (AppearingBlocksTable+0),a
  ld    (AppearingBlocksTable+3),a
  ld    a,(ix+Object015Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (AppearingBlocksTable+1),a
  ld    (AppearingBlocksTable+4),a

  ld    de,Object015Table.lenghtobjectdata
  ret

  .FindTotalAmountOfRetractingPlatforms:
  add   ix,de                           ;next object
  ld    a,(ix)
  cp    15
  ret   nz
  inc   b
  jr    .FindTotalAmountOfRetractingPlatforms

  .Object057:                           ;big moving platform off
  call  .Object011

  ;set box x right
  ld    a,(ix+Object011Table.xbox)
  add   a,(ix+Object011Table.widthbox)
  sub   a,32/2                          ;subtract width platform
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  call  .CheckIfObjectMovementIsWithinAllowedRange
  ld    de,Object011Table.lenghtobjectdata
  ld    (iy+enemies_and_objects.v1-2),l ;v1-2 and v1-1=box right (16bit)
  ld    (iy+enemies_and_objects.v1-1),h ;v1-2 and v1-1=box right (16bit)

  ld    (iy+enemies_and_objects.nx),32  ;nx
  ld    (iy+enemies_and_objects.v2),001 ;v2=active?
  ld    (iy+enemies_and_objects.v1),032 ;v1=sx software sprite in Vram on
  ld    a,(ix+Object011Table.active)
  cp    1
  ret   z
  ld    (iy+enemies_and_objects.v1),000 ;v1=sx software sprite in Vram off
  ld    (iy+enemies_and_objects.v2),000 ;v2=active?
  ret

  .Object012:                           ;small moving platform (lighter version)
  call  .Object011
  ld    (iy+enemies_and_objects.v1),080 ;v1=sx software sprite in Vram off
  ld    a,(ix+Object011Table.active)
  ld    (iy+enemies_and_objects.v2),a   ;v2=active?
  or    a
  ret   z
  ld    (iy+enemies_and_objects.v1),096 ;v1=sx software sprite in Vram on
  ret








  .Object010:                           ;huge block (HugeBlock)
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

  call  .SetHugeBlock

  ;if we have spritesplit enabled, we split our block in 2 and put top and bottom as separate objects
  ld    a,(scrollEngine)              ;1= 304x216 engine, 2=256x216 SF2 engine, 3=256x216 SF2 engine sprite split ON 
  cp    2
  ret   z

  ld    (iy+enemies_and_objects.v1),1   ;v1=0 normal total block, v1=1 top half, v1=2 bottom half
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table
  call  .SetHugeBlock
  ld    (iy+enemies_and_objects.v1),2   ;v1=0 normal total block, v1=1 top half, v1=2 bottom half
  ret

  .SetHugeBlock:
  ld    hl,Object010Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1           ;1 objects
  ldir

  ld    a,(AmountOfSF2ObjectsCurrentRoom)
  ld    (iy+enemies_and_objects.v2),a   ;v2=framenumber to handle this object on
  inc   a
  ld    (AmountOfSF2ObjectsCurrentRoom),a

  ;set x (relative to box)
  ld    a,(ix+Object010Table.xbox)
  add   a,(ix+Object010Table.relativex)
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y (relative to box)
  ld    a,(ix+Object010Table.ybox)
  add   a,(ix+Object010Table.relativey)
;  sub   a,.HeightHugeBlock/2
  ld    (iy+enemies_and_objects.y),a

  ;set box x left
  ld    l,(ix+Object010Table.xbox)
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.v6),l   ;v6 and v7=box left (16bit)
  ld    (iy+enemies_and_objects.v7),h   ;v6 and v7=box left (16bit)

  ;set box x right
  ld    a,(ix+Object010Table.xbox)
  add   a,(ix+Object010Table.widthbox)
  sub   a,.WidthHugeBlock/2
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  call  .CheckIfObjectMovementIsWithinAllowedRange
  ld    (iy+enemies_and_objects.v1-2),l ;v1-2 and v1-1=box right (16bit)
  ld    (iy+enemies_and_objects.v1-1),h ;v1-2 and v1-1=box right (16bit)

  ;set box y top
  ld    a,(ix+Object010Table.ybox)
  ld    (iy+enemies_and_objects.v8),a   ;v8=box top

  ;set box y bottom
  add   a,(ix+Object010Table.heightbox)
  sub   a,.HeightHugeBlock
  ld    (iy+enemies_and_objects.v9),a   ;v9=box bottom

  ;set facing direction
  ld    a,(ix+Object010Table.face)
  add   a,a
  ld    d,0
  ld    e,a
  ld    hl,Movementtable-2
  add   hl,de
  ld    a,(hl)                          ;y

  ;We multiplay the vertical movement with the object speed
  ld    b,0
  ld    c,(ix+Object010Table.speed)     ;object speed
  push  hl
  call  checktile.Mult12                ;Multiply 8-bit value with a 16-bit value. In: Multiply A with BC. Out: HL = result 
  or    a
  sbc   hl,de                           ;AAAAAAAAAAAAAAAAAAAAAAH
  ld    (iy+enemies_and_objects.v3),l   ;v3=y movement
  pop   hl

  inc   hl
  ld    a,(hl)                          ;x

  ;We multiplay the horizontal movement with the object speed
  ld    b,0
  ld    c,(ix+Object010Table.speed)     ;object speed
  call  checktile.Mult12                ;Multiply 8-bit value with a 16-bit value. In: Multiply A with BC. Out: HL = result 
  or    a
  sbc   hl,de                           ;AAAAAAAAAAAAAAAAAAAAAAH
  ld    (iy+enemies_and_objects.v4),l   ;v4=x movement

  ld    de,Object010Table.lenghtobjectdata
  ret   

  .HeightHugeBlock:   equ 48
  .WidthHugeBlock:    equ 48



  .Object011:                           ;small moving platform on (standard dark grey)
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

  ld    hl,Object011Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  ;set x (relative to box)
  ld    a,(ix+Object011Table.xbox)
  add   a,(ix+Object011Table.relativex)
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y (relative to box)
  ld    a,(ix+Object011Table.ybox)
  add   a,(ix+Object011Table.relativey)
  ld    (iy+enemies_and_objects.y),a
  
  ;set box x left
  ld    l,(ix+Object011Table.xbox)
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.v6),l   ;v6 and v7=box left (16bit)
  ld    (iy+enemies_and_objects.v7),h   ;v6 and v7=box left (16bit)

  ;set box x right
  ld    a,(ix+Object011Table.xbox)
  add   a,(ix+Object011Table.widthbox)
  sub   a,16/2                          ;subtract width platform
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  call  .CheckIfObjectMovementIsWithinAllowedRange
  ld    (iy+enemies_and_objects.v1-2),l ;v1-2 and v1-1=box right (16bit)
  ld    (iy+enemies_and_objects.v1-1),h ;v1-2 and v1-1=box right (16bit)

  ;set box y top
  ld    a,(ix+Object011Table.ybox)
  ld    (iy+enemies_and_objects.v8),a   ;v8=box top

  ;set box y bottom
  add   a,(ix+Object011Table.heightbox)
  sub   a,16                            ;subtract height platform
  ld    (iy+enemies_and_objects.v9),a   ;v9=box bottom

  ;set facing direction
  ld    a,(ix+Object011Table.face)
  add   a,a
  ld    d,0
  ld    e,a
  ld    hl,Movementtable-2
  add   hl,de
  ld    a,(hl)                          ;y
  ld    (iy+enemies_and_objects.v3),a   ;v3=y movement
  inc   hl
  ld    a,(hl)                          ;x
  ld    (iy+enemies_and_objects.v4),a   ;v4=x movement
  
  ;set speed
  ld    a,(ix+Object011Table.speed)
  ld    (iy+enemies_and_objects.v10),a  ;v10=speed

  ;set active
  ld    (iy+enemies_and_objects.v2),1   ;v2=active?

  ld    de,Object011Table.lenghtobjectdata
  ret

  .CheckIfObjectMovementIsWithinAllowedRange:
  ld    de,253                          ;box right edge
  xor   a                               ;clear carry flag
  sbc   hl,de
  jr    c,.WithinRange
  ld    hl,253                          ;16 pixels wide
  ret
  .WithinRange:
  add   hl,de
  ret

  .Object016:                           ;omni directional platform
  ld    hl,Object016Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetCleanObjectNumber            ;each object has a reference cleanup table

  ;set  x
  ld    a,(ix+Object016Table.x)
  add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),a

  ;set  y
  ld    a,(ix+Object016Table.y)
  ld    (iy+enemies_and_objects.y),a

  ld    a,(ObjectPresentInVramPage1)    ;1=omni directional platform
  cp    1
  jr    z,.EndPutObject016
  ld    a,1
  ld    (ObjectPresentInVramPage1),a    ;1=omni directional platform
  
  ;write omni directional platforms to (216+16,0) page 1
  xor   a
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + ((216+016)*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (016*256) + (128/2)        ;(ny*256) + (nx/2)
  ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  .EndPutObject016:
  ld    de,Object016Table.lenghtobjectdata
  ret

  .Object020:                           ;bat spawner (BigStatueMouth)
  ld    hl,Object020Table
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable*1
  ldir                                  ;copy enemy table

  ;set x
  ld    a,(ix+Object020Table.x)
  add   a,4                             ;10 pix to the right
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object020Table.y)
  add   a,24                            ;8 pix down
  ld    (iy+enemies_and_objects.y),a

  ld    a,(ix+Object020Table.face)
  ld    (iy+enemies_and_objects.v9),a   ;face

  ld    b,(ix+Object020Table.MaxNum)
  ld    (iy+enemies_and_objects.v10),b  ;max number
  
  ld    hl,CuteMiniBatTable             ;cute mini bat
  .AddCuteMiniBatLoop:
  push  bc
  call  .AddCuteMiniBat                       ;adds a cute mini bat to the room's object table
  pop   bc
  djnz  .AddCuteMiniBatLoop

  ld    a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
  cp    1
  jr    z,.EndPutObject020
  ld    a,1
  ld    (BigEnemyPresentInVramPage3),a  ;1=big statue mouth, 2=huge blob, 3=huge spider
  
  ;write big statue mouth to (216,0) page 3
  ld    a,1
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (016*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + (216*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (031*256) + (056/2)        ;(ny*256) + (nx/2)
  ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

;call screenon
;	ld    a,3*32+31         ;set page 0
;di
;	out   ($99),a
;	ld    a,2+128
;	out   ($99),a


;	ld    a,100 
;	out   ($99),a
;	ld    a,23+128
;	out   ($99),a
;ei


;.kut: jp .kut

  .EndPutObject020:
  ld    de,Object020Table.lenghtobjectdata
  ret

  .AddCuteMiniBat:                      ;add a cute mini bat to the room's object table 
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
  ret

  .Object128:                           ;huge blob (HugeBlob)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=jumping)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Jump to Which platform ? (1,2 or 3)
;v6=Gravity timer
;v7=Dont Check Land Platform First x Frames
  exx
  ld    b,16                            ;huge blob starts at sprite nr 16 and places player at sprite 12-15, to make sure player is always in the front
  exx   

  ld    hl,Object128Table
  call  .SetGeneralHardwareSpriteNotMovingObject

  ;we also need to set a vram object, the rest of the blob's body. this is a separate object
  ld    hl,Object128Table.body
  call  .SetObjectBelongingToHardwareSprite

  ld    a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
  cp    2
  jr    z,.EndPutObject128
  ld    a,2
  ld    (BigEnemyPresentInVramPage3),a  ;1=big statue mouth, 2=huge blob, 3=huge spider
  
  ;write huge blob to (216,0) page 3
  ld    a,1
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (016*128) + (112/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + (216*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (032*256) + (074/2)        ;(ny*256) + (nx/2)
  ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  .EndPutObject128:
  ld    de,Object128Table.lenghtobjectdata
  ret

  .Object129:                           ;huge spider (HugeSpiderLegs)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  ld    hl,Object129Table
  call  .SetGeneralHardwareSprite

  ;we also need to set a vram object, the body. this is a separate object
  ld    hl,Object129Table.body
  call  .SetObjectBelongingToHardwareSprite

  ld    a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
  cp    3
  jr    z,.EndPutObject129
  ld    a,3
  ld    (BigEnemyPresentInVramPage3),a  ;1=big statue mouth, 2=huge blob, 3=huge spider
  
  ;write huge spider to (216,0) page 3
  ld    a,1
  ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
  ld    hl,$4000 + (016*128) + (186/2) - 128  ;(y*128) + (x/2)
  ld    de,$8000 + (216*128) + (000/2) - 128  ;(y*128) + (x/2)
  ld    bc,$0000 + (021*256) + (054/2)        ;(ny*256) + (nx/2)
  ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
  call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

  .EndPutObject129:
  ld    de,Object129Table.lenghtobjectdata
  ret

  .Object130:                           ;lancelot (Lancelot)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Shield hit timer
  ld    hl,Object130Table
  call  .SetGeneralHardwareSprite

  ;we also need to set a sword object, this is a separate object
  ld    hl,Object130Table.sword
  call  .SetObjectBelongingToHardwareSprite

  ld    de,Object130Table.lenghtobjectdata
  ret

  .Object131:                           ;black hole alien (BlackHoleAlien)
;v1=Animation Counter
;v4=Horizontal Movement
  ld    hl,Object131Table
  jp    .SetGeneralHardwareSprite

  .Object132:                           ;green fire eye (FireEye)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=v3v4tablerotator
;v7=green fire eye(0) / grey fire eye(1)
  ld    hl,Object132Table
  call  .SetGeneralHardwareSpriteNotMovingObject

  .SetFireEyeBullets:                   ;we also need to set 4 bullet objects
  ld    hl,Object132Table.bullet
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object132Table.bullet
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object132Table.bullet
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object132Table.bullet
  call  .SetObjectBelongingToHardwareSprite

  ld    de,Object132Table.lenghtobjectdata
  ret

  .Object133:                           ;grey fire eye (FireEye)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=v3v4tablerotator
;v7=green fire eye(0) / grey fire eye(1)
  ld    hl,Object132Table
  call  .SetGeneralHardwareSpriteNotMovingObject
  ld    (iy+enemies_and_objects.v7),1   ;v7=green fire eye(0) / grey fire eye(1)
  jp    .SetFireEyeBullets

  .SetObjectBelongingToHardwareSprite:
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table
  jp    SetCleanObjectNumber            ;each object has a reference cleanup table

  .SetHandlerObject:                    ;this object does not put an image in screen, just handles something
  ld    de,lenghtenemytable             ;lenght 1 object in object table
  add   iy,de                           ;next object in object table

  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table
  ret

  .Object134:                           ;knife thrower (SnowballThrower)
;v1=Animation Counter
;v2=Phase (0=Walking, 1=Throwing)
;v3=Vertical Movement
;v4=Horizontal Movement
  ld    hl,Object134Table
  call  .SetGeneralHardwareSprite

  ld    hl,Object134Table.knife
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object134Table.knife
  call  .SetObjectBelongingToHardwareSprite

  ld    de,Object134Table.lenghtobjectdata
  ret

  .Object135:                           ;octopussy (Octopussy)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack phase duration
  ld    hl,Object135Table
  call  .SetGeneralHardwareSpriteNotMovingObject

  ld    hl,Object135Table.bullet
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object135Table.bullet
  call  .SetObjectBelongingToHardwareSprite
  ld    hl,Object135Table.slowdownhandler
  call  .SetHandlerObject
  ld    de,Object135Table.lenghtobjectdata
  ret

  .Object136:                           ;grinder (Grinder)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  ld    hl,Object136Table
  jp    .SetGeneralHardwareSprite

  .Object137:                           ;treeman (Treeman)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
  ld    hl,Object137Table
  jp    .SetGeneralHardwareSprite

  .Object138:                           ;hunchback (Hunchback)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
;v6=Gravity timer
  ld    hl,Object138Table
  jp    .SetGeneralHardwareSprite

  .Object139:                           ;scorpion (Scorpion)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Rattle timer / Wait before Rattle again Timer
  ld    hl,Object139Table
  jp    .SetGeneralHardwareSprite

  .Object140:                           ;beetle (Beetle)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=movement table. 0=Table 1 (Circling ClockWise) 1=Table 1 (Circling CounterClockwise)      
;v8=face left (-0) or face right (1)
  ld    hl,Object140Table
  call  .SetGeneralHardwareSprite

  ;set y
  ld    a,(iy+enemies_and_objects.y)
  add   2                               ;ny=22, thats 2 below an 8-fold, therefor add 2 to it's y
  ld    (iy+enemies_and_objects.y),a

  ;set face in v8 for this object
  ld    a,(iy+enemies_and_objects.v4)   ;v4=Horizontal Movement
  or    a
  ret   p
  ld    (iy+enemies_and_objects.v8),0   ;v8=face left (-0) or face right (1)
  ret

  .Object141:                           ;green spider (GreenSpider)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=fast)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Grey Spider Slow Down Timer
;v6=Green Spider(0) / Grey Spider(1)
  ld    hl,Object141Table
  jp    .SetGeneralHardwareSprite

  .Object142:                           ;grey spider (GreenSpider)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=fast)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Grey Spider Slow Down Timer
;v6=Green Spider(0) / Grey Spider(1)
  ld    hl,Object141Table
  call  .SetGeneralHardwareSprite
  ld    (iy+enemies_and_objects.v6),1   ;v6=Green Spider(0) / Grey Spider(1)
  ret

  .Object144:                           ;green boring eye (BoringEye)
;v1=Animation Counter
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Green (0) / Red(1)
  ld    hl,Object144Table
  jp    .SetGeneralHardwareSpriteNotMovingObject

  .Object145:                           ;red boring eye (BoringEye)
;v1=Animation Counter
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Green (0) / Red(1)
  ld    hl,Object144Table
  call  .SetGeneralHardwareSpriteNotMovingObject
  ld    (iy+enemies_and_objects.v7),1   ;v7=Green (0) / Red(1)
  ret

  .Object146:                           ;black hole alien baby (BlackHoleBaby)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v6=Gravity timer
  ld    hl,Object146Table
  jp    .SetGeneralHardwareSprite

  .Object148:                           ;landstrider (LandStrider)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=unable to hit timer
;v6=Grow Timer
;v7=move up once when growing flag
  ld    hl,Object148Table
  call  .SetGeneralHardwareSprite
  exx                                   ;landstider uses 2 sprites when small, but 4 sprites when big, therefor we need to reserve 2 extra sprite positions for this object
  inc   b                               ;next sprite position in b
  inc   b                               ;next sprite position in b
  exx
  ret

  .Object149:                           ;sensor tentacles (SensorTentacles)
;v1=Animation Counter
;v2=Phase (0=Hanging, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Gravity timer
;v8=Starting Y
;v9=wait until attack timer 
  ld    hl,Object149Table
  call  .SetGeneralHardwareSpriteNotMovingObject
  ld    a,(iy+enemies_and_objects.y)    ;y
  ld    (iy+enemies_and_objects.v8),a   ;v8=Starting Y
  ret


  .Object150:                           ;trampoline blob
;v1=Animation Counter
;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping)
;v4=Horizontal Movement
;v5=Unable to be hit duration
  ld    hl,Object150Table
  jp    .SetGeneralHardwareSprite

  .Object151:                           ;green circling wasp (Wasp)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Repeating Steps
;v6=Pointer To Movement Table
;v7=Green Wasp(0) / Brown Wasp(1)
;v8=face left (-0) or face right (1)
  ld    hl,Object151Table
  jp    .SetGeneralHardwareSpriteNotMovingObject

  .Object152:                           ;brown circling wasp (Wasp)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Repeating Steps
;v6=Pointer To Movement Table
;v7=Green Wasp(0) / Brown Wasp(1)
;v8=face left (-0) or face right (1)
  ld    hl,Object151Table
  call  .SetGeneralHardwareSpriteNotMovingObject
  ld    (iy+enemies_and_objects.v7),1   ;v7=Green Wasp(0) / Brown Wasp(1)
  ret

  .Object153:                           ;yellow wasp (YellowWasp)
;v1=Animation Counter
;v2=Phase (0=Hovering Towards player, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=attack duration
;v8=face left (0) or face right (1) 
  ld    hl,Object153Table
  jp    .SetGeneralHardwareSpriteNotMovingObject

  .SetGeneralHardwareSpriteNotMovingObject:
  call  .SetGeneralHardwareSprite
  ld    de,3                            ;id, x, y, face, speed (lenght object data)
  ret
  
  .SetGeneralHardwareSprite:
  push  iy
  pop   de                              ;enemy object table
  ld    bc,lenghtenemytable
  ldir                                  ;copy enemy table

  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT

  ;set x
  ld    a,(ix+Object150Table.x)
  add   a,8                             ;all hardware sprites need to be put 16 pixel to the right
  ld    l,a
  ld    h,0
  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
  ld    (iy+enemies_and_objects.x),l
  ld    (iy+enemies_and_objects.x+1),h

  ;set y
  ld    a,(ix+Object150Table.y)
  ld    (iy+enemies_and_objects.y),a

  ;set facing direction
  ld    a,(ix+Object150Table.face)
  cp    3
  jr    z,.EndCheckMovingRight          ;the standard movement direction of any object is right, if this is the facing direction, then we don't need to change movement direction
  ld    a,(iy+enemies_and_objects.v4)   ;v4=Horizontal Movement
  neg
  ld    (iy+enemies_and_objects.v4),a   ;v4=Horizontal Movement
  .EndCheckMovingRight:

  ld    de,5                            ;id, x, y, face, speed (lenght object data)
  ret

  .Object154:                           ;green demontje (Demontje)
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  ld    hl,Object154Table
  call  .SetGeneralHardwareSprite

  .SetDemontjeBullet:                   ;we also need to set a bullet object, this is a separate object
  ld    hl,Object154Table.bullet
  call  .SetObjectBelongingToHardwareSprite

  ld    de,Object154Table.lenghtobjectdata
  ret

  .Object155:                           ;red demontje (Demontje)
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  ld    hl,Object154Table
  call  .SetGeneralHardwareSprite
  ld    (iy+enemies_and_objects.v7),1   ;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  jp    .SetDemontjeBullet

  .Object156:                           ;brown demontje (Demontje)
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  ld    hl,Object154Table
  call  .SetGeneralHardwareSprite
  ld    (iy+enemies_and_objects.v7),2   ;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  jp    .SetDemontjeBullet

  .Object157:                           ;grey demontje (Demontje)
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  ld    hl,Object154Table
  call  .SetGeneralHardwareSprite
  ld    (iy+enemies_and_objects.v7),3   ;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
  jp    .SetDemontjeBullet

  .Object158:                           ;black slime (Slime)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
  ld    hl,Object158Table
  jp    .SetGeneralHardwareSprite

  .Object159:                           ;glassball pipe (GlassballPipe)
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait timer
  ld    hl,GlassBallPipeObject
  call  .SetGeneralHardwareSpriteNotMovingObject
  dec   (iy+enemies_and_objects.y)      ;should be 1 pixel up
  dec   (iy+enemies_and_objects.x)      ;should be 1 pixel to the left
  ret

;  .Object143:                           ;retarded zombie
;v1=Animation Counter
;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Wait Timer
;  ld    hl,Object143Table
;  push  iy
;  pop   de                              ;enemy object table
;  ld    bc,lenghtenemytable
;  ldir                                  ;copy enemy table

;  call  SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT

  ;set x
;  ld    a,(ix+Object143Table.x)
;  add   a,8                             ;all hardware sprites need to be put 16 pixel to the right
;  ld    l,a
;  ld    h,0
;  add   hl,hl                           ;*2 (all x values are halved, so *2 for their absolute values)
;  ld    (iy+enemies_and_objects.x),l
;  ld    (iy+enemies_and_objects.x+1),h

  ;set y
;  ld    a,(ix+Object143Table.y)
;  ld    (iy+enemies_and_objects.y),a

  ;set facing direction
;  ld    a,(ix+Object143Table.face)
;  cp    3
;  jr    z,.EndCheckMovingRight2          ;the standard movement direction of any object is right, if this is the facing direction, then we don't need to change movement direction
;  ld    (iy+enemies_and_objects.v4),-1  ;v4=Horizontal Movement
;  .EndCheckMovingRight2:

;  ld    de,Object143Table.lenghtobjectdata
;  ret

SetCleanObjectNumber:                   ;each object has a reference cleanup table
  exx
  ld    (iy+enemies_and_objects.ObjectNumber),l
  ld    (iy+enemies_and_objects.ObjectNumber+1),h
  ld    de,CleanObjectTableLenght
  add   hl,de                           ;set next clean object table for potential next object
  exx
  ret

SetSPATPositionForThisSprite:           ;we need to define the position this sprite takes in the SPAT
  exx
  push  hl
  ld    l,b                             ;hardware object sprite nr (sprite 0-11 are border masking sprites, after this start the hardware sprite objects)
  ld    h,0
  add   hl,hl                           ;*2
  push  hl
  ld    de,spat
  add   hl,de
  ld    (iy+enemies_and_objects.spataddress),l
  ld    (iy+enemies_and_objects.spataddress+1),h
  pop   hl
  add   hl,hl                           ;*4
  add   hl,hl                           ;*8
  add   hl,hl                           ;*16  
  ld    (iy+enemies_and_objects.SprNrTimes16),l
  ld    (iy+enemies_and_objects.SprNrTimes16+1),h
  pop   hl
  ld    a,(iy+enemies_and_objects.nrspritesSimple)
  add   a,b
  ld    b,a                             ;set next sprite position in b by adding the amount of sprites current object uses
  exx
  ret

                ;y,x  1=up,   2=upright,  3=right,  4=rightdown,  5=down, 6=downleft, 7=left, 8=leftup)
Movementtable:    db  -1,+0,  -1,+1,      +0,+1,    +1,+1,        +1,+0,  +1,-1,      +0,-1,  -1,-1  

Object001Table:               ;pushing stone (PushingStone)
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
          db 1,        0|dw PushingStone        |db 8*00|dw 8*00|db 16,16|dw CleanOb1,0 db 0 | dw PuzzleBlocks4Y | db  112,+00,+00,+00,+00,+00,+00,+14,+14, 0|db 000,movementpatterns1block| ds fill-1

Object005Table:               ;Area sign
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db 2,        0|dw AreaSign             |db 8*05|dw 8*17|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+00,+00,190, 0|db 016,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object010Table:               ;platform
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
          db 2,        0|dw HugeBlock           |db 8*06|dw 8*09|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movementpatterns1block| ds fill-1
.ID: equ 0
.relativex: equ 1
.relativey: equ 2
.xbox: equ 3
.ybox: equ 4
.widthbox: equ 5
.heightbox: equ 6
.face: equ 7
.speed: equ 8
.active: equ 9
.lenghtobjectdata: equ 10

Object010bTable:               ;platform
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
          db 2,        0|dw HugeBlock           |db 8*06|dw 8*09|db 24,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movementpatterns1block| ds fill-1
.ID: equ 0
.relativex: equ 1
.relativey: equ 2
.xbox: equ 3
.ybox: equ 4
.widthbox: equ 5
.heightbox: equ 6
.face: equ 7
.speed: equ 8
.active: equ 9
.lenghtobjectdata: equ 10

Object010cTable:               ;platform
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
          db 2,        0|dw HugeBlock           |db 8*06|dw 8*09|db 12,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movementpatterns1block| ds fill-1
.ID: equ 0
.relativex: equ 1
.relativey: equ 2
.xbox: equ 3
.ybox: equ 4
.widthbox: equ 5
.heightbox: equ 6
.face: equ 7
.speed: equ 8
.active: equ 9
.lenghtobjectdata: equ 10





Object011Table:               ;platform
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
          db 1,        0|dw Platform            |db 8*09|dw 8*18|db 16,16|dw CleanOb1,0 db 0,0,0,                      +64,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.relativex: equ 1
.relativey: equ 2
.xbox: equ 3
.ybox: equ 4
.widthbox: equ 5
.heightbox: equ 6
.face: equ 7
.speed: equ 8
.active: equ 9
.lenghtobjectdata: equ 10

Object015Table:               ;retracting platform (handler)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
          db 1,        0|dw AppBlocksHandler    |db 0*00|dw 0*00|db 00,00|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
                              ;AppearingBlocks
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
          db 0,        0|dw AppearingBlocks     |db 8*21|dw 8*19|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object016Table:               ;omni directional platform
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3
;platform Omni Directionally
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
          db 1,   0|dw PlatformOmniDirectionally|db 8*11|dw 8*10|db 16,16|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
          db 1,   0|dw PlatformOmniDirectionally|db 8*19|dw 8*25|db 16,16|dw CleanOb2,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

Object020Table:               ;bat spawner (BigStatueMouth)
;Big Statue Mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db 1,        0|dw BigStatueMouth    |db 8*09+4|dw 8*13|db 31,28|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.MaxNum: equ 5
.lenghtobjectdata: equ 6

;Cute Mini Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
CuteMiniBatTable:
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,095, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,180, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,045, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,160, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,030, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,110, 0|db 001,movementpatterns1block| ds fill-1

Object061Table:               ;glass ball (& GlassBallActivator)
.ID: equ 0
.ballnr: equ 1
.lenghtobjectdata: equ 2
GlassBall5Data:
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 2,        0|dw GlassBall3          |db 8*19|dw 8*02|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.object2: db 2,        0|dw GlassBall4          |db 8*19|dw 8*24|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
GlassBall1Data:
;Glass Ball
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db 0,        0|dw GlassBall1          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.object2: db 0,        0|dw GlassBall2          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Glass Ball Activator
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object3: db 2,        0|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

Object062Table:               ;zombie spawn point
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db  1,        1|dw ZombieSpawnPoint    |db 8*03|dw 8*19|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+04,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.MaxNum: equ 5
.lenghtobjectdata: equ 6

Object128Table:               ;huge blob
;Huge Blob
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw HugeBlob            |db 8*11|dw 8*20|db 48,46|dw 16*16,spat+(16*2)|db 72-(12*6),12  ,12*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
;Huge Blob software sprite part
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.body:    db 1,        0|dw HugeBlobSWsprite    |db 0*00|dw 0*00|db 21,14|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object129Table:               ;huge spider
;Huge Spider Legs
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw HugeSpiderLegs      |db 8*04|dw 8*14|db 24,64|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1  
;Huge Spider Body
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.body:    db 1,        0|dw HugeSpiderBody      |db 8*06|dw 8*14|db 21,27|dw CleanOb1,0 db 0,0,0,                     +027,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object130Table:               ;lancelot
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Lancelot            |db 8*13|dw 8*20|db 32,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
;Lancelot Sword
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.sword:  db 1,        0|dw LancelotSword       |db 8*10|dw 8*10|db 07,27|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object131Table:               ;Black Hole Alien
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw BlackHoleAlien      |db 8*21|dw 8*04|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object132Table:               ;green fire eye
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw FireEye             |db 8*19|dw 8*21|db 48,32|dw 12*16,spat+(12*2)|db 72-(11*6),11  ,11*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
;Fire Eye Firebullets
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.bullet:  db 0,        0|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb1,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object134Table:               ;knife thrower
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw SnowballThrower     |db 8*05|dw 8*13|db 32,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
;knife
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.knife:   db 0,        0|dw Snowball            |db 8*21|dw 8*13|db 04,15|dw CleanOb1,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object135Table:               ;octopussy
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Octopussy           |db 8*14|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
;Octopussy Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.bullet:  db 0,        0|dw OctopussyBullet     |db 8*12|dw 8*16|db 08,08|dw CleanOb1,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Octopussy Bullet Slow Down Handler
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.slowdownhandler: db 1,        0|dw OP_SlowDownHandler  |db 8*12|dw 8*16|db 00,00|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object136Table:               ;grinder
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Grinder             |db 8*19|dw 8*16|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1  
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object137Table:               ;treeman
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Treeman             |db 8*11|dw 8*30|db 32,26|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object138Table:               ;hunchback
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Hunchback           |db 8*21|dw 8*34|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 003,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object139Table:               ;scorpion
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Scorpion            |db 8*03|dw 8*20|db 32,22|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object140Table:               ;beetle
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Beetle           |db 8*14+10|dw 8*19|db 22,28|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+00,+00,+00,+01,+00, 0|db 003,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object141Table:               ;green / grey spider. v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw GreenSpider         |db 8*23|dw 8*12|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object143Table:               ;retarded zombie
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
;         db -0,        1|dw RetardedZombie      |db 0000|dw 0000|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
         db -0,        1|dw RetardedZombie      |db 8*00|dw 8*00|db 32,16|dw 12*16,spat+(12*2)|db 00-(00*0),04  ,04*16,+00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object144Table:               ;Boring Eye. v6=Green (0) / Red (1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw BoringEye           |db 8*18|dw 8*09|db 22,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object146Table:               ;black hole alien baby
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw BlackHoleBaby       |db 8*08|dw 8*05|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object148Table:               ;landstrider
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Landstrider         |db 8*24|dw 8*29|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object149Table:               ;sensor tentacles
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw SensorTentacles     |db 8*12|dw 8*16|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object150Table:               ;trampoline blob: v9=special width for Pushing Stone Puzzle Switch
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw TrampolineBlob      |db 8*10|dw 8*10|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+08,+36, 0|db 255,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object151Table:               ;green circling wasp. v7=Green Wasp(0) / Brown Wasp(1)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Wasp                |db 8*13|dw 8*11|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object153Table:               ;yellow wasp
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw YellowWasp          |db 8*12|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object154Table:               ;Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Demontje            |db 8*20|dw 8*30|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.bullet: db 0,        0|dw DemontjeBullet      |db 8*10|dw 8*15|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

Object158Table:               ;black slime
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw Slime               |db 8*07|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.face: equ 3
.speed: equ 4
.lenghtobjectdata: equ 5

GlassBallPipeObject:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db -1,        1|dw GlassballPipe       |db 8*07|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object002Table:               ;waterfall yellow statue (WaterfallEyesYellow)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.eyes:    db 1,        0|dw WaterfallEyesYellow |db 8*15+3|dw 8*17|db 06,14|dw CleanOb1,0 db 0,0,0,                   +067,+00,+01,+01,+00,8*15+3,8*17,8*00+3,8*00,8*00+3,8*00,movementpatterns1block| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.mouth:   db 0,        0|dw WaterfallMouth      |db 8*16+7|dw 8*17+2|db 06,10|dw CleanOb2,0 db 0,0,0,                 +119,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Waterfall
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.water:   db -0,       1|dw Waterfall           |db 8*00|dw 8*00|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object003Table:               ;waterfall grey statue (WaterfallEyesYellow)
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.eyes:    db 1,        0|dw WaterfallEyesGrey   |db 8*15+3|dw 8*28|db 06,14|dw CleanOb3,0 db 0,0,0,                   +095,+00,200,+02,+01,8*15+3,8*06,8*15+3,8*28,8*00+3,8*00,movementpatterns1block| ds fill-1




Object004Table:               ;Dripping Ooze Drop
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   ,Hit?,life 
          db 1,        0|dw DrippingOozeDrop    |db 8*09-5|dw 8*10+3|db 08,05|dw CleanOb1,0 db 0,0,0,                 +149,+02,+03,+00,+63,+00,+00,8*09-5,8*10+3, 0|db 000,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.Splash: db -0,        1|dw DrippingOoze        |db 8*22|dw 8*24|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object006Table:               ;Teleport
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db 2,        0|dw Teleport            |db 8*02  |dw 8*17  |db 64,64|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,+00,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3

Object007Table:               ;Waterfall Scene
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db 2,        0|dw WaterfallScene      |db 8*02  |dw 8*17  |db 64,64|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,+00,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1
.ID: equ 0
.x: equ 1
.y: equ 2
.lenghtobjectdata: equ 3


;Get room type [A] table record address [HL]
getRoomType:
		push bc
		ld l,A
		ld h,0
		add hl,hl
		add hl,hl
		ld bc,roomTypes.data
		add hl,bc
		pop bc
ret
;LookUpTable for Room Types (width,height,engine,free)
roomTypes:
.recLen:		equ 4		;[atrribute]record length
.numRec:		equ 8		;[atrribute]number of records
.size:			equ .reclen*.numrec		;[atrribute]table size
.roomWidth:		equ +0		;[property]Room with
.roomHeight:	equ +1		;[property]Room height
.engineType:	equ +2		;[property]engineType
.free:			equ +3		;[property]<free for future use>
.data:			DB 38,27,1,0	;Regular
				DB 32,27,2,0	;Teleport
				DB 38,27,1,0	;Secret
				DB 32,27,2,0	;Boss
				DB 32,27,3,0	;Gate
				DB 32,27,2,0	;RegularSmall
				DB 32,27,3,0	;NPC
				DB 0,0,0,0	;<free>


;Get room [DE] ROM location, block[A] address[HL]
getRoom:
		call GetWorldMapRoomLocation
		add a,Dsm.firstBlock ;+dsm.indexBlock	;offset (temp)
;		ld bc,$8000							;destination
;		add hl,bc
		set 7,h
;		ld ix,MapDataCopiedToRam
;		ld (ix+MapDataCopiedToRam.block),a
;		ld (ix+MapDataCopiedToRam.address+0),l
;		ld (ix+MapDataCopiedToRam.address+1),h
;		ld (ix+MapDataCopiedToRam.engine),1	;unused, I hope
;		ld (ix+MapDataCopiedToRam.tileset),0 ;unused
;		ld (ix+MapDataCopiedToRam.palette),0 ;unused
ret


;Get WorldMapRoom
;In:	DE=IndexID (D=X,E=Y)
;out:	HL=Address(relative, 0-3fff), A=block(relative)
GetWorldMapRoomLocation:
		ld    a,Dsm.firstBlock ;+dsm.indexBlock
		call  block34
        LD    HL,roomindex.data
        LD    BC,roomindex.reclen-1
GWMR.1: LD    A,D             ;x
        CP    (HL)
        INC   HL
        JR    NZ,GWMR.0
        LD    A,E             ;y
        CP    (HL)
        JR    NZ,GWMR.0
        INC   HL
        LD    A,(HL)          ;block
        INC   HL
        LD    H,(HL)          ;seg
        LD    L,0
        SRL   H     	    ;seglen=128, so shift 1 right
        RR    L
        RET
GWMR.0: ADD   HL,BC
        JP    GWMR.1


;store and set palette as current pal
SetMapPalette:
		push  hl
		ld    de,CurrentPalette
		ld    bc,32
		ldir
		pop   hl
		call setpalette
ret

;Get palette location
;in:	A=palId
;out:	HL=adr of 32byes palbuffer
getPalette:
		push bc
		LD	h,0
		ld	l,A
		add	hl,hl	;x2
		add	hl,hl	;4
		add hl,hl	;8
		add	hl,hl	;16
		add hl,hl	;32
		ld	bc,palettes.data
		add	hl,bc
		pop bc		
ret

palettes:
.reclen:		equ 32
.numrec:		equ 32
.data:
.0:				DS .reclen		;incBin filename,0,.reclen
.1:				DS .reclen
.2Lemniscate:	DB $06,$05,$12,$01,$32,$03,$34,$03,$20,$01,$21,$02,$07,$05,$73,$06,$05,$03,$77,$07,$53,$05,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.3:				DS .reclen
.4Pegu:		    DB $60,$05,$12,$01,$20,$05,$34,$03,$20,$01,$00,$03,$50,$03,$73,$06,$40,$02,$77,$07,$40,$06,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.5:				DS .reclen
.6KarniMata:	DB 71,5,18,1,32,5,52,3,32,1,0,3,80,3,115,6,0,2,119,7,64,6,35,2,69,4,112,5,112,2,0,0
.7Konark:		DB $77,$04,$12,$01,$42,$03,$34,$03,$20,$01,$31,$02,$61,$03,$73,$06,$41,$02,$77,$07,$53,$04,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.815:			DS .reclen*8
.1623:			DS .reclen*8
.2430:			DS .reclen*7
.31Teleport:	DB $00,$00,$12,$01,$50,$02,$34,$03,$20,$00,$30,$01,$00,$00,$73,$06,$00,$00,$77,$07,$70,$04,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00




;Get Ruin properties
;in:	A=ruinId
;out:	HL=adr
GetRuin:
push bc
		LD	h,0
		ld	l,A
		add	hl,hl	;x2
		add	hl,hl	;4
		add hl,hl	;8
		add	hl,hl	;16
		ld	bc,RuinPropertiesLUT.data
		add	hl,bc
		pop bc
ret

;RuinPropertiesLUT
RuinPropertiesLUT:
.reclen:		equ 16
.numrec:		equ 32
.data:
	DB 0,0,0,"             "
	DB 0,0,0,"Hub          "
	DB 2,0,0,"Lemniscate   "
	DB 0,0,0,"Bos Stenen Wa"
	DB 4,0,0,"Pegu         "
	DB 0,0,0,"Bio          "
	DB 6,6,3,"Karni Mata   "
	DB 0,0,0,"Konark       "
	DB 0,0,0,"Ashoka   hell"
	DB 0,0,0,"Taxilla      "
	DB 0,0,0,"Euderus Set  "
	DB 0,0,0,"Akna         "
	DB 0,0,0,"Fate         "
	DB 0,0,0,"Sepa         "
	DB 0,0,0,"undefined    "
	DB 0,0,0,"Chi          "
	DB 0,0,0,"Sui          "
	DB 0,0,0,"Grot         "
	DB 0,0,0,"Tiwanaku     "
	DB 0,0,0,"Aggayu       "
	DB 0,0,0,"Ka           "
	DB 0,0,0,"Genbu        "
	DB 0,0,0,"Fuu          "
	DB 0,0,0,"Indra        "
	DB 0,0,0,"Morana       "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "
	DB 0,0,0,"             "

ResetPushStones:
  ld    hl,PuzzleBlocks1Y+3             ;y stone 1
  ld    de,4
  ld    b,31
  xor   a
  .loop:
  ld    (hl),a
  add   hl,de
  djnz  .loop
  ret

PutSpatToVramSlow:
	ld		hl,(invisspratttableaddress)		;sprite attribute table in VRAM ($17600)
	ld		a,1
	call	SetVdp_Write	

	ld		hl,spatSlow			                ;sprite attribute table
  ld    c,$98
	call	outix128
  ret

spatSlow:						;sprite attribute table
	db		000,000,000,0	,000,000,004,0	,000,000,008,0	,000,000,012,0
	db		000,000,016,0	,000,000,020,0	,000,000,024,0	,000,000,028,0
	db		000,000,032,0	,000,000,036,0	,000,000,040,0	,000,000,044,0
	db		000,000,048,0	,000,000,052,0	,000,000,056,0	,000,000,060,0
	
	db		000,000,064,0	,000,000,068,0	,000,000,072,0	,000,000,076,0
	db		000,000,080,0	,000,000,084,0	,000,100,088,0	,000,100,092,0
	db		000,100,096,0	,000,100,100,0	,000,000,104,0	,000,000,108,0
	db		000,000,112,0	,000,000,116,0	,000,000,120,0	,000,000,124,0

bordermasksprite_graphics:
include "../sprites/bordermasksprite.tgs.gen"
bordermasksprite_color:
include "../sprites/bordermasksprite.tcs.gen"
bordermasksprite_color_withCEbit:
include "../sprites/bordermaskspriteECbit.tcs.gen"

initiatebordermaskingsprites:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    a,11                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    a,06                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:
  ld    (SetBorderMaskingSprites.selfmodifyingcodeAmountSpritesOneSide),a

	ld		c,$98                 ;out port
	ld		de,(sprchatableaddress)		      ;sprite character table in VRAM ($17800)
  call  bordermaskspritecharacter
	ld		de,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
  call  bordermaskspritecharacter
	ld		de,(sprcoltableaddress)		      ;sprite color table in VRAM ($17400)
  call  bordermaskspritecolor
	ld		de,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
  call  bordermaskspritecolor
  ret

  bordermaskspritecharacter:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    b,22                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    b,12                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:

  ;put border masking sprites character
  ld    hl,0 * 32             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write
  
  .loop:
  push  bc
  ld    hl,bordermasksprite_graphics
	call	outix32               ;1 sprites (1 * 32 = 32 bytes)
  pop   bc
  djnz  .loop
  ;/put border masking sprites character
  ret
  
  bordermaskspritecolor:
  ld    a,(SpriteSplitFlag)
  or    a
  ld    b,11                ;amount of border masking sprites left and right side of screen (without Border Masking Sprites Screensplit)
  jr    z,.Set
  ld    b,06                ;amount of border masking sprites left and right side of screen (with Border Masking Sprites Screensplit)
  .Set:
    
  ;put border masking sprites color
  ld    hl,0 * 16             ;border mask at sprite position 0
  add   hl,de
	ld		a,1
	call	SetVdp_Write

  .loop:                      ;alternate writing Color data between left and right sprites
  push  bc
  ld    hl,bordermasksprite_color_withCEbit
	call	outix16               ;1 sprites left side of screen (1 * 16 = 16 bytes)
  ld    hl,bordermasksprite_color
	call	outix16               ;1 sprites right side of screen (1 * 16 = 16 bytes)
  pop   bc
  djnz  .loop
  ;/put border masking sprites color
  ret

RemoveSpritesFromScreen:
  ld    hl,spat
  ld    de,2
  ld    b,32
  .loop:
  ld    (hl),217
  add   hl,de
  djnz  .loop
  ret

CopyVramObjectsPage1and3:
  ld    a,(VramGraphicsPage1And3AlreadyInScreen?)
  or    a
  ret   nz
  ld    a,1
  ld    (VramGraphicsPage1And3AlreadyInScreen?),a

  ;Copy level objects to page 1
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ld    a,Graphicsblock5          ;block to copy from
  call  block34
  
	xor   a
  ld    hl,$6C00+$8000            ;page 1 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
	call	SetVdp_Write	
	ld		hl,itemsKarniMata
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1     

  ;copy Huge Blob graphics and primary and secundary weapons to page 3
  ld    a,(slot.page12rom)        ;all RAM except page 12
  out   ($a8),a          

  ld    a,Graphicsblock4          ;block to copy from
  call  block34

	ld    a,1
  ld    hl,$6C00+$8000            ;page 3 - screen 5 - bottom 40 pixels (scoreboard) start at y = 216
	call	SetVdp_Write	

	ld		hl,itemsKarniMataPage3
  ld    c,$98
  ld    a,40/2                    ;copy 40 lines..
  ld    b,0
  jp    copyGraphicsToScreen.loop1   
  
copyScoreBoard:                       ;set scoreboard from page 2 rom to Vram
  ld    a,(ScoreBoardAlreadyInScreen?)
  or    a
  ret   nz
  ld    a,1
  ld    (ScoreBoardAlreadyInScreen?),a

  ld    hl,$6C00+128                      ;page 0 - screen 5 - bottom 40 pixels (scoreboard)
  ld    a,Graphicsblock5              ;block to copy from
  call  block34
  
	xor   a
	call	SetVdp_Write	
	ld		hl,scoreboard
  ld    c,$98
  ld    a,38/2                        ;copy 38 lines..
  ld    b,0
  call  copyGraphicsToScreen.loop1
  jp    outix128



;SetTilesInVram:  
;set tiles in Vram
;  ld    a,(ix+4)                      ;tile data
;  or    a
;  ld    d,VoodooWaspTilesBlock        ;0
;  jr    z,.settiles
;  dec   a
;  ld    d,GoddessTilesBlock           ;1
;  jr    z,.settiles
;  dec   a
;  ld    d,KonarkTilesBlock            ;2
;  jr    z,.settiles
;  dec   a
;  ld    d,KarniMataTilesBlock         ;3
;  jr    z,.settiles
;  dec   a
;  ld    d,BlueTempleTilesBlock        ;4
;  jr    z,.settiles
;  dec   a
;  ld    d,BurialTilesBlock            ;5
;  jr    z,.settiles
;  dec   a
;  ld    d,BossAreaTilesBlock          ;6
;  jr    z,.settiles
;  dec   a
;  ld    d,IceTempleTilesBlock         ;7
;  jr    z,.settiles

;  .settiles:
;  ld    a,(slot.page12rom)            ;all RAM except page 12
;  out   ($a8),a          

;  ld    hl,$8000                      ;page 1 - screen 5
;  ld    b,0
;  call  copyGraphicsToScreen2
;  ret

;copyGraphicsToScreen2:
;  ld    a,d                           ;Graphicsblock
;  call  block34
  
;	ld		a,b
;	call	SetVdp_Write	
;	ld		hl,$8000
;  ld    c,$98
;  ld    a,64                          ;first 128 line, copy 64*256 = $4000 bytes to Vram
      
;  call  .loop1    

;  ld    a,d                           ;Graphicsblock
;  inc   a
;  call  block34
  
;	ld		hl,$8000
;  ld    c,$98
;  ld    a,64 ; 42                     ;second 84 line, copy 64*256 = $4000 bytes to Vram
      
;  call  .loop1   
;  ret

;.loop1:
;  call  outix256
;  dec   a
;  jp    nz,.loop1
;  ret

;BorderMaskingSpritesCall:
;  call  SetBorderMaskingSprites       ;set border masking sprites position in Spat
;NoBorderMaskingSpritesCall:
;  nop | nop | nop                     ;skip border masking sprites
SetEngineType:                        ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
;Set Engine type
;  ld    hl,BorderMaskingSpritesCall
;  ld    de,LevelEngine.SelfModifyingCallBMS
;  ld    bc,3
;  ldir

  ld    a,1                           ;sprite split active
  ld    (SpriteSplitFlag),a           

  ld    a,(UnpackedRoomFile+roomDataBlock.mapid)  ;tttrrrrr (t=type,r=ruin)
  rlca
  rlca
  rlca
  and   7
  call  getroomtype
  inc   hl		;skip width
  inc   hl		;skip heigth
  ld    a,(hl)
  ld    (scrollEngine),a              ;1= 304x216 engine, 2=256x216 SF2 engine, 3=256x216 SF2 engine sprite split ON 
  dec   a
  jp    z,.Engine304x216

  .Engine256x216:                     ;SF2 engine
;;;;;;;;;;;;;;;; ################ in the SF2 engine we can choose to have spritesplit active, which gives us 14 extra sprites  
  dec   a                             ;1= 304x216 engine, 2=256x216 SF2 engine, 3=256x216 SF2 engine sprite split ON 
  ld    a,1                           ;sprite split active
  jr    nz,.SetSpriteSplit
  xor   a                             ;sprite split inactive
  .SetSpriteSplit:
  ld    (SpriteSplitFlag),a           

;  ld    hl,NoBorderMaskingSpritesCall
;  ld    de,LevelEngine.SelfModifyingCallBMS
;  ld    bc,3
;  ldir

  .Engine256x216WithSpriteSplit:
  ld    de,CheckTile256x216MapLenght
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,ExitRight256x216
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
  ld    a,MapLenght256x216
  ld    (ConvertToMapinRam.SelfModifyingCodeMapLenght+1),a
  ld    de,MapData- 68
  ld    (checktile.selfmodifyingcodeStartingPosMapForCheckTile+1),de
 
;check if player enters on the left side of the screen or on the right side. On the left camerax = 0, on the right camerax=15
  ld    hl,256/2
  ld    de,(ClesX)
  sbc   hl,de
  ld    a,15
  jr    c,.setCameraX
  xor   a
  .setCameraX:
  ld    (CameraX),a

  ;if engine type = 256x216 and x Cles = 34*8, then move cles 6 tiles to the left, because this Engine type has a screen width of 6 tiles less
  ld    hl,(ClesX)
  ld    de,ExitRight304x216
  xor   a
  sbc   hl,de
  ret   nz
  ld    hl,252 ;28*8
  ld    (ClesX),hl
  ret

  .Engine304x216:                        ;
  ld    de,CheckTile304x216MapLenght
  ld    (checktile.selfmodifyingcodeMapLenght+1),de
  ld    de,ExitRight304x216
  ld    (checkmapexit.selfmodifyingcodeMapexitRight+1),de
  ld    a,MapLenght304x216
  ld    (ConvertToMapinRam.SelfModifyingCodeMapLenght+1),a
  ld    de,MapData- 80
  ld    (checktile.selfmodifyingcodeStartingPosMapForCheckTile+1),de
  ret
  
ReSetVariables:
  ;set player sprites to spritenumber 28 for char and color address
  ld    a,$7b ;-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddress),a
  ld    a,$75 ;-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddress),a
  ld    a,$73 ;-2
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerCharAddressMirror),a
  ld    a,$6d ;-1
  ld    (SwapSpatColAndCharTable2.DoubleSelfmodifyingCodePlayerColAddressMirror),a
  ;set player sprites to spritenumber 28 for spatposition
  ld    hl,spat+(28 * 2)
  ld    (Apply32bitShift.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerLeftSideOfScreen.SelfmodyfyingSpataddressPlayer),hl          
  ld    (PlayerRightSideOfScreen.SelfmodyfyingSpataddressPlayer),hl          
  
  ld    a,StartingJumpSpeedEqu        ;reset Starting Jump Speed
  ld    (StartingJumpSpeed),a
  inc   a
  ld    (StartingJumpSpeedWhenHit),a
  
  ld    hl,.NormalRunningTable        ;Reset Normal Running Table
  ld    de,RunningTable1
  ld    bc,RunningTableLenght
  ldir

  ld    a,0*32+31
  ld    (PageOnNextVblank),a

  xor   a                              ;restore variables to put SF2 objects in play
  ld    (PutObjectInPage3?),a

  ld    (CleanOb1-1),a
  ld    (CleanOb2-1),a
  ld    (CleanOb3-1),a
  ld    (CleanOb4-1),a
  ld    (CleanOb5-1),a
  ld    (CleanOb6-1),a
  ld    (CleanPlayerProjectile-1),a
  ld    (CleanPlayerWeapon-1),a

  ld    a,1
  ld    (RestoreBackgroundSF2Object?),a

  ld    a,-1
  ld    (HugeObjectFrame),a           ;Reset this value by setting it to -1
  xor   a
  ld    (ShakeScreen?),a
  ld    (PlayerDead?),a
  ld    (SecundaryWeaponActive?),a              ;remove arrow weapon  

  ld    hl,lineint
  ld    (InterruptHandler.SelfmodyfyingLineIntRoutine),hl

  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  ret   z                              ;wait for previous primary attack to end
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a   
  ld    hl,0
  ld    (PlayerAnicount),hl     
  ret
  
.NormalRunningTable:
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
;  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
;  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
;  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1
  
ruinProperties:
.reclen:		equ 16		;[attribute]The length of one record
.numrec:		equ 32		;[attribute]Number of records
.tileset:		equ +0		;[property]Default Tileset ID
.palette:		equ +1		;[property]Default palette ID
.music:			equ +2		;[property]Default music ID
.Name:			equ +3		;[property]Name of the ruin as string
.data:						;RM:table generated externally
	DB	0,0,0,"             "
	DB	0,0,0,"Hub          "
	DB	0,0,0,"Lemniscate   "
	DB	0,0,0,"Bos Stenen Wa"
	DB	0,0,0,"Pegu         "
	DB	0,0,0,"Bio          "
	DB	6,6,3,"Karni Mata   "
	DB	0,0,0,"Konark       "
	DB	0,0,0,"Verhakselaar "
	DB	0,0,0,"Taxilla      "
	DB	0,0,0,"Euderus Set  "
	DB	0,0,0,"Akna         "
	DB	0,0,0,"Fate         "
	DB	0,0,0,"Sepa         "
	DB	0,0,0,"undefined    "
	DB	0,0,0,"Chi          "
	DB	0,0,0,"Sui          "
	DB	0,0,0,"Grot         "
	DB	0,0,0,"Tiwanaku     "
	DB	0,0,0,"Aggayu       "
	DB	0,0,0,"Ka           "
	DB	0,0,0,"Genbu        "
	DB	0,0,0,"Fuu          "
	DB	0,0,0,"Indra        "
	DB	0,0,0,"Morana       "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "
	DB	0,0,0,"             "

	dephase