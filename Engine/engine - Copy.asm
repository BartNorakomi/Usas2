LevelEngine:
;  call  BackdropBlue
  call  CameraEngine              ;Move camera in relation to Player's position. prepare R18, R19, R23 and page to be set on Vblank.
;  call  BackdropBlack
  call  BackdropRed
  call  Sf2EngineObjects          ;di, restore background object, handle action object, put object in screen, handle interaction object and player, prepare page to be set on Vblank, ei 
  call  BackdropBlack
;  call  BackdropRed
  call  Handle_HardWareSprite_Enemies_And_objects
;  call  BackdropBlack
;  call  BackdropGreen
  call  SetBorderMaskingSprites   ;set border masking sprites position in Spat
;  call  BackdropBlack
  call  BackdropGreen
  call  PutPlayersprite           ;outs char data to Vram, col data to Vram and sets spat data for player (coordinates depend on camera x+y)
;  call  PutPlayerspriteSF2Engine
  call  BackdropBlack
;  call  BackdropGreen
  call  PutSpatToVram             ;outs all spat data to Vram
;  call  BackdropBlack
  call  CheckMapExit              ;check if you exit the map (top, bottom, left or right)

;Routines starting at lineint:
  xor   a                         ;wait for lineint flag to be set. It's better (for now) to put the VRAM objects directly after the lineint
  ld    hl,lineintflag
;  ld    (hl),a
.checkflag1:
  cp    (hl)
  jr    z,.checkflag1

  call  SwapSpatColAndCharTable2

  call  BackdropBlue
  call  RestoreBackground         ;remove all vdp copies/software sprites that were put in screen last frame
  call  HandlePlayerSprite        ;handles all stands, moves player, checks collision, prepares sprite offsets
  call  HandlePlayerWeapons
  call  BackdropBlack

  xor   a
  ld    (SnapToPlatForm?),a
	call	handle_enemies_and_objects

  call  PopulateControls

  ld    a,(framecounter)
  inc   a
  ld    (framecounter),a

  xor   a
  ld    hl,vblankintflag
.checkflag:
  cp    (hl)
  jr    z,.checkflag
  ld    (hl),a  
  ld    (lineintflag),a
  jp    LevelEngine

ClesX:      dw 50 ;$19 ;230 ;250 ;210
ClesY:      db 30 ;144-1
;herospritenrTimes2:       equ 12*2
herospritenrTimes2:       equ 28*2

BackdropRandom:
  ld    a,r
  jp    SetBackDrop

BackdropOrange:
  ld    a,13
  jp    SetBackDrop

BackdropGreen:
  ld    a,10
  jp    SetBackDrop

BackdropRed:
  ld    a,14
  jp    SetBackDrop

BackdropBlack:
  ld    a,15
  jp    SetBackDrop

BackdropBlue:
  xor   a
  SetBackDrop:
ret
  di
  out   ($99),a
  ld    a,7+128
  ei
  out   ($99),a	
  ret

RestoreBackground:        ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    hl,CleanPlayerProjectile+restorebackground?
  bit   0,(hl)
  call  nz,.Restore

  ld    hl,CleanPlayerWeapon+restorebackground?
  bit   0,(hl)
  call  nz,.Restore

  ld    hl,CleanOb1+restorebackground?
  bit   0,(hl)
  call  nz,.Restore

  ld    hl,CleanOb2+restorebackground?
  bit   0,(hl)
  call  nz,.Restore

  ld    hl,CleanOb3+restorebackground?
  bit   0,(hl)
  call  nz,.Restore

  ld    hl,CleanOb4+restorebackground?
  bit   0,(hl)
  call  nz,.Restore
  ret

  .Restore:
  ld    (hl),0
  inc   hl
  jp    docopy  
  

switchpageSF2Engine:
;switch to next page
  ld    a,(screenpage)
  inc   a
  cp    3
  jr    nz,.not3
  xor   a
.not3:  
  ld    (screenpage),a

  add   a,a                   ;x32
  add   a,a
  add   a,a
  add   a,a
  add   a,a
  add   a,31
  ld    (PageOnNextVblank),a
  ret

Handle_HardWareSprite_Enemies_And_objects:
;several optimizations are possible here:
;1. selfmodifying ld hl,(invissprchatableaddress) into ld hl,nn
;2. several calls can be written out, like call SetVdp_Write
;3. the call outix32 can be changed into their respective numbers with a jp endOutChar at the end
;4. ld a,(CameraX) and %1111 0000 neg can be hardcoded
	ld		a,(slot.page12rom)	                          ; all RAM except page 1+2
	out		($a8),a	
  ld    a,(movementpatternsblock)
	call	block12 			                                ;at address $4000 / page 1

  ld    de,enemies_and_objects+(0*lenghtenemytable)                           
  ld    a,(de) | inc a | call z,.docheck            
  ld    de,enemies_and_objects+(1*lenghtenemytable)                        
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(2*lenghtenemytable)                                 
  ld    a,(de) | inc a | call z,.docheck            
  ld    de,enemies_and_objects+(3*lenghtenemytable)                               
  ld    a,(de) | inc a | call z,.docheck            
  ld    de,enemies_and_objects+(4*lenghtenemytable)                                     
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(5*lenghtenemytable)                                     
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(6*lenghtenemytable)
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(7*lenghtenemytable)                                     
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(8*lenghtenemytable)
  ld    a,(de) | inc a | call z,.docheck             
  ld    de,enemies_and_objects+(9*lenghtenemytable)                                     
  ld    a,(de) | inc a | call z,.docheck             

	ld		a,(slot.ram)	      ;back to full RAM
	out		($a8),a	
  ret

  .docheck:    
  ld    ixl,e
  ld    ixh,d
  call  movement_enemies_and_objects            ;handle sprite movement and animation
;out hl -> sprite character data to out to Vram
;out a -> EnemySpritesblock
;out exx
;out de -> spritenumber*26 (used for character and color data addreess)

  ;set block containing sprite data
	di
	ld		(memblocks.3),a                         ;set to block 3+4 at $8000- $c000
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a	
	ei
  
  ;set address to write sprite character data to
	ld		hl,(invissprchatableaddress)		        ;sprite character table in VRAM ($17800)   
  add   hl,de
  add   hl,de
  
  call  Backdropred
    
	ld		a,1
	call	SetVdp_WriteRemainDI

  ;out character data
  exx                                           ;recall hl. hl now points to character data
  ld    a,(ix+enemies_and_objects.nrsprites)    ;amount of sprites (1 spr=64, 2 spr=60, 3 spr=54, 4 spr=48, 5 spr=42, 6 spr=36, 7 spr=30, 8 spr=24, 9 spr=18, 10 spr=12, 11 spr=6, 12 spr=0   (72 - (amount of sprites*6)))  
  ld    (RightSideOfMap.SelfModifyinJRColorData),a  
  ld    (.SelfModifyinJRCharacterData),a
	ld		c,$98
		
  .SelfModifyinJRCharacterData:  equ $+1
  jr    .Charloop
  call  outix384 | jp .endOutChar |call  outix352 | jp .endOutChar |call  outix320 | jp .endOutChar |call  outix288 | jp .endOutChar |call  outix256 | jp .endOutChar | call  outix224 | jp .endOutChar | call  outix192 | jp .endOutChar | call  outix160 | jp .endOutChar | call  outix128 | jp .endOutChar | call  outix96 | jp .endOutChar | call  outix64 | jp .endOutChar
  .CharLoop:  
  call  outix32 ; | jp .endOutChar
  .endOutChar:
  ei
  exx                                           ;store hl. hl now points to color data

  ;set address to write sprite color data to
	ld		hl,(invissprcoltableaddress)		        ;sprite color table in VRAM ($17400)
  add   hl,de
	ld		a,1
	call	SetVdp_WriteRemainDI

  ;check if sprite is left or right part of map
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  ld    de,304/2                            ;half of the map width
  sbc   hl,de
  jp    c,LeftSideOfMap

RightSideOfMap:
  ;out color data
  exx                                           ;recall hl. hl now points to color data 
  bit   1,(ix+enemies_and_objects.hit?)         ;check if enemy is hit ? If so, out white sprite
  jr    nz,.OutWhiteSprite

  .SelfModifyinJRColorData:  equ $+1
  jr    .ColLoop
  call  outix192 | jp .EndOutColor |call  outix176 | jp .EndOutColor |call  outix160 | jp .EndOutColor |call  outix144 | jp .EndOutColor |call  outix128 | jp .EndOutColor | call  outix112 | jp .EndOutColor | call  outix96 | jp .EndOutColor | call  outix80 | jp .EndOutColor | call  outix64 | jp .EndOutColor | call  outix48 | jp .EndOutColor | call  outix32 | jp .EndOutColor
  .ColLoop:  
  call  outix16 ; | jp .EndOutColor
  .EndOutColor:
  ei

  ;write sprite coordinates to spat (take in account offset values per sprite and camera position)
  ld    e,(ix+enemies_and_objects.spataddress)  
  ld    d,(ix+enemies_and_objects.spataddress+1);de points to spat  
  
  ld    a,(CameraX)                             ;camera jumps 16 pixels every page, subtract this value from x Cles
  and   %1111 0000
  neg
  add   a,(ix+enemies_and_objects.x)
  add   -16                                     ;move all sprite 16 pixels left so they can walk out of screen left completely  
  ld    c,a                                     ;x coordinate in c
  ld    b,(ix+enemies_and_objects.y)            ;y coordinate in b

  exx
  ld    b,(ix+enemies_and_objects.nrspritesSimple)
  .Loop:
  exx
  
  ld    a,(hl)                                  ;offset y (sprite offsets are in hl and are stored in rom right after the color data)
  add   a,b
  ld    (de),a                                  ;y sprite
  inc   de                  
  inc   hl               
  ld    a,(hl)                                  ;offset x
  add   a,c  
  cp    65                                      ;check if x<65. If so sprite is out of camera range
  jr    nc,.RightSideChecked
  ld    a,255
  .RightSideChecked:
  ld    (de),a                                  ;x sprite
;  inc   de
;  inc   de
  inc   de                                      ;y next sprite
  inc   hl
  
  exx
  djnz  .Loop

  call  BackdropBlack
  ret

  .OutWhiteSprite:                              ;when enemy is hit, it's spritecolor will be white
  ld    b,(ix+enemies_and_objects.nrspritesTimes16)
  ld    e,b
  ld    d,0
  add   hl,de
  ld    a,09                                    ;white
  .loopWhite:
  out   ($98),a
  djnz  .loopWhite
  jp    .EndOutColor
  
LeftSideOfMap:
  ;out color data
  exx                                           ;recall hl. hl now points to color data
  bit   1,(ix+enemies_and_objects.hit?)         ;check if enemy is hit ? If so, out white sprite
  jr    nz,.OutWhiteSprite
  
  ld    b,(ix+enemies_and_objects.nrspritesTimes16)
  ld    c,128
  .CEbitloop:                                   ;out spritecolor with CE bit set (all values get +128)
  ld    a,(hl)
  add   a,c  
  out   ($98),a
  inc   hl
  djnz  .CEbitloop
  .EndOutColor:
  ei
  
  ;write sprite coordinates to spat (take in account offset values per sprite and camera position)
  ld    e,(ix+enemies_and_objects.spataddress)  
  ld    d,(ix+enemies_and_objects.spataddress+1);de points to spat  
  
  ld    a,(CameraX)                             ;camera jumps 16 pixels every page, subtract this value from x Cles
  and   %1111 0000
  neg
  add   a,(ix+enemies_and_objects.x)
  add   32-16                                   ;CE bit correction and move all sprite 16 pixels left so they can walk out of screen left completely
  ld    c,a                                     ;x coordinate in c
  ld    b,(ix+enemies_and_objects.y)            ;y coordinate in b

  exx
  ld    b,(ix+enemies_and_objects.nrspritesSimple)
  .Loop:
  exx
  
  ld    a,(hl)                                  ;offset y (sprite offsets are in hl and are stored in rom right after the color data)
  add   a,b
  ld    (de),a                                  ;y sprite
  inc   de                  
  inc   hl               
  ld    a,(hl)                                  ;offset x
  add   a,c
  cp    200                                     ;check if x>200. If so sprite is out of camera range
  jr    c,.LeftSideChecked
  xor   a
  .LeftSideChecked:
  ld    (de),a                                  ;x sprite
;  inc   de
;  inc   de
  inc   de                                      ;y next sprite
  inc   hl
  
  exx
  djnz  .Loop

  call  BackdropBlack
  ret

  .OutWhiteSprite:                              ;when enemy is hit, it's spritecolor will be white
  ld    b,(ix+enemies_and_objects.nrspritesTimes16)
  ld    e,b
  ld    d,0
  add   hl,de
  ld    a,09+128                                ;white + CE bit
  .CEbitloopWhite:
  out   ($98),a
;  inc   hl
  djnz  .CEbitloopWhite
  jp    .EndOutColor

handle_enemies_and_objects:
  ld    a,(scrollEngine)                              ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ret   nz
  
	ld		a,(slot.page12rom)	                          ; all RAM except page 1+2
	out		($a8),a	
  ld    a,(movementpatternsblock)
	call	block1234			                                ;at address $4000 / page 1+2

  ld    de,enemies_and_objects+(0*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(1*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(2*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(3*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(4*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(5*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(6*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(7*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(8*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(9*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(10*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(11*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(12*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(13*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(14*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(15*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(16*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(17*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(18*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(19*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(20*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)
  ld    de,enemies_and_objects+(21*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | dec a | call z,.docheck             ;4. set x&y of object in spat and out the col and char (if within screen display)

	ld		a,(slot.ram)	      ;back to full RAM
	out		($a8),a	
  ret

  .docheck:
;  call  BackdropRed  
  ld    ixl,e
  ld    ixh,d
  call  movement_enemies_and_objects                  ;sprite is in movement area, so let it move !! ^__^
;  call  BackdropBlack
  ret
  
movementpatternsblock:  db  movementpatterns1block
movement_enemies_and_objects:
  ld    l,(ix+enemies_and_objects.movementpattern)    ;movementpattern
  ld    h,(ix+enemies_and_objects.movementpattern+1)  ;movementpattern
  jp    (hl)

VramObjectX:  db  000
VramObjectY:  db  000

CopyObject:                                           ;copy any object into screen in the normal engine
  db    000,000,216,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
;  db    000,%0000 0100,$d0       ;slow transparant copy -> Copy from right to left
  db    000,%0000 0100,$90       ;slow transparant copy -> Copy from right to left

  db    0                 ;restorebackground?
CleanOb1:                                             ;these 3 objects are used in the normal engine to clean up any object that has been placed (platform, pushing stone etc)
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

  db    0                 ;restorebackground?
CleanOb2:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

  db    0                 ;restorebackground?
CleanOb3:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

  db    0                 ;restorebackground?
CleanOb4:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

CleanOb5:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

CleanOb6:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    002,000,001,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

PuzzleSwitchTable1: db  3,0,1,0,2,3,1,0,2,3
PuzzleSwitchTable2: db  0,1,2,3,1,3,0, 0,0,0
PuzzleSwitchTable3: db  0,1,2,3 ,0,0,0,0,0,0
PuzzleSwitchTable4: db  3,1,3,2,0 ,0,0,0,0,0
ShowOverView?:  db  1

CopySwitch1:
  db    000,000,232,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    016,000,004,000   ;nx,--,ny,--
  db    000,%0000 0000,$d0       ;fast copy
 
ActivateSwitch:
  db    000,000,232,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    016,000,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy  
  
CopySwitch2:
  db    000,000,232,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    016,000,016,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy
  
PuzzleBlocks1Y: db  032 | PuzzleBlocks1X: db  111
PuzzleBlocks2Y: db  032 | PuzzleBlocks2X: db  161
PuzzleBlocks3Y: db  120 | PuzzleBlocks3X: db  171
PuzzleBlocks4Y: db  024 | PuzzleBlocks4X: db  063
PuzzleBlocks5Y: db  024 | PuzzleBlocks5X: db  199
PuzzleBlocks6Y: db  096 | PuzzleBlocks6X: db  157
PuzzleBlocks7Y: db  024 | PuzzleBlocks7X: db  127
PuzzleBlocks8Y: db  024 | PuzzleBlocks8X: db  175
PuzzleBlocks9Y: db  072 | PuzzleBlocks9X: db  103
PuzzleBlocks10Y:db  032 | PuzzleBlocks10X:db  039
PuzzleBlocks11Y:db  032 | PuzzleBlocks11X:db  081
PuzzleBlocks12Y:db  032 | PuzzleBlocks12X:db  161

PuzzleBlocks13Y:db  11*8 | PuzzleBlocks13X:db  18*8+1
PuzzleBlocks14Y:db  17*8 | PuzzleBlocks14X:db  18*8+1
PuzzleBlocks15Y:db  23*8 | PuzzleBlocks15X:db  18*8+1

PuzzleBlocks16Y:db  09*8 | PuzzleBlocks16X:db  18*8+1
PuzzleBlocks17Y:db  15*8 | PuzzleBlocks17X:db  12*8+1
PuzzleBlocks18Y:db  15*8 | PuzzleBlocks18X:db  24*8+1

PuzzleBlocks19Y:db  04*8 | PuzzleBlocks19X:db  09*8-1
PuzzleBlocks20Y:db  04*8 | PuzzleBlocks20X:db  13*8+1
PuzzleBlocks21Y:db  04*8 | PuzzleBlocks21X:db  18*8+1
PuzzleBlocks22Y:db  10*8 | PuzzleBlocks22X:db  10*8+1

PuzzleBlocksEmpty:db  00*8 | PuzzleBlocksEmptyX:db  00*8+1

PuzzleSwitch1On?: db  000
PuzzleSwitch2On?: db  000
PuzzleSwitch3On?: db  000
PuzzleSwitch4On?: db  000
PuzzleSwitch5On?: db  000
PuzzleSwitch6On?: db  000
PuzzleSwitch7On?: db  000
PuzzleSwitch8On?: db  000
PuzzleSwitch9On?: db  000
PuzzleSwitch10On?:db  000
PuzzleSwitch11On?:db  000
PuzzleSwitch12On?:db  000
PuzzleSwitch13On?:db  000
PuzzleSwitch14On?:db  000

PuzzleSwitch15On?:db  000
PuzzleSwitch16On?:db  000
PuzzleSwitch17On?:db  000
PuzzleSwitch18On?:db  000
PuzzleSwitch19On?:db  000
PuzzleSwitch20On?:db  000
PuzzleSwitch21On?:db  000
PuzzleSwitch22On?:db  000
PuzzleSwitch23On?:db  000
PuzzleSwitch24On?:db  000
PuzzleSwitch25On?:db  000
PuzzleSwitch26On?:db  000
PuzzleSwitch27On?:db  000
PuzzleSwitch28On?:db  000
PuzzleSwitch29On?:db  000
PuzzleSwitch30On?:db  000
PuzzleSwitch31On?:db  000
PuzzleSwitch32On?:db  000

PuzzleSwitch33On?:db  000
PuzzleSwitch34On?:db  000
PuzzleSwitch35On?:db  000
PuzzleSwitch36On?:db  000
PuzzleSwitch37On?:db  000

PuzzleSwitch38On?:db  000
PuzzleSwitch39On?:db  000
PuzzleSwitch40On?:db  000
PuzzleSwitch41On?:db  000
PuzzleSwitch42On?:db  000
PuzzleSwitch43On?:db  000
PuzzleSwitch44On?:db  000
PuzzleSwitch45On?:db  000

SnapToPlatform?:  db  0
CheckCollisionObjectPlayer:               ;check collision with player - and handle interaction of player with object. Out: b=255 collision right side of object. b=254 collision left side of object
  xor   a
;  ld    (SnapToPlatForm?),a
  ld    (ix+enemies_and_objects.SnapPlayer?),a

;check player collides with object on the bottom side. This little part is preparing b. THIS CAN BE SPED UP BY SETTING THIS AS A FIXED VARIABLE IN THE OBJECT LIST
  ld    a,(ix+enemies_and_objects.ny)
  add   a,30
  ld    b,a

;check player collides with object on the top side. c= no collision
  ld    a,(ClesY)
  add   a,17
  sub   (ix+enemies_and_objects.y)
  ret   c

;check player collides with object on the bottom side. nc= no collision
  sub   b                             ;b= ny + 30
  ret   nc

;check player collides with object on the bottom side. c= no collision / alternative version of the routine without the prep. part
;  ld    a,(ClesY)
;  sub   a,14
;  sub   (ix+enemies_and_objects.ny)
;  sub   (ix+enemies_and_objects.y)
;  ret   nc  

;check collision on the left side of object. c= no collision
  ld    hl,(ClesX)                    ;hl: x player (165)
  ld    de,06
  add   hl,de
  ld    d,0
  ld    e,(ix+enemies_and_objects.x)  ;de: x object (180)
  sbc   hl,de  
  ret   c

;check player collides with object on the right side. nc= no collision  
  ld    a,(ix+enemies_and_objects.nx)
  add   15
  ld    e,a
  sbc   hl,de  
  ret   nc

;.loop: jp .loop

;At this point there is collision between player and object. Now 4 new checks are made:
;1. check if player hits the bottom part of the object, then snap player to the object on the bottom side
;2. check if player hits the top    part of the object, then snap player to the object on the top    side
;3. check if player hits the right  part of the object, then snap player to the object on the right  side
;4. check if player hits the left   part of the object, then snap player to the object on the left   side
    
;2. check if player hits the top    part of the object, then snap player to the object on the top    side
  ld    a,(ClesY)
  add   a,09
  sub   (ix+enemies_and_objects.y)
  jp    c,.CollisionTopOfObject

;4. check if player hits the left   part of the object, then snap player to the object on the left   side
  ld    hl,(ClesX)                  ;hl: x player (165)
  ld    de,1                       ;exact edge at de=4
  add   hl,de
  ld    d,0
  ld    e,(ix+enemies_and_objects.x);de: x object (180)
  sbc   hl,de  
  jp    c,.CollisionLeftOfObject

;3. check if player hits the right  part of the object, then snap player to the object on the right  side
  ld    hl,(ClesX)                  ;hl: x player (165)
  ld    a,(ix+enemies_and_objects.nx)
  add   4                          ;exact edge at de=7
;  ld    d,0
  ld    e,a
  sbc   hl,de
  jr    nc,.EndCheckOutOfScreenLeft
  ld    hl,0
  .EndCheckOutOfScreenLeft:
    
  ld    e,(ix+enemies_and_objects.x);de: x object (180)
  sbc   hl,de  
  jp    nc,.CollisionRightOfObject

;1. check if player hits the bottom part of the object, then snap player to the object on the bottom side
  ld    a,(ClesY)
;  sub   a,06

;dit was 06, maar we hebben er 1 van gemaakt voor de glass ball als die met 8 pix per frame naar beneden valt
  sub   a,1                         



  jr    c,.skip                     ;if Cles is in the top of the screen we don't really need to check collision with bottom part of object
  sub   (ix+enemies_and_objects.ny)
  jr    c,.skip                     ;if Cles is in the top of the screen we don't really need to check collision with bottom part of object
  sub   (ix+enemies_and_objects.y)
  jp    nc,.CollisionBottomOfObject
  .skip:

  jp    Set_Dying

;  call  Set_Dying
;  jp    .CollisionTopOfObject       ;if none of the sides are detected, player is in the middle of object. Snap on top.

.CollisionRightOfObject:
  ld    a,(ix+enemies_and_objects.x)
  ld    h,0
  ld    l,a
  ld    de,09
  add   hl,de
  ld    e,(ix+enemies_and_objects.nx)
  add   hl,de
  
  ld    b,255                       ;collision right side of object detected (used for the pushing blocks)            
    
  ld    a,(PlayerDead?)
  or    a
  ret   nz
    
  ld    (ClesX),hl
  
  ld    hl,(PlayerSpriteStand)
  ld    de,Climb
  sbc   hl,de
  jp    z,CollisionEnemyPlayer.PlayerIsHit

;	ld		hl,ClimbDown
;	ld		(PlayerSpriteStand),hl
;	ld		hl,ClimbUp
;	ld		(PlayerSpriteStand),hl
;	ld		hl,Climb
;	ld		(PlayerSpriteStand),hl
	
  ;check at height of waiste if player is pushed into a wall on the right side
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
  ld    b,YaddFeetPLayer-4   ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-4  ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  jp    z,Set_Dying
  ret
    
.CollisionLeftOfObject:
  ld    a,(ix+enemies_and_objects.x)
  sub   7

  ld    h,0
  ld    l,a

  ld    b,254                       ;collision leftside of object detected (used for the pushing blocks)            

  ld    a,(PlayerDead?)
  or    a
  ret   nz

  ld    (ClesX),hl                   

  ;check at height of waiste if player is pushed into a wall on the left side
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
  ld    b,YaddFeetPLayer-4   ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+4   ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  jp    z,Set_Dying
  ret

.CollisionTopOfObject:
  ld    a,(JumpSpeed)               ;if vertical JumpSpeed is negative then return. If it's positive then snap to object
  or    a
  ret   m

  ld    a,(PlayerDead?)
  or    a
  jr    nz,.SkipSnapY
    
  ld    a,(ix+enemies_and_objects.y)
  sub   a,17
  ld    (ClesY),a
  .SkipSnapY:

;Don't snap to object if it falls with a very high speed, like the Glass Ball
  ld    a,(ix+enemies_and_objects.v3) ;v3=Vertical Movement
  cp    8
  jr    nz,.NotGlassBallFalling
  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a
  .NotGlassBallFalling:
;/Don't snap to object if it falls with a very high speel, like the Glass Ball
  
  ld    a,1                         ;snap player to this platform
  ld    (SnapToPlatform?),a  
  ld    (ix+enemies_and_objects.SnapPlayer?),a
  
;check if player is jumping. If so, then set standing
	ld		hl,(PlayerSpriteStand)
	ld		de,Jump
	xor   a
	sbc   hl,de
  ret   nz  
  
  
  ld    a,(PlayerFacingRight?)          ;is player facing right ?
  or    a
  jp    z,Set_L_stand
  jp    Set_R_stand

.CollisionBottomOfObject:
  ld    a,(PlayerDead?)
  or    a
  ret   nz

  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)
  add   a,14d
  ld    (ClesY),a
  
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall  

  ;check at height of waiste if player runs into a wall on the left side
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8 ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  call  z,Set_Dying
  ret

PutPlayerspriteSF2Engine:
  ld    a,$05
  di
	out   ($99),a       ;set bits 15-17
	ld    a,14+128
	ei
	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)

PutPlayersprite:
	ld		a,(slot.page12rom)	;all RAM except page 1+2
	out		($a8),a	
  
;put hero sprite character
;  ld    hl,herospritenrTimes32
;	ld		de,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
      ;  ld    a,(herospritenr)
      ;  ld    h,0
      ;  ld    l,a
      ;  add   hl,hl       ;*2
      ;  add   hl,hl       ;*4
      ;  add   hl,hl       ;*8
      ;  add   hl,hl       ;*16
      ;  add   hl,hl       ;*32
;  add   hl,de
;	ld		a,1
;	call	SetVdp_Write

  standchar:	equ	$+1
	ld		hl,PlayerSpriteData_Char_RightStand  ;sprite character in ROM

	ld		a,PlayerSpritesBlock 
  bit   0,l                                   ;if bit 0 of address of character is set, then add 4 blocks to starting blocks
  jr    z,.go
  add   a,4
  .go:
	call	block1234		;set blocks in page 1/2
  
  ;if player invulnerable, display empty sprite even x frames
  ld    a,(PlayerInvulnerable?)
  or    a
  jr    z,.EndCheckPlayerInvulnerable
  dec   a
  ld    (PlayerInvulnerable?),a
  ld    a,(framecounter)
  and   3
  jr    nz,.EndCheckPlayerInvulnerable
  ld    hl,PlayerSpriteData_Char_Empty+2
  .EndCheckPlayerInvulnerable:    

;ALERT, THIS WRITE TO R#14 IS REQUIRED IN THE SF2 ENGINE !!! 

  ;SetVdp_Write address for Sprite Character
	di

;THIS CAN BE REMOVED IF WE ADD THE SELFMODIFYING CALL TO PutPlayerspriteSF2Engine
  ld    a,$05
	out   ($99),a       ;set bits 15-17
	ld    a,14+128
	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)
	ld    a,$80
  nop
;THIS CAN BE REMOVED IF WE ADD THE SELFMODIFYING CALL TO PutPlayerspriteSF2Engine

;Sprite Character table and it's mirror table start at  $17000 and $17800
;Sprite color table and it's mirror table start at      $16c00 and $17400


	out   ($99),a       ;set bits 0-7
  SelfmodifyingCodePlayerCharAddress: equ $+1
	ld    a,$73         ;$73 / $7b (
;  nop
	ld		c,$98         ;port to write to, and replace the nop wait time instruction required
	out   ($99),a       ;set bits 8-14 + write access
      
	call	outix128    ;4 sprites (4 * 32 = 128 bytes)
	ei
;/put hero sprite character

;  exx               ;store hl. hl now points to color data

;put hero sprite color
;  ld    hl,herospritenrTimes16
;	ld		de,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
        ;  ld    a,(herospritenr)
        ;  ld    h,0
        ;  ld    l,a
        ;  add   hl,hl       ;*2
        ;  add   hl,hl       ;*4
        ;  add   hl,hl       ;*8
        ;  add   hl,hl       ;*16
;  add   hl,de
;	ld		a,1
;	call	SetVdp_Write
;  exx               ;recall hl. hl now points to color data

;check if player is left side of screen, if so add 32 bit shift
  exx               ;store hl. hl now points to color data

  ld    a,(CameraX)         ;camera jumps 16 pixels every page, subtract this value from x Cles
  and   %1111 0000  
  add   a,ECbytes                ;Check if player is between x=0 and x=.. in the current screen
  ld    d,0
  ld    e,a
  ld    hl,(ClesX)
  sbc   hl,de               ;take x Cles and subtract the x camera
  ld    a,l
  push  af

  ;SetVdp_Write address for Sprite Color
	di
;  ld    a,$05
;	out   ($99),a       ;set bits 15-17
;	ld    a,14+128
;	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)
	ld    a,$c0
;  nop
	out   ($99),a       ;set bits 0-7
  SelfmodifyingCodePlayerColorAddress: equ $+1
	ld    a,$6d         ;$6d / $75
;  nop
  exx               ;recall hl. hl now points to color data (also replaces the nop wait time instruction required between reads and writes to vram)
	out   ($99),a       ;set bits 8-14 + write access
	
	jp    nc,DontApply32bitShift

ECbytes:  equ 16

Apply32bitShift:      ;if x player - x camera < 16 then apply EC bit shift
  ld    c,128
;  ld    b,64
;  .Player32bitShifLoop:  
;  ld    a,(hl)
;  add   a,c  
;  out   ($98),a
;  inc   hl
;  djnz  .Player32bitShifLoop

  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
  ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | ld a,(hl)|add a,c|out ($98),a|inc hl | 
;even faster would be to mirror all sprites with CE bit in a different block
	ei
	
  ;after the color data there are 2 bytes for the top and bottom offset of the sprites
  ld    a,(hl)
  ld    (.selfmodifyingcode_x_offset_hero_top_LeftSide),a  
  inc   hl
  ld    a,(hl)
  ld    (.selfmodifyingcode_x_offset_hero_bottom_LeftSide),a  

  .spriteattributetable:
  ld    a,(ClesY)
  sub   a,16
  ld    b,a
  add   a,16
  ld    c,a

  pop   af                  ;Cles x and subtract the x camera
  add   a,ECbytes+32             ;adjust for the correction made earlier and add 32 bit shift added to sprite x

  ld    de,3
  .SelfmodyfyingSpataddressPlayer:  equ $+1
  ld    hl,spat+herospritenrTimes2 ;4          
  ld    (hl),b              ;y sprite 22
  inc   hl                  
  .selfmodifyingcode_x_offset_hero_top_LeftSide: equ $+1
  add   a,0
  ld    (hl),a              ;x sprite 22
  inc   hl
  ld    (hl),b              ;y sprite 23      
  inc   hl 
  ld    (hl),a              ;x sprite 23
  inc   hl
  ld    (hl),c              ;y sprite 24  
  inc   hl      
  .selfmodifyingcode_x_offset_hero_bottom_LeftSide: equ $+1
  add   a,0
  ld    (hl),a              ;x sprite 24
  inc   hl
  ld    (hl),c              ;y sprite 25
  inc   hl               
  ld    (hl),a              ;x sprite 25

	ld		a,(slot.ram)	      ;back to full RAM
	out		($a8),a	
  ret

DontApply32bitShift:        ;if x player - x camera > 16 then don't apply EC bit shift
  ;Check Player Hit. If player is hit then show player alternating colors red + white
;  ld    a,(PlayerInvulnerable?)
;  or    a
;  jr    z,.EndCheckPlayerHit
  
;  ld    a,(framecounter)
;  and   3
;  ld    d,14
;  jp    nz,.EndCheckPlayerHit    
;  ld    b,64
;  .PlayerRedColorLoop:  
;  ld    a,d
;  out   ($98),a
;  inc   hl
;  djnz  .PlayerRedColorLoop
;  jp    .end32bitshift
;  .EndCheckPlayerHit:

	call	outix64     ;4 sprites (4 * 16 bytes = 46 bytes)
	ei

  ;after the color data there are 2 bytes for the top and bottom offset of the sprites
  ld    d,(hl)                ;add x to top sprites
  inc   hl                    ;add x to bottom sprites
  ld    e,(hl)                ;add x to bottom sprites
	;Prepare Y player in c (top part of sprite) and b (bottom part of sprite)
  ld    a,(ClesY)
  ld    c,a
  sub   a,16
  ld    b,a
  ;check if player is left side or right side of screen
  ld    a,(ClesX)             
  and   %1000 0000            
  ld    hl,ClesX+1          
  or    (hl)                
  jr    nz,PlayerRightSideOfScreen ;13/8
  
PlayerLeftSideOfScreen:
  pop   af                  ;Cles x and subtract the x camera
  add   a,ECbytes                ;adjust for the correction made earlier

  .SelfmodyfyingSpataddressPlayer:  equ $+1
  ld    hl,spat+herospritenrTimes2 ;4
  ld    (hl),b              ;y sprite 22
  inc   hl                  
  add   a,d
;  cp    30                                      ;check if x<32. If so sprite is out of camera range
;  jr    nc,.RightSideChecked1
;  ld    a,255
;  .RightSideChecked1:
  ld    (hl),a              ;x sprite 22
  inc   hl
  ld    (hl),b              ;y sprite 23      
  inc   hl 
  ld    (hl),a              ;x sprite 23
  inc   hl
  ld    (hl),c              ;y sprite 24  
  inc   hl      
  add   a,e
;  cp    30                                      ;check if x<32. If so sprite is out of camera range
;  jr    nc,.RightSideChecked2
;  ld    a,255
;  .RightSideChecked2:
  ld    (hl),a              ;x sprite 24
  inc   hl
  ld    (hl),c              ;y sprite 25
  inc   hl               

;add a,32

  ld    (hl),a              ;x sprite 25
	ld		a,(slot.ram)	;back to full RAM
	out		($a8),a	
  ret



PlayerRightSideOfScreen:
  pop   af                  ;Cles x and subtract the x camera
  add   a,ECbytes                ;adjust for the correction made earlier

  .SelfmodyfyingSpataddressPlayer:  equ $+1
  ld    hl,spat+herospritenrTimes2 ;4
  ld    (hl),b              ;y sprite 22
  inc   hl                  
  add   a,d
  cp    40                                      ;check if x<32. If so sprite is out of camera range
  jp    nc,.RightSideChecked1
  ld    a,255               ;remove sprite / put sprite out of visible range
  .RightSideChecked1:
  ld    (hl),a              ;x sprite 22
  inc   hl
  ld    (hl),b              ;y sprite 23      
  inc   hl 
  ld    (hl),a              ;x sprite 23
  inc   hl
  ld    (hl),c              ;y sprite 24  
  inc   hl      
  add   a,e
  cp    40                                      ;check if x<32. If so sprite is out of camera range
  jp    nc,.RightSideChecked2
  ld    a,255               ;remove sprite / put sprite out of visible range
  .RightSideChecked2:
  ld    (hl),a              ;x sprite 24
  inc   hl
  ld    (hl),c              ;y sprite 25
  inc   hl               

;sub a,32

  ld    (hl),a              ;x sprite 25
	ld		a,(slot.ram)	;back to full RAM
	out		($a8),a	
  ret

Sf2EngineObjects:
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  cp    2
  ret   nz

	ld		a,(slot.page12rom)	                          ; all RAM except page 1+2
	out		($a8),a	
  ld    a,(movementpatternsblock)
	call	block1234			                                ;at address $4000 / page 1+2
  
  ld    de,enemies_and_objects+(0*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck
  ld    de,enemies_and_objects+(1*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck
  ld    de,enemies_and_objects+(2*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck

	ld		a,(slot.ram)	      ;back to full RAM
	out		($a8),a	
  ret

  .docheck:
  ld    ixl,e
  ld    ixh,d    

  ld    l,(ix+enemies_and_objects.movementpattern)    ;movementpattern
  ld    h,(ix+enemies_and_objects.movementpattern+1)  ;movementpattern
  jp    (hl)

restoreBackgroundObject1:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then restore page 2
  ld    hl,RestoreBackgroundObject1Page2
  jp    z,DoCopy
  dec   a                     ;if current page =1 then restore page 0
  ld    hl,RestoreBackgroundObject1Page0
  jp    z,DoCopy         ;if current page =2 then restore page 1
  ld    hl,RestoreBackgroundObject1Page1
  jp    DoCopy

restoreBackgroundObject2:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then restore page 2
  ld    hl,RestoreBackgroundObject2Page2
  jp    z,DoCopy
  dec   a                     ;if current page =1 then restore page 0
  ld    hl,RestoreBackgroundObject2Page0
  jp    z,DoCopy         ;if current page =2 then restore page 1
  ld    hl,RestoreBackgroundObject2Page1
  jp    DoCopy

restoreBackgroundObject3:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then restore page 2
  ld    hl,RestoreBackgroundObject3Page2
  jp    z,DoCopy
  dec   a                     ;if current page =1 then restore page 0
  ld    hl,RestoreBackgroundObject3Page0
  jp    z,DoCopy         ;if current page =2 then restore page 1
  ld    hl,RestoreBackgroundObject3Page1
  jp    DoCopy

RestoreBackgroundObject1Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject1Page1:
	db    0,0,0,3
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject1Page2:
	db    0,0,0,3
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject2Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject2Page1:
	db    0,0,0,3
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject2Page2:
	db    0,0,0,3
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject3Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject3Page1:
	db    0,0,0,3
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject3Page2:
	db    0,0,0,3
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
	
HugeObjectFrame:  db  -1


moveplayerleftinscreen:       equ 128
blitpage:                     db  0
screenpage:                   db  2
Player1Spritedatablock:       db  ryuspritedatablock

Player1Framelistblock:        db  ryuframelistblock
Player1Frame:                 dw  ryupage0frame000
Player1FramePage:             db  0

Object1y:                     db  000
Object1x:                     db  000

;Object2y:                     db  100
;Object2x:                     db  100

PutSF2Object:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then que page 1 to be restored
  ld    ix,RestoreBackgroundObject1Page1
  jp    z,.startsetupque
  dec   a                     ;if current page =1 then que page 2 to be restored
  ld    ix,RestoreBackgroundObject1Page2
  jp    z,.startsetupque      ;if current page =2 then que page 0 to be restored
  ld    ix,RestoreBackgroundObject1Page0
  .startsetupque:

	ld		a,(slot.page12rom)    ;all RAM except page 1+2
	out		($a8),a	

  ;set framelist in page 2 in rom ($8000 - $bfff)
	ld    a,ryuframelistblock
  call	block34

  ;set framedata in page 1 in rom ($4000 - $7fff)
	ld    a,ryuspritedatablock
  call	block12

  di
  call  GoPutSF2Object
  ei

  ld    a,(movementpatternsblock)
	call	block1234			                                ;at address $4000 / page 1+2  
  ret

PutSF2Object2:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then que page 1 to be restored
  ld    ix,RestoreBackgroundObject2Page1
  jp    z,.startsetupque
  dec   a                     ;if current page =1 then que page 2 to be restored
  ld    ix,RestoreBackgroundObject2Page2
  jp    z,.startsetupque      ;if current page =2 then que page 0 to be restored
  ld    ix,RestoreBackgroundObject2Page0
  .startsetupque:

	ld		a,(slot.page12rom)    ;all RAM except page 1+2
	out		($a8),a	

  ;set framelist in page 2 in rom ($8000 - $bfff)
	ld    a,ryuframelistblock
  call	block34

  ;set framedata in page 1 in rom ($4000 - $7fff)
	ld    a,ryuspritedatablock
  call	block12
	
	ld    a,ryuspritedatablock
  call	block12

  di
  call  GoPutSF2Object
  ei

  ld    a,(movementpatternsblock)
	call	block1234			                                ;at address $4000 / page 1+2  
  ret

PutSF2Object3:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then que page 1 to be restored
  ld    ix,RestoreBackgroundObject3Page1
  jp    z,.startsetupque
  dec   a                     ;if current page =1 then que page 2 to be restored
  ld    ix,RestoreBackgroundObject3Page2
  jp    z,.startsetupque      ;if current page =2 then que page 0 to be restored
  ld    ix,RestoreBackgroundObject3Page0
  .startsetupque:

	ld		a,(slot.page12rom)    ;all RAM except page 1+2
	out		($a8),a	

  ;set framelist in page 2 in rom ($8000 - $bfff)
	ld    a,ryuframelistblock
  call	block34

  ;set framedata in page 1 in rom ($4000 - $7fff)
	ld    a,ryuspritedatablock
  call	block12

  di
  call  GoPutSF2Object
  ei

  ld    a,(movementpatternsblock)
	call	block1234			                                ;at address $4000 / page 1+2  
  ret

;Frameinfo looks like this:

  ;width, height, offset x, offset y
  ;x offset for first line
  
;ryuPage0frame000:
;  db 024h,04Eh,06Ch,036h
;  db 082h
;  db 068h,022h,037h,06Bh,024h
;  db 000h,000h
;  db 000h,000h

  ;lenght ($1f) + increment ($80) first spriteline, source address (base+00000h etc)
;  dw 01F80h,base+00000h
;  dw 01F80h,base+0001Fh
;  dw 01F80h,base+0003Eh
;  dw 01F80h,base+0005Dh



ScreenLimitxRight:  equ 256-10
ScreenLimitxLeft:   equ 10
GoPutSF2Object:
  ld    bc,Object1x
  ld    hl,(Player1Frame)     ;points to object width
  ld    iy,Player1SxB1        ;player collision detection blocks

;screen limit right
  ld    a,(bc)                ;object x
  cp    ScreenLimitxRight
  jp    c,.LimitRight
  ld    a,ScreenLimitxRight
;  ld    (bc),a
  .LimitRight:
;screen limit left
  ld    a,(bc)                ;object x
  cp    ScreenLimitxLeft
  jp    nc,.LimitLeft
  ld    a,ScreenLimitxLeft
;  ld    (bc),a
  .LimitLeft:

  Putprojectile:              ;projectiles use the same routine as Putplayer
  or    a
  jp    p,PutSpriteleftSideOfScreen

PutSpriteRightSideOfScreen:
  ;Set up restore background que player
  ;set width
  ld    a,(hl)                ;object width
  ld    (ix+nx),a             ;set object width to be restored by background
    ;set height
  inc   hl                    ;object height
  ld    a,(hl)
  ld    (ix+ny),a             ;set object height to be restored by background
    ;set sx,dx by adding offset x to object x
  inc   hl                    ;offset x
  ld    e,(hl)                ;offset x
  ld    a,(bc)                ;object x
  sub   a,moveplayerleftinscreen
  add   a,e

  jp    c,putplayer_clipright_totallyoutofscreenright

  ld    (ix+sx),a             ;set sx/dx to restore by background
  ld    (ix+dx),a
    ;set sy,dy by adding offset y to player y
  inc   hl                    ;player y offset
  dec   bc                    ;player y
  ld    a,(bc)
  add   a,(hl)
  ld    d,a
  ld    (ix+sy),a             ;set sy/dy to restore by background
  ld    (ix+dy),a
  ld    (iy+1),a              ;Player1SyB1 (set block 1 sy)
  ;/Set up restore background que player
  inc   hl                    ;player x offset for first line
  inc   bc                    ;player x

  ;clipping check
  ld    a,(bc)                ;player x
  sub   moveplayerleftinscreen
  add   a,e                   ;player x + offset x
  add   a,(ix+nx)
  jp    c,putplayer_clipright
  jp    putplayer_noclip

  
PutSpriteleftSideOfScreen:
  ;Set up restore background que player
    ;set width
  ld    a,(hl)                ;player width
  ld    (ix+nx),a             ;set player width to be restored by background
    ;set height
  inc   hl                    ;player height
  ld    a,(hl)
  ld    (ix+ny),a             ;set player height to be restored by background
    ;set sx,dx by adding offset x to player x
  inc   hl                    ;offset x
  ld    e,(hl)                ;offset x
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  add   a,e
  jr    c,.carry
  xor   a
  .carry:
  ld    (ix+sx),a             ;set sx/dx to restore by background
  ld    (ix+dx),a
    ;set sy,dy by adding offset y to player y
  inc   hl                    ;player y offset
  dec   bc                    ;player y
  ld    a,(bc)
  add   a,(hl)
  ld    d,a
  ld    (ix+sy),a             ;set sy/dy to restore by background
  ld    (ix+dy),a
  ld    (iy+1),a              ;Player1SyB1 (set block 1 sy)
  ;/Set up restore background que player
  inc   hl                    ;player x offset for first line
  inc   bc                    ;player x

  ;clipping check
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  add   a,e                   ;player x + offset x
  jp    nc,putplayer_clipleft
  ;/clipping check

putplayer_noclip:
  ld    a,(bc)                ;player x
  add   a,(hl)                ;add offset x  for first line to destination x
  sub   a,moveplayerleftinscreen
  ld    e,a
  call  SetOffsetBlocksAndAttackpoints
  inc   hl                    ;lenght + increment first spriteline

  ;if screenpage=0 then blit in page 1
  ;if screenpage=1 then blit in page 2
  ;if screenpage=2 then blit in page 0
  ld    a,(screenpage)
  inc   a
  cp    3
  jr    nz,.not3
  xor   a
  .not3:  
  add   a,a

  bit   7,d

  jp    z,.setpage
  inc   a
  .setpage:
  ld    (blitpage),a
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a

  srl   d                     ;write addres is de/2
  rr    e

  set   6,d                   ;write access

dec hl
dec hl


  ld    (spatpointer),sp  
  ld    sp,hl

  ld    a,e
  ld    c,$98
  .loop:
  out   ($99),a               ;set x to write to
  ld    a,d
  out   ($99),a               ;set y to write to

  pop   hl                    ;pop lenght + increment  
  ld    b,h                   ;length
  ld    a,l                   ;increment
  pop   hl                    ;pop source address

  otir
  or    a
  jr    z,.exit

  add   a,e                   ;add increment to x
  ld    e,a                   ;new x
  jr    nc,.loop
  inc   d                     ;0100 0000

  jp    p,.loop

  set   6,d
  res   7,d

  ld    a,(blitpage)
  xor   1
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a
  
  ld    a,e
  jp    .loop

  .exit:
  ld    sp,(spatpointer)
  ret
  
putplayer_clipright_totallyoutofscreenright:
  inc   hl                    ;player y offset
  inc   hl                    ;player x offset for first line
  inc   hl                    ;player x offset for first line
  inc   bc                    ;player x
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  add   a,(hl)                ;add player x offset for first line
  ld    e,a
  jp    SetOffsetBlocksAndAttackpoints
  
putplayer_clipright:
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  add   a,(hl)                ;add player x offset for first line
  ld    e,a
  call  SetOffsetBlocksAndAttackpoints
  inc   hl                    ;lenght + increment first spriteline

  ;if screenpage=0 then blit in page 1
  ;if screenpage=1 then blit in page 2
  ;if screenpage=2 then blit in page 0
  ld    a,(screenpage)
  inc   a
  cp    3
  jr    nz,.not3
  xor   a
  .not3:  
  add   a,a

  bit   7,d

  jp    z,.setpage
  inc   a
  .setpage:
  ld    (blitpage),a
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a

  srl   d                     ;write addres is de/2
  rr    e

  set   6,d                   ;write access

dec hl
dec hl

  ld    (spatpointer),sp  
  ld    sp,hl

  ld    a,e
  ld    c,$98
  .loop:
  out   ($99),a               ;set x to write to
  ld    a,d
  out   ($99),a               ;set y to write to

  pop   hl                    ;pop lenght + increment  
  ld    b,h                   ;length

  ;extra code in case of clipping right
    ;first check if total piece is out of screen right (or x<64)
  bit   6,e                   
  jr    z,.totallyoutofscreenright
  
    ;check if piece is fully within screen
  ld    a,e                   ;x
  or    %1000 0000

  add   a,b
  jr    nc,.endoverflowcheck1  ;nc-> piece is fully within screen
    
  sub   a,b
  neg
  ld    b,a
  .endoverflowcheck1:
  ;/extra code in case of clipping right

  ld    a,l                   ;increment
  pop   hl                    ;pop source address

  otir
  .skipotir:
  or    a
  jr    z,.exit

  add   a,e                   ;add increment to x
  ld    e,a                   ;new x
  jr    nc,.loop
  inc   d                     ;0100 0000

  jp    p,.loop

  set   6,d
  res   7,d

  ld    a,(blitpage)
  xor   1
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a
  
  ld    a,e
  jp    .loop

  .exit:
  ld    sp,(spatpointer)
  ret

.totallyoutofscreenright:
  ld    a,l
  pop   hl
  jp    .skipotir             ;piece is totally out of screen, dont otir


putplayer_clipleft:
  ld    a,(bc)
  add   a,(hl)
  sub   a,moveplayerleftinscreen
  ld    e,a
  jp    nc,.notcarry
  dec   d
  .notcarry:
  call  SetOffsetBlocksAndAttackpoints
  inc   hl                    ;lenght + increment first spriteline

  ;if screenpage=0 then blit in page 1
  ;if screenpage=1 then blit in page 2
  ;if screenpage=2 then blit in page 0
  ld    a,(screenpage)
  inc   a
  cp    3
  jr    nz,.not3
  xor   a
  .not3:  
  add   a,a

  bit   7,d

  jp    z,.setpage
  inc   a
  .setpage:
  ld    (blitpage),a
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a

  srl   d                     ;write addres is de/2
  rr    e

  set   6,d                   ;write access

dec hl
dec hl

  ld    (spatpointer),sp  
  ld    sp,hl

  ld    a,e
  ld    c,$98
  .loop:

  pop   hl                    ;pop lenght + increment  
  ld    b,h                   ;length

  ;check if piece is fully in screen
  bit   6,e                   ;first check if total piece is in screen left (or x<64)
  jr    z,.totallyinscreen    ;z-> piece is fully within screen left

  ;look at current x, add lenght, set new lenght accordingly, and then dont output if piece is totally out of screen
  ld    a,e
  or    %1000 0000
  ld    h,a
  add   a,b
  ld    b,a                   ;set new lenght (this is the part that is in screen)
  dec   a
  jp    m,.totallyoutofscreen

  ;set new write address
  ld    a,h
  neg
  ld    h,a                   ;distance from x to border of screen
  add   a,e
  out   ($99),a               ;set x to write to
  ld    a,d
  adc   a,0

  jp    p,.nopageoverflow

  set   6,a
  res   7,a
  out   ($99),a               ;set y to write to

  ld    a,(blitpage)
  xor   1
  out   ($99),a               ;write page instellen
  ld    a,14+128
  .nopageoverflow:

  out   ($99),a               ;set y to write to

  .gosourceaddress:
  ;set new source address
  ld    a,l                   ;increment
  ex    af,af'                ;store increment
  ld    a,h                   ;distance from x to border of screen

  pop   hl                    ;source address
  add   a,l                   ;add distance from x to border of screen to source address
  ld    l,a
  jr    nc,.noinch
  inc   h
  .noinch:

  ex    af,af'                ;recall stored increment
  otir
  jp    .skipotir

  .totallyoutofscreen:
  ld    a,l
  pop   hl
  jp    .skipotir             ;piece is totally out of screen, dont otir

  .totallyinscreen:
  ld    a,e
  out   ($99),a               ;set x to write to
  ld    a,d
  out   ($99),a               ;set y to write to

  ld    a,l                   ;increment
  pop   hl                    ;pop source address

  otir
  .skipotir:
  or    a                     ;check increment
  jr    z,.exit

  add   a,e                   ;add increment to x
  ld    e,a                   ;new x
  jr    nc,.loop

  inc   d                     ;01xx xxxx

  jp    p,.loop

  set   6,d
  res   7,d

  ld    a,(blitpage)
  xor   1
  out   ($99),a               ;write page instellen
  ld    a,14+128
  out   ($99),a
  
  ld    a,e
  jp    .loop

  .exit:
  ld    sp,(spatpointer)
  ret  














  

SetOffsetBlocksAndAttackpoints:
  Setblock1:
  ld    a,(bc)                ;player x
  or    a
  jp    p,PlayerLeftOfscreenSetBlocksAndattackpoints

PlayerRightOfscreenSetBlocksAndattackpoints:
  ;block 1
  sub   a,moveplayerleftinscreen
  inc   hl                    ;offsetx Block1
  add   a,(hl)
  jp    nc,.notcarry1
  ld    a,252                 ;if Sx Block1 is out of screen right, then set sx Block to 252
  .notcarry1:
  ld    (iy+0),a              ;Sx block 1
  inc   hl                    ;Nx block 1
  ld    a,(hl)
  ld    (iy+2),a              ;Nx block 1
  inc   hl                    ;Ny block 1
  ld    a,(hl)
  ld    (iy+3),a              ;Ny block 1
  add   a,(iy+1)              ;Ny block 1 + Sy block 1
  ld    (iy+5),a              ;Sy block 2

  ;block 2
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  inc   hl                    ;offsetx Block1
  add   a,(hl)
  jp    nc,.notcarry2
  ld    a,252                 ;if Sx Block1 is out of screen right, then
  .notcarry2:
  ld    (iy+4),a              ;Sx block 2
  inc   hl                    ;Nx block 2
  ld    a,(hl)
  ld    (iy+6),a              ;Nx block 2
  ld    a,(ix+ny)             ;player height total (=Ny block 1 + Ny block 2)
  sub   a,(iy+3)
  ld    (iy+7),a              ;Ny block 2

  ;attack point1
  inc   hl                    ;attack point 1 offset x
  ld    a,(hl)
  or    a
  jr    z,.setattackpoint1sx  ;if there is no attack point, then set attackpoint1sx to 0

  ld    a,(bc)                ;player x
  add   a,(hl)
  jp    c,.carry1
  sub   a,moveplayerleftinscreen
  jp    .setattackpoint1sx
  .carry1:
  sub   a,moveplayerleftinscreen
  jp    c,.setattackpoint1sx
  ld    a,254
  .setattackpoint1sx:
  ld    (iy+8),a              ;attack point 1 sx
  inc   hl                    ;attack point 1 offset y
  dec   bc                    ;player y
  ld    a,(bc)                ;player y
  add   a,(hl)
  ld    (iy+9),a              ;attack point 1 sy

  ;attack point2
  inc   hl                    ;attack point 2 offset x
  inc   bc
  ld    a,(bc)                ;player x
  add   a,(hl)
  jp    c,.carry2
  sub   a,moveplayerleftinscreen
  jp    .setattackpoint2sx
  .carry2:
  sub   a,moveplayerleftinscreen
  jp    c,.setattackpoint2sx
  ld    a,254
  .setattackpoint2sx:
  ld    (iy+10),a             ;attack point 2 sx
  inc   hl                    ;attack point 2 offset y
  dec   bc
  ld    a,(bc)                ;player y
  add   a,(hl)
  ld    (iy+11),a             ;attack point 2 sy
  ret

PlayerLeftOfscreenSetBlocksAndattackpoints:
  ;block 1
  sub   a,moveplayerleftinscreen
  inc   hl                    ;offsetx Block1
  add   a,(hl)
  jp    c,.notcarry1
  ld    (iy+0),0              ;Sx block 1
  inc   hl                    ;Nx block 1
  add   a,(hl)
  jp    p,.positive1
  ld    a,1
  jp    .positive1
  .notcarry1:
  ld    (iy+0),a              ;Sx block 1
  inc   hl                    ;Nx block 1
  ld    a,(hl)
  .positive1:
  ld    (iy+2),a              ;Nx block 1
  inc   hl                    ;Ny block 1
  ld    a,(hl)
  ld    (iy+3),a              ;Ny block 1
  add   a,(iy+1)              ;Ny block 1 + Sy block 1
  ld    (iy+5),a              ;Sy block 2

  ;block 2
  ld    a,(bc)                ;player x
  sub   a,moveplayerleftinscreen
  inc   hl                    ;offsetx block 2
  add   a,(hl)
  jp    c,.notcarry2
  ld    (iy+4),0              ;Sx block 2
  inc   hl                    ;Nx block 2
  add   a,(hl)
  jp    p,.positive2
  ld    a,1
  jp    .positive2
  .notcarry2:
  ld    (iy+4),a              ;Sx block 2
  inc   hl                    ;Nx block 2
  ld    a,(hl)
  .positive2:
  ld    (iy+6),a              ;Nx block 2
  ld    a,(ix+ny)             ;player height total (=Ny block 1 + Ny block 2)
  sub   a,(iy+3)
  ld    (iy+7),a              ;Ny block 2

  ;attack point1
  inc   hl                    ;attack point 1 offset x
  ld    a,(hl)
  or    a
  jr    z,.setattackpoint1sx  ;if there is no attack point, then set attackpoint1sx to 0

  ld    a,(bc)                ;player x
  add   a,(hl)
  jp    nc,.notcarry3
  sub   a,moveplayerleftinscreen
  jp    .setattackpoint1sx
  
  .notcarry3:
  sub   a,moveplayerleftinscreen
  jr    z,.set1a
  cp    200
  jp    c,.setattackpoint1sx
  .set1a:
  ld    a,1
  .setattackpoint1sx:
  ld    (iy+8),a              ;attack point 1 sx
  inc   hl                    ;attack point 1 offset y
  dec   bc                    ;player y
  ld    a,(bc)                ;player y
  add   a,(hl)
  ld    (iy+9),a              ;attack point 1 sy

  ;attack point2
  inc   hl                    ;attack point 2 offset x
  inc   bc
  ld    a,(bc)                ;player x
  add   a,(hl)
  sub   a,moveplayerleftinscreen
  jr    z,.set1b
  cp    224
  jr    c,.setattackpoint2sx
.set1b:
  ld    a,1
  .setattackpoint2sx:
  ld    (iy+10),a             ;attack point 2 sx
  inc   hl                    ;attack point 2 offset y
  dec   bc
  ld    a,(bc)                ;player y
  add   a,(hl)
  ld    (iy+11),a             ;attack point 2 sy
  ret
	
base:                         equ   $4000         ;address of heroframes
RyuActions2:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,8,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage0frame000 | db 1 | dw ryupage0frame001 | db 1
  dw ryupage0frame002 | db 1 | dw ryupage0frame003 | db 1
  ds  12

GlassBallAnimationRight:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,8
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,1,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage0frame004 | db 1 | dw ryupage0frame005 | db 1
  dw ryupage0frame006 | db 1 | dw ryupage0frame007 | db 1
  dw ryupage0frame008 | db 1 | dw ryupage0frame009 | db 1
  dw ryupage0frame010 | db 1 | dw ryupage0frame011 | db 1

GlassBallAnimationLeft:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,8
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,1,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage0frame011 | db 1 | dw ryupage0frame010 | db 1
  dw ryupage0frame009 | db 1 | dw ryupage0frame008 | db 1
  dw ryupage0frame007 | db 1 | dw ryupage0frame006 | db 1
  dw ryupage0frame005 | db 1 | dw ryupage0frame004 | db 1

GlassBallAnimationFallingDown:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,2
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,1,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage0frame004 | db 1 | dw ryupage0frame008 | db 1
  ds    18
  
ObjectAnimation:              ;animates, forces writing spriteframe, out: z=animation ended
  ld    ix,RyuActions2.LeftIdleFrame
ObjectAnimationIXgiven:       ;animates, forces writing spriteframe, out: z=animation ended
  ld    iy,Player1Frame
              
;check speed of animation
  ld    a,(ix+3)              ;PxLeftIdleAnimationSpeed+1
  ld    b,a
  ld    a,(ix+2)              ;P1LeftIdleAnimationSpeed+0
  inc   a
  cp    b                     ;overflow check
  jr    nz,.setanimationspeed

  ld    a,(ix+4)              ;P1LeftIdleAnimationSpeed+2
  or    a                     ;should animation speed fluctuate ?
  jp    z,.endcheckfluctuate
  ld    b,a
  neg
  ld    (ix+4),a              ;P1LeftIdleAnimationSpeed+2
  ld    a,(ix+3)              ;PxLeftIdleAnimationSpeed+1
  add   a,b
  ld    (ix+3),a              ;PxLeftIdleAnimationSpeed+1
  .endcheckfluctuate:
  xor   a
  .setanimationspeed:
  ld    (ix+2),a              ;P1LeftIdleAnimationSpeed+0
  jr    nz,.endchangespriteframe
;/check speed of animation

;change/animate sprite
  ld    a,(ix+1)              ;P1LeftIdleFrame+1
  ld    b,a
  ld    a,(ix+0)              ;P1LeftIdleFrame+0
  inc   a
  cp    b                     ;overflow check
  jr    nz,.setstep
  xor   a
  .setstep:
  ld    (ix+0),a              ;P1LeftIdleFrame+0
  .endchangespriteframe:  
;/change/animate sprite  

  ld    a,(ix+0)              ;P1LeftIdleFrame+0
  ld    b,a
  add   a,a
  add   a,b                   ;*3 to fetch frame in table
  ld    b,0
  ld    c,a
  add   ix,bc
  
  ld    a,(ix+7)              ;framepage
  ld    (iy+2),a              ;write to framepage

  ld    a,(ix+5)              ;fetch current Idle frame
  ld    (iy+0),a              ;and write it to PlayerxFrame
  ld    a,(ix+6)
  ld    (iy+1),a

  ld    a,(ix+0)              ;Check if animation ended
  or    (ix+2)
  ret

ExitRight256x216: equ 252 ; 29*8
ExitRight304x216: equ 38*8-3
CheckMapExit:
  ld    a,(ClesY)
  cp    180+8 + 24
  jr    nc,.ExitBottomFound

;  ld    a,(ClesY)
  cp    5
  jr    c,.ExitTopFound

  ld    a,(ClesX)
  or    a
;  jr    z,.PossibleExitLeftFound
  jp    z,.PossibleExitLeftFound

.selfmodifyingcodeMapexitRight:
  ld    hl,ExitRight304x216
  ld    de,(ClesX)
  sbc   hl,de
  ret   nc

  ld    hl,(ClesX)
  ld    de,50*8
  sbc   hl,de
;  jr    c,.ExitRightFound
  jp    c,.ExitRightFound
  jp    .ExitLeftFound  

.ExitBottomFound:
;check if player was climbing stairs left up
  ld    de,ClimbStairsLeftUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairsLeftUp1
  ld    hl,(ClesX)
  ld    de,18
  add   hl,de
  ld    (ClesX),hl
  .EndCheckClimbStairsLeftUp1:

;check if player was climbing stairs right up
  ld    de,ClimbStairsRightUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairsRightUp1
  ld    hl,(ClesX)
  ld    de,-18
  add   hl,de
  ld    (ClesX),hl
  .EndCheckClimbStairsRightUp1:
  
  ld    de,WorldMapDataMapLenght*WorldMapDataWidth
  ld    a,6
  ld    (ClesY),a
  ld    a,0
  ld    (CameraY),a  
  jp    .LoadnextMap
  
.ExitTopFound:  
;check if player was climbing stairs
  ld    de,ClimbStairsLeftUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairs2
  ld    hl,(ClesX)
  ld    de,-19
  add   hl,de
  ld    (ClesX),hl
  .EndCheckClimbStairs2:

;check if player was climbing stairs right up
  ld    de,ClimbStairsRightUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairsRightUp2
  ld    hl,(ClesX)
  ld    de,19
  add   hl,de
  ld    (ClesX),hl
  .EndCheckClimbStairsRightUp2:

  ld    de,-WorldMapDataMapLenght*WorldMapDataWidth
  ld    a,176+8 + 24;  - 60
  ld    (ClesY),a
  ld    a,44
  ld    (CameraY),a  
  jp    .LoadnextMap
  
.ExitRightFound:
;check if player was climbing stairs
  ld    de,ClimbStairsLeftUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairs3
  ld    a,(Clesy)
  add   a,11
  ld    (Clesy),a
  .EndCheckClimbStairs3:
  
  ld    de,WorldMapDataMapLenght
  ld    hl,1
  ld    (ClesX),hl
  xor   a
  ld    (CameraX),a
  jp    .LoadnextMap

.PossibleExitLeftFound:  
  ld    a,(ClesX+1)
  or    a
  ret   nz
  .ExitLeftFound:  
;check if player was climbing stairs
  ld    de,ClimbStairsLeftUp
  ld    hl,(PlayerSpriteStand)
  xor   a
  sbc   hl,de
  jr    nz,.EndCheckClimbStairs4
  ld    a,(Clesy)
  sub   a,11
  ld    (Clesy),a
  .EndCheckClimbStairs4:
    
  ld    de,-WorldMapDataMapLenght
  ld    hl,ExitRight304x216
  ld    (ClesX),hl
  ld    a,63
  ld    (CameraX),a
  jp    .LoadnextMap

.LoadnextMap:
  ld    hl,(WorldMapPointer)
  add   hl,de
  ld    (WorldMapPointer),hl

  pop   hl                  ;pop the call to this routine
  call  CameraEngine304x216.setR18R19R23andPage  
  call  DisableLineint	
  jp    loadGraphics
  
DisableLineint:
  di
  
; set temp ISR
	ld		hl,tempisr2
	ld		de,$38
	ld		bc,6
	ldir

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  
  ld    a,(vdp_0)           ;set ei1
  and   %1110 1111          ;ei1 checks for lineint and vblankint
  ld    (vdp_0),a           ;ei0 (which is default at boot) only checks vblankint
;  di
  out   ($99),a
  ld    a,128
;  ei
  out   ($99),a

  xor   a
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  out   ($99),a

  xor   a
  out   ($99),a
  ld    a,23+128            ;set r#23 height
  out   ($99),a
  ei
  ret

tempisr2:	
	push	af
	in		a,($99)             ;check and acknowledge vblank int (ei0 is set)
	pop		af
	ei	
	ret  


vblankintflag:  db  0
lineintflag:  db  0
InterruptHandler:
  push  af
  
  ld    a,1               ;set s#1
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge line interrupt
  rrca
  jp    c,lineint         ;ScoreboardSplit/BorderMaskingSplit
  
  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge vblank interrupt
  rlca
  jp    c,vblank  ;vblank detected, so jp to that routine
 
  pop   af 
  ei
  ret

;we set horizontal and vertical screen adjust
;we set status register 0
vblank:
  ld    a,(VDP_8)             ;sprites on
  and   %11111101
  ld    (VDP_8),a
  out   ($99),a
  ld    a,8+128
  out   ($99),a

  ld    a,(R18onVblank)       ;horizontal screen adjust
  out   ($99),a
  ld    a,18+128
  out   ($99),a

  ld    a,(R23onVblank)       ;vertical screen adjust
  out   ($99),a
  add   a,lineintheight
  ld    (R19onVblank),a
  ld    a,23+128
  out   ($99),a
  
  ld    a,(SpriteSplitFlag)   ;1= 304x216 engine  0=256x216 SF2 engine
  ld    (SpriteSplitAtY100?),a
  or    a
  ld    a,(R19onVblank)       ;splitline height
  jp    z,.SetSplitLine
  sub   a,94
  .SetSplitLine:
  
  out   ($99),a
  ld    a,19+128
  out   ($99),a

  ld    a,(PageOnNextVblank)  ;set page
  out   ($99),a
  ld    a,2+128
  out   ($99),a

;  xor   a                  ;set s#15 to 0 / Warning. Interrupts should end in Status Register 15=0 (normally)
;  out   ($99),a            ;we don't do this to save time, but it's not a good practise
;  ld    a,15+128           ;we do set to s#15 to 0 when mapExit is found and a new map is loaded
;  out   ($99),a
       
;  ld    a,1                   ;vblank flag gets set
  ld    (vblankintflag),a  

  pop   af 
  ei
  ret

lineintBorderMaskingSplit:
  push  bc
  push  hl
  
;  call  BackdropOrange

  ;Set address to Write to Spat
; ld    a,$05
;	out   ($99),a       ;set bits 15-17
;	ld    a,14+128
;	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)
;	ld    a,$00
  xor   a
	out   ($99),a       ;set bits 0-7
  .SelfmodifyingCodeSpatAddress: equ $+1
	ld    a,$6e         ;$6e /$76 
;  nop
  ld    c,$98         ;port to write to and deal with the nop required wait time 
	out   ($99),a       ;set bits 8-14 + write access

  ;Out bordermasking sprites all 96 pixels lower
  ld    hl,BorderMaskingSpat
  outi | dec hl | in a,($98) | nop | in a,($98) | nop | in a,($98)  ;18 + 7 + 12 + 5 + 12 + 5 + 12 = 69
  outi |    nop | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi | dec hl | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi |    nop | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi | dec hl | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi |    nop | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi | dec hl | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi |    nop | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi | dec hl | in a,($98) | nop | in a,($98) | nop | in a,($98)
  outi  

  ;prepare y bordermasking splitsprites for next frame
  ld    a,(CameraY)
  add   a,95
  ld    (BorderMaskingSpat+00),a | add   a,16
  ld    (BorderMaskingSpat+01),a | add   a,16
  ld    (BorderMaskingSpat+02),a | add   a,16
  ld    (BorderMaskingSpat+03),a | add   a,16
  ld    (BorderMaskingSpat+04),a

;  xor   a                  ;set s#15 to 0 / Warning. Interrupts should end in Status Register 15=0 (normally)
;  out   ($99),a            ;we don't do this to save time, but it's not a good practise
;  ld    a,15+128           ;we do set to s#15 to 0 when mapExit is found and a new map is loaded
;  out   ($99),a

  xor   a                     ;next splitline will be at scoreboard
  ld    (SpriteSplitAtY100?),a

  ld    a,(R19onVblank)       ;splitline height
  out   ($99),a
  ld    a,19+128
  out   ($99),a
  
  pop   hl
  pop   bc
  pop   af 
  ei
  ret  
BorderMaskingSpat:  db  0,0,0,0,0


LineInt:
  ld    a,(SpriteSplitAtY100?)
  or    a
  jp    nz,lineintBorderMaskingSplit

;on the lineint we turn the screen off at the end of the line using polling for HR
;then we switch page
;we set horizontal and vertical adjust
;and we turn screen on again at the end of the line
;and set s#0 again
LineIntAtScoreboard:
;  call  BackdropBlack

  ;screen always gets turned on/off at the END of the line
  ld    a,(VDP_0+1)       ;screen off
  and   %1011 1111
  out   ($99),a
  ld    a,1+128
  out   ($99),a
 ;so after turning off the screen wait till the end of HBLANK, then perform actions

  ld    a,2               ;Set Status register #2
  out   ($99),a
  ld    a,15+128          ;we are about to check for HR
  out   ($99),a
 
.Waitline:                ;wait until end of HBLANK
  in    a,($99)           ;Read Status register #2
  and   %0010 0000        ;bit to check for HBlank detection
  jr    z,.Waitline
  
  ld    a,0*32+31         ;set page 0
  out   ($99),a
  ld    a,2+128
  out   ($99),a

  xor   a                  ;set horizontal screen adjust
  out   ($99),a
  ld    a,18+128
  out   ($99),a

  ld    a,44               ;set vertical screen adjust
  out   ($99),a
  ld    a,23+128
  out   ($99),a

  ld    a,(VDP_8)         ;sprites off
  or    %00000010
  ld    (VDP_8),a
  out   ($99),a
  ld    a,8+128
  out   ($99),a

  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a

  ld    (lineintflag),a   ;lineine flag gets set

  pop   af 
  ei
  ret  

CameraX:          db  0
CameraY:          db  44
CameraSpeed:      db  0
HorizontalOffset: ds  1
;R#18 (register 18) uses bits 3 - 0 for horizontal screen adjust
;MSB  7   6   5   4   3   2   1   0
;R#18 v3  v2  v1  v0  h3  h2  h1  h0
;h can have a value from 0 - 15 and the screen adjusts horizontally according to the table below
;     7   6   5   4   3   2   1   0   15  14  13  12  11  10  9   8

R18ConversionTable: 
db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7
;db 8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7

CameraMoveRightXBoundary: equ 050       ;as soon as the player x>50 and walking right still the camera should start moving right
CameraMoveLeftXBoundary:  equ 234       ;as soon as the player x<304-50 and walking left still the camera should start moving left
CameraEngine:                           ;prepare R18 and R23 to be set on Vblank. Camera movement depends on the Player's position in the screen
  ld    a,(scrollEngine)                ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jp    z,CameraEngine304x216
  
CameraEngine256x216:
  Call  VerticalMovementCamera

.playerfacingRight:
;camera should start moving to the right, when player x>50 and facing right
  ld    a,(PlayerFacingRight?)          ;is player facing right ?
  or    a
  jp    z,.playerfacingLeft

  ld    hl,(ClesX)                      ;is player x>CameraMoveRightXBoundary ?
  ld    de,CameraMoveRightXBoundary
  xor   a 
  sbc   hl,de                           ;hl=playerX - CameraMoveRightXBoundary
  jp    c,.setR18R19R23

  ld    a,(CameraX)                     ;is cameraX > playerX - CameraMoveRightXBoundary ?
  ld    e,a
  sbc   hl,de
  jp    c,.setR18R19R23

  ld    b,1           ;horizontal camera movent
  jp    .movecamera

.playerfacingLeft:
;camera should start moving to the left, when player x<304-50 and facing left
  ld    de,(ClesX)                      ;is player x<CameraMoveLeftXBoundary ?
  ld    hl,CameraMoveLeftXBoundary
  xor   a
  sbc   hl,de                           ;hl=CameraMoveLeftXBoundary - playerX 
  jp    c,.setR18R19R23

  ld    a,(CameraX)  
  sub   64
  neg 
  ld    e,a
  sbc   hl,de
  jp    c,.setR18R19R23
 
  ld    b,-1           ;horizontal camera movent 
;  jp    .movecamera

.movecamera:
  ld    a,(CameraX)
  add   a,b
  jp    m,.negativeValue
  cp    16
  jr    nc,.maxRangeFound
  ld    (CameraX),a
  .negativeValue:
  .maxRangeFound:
 
.setR18R19R23:
  ld    a,(CameraX)
  and   %0000 1111
  ld    d,0
  ld    e,a
  ld    hl,R18ConversionTable
  add   hl,de
  ld    a,(hl)
  ld    (R18onVblank),a

  ld    a,(CameraY)
  ld    (R23onVblank),a

;  add   a,lineintheight
;  ld    (R19onVblank),a
  ret

ShakeScreen?: db 0

VerticalMovementCamera:
  ld    a,(ShakeScreen?)
  or    a
  call  nz,.ShakeScreen
  
;follow y position of player with camera
  ld    a,(Clesy)

  cp    100             ;check if player is in the bottom part of screen  
  ld    c,+1            ;vertical camera movent
  jr    nc,.movecameraY
  cp    080             ;check if player is in the top part of screen  
  ld    c,-1            ;vertical camera movent
  ret   nc

  .movecameraY:
  ld    a,(CameraY)
  add   a,c
  ret   m
  cp    45
  ret   nc
  ld    (CameraY),a
  ret

.ShakeScreen:
  dec   a
  ld    (ShakeScreen?),a

  cp    10
  ld    c,2             ;strenght shake
  jr    c,.StrenghtSet
  cp    20
  ld    c,3             ;strenght shake
  jr    c,.StrenghtSet
  ld    c,4             ;strenght shake

  .StrenghtSet:
  rrca
  ld    a,c
  jr    c,.set
  neg
  .set:
  ld    c,a
  
  ld    a,(CameraY)
  add   a,c
  ret   m
  cp    45
  ret   nc
  ld    (CameraY),a
  ret

CameraEngine304x216:  
  Call  VerticalMovementCamera

.playerfacingRight:
;camera should start moving to the right, when player x>50 and facing right
  ld    a,(PlayerFacingRight?)          ;is player facing right ?
  or    a
  jp    z,.playerfacingLeft

  ld    hl,(ClesX)                      ;is player x>CameraMoveRightXBoundary ?
  ld    de,CameraMoveRightXBoundary
  xor   a 
  sbc   hl,de                           ;hl=playerX - CameraMoveRightXBoundary
  jp    c,.setR18R19R23andPage

  ld    a,(CameraX)                     ;is cameraX > playerX - CameraMoveRightXBoundary ?
  ld    e,a
  sbc   hl,de
  jp    c,.setR18R19R23andPage

;move camera slower if player is close to left side of screen and faster when player is more to the right side of screen 
  ld    e,40
  sbc   hl,de
  ld    b,2           ;horizontal camera movent
  jp    nc,.movecamera
  ld    b,1           ;horizontal camera movent
  jp    .movecamera

.playerfacingLeft:
;camera should start moving to the left, when player x<304-50 and facing left
  ld    de,(ClesX)                      ;is player x<CameraMoveLeftXBoundary ?
  ld    hl,CameraMoveLeftXBoundary
  xor   a
  sbc   hl,de                           ;hl=CameraMoveLeftXBoundary - playerX 
  jp    c,.setR18R19R23andPage

  ld    a,(CameraX)  
  sub   64
  neg 
  ld    e,a
  sbc   hl,de
  jp    c,.setR18R19R23andPage
 
;move camera slower if player is close to right side of screen and faster when player is more to the left side of screen
  ld    e,40
  sbc   hl,de
  ld    b,-2           ;horizontal camera movent
  jp    nc,.movecamera
  ld    b,-1           ;horizontal camera movent 
;  jp    .movecamera

.movecamera:
  ld    a,(CameraX)
  add   a,b
  jp    m,.negativeValue
  cp    64
  jr    nc,.maxRangeFound
  ld    (CameraX),a
  .negativeValue:
  .maxRangeFound:
 
.setR18R19R23andPage:
  ld    a,(CameraX)
  and   %0000 1111
  ld    d,0
  ld    e,a
  ld    hl,R18ConversionTable
  add   hl,de
  ld    a,(hl)  
  ld    (R18onVblank),a
  
  ld    a,(CameraY)
  ld    (R23onVblank),a

;  add   a,lineintheight
;  ld    (R19onVblank),a

  ;set page. page 0=camerax 0-15 page 1=camerax 16-31 page 2=camerax 32-47 page 3=camerax 48-63
  ld    a,(CameraX)
  ld    b,0*32+31           ;x*32+31 (x=page)
  sub   a,16
  jr    c,.SetPageOnNextVblank
  ld    b,1*32+31           ;x*32+31 (x=page)
  sub   a,16
  jr    c,.SetPageOnNextVblank
  ld    b,2*32+31           ;x*32+31 (x=page)
  sub   a,16
  jr    c,.SetPageOnNextVblank
  ld    b,3*32+31           ;x*32+31 (x=page)
 
.SetPageOnNextVblank: 
  ld    a,b
  ld    (PageOnNextVblank),a
  ret


 
  
;*************************************************************
; met $7f, $bf en $ff in $9000 wordt de SCC voorgeschakeld
; ascii8 blokken:
; $5000 -> $6000 -> 
; $7000 -> $6800 -> 
; $9000 -> $7000 -> 
; $b000 -> $7800 -> 
;*************************************************************

;setpage:              ;in a->x*32+31 (x=page)
;  ld    a,b
;  ld    (currentpage),a
;  di
;  out   ($99),a
;  ld    a,2+128
;  ei
;  out   ($99),a
;  ret

block1:
	di
	ld    (memblocks.1),a
	ld    ($5000),a
	ei
	ret

block2:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	ei
	ret

block3:		
	di
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block4:		
	di
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

block12:	
	di
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	ei
	ret

	ld		(memblocks.1),a
	ld		($6000),a

	
	
	

block23:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block34:	
	di
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

	ld		(memblocks.1),a
	ld		($7000),a


block123:	
	di
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	ei
	ret

block234:	
	di
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

block1234:	 
  di
	ld		(memblocks.1),a
	ld		($5000),a
	inc		a
	ld		(memblocks.2),a
	ld		($7000),a
	inc		a
	ld		(memblocks.3),a
	ld		($9000),a
	inc		a
	ld		(memblocks.4),a
	ld		($b000),a
	ei
	ret

	ld		(memblocks.1),a
	ld		($6000),a
	ld		(memblocks.1),a
	ld		($7000),a



SwapSpatColAndCharTable:
	ld		a,(vdp_0+6)     ;check current sprite character table
  cp    %0010 1111      ;spr chr table at $17800 now ?
  ld    hl,$6c00        ;spr color table $16c00
  ld    de,$7400        ;spr color table buffer $17400
	ld		a,%1101 1111    ;spr att table to $16e00    
	ld		b,%0010 1110    ;spr chr table to $17000
  jp    z,.setspritetables
  ld    hl,$7400        ;spr color table $17400
  ld    de,$6c00        ;spr color table buffer $16c00
	ld		a,%1110 1111    ;spr att table to $17600
	ld		b,%0010 1111    ;spr chr table to $17800

.setspritetables:
	di
	ld		(vdp_0+5),a
	out		($99),a		;spr att table to $17600
	ld		a,5+128
	out		($99),a
	ld		a,$02     ;%0000 0010
	ld		(vdp_8+3),a
	out		($99),a
	ld		a,11+128
	out		($99),a
	
	ld		a,b
	ld		(vdp_0+6),a
	out		($99),a		;spr chr table to $17800
	ld		a,6+128
	ei
	out		($99),a

  ld    bc,$200
  ld    (sprcoltableaddress),hl
  add   hl,bc
  ld    (spratttableaddress),hl
  add   hl,bc
  ld    (sprchatableaddress),hl
  ex    de,hl
  ld    (invissprcoltableaddress),hl
  add   hl,bc
  ld    (invisspratttableaddress),hl
  add   hl,bc
  ld    (invissprchatableaddress),hl
  ret

SwapSpatColAndCharTable2:
	ld		a,(vdp_0+6)     ;check current sprite character table
  rrca
	di
  jr    nc,.setspritetablesBuffer

  .setspritetables:
	ld		a,%0010 1110    ;spr chr table to $17000
	ld		(vdp_0+6),a
	out		($99),a		;spr chr table to $17800
	ld		a,6+128
	out		($99),a

	ld		a,%1101 1111    ;spr att table to $16e00    
	ld		(vdp_0+5),a
	out		($99),a		;spr att table to $17600
	ld		a,5+128
  ei
	out		($99),a

.DoubleSelfmodifyingCodePlayerCharAddress: equ $+1
  ld    a,$7b ;-2
  ld    (SelfmodifyingCodePlayerCharAddress),a
.DoubleSelfmodifyingCodePlayerColAddress: equ $+1
  ld    a,$75 ;-1
  ld    (SelfmodifyingCodePlayerColorAddress),a
  ld    a,$76
  ld    (SelfmodifyingCodeSpatAddress),a
  ld    a,$6e
  ld    (lineintBorderMaskingSplit.SelfmodifyingCodeSpatAddress),a

  ld    hl,$7400              ;spr color table buffer $17400
  ld    (invissprcoltableaddress),hl
  ld    hl,$7400+$200         ;spr attr table buffer $17600
  ld    (invisspratttableaddress),hl
  ld    hl,$7400+$400        ;spr char table buffer $17800
  ld    (invissprchatableaddress),hl
  ret

  .setspritetablesBuffer:
	ld		a,%0010 1111    ;spr chr table to $17800
	ld		(vdp_0+6),a
	out		($99),a		;spr chr table to $17800
	ld		a,6+128
	out		($99),a

	ld		a,%1110 1111    ;spr att table to $17600
	ld		(vdp_0+5),a
	out		($99),a		;spr att table to $17600
	ld		a,5+128
  ei
	out		($99),a

.DoubleSelfmodifyingCodePlayerCharAddressMirror: equ $+1
  ld    a,$73 ;-2
  ld    (SelfmodifyingCodePlayerCharAddress),a
.DoubleSelfmodifyingCodePlayerColAddressMirror: equ $+1
  ld    a,$6d ;-1
  ld    (SelfmodifyingCodePlayerColorAddress),a
  ld    a,$6e
  ld    (SelfmodifyingCodeSpatAddress),a
  ld    a,$76
  ld    (lineintBorderMaskingSplit.SelfmodifyingCodeSpatAddress),a

  ld    hl,$6c00              ;spr color table buffer $17400
  ld    (invissprcoltableaddress),hl
  ld    hl,$6c00+$200         ;spr attr table buffer $17600
  ld    (invisspratttableaddress),hl
  ld    hl,$6c00+$400        ;spr char table buffer $17800
  ld    (invissprchatableaddress),hl
  ret

CollisionObjectPlayer:  
  ld    hl,(Clesx)                          ;hl = x player
  ld    bc,20-2-16                          ;reduce this value to reduce the hitbox size (on the left side)
  jp    CollisionEnemyPlayer.ObjectEntry
  
  CollisionEnemyPlayer:
;check if player collides with left side of enemy/object
  ld    hl,(Clesx)                          ;hl = x player
  ld    bc,20-2                             ;reduce this value to reduce the hitbox size (on the left side)

  .ObjectEntry:
  add   hl,bc

  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object

  or    a                                   ;reset flag
  sbc   hl,de
  ret   c

;check if player collides with right side of enemy/object
  ld    c,(ix+enemies_and_objects.nx)       ;width object

ld a,09-4 ;nx + 10                          ;reduce this value to reduce the hitbox size (on the right side)
add a,c
ld c,a

  sbc   hl,bc  
  ret   nc

;check if player collides with top side of enemy/object
  ld    a,(Clesy)                           ;a = y player

.SelfModifyingCodeCollisionSY:  equ $+1
  add   a,07; + 8                            ;increase this value to reduce the hitbox size (on the yop side)
  sub   (ix+enemies_and_objects.y)
  ret   c

;check if player collides with bottom side of enemy/object
  ld    c,(ix+enemies_and_objects.ny)       ;width object

ld e,a ;store a
.SelfModifyingCodeCollisionSYBottom:  equ $+1 ;WE STILL NEED TO ADD THIS!!!!!!!!!!!!!!!!!!!!!!!!!
ld a,20-4 ;ny + 20   ;if this is 20-8 it would be same reduction top as bottom, but at the bottom its better if there is less reduction                         ;reduce this value to reduce the hitbox size (on the bottom side)
add a,c
ld c,a
ld a,e

  sub   a,c
  ret   nc
  
  .PlayerIsHit:
  ld    a,(PlayerInvulnerable?)
  or    a
  ret   nz

  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_BeingHit
  jp    Set_R_BeingHit

;MapData:
;  ds    38 * 27           ;a map is 38 * 27 tiles big  

CheckTileEnemyInHL:  
;get enemy X in tiles
  ld    e,(ix+enemies_and_objects.x)  
  ld    d,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de

;  ld    a,h
;  or    a
;  jp    m,checktile.CheckTileIsOutOfScreenLeft

  add   a,(ix+enemies_and_objects.y)
  jp    checktile.XandYset

CheckTileEnemy:  
;get enemy X in tiles
  ld    l,(ix+enemies_and_objects.x)  
  ld    h,(ix+enemies_and_objects.x+1)      ;x
  add   hl,de

;  ld    a,h
;  or    a
;  jp    m,checktile.CheckTileIsOutOfScreenLeft

  add   a,(ix+enemies_and_objects.y)  
  jp    checktile.XandYset
  
checktile:                  ;in b->add y to check, de->add x to check
;get player X in tiles
  ld    hl,(ClesX)
  add   hl,de

;  ld    a,h
;  or    a
;  jp    m,.CheckTileIsOutOfScreenLeft

  bit   7,h
  jr    nz,.CheckTileIsOutOfScreenLeft

  .EntryOutOfScreenLeft:

  ld    a,(Clesy)
;get player Y in pixels and convert it to tiles
  add   a,b
  .XandYset:

  srl   h
  rr    l                   ;/2
  srl   l                   ;/4
  srl   l                   ;/8

  and   %11111000           ;Clear bits 0-2 (equals 256 - 8)
  rrca                      ;/2
  rrca                      ;/4
  rrca                      ;/8

.selfmodifyingcodeStartingPosMapForCheckTile:
	ld		de,MapData- 000000  ;start 2 rows higher (MapData-80 for normal engine, MapData-68 for SF2 engine)
	add   hl,de
	
.selfmodifyingcodeMapLenght:
	ld		bc,000              ;32+2 for 256x216 and 38+2 tiles for 304x216
;  jr    z,.yset

  ex    de,hl               ;de->x in tiles

;
; Multiply 8-bit value with a 16-bit value (amount of Y tiles * map lenght)
; In: Multiply A with BC
; Out: HL = result
;
.Mult12:
  ld    hl,0
.Mult12_Loop:
;  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd
  add   hl,bc
.Mult12_NoAdd:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd2
  add   hl,bc
.Mult12_NoAdd2:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd3
  add   hl,bc
.Mult12_NoAdd3:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd4
  add   hl,bc
.Mult12_NoAdd4:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd5
  add   hl,bc
.Mult12_NoAdd5:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd6
  add   hl,bc
.Mult12_NoAdd6:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd7
  add   hl,bc
.Mult12_NoAdd7:
  add   hl,hl
  add   a,a
  jr    nc,.Mult12_NoAdd8
  add   hl,bc
.Mult12_NoAdd8:

;  pop   bc                  ;x in tiles
  add   hl,de               ;(amount of Y tiles * map lenght ) + x in tiles
;  jp    .yset
  
;  ld    b,a                 ;b * de
;.setmapwidthy:
;	add		hl,de
;  djnz  .setmapwidthy
;.yset:

  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
	ret

.CheckTileIsOutOfScreenLeft:
  ld    hl,0
  jp    .EntryOutOfScreenLeft


;  xor   a                   ;reset carry
;  dec   a                   ;1 = wall
;  ret

ArrowSpeed:             equ 6
ArrowActive?:           db  0
ArrowY:                 db  100
ArrowX:                 dw  100
ArrowSY:                db  216+16    ;(ix+4)
ArrowSX_RightSide:      db  030       ;(ix+5)
ArrowSX_LeftSide:       db  030+15    ;(ix+6)
ArrowNY:                db  001       ;(ix+7)
ArrowNX:                db  016       ;(ix+8)

FireballSpeed:          equ 3
FireballActive?:        db  0         ;(ix+0)
FireballY:              db  100       ;(ix+1)
FireballX:              dw  100       ;(ix+2)
FireballSY:             db  216+32    ;(ix+4)
FireballSX_RightSide:   db  000       ;(ix+5)
FireballSX_LeftSide:    db  000+10    ;(ix+6)
FireballNY:             db  008       ;(ix+7)
FireballNX:             db  011       ;(ix+8)


HandlePlayerWeapons:
  ld    a,(ArrowActive?)
  or    a
  jp    nz,Arrow2

  ld    a,(FireballActive?)
  or    a
  jp    nz,Fireball
  ret

  Arrow2:
  ld    ix,ArrowActive?
  jp    GoHandlePlayerWeapon  

  Fireball:
  ld    ix,FireballActive?
  ld    b,0
  jp    p,.DirectionFound
  ld    b,22
      
  .DirectionFound:
  ld    a,(framecounter)
  and   7
  cp    4
  ld    a,11
  jr    c,.SxFound
  xor   a
  .SxFound:
  add   a,b
  ld    (FireballSX_RightSide),a
  add   a,10
  ld    (FireballSX_LeftSide),a  
;  jp    GoHandlePlayerWeapon  
  
  GoHandlePlayerWeapon:
  ld    a,(ix+4)          ;sy  
  ld    (CopyPlayerProjectile+sy),a
  ld    a,(ix+7)          ;sy
  ld    (CopyPlayerProjectile+ny),a
  ld    (CleanPlayerProjectile+ny),a
  ld    a,(ix+8)          ;nx
  ld    (CopyPlayerProjectile+nx),a
  ld    (CleanPlayerProjectile+nx),a
  
  ld    l,(ix+2)            ;FireballX
  ld    h,(ix+3)            ;FireballX
  add   a,4
  ld    d,0
  ld    e,a
  add   hl,de  
  ld    a,(ix+1)            ;FireballY
  add   a,16 + 2
  
  call  checktile.XandYset  ;out z=collision found with wall  
  jp    z,.RemoveWeapon
  inc   hl                  ;also check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jp    z,.RemoveWeapon

  ld    iy,CleanPlayerProjectile
  
  ld    a,(ix+2)            ;FireballX
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

  .ObjectOnRightSideOfScreen:
  ld    a,(ix+5)          ;SX right side
  ld    (CopyPlayerProjectile+sx),a  
  ld    a,%0000 0000      ;set copy direction. Copy from left to right
  ld    (iy+copydirection),a
  ld    (CopyPlayerProjectile+copydirection),a
    
  ;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+17         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefoundright

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+17         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefoundright

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+17         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefoundright

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+17         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefoundright

.pagefoundright:
  ld    a,b
  ld    (CopyPlayerProjectile+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+1)            ;FireballY
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerProjectile+dy),a
  
  ld    a,(ix+2)            ;FireballX
  add   a,d  
  ld    (CopyPlayerProjectile+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a

  ld    a,(ix+2)            ;FireballX
  add   a,(ix+0)            ;Weapon active?/ movement speed. move arrow with arrow speed (which is set in ArrowActive?)
  ld    (ix+2),a            ;FireballX

  ld    a,(ix+2)            ;FireballX
  cp    10
  jr    c,.RemoveWeapon       ;if arrow went through the edge of the map (on the right side) remove the arrow from play

  ld    a,(CopyPlayerProjectile+dx)  ;dont put arrow in screen (on the left side) if it went through the screen on the right side
  cp    20
  ret   c

  ;put arrow
  ld    hl,CopyPlayerProjectile
  call  docopy
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerProjectile+restorebackground?),a   
  ret

  .RemoveWeapon:
  xor   a
  ld    (ix+0),a
  ret
  
  .ObjectOnLeftSideOfScreen:
  ld    a,(ix+6)          ;SX left side
  ld    (CopyPlayerProjectile+sx),a  
  ld    a,%0000 0100      ;set copy direction. Copy from right to left
  ld    (iy+copydirection),a
  ld    (CopyPlayerProjectile+copydirection),a

  ;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+16         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,0               ;clean object from vram data in page 2
  ld    d,-016+16         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,1               ;clean object from vram data in page 3
  ld    d,-032+16         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+16         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jr    z,.pagefoundLeft

.pagefoundLeft:
  ld    a,b
  ld    (CopyPlayerProjectile+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+1)            ;FireballY
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerProjectile+dy),a

  ld    a,(ix+2)            ;FireballX
  add   a,(ix+0)            ;Weapon active?/ movement speed. move arrow with arrow speed (which is set in ArrowActive?)
  ld    (ix+2),a            ;FireballX
  
  add   a,d
  add   a,(ix+8)            ;nx
  ld    (CopyPlayerProjectile+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a

  ld    a,(ix+2)            ;FireballX
  cp    255-10
  jr    nc,.RemoveWeapon         ;if arrow went through the edge of the map (on the right side) remove the arrow from play

  ld    a,(CopyPlayerProjectile+dx)  ;dont put arrow in screen (on the left side) if it went through the screen on the right side
  cp    255-20
  ret   nc
  
  ;put arrow
  ld    hl,CopyPlayerProjectile
  call  docopy
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerProjectile+restorebackground?),a   
  ret


 
  db    0                 ;restorebackground?
CleanPlayerProjectile:                                       ;this is used in the normal engine to clean up any object that has been placed (platform, pushing stone etc)
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    016,000,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$90       ;fast copy -> Copy from left to right
;  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

CopyPlayerProjectile:                                        ;copy any object into screen in the normal engine
  db    030,000,216+16,003   ;sx,--,sy,spage
  db    100,000,100,000   ;dx,--,dy,dpage
  db    016,000,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$98       ;fast copy command -> Copy from left to right
;  db    000,%0000 0100,$98       ;slow transparant copy -> Copy from right to left



playermovementspeed:    db  2
PlayerFacingRight?:     db  1
PlayerInvulnerable?:    db  0

;Rstanding,Lstanding,Rsitting,Lsitting,Rrunning,Lrunning,Jump,ClimbDown,ClimbUp,Climb,RAttack,LAttack,ClimbStairsLeftUp, ClimbStairsRightUp, RPushing, LPushing, RRolling, LRolling, RBeingHit, LBeingHit
;RSitPunch, LSitPunch, Dying, Charging, LBouncingBack, RBouncingBack, LMeditate, RMeditate, LShootArrow, RShootArrow, LSitShootArrow, RSitShootArrow, LShootFireball, RShootFireball
PlayerSpriteStand: dw  Rstanding

PlayerAniCount:     db  0,0
HandlePlayerSprite:
  ld    hl,(PlayerSpriteStand)
  jp    (hl)

LShootFireball:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,38
  xor   a
  sbc   hl,de
  jp    c,Set_L_Stand

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-10
  xor   a
  sbc   hl,de
  jp    nc,Set_L_Stand

;Animate
  ld    hl,LeftShootFireballAnimation
  call  AnimateShootFireball             ;animate

  ld    a,(PlayerAniCount)
  cp    2 * 14
  jp    z,Set_L_Stand  
  cp    2 * 10
  ret   nz

  ld    a,-FireballSpeed
  ld    (FireballActive?),a
;  ld    a,(ClesX)
;  sub   a,26
  ld    hl,(ClesX)
  ld    de,-26
  add   hl,de
  ld    a,l
  bit   0,h
  jr    z,.SetX
  ld    a,255
  .SetX:
  ld    (FireballX),a
  ld    a,(ClesY)
  ld    (FireballY),a
  ret

RShootFireball:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,11
  xor   a
  sbc   hl,de
  jp    c,Set_R_Stand

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-37-12
  xor   a
  sbc   hl,de
  jp    nc,Set_R_Stand

;Animate
  ld    hl,RightShootFireballAnimation
  call  AnimateShootFireball             ;animate

  ld    a,(PlayerAniCount)
  cp    2 * 14
  jp    z,Set_R_Stand  
  cp    2 * 10
  ret   nz

  ld    a,FireballSpeed
  ld    (FireballActive?),a
  ld    a,(ClesX)
  sub   a,20
  jr    nc,.SetX
  xor   a
  .SetX:
  ld    (FireballX),a
  ld    a,(ClesY)
  ld    (FireballY),a
  ret

AnimateShootFireball:
  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jp    AnimateRun.SetPlayerAniCount

LeftShootFireballAnimation:
  dw  PlayerSpriteData_Char_LeftPunch1a 
  dw  PlayerSpriteData_Char_LeftPunch1a 
  dw  PlayerSpriteData_Char_LeftPunch1b 
  dw  PlayerSpriteData_Char_LeftPunch1c 
  dw  PlayerSpriteData_Char_LeftPunch1c
  dw  PlayerSpriteData_Char_LeftPunch1c 
  dw  PlayerSpriteData_Char_LeftPunch1c
  dw  PlayerSpriteData_Char_LeftPunch1d 
  dw  PlayerSpriteData_Char_LeftCharge2
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge5
  
RightShootFireballAnimation:
  dw  PlayerSpriteData_Char_RightPunch1a 
  dw  PlayerSpriteData_Char_RightPunch1a 
  dw  PlayerSpriteData_Char_RightPunch1b 
  dw  PlayerSpriteData_Char_RightPunch1c 
  dw  PlayerSpriteData_Char_RightPunch1c
  dw  PlayerSpriteData_Char_RightPunch1c 
  dw  PlayerSpriteData_Char_RightPunch1c
  dw  PlayerSpriteData_Char_RightPunch1d 
  dw  PlayerSpriteData_Char_RightCharge2
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5
  dw  PlayerSpriteData_Char_RightCharge5

LSitShootArrow:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,38
  xor   a
  sbc   hl,de
  jp    c,Set_L_Sit

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-10
  xor   a
  sbc   hl,de
  jp    nc,Set_L_Sit
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028
  ld    (CopyPlayerWeapon+sx),a

;Animate
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    4
  ld    de,PlayerSpriteData_Char_LeftSitShootArrow1
  ld    h,-13-1               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_LeftSitShootArrow2
  ld    h,-13-3               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_LeftSitShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_LeftSitShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+05         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  add   a,2
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(PlayerAniCount)
  cp    15
  ret   nz

  ld    a,-ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,38
  ld    (ArrowX),a
  ld    a,(ClesY)
  add   a,7
  ld    (ArrowY),a
  jp    Set_L_Sit 

RSitShootArrow:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,11
  xor   a
  sbc   hl,de
  jp    c,Set_R_Sit

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-37
  xor   a
  sbc   hl,de
  jp    nc,Set_R_Sit
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028+2
  ld    (CopyPlayerWeapon+sx),a  

;Animate
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    4
  ld    de,PlayerSpriteData_Char_RightSitShootArrow1
  ld    h,1               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_RightSitShootArrow2
  ld    h,3               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_RightSitShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_RightSitShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+05         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  add   a,2
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(PlayerAniCount)
  cp    15
  ret   nz

  ld    a,ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,11
  ld    (ArrowX),a
  ld    a,(ClesY)
  add   a,7
  ld    (ArrowY),a
  jp    Set_R_Sit  

LShootArrow:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,38
  xor   a
  sbc   hl,de
  jp    c,Set_L_Stand

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-10
  xor   a
  sbc   hl,de
  jp    nc,Set_L_Stand
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028
  ld    (CopyPlayerWeapon+sx),a

;Animate
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    4
  ld    de,PlayerSpriteData_Char_LeftShootArrow1
  ld    h,-13               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_LeftShootArrow2
  ld    h,-13-3               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_LeftShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_LeftShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+05         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  sub   a,4
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(PlayerAniCount)
  cp    15
  ret   nz

  ld    a,-ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,38
  ld    (ArrowX),a
  ld    a,(ClesY)
  inc   a
  ld    (ArrowY),a
  jp    Set_L_Stand  
    
RShootArrow:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,11
  xor   a
  sbc   hl,de
  jp    c,Set_R_Stand

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-37
  xor   a
  sbc   hl,de
  jp    nc,Set_R_Stand

  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028+2
  ld    (CopyPlayerWeapon+sx),a  

;Animate
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    4
  ld    de,PlayerSpriteData_Char_RightShootArrow1
  ld    h,0               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_RightShootArrow2
  ld    h,3               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_RightShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_RightShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+05         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+05         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  sub   a,4
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(PlayerAniCount)
  cp    15
  ret   nz

  ld    a,ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,11
  ld    (ArrowX),a
  ld    a,(ClesY)
  inc   a
  ld    (ArrowY),a
  jp    Set_R_Stand  

CopyPlayerWeapon:                                        ;copy any object into screen in the normal engine
  db    028+2,000,216+19,003   ;sx,--,sy,spage
  db    100,000,100,000   ;dx,--,dy,dpage
  db    003,000,013,000   ;nx,--,ny,--
  db    000,%0000 0000,$98       ;slow transparant copy -> Copy from left to right
;  db    000,%0000 0100,$98       ;slow transparant copy -> Copy from right to left

  db    0                 ;restorebackground?
CleanPlayerWeapon:                                       ;this is used in the normal engine to clean up any object that has been placed (platform, pushing stone etc)
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    003,000,013,000   ;nx,--,ny,--
  db    000,%0000 0000,$90       ;slow copy -> Copy from left to right
;  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

;CleanPlayerWeapon:                                       ;this is used in the normal engine to clean up any object that has been placed (platform, pushing stone etc)
;  db    000,000,000,000   ;sx,--,sy,spage
;  db    000,000,000,000   ;dx,--,dy,dpage
;  db    003+2,000,013,000   ;nx,--,ny,--
;  db    000,%0000 0000,$D0       ;fast copy -> Copy from left to right
;  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

RMeditate:
  ld    hl,RightMeditateAnimation - 2
  call  AnimateMeditating           ;animate

  ld    a,(PlayerAniCount+1)
  cp    121-1
  call  z,Set_R_stand               ;at end of meditate change to L_Stand
  jr    LMeditate.VerticalMovement

LMeditate:
  ld    hl,LeftMeditateAnimation - 2
  call  AnimateMeditating           ;animate

  ld    a,(PlayerAniCount+1)
  cp    121-1
  call  z,Set_L_stand               ;at end of meditate change to L_Stand

  .VerticalMovement:
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  and   31
  ld    e,a
  ld    d,0
  ld    hl,VerticalMovementWhileMeditateTable
  add   hl,de
  ld    a,(clesY)
  add   a,(hl)
  ld    (clesY),a

  ld    b,0
  ld    a,(PlayerAniCount+1)
  cp    10
  jr    nc,.EndCheckSmallerThan6
  ld    b,-1
  .EndCheckSmallerThan6:
  cp    110
  jr    c,.EndCheckBiggerThan26
  ld    b,1
  .EndCheckBiggerThan26:
  ld    a,(clesY)
  add   a,b
  ld    (clesY),a
  
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop after running
  
VerticalMovementWhileMeditateTable:
  db    -0,-1,-0,-1,-1,-0,-1,-0
  db    -0,-1,-0,-0,-0,-1,-0,-0
  db    +0,+0,+1,+0,+0,+0,+1,+0
  db    +0,+1,+0,+1,+1,+0,+1,+0
  
LeftMeditateAnimation:
  dw  PlayerSpriteData_Char_LeftMeditate1 
  dw  PlayerSpriteData_Char_LeftMeditate2 

  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate5 
  dw  PlayerSpriteData_Char_LeftMeditate6
  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate5 
  dw  PlayerSpriteData_Char_LeftMeditate6
  dw  PlayerSpriteData_Char_LeftMeditate3 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate4 
  dw  PlayerSpriteData_Char_LeftMeditate2
  dw  PlayerSpriteData_Char_LeftMeditate2 
  
RightMeditateAnimation:
  dw  PlayerSpriteData_Char_RightMeditate1 
  dw  PlayerSpriteData_Char_RightMeditate2 

  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate6
  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate6
  dw  PlayerSpriteData_Char_RightMeditate3 
  dw  PlayerSpriteData_Char_RightMeditate4 
  dw  PlayerSpriteData_Char_RightMeditate5 
  dw  PlayerSpriteData_Char_RightMeditate2
  dw  PlayerSpriteData_Char_RightMeditate2 

;  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2
RBouncingBack:
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement

  ld    a,0
  ld    (RunningTablePointer),a
  call  MovePlayerLeft.skipFacingDirection
    
  ld    hl,RightRollingAnimation
  call  AnimateRolling             ;animate
  ret

LBouncingBack:
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement

  ld    a,RunningTablePointerRunRightEndValue-4
  ld    (RunningTablePointer),a
  call  MovePlayerRight.skipFacingDirection
    
  ld    hl,LeftRollingAnimation
  call  AnimateRolling             ;animate
  ret

Charging:
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.RCharging

  .LCharging:
  ld    hl,LeftChargeAnimation
  call  AnimateCharging
  ld    a,(PlayerAniCount)
  cp    2 * 11                      ;check 10th frame
  jp    z,Set_L_stand               ;at end of charge change to L_Stand

  call  LSitPunch.SetAttackHitBox     ;set the hitbox coordinates and enable hitbox
  
  ;horizontal movement
  ld    a,(PlayerAniCount)
  cp    2 * 04                      ;start moving after the 3d frame
  ret   c
    
  ld    de,-4                       ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc
  jp    Set_L_stand                 ;on collision change to R_Stand

  .RCharging:
  ld    hl,RightChargeAnimation
  call  AnimateCharging
  ld    a,(PlayerAniCount)
  cp    2 * 11                      ;check 10th frame
  jp    z,Set_R_stand               ;at end of charge change to R_Stand

  call  RSitPunch.SetAttackHitBox     ;set the hitbox coordinates and enable hitbox
  
  ;horizontal movement
  ld    a,(PlayerAniCount)
  cp    2 * 04                      ;start moving after the 3d frame
  ret   c
    
  ld    de,4                        ;horizontal movement speed
  call  DoMovePlayer.EntryForHorizontalMovement
  ret   nc
  jp    Set_R_stand                 ;on collision change to R_Stand

LeftChargeAnimation:
  dw  PlayerSpriteData_Char_LeftCharge1 
  dw  PlayerSpriteData_Char_LeftCharge1 
  dw  PlayerSpriteData_Char_LeftCharge2 
  dw  PlayerSpriteData_Char_LeftCharge3 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge4 
  dw  PlayerSpriteData_Char_LeftCharge5
  dw  PlayerSpriteData_Char_LeftCharge6 
  dw  PlayerSpriteData_Char_LeftCharge7 
  dw  PlayerSpriteData_Char_LeftCharge8 
  dw  PlayerSpriteData_Char_LeftCharge8 
  
RightChargeAnimation:
  dw  PlayerSpriteData_Char_RightCharge1 
  dw  PlayerSpriteData_Char_RightCharge1 
  dw  PlayerSpriteData_Char_RightCharge2 
  dw  PlayerSpriteData_Char_RightCharge3 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge4 
  dw  PlayerSpriteData_Char_RightCharge5 
  dw  PlayerSpriteData_Char_RightCharge6 
  dw  PlayerSpriteData_Char_RightCharge7 
  dw  PlayerSpriteData_Char_RightCharge8 
  dw  PlayerSpriteData_Char_RightCharge8 
  
Dying:
  ld    a,1
  ld    (PlayerDead?),a
  
  ld    a,(framecounter)
  and   %0000 1000
	ld		hl,PlayerSpriteData_Char_Dying1
  jr    z,.Setchar
	ld		hl,PlayerSpriteData_Char_Dying2
  .Setchar:
	ld		(standchar),hl
  ret

LSitPunch:
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
    
  call  .SetAttackHitBox
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,18
  ld    (PlayerAniCount),a
  .EndCheckSpace:
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftSitPunch1
  cp    2
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch2
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch3
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch2
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftSitPunch1
  .setSprite:
	ld		(standchar),hl
	
	cp    21
	ret   nz
  
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_L_Sit
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_SitPunch
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_L_SitPunch
	jp		Set_L_Attack

.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,-14  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 6
  ld    (HitBoxSY),a
  ret
  
RSitPunch:
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  .SetAttackHitBox
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,18
  ld    (PlayerAniCount),a
  .EndCheckSpace:

  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightSitPunch1
  cp    2
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch2
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch3
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch2
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightSitPunch1
  .setSprite:
	ld		(standchar),hl

	cp    21
	ret   nz
  
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_R_Sit
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_SitPunch
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_R_SitPunch
	jp		Set_R_Attack
    
.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,+14  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 6
  ld    (HitBoxSY),a    
  ret

;RunningTablePointerWhenHit:           ds  1       ;this variable is used to decide how player moves when hit
;RunningTablePointer:                  db  18 ;12
;RunningTablePointerCenter:            equ 18 ;12
;RunningTablePointerRightEnd:          equ 38 ;26
;RunningTablePointerRunLeftEndValue:   equ 6
;RunningTablePointerRunRightEndValue:  equ 32 ;20
;RunningTable1:
;       [run  L]                   C                   [run  R]
;  dw    -1,-1,-1,-1,-1,-1,-1,-1,-1,0,+1,+1,+1,+1,+1,+1,+1,+1,+1
;  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2

CheckMoveHorizontallyWhenHitFaceLeft:     
  ld    a,RunningTablePointerRunRightEndValue-2
  ld    (RunningTablePointer),a      
  ld    a,(RunningTablePointerWhenHit)
  sub   5
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl3
  jr    c,CheckMoveHorizontallyWhenHitFaceRight.TableFound
  sub   11
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl2
  jr    c,CheckMoveHorizontallyWhenHitFaceRight.TableFound
  ld    hl,CheckMoveHorizontallyWhenHitFaceRight.MoveTabl1
  jp    CheckMoveHorizontallyWhenHitFaceRight.TableFound
  
CheckMoveHorizontallyWhenHitFaceRight:  
  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a
  ld    a,(RunningTablePointerWhenHit)
  sub   25
  ld    hl,.MoveTabl1
  jr    c,.TableFound
  sub   07
  ld    hl,.MoveTabl2
  jr    c,.TableFound
  ld    hl,.MoveTabl3
  .TableFound:
  
  ld    a,(framecounter)
  and   3
  ld    d,0
  ld    e,a
  add   hl,de
  
  ld    a,(hl)
  or    a
  ret
  .MoveTabl1:   db 0,0,0,1 ;00-24
  .MoveTabl2:   db 0,1,0,1 ;25-36
  .MoveTabl3:   db 1,1,1,1 ;36->

LBeingHit:
  call  CheckMoveHorizontallyWhenHitFaceLeft                         ;out: z-> don't move
  call  nz,MovePlayerRight.skipFacingDirection
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;    
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    24
;  jp    z,Set_L_Stand  
  jp    z,Set_Fall

  ld    hl,PlayerSpriteData_Char_LeftBeingHit1
  cp    08
  jp    c,.SetCharacter
  cp    16
  jp    nc,.SetCharacter
  ld    hl,PlayerSpriteData_Char_LeftBeingHit2
  .SetCharacter:
	ld		(standchar),hl

  ld    a,075                                       ;75 frames invulnerable after being hit
  ld    (PlayerInvulnerable?),a
  ret

RBeingHit:
  call  CheckMoveHorizontallyWhenHitFaceRight                         ;out: z-> don't move
  call  nz,MovePlayerLeft.skipFacingDirection
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;    
	ld		a,(Controls)
  set   0,a
	ld		(Controls),a                                ;force up pressed, to enable/simulate maximum jump height
  call  Jump.VerticalMovement
  
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  cp    24
;  jp    z,Set_R_Stand  
  jp    z,Set_Fall
  
  ld    hl,PlayerSpriteData_Char_RightBeingHit1
  cp    08
  jp    c,.SetCharacter
  cp    16
  jp    nc,.SetCharacter
  ld    hl,PlayerSpriteData_Char_RightBeingHit2
  .SetCharacter:
	ld		(standchar),hl

  ld    a,075                                       ;75 frames invulnerable after being hit
  ld    (PlayerInvulnerable?),a
  ret

RRolling:
  call  .SetAttackHitBox            ;set the hitbox coordinates and enable hitbox

  ld    a,(PlayerAniCount+1)
  inc   a
  cp    100
  jp    z,.endRollingRight          ;end rolling after 100 frames
  ld    (PlayerAniCount+1),a
  cp    4
  jp    c,.Sit                      ;the first 4 frames show sitting pose
  .ContinueRollingWhenCollisionTopFound:

  ld    hl,RightRollingAnimation
  call   AnimateRolling             ;animate

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadderWhileRolling;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit  

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		0,a                         ;cursor up pressed ?
	jr		nz,.UpPressed
    
	ld		a,(Controls)
	bit		1,a                         ;cursor down pressed ?
	jp		nz,.DownPressed             ;check stairs or ladders
	bit		3,a                         ;cursor right pressed ?
	jp		nz,MovePlayerRight
	bit		2,a                         ;cursor left pressed ?
	jp		nz,Set_L_Rolling.SkipPlayerAniCount
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop when not moving horizontally

  .DownPressed:                     ;check stairs or ladders
  call  CheckClimbStairsDown  
  jp    RSitting.CheckLadder

  .UpPressed:                       ;jump and check stairs or ladders

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2         ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z

	call  Set_jump
  call  CheckClimbLadderUp	
	jp    CheckClimbStairsUp    

  .sit:
  ld    de,PlayerSpriteData_Char_RightSitting  
	ld		(standchar),de
  ret

  .endRollingRight:
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.ContinueRollingWhenCollisionTopFound

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.ContinueRollingWhenCollisionTopFound

  jp    Set_R_Stand                 ;end rolling after 100 frames
  
  .Set_Fall:                        ;there is a little bug when falling from an object after rolling where players gets snapped back on top of the object. So move player 2 pixels to the right when falling
  ;if this turns out to be annoying, then add the above check and only inc/dec hl if there is a ceiling at eye height
  ld    hl,(clesx)
  inc   hl    
  inc   hl    
  inc   hl    
  inc   hl    
  ld    (clesx),hl  
  jp    Set_Fall

.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,+05  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 7
  ld    (HitBoxSY),a
  ret  

LRolling:
  call  .SetAttackHitBox            ;set the hitbox coordinates and enable hitbox

  ld    a,(PlayerAniCount+1)
  inc   a
  cp    100
  jp    z,.endRollingLeft           ;end rolling after 100 frames
  ld    (PlayerAniCount+1),a
  cp    4
  jp    c,.Sit                      ;the first 4 frames show sitting pose
  
  .ContinueRollingWhenCollisionTopFound:
  ld    hl,LeftRollingAnimation
  call   AnimateRolling             ;animate

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadderWhileRolling;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit  

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		0,a                         ;cursor up pressed ?
	jr		nz,.UpPressed
    
	ld		a,(Controls)
	bit		1,a                         ;cursor down pressed ?
	jp		nz,.DownPressed             ;check stairs or ladders
	bit		2,a                         ;cursor left pressed ?
	jp		nz,MovePlayerLeft 
	bit		3,a                         ;cursor right pressed ?
	jp		nz,Set_R_Rolling.SkipPlayerAniCount
  jp    EndMovePlayerHorizontally   ;slowly come to a full stop when not moving horizontally

  .DownPressed:                     ;check stairs or ladders
  call  CheckClimbStairsDown  
  jp    RSitting.CheckLadder

  .UpPressed:                       ;jump and check stairs or ladders
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2         ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  ret   z

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z
  
  
  
  
	call  Set_jump
  call  CheckClimbLadderUp	
	jp    CheckClimbStairsUp    


  .sit:
  ld    de,PlayerSpriteData_Char_LeftSitting  
	ld		(standchar),de
  ret

  .endRollingLeft:
  
;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  ld    b,YaddHeadPLayer+1    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.ContinueRollingWhenCollisionTopFound

;  ld    b,YaddHeadPLayer+1          ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile                   ;out z=collision found with wall
;  jr    z,.ContinueRollingWhenCollisionTopFound

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.ContinueRollingWhenCollisionTopFound  
  
  jp    Set_L_Stand                 ;end rolling after 100 frames
  
  .Set_Fall:                        ;there is a little bug when falling from an object after rolling where players gets snapped back on top of the object. So move player 2 pixels to the right when falling
  ;if this turns out to be annoying, then add the above check and only inc/dec hl if there is a ceiling at eye height
  ld    hl,(clesx)
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  dec   hl    
  ld    (clesx),hl  
  jp    Set_Fall

.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,-05  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 7
  ld    (HitBoxSY),a
  ret  
      
LeftRollingAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftRolling1 
  dw  PlayerSpriteData_Char_LeftRolling2 
  dw  PlayerSpriteData_Char_LeftRolling3 
  dw  PlayerSpriteData_Char_LeftRolling4 
  dw  PlayerSpriteData_Char_LeftRolling5 
  dw  PlayerSpriteData_Char_LeftRolling6 
  dw  PlayerSpriteData_Char_LeftRolling7 
  dw  PlayerSpriteData_Char_LeftRolling8 
  dw  PlayerSpriteData_Char_LeftRolling9 
  dw  PlayerSpriteData_Char_LeftRolling10 
  dw  PlayerSpriteData_Char_LeftRolling11 
  dw  PlayerSpriteData_Char_LeftRolling12 
    
RightRollingAnimation:
  dw  PlayerSpriteData_Char_RightRolling1 
  dw  PlayerSpriteData_Char_RightRolling2 
  dw  PlayerSpriteData_Char_RightRolling3 
  dw  PlayerSpriteData_Char_RightRolling4 
  dw  PlayerSpriteData_Char_RightRolling5 
  dw  PlayerSpriteData_Char_RightRolling6 
  dw  PlayerSpriteData_Char_RightRolling7 
  dw  PlayerSpriteData_Char_RightRolling8 
  dw  PlayerSpriteData_Char_RightRolling9 
  dw  PlayerSpriteData_Char_RightRolling10 
  dw  PlayerSpriteData_Char_RightRolling11
  dw  PlayerSpriteData_Char_RightRolling12

RPushing:
;  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall
;  .EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;

;  ld    a,(NewPrContr)
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,.UpPressed

;	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_L_attack3


	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		3,a           ;cursor right pressed ?
;	jp		nz,.PushingLeft
;  jp    Set_L_Stand
	jp		z,Set_R_Stand
  
  .PushingLeft:
  call  MovePlayerRight     ;out: c-> collision detected
;  jp    c,Set_R_stand       ;on collision change to R_Stand
  
;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall  
;  .EndCheckSnapToPlatform:
  
  ld    hl,RightPushingAnimation
  jp    AnimatePushing  

  .DownPressed:
	call	Set_R_sit
  call  CheckClimbStairsDown  
  ret

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp	
	call  CheckClimbStairsUp    
  ret
  
LPushing:
;  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall
;  .EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;

;  ld    a,(NewPrContr)
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,.UpPressed

;	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_L_attack3


	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
;	jp		nz,.PushingLeft
;  jp    Set_L_Stand
	jp		z,Set_L_Stand
  
  .PushingLeft:
  call  MovePlayerLeft      ;out: c-> collision detected
;  jp    c,Set_R_stand       ;on collision change to R_Stand
  
;  ld    a,(SnapToPlatform?)
;  or    a
;  jr    nz,.EndCheckSnapToPlatform
;  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
;  jp    c,Set_Fall  
;  .EndCheckSnapToPlatform:
  
  ld    hl,LeftPushingAnimation
  jp    AnimatePushing  

  .DownPressed:
	call	Set_L_sit
  call  CheckClimbStairsDown  
  ret

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp	
	call  CheckClimbStairsUp    
  ret

LeftPushingAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftPush1 
  dw  PlayerSpriteData_Char_LeftPush2 
  dw  PlayerSpriteData_Char_LeftPush3 
  dw  PlayerSpriteData_Char_LeftPush4 
  dw  PlayerSpriteData_Char_LeftPush5 
  dw  PlayerSpriteData_Char_LeftPush6 
  dw  PlayerSpriteData_Char_LeftPush7 
  dw  PlayerSpriteData_Char_LeftPush8 
  dw  PlayerSpriteData_Char_LeftPush9 
    
RightPushingAnimation:
  dw  PlayerSpriteData_Char_RightPush1 
  dw  PlayerSpriteData_Char_RightPush2 
  dw  PlayerSpriteData_Char_RightPush3 
  dw  PlayerSpriteData_Char_RightPush4 
  dw  PlayerSpriteData_Char_RightPush5 
  dw  PlayerSpriteData_Char_RightPush6 
  dw  PlayerSpriteData_Char_RightPush7 
  dw  PlayerSpriteData_Char_RightPush8 
  dw  PlayerSpriteData_Char_RightPush9 

ClimbStairsRightUp:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.ClimbUp
	bit		1,a           ;cursor down pressed ?
	jp		nz,.ClimbDown
	bit		2,a           ;cursor left pressed ?
	jp		nz,.ClimbDown
	bit		3,a           ;cursor right pressed ?
	jp		nz,.ClimbUp

;  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
;	jp		Set_L_stand
  ret

  .ClimbDown:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    z,.PlayerFacingLeft

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,-6
  add   hl,de
  ld    (ClesX),hl
  
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl  
  .PlayerFacingLeft:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
      
  ld    a,(ClesY)
  inc   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  dec   hl
  ld    (ClesX),hl

  ld    hl,LeftRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing down, if not, then run left
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+13   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ;check if there are still stairs when climbing down, if not, then run left
  ld    b,YaddFeetPlayer+08    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+05   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc
  
  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_L_Run
  

  .ClimbUp:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.PlayerFacingRight

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,+6
  add   hl,de
  ld    (ClesX),hl

	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl  
  .PlayerFacingRight:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  
  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  inc   hl
  ld    (ClesX),hl

  ld    hl,RightRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer+07    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+0   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc
  
  ld    a,RunningTablePointerRunRightEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_R_Run


ClimbStairsLeftUp:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.ClimbUp
	bit		1,a           ;cursor down pressed ?
	jp		nz,.ClimbDown
	bit		2,a           ;cursor left pressed ?
	jp		nz,.ClimbUp
	bit		3,a           ;cursor right pressed ?
	jp		nz,.ClimbDown

;  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
;	jp		Set_L_stand
  ret

  .ClimbDown:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.PlayerFacingRight

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,6
  add   hl,de
  ld    (ClesX),hl
  
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl  
  .PlayerFacingRight:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
      
  ld    a,(ClesY)
  inc   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  inc   hl
  ld    (ClesX),hl

  ld    hl,RightRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing down, if not, then run right
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ;check if there are still stairs when climbing down, if not, then run right
  ld    b,YaddFeetPlayer+08    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+10   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc

  ld    a,RunningTablePointerRunRightEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_R_Run

  .ClimbUp:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  ld    a,(PlayerFacingRight?)
  or    a
  jr    z,.PlayerFacingLeft

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,(ClesX)
  ld    de,-6
  add   hl,de
  ld    (ClesX),hl

	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl  
  .PlayerFacingLeft:
  ;when turning around during stair climbing x offset has to be changed by 6 pixels
  
  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  dec   hl
  ld    (ClesX),hl

  ld    hl,LeftRunAnimation
  call  AnimateRun

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+7   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ;check if there are still stairs when climbing up, if not, then run left
  ld    b,YaddFeetPlayer+07    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+15   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z

  ld    a,(ClesY)           ;return if player is at the bottom of the screen. This means stairs continue into the next map
  cp    180+8 + 24 - 20
  ret   nc

  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_L_Run

AttackRotator:  db 0
LAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  .SetAttackHitBox            ;set the hitbox coordinates and enable hitbox
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,20
  ld    (PlayerAniCount),a
  .EndCheckSpace:
  
  ld    a,(AttackRotator)
  or    a
  jp    z,LAttack2
  dec   a
  jp    z,LAttack3
  dec   a
  jp    z,LAttack2
  jp    LAttack3

.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,-14  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 8
  ld    (HitBoxSY),a
  ret

LAttack4:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch3a
  cp    3
  jr    c,.setSprite
  cp    7
  ld    hl,PlayerSpriteData_Char_LeftPunch3b
  jr    c,.setSprite  
  ld    hl,PlayerSpriteData_Char_LeftPunch3c
  .setSprite:
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_L_Stand

LAttack3:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch2a
  cp    4
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2b
  cp    7
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2b
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2a
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
	
	.CheckInitiateNewAttack:   
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_L_Stand
  xor   a
  ld    (InitiateNewAttack?),a

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_L_SitPunch
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_Attack
	jp		Set_L_Attack

LAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch1a
  cp    03
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1b
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1c
  cp    08
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2c
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1f
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1g
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1h
  cp    24
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz

  jp    LAttack3.CheckInitiateNewAttack

LAttack1:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a

  ld    hl,PlayerSpriteData_Char_LeftHighKick
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_L_Stand

LAttack0:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a

  ld    hl,PlayerSpriteData_Char_LeftLowKick
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_L_Stand

;For now all hitboxes are 16x16, so we only need SX and SY
EnableHitbox?:  db  0
HitBoxSX:       dw  0
HitBoxSY:       db  0
;HitBoxNX:       db  0
;HitBoxNY:       db  0

InitiateNewAttack?:  db  0
RAttack:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  .SetAttackHitBox            ;set the hitbox coordinates and enable hitbox
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)	
	bit		4,a                       ;space pressed ?
	jp		z,.EndCheckSpace
  ld    a,(PlayerAniCount)
  cp    08                        ;if space is pressed during attacking (at least 8 frames in), end the attack and initiate a new attack
  jr    c,.EndCheckSpace
  ld    a,1
  ld    (InitiateNewAttack?),a
  ld    a,20
  ld    (PlayerAniCount),a
  .EndCheckSpace:

;  jp    RAttack3

  ld    a,(AttackRotator)
  or    a
  jp    z,RAttack2
  dec   a
  jp    z,RAttack3
  dec   a
  jp    z,RAttack2
  jp    RAttack3

.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a
  ld    hl,(ClesX)
  ld    de,14  + 19
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(ClesY)
  add   a,17 - 8
  ld    (HitBoxSY),a
  ret

RAttack4:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch3a
  cp    3
  jr    c,.setSprite
  cp    7
  ld    hl,PlayerSpriteData_Char_RightPunch3b
  jr    c,.setSprite  
  ld    hl,PlayerSpriteData_Char_RightPunch3c
  .setSprite:
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_R_Stand

RAttack3:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch2a
  cp    4
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2b
  cp    7
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2b
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2a
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
	
	.CheckInitiateNewAttack:   
  ld    a,(InitiateNewAttack?)
  or    a
  jp    z,Set_R_Stand
  xor   a
  ld    (InitiateNewAttack?),a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,Set_R_SitPunch
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_Attack
	jp		Set_R_Attack

RAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch1a
  cp    03
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1b
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1c
  cp    08
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2c
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1f
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1g
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1h
  cp    24
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz

  jp    RAttack3.CheckInitiateNewAttack

RAttack1:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a

  ld    hl,PlayerSpriteData_Char_RightHighKick
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_R_Stand

RAttack0:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a

  ld    hl,PlayerSpriteData_Char_RightLowKick
	ld		(standchar),hl
	
	cp    15
	ret   nz
  jp    Set_R_Stand

ClimbUpMovementTable:
  db    -0,-0,-0,-1
  db    -1,-1,-2,-2
  db    -2,-3,-3,-3
  db    -3,-2,-1,+0
  db    +0,+1,+2,+2
  db    +0,+0,+0,+0,-100
ClimbUp:
  ld    a,(PlayerAniCount+1)
  ld    d,0
  ld    e,a
  ld    hl,ClimbUpMovementTable
  add   hl,de

  ld    a,(Clesy)
  add   a,(hl)
  ld    (Clesy),a

;animate
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  and   3
  ret   nz
    
  ld    hl,ClimbuPAnimation-2  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 06                    ;05 frame addresses
  jr    z,.EndClimbUp
  ld    (PlayerAniCount),a
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)    
	ld		(standchar),de
  ret	

  .EndClimbUp:   
  ld    a,(PlayerFacingRight?)
  or    a
  jp    nz,Set_R_Stand
  jp    Set_L_Stand
    
ClimbuPAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_Climbing9 
  dw  PlayerSpriteData_Char_Climbing10 
  dw  PlayerSpriteData_Char_Climbing11
  dw  PlayerSpriteData_Char_Climbing12
  dw  PlayerSpriteData_Char_Climbing13

FloorFoundWhileClimbing:    ;floor below player is found, go to R_stand or L_stand
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_stand
  jp    Set_R_stand

Climb:
  call  CheckFloor          ;out: z-> floor, c-> no floor. check if there is floor under the player
  jr    z,FloorFoundWhileClimbing
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		2,a           ;cursor left pressed ?
	jp		nz,.LeftPressed
	bit		3,a           ;cursor right pressed ?
	jp		nz,.RightPressed

 ;check for a ladder when climbing up. If no ladder is found, jump off the top of the ladder
  ld    b,YaddFeetPlayer-20 ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2 ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jp    nz,Set_ClimbUp

  ld    b,0           ;vertical movement
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	jp		z,.EndCheckUpPressed
  dec   b
.EndCheckUpPressed:
	bit		1,a           ;cursor down pressed ?
	jp		z,.EndCheckDownPressed
  inc   b
.EndCheckDownPressed:

  ld    a,b
  or    a
  ret   z

  ld    a,(Clesy)
  add   a,b
  ld    (Clesy),a
  call  AnimateClimbing
  ret

.RightPressed:
  call  Set_Fall
  ld    a,RunningTablePointerRightEnd-2
  ld    (RunningTablePointer),a
  ret

.LeftPressed:
  call  Set_Fall
  xor   a
  ld    (RunningTablePointer),a
  ret

ClimbDown:
  ld    a,(Clesy)
  inc   a
  ld    (Clesy),a

  call  AnimateClimbing
  ret

AnimateClimbing:
;animate
  ld    a,(PlayerAniCount+1)
  inc   a
  ld    (PlayerAniCount+1),a
  cp    32
  jp    z,Set_Climb
  and   7
  ret   nz
    
  ld    hl,ClimbAnimation  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 08                    ;08 frame addresses
  jr    nz,.SetPlayerAniCount
  xor   a
  .SetPlayerAniCount:
  ld    (PlayerAniCount),a
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)    
	ld		(standchar),de
  ret	
   
ClimbAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_Climbing1 
  dw  PlayerSpriteData_Char_Climbing2 
  dw  PlayerSpriteData_Char_Climbing3 
  dw  PlayerSpriteData_Char_Climbing4 
  dw  PlayerSpriteData_Char_Climbing5 
  dw  PlayerSpriteData_Char_Climbing6 
  dw  PlayerSpriteData_Char_Climbing7 
  dw  PlayerSpriteData_Char_Climbing8 

StartingJumpSpeedEqu:     equ -5    ;initial starting jump take off speed
StartingJumpSpeed:        db -5 ;equ -5    ;initial starting jump take off speed
StartingJumpSpeedWhenHit: db -4 ;equ -5    ;initial starting jump take off speed
FallingJumpSpeed:         equ 1
JumpSpeed:                db  0
MaxDownwardFallSpeed:     equ 5
GravityTimer:             equ 4     ;every x frames gravity changes jump speed
YaddHeadPLayer:           equ 2
YaddmiddlePLayer:         equ 17
YaddFeetPlayer:           equ 33
XaddLeftPlayer:           equ 00 - 8
XaddRightPlayer:          equ 15 - 8
KickWhileJumpDuration:    equ 10

MoveHorizontallyWhileJump:
  ld    b,0                 ;horizontal movement

	ld		a,(Controls)
	bit		2,a                 ;cursor left pressed ?
  jp    z,.EndCheckLeftPressed
  dec   b
  .EndCheckLeftPressed:
	bit		3,a           ;cursor right pressed ?
  jp    z,.EndCheckRightPressed
  inc   b
  .EndCheckRightPressed:

  ld    a,b
  or    a
  jp    m,MovePlayerLeft
  jp    z,EndMovePlayerHorizontally
  jp    MovePlayerRight

AnimateWhileJump:
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,.AnimateJumpFacingLeft

.AnimateJumpFacingRight:
  ld    a,(ShootArrowWhileJump?)
  or    a
  jp    nz,ShootArrowWhileJumpRight

  ld    a,(KickWhileJump?)
  dec   a
  jr    nz,.KickWhileJumpRight

  ld    a,(DoubleJumpAvailable?)
  or    a
  jr    z,.RollingJumpRight

  ld    a,(JumpSpeed)
  add   a,2
	ld		hl,PlayerSpriteData_Char_RightJump1
	jp    m,.SetRightJumpAnimationFrame  
  cp    3
	ld		hl,PlayerSpriteData_Char_RightJump2
	jr    c,.SetRightJumpAnimationFrame  
	.LastJumpFrameRight:
	ld		hl,PlayerSpriteData_Char_RightJump3
	.SetRightJumpAnimationFrame:
	ld		(standchar),hl
  ret

.KickWhileJumpRight:
  sub   KickWhileJumpDuration-2                 ;only change kicking pose once, so it doesn't change from highkick to lowkick mid air
  ret   nz

  ld    a,(JumpSpeed)
  or    a
	ld		hl,PlayerSpriteData_Char_RightHighKick
	jp    m,.GoKickRight
	ld		hl,PlayerSpriteData_Char_RightLowKick	
	.GoKickRight:
	ld		(standchar),hl
  ret

.RollingJumpRight:
  ld    a,(JumpSpeed)
  sub   a,5
  jp    p,.LastJumpFrameRight
  
  ld    hl,RightRollingAnimation
  jp    AnimateRolling  
  ret

.AnimateJumpFacingLeft:
  ld    a,(ShootArrowWhileJump?)
  or    a
  jr    nz,ShootArrowWhileJumpLeft

  ld    a,(KickWhileJump?)
  dec   a
  jr    nz,.KickWhileJumpLeft

  ld    a,(DoubleJumpAvailable?)
  or    a
  jr    z,.RollingJumpLeft
  
  ld    a,(JumpSpeed)
  add   a,2
	ld		hl,PlayerSpriteData_Char_LeftJump1
	jp    m,.SetLeftJumpAnimationFrame  
  cp    3
	ld		hl,PlayerSpriteData_Char_LeftJump2
	jr    c,.SetLeftJumpAnimationFrame  
	.LastJumpFrameLeft:
	ld		hl,PlayerSpriteData_Char_LeftJump3
	.SetLeftJumpAnimationFrame:
	ld		(standchar),hl
  ret

.RollingJumpLeft:
  ld    a,(JumpSpeed)
  sub   a,5
  jp    p,.LastJumpFrameLeft

  ld    hl,LeftRollingAnimation
  jp    AnimateRolling  

.KickWhileJumpLeft:
  sub   KickWhileJumpDuration-2                 ;only change kicking pose 1, so it doesn't change from highkick to lowkick mid air
  ret   nz
  
  ld    a,(JumpSpeed)
  or    a
	ld		hl,PlayerSpriteData_Char_LeftHighKick
	jp    m,.GoKickLeft
	ld		hl,PlayerSpriteData_Char_LeftLowKick
	.GoKickLeft:
	ld		(standchar),hl
  ret

ShootArrowWhileJumpLeft:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,38
  xor   a
  sbc   hl,de
  jp    c,.endShootArrowWhileJump

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-10
  xor   a
  sbc   hl,de
  jp    nc,.endShootArrowWhileJump

  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028
  ld    (CopyPlayerWeapon+sx),a  

;Animate
  ld    a,(ShootArrowWhileJump?)
  inc   a
  ld    (ShootArrowWhileJump?),a  
  cp    4
  ld    de,PlayerSpriteData_Char_LeftJumpShootArrow1
  ld    h,-12               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_LeftJumpShootArrow2
  ld    h,-12-3               ;move software sprite h pixels to the Left
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_LeftJumpShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_LeftJumpShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+04         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  sub   a,5
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(ShootArrowWhileJump?)
  cp    15
  ret   nz
  
  ld    a,-ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,38
  ld    (ArrowX),a
  ld    a,(ClesY)
  ld    (ArrowY),a

  .endShootArrowWhileJump:
  xor   a
  ld    (ShootArrowWhileJump?),a
  ret

ShootArrowWhileJumpRight:
  ld    hl,(clesx)            ;check if player is standing on the left edge of the screen, if so, dont shoot
  ld    de,11
  xor   a
  sbc   hl,de
  jp    c,.endShootArrowWhileJump

  ld    hl,(clesx)            ;check if player is standing on the right edge of the screen, if so, dont shoot
  ld    de,304-37
  xor   a
  sbc   hl,de
  jp    nc,.endShootArrowWhileJump
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerWeapon+restorebackground?),a 

  ld    a,028+2
  ld    (CopyPlayerWeapon+sx),a  

;Animate
  ld    a,(ShootArrowWhileJump?)
  inc   a
  ld    (ShootArrowWhileJump?),a  
  cp    4
  ld    de,PlayerSpriteData_Char_RightJumpShootArrow1
  ld    h,1               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    8
  ld    de,PlayerSpriteData_Char_RightJumpShootArrow2
  ld    h,3+1               ;move software sprite h pixels to the right
  jr    c,.SetStandChar
  cp    12
  ld    de,PlayerSpriteData_Char_RightJumpShootArrow3
  jr    c,.SetStandChar
  ld    de,PlayerSpriteData_Char_RightJumpShootArrow4
  .SetStandChar:
	ld		(standchar),de

;set pages to copy to and to clean from
  ld    a,(PageOnNextVblank)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032+04         ;dx offset CopyObject
  ld    e,-016            ;sx offset CleanObject 
  jp    z,.pagefound

  cp    3*32+31           ;x*32+31 (x=page)
  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048+04         ;dx offset CopyObject
  ld    e,+016            ;sx offset CleanObject 
  jp    z,.pagefound

.pagefound:
  ld    iy,CleanPlayerWeapon

  ld    a,b
  ld    (CopyPlayerWeapon+dpage),a  
  ld    (iy+dpage),a
  ld    a,c
  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ClesY)
  sub   a,5
  ld    (iy+sy),a
  ld    (iy+dy),a
  ld    (CopyPlayerWeapon+dy),a

  ld    a,(ClesX)
  add   a,d
  add   a,h
  ld    (CopyPlayerWeapon+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a
  
  ;put weapon
  ld    hl,CopyPlayerWeapon
  call  docopy

  ld    a,(ShootArrowWhileJump?)
  cp    15
  ret   nz
  
  ld    a,ArrowSpeed
  ld    (ArrowActive?),a
  ld    a,(ClesX)
  sub   a,11
  ld    (ArrowX),a
  ld    a,(ClesY)
  ld    (ArrowY),a

  .endShootArrowWhileJump:
  xor   a
  ld    (ShootArrowWhileJump?),a
  ret

CheckSnapToStairsWhileJump:
;check if there are stairs when pressing up, if so climb the stairs.
;[Check ladder going Right UP]
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08-08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  jp    z,.stairsfoundrightup

;  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+08   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  sub   3                   ;check for tilenr 4=stairsleftup
;  ret   nz

  ;now do the same check, but 1 tile to the right
  inc   hl                  ;1 tile to the right
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  sub   4                   ;check for tilenr 4=stairsleftup
  ret   nz

.stairsfoundleftup:  
  pop   af                    ;pop the call  

	call  Set_Stairs_Climb_LeftUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    a,(ClesY)
  and   %1111 1000
  dec   a
  ld    (ClesY),a

  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   z
  
  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret  

.stairsfoundrightup:
  pop   af                    ;pop the call  

	call  Set_Stairs_Climb_RightUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    a,(ClesY)
  and   %1111 1000
  dec   a
  ld    (ClesY),a

  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08-08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   z
  
  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret  

KickWhileJump?:  db  1
ShootArrowWhileJump?:  db  0
Jump:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  call  .HandleKickWhileJump        ;if player kicks in the air, enable hitbox and set hixbox coordinates
  call  AnimateWhileJump
  call  MoveHorizontallyWhileJump
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump
  call  .VerticalMovement
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump

  ld    a,(NewPrContr)
	bit		4,a           ;trig a pressed ?
	jp    nz,.SetKickWhileJump
	bit		5,a           ;trig b pressed ?
	jp    nz,.SetShootArrowWhileJump
	bit		0,a           ;cursor up pressed ?
	jp    nz,.CheckJumpOrClimbLadder  ;while jumping player can double jump can snap to a ladder and start climbing
  ret

.HandleKickWhileJump:
  xor   a
  ld    (EnableHitbox?),a   ;turn hitbox off when not kicking
  ld    a,(KickWhileJump?)
  dec   a
  ret   z
  ld    (KickWhileJump?),a
  ;.SetAttackHitBox:
  ld    a,1
  ld    (EnableHitbox?),a   ;turn hitbox back on if player kicks mid air
  ld    hl,(ClesX)
  ld    a,(PlayerFacingRight?)
  or    a
  ld    de,-12  + 19        ;12 + 19 when kicking right, -12 + 19 when kicking left
  jp    z,.setSX
  ld    de,+12  + 19        ;12 + 19 when kicking right, -12 + 19 when kicking left
  .setSX:
  add   hl,de
  ld    (HitBoxSX),hl
;  ld    a,16
;  ld    (HitBoxNX),a
;  ld    a,12
;  ld    (HitBoxNY),a
  ld    a,(JumpSpeed)
  or    a
  ld    b,26 - 8
	jp    m,.setSY
  cp    3
  jr    c,.setSY
  ld    b,46 - 8
  .setSY:
  ld    a,(ClesY)
  add   a,b                 ;36 - 8 when kicking up, 46 - 8 when kicking down
  ld    (HitBoxSY),a    
  ret

.SetShootArrowWhileJump:
  ld    a,(ShootArrowWhileJump?)
  or    a
  ret   nz                  ;don't shoot if already shooting

  ld    a,1
  ld    (ShootArrowWhileJump?),a
  ret

.SetKickWhileJump:
  ld    a,KickWhileJumpDuration
  ld    (KickWhileJump?),a  
  ret

.VerticalMovement:
  ;as soon as up is released, player stops jumping up. This way the jump height can be controlled
  ld    hl,JumpSpeed
  bit   7,(hl)
  jr    z,.EndCheckUpPressed  ;check if jump speed is positive
  
	ld		a,(Controls)
	rrca                        ;cursor up pressed ?
  jr    c,.EndCheckUpPressed
  
  ld    a,(framecounter)
  rrca
  jr    c,.EndCheckUpPressed

  inc   (hl)                  ;increase JumpSpeed if we don't press up, if JumpSpeed is negative and we don't press up 
  .EndCheckUpPressed:

	ld		a,(PlayerAniCount+1)
	inc   a
	cp    GravityTimer
	jr    nz,.set
  ld    a,(hl)
  inc   a
  cp    MaxDownwardFallSpeed+1
  jr    z,.maxfound
  ld    (hl),a
  .maxfound:

	xor   a
	.set:
	ld		(PlayerAniCount+1),a

  ;unable to jump through the top of the screen
;  ld    a,(Clesy)
;  cp    9
;  jp    nc,.EndCheckTopOfScreen
;  ld    a,(hl)              ;if vertical JumpSpeed is negative then and y<9 then skip vertical movement
;  or    a
;  jp    m,.SkipverticalMovement
;  .EndCheckTopOfScreen:
  ;/unable to jump through the top of the screen
  
  ;move player y
  ld    a,(Clesy)
  add   a,(hl)
  ld    (Clesy),a
  .SkipverticalMovement:

  ld    a,(hl)              ;if vertical JumpSpeed is negative then CheckPlatformAbove. If it's positive then CheckPlatformBelow
  or    a
  jp    m,.CheckPlatformAbove
  ret   z

;XaddLeftPlayer:           equ 00 - 8
;XaddRightPlayer:          equ 15 - 8

;-6      5


  .CheckPlatformBelow:        ;check platform below


  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,+3-8 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToPlatformBelow  

  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFoundUnderLeftFoot1

  inc   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.SnapToPlatformBelow  


;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,-5 ;XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToPlatformBelow

  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFoundUnderRightFoot1

  sub   4                   ;check for tilenr 6=lava
  ret   nz

  .LavaFound:
;  ld    a,(ClesY)           ;don't check lava in top of screen
 ; cp    20
 ; ret   c
  ld    a,(ClesY)           ;don't check lava in bottom of screen
  cp    $c0                
  ret   nc
  jp    Set_Dying


  
;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  dec   a                   ;check for tilenr 2=ladder 
;  jr    z,.LadderFound

;  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  dec   a                   ;check for tilenr 2=ladder 
;  jr    z,.LadderFound
;  scf
;  ret




;while falling a ladder tile is found at player's feet. 
;check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderRightFoot1:               
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-0-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.LadderFoundUnderRightFoot2

  ld    b,YaddFeetPlayer-9  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-0-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow

;check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderRightFoot2:
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-0+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   nz

  ld    b,YaddFeetPlayer-9    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-0+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow
;  ret   z
  ret







;while falling a ladder tile is found at player's feet. 
;check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderLeftFoot1:               
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-8-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.LadderFoundUnderLeftFoot2

  ld    b,YaddFeetPlayer-9  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  ld    de,+3-8-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow

;check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFoundUnderLeftFoot2:
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-8+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   nz

  ld    b,YaddFeetPlayer-9    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  ld    de,+3-8+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

  .SnapToPlatformBelow:
  ld    a,(Clesy)           ;on collision snap y player to platform below and switch standing
  and   %1111 1000
  dec   a
  ld    (Clesy),a

  ld    a,1                 ;reset kicking while jumping
  ld    (KickWhileJump?),a  
  xor   a
  ld    (EnableHitbox?),a 
 
  pop   af                  ;pop the call to .VerticalMovement, this way no further checks are done
 
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_stand       ;on collision change to L_Stand  
  jp    Set_R_stand         ;on collision change to R_Stand    

  .CheckPlatformAbove:    
;check platform above
  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-3  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToCeilingAbove

;  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+3   ;add x to check (x is expressed in pixels)
;  ld    de,-5
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToCeilingAbove

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   nz
 
  .SnapToCeilingAbove:
  ld    a,(Clesy)           ;on collision snap y player to ceiling above
  and   %1111 1000
  add   a,6
  ld    (Clesy),a
  ret

  .CheckJumpOrClimbLadder: 
  call  CheckClimbLadderUp  ;out: PlayerSpriteStand->Climb if ladder found

	ld		hl,(PlayerSpriteStand)
	ld		de,Climb
  xor   a
  sbc   hl,de
  jr    nz,.CheckDoubleJump

	ld		hl,PlayerSpriteData_Char_Climbing1
	ld		(standchar),hl
  jp    Set_Climb_AndResetAniCount
   
  .CheckDoubleJump:
  ld    a,(DoubleJumpAvailable?)
  or    a
  ret   z
  
  xor   a
  ld    (DoubleJumpAvailable?),a
  jp    Set_jump.SkipTurnOnDoubleJump
   
Lsitting:
  xor   a
  ld    (PlayerFacingRight?),a		

	ld		hl,PlayerSpriteData_Char_LeftSitting
	ld		(standchar),hl

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
    
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
	jp		nz,Set_L_SitPunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	

	bit		5,a           ;'M' pressed ?
	jp		nz,Set_L_SitShootArrow

	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,.EndCheckLeftPressed
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_sit
  .EndCheckLeftPressed:
	bit		1,a           ;cursor down pressed ?
	jp		nz,Rsitting.CheckLadder
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,Set_jump
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
;	ld		a,(Controls)
;	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun

	jp		Set_L_stand

Rsitting:
  ld    a,1
  ld    (PlayerFacingRight?),a		

	ld		hl,PlayerSpriteData_Char_RightSitting
	ld		(standchar),hl

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:
  
  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
	jp		nz,Set_R_SitPunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	

	bit		5,a           ;'M' pressed ?
	jp		nz,Set_R_SitShootArrow

	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
	jp		nz,.EndCheckRightPressed
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_sit
  .EndCheckRightPressed:
	bit		1,a           ;cursor down pressed ?
	jp		nz,.CheckLadder
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,Set_jump
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
;	ld		a,(Controls)
;	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun

	jp		Set_R_stand

.CheckLadder:
;check if there is a ladder tile below left foot AND right foot
  ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+6   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jp    z,.ladderfound

  ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-7  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   nz

  .ladderfound:
	call  Set_ClimbDown

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

;after snapping player could be 1 tile too much to theright. Check again for ladder under right foot. If not, then move 1 tile to the left
  ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.NowCheckLeft

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  sbc   hl,de
  ld    (ClesX),hl
  ret

.NowCheckLeft:
;after snapping player could be 1 tile too much to the left. Check again for ladder under left foot. If not, then move 1 tile to the right
  ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   z

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret
 
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
  ex    de,hl                     ;out hl -> sprite character data to out to Vram
  ret	

AnimateMeditating:
  ld    a,(framecounter)          ;animate every 4 frames
  and   07
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jr    AnimateRun.SetPlayerAniCount

AnimateCharging:
  ld    a,(framecounter)          ;animate every 4 frames
  and   1
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  jr    AnimateRun.SetPlayerAniCount
  
AnimateRolling:
;  ld    a,(framecounter)          ;animate every 4 frames
;  and   3
;  ret   z
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 12                    ;12 frame addresses
  jr    nz,AnimateRun.SetPlayerAniCount
  jr    AnimateRun.reset
  
AnimatePushing:
  ld    a,(framecounter)          ;animate every 4 frames
  and   7
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 09                    ;09 frame addresses
  jr    nz,AnimateRun.SetPlayerAniCount
  jr    AnimateRun.reset

AnimateRun:
  ld    a,(framecounter)          ;animate every 4 frames
  and   3
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 10                    ;10 frame addresses
  jr    nz,.SetPlayerAniCount
  .reset:
  xor   a
  .SetPlayerAniCount:
  ld    (PlayerAniCount),a
  
  ld    d,0
  ld    e,a
  add   hl,de
    
  ld    e,(hl)
  inc   hl
  ld    d,(hl)
    
	ld		(standchar),de
;	ld    hl,PlayerSpriteData_Colo_LeftRun1-PlayerSpriteData_Char_LeftRun1
;	add   hl,de
;	ld		(standcol),hl
  ret	
   
LeftRunAnimation:          ;xoffset sprite top, xoffset sprite bottom
  dw  PlayerSpriteData_Char_LeftRun2 
  dw  PlayerSpriteData_Char_LeftRun3 
  dw  PlayerSpriteData_Char_LeftRun4 
  dw  PlayerSpriteData_Char_LeftRun5 
  dw  PlayerSpriteData_Char_LeftRun6 
  dw  PlayerSpriteData_Char_LeftRun7 
  dw  PlayerSpriteData_Char_LeftRun8 
  dw  PlayerSpriteData_Char_LeftRun9 
  dw  PlayerSpriteData_Char_LeftRun10
  dw  PlayerSpriteData_Char_LeftRun1 
    
RightRunAnimation:
  dw  PlayerSpriteData_Char_RightRun7 
  dw  PlayerSpriteData_Char_RightRun8 
  dw  PlayerSpriteData_Char_RightRun9 
  dw  PlayerSpriteData_Char_RightRun10
  dw  PlayerSpriteData_Char_RightRun1 
  dw  PlayerSpriteData_Char_RightRun2 
  dw  PlayerSpriteData_Char_RightRun3 
  dw  PlayerSpriteData_Char_RightRun4 
  dw  PlayerSpriteData_Char_RightRun5 
  dw  PlayerSpriteData_Char_RightRun6 

RunningTablePointerWhenHit:           ds  1       ;this variable is used to decide how player moves when hit
RunningTablePointer:                  db  18 ;12
RunningTablePointerCenter:            equ 18 ;12
RunningTablePointerRightEnd:          equ 38 ;26
RunningTableLenght:                   equ 38 ;26
RunningTablePointerRunLeftEndValue:   equ 6
RunningTablePointerRunRightEndValue:  equ 32 ;20
RunningTable1:
;       [run  L]                   C                   [run  R]
;  dw    -1,-0,-0,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+0,+0,+1
;  dw    -1,-0,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+0,+1
;  dw    -1,-1,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+1,+1
;  dw    -1,-2,-1,-1,-0,-0,-0,-0,-0,0,+0,+0,+0,+0,+0,+1,+1,+2,+1
  dw    -2,-2,-1,-1,-1,-0,-0,-0,-0,0,+0,+0,+0,+0,+1,+1,+1,+2,+2

EndMovePlayerHorizontally:              ;slowly come to a full stop after running
  ld    a,(RunningTablePointer)
  cp    RunningTablePointerCenter
  ret   z
  jp    c,.smaller
  sub   a,2
  jp    DoMovePlayer
.smaller:
  add   a,2
  jp    DoMovePlayer
  ret
  
MovePlayerRight:
  ld    a,1
  ld    (PlayerFacingRight?),a		
  .skipFacingDirection: 
  ld    a,(RunningTablePointer)
  cp    RunningTablePointerRunLeftEndValue
  jr    nc,.go
  ld    a,RunningTablePointerRunLeftEndValue
  .go:
  
  add   a,2
  cp    RunningTablePointerRightEnd                ;check right end of running table
  jr    nz,.SetRunningTablePointer
  ld    a,RunningTablePointerRunRightEndValue
  .SetRunningTablePointer:
  jp    DoMovePlayer

MovePlayerLeft:
  xor   a
  ld    (PlayerFacingRight?),a		
  .skipFacingDirection:
  ld    a,(RunningTablePointer)
  cp    RunningTablePointerRunRightEndValue
  jr    c,.go
  ld    a,RunningTablePointerRunRightEndValue-2
  .go:
 
  ld    a,(RunningTablePointer)
  sub   a,2
  cp    -2                  ;check left end of running table
  jr    nz,.SetRunningTablePointer
  ld    a,RunningTablePointerRunLeftEndValue-2
  .SetRunningTablePointer:
  jp    DoMovePlayer

DoMovePlayer:               ;carry: collision detected
  ld    (RunningTablePointer),a
  ld    d,0
  ld    e,a
  
  ld    hl,RunningTable1
  add   hl,de
  ld    e,(hl)              ;horizontal movement in de
  inc   hl
  ld    d,(hl)              ;horizontal movement in de

  .EntryForHorizontalMovement:
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl
  
  ld    a,e
  or    a
  jp    m,.PlayerMovedLeft
  ret   z

.PlayerMovedRight:
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallRight

;  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallRight

  ;check at height of waiste if player runs into a wall on the right side
  ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallRight
  ;now do the same check, but 2 tiles lower 
	add		hl,bc               ;1 tile lower
	add		hl,bc               ;1 tile lower
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.SnapToWallRight

  ;when player is rolling we don't have to check for collision on eye height
	ld		hl,(PlayerSpriteStand)
	ld		de,RRolling
	xor   a
	sbc   hl,de
	ret   z

  ld    b,YaddHeadPLayer+1  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallRight
  ret

  .SnapToWallRight:
  ld    hl,(ClesX)          ;in case collision with wall is detected after the momevent, snap to the wall
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl
  scf                       ;carry: collision detected
  ret

.PlayerMovedLeft:
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallLeft

;  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallLeft

  ;check at height of waiste if player runs into a wall on the left side
  ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)

  ld    a,(ClesX+1)
  bit   7,a
  ret   nz                  ;no need to perform tilecheck when player is out of screen on the left side

  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallLeft
  ;now do the same check, but 2 tiles lower
	add		hl,bc               ;1 tile lower
	add		hl,bc               ;1 tile lower
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  jr    z,.SnapToWallLeft

  ;when player is rolling we don't have to check for collision on eye height
	ld		hl,(PlayerSpriteStand)
	ld		de,LRolling
	xor   a
	sbc   hl,de
	ret   z

  ld    b,YaddHeadPLayer+1  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallLeft
  ret

  .SnapToWallLeft:
  ld    hl,(ClesX)          ;in case collision with wall is detected after the momevent, snap to the wall
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    de,8
  add   hl,de
  
  ld    (ClesX),hl
  scf                       ;carry: collision detected
  ret

;XaddLeftPlayer:           equ 0
;XaddRightPlayer:          equ 15
;YaddHeadPLayer:           equ 2
;YaddmiddlePLayer:         equ 17
;YaddFeetPlayer:           equ 33

CheckFloor:
;  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  ret   z


  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z

;  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  ret   z
  scf
  ret

CheckFloorInclLadderWhileRolling:
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  
  
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer+2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  

  ld    a,(PlayerFacingRight?)          ;is player facing right ?
  or    a
  ld    de,-6
  jr    z,.ChangeClesX
  ld    de,+6
  .ChangeClesX:
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl

  ld    a,(ClesY)
  add   a,4
  ld    (ClesY),a

  scf
  ret

CheckFloorInclLadder:
;  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  ret   z
;  dec   a                   ;check for tilenr 2=ladder 
;  ret   z  


  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  


  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  
  scf
  ret

  

;  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  ret   z
;  dec   a                   ;check for tilenr 2=ladder 
;  ret   z  
;  scf
;  ret

CheckLavaPoisonSpikes:      ;out z-> lava poison or spikes found
  ld    a,(PlayerInvulnerable?)
  or    a
  ret   nz
  
;  ld    b,YaddFeetPlayer-7    ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer+2 ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  sub   2                   ;check for tilenr 3=lava poison spikes
;  ret   z  


  ld    b,YaddFeetPlayer-7    ;add y to check (y is expressed in pixels)
  ld    de,+3 ;XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   2                   ;check for tilenr 3=lava poison spikes
  ret   z  


  dec   hl                  ;check next tile
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
;  dec   a                   ;1 = wall
  sub   3                   ;check for tilenr 3=lava poison spikes
  ret



;  ld    b,YaddFeetPlayer-7    ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
;  call  checktile           ;out z=collision found with wall
;  sub   2                   ;check for tilenr 3=lava poison spikes
;  ret
  
Rrunning:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;	bit		1,a           ;cursor down pressed ?
;	jp		nz,.Maybe_Set_R_sit
  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?
	jr		nz,.UpPressed
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
	bit		4,a           ;space pressed ?
	jp		nz,Set_R_attack
	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_R_Rolling
	jp		nz,Set_R_ShootArrow
		
	bit		6,a           ;F1 pressed ?
	jp		nz,Set_Charging

	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		3,a           ;cursor right pressed ?
	jp		nz,.MoveAndAnimate
	
  jp    Set_R_stand

.DownPressed:
	call	Set_R_sit
  call  CheckClimbStairsDown  
  ret
  
  .MoveAndAnimate:
  call  MovePlayerRight     ;out: c-> collision detected
  jp    c,Set_R_stand       ;on collision change to R_Stand
  
  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,.EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall  
  .EndCheckSnapToPlatform:

  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit
  
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	call  nz,CheckClimbStairsUp
  
  ld    hl,RightRunAnimation
  jp    AnimateRun

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp	
	call  CheckClimbStairsUp    
  ret

Lrunning:
;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;	bit		1,a           ;cursor down pressed ?
;	jp		nz,.Maybe_Set_R_sit
  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?
	jr		nz,.UpPressed
	bit		4,a           ;space pressed ?
	jp		nz,Set_L_attack
	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_Rolling
	jp		nz,Set_L_ShootArrow
	
	bit		6,a           ;F1 pressed ?
	jp		nz,Set_Charging

	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
	jp		nz,.MoveAndAnimate
;	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun
	
  jp    Set_L_stand

.DownPressed:
	call	Set_L_sit
  call  CheckClimbStairsDown  
  ret
    
  .MoveAndAnimate:
  call  MovePlayerLeft      ;out: c-> collision detected
  jp    c,Set_L_stand       ;on collision change to R_Stand

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,.EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  .EndCheckSnapToPlatform:

  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit

	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
	call  nz,CheckClimbStairsUp
	    
  ld    hl,LeftRunAnimation
  jp    AnimateRun

  .UpPressed:
	call  Set_jump
  call  CheckClimbLadderUp
	call  CheckClimbStairsUp  
  ret

CheckWallSides:                     ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  call  DoMovePlayer.PlayerMovedRight
  jp    DoMovePlayer.PlayerMovedLeft
  
Lstanding:
  ld    a,(NewPrContr)      ;first handle up pressed, since the checks performed are heavy on the cpu
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides
  
  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,.EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  .EndCheckSnapToPlatform:

  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_L_BeingHit
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
	jp		nz,Set_L_attack

	bit		5,a           ;'M' pressed ?
;	jp		nz,.Set_L_MeditateOrRoll
;	jp		nz,Set_L_ShootArrow
	jp		nz,Set_L_ShootFireball

	bit		6,a           ;F1 pressed ?
	jp		nz,Set_Charging
	
	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_run
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_run
	bit		1,a           ;cursor down pressed ?
  ret   z

.DownPressed:  
	call	Set_L_sit
  jp    CheckClimbStairsDown  

.UpPressed:
  call  Set_jump
  call  CheckClimbLadderUp
  jp    CheckClimbStairsUp

.Set_L_MeditateOrRoll:
	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
  jp    nz,Set_L_Rolling
	jp		Set_L_Meditate
	
Rstanding:
  ld    a,(NewPrContr)      ;first handle up pressed, since the checks performed are heavy on the cpu
	bit		0,a                 ;cursor up pressed ?	
	jp		nz,Lstanding.UpPressed	

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  or    a
  call  nz,CheckWallSides

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:

  call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
  jp    z,Set_R_BeingHit
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
	jp		nz,Set_R_attack

	bit		5,a           ;'M' pressed ?
;	jp		nz,.Set_R_MeditateOrRoll
;	jp		nz,Set_R_ShootArrow
	jp		nz,Set_R_ShootFireball
	
	bit		6,a           ;F1 pressed ?
	jp		nz,Set_Charging


	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_run
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_run
	bit		1,a           ;cursor down pressed ?
  ret   z

.DownPressed:
	call	Set_R_sit
  jp    CheckClimbStairsDown  

.Set_R_MeditateOrRoll:
	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
  jp    nz,Set_R_Rolling
	jp		Set_R_Meditate

    
CheckClimbStairsDown:
  call  .StairsGoingLeftUp
  
.StairsGoingRightUp:
;check if there are stairs when pressing down, if so climb the stairs. Check if there is a tile below left foot AND right foot
;[Check stairs going RIGHT UP]
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-04   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  jp    z,.stairsfound1

  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+02   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 6 pixels further to the left. If stairs found, then move player 6 pixels to the right, so we have the same x value for check 1 and 2
  ld    de,6
  add   hl,de
  ld    (ClesX),hl

  .stairsfound1:      
	call  Set_Stairs_Climb_RightUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,-16 + 18
  add   hl,de
  ld    (ClesX),hl

;  ld    a,(Clesy)
;  add   a,18 - 18
;  ld    (Clesy),a
  
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-4   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairsrightup
  ret   nz
  
  ld    hl,(ClesX)          ;sub 8 pixels to player in case we snapped too much to the right
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret


.StairsGoingLeftUp:
;check if there are stairs when pressing down, if so climb the stairs. Check if there is a tile below left foot AND right foot
;[Check stairs going LEFT UP]
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  jp    z,.stairsfound

  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+14   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 6 pixels further to the left. If stairs found, then move player 6 pixels to the right, so we have the same x value for check 1 and 2
  ld    de,6
  add   hl,de
  ld    (ClesX),hl

  .stairsfound:      
	call  Set_Stairs_Climb_LeftUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    de,6
  add   hl,de
  ld    (ClesX),hl
;  ld    a,(Clesy)
;  add   a,0
;  ld    (Clesy),a
  
  ld    b,YaddFeetPlayer+09    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz
  
  ld    hl,(ClesX)          ;sub 8 pixels to player in case we snapped too much to the right
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl
  ret

CheckClimbStairsUp:
  call  .StairsGoingLeftUp

.StairsGoingRightUp:
;check if there are stairs when pressing up, if so climb the stairs. Check if there is a tile above left foot AND right foot
;[Check ladder going Right UP]
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+04   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  jp    z,.stairsfound1

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+12   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   nz

  ld    hl,(ClesX)          ;2nd check checks 8 pixels further than the 1st check. If stairs is found, move player 8 pixels to the right.
  ld    de,8
  add   hl,de
  ld    (ClesX),hl

  .stairsfound1:  
  
	call  Set_Stairs_Climb_RightUp

  ld    a,1
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

;after snapping to an x position, player is either 8 pixels left of stairs, ON the stairs, or 8 pixels right of stairs
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   z
;  jr    z,.snaptostairs
  
  ld    hl,(ClesX)          ;add 8 pixels to player in case we snapped too much to the left
  ld    de,-8
  add   hl,de
  ld    (ClesX),hl

;.snaptostairs:
;  ld    hl,(ClesX)
;  ld    de,6
;  add   hl,de
;  ld    (ClesX),hl
  ret

.StairsGoingLeftUp:
;check if there are stairs when pressing up, if so climb the stairs. Check if there is a tile above left foot AND right foot
;[Check ladder going LEFT UP]
  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  jp    z,.stairsfound

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz

  .stairsfound:  
	call  Set_Stairs_Climb_LeftUp

  xor   a
  ld    (PlayerFacingRight?),a          ;is player facing right ?

  ld    hl,(ClesX)          ;in case stairs are detected, snap to the x position of the stairs
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ld    b,YaddFeetPlayer-01    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+8   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  ret   nz
  
  ld    hl,(ClesX)          ;add 8 pixels to player in case we snapped too much to the left
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret

CheckClimbLadderUp:;
;check if there is a ladder when pressing up, if so climb the ladder. Check if there is a tile above left foot AND right foot
  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+6   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jp    z,.ladderfound

  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-7  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   nz

  .ladderfound:
	call  Set_Climb

  ld    a,(ClesY)
  dec   a
  ld    (ClesY),a

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    a,l
  and   %1111 1000
  ld    l,a
  ld    (ClesX),hl

  ;after snapping player could be 1 tile too much to theright. Check again for ladder under right foot. If not, then move 1 tile to the left
  ld    b,YaddFeetPlayer-20    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.NowCheckLeft

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  sbc   hl,de
  ld    (ClesX),hl
  ret

  .NowCheckLeft:
  ;after snapping player could be 1 tile too much to the left. Check again for ladder under left foot. If not, then move 1 tile to the right
  ld    b,YaddFeetPlayer-20   ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  ret   z

  ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
  ld    de,8
  add   hl,de
  ld    (ClesX),hl
  ret

Set_L_SitShootArrow:
	ld		hl,LSitShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  
  ret

Set_R_SitShootArrow:
	ld		hl,RSitShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  
  ret

Set_L_ShootFireball:
	ld		hl,LShootFireball
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  ret

Set_R_ShootFireball:
	ld		hl,RShootFireball
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  ret
  
Set_L_ShootArrow:
	ld		hl,LShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  
  ret

Set_R_ShootArrow:
	ld		hl,RShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  ret

Set_L_Meditate:
	ld		hl,LMeditate
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_R_Meditate:
	ld		hl,RMeditate
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_L_BouncingBack:
  xor   a
  ld    (EnableHitbox?),a
  
	ld		hl,LBouncingBack
	ld		(PlayerSpriteStand),hl

;  ld    a,1
;  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a
  ret
  
Set_R_BouncingBack:
  xor   a
  ld    (EnableHitbox?),a
  
	ld		hl,RBouncingBack
	ld		(PlayerSpriteStand),hl

;  ld    a,1
;  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a
  ret

Set_Charging:
  ld    a,(PlayerFacingRight?)
  or    a
  jr    nz,.FacingRight

  .FacingLeft:
  ;check at height of waiste if player is near on the right side
  ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer-16  ;add 0 to x to check left side of player for collision (player moved left)

;  ld    a,(ClesX+1)
;  bit   7,a
;  ret   nz                  ;no need to perform tilecheck when player is out of screen on the left side

  call  checktile           ;out z=collision found with wall
  ret   z
  ;now do the same check, but 2 tiles lower
	add		hl,bc               ;1 tile lower
	add		hl,bc               ;1 tile lower
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z
	ld		hl,Charging
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl  
  ret  

  .FacingRight:
  ;check at height of waiste if player is near on the right side
  ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer+16 ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall
  ret   z  
  ;now do the same check, but 2 tiles lower 
	add		hl,bc               ;1 tile lower
	add		hl,bc               ;1 tile lower
  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
  ret   z
  
	ld		hl,Charging
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl  
  ret

Set_Dying:
	ld		hl,Dying
	ld		(PlayerSpriteStand),hl
  ret

Set_R_attack:
  ld    a,(AttackRotator)
  inc   a
  cp    5
  jr    nz,.SetAttackRotator
  xor   a
  .SetAttackRotator:
  ld    (AttackRotator),a

	ld		hl,RAttack
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_L_Attack:
  ld    a,(AttackRotator)
  inc   a
  cp    5
  jr    nz,.SetAttackRotator
  xor   a
  .SetAttackRotator:
  ld    (AttackRotator),a

	ld		hl,LAttack
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_R_Rolling:
  ld    a,CollisionSYRolling
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  .SkipPlayerAniCount:
	ld		hl,RRolling
	ld		(PlayerSpriteStand),hl
  ret

Set_L_Rolling:
  ld    a,CollisionSYRolling
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  .SkipPlayerAniCount:
	ld		hl,LRolling
	ld		(PlayerSpriteStand),hl
  ret

Set_Stairs_Climb_RightUp:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,ClimbStairsRightUp
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ret

Set_Stairs_Climb_LeftUp:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,ClimbStairsLeftUp
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ret

Set_ClimbDown:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,ClimbDown
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  
  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

CollisionSYStanding:  equ 07 + 0
CollisionSYSitting:   equ 07 + 6
CollisionSYRolling:   equ 07 + 10
Set_ClimbUp:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,ClimbUp
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_Climb_AndResetAniCount:
  ld    hl,0 
  ld    (PlayerAniCount),hl
  Set_Climb:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a  
  
	ld		hl,Climb
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a

	ld		hl,PlayerSpriteData_Char_Climbing1
	ld		(standchar),hl	

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  ret

Set_jump:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
  xor   a
  ld    (EnableHitbox?),a
  
  ld    a,1
  ld    (DoubleJumpAvailable?),a

  .SkipTurnOnDoubleJump:  
	ld		hl,Jump
	ld		(PlayerSpriteStand),hl

  ld    hl,0
	ld		(PlayerAniCount),hl
;	ld    a,StartingJumpSpeed
	ld    a,(StartingJumpSpeed)
	ld		(JumpSpeed),a
  ret

Set_Fall: 
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
  xor   a
  ld    (EnableHitbox?),a
      
  ld    a,1
  ld    (DoubleJumpAvailable?),a

	ld		hl,Jump
	ld		(PlayerSpriteStand),hl

  ld    hl,0
	ld		(PlayerAniCount),hl
	ld    a,FallingJumpSpeed
	ld		(JumpSpeed),a
  ret
        
Set_R_run:
	ld		hl,Rrunning
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
  ret

Set_L_run:
	ld		hl,Lrunning
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
  ret

Set_R_sit:
  ld    a,CollisionSYSitting
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
  xor   a
  ld    (EnableHitbox?),a
	ld		hl,RSitting
	ld		(PlayerSpriteStand),hl
  ret

Set_L_sit:	
  ld    a,CollisionSYSitting
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  xor   a
  ld    (EnableHitbox?),a
	ld		hl,LSitting
	ld		(PlayerSpriteStand),hl
  ret

Set_R_stand:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  xor   a
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ld    a,1
  ld    (PlayerFacingRight?),a	
	ld		hl,RStanding
	ld		(PlayerSpriteStand),hl
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl
  ret

Set_L_stand:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  xor   a
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ld    (PlayerFacingRight?),a	
	ld		hl,LStanding
	ld		(PlayerSpriteStand),hl
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl
  ret

Set_L_Push:
	ld		hl,LPushing
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
  ret

Set_R_Push:
	ld		hl,RPushing
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
  ret

Set_L_BeingHit:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,LBeingHit
	ld		(PlayerSpriteStand),hl
  xor   a
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
;  ld    a,1
;  ld    (PlayerFacingRight?),a                    ;since we move right, but face left, let's pretend we actually face right. This way the camera moves accordingly
  ld    a,(RunningTablePointer)
  ld    (RunningTablePointerWhenHit),a

  ld    hl,0
	ld		(PlayerAniCount),hl
;	ld    a,StartingJumpSpeed+1
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a
	
	ld    h,128                                     ;variable to determine if player was hit this frame (for now used by octopussy bullet)
  ret

Set_R_BeingHit:
  ld    a,CollisionSYStanding
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,RBeingHit
	ld		(PlayerSpriteStand),hl
  xor   a
  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
;  ld    (PlayerFacingRight?),a                    ;since we move left, but face right, let's pretend we actually face left. This way the camera moves accordingly
  ld    a,(RunningTablePointer)
  ld    (RunningTablePointerWhenHit),a

  ld    hl,0
	ld		(PlayerAniCount),hl
;	ld    a,StartingJumpSpeed+1
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a

	ld    h,128                                     ;variable to determine if player was hit this frame (for now used by octopussy bullet)
  ret

Set_L_SitPunch:
  ld    a,CollisionSYSitting
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,LSitPunch
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (PlayerFacingRight?),a	
	ld		(PlayerAniCount),a
  ret

Set_R_SitPunch:
  ld    a,CollisionSYSitting
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  
	ld		hl,RSitPunch
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (PlayerFacingRight?),a
	
  xor   a
	ld		(PlayerAniCount),a
  ret


SetBorderMaskingSprites:
  ld    hl,spat+0           ;y sprite 1
  
  ld    a,(CameraX)
  and   %0000 1111
  add   a,15 + 1
  ld    c,a                 ;x bordermasking sprite left side of screen
  add   a,225 - 1
  ld    d,a                 ;x bordermasking sprite right side of screen
  
  ld    a,(CameraY)
  dec   a                   ;y top sprite
  .selfmodifyingcodeAmountSpritesOneSide:  equ $+1
  ld    b,11                ;amount of sprites each side of the screen

  .loop:
  ld    (hl),a              ;y
  inc   hl                  ;x sprite
  ld    (hl),c              ;x bordermasking sprite left side of screen
  inc   hl                  ;next sprite
  ld    (hl),a              ;y
  inc   hl                  ;x sprite
  ld    (hl),d              ;x bordermasking sprite right  side of screen
  inc   hl                  ;next sprite
  add   a,16                ;next sprite will be 16 pixels lower
  djnz  .loop
  ret

ScreenOff:
  ld    a,(VDP_0+1)       ;screen off
  and   %1011 1111
  di
  out   ($99),a
  ld    a,1+128
  ei
  out   ($99),a
  ret

;ScreenOn:
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  di
  out   ($99),a
  ld    a,1+128
  ei
  out   ($99),a
  ret

spat:						;sprite attribute table (y,x 32 sprites)
	ds    32*2,0

PutSpatToVram:
;	ld		hl,(invisspratttableaddress)		;sprite attribute table in VRAM ($17600)
;	ld		a,1
;	call	SetVdp_Write	

  ;SetVdp_Write address for Spat
	di
;  ld    a,$05
;	out   ($99),a       ;set bits 15-17
;	ld    a,14+128
;	out   ($99),a       ;/first set register 14 (actually this only needs to be done once)
  xor   a
;  nop
	out   ($99),a       ;set bits 0-7
  SelfmodifyingCodeSpatAddress: equ $+1
	ld    a,$6e         ;$6e /$76 
;  nop
	ld		hl,spat			;sprite attribute table, and replace the nop required wait time
	out   ($99),a       ;set bits 8-14 + write access

  ld    c,$98
;	call	outix128

;outi = 16 (4 cycles) (4,5,3,4)
;nop = 4 (1 cycle)
;in a,($98) = 11 (3 cycles)
  outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|
  outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|
  outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|
  outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi|nop|in a,($98)|nop|in a,($98)|outi|outi;|nop|in a,($98)|nop|in a,($98)|
	ei
  ret

outix384:
  call  outix256
  jp    outix128
outix352:
  call  outix256
  jp    outix96
outix320:
  call  outix256
  jp    outix64
outix288:
  call  outix256
  jp    outix32
outix256:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix250:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix224:
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix208:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix192:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi
outix176:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix160:
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix144:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix128:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix112:
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix96:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix80:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi
outix64:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix48:
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix32:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix16:	
	outi	outi	outi	outi	outi	outi	outi	outi
outix8:	
	outi	outi	outi	outi	outi	outi	outi	outi	
	ret	