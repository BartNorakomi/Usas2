phase	loaderAddress	;20240525;ro;moved from usas2.asm to this file



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
;db 8,100,100,0    ;Boss Demon, x,y

;db 13,0   ;boss plant
;db 14,16*8/2,19*8,   2*8, 6*8,  20*8/2,19*8   ;breakable wall (sx,sy,nx,ny,sx repair, sy repair)
;db    0

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

  pop   ix		;<DE
;  ld    ix,UnpackedRoomFile.tiledata+38*27*2  ;room object data list
;  ld    ix,UnpackedRoomFile.tiledata+32*27*2  ;room object data list
  ld    iy,enemies_and_objects          ;start object table in iy

.loop:
		ld    a,(ix)			;UID
		or    a
		ret   z					;0=end room object list

		call  .SetObject
		add   ix,de                           ;add the lenght of current object data to ix, and set next object in ix
		ld    de,lenghtenemytable             ;lenght 1 object in object table
		add   iy,de                           ;next object in object table
		jp    .loop                           ;go handle next object
  
.SetObject:
  cp    roomObject.PushStone
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
  cp    8
  jp    z,.Object008                    ;boss demon (BossDemon)
  cp    10
  jp    z,.Object010                    ;huge block (HugeBlock)
  cp    11
  jp    z,.Object011                    ;small moving platform on (standard dark grey)
  cp    12
  jp    z,.Object012                    ;small moving platform (lighter version)
  cp    13
  jp    z,.Object013                    ;boss plant (BossPlant)
  cp    14
  jp    z,.Object014                    ;breakable wall (BreakableWall)
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
  cp    143
  jp    z,.Object143                    ;retarded zombie
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

;copy template [HL] properties to objectRec [IY]
.copyObjectTemplate:
		push  iy
		pop   de
		ld    bc,lenghtenemytable
		ldir
		ret
		
.SetObjectBelongingToHardwareSprite:
		ld		de,lenghtenemytable	;next record
		add		iy,de
  		call	.copyObjectTemplate
		jp		SetCleanObjectNumber            ;each object has a reference cleanup table

.SetHandlerObject:                    ;this object does not put an image in screen, just handles something
		ld		de,lenghtenemytable	;next record
		add		iy,de
  		call	.copyObjectTemplate
		ret

;ro:  generically apply a class
;using IX as source, but I'd recommend using HL or DE

;out: DE=numbBytes, HL=objectX, A=objectY
.applyObjectClassMovingPlatform:
		ld		a,(ix+roomObjectClass.MovingPlatform.Active)
		ld		(iy+enemies_and_objects.v2),a

		ld		a,(ix+roomObjectClass.MovingPlatform.Speed)
		ld		(iy+enemies_and_objects.v10),a  ;speed (in frames)

		ld		a,(ix+roomObjectClass.MovingPlatform.Face)
		ld		b,1	;step is always one (is it?)
		call	.getfacing
		ld		(iy+enemies_and_objects.v3),C	;vMove
		ld		(iy+enemies_and_objects.v4),b	;hMove

		ld		a,(ix+roomObjectClass.MovingPlatform.Y)
		ld		(iy+enemies_and_objects.v8),a   ;boxY
		add		a,(ix+roomObjectClass.MovingPlatform.Height)
		sub		a,(iy+enemies_and_objects.ny)
		ld		(iy+enemies_and_objects.v9),a   ;boxY'

		ld		l,(ix+roomObjectClass.MovingPlatform.X)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.v6),l   ;boxX
		ld		(iy+enemies_and_objects.v7),h
		ex		de,hl
		ld		a,(ix+roomObjectClass.MovingPlatform.width)
		add		a,a
		sub		a,(iy+enemies_and_objects.nx)
		ld		h,0
		ld		l,a
		add		hl,de
; 		call  .CheckIfObjectMovementIsWithinAllowedRange
		ld		(iy+enemies_and_objects.v1-2),l ;boxX'
		ld		(iy+enemies_and_objects.v1-1),h
		ld		l,(ix+roomObjectClass.MovingPlatform.xstart)
		ld		h,0
		add		hl,hl
		add		hl,de
		ld		(iy+enemies_and_objects.x),l	;platformX
		ld		(iy+enemies_and_objects.x+1),h
		ld		a,(ix+roomObjectClass.MovingPlatform.Y)
		add		a,(ix+roomObjectClass.MovingPlatform.Ystart)
		ld		(iy+enemies_and_objects.y),a	;platformY
		ld		de,roomObjectClass.MovingPlatform.numBytes
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

;out: DE=numbBytes, HL=objectX, A=objectY
.applyObjectClassBreakableWall:
		ld		a,(ix+roomObjectClass.BreakableWall.Width)
		add		a,a
		ld		(iy+enemies_and_objects.nx),a
		ld		a,(ix+roomObjectClass.BreakableWall.height)
		ld		(iy+enemies_and_objects.ny),a
		ld		l,(ix+roomObjectClass.BreakableWall.Xrestore)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.v1),l		;!! 8bit
		ld		a,(ix+roomObjectClass.BreakableWall.Yrestore)
		ld		(iy+enemies_and_objects.v2),a

		ld		l,(ix+roomObjectClass.BreakableWall.X)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		ld		a,(ix+roomObjectClass.BreakableWall.Y)
		ld		(iy+enemies_and_objects.y),a
		ld		de,roomObjectClass.BreakableWall.numBytes
		ret

;out: DE=numbBytes, HL=objectX, A=objectY
.applyObjectClassGeneral:
		ld		l,(ix+roomObjectClass.General.X)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		ld		a,(ix+roomObjectClass.General.Y)
		ld		(iy+enemies_and_objects.y),a
		ld		de,roomObjectClass.General.numBytes
		ret

;!! ro;wip
;out: DE=numbBytes, HL=objectX, A=objectY, B=maxSpawn
.applyObjectClassEnemySpawn:
		ld		b,(ix+roomObjectClass.EnemySpawn.spawnSpeed)
		ld		(iy+enemies_and_objects.spawnSpeed),b
		ld		b,(ix+roomObjectClass.EnemySpawn.Speed)	;spawned offspring move speed (default 1)
		ld		a,(ix+roomObjectClass.EnemySpawn.Face)
		call	.getfacing
		ld		(iy+enemies_and_objects.v4),b
		ld		b,(ix+roomObjectClass.EnemySpawn.MaxNum)
		ld		(iy+enemies_and_objects.spawnMax),b
		ld		l,(ix+roomObjectClass.EnemySpawn.X)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		ld		a,(ix+roomObjectClass.EnemySpawn.Y)
		ld		(iy+enemies_and_objects.y),a

		ld		de,roomObjectClass.EnemySpawn.numBytes
		ret

;out: DE=numbBytes, HL=objectX, A=objectY
;v3=vdir,v4=hdir
.applyObjectClassEnemy:
		ld		b,(ix+roomObjectClass.Enemy.Speed)
		ld		a,(ix+roomObjectClass.Enemy.Face)
		call	.getfacing
		ld		(iy+enemies_and_objects.v3),C
		ld		(iy+enemies_and_objects.v4),b
		ld		l,(ix+roomObjectClass.Enemy.X)
		ld		h,0
		add		hl,hl
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		ld		a,(ix+roomObjectClass.Enemy.Y)
		ld		(iy+enemies_and_objects.y),a

		ld		de,roomObjectClass.Enemy.numBytes
		ret

;1=-y,x		| 0 n
;2=-y,+x	/ 1 ne
;3=y,+x		- 2 e
;4=+y,+x	\ 3 es
;5=+y,x		| 4 s
;6=+y,-x	/ 5 sw
;7=y,-x		- 6 w
;8=-y,-x	\ 7 we
.getFacing:	;ro: it's not the most beautiful code, but it gets the job done. Bart-style :)
		ld		c,b
		and		A
		call	z,.random
		cp		2
		jr		c,.nor
		jr		z,.ne
		cp		4
		jr		c,.eas
		jr		z,.es
		cp		6
		jr		c,.sou
		jr		z,.sw
		cp		8
		jr		c,.wes
		jr		z,.we
		ld		bc,0
		ret
.random:	ld		a,R
		and		7
		inc		A
		ret
.nor:	ld		a,C
		neg
		ld		c,A
		ld		b,0
		ret
.ne:	ld		a,C
		neg
		ld		c,A
		ret
.eas:	ld		c,0
		ret
.es:	ret
.sou:	ld		b,0
		ret
.sw:	ld		a,c
		neg	
		ld		b,A
		ret
.wes:	ld		c,0
		ld		a,b
		neg
		ld		b,A
		ret
.we:	ld		a,C
		neg	
		ld		b,A
		ld		c,A
		ret		



;If this is a sprite, do stuff.
;in:	IY=objectRec
;alt:	A, HL, BC
.applyObjectSpriteProperties:
		ld		a,(iy+enemies_and_objects.sprite?)
		and		a
		ret		z
		call	SetSPATPositionForThisSprite
		ld		l,(iy+enemies_and_objects.x)
		ld		h,(iy+enemies_and_objects.x+1)
		ld		bc,16
		add		hl,bc
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		ret


;001-PushStone
;v1=sx
;v2=falling stone?
;v3=y movement
;v4=x movement
;v7=set/store coord
;v9=special width for Pushing Stone Puzzle Switch
;v1-2= coordinates in pushing stone table (PuzzleBlocks1Y, PuzzleBlocks2Y etc)
.Object001:
		call	.newObjectRecord
		ld		hl,pushStonetable.data+pushStoneTable.roomY	;table record #0
		Call	.CheckBlock
		ld		de,roomObjectClass.General.numBytes
		ret

;check if this block is already present in the pushing block table
;find the first record with the correct roomNumber and store all blocks from this room in sequencial order
.CheckBlock:
		ld		de,PushStoneTable.reclen			;4
.checkblockL0:
		ld		a,(hl)	;.roomY
		cp		-1  		;free or oed
		jr		z,.NotYetPresent
		ld		a,(WorldMapPosition.y)
		cp		(hl)
		jr		nz,.ThisBlockBelongsInADifferentRoom
		dec		hl
		ld		b,(hl)
		inc		hl
		ld		a,(WorldMapPosition.X)
		cp		b
		jp		z,.isPresent
.ThisBlockBelongsInADifferentRoom:
		add		hl,de								;next block in pushing block table
		jp		.CheckBlockL0

;when a block is already in the table, set table coordinates in v1-2 and take x,y from table and feed it into the object
;!! ro: coordinates are NOT set in v1/v2 atm.
.isPresent:                   
		dec		hl
		dec		hl
		dec		hl
		ld		(iy+enemies_and_objects.tableRecordPointer),l ;store pointer to tableRecord
		ld		(iy+enemies_and_objects.tableRecordPointer+1),h

		ld		a,(ix+roomObjectClass.General.numBytes)	;check if next object is another pushing stone
		cp		roomObject.PushStone
		ret		nz

		ld		de,roomObjectClass.General.numBytes	;goto next roomObject and skip ID
		add		ix,de
		ld		de,lenghtenemytable					;goto next objectRecord
		add		iy,de
		call	.newObjectRecord
    
		ld		de,PushStoneTable.reclen				;next tableRecord +4
		add		hl,de
		jr		.isPresent						;look for more pushing stones in this room

.NotYetPresent:
		push	hl
		call	.applyObjectClassGeneral
		pop		hl
		call	.newPushStoneRecord 

		ld		a,(ix+roomObjectClass.General.numBytes)	;check if next object is another pushing stone
		cp		roomObject.PushStone
		ret		nz

		ld		de,roomObjectClass.General.numBytes	;goto next roomObject and skip ID
		add		ix,de
		ld		de,lenghtenemytable					;goto next objectRecord
		add		iy,de
		call	.newObjectRecord

		ld		de,pushStoneTable.reclen+pushStoneTable.roomy   ;7	;next record, and move to .roomY
		add		hl,de                           ;room y for next block in pushing block table
		jr		.NotYetPresent                  ;now loop this routine and look for more pushing stones in this room

.newPushStoneRecord:
		ld		a,(WorldMapPosition.Y)	;.roomY
		ld		(hl),a
		dec		hl
		ld		a,(WorldMapPosition.X)	;.roomX
		ld		(hl),a
		dec		hl
		ld		a,(iy+enemies_and_objects.x)	;transfer stone coordinates to current tableRecord *8bit
		ld		(hl),A
		dec		hl
		ld		a,(iy+enemies_and_objects.y)
		ld		(hl),A

		ld		(iy+enemies_and_objects.tableRecordPointer),l ;store pointer to tableRecord
		ld		(iy+enemies_and_objects.tableRecordPointer+1),h
		ret

.newObjectRecord:
		push	hl
		ld		hl,Object001Table
		call	.copyObjectTemplate
		call	SetCleanObjectNumber
		ld		hl,AmountOfPushingStonesInCurrentRoom
		inc		(hl)
		pop		hl
		ret


;waterfall grey statue (WaterfallEyesGrey)
.Object003:                           
		ld    hl,Object003Table.eyes
		jr    .EntryForObject003

;waterfall yellow statue (WaterfallEyesYellow)
;v1=sx
;v2=Active Timer
;v3=wait timer in case only 1 waterfall
;v4=Waterfall nr
.Object002:                           
		ld    hl,Object002Table.eyes
.EntryForObject003:
		call	.object002AddEyes
		push	de
		call	.object002AddMouth
		call	.object002AddWaterfall
		pop		de
		ret
	
.object002AddEyes:
		call	.copyObjectTemplate
		call	SetCleanObjectNumber

		call	.applyObjectClassGeneral			;transfer class properties, ;out: DE=numbBytes, HL=objectX, A=objectY
		add		a,3
		ld		(iy+enemies_and_objects.y),a

		ld		a,(AmountOfWaterfallsInCurrentRoom)
		inc		a
		ld		(AmountOfWaterfallsInCurrentRoom),a
		ld		(iy+enemies_and_objects.v4),a   ;v4=Waterfall nr
		dec		a
		ret		z
		exx     ;a 2nd or 3d waterfall uses the same sprite position as the 1st, sprite size=8, so decrease b with 8
		ld		a,b
		sub		a,8
		ld		b,a
		exx
		ret  

.object002AddMouth:
		ld		bc,lenghtenemytable             ;next objectRecord
		add		iy,bc
		ld		hl,Object002Table.mouth
		push	iy
		pop		de 
		ldir
		call	SetCleanObjectNumber
		ret

.object002AddWaterfall:                     ;we also need to set a waterfall hardware sprite
		ld		bc,lenghtenemytable             ;next objecgt record
		add		iy,bc                          ;next object in object table
		ld		hl,Object002Table.water         ;we also need to set a waterfall hardware sprite
		push	iy
		pop		de
		ldir
		call	SetSPATPositionForThisSprite
		ret


;004-PoisonDrop
;v1=sx
;v2=Phase (0=growing, 1=falling, 2=waiting for respawn)
;v3=Vertical Movement
;v4=Grow Duration
;v5=Wait FOr Respawn Counter
;v8=Y spawn
;v9=X spawn
.Object004:
;initialize object
		ld		hl,Object004Table				;copy template
		push	iy
		pop		de
		ld		bc,lenghtenemytable
		ldir
		call	SetCleanObjectNumber
;copy class properties
		ld		a,(ix+roomObjectClass.General.X)	;should be a 16b adr
		add		a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
		add		a,3
		ld		(iy+enemies_and_objects.v9),a   ;v9=X spawn
		ld		a,(ix+roomObjectClass.General.Y)
		add		a,03                            ;32 pix down
		ld		(iy+enemies_and_objects.v8),a   ;v8=Y spawn

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
;Also set a splashing hardware sprite, when drop hits the ooze pool
		ld		de,lenghtenemytable             ;next object
		add		iy,de
		ld		hl,Object004Table.Splash		;copy template
		push	iy
		pop		de
		ld		bc,lenghtenemytable
		ldir
		call	SetSPATPositionForThisSprite    ;define the position this sprite takes in the SPAT

		ld		de,roomObjectClass.general.numBytes
		ret


;005-AreaSign
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=put line in all 3 pages
;v7=sprite frame
;v8=Phase (0=put a new line for 3 frames, 1=wait, 2=remote all the lines in all the pages)
;v9=wait timer / bottom of area sign
.Object005:
		ld		a,(PreviousRuin)		;Only apply if this is another ruin
		ld		b,a
		call	GetRoomRuinId
		cp		b
		call	nz,.initAreaSignObject
		ld		de,roomObjectClass.general.numBytes
		ret

.initAreaSignObject:
		call	UnpackAreaSign
		ld		hl,Object005Table
		call	.copyObjectTemplate
		call	.applyObjectClassGeneral

		xor   a		;start writing at (0,0) page 1 
		ld    hl,$8000
		call	SetVdp_Write	

		ld    hl,$8000	;RAM source
		ld    c,$98	;out port
		ld    d,24
.Outiloop:
		call  outix256
		dec   d
		jp    nz,.Outiloop

		ld    a,(slot.page12rom)            ;RAMROMROMRAM
		out   ($a8),a

;now copy (transparant) area sign from page 1 to page 3 at it's coordinates
		ld    a,$98
		ld    (FreeToUseFastCopy+copytype),a
		xor   a
		ld    (FreeToUseFastCopy+sx),a
		ld    (FreeToUseFastCopy+sy),a
		ld    a,1
		ld    (FreeToUseFastCopy+sPage),a
		ld    a,3
		ld    (FreeToUseFastCopy+dPage),a  
		ld    a,(iy+enemies_and_objects.x)
		ld    (FreeToUseFastCopy+dx),a
		ld    a,(iy+enemies_and_objects.y)
		ld    (FreeToUseFastCopy+dy),a
		ld    a,200
		ld    (FreeToUseFastCopy+nx),a
		ld    a,48
		ld    (FreeToUseFastCopy+ny),a
		ld    hl,FreeToUseFastCopy
		call  DoCopy
		ld    a,$d0
		ld    (FreeToUseFastCopy+copytype),a

		ret   
  

;006-TeleportVortex
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
.Object006:
		ld		hl,Object006Table
		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		ret    


;waterfall scene (WaterfallScene) @karnimata
.Object007:                           
		ld		hl,Object007Table
		call	.copyObjectTemplate
		; call	.applyObjectClassGeneral

;put waterfall backdrop in all 4 pages
		ld    a,0
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$0000 + (040*128) + (032/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (128*256) + (192/2)        ;(ny*256) + (nx/2)
		ld    a,WaterfallSceneBlock1              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,0
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$8000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (040*128) + (032/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (128*256) + (192/2)        ;(ny*256) + (nx/2)
		ld    a,WaterfallSceneBlock1              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$0000 + (040*128) + (032/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (128*256) + (192/2)        ;(ny*256) + (nx/2)
		ld    a,WaterfallSceneBlock2              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$8000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (040*128) + (032/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (128*256) + (192/2)        ;(ny*256) + (nx/2)
		ld    a,WaterfallSceneBlock2              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    de,roomObjectclass.General.numBytes
		ret   

 

;008-FireDemonBoss
.Object008:                           ;boss demon (BossDemon)
		ld    hl,Object008Table
		push  iy
		pop   de                              ;enemy object table
		ld    bc,lenghtenemytable*4           ;4 object(s)
		ldir

;put lava animation backdrop in all 4 pages
		ld    a,0
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$0000 + (168*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (040*256) + (240/2)        ;(ny*256) + (nx/2)
		ld    a,KonarkLavaSceneBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,0
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (040*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (168*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (040*256) + (240/2)        ;(ny*256) + (nx/2)
		ld    a,KonarkLavaSceneBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (080*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$0000 + (168*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (040*256) + (240/2)        ;(ny*256) + (nx/2)
		ld    a,KonarkLavaSceneBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (120*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (168*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (040*256) + (240/2)        ;(ny*256) + (nx/2)
		ld    a,KonarkLavaSceneBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

		ld    de,roomObjectclass.General.numBytes
		ret   


;huge block (HugeBlock)
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
.HeightHugeBlock:   equ 48
.WidthHugeBlock:    equ 48
.Object010:
		call  .SetHugeBlock
;if spritesplit enabled, we split our block in 2 and put top and bottom as separate objects
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
		ld		hl,Object010Table
		call	.copyObjectTemplate
		call	.applyObjectClassMovingPlatform

		ld		a,(AmountOfSF2ObjectsCurrentRoom)
		ld		(iy+enemies_and_objects.v2),a   ;v2=framenumber to handle this object on
		inc		a
		ld		(AmountOfSF2ObjectsCurrentRoom),a
		ret

  
;011-PlatformMovingSmall
.Object011:
		ld		hl,Object011Table
		call	.copyObjectTemplate
		call	SetCleanObjectNumber            ;each object has a reference cleanup table
		call	.applyObjectClassMovingPlatform
		ld		(iy+enemies_and_objects.v2),1		;activate
		ret


;012-PlatformMovingSmallSwitch
.Object012:
		ld		hl,Object012Table
		call	.copyObjectTemplate
		call	SetCleanObjectNumber            ;each object has a reference cleanup table
		call	.applyObjectClassMovingPlatform
		ld		a,(iy+enemies_and_objects.v2)	;active?
		or		a
		ret		z
		ld		(iy+enemies_and_objects.v1),Object012Table.sxOn ;v1=sx software sprite in Vram on
		ret


;057-PlatformMovingMedium
.Object057:
		ld		hl,Object057Table
		call	.copyObjectTemplate
		call	SetCleanObjectNumber            ;each object has a reference cleanup table
		call	.applyObjectClassMovingPlatform
		ret


;015-PlatformRetracting 
  ;retracting platform has 3 different situations:
  ;1=only 1 retracting platform in total: animation will be platform1 on, platform1 off
  ;2=only 2 retracting platforms in total: animation will be platform1 on, platform2 on, platform1 off, platform2 off
  ;3=3 or more retracting platforms in total: animation will be platform1 on, platform3 off, platform2 on, platform1 off, platform3 on, platform2 off (this concept can then be used for more than 3)
.Object015:
		ld    hl,Object015Table
		push  iy
		pop   de                              ;enemy object table
		ld    bc,lenghtenemytable*2
		ldir

;first let's find total amount of retracting platforms
		ld    de,roomObjectClass.General.numBytes	;Object015Table.lenghtobjectdata
		ld		a,roomObject.PlatformRetracting
		call	.countEqualObjects
		ld		a,b
		;!! ro: what happens is the max of 7 is reached? there should be a check
		ld		(AmountOfAppearingBlocks),a
		dec		a                               ;only 1 platform ?
		jp		z,.Only1RetractingPlatform ;only 1 platform uses the same placement routin as more than 2
		dec		a                               ;only 2 platforms ?
		jp		z,.Only2RetractingPlatforms

.MoreThan2RetractingPlatforms:  
		push  iy
		ld    iy,AppearingBlocksTable
		push  iy
.PlatformLoop:
		ld    a,(ix+roomObjectClass.General.Y)	;(ix+Object015Table.y)
		ld    l,a
		ld    (iy+0),a                        ;y block 1 (block turns on)
		ld    (iy+9),a                        ;y block 1 (block turns off)
		ld    a,(ix+roomObjectClass.General.X)	;(ix+Object015Table.x)
		add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
		ld    h,a
		ld    (iy+1),a                        ;x block 1 (block turns on)
		ld    (iy+2),1                        ;block 1 on
		ld    (iy+10),a                       ;x block 1 (block turns off)
		ld    (iy+11),0                       ;block 1 off

		ld    de,AppearingBlocksTable.reclen	;next record
		add   iy,de
		ld    de,roomObjectClass.General.numBytes	;Object015Table.lenghtobjectdata	;next object
		add   ix,de
		djnz  .PlatformLoop
		ld    (iy+0),255                      ;end list

		pop   iy  
		ld    (iy+3),l                        ;y last block (block turns on)
		ld    (iy+4),h                        ;x last block (block turns on)
		ld    (iy+5),0                        ;off
		pop   iy
  
		;ld    de,Object015Table.lenghtobjectdata
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

		ld    a,(ix+roomObjectClass.General.Y)	;(ix+Object015Table.y)
		ld    (AppearingBlocksTable+0),a
		ld    (AppearingBlocksTable+6),a
		ld    a,(ix+roomObjectClass.General.X)	;(ix+Object015Table.x)
		add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
		ld    (AppearingBlocksTable+1),a
		ld    (AppearingBlocksTable+7),a

		ld    de,roomObjectClass.General.numBytes	;Object015Table.lenghtobjectdata
		add   ix,de                           ;next retracting platform

		ld    a,(ix+roomObjectClass.General.Y)	;(ix+Object015Table.y)
		ld    (AppearingBlocksTable+3),a
		ld    (AppearingBlocksTable+9),a
		ld    a,(ix+roomObjectClass.General.X)	;(ix+Object015Table.x)
		add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
		ld    (AppearingBlocksTable+4),a
		ld    (AppearingBlocksTable+10),a

		;ld    de,Object015Table.lenghtobjectdata
		ret

.Only1RetractingPlatform:
		ld    a,1
		ld    (AppearingBlocksTable+2),a
		xor   a
		ld    (AppearingBlocksTable+5),a
		ld    a,255		;eod
		ld    (AppearingBlocksTable+6),a

		ld    a,(ix+roomObjectClass.General.Y)	;(ix+Object015Table.y)
		ld    (AppearingBlocksTable+0),a
		ld    (AppearingBlocksTable+3),a
		ld    a,(ix+roomObjectClass.General.X)	;(ix+Object015Table.x)
		add   a,a                             ;*2 (all x values are halved, so *2 for their absolute values)
		ld    (AppearingBlocksTable+1),a
		ld    (AppearingBlocksTable+4),a

		ld    de,roomObjectClass.General.numBytes	;Object015Table.lenghtobjectdata
		ret

;Find number of sequencial equal objects
;in:	A=objectNr, DE=recordLength
;out:	B=amount
.countEqualObjects:
		push	ix
		ld		b,0
		call	.ceoL0
		pop		ix
		ret
.ceoL0:	cp		(ix)
		ret		nz
		add		ix,de
		inc		B
		jr		.ceoL0


;016-PlatformMovingSmallOmnidirectional
.Object016:
		ld		hl,Object016Table
		call	.copyObjectTemplate
		call	SetCleanObjectNumber            ;each object has a reference cleanup table
		call	.applyObjectClassGeneral
		call	.loadObject016
		ret

;write omni directional platforms to (216+16,0) page 1
.loadObject016:
		ld		a,(ObjectPresentInVramPage1)
		cp		1
		ret		z
		Push	de
		xor		a
		ld		(PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld		hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld		de,$8000 + ((216+016)*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld		bc,$0000 + (016*256) + (128/2)        ;(ny*256) + (nx/2)
		ld		a,GfxObjectsForVramBlock              ;block to copy graphics from
		call	CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY
		ld		a,1
		ld		(ObjectPresentInVramPage1),a    ;1=omni directional platform
		pop		de
		ret


;013-bossPlant
.Object013: 
		ld		hl,Object013Table
		call	.copyObjectTemplate
		; call	.applyObjectClassGeneral
		call	.object013CopyBackDrop
		ld		de,roomObjectClass.General.numBytes
		ret

;put boss plant backdrop in all 4 pages
.object013CopyBackDrop:
	ld    a,0
	ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
	ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
	ld    de,$0000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
	ld    bc,$0000 + (212*256) + (256/2)        ;(ny*256) + (nx/2)
	ld    a,BossPlantBackdropBlock              ;block to copy graphics from
	call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

	ld    hl,.Page0ToPage1CopyTable
	call  DoCopy

	ld    a,1
	ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
	ld    hl,$4000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
	ld    de,$0000 + (000*128) + (000/2) - 128  ;(y*128) + (x/2)
	ld    bc,$0000 + (212*256) + (256/2)        ;(ny*256) + (nx/2)
	ld    a,BossPlantBackdropBlock              ;block to copy graphics from
	call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY

	ld    hl,.Page0ToPage3CopyTable
	call  DoCopy
	ld    hl,TinyCopyWhichFunctionsAsWaitVDPReady
	call  DoCopy
	ret  

.Page0ToPage1CopyTable:
	db    000,000,000,000   ;sx,--,sy,spage
	db    000,000,000,001   ;dx,--,dy,dpage
	db    000,001,212,000   ;nx,--,ny,--
	db    000,000,$E0       ;fast copy HMMM > ro: changed to YMMM, which is faster
.Page0ToPage3CopyTable:
	db    000,000,000,000   ;sx,--,sy,spage
	db    000,000,000,003   ;dx,--,dy,dpage
	db    000,001,212,000   ;nx,--,ny,--
	db    000,000,$E0       ;fast copy YMMM


;014-BreakableWall
.Object014:
		ld		hl,Object014Table
		call	.copyObjectTemplate
		call	.applyObjectClassBreakableWall
		push	de
		call	.CheckWallLeftEdge              ;check if wall is at left edge of screen AND player enters IN the wall. If so, remove wall from roomtiles
		call	.CheckWallRightEdge             ;check if wall is at right edge of screen AND player enters IN the wall. If so, remove wall from roomtiles
		pop		de
		ret  

;check if wall is at left edge of screen AND player enters IN the wall. If so, remove wall from roomtiles
.CheckWallLeftEdge: 
		ld    a,(iy+enemies_and_objects.x)
		or    (iy+enemies_and_objects.x+1)
		ret   nz

		ld    hl,(clesX)
		ld    de,16
		sbc   hl,de
		ret   nc

.remove:push  ix
		push  iy
		pop   ix
		call  removeObjectFromRoomMapData	;RemoveWallFromRoomTiles
		set   0,(iy+enemies_and_objects.v8)       ;v8=Phase (0=idle, 1=wall bashed)
		set   0,(iy+enemies_and_objects.v3)       ;v3=entered room inside a wall ?
		pop   ix
		ret

;check if wall is at right edge of screen AND player enters IN the wall. If so, remove wall from roomtiles
.CheckWallRightEdge:
	;ro:this is gonna be shitty - but gets the job done
;	ld	a,(checktile.selfmodifyingcodeMapLenght+1)
;	sub 2
		ld	 a,(roomMap.width)
		ld	 l,A
		ld	 h,0
		add	 hl,hl	;x2
		add	 hl,hl	;x4
		add	 hl,hl	;x8
		ld	 de,16
		sbc  hl,de 	;cy=0 since sub2 is > 0
		ex	 de,hl

		ld    hl,(clesX)
		sbc   hl,de
		ret   c

		ld	 l,(iy+enemies_and_objects.x)
		ld	 h,(iy+enemies_and_objects.x+1)
		ld	 c,(iy+enemies_and_objects.nx)
		ld	 b,0
		add	 hl,bc
		;	ld    de,271                          ;lets say that if a wall's x>272 is on the right edge of the screen.
		sbc   hl,de
		ret   c
		jp .remove



;020-ratFaceBatSpawner
.Object020:
  		ld		hl,Object020Table			;object=RatFace
		call	.copyObjectTemplate
		call	.applyObjectClassEnemySpawn ;out: DE=numbBytes, HL=objectX, A=objectY, B=maxSpawn
		ld		de,8
		add		hl,de
		ld		(iy+enemies_and_objects.x),l
		ld		(iy+enemies_and_objects.x+1),h
		add		a,24
		ld		(iy+enemies_and_objects.y),a
		ld		(iy+enemies_and_objects.phase),0
		ld		(iy+enemies_and_objects.v5),0

		ld 		a,BigStatueMouth.maxBats
		cp		b
		jr		nc,.020l0
		ld		(iy+enemies_and_objects.spawnMax),a
		ld		b,a
.020l0:	call	.addBats
		call	.LoadObject020Gfx
		ld		de,roomobjectClass.enemyspawn.numBytes
		ret

.addBats:
		push	bc
		ld		de,lenghtenemytable	;next objectRecord
		add		iy,de
		call	.object147Spawn
		pop		bc
		djnz	.addBats
		ret

 ;write big statue mouth to (216,0) page 3
.LoadObject020Gfx:
		ld		a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
		cp		1
		ret		z
		ld		a,1
		ld		(BigEnemyPresentInVramPage3),a  ;1=big statue mouth, 2=huge blob, 3=huge spider

		ld		a,1
		ld		(PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld		hl,$4000 + (016*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld		de,$8000 + (Object020Table.sy*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld		bc,$0000 + (031*256) + (056/2)        ;(ny*256) + (nx/2)
		ld		a,GfxObjectsForVramBlock              ;block to copy graphics from
		call	CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY
		ret

;147-bat
.object147Spawn:
		ld		hl,object147Table	;CuteMiniBatTable               ;bat
		call	.copyObjectTemplate
		call	.applyObjectSpriteProperties	; call	SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
		ld		(iy+enemies_and_objects.Alive?),0	;mark inactive
		ret


;ro: this is very, very quick and dirty code :) it asumes there's two balls in Tiled with the same number.
;061 - glass ball (GlassBallActivator)
.Object061:  
		ld    a,(ix+roomObjectClass.glassBall.ballNumber)
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
		ld    de,roomObjectClass.glassBall.numBytes*2 ;Object061Table.lenghtobjectdata*2
		ret    
  
.SetGlassBall4:
		ld    hl,GlassBall5Data
		push  iy
		pop   de                              ;enemy object table
		ld    bc,lenghtenemytable*3           ;3 objects (2 balls and 1 ball activator)
		ldir
		ld    de,lenghtenemytable*2           ;lenght 2 objects in object table
		add   iy,de                           ;next object in object table
		ld    de,roomObjectClass.glassBall.numBytes*2 ;Object061Table.lenghtobjectdata*2
		ret    


;062-ZombieSpawnPoint
;v1=Zombie Spawn Timer
;v2=Max Number Of Zombies
;v3=Speed
;v4=Face direction
;class=EnemySpawn
.Object062:                           
		ld		hl,Object062Table		;spawnPoint
		call	.copyObjectTemplate
		call	.SetAlive?BasedOnEngineType		;!! ro:why?
		call	.applyObjectClassEnemySpawn

		call	.SetGfxZombieSpawnPoint
		ld		a,(iy+enemies_and_objects.spawnMax)	;(iy+enemies_and_objects.v2)
		dec		a
		and		0x03	;max 4
		inc		a
		ld		b,a
		call	.addZombies
		ld		de,roomobjectClass.enemyspawn.numBytes
		ret

;add [b] zombie objects
.addZombies:
		push	bc
		ld		de,lenghtenemytable	;next objectRecord
		add		iy,de
		call	.object143Spawn
		pop 	bc
		djnz	.addZombies
		ret  

;!! ro: what, why?
.SetAlive?BasedOnEngineType:
		ld    a,(scrollEngine)              ;1= 304x216 engine  2=256x216 SF2 engine
		dec   a
		ret   z
		ld    (iy+enemies_and_objects.Alive?),2	;-1=hardsprite,0=off,1=softsprite,2=sf2
		ret  

;143-retardedZombie
.object143Spawn:
		ld		hl,Object143Table               ;zombie
		call	.copyObjectTemplate
		call	.applyObjectSpriteProperties	; call	SetSPATPositionForThisSprite    ;we need to define the position this sprite takes in the SPAT
		ld		(iy+enemies_and_objects.Alive?),0	;mark inactive
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
		jr    z,.l0
		ld    de,00
.l0:	ld    a,(FreeToUseFastCopy+dpage)
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
		ld    a,216+32						;source is 248 (magic number)
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



;128-hugeBlob, class=general
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=jumping)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Jump to Which platform ? (1,2 or 3)
;v6=Gravity timer
;v7=Dont Check Land Platform First x Frames
.Object128:
		exx
		ld    b,16                            ;huge blob starts at sprite nr 16 and places player at sprite 12-15, to make sure player is always in the front
		exx   

		ld		hl,Object128Table
  		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		push	de
		call	.applyObjectSpriteProperties
		ld		hl,Object128Table.body
		call	.SetObjectBelongingToHardwareSprite
		call	.object128LoadGfx
		pop		de
		ret

.object128LoadGfx:
		ld		a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
		cp		2	;already present?
		ret		z
		ld		a,2
		ld		(BigEnemyPresentInVramPage3),a
;write huge blob to (216,0) page 3
		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (016*128) + (112/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (216*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (032*256) + (074/2)        ;(ny*256) + (nx/2)
		ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY
		ret


;129-hugeSpider (hwspr), class=enemy
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
.Object129:
		ld    hl,Object129Table		;legs
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
  		push	de
		ld		hl,Object129Table.body	;body
		call	.SetObjectBelongingToHardwareSprite
		call	.object129LoadGfx
		pop		de	
		ret

.object129LoadGfx:
		ld		a,(BigEnemyPresentInVramPage3)  ;1=big statue mouth, 2=huge blob, 3=huge spider
		cp		3
		ret		Z	;jr    z,.EndPutObject129
		ld		a,3
		ld		(BigEnemyPresentInVramPage3),a  ;1=big statue mouth, 2=huge blob, 3=huge spider

		;write huge spider to (216,0) page 3
		ld    a,1
		ld    (PageToWriteTo),a                     ;0=page 0 or 1, 1=page 2 or 3
		ld    hl,$4000 + (016*128) + (186/2) - 128  ;(y*128) + (x/2)
		ld    de,$8000 + (216*128) + (000/2) - 128  ;(y*128) + (x/2)
		ld    bc,$0000 + (021*256) + (054/2)        ;(ny*256) + (nx/2)
		ld    a,GfxObjectsForVramBlock              ;block to copy graphics from
		call  CopyRomToVram                         ;in: hl->sx,sy, de->dx, dy, bc->NXAndNY
		ret


;130-lancelot (hwspr), class=enemy
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Shield hit timer
.Object130:
		ld    hl,Object130Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
  		push	de
		ld		hl,Object130Table.sword
		call	.SetObjectBelongingToHardwareSprite
		pop		de	
		ret


;131-blackHoleAlien, class=enemy
.Object131:
		ld		hl,Object131Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;132-fireEyeGreen, class=general
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=v3v4tablerotator
;v7=green fire eye(0) / grey fire eye(1)
.Object132:
		call	.object132AddTurret
		ld		(iy+enemies_and_objects.v7),0   ;v7=green fire eye(0) / grey fire eye(1)
		call	.object132AddBullets
		ld		de,roomObjectClass.General.numBytes
		ret
;add the turret as object
.object132AddTurret:
		ld		hl,Object132Table
  		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		jp		.applyObjectSpriteProperties
;add 4 bullets as objects
.object132AddBullets:
		ld    hl,Object132Table.bullet
		call  .SetObjectBelongingToHardwareSprite
		ld    hl,Object132Table.bullet
		call  .SetObjectBelongingToHardwareSprite
		ld    hl,Object132Table.bullet
		call  .SetObjectBelongingToHardwareSprite
		ld    hl,Object132Table.bullet
		call  .SetObjectBelongingToHardwareSprite
		ret

;132-fireEyeGrey, class=general
.Object133:
		call	.object132AddTurret
		ld		(iy+enemies_and_objects.v7),1   ;v7=green fire eye(0) / grey fire eye(1)
		call	.object132AddBullets
		ld		de,roomObjectClass.General.numBytes
		ret


;134-knifeThrower, class=enemy
.Object134:
		ld		hl,Object134Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties

		push	de
		ld		hl,Object134Table.knife
		call	.SetObjectBelongingToHardwareSprite
		ld		hl,Object134Table.knife
		call	.SetObjectBelongingToHardwareSprite
		pop		de
		ret


;135-octopussy, class=general
.Object135:
		ld		hl,Object135Table
  		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties

		ld		hl,Object135Table.bullet
		call	.SetObjectBelongingToHardwareSprite
		ld		hl,Object135Table.bullet
		call	.SetObjectBelongingToHardwareSprite
		ld		hl,Object135Table.slowdownhandler
		call	.SetHandlerObject
		ld		de,roomObjectClass.General.numBytes
		ret


;136-grinder, class=enemy
.Object136:
		ld		hl,Object136Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;137-Treeman, class=enemy
.Object137:
		ld		hl,Object137Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;138-Hunchbak, class=enemy
.Object138:
		ld		hl,Object138Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;139-Scorpion, class=enemy
.Object139:
		ld		hl,Object139Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;140-Beetle, class=enemy
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=movement table. 0=Table 1 (Circling ClockWise) 1=Table 1 (Circling CounterClockwise)      
;v8=face left (-0) or face right (1)
.Object140:
		ld		hl,Object140Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		add   2                               ;ny=22, thats 2 below an 8-fold, therefor add 2 to it's y
		ld    (iy+enemies_and_objects.y),a
		call	.applyObjectSpriteProperties

;set face in v8 for this object
;!! ro:why not just look at .v4 during operation as well and skip v8?
		ld    a,(iy+enemies_and_objects.v4)   ;v4=Horizontal Movement
		or    a
		ret   p
		ld    (iy+enemies_and_objects.v8),0   ;v8=face left (-0) or face right (1)
		ret


;141-spiderGreen, class=enemy
;v6=Green Spider(0) / Grey Spider(1)
.Object141:
		ld		hl,Object141Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		ld		(iy+enemies_and_objects.v6),0   ;v6=Green Spider(0) / Grey Spider(1)
		call	.applyObjectSpriteProperties
		ret

;142-spiderGrey, class=enemy
.Object142:
		ld		hl,Object141Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		ld		(iy+enemies_and_objects.v6),1   ;v6=Green Spider(0) / Grey Spider(1)
		call	.applyObjectSpriteProperties
		ret


;144-boringEyeGreen
;v1=Animation Counter
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Green (0) / Red(1)
.Object144:
		ld		hl,Object144Table
  		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		ld		(iy+enemies_and_objects.v7),0   ;v7=Green (0) / Red(1)
		call	.applyObjectSpriteProperties
		ret

;145-boringEyeRed
.Object145:
		ld		hl,Object144Table
  		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		ld		(iy+enemies_and_objects.v7),1   ;v7=Green (0) / Red(1)
		call	.applyObjectSpriteProperties
		ret


;146-blackHoleAlienBaby, class=enemy
.Object146:
;v1=Animation Counter
;v2=Phase (0=walking slow, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v6=Gravity timer
		ld		hl,Object146Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;148-landstrider, class=enemy
.Object148:
		ld		hl,Object148Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		exx                                   ;landstider uses 2 sprites when small, but 4 sprites when big, therefor we need to reserve 2 extra sprite positions for this object
		inc   b                               ;next sprite position in b
		inc   b                               ;next sprite position in b
		exx
		ret


;149-sensorTentacle (hwspr)
.Object149:
;v1=Animation Counter
;v2=Phase (0=Hanging, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=repeating steps
;v6=pointer to movement table
;v7=Gravity timer
;v8=Starting Y
;v9=wait until attack timer 
		ld		hl,Object149Table
		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties
		ld		a,(iy+enemies_and_objects.y)    ;y
		ld		(iy+enemies_and_objects.v8),a   ;v8=Starting Y
		ret


;150-trampolineSlimeGreen, class=enemy
.Object150:
;v1=Animation Counter
;v2=Phase (0=TrampolineBlob Moving, 1=TrampolineBlob jumping)
;v4=Horizontal Movement
;v5=Unable to be hit duration
		ld		hl,Object150Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;151-waspGreen (hwSpr)
.Object151:
		ld		hl,Object151Table
		call	.copyObjectTemplate
		ld		(iy+enemies_and_objects.v7),0  ;v7=Green Wasp(0) / Brown Wasp(1)
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties
		ret

;152-waspBrown (hwSpr)
.Object152:
		ld		hl,Object151Table
		call	.copyObjectTemplate
		ld		(iy+enemies_and_objects.v7),1  ;v7=Green Wasp(0) / Brown Wasp(1)
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties
		ret

;153-waspYellow (hwSpr)
.Object153:
		ld		hl,Object153Table
		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties
		ret



;154-demonGreen, class=enemy
;v1=Animation Counter
;v2=Phase (0=hanging in air, 1=attacking)
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Attack Timer
;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
.Object154:
		ld		a,0	;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
		jp		.object154Add
.object154Add:
		push	af
		ld		hl,Object154Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		pop		af
		ld		(iy+enemies_and_objects.v7),a   ;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
		call	.applyObjectSpriteProperties
		push	de
		ld		hl,Object154Table.bullet		;add bullet sprite
		call	.SetObjectBelongingToHardwareSprite
		pop		de
		ret

;155-demonRed
.Object155:
		ld		a,1	;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
		jp		.object154Add

;156-demonBrown
.Object156:
		ld		a,2	;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
		jp		.object154Add

;157-demonGrey
.Object157:
		ld		a,3	;v7=Green (0) / Red(1) / Brown(2) / Grey(3)
		jp		.object154Add


;158-slimeBlack, class=enemy
.Object158:
		ld		hl,Object158Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ret


;159-glassBallPipe, class=general
.Object159:
		ld    hl,object159Table	;GlassBallPipeObject
		call	.copyObjectTemplate
		call	.applyObjectClassGeneral
		call	.applyObjectSpriteProperties
		dec   (iy+enemies_and_objects.y)      ;should be 1 pixel up
		dec   (iy+enemies_and_objects.x)      ;should be 1 pixel to the left
		ret


;143-zombie
.Object143:
		ld		hl,Object143Table
		call	.copyObjectTemplate
		call	.applyObjectClassEnemy
		call	.applyObjectSpriteProperties
		ld		(iy+enemies_and_objects.v2),1	;v2=Phase (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
		ret


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



;##### Object definitions as template for objectdata ##### 
isSprite:		equ 1
isNotSprite:	equ 0
isAliveSs:		equ 1	;alive=2 / sf2, alive=1 softSpr, alive=-1 hardSpr
isAliveHs:		equ -1
isAliveSf2:		equ 2
isNotAlive:		equ 0

;001-pushStone
Object001Table:
.sx:	equ 112	;graphics location
.hit:	equ 0
.life:	equ 0
;Pushing Stones: v1=sx, v2=falling stone?, v3=y movement, v4=x movement, v7=set/store coord, v9=special width for Pushing Stone Puzzle Switch, v1-2= coordinates
;		alive?,Sprite?,Movement Pattern,   y,x,    ny,nx,   Objectnr, spatAdr, numspr,     ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,movepatbloc
		db	isaliveSs,isNotSprite
		dw	PushingStone
		db	0,0,0,16,16	;y,xx,ny,nx
		dw	cleanOb1,0 ;objnr,spatadr
		db	0	;numsprites
		dw	-1 ;pushStoneTable+pushStoneTable.roomY	;tableRec
		db	.sx,0,0,0,0,0,0,14,14,.hit,.life,movementpatterns1block
		ds	fill-1


;002-Waterfall yellow
;v1=sx
;v2=Active Timer
;v3=wait timer in case only 1 waterfall
;v4=Waterfall nr
Object002Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                ,v1, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.eyes:    db isAlivess,isNotSprite|dw WaterfallEyesYellow|db 0|dw 0|db 06,14|dw CleanOb1,0 db 0,0,0, WaterfallEyesYellowClosedSX,+00,+01,+01,+00,0,0,8*00+3,8*00,8*00+3,8*00,movementpatterns1block| ds fill-1
;Waterfall mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.mouth:   db isNotAlive,isNotSprite|dw WaterfallMouth|db 0|dw 0|db 06,10|dw CleanOb2,0 db 0,0,0, WaterfallMouthYellowClosedSX,+00,+00,+02,+00,+00,+02,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Water
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.water:   db isNotAlive,isSprite|dw Waterfall |db 0|dw 0|db 64,10|dw 16*16,spat+(16*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,-01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1

;003-Waterfall grey
Object003Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#             ,sx, v2, v3, v4, v5,    v6,    v7,    v8,    v9,   v10,   v11,   
.eyes:    db isAliveSs,isNotSprite|dw WaterfallEyesGrey|db 0|dw 0|db 06,14|dw CleanOb3,0 db 0,0,0,+095,+00,200,+02,+01,8*15+3,8*06,8*15+3,8*28,8*00+3,8*00,movementpatterns1block| ds fill-1


;004-PoisonDrop / Dripping Ooze Drop
Object004Table:
.sx:	equ	SXDrippingOoze1
		;alive?,Sprite?,Movement Pattern,             y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8   , v9   ,Hit?,life 
		db isAliveSs,isNotSprite|dw DrippingOozeDrop|db 0|dw 0|db 08,05|dw CleanOb1,0 db 0,0,0,.sx,+02,+03,+00,+63,+00,+00,8*09-5,8*10+3, 0|db 000,movementpatterns1block| ds fill-1
		;alive?,Sprite?,Movement Pattern,     y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.Splash:db isAliveHs,isSprite|dw DrippingOoze|db 0|dw 0|db 32,32|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;005-AreaSign
Object005Table:               
		;alive?,Sprite?,Movement Pattern,     y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveSf2,isNotSprite|dw AreaSign|db 0|dw 0|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+01,+00,+00,+00,+00,190, 0|db 016,movementpatterns1block| ds fill-1


;006-TeleportVortex
Object006Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db isAliveSf2,isNotSprite|dw Teleport|db 0|dw 0|db 64,64|dw CleanOb1,0 db 0,0,0,+149,+00,+00,+00,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1


Object007Table:               ;Waterfall Scene
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
          db isAliveSf2,isNotSprite|dw WaterfallScene      |db 8*02  |dw 8*17  |db 64,64|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,+00,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1
;          db 0,        0|dw BossRatty         |db 8*21+7  |dw 8*10  |db 42,32|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,+04,+00,+01,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1
;          db 2,        0|dw BossRatty         |db 8*21+7  |dw 8*20  |db 42,32|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,-04,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1
;          db 2,        0|dw BossRattyHandler    |db 8*02  |dw 8*17  |db 00,00|dw CleanOb1,0 db 0,0,0,                 +149,+00,+00,+00,+00,+00,+00,+00,+00, 1|db 000,movementpatterns1block| ds fill-1


;008-FireDemonBoss
Object008Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveSf2,isNotSprite|dw BossDemon           |db 8*02+1|dw 8*06|db 00,00|dw 00000000,0 db 0,0,0,                    +00,+00,+00,+00,+00,+00,+00,+00,+20, 0|db 2,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isNotAlive,isSprite|dw BossDemonBullet     |db 8*10|dw 8*22|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
		db isNotAlive,isSprite|dw BossDemonBullet     |db 8*12|dw 8*22|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
		db isNotAlive,isSprite|dw BossDemonBullet     |db 8*14|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;010-PlatformMovingLarge
Object010Table:
       ;alive?,Sprite?,Movement Pattern,        y,  x,   ny,nx,Objectnr#					,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
		db isAliveSf2,isNotSprite|dw HugeBlock|db 0|dw 0|db 48,48|dw 00000000,0 db 0,0,0,	+00,+00,+00,+01,+00,+00,+16,+00,+00, 0|db 016,movementpatterns1block| ds fill-1


;011-PlatformMovingSmall
Object011Table:
.sx:	equ	64
.sy:	equ 216
		;alive?,Sprite?,Movement Pattern,    y,      x,   ny,nx,Objectnr#               ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
		db isAliveSs,isNotSprite|dw Platform|db 0|dw 0|db 16,16|dw CleanOb1,0 db 0,0,0, .sx,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;012-PlatformMovingSmallSwitch
Object012Table:
.sxOff:	equ	80
.sxOn:	equ 96
		;alive?,Sprite?,Movement Pattern,    y,      x,   ny,nx,Objectnr#               ,sx,   v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
		db isAliveSs,isNotSprite|dw Platform|db 0|dw 0|db 16,16|dw CleanOb1,0 db 0,0,0, .sxOff,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1

;057-PlatformMovingMedium
Object057Table:
.sxOff:	equ	00
.sxOn:	equ 32
		;alive?,Sprite?,Movement Pattern,    y,      x,   ny,nx,Objectnr#               ,sx,   v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
		db isAliveSs,isNotSprite|dw Platform|db 0|dw 0|db 16,32|dw CleanOb1,0 db 0,0,0, .sxOn,+05,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;013-bossPlant
Object013Table:
       ;alive?,Sprite?,Movement Pattern,       y=83,  x=52, ny,nx,   Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life   
		db isAliveSf2,isNotSprite|dw BossPlant|db 083|dw 52|db 60,60|dw CleanOb1,0 db 0,0,0,                      -01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 011,movementpatterns2block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db -0,        1|dw BossPlantBullet     |db 8*00|dw 8*00|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1
		db -0,        1|dw BossPlantBullet     |db 8*00|dw 8*00|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1
		db -0,        1|dw BossPlantBullet     |db 8*00|dw 8*00|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1
;         db -0,        1|dw BossPlantBullet     |db 8*00|dw 8*00|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1

;         db -0,        1|dw BossPlantBullet     |db 8*10|dw 8*22|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1
;         db -0,        1|dw BossPlantBullet     |db 8*12|dw 8*22|db 16,16|dw 24*16,spat+(24*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1
;         db -0,        1|dw BossPlantBullet     |db 8*14|dw 8*22|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns2block| ds fill-1


;014-BreakableWall
Object014Table:
		;alive?,Sprite?,Movement Pattern,         y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveSs,isNotSprite|dw BreakableWall|db 0000|dw 000 |db 00,00|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 255,movementpatterns2block| ds fill-1


;015-PlatformRetracting
Object015Table:
       		;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.handler:	db isAliveSs,isNotSprite|dw AppBlocksHandler|db 0*00|dw 0*00|db 00,00|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
       		;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.platform:	db isNotAlive,isNotSprite|dw AppearingBlocks|db 0|dw 0|db 16,16|dw CleanOb1,0 db 0,0,0,                     -001,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;016-PlatformMovingSmallOmnidirectional
Object016Table:
;platform Omni Directionally
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
		db isAliveSs,isNotSprite|dw PlatformOmniDirectionally|db 8*11|dw 8*10|db 16,16|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;bat spawner (BigStatueMouth)
Object020Table:
.sy:	equ	216
       ;alive?,Sprite?,Movement Pattern,           y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveSs,isNotSprite|dw BigStatueMouth|db 0|dw 0|db 31,28|dw CleanOb1,0 db 0,0,0,                     BigStatueMouthClosedSx,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

;147-bat / Cute Mini Bat
object147Table:
		;alive?,Sprite?,Movement Pattern,        y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw CuteMiniBat|db 0|dw 0|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+01,095, 0|db 001,movementpatterns1block| ds fill-1


;glass ball (& GlassBallActivator) @karnimata
Object061Table:
GlassBall5Data:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db isAliveSf2,isNotSprite|dw GlassBall3          |db 8*19|dw 8*02|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.object2: db isAliveSf2,isNotSprite|dw GlassBall4          |db 8*19|dw 8*24|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Glass Ball Activator
.object3: db isAliveSf2,isNotSprite|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
GlassBall1Data:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object1: db isNotAlive,isNotSprite|dw GlassBall1          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
.object2: db isNotAlive,isNotSprite|dw GlassBall2          |db 8*03|dw 8*31|db 48,48|dw 00000000,0 db 0,0,0,                      +00,+00,+00,+00,+00,+01,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
;Glass Ball Activator
.object3: db isAliveSf2,isNotSprite|dw GlassBallActivator  |db 0*00|dw 0*00|db 00,00|dw 00000000,0 db 0,0,0,                      +01,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;062-zombieSpawnPoint
Object062Table:
		;alive?,Sprite?,Movement Pattern,   y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db  isAliveSs,isNotSprite|dw ZombieSpawnPoint|db 0|dw 0|db 00,00|dw 00*00,spat+(00*0)|db 00-(00*0),00  ,00*00,+04,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;retarded zombie
Object143Table:
		;alive?,Sprite?,Movement Pattern,        y,   x,   ny,nx,   spnrinspat,spatadr,  nrsprites,  nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw RetardedZombie|db 0|dw 0|db 32,16|dw 12*16,spat+(12*2)|db 72-(04*6),04,04*16,   +00,+00,+01,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;128-hugeBlob
Object128Table:
       ;alive?,Sprite?,Movement Pattern,  y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw HugeBlob|db 0|dw 0|db 48,46|dw 16*16,spat+(16*2)|db 72-(12*6),12  ,12*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
;Huge Blob software sprite part
       ;alive?,Sprite?,Movement Pattern,             y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.body:	db isAliveSs,isNotSprite|dw HugeBlobSWsprite|db 0|dw 0|db 21,14|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

;129-hugeSpider
Object129Table:
;Huge Spider Legs
       ;alive?,Sprite?,Movement Pattern,              y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.legs:	db isAliveHs,isSprite|dw HugeSpiderLegs      |db 0|dw 0|db 24,64|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1  
.body:	db isAliveSs,isNotSprite|dw HugeSpiderBody   |db 0|dw 0|db 21,27|dw CleanOb1,0 db 0,0,0,                     +027,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

;130-lancelot
Object130Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite   |dw Lancelot            |db 8*13|dw 8*20|db 32,16|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
.sword:	db isAliveSs,isNotSprite|dw LancelotSword       |db 8*10|dw 8*10|db 07,27|dw CleanOb1,0 db 0,0,0,                     +000,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;131-blackHoleAlien
Object131Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw BlackHoleAlien |db 0|dw 0|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1


;132-fireEyeGreen
;132-fireEyeGrey
Object132Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db isAliveHs,isSprite|dw FireEye             |db 8*19|dw 8*21|db 48,32|dw 12*16,spat+(12*2)|db 72-(11*6),11  ,11*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.bullet:  db isNotAlive,isNotSprite|dw FireEyeFireBullet   |db 8*18|dw 8*21|db 13,06|dw CleanOb1,0 db 0,0,0,                     +128,+00,-03,+01,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;134-knifeThrower
Object134Table:
       ;alive?,Sprite?,Movement Pattern,         y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw SnowballThrower|db 0|dw 0|db 32,16|dw 16*16,spat+(16*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,      y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.knife:	db isNotAlive,isNotSprite|dw Snowball|db 8*21|dw 8*13|db 04,15|dw CleanOb1,0 db 0,0,0,                     +241,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;135-octopussy
Object135Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db isAliveHs,isSprite|dw Octopussy           |db 8*14|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,-01,+00,+01,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
;Octopussy Bullet
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,Objectnr#                                    ,sx, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life,   
.bullet:  db isNotAlive,isNotSprite|dw OctopussyBullet     |db 8*12|dw 8*16|db 08,08|dw CleanOb1,0 db 0,0,0,                     +146,+00,+02,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.slowdownhandler: db isAliveSs,isNotSprite|dw OP_SlowDownHandler  |db 8*12|dw 8*16|db 00,00|dw CleanOb1,0 db 0,0,0,                      +00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1


;136-grinder
Object136Table:
       ;alive?,Sprite?,Movement Pattern, y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Grinder|db 0|dw 0|db 32,32|dw 12*16,spat+(12*2)|db 72-(08*6),08,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1  


;137-Treeman
Object137Table:
       ;alive?,Sprite?,Movement Pattern, y,   x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Treeman|db 0|dw 0|db 32,26|dw 20*16,spat+(20*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 005,movementpatterns1block| ds fill-1


;138-Hunchback
Object138Table:
       ;alive?,Sprite?,Movement Pattern,     y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
         db isAliveHs,isSprite|dw Hunchback|db 0|dw 0|db 32,30|dw 12*16,spat+(12*2)|db 72-(08*6),08  ,08*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 003,movementpatterns1block| ds fill-1


;139-Scorpion
Object139Table:
       ;alive?,Sprite?,Movement Pattern,    y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Scorpion|db 0|dw 0|db 32,22|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+01,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;140-Beetle
Object140Table:
       ;alive?,Sprite?,Movement Pattern, y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Beetle|db 0|dw 0|db 22,28|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+00,+00,+00,+01,+00, 0|db 003,movementpatterns1block| ds fill-1

;141-spiderGreen
;142-spiderGrey
Object141Table:               ;green / grey spider. v6=Green Spider(0) / Grey Spider(1)
       ;alive?,Sprite?,Movement Pattern,      y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw GreenSpider|db 0|dw 0|db 16,30|dw 24*16,spat+(24*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,-01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;144-boringEyeGreen
;145-boringEyeRed
;v6=Green (0) / Red (1)
Object144Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw BoringEye           |db 8*18|dw 8*09|db 22,16|dw 12*16,spat+(12*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;146-blackHoleAlienBaby
Object146Table:               ;black hole alien baby
       ;alive?,Sprite?,Movement Pattern,        y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw BlackHoleBaby|db 0|dw 0|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 002,movementpatterns1block| ds fill-1


;148-landstrider
Object148Table:
       ;alive?,Sprite?,Movement Pattern,     y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Landstrider|db 0|dw 0|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;149-sensorTentacle
Object149Table:
       ;alive?,Sprite?,Movement Pattern,           y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw SensorTentacles|db 0|dw 0|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,8*12,+1, 0|db 001,movementpatterns1block| ds fill-1


;150-trampolineSlimeGreen
Object150Table:
		;alive?,Sprite?,Movement Pattern,        y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw TrampolineBlob|db 0|dw 0|db 16,22|dw 20*16,spat+(20*2)|db 72-(04*6),04  ,04*16,+00,+00,+00,+01,+01,+00,+00,+08,+36, 0|db 255,movementpatterns1block| ds fill-1


;151-waspGreen
Object151Table:
		;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db  isAliveHs,isSprite|dw Wasp|db 0|dw 0|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1

;151-waspYellow
Object153Table:
		;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db  isAliveHs,isSprite|dw YellowWasp|db 0|dw 0|db 16,16|dw 26*16,spat+(26*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1


;154/155/156/157-Demontje v7=Green (0) / Red(1) / Brown(2) / Grey(3)
Object154Table:
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Demontje|db 0|dw 0|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+02,+00,+00,+00,+00,+00, 0|db 001,movementpatterns1block| ds fill-1
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.bullet:	db isNotAlive,isNotSprite|dw DemontjeBullet|db 0|dw 0|db 11,11|dw CleanOb1,0 db 0,0,0,                     +146,+00,-01,+02,+00,+00,+00,+00,+00, 0|db 000,movementpatterns1block| ds fill-1

;158-slimeBlack
Object158Table:
       ;alive?,Sprite?,Movement Pattern,y,  x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw Slime|db 0|dw 0|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movementpatterns1block| ds fill-1


;159-glassBallPipe, class=general
GlassBallPipeObject:
object159Table:
       ;alive?,Sprite?,Movement Pattern,       y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
		db isAliveHs,isSprite|dw GlassballPipe|db 8*07|dw 8*20|db 16,16|dw 12*16,spat+(12*2)|db 72-(06*6),06  ,06*16,+00,+00,+00,+01,+00,+00,+00,-02,+30, 0|db 001,movementpatterns1block| ds fill-1





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
		add a,Dsm.firstBlock	;+dsm.indexBlock	;offset (temp)
;		ld bc,$8000				;destination
;		add hl,bc
		set 7,h
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
        SRL   H     	    ;seglen=128. So, shift 1 right
        RR    L
        RET
GWMR.0: ADD   HL,BC
        JP    GWMR.1





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

		ld    a,Graphicsblock5              ;block to copy from
		call  block34

		ld    hl,$6C00+128                      ;page 0 - screen 5 - bottom 40 pixels (scoreboard)
		xor   a
		call	SetVdp_Write	
		ld		hl,scoreboard
		ld    c,$98
		ld    a,38/2                        ;copy 38 lines..
		ld    b,0
		call  copyGraphicsToScreen.loop1
		jp    outix128



;BorderMaskingSpritesCall:
;  call  SetBorderMaskingSprites       ;set border masking sprites position in Spat
;NoBorderMaskingSpritesCall:
;  nop | nop | nop                     ;skip border masking sprites



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
  
  ld    a,(PlayerIsInWater?)
  or    a
  jr    nz,.PlayerIsInWaterDontChangeRunningSpeed
  ld    a,StartingJumpSpeedEqu        ;reset Starting Jump Speed
  ld    (StartingJumpSpeed),a
  inc   a
  ld    (StartingJumpSpeedWhenHit),a
  ld    hl,.NormalRunningTable        ;Reset Normal Running Table
  ld    de,RunningTable1
  ld    bc,RunningTableLenght
  ldir
  .PlayerIsInWaterDontChangeRunningSpeed:

  ld    a,0*32+31
  ld    (PageOnNextVblank),a

  xor   a                              ;restore variables to put SF2 objects in play
  ld    (PutObjectInPage3?),a
  ld    (screenpage),a                    ;we (hack)force screen 1 to be active at all time
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
  ld    (Bossframecounter),a              ;boss frame counter

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
  
.NormalRunningTable:	;ro, this is called "enertia"
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
;  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
;  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
;  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1
  


	dephase