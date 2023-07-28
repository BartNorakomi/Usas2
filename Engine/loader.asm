loader:
  call  screenoff
  call  ReSetVariables
  call  SwapSpatColAndCharTable2
  call  SwapSpatColAndCharTable
  call  SwapSpatColAndCharTable2


  ld    a,WorldMapDataCopiedToRamBlock;loader routine at $4000
  call  block34
  ld    hl,(WorldMapPointer)
  ld    de,MapDataCopiedToRam
  ld    bc,6
  ldir
  ld    ix,MapDataCopiedToRam

  call  SetEngineType                 ;sets engine type (1= 304x216 engine  2=256x216 SF2 engine), sets map lenghts and map exit right and adjusts X player player is completely in the right of screen
  call  SetTilesInVram                ;copies all the tiles to Vram
  call  PopulateControls              ;this allows for a double jump as soon as you enter a new map
  call  SetMapPalette                 ;sets palette
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
;  ld    hl,FillBottomPartScoreBoard
;  call  docopy  

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
;  ld    b,128
;  otir                                ;copy last line, 39 in total
  call  outix128
  ret
  
SetMapPalette:
;set palette
  ld    a,(ix+5)                      ;palette
  or    a
  ld    hl,VoodooWaspPalette          ;0
  jr    z,.goSetPalette
  dec   a
  ld    hl,GoddessPalette             ;1
  jr    z,.goSetPalette
  dec   a
  ld    hl,KonarkPalette              ;2
  jr    z,.goSetPalette
  dec   a
  ld    hl,KarniMataPalette           ;3
  jr    z,.goSetPalette
  dec   a
  ld    hl,BlueTemplePalette          ;4
  jr    z,.goSetPalette
  dec   a
  ld    hl,BurialPalette              ;5
  jr    z,.goSetPalette
  dec   a
  ld    hl,BossAreaPalette            ;6
  jr    z,.goSetPalette
  dec   a
  ld    hl,IceTemplePalette           ;7
  jr    z,.goSetPalette

  .goSetPalette:
  
  push  hl
  ld    de,CurrentPalette
  ld    bc,32
  ldir
  pop   hl
  
;ret  
  
  jp    setpalette

KarniMataPalette:
  incbin "..\grapx\tilesheets\sKarniMatapalette.PL" ;file palette 
VoodooWaspPalette:
  incbin "..\grapx\tilesheets\sVoodooWaspPalette.PL" ;file palette 
GoddessPalette:
  incbin "..\grapx\tilesheets\sGoddessPalette.PL" ;file palette 
BlueTemplePalette:
  incbin "..\grapx\tilesheets\sBlueTemplePalette.PL" ;file palette 
KonarkPalette:
  incbin "..\grapx\tilesheets\sKonarkPalette.PL" ;file palette 
;KonarkBrighterPalette1:
;  incbin "..\grapx\tilesheets\sKonarkBrighterPalette1.PL" ;file palette 
;KonarkBrighterPalette2:
;  incbin "..\grapx\tilesheets\sKonarkBrighterPalette2.PL" ;file palette 
;KonarkBrighterPalette3:
;  incbin "..\grapx\tilesheets\sKonarkBrighterPalette3.PL" ;file palette 
BurialPalette:
  incbin "..\grapx\tilesheets\sBurialPalette.PL" ;file palette 
BossAreaPalette:
  incbin "..\grapx\tilesheets\sBossAreaPalette.PL" ;file palette 
IceTemplePalette:
  incbin "..\grapx\tilesheets\sIceTemplePalette.PL" ;file palette 
  
SetTilesInVram:  
;set tiles in Vram
  ld    a,(ix+4)                      ;tile data
  or    a
  ld    d,VoodooWaspTilesBlock        ;0
  jr    z,.settiles
  dec   a
  ld    d,GoddessTilesBlock           ;1
  jr    z,.settiles
  dec   a
  ld    d,KonarkTilesBlock            ;2
  jr    z,.settiles
  dec   a
  ld    d,KarniMataTilesBlock         ;3
  jr    z,.settiles
  dec   a
  ld    d,BlueTempleTilesBlock        ;4
  jr    z,.settiles
  dec   a
  ld    d,BurialTilesBlock            ;5
  jr    z,.settiles
  dec   a
  ld    d,BossAreaTilesBlock          ;6
  jr    z,.settiles
  dec   a
  ld    d,IceTempleTilesBlock         ;7
  jr    z,.settiles

  .settiles:
  ld    a,(slot.page12rom)            ;all RAM except page 12
  out   ($a8),a          

  ld    hl,$8000                      ;page 1 - screen 5
  ld    b,0
  call  copyGraphicsToScreen2
  ret

copyGraphicsToScreen2:
  ld    a,d                           ;Graphicsblock
  call  block34
  
	ld		a,b
	call	SetVdp_Write	
	ld		hl,$8000
  ld    c,$98
  ld    a,64                          ;first 128 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
  call  .loop1    

  ld    a,d                           ;Graphicsblock
;  add   a,2
  inc   a
  call  block34
  
	ld		hl,$8000
  ld    c,$98
  ld    a,64 ; 42                     ;second 84 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
  call  .loop1   

  ;this last part is to fill the screen with a repetition
;	ld		hl,$4000
;  ld    c,$98
;  ld    a,22                         ;second 84 line, copy 64*256 = $4000 bytes to Vram
;  ld    b,0
      
;  call  .loop1   
  ret

.loop1:
  call  outix256
  dec   a
  jp    nz,.loop1
  ret

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

  ld    a,1
  ld    (SpriteSplitFlag),a           ;sprite split active

  ld    a,(ix+3)                      ;engine type
  ld    (scrollEngine),a              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a                             ;1= 304x216 engine  2=256x216 SF2 engine
  jp    z,.Engine304x216

  .Engine256x216:                     ;SF2 engine
  dec   a                             ;'normal' SF2 engine ?
  jr    nz,.Engine256x216WithSpriteSplit

;  ld    hl,NoBorderMaskingSpritesCall
;  ld    de,LevelEngine.SelfModifyingCallBMS
;  ld    bc,3
;  ldir
  
  xor   a
  ld    (SpriteSplitFlag),a           ;SF2 engine with spritesplit inactive

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

  xor   a                              ;restore variables to put SF2 objects in play
  ld    (PutObjectInPage3?),a
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
  