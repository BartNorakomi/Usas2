LevelEngine:

  call  BackdropBlue
  call  CameraEngine              ;Move camera in relation to Player's position. prepare R18, R19, R23 and page to be set on Vblank.
  call  BackdropBlack
  call  PopulateControls

;  call  Sf2EngineObjects          ;restore background P1, handle action P1, put P1 in screen, play music, 
                                  ;restore background P2, handle action P2, put P2 in screen, collision detection, set prepared collision action
  call  SetBorderMaskingSprites   ;set border masking sprites position in Spat
  call  PutPlayersprite           ;outs char data to Vram, col data to Vram and sets spat data for player (coordinates depend on camera x+y)
  call  PutSpatToVram             ;outs all spat data to Vram
  call  CheckMapExit              ;check if you exit the map (top, bottom, left or right)

;Routines starting at lineint:
  xor   a                         ;wait for lineint flag to be set. It's better (for now) to put the VRAM objects directly after the lineint
  ld    hl,lineintflag
.checkflag1:
  cp    (hl)
  jr    z,.checkflag1

  call  SwapSpatColAndCharTable
  call  switchpageSF2Engine

  call  BackdropBlue
  call  HandlePlayerSprite        ;handles all stands, moves player, checks collision, prepares sprite offsets
  call  BackdropBlack

	call	handle_enemies_and_objects

;  ld    ix,enemies_and_objects+(0*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
;  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object


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



BackdropGreen:
  ld    a,08
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

handle_enemies_and_objects:                           ;2. call movement_enemies_and_objects (if within movement area)
;	ld		a,(slot.page2rom)	; all RAM except page 2
;	out		($a8),a	

  ld    de,enemies_and_objects+(0*lenghtenemytable)   ;3. check object in screen display (if within movement area)                                    
  ld    a,(de) | or a | call nz,.docheck              ;4. set x&y of object in spat and out the col and char (if within screen display)
;  ld    de,enemies_and_objects+(1*lenghtenemytable)
;  ld    a,(de) | or a | call nz,.docheck
;  ld    de,enemies_and_objects+(2*lenghtenemytable)
;  ld    a,(de) | or a | call nz,.docheck
 
;	ld		a,(slot.ram)	      ;back to full RAM
;	out		($a8),a	
  ret

  .docheck:
  ld    ixl,e
  ld    ixh,d
    
  call  movement_enemies_and_objects                  ;sprite is in movement area, so let it move !! ^__^
  ret

movement_enemies_and_objects:
;  ld    a,(movementpatternsblock)
;	call	block34			      ;at address $8000 / page 2

  
  ld    a,(ix+enemies_and_objects.movementpattern)             ;movementpattern
  dec   a
  ld    b,a
  add   a,a                 ;*2
  add   a,b                 ;*3
  ld    d,0
  ld    e,a
  ld    hl,movementpatternaddress
  add   hl,de
  jp    (hl)

;This is at $4000 inside a block (movementpatternsblock)
movementpatternaddress:
  jp    PlatformVertically                  ;movement pattern 1   
  jp    PlatformHorizontally                ;movement pattern 2   

PlatformVertically:
  call  VramObjects                         ;put object in Vram/screen
  call  .MovePlatForm                       ;move
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  ret

.MovePlatForm:
  ld    a,(framecounter)
  and   1
  ret   nz

  ld    a,(SnapToPlatform?)
  or    a
  jr    z,.EndCheckPLayerSnapToPlatform

  ld    a,(ClesY)
  add   a,(ix+enemies_and_objects.v3)
  ld    (ClesY),a
  .EndCheckPLayerSnapToPlatform:


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

PlatformHorizontally:
  call  VramObjects                         ;put object in Vram/screen
  call  .MovePlatForm                       ;move
  call  CheckCollisionObjectPlayer          ;check collision with player - and handle interaction of player with object
  ret

.MovePlatForm:
  ld    a,(framecounter)
  and   3
  ret   nz

  ld    a,(SnapToPlatform?)
  or    a
  jr    z,.EndCheckPLayerSnapToPlatform

  ld    a,(ix+enemies_and_objects.v2)
  or    a
  jp    m,.MoveLeft
  .MoveRight:
  ld    hl,(ClesX)
  inc   hl
  ld    (ClesX),hl  
  jp    .EndCheckPLayerSnapToPlatform
  .MoveLeft:
  ld    hl,(ClesX)
  dec   hl
  ld    (ClesX),hl  
  .EndCheckPLayerSnapToPlatform:

;move object
  ld    a,(ix+enemies_and_objects.x)
  add   (ix+enemies_and_objects.v2)
  ld    (ix+enemies_and_objects.x),a  
  cp    254
  jr    z,.ChangeDirection
  cp    17+16     ;17 for 32 pix wide objects, 17+16 for 16 pix wide objects
  ret   nz

  .ChangeDirection:
  ld    a,(ix+enemies_and_objects.v2)
  neg
  ld    (ix+enemies_and_objects.v2),a
  ret

enemyexplosion:
jp enemyexplosion
  ret

Currency:
  ret

SnapToPlatform?:  db  0
CheckCollisionObjectPlayer:
  xor   a
  ld    (SnapToPlatForm?),a

;check player collides with object on the bottom side. This little part is preparing b. THIS CAN BE SPED UP BY SETTING THIS AS A FIXED VARIABLE IN THE OBJECT LIST
  ld    a,(ix+enemies_and_objects.ny)
  add   a,30
  ld    b,a

;check player collides with object on the top side. c= no collision
  ld    a,(ClesY)
  add   a,16
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
    
;1. check if player hits the bottom part of the object, then snap player to the object on the bottom side
  ld    a,(ClesY)
  sub   a,14-6
  sub   (ix+enemies_and_objects.ny)
  sub   (ix+enemies_and_objects.y)
  jp    nc,.CollisionBottomOfObject

;2. check if player hits the top    part of the object, then snap player to the object on the top    side
  ld    a,(ClesY)
  add   a,16 - 6
  sub   (ix+enemies_and_objects.y)
  jp    c,.CollisionTopOfObject

;3. check if player hits the right  part of the object, then snap player to the object on the right  side
  ld    hl,(ClesX)                    ;hl: x player (165)
  ld    de,-21 ;NX IS NOT INCLUDED HERE YET
  add   hl,de
  ld    d,0
  ld    e,(ix+enemies_and_objects.x)  ;de: x object (180)
  sbc   hl,de  
  jp    nc,.CollisionRightOfObject

;4. check if player hits the left   part of the object, then snap player to the object on the left   side
  ld    hl,(ClesX)                    ;hl: x player (165)
  ld    de,06-4
  add   hl,de
  ld    d,0
  ld    e,(ix+enemies_and_objects.x)  ;de: x object (180)
  sbc   hl,de  
  jp    c,.CollisionLeftOfObject
  ret

.CollisionRightOfObject:
  ld    a,(ix+enemies_and_objects.x)
  add   a,(ix+enemies_and_objects.nx)
  add   09

  ld    h,0
  ld    l,a
  ld    (ClesX),hl                   
  ret
  
.CollisionLeftOfObject:
  ld    a,(ix+enemies_and_objects.x)
  sub   7

  ld    h,0
  ld    l,a
  ld    (ClesX),hl                   
  ret

.CollisionTopOfObject:
  ld    a,(JumpSpeed)              ;if vertical JumpSpeed is negative or 0 then return. If it's positive then snap to object
  or    a
  ret   m
  ret   z
  
  ld    a,(ix+enemies_and_objects.y)
  sub   a,16
  ld    (ClesY),a
  
  ld    a,1
  ld    (SnapToPlatform?),a
  
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
  ld    a,(ix+enemies_and_objects.y)
  add   a,(ix+enemies_and_objects.ny)
  add   a,14
  ld    (ClesY),a
  ret


  

ClesX:      dw 180 ;210
ClesY:      db 111 ; 144-1
herospritenr:             db  22

VramObjectX:  db  000
VramObjectY:  db  000
VramObjects:
;first clean the object
  call  BackdropRed

  ld    hl,.CleanObject
  call  docopy

  ld    a,(ix+enemies_and_objects.x)
  or    a
  jp    p,.ObjectOnLeftSideOfScreen

.ObjectOnRightSideOfScreen:
;set sx
  ld    a,(ix+enemies_and_objects.v1)   ;v1 = sx
  ld    (.CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0000      ;Copy from left to right
  ld    (.CleanObject+copydirection),a
  ld    (.CopyObject+copydirection),a

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
  jp    z,.pagefound1

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
  ld    (.CopyObject+sx),a  
;set copy direction
  ld    a,%0000 0100      ;Copy from right to left
  ld    (.CleanObject+copydirection),a
  ld    (.CopyObject+copydirection),a

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
  ld    (.CopyObject+dpage),a  
  ld    (.CleanObject+dpage),a
  ld    a,c
  ld    (.CleanObject+spage),a

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+enemies_and_objects.y)
  ld    (.CleanObject+sy),a
  ld    (.CleanObject+dy),a
  ld    (.CopyObject+dy),a

  ld    a,(ix+enemies_and_objects.x)
  add   d
  ld    (.CopyObject+dx),a
  ld    (.CleanObject+dx),a
  add   e
  ld    (.CleanObject+sx),a
  
  ld    a,(ix+enemies_and_objects.nx)  
  ld    (.CopyObject+nx),a  
  add   a,2                 ;we clean 2 more pixels, because we use fast copy ($D0) for cleaning, which is not pixel precise (Bitmap mode)
  ld    (.CleanObject+nx),a  

  ld    a,(ix+enemies_and_objects.ny)
  ld    (.CopyObject+ny),a  
  ld    (.CleanObject+ny),a  

;put object
  ld    hl,.CopyObject
  call  docopy
  call  BackdropGreen
  ld    hl,.CopyObject
  call  docopy
  call  BackdropBlack
  ret

.pagefound1:
  jp    .pagefound

.CleanObject:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
  db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     
  
.CopyObject:
  db    000,000,216,001   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
  db    000,%0000 0100,$98       ;slow transparant copy -> Copy from right to left



PutPlayersprite:
	ld		a,(slot.page12rom)	;all RAM except page 1+2
	out		($a8),a	
  
;put hero sprite character
	ld		de,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
  ld    a,(herospritenr)
  ld    h,0
  ld    l,a
  add   hl,hl       ;*2
  add   hl,hl       ;*4
  add   hl,hl       ;*8
  add   hl,hl       ;*16
  add   hl,hl       ;*32
  add   hl,de
	ld		a,1
	call	SetVdp_Write

;  ld    a,(standchar+1)
;  cp    $80
;  ld    h,0         ;characterspritesblock + 0
;  ld    de,$0000+$4000
;  jp    c,.setsprites
;  ld    h,4         ;characterspritesblock + 4
;  ld    de,$C000-$40
;.setsprites:
;  push  de

;.nakedMod: equ	$+1
	ld		a,PlayerSpritesBlock
;  add   a,h
	call	block1234		;set blocks in page 1/2

standchar:	equ	$+1
	ld		hl,PlayerSpriteData_Char_LeftStand      ;sprite character in ROM
    
	ld		c,$98
	call	outix128    ;4 sprites (4 * 32 = 128 bytes)
;/put hero sprite character

  exx               ;store hl. hl now points to color data

;put hero sprite color
	ld		de,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
  ld    a,(herospritenr)
  ld    h,0
  ld    l,a
  add   hl,hl       ;*2
  add   hl,hl       ;*4
  add   hl,hl       ;*8
  add   hl,hl       ;*16
  add   hl,de
	ld		a,1
	call	SetVdp_Write

  exx               ;recall hl. hl now points to color data


X32BitShiftValue: equ 32
;check if player is left side of screen, if so add 32 bit shift
  push  hl
  ld    hl,(ClesX)
  ld    de,X32BitShiftValue
  sbc   hl,de
  pop   hl
	jp    nc,.PlayerRightSide

  .PlayerLeftSide:
  ld    c,128
  ld    b,64
  .Player32bitShifLoop:  
  ld    a,(hl)
  add   a,c
  out   ($98),a
  inc   hl
  djnz  .Player32bitShifLoop
  jp    .end32bitshift
;check if player is left side of screen, if so add 32 bit shift

  .PlayerRightSide:
	call	outix64     ;4 sprites (4 * 16 bytes = 46 bytes)
.end32bitshift:



;after the color data there are 2 bytes for the top and bottom offset of the sprites
  ld    a,(hl)
  ld    (selfmodifyingcode_x_offset_hero_top),a  
  inc   hl
  ld    a,(hl)
  ld    (selfmodifyingcode_x_offset_hero_bottom),a  


.spriteattributetable:


;	ld		a,(addytohero)
;  sub   a,16
;	add		a,a
;	add		a,a
;	add		a,a				;*8
;	sub		a,4				;all sprites 4 pixels up
;	ld		d,a       ;relative y
;	ld		a,(addxtohero)
;  sub   a,13
;	add		a,a
;	add		a,a
;	add		a,a				;*8
;32 bit shift here
;  add   a,32      ;32 bit shift
;/32 bit shift here
;	ld		e,a       ;relative x

;check if player is left side of screen, if so add 32 bit shift
;	ld		a,(addxtohero)
;  cp    250
;	jp    nc,.playerleft2
;	cp    3
;	jp    nc,.endcheck32bitshift
;.playerleft2:	
;  ld    a,e
;  add   a,32
;  ld    e,a
;.endcheck32bitshift:
;check if player is left side of screen, if so add 32 bit shift

;remove hero from screen ?
;  ld    a,(invis?)
;  or    a
;  jr    nz,.invis

;.setspathero:
;  ld    a,(x_offset_hero_top)
;  cp    200
;  jp    nc,setrowspecialspritepositions



;  ld    a,(herospritenr)
;  add   a,a         ;*2
;  add   a,a         ;*4
;  ld    d,0
;  ld    e,a
;	ld		hl,spat			;sprite attribute table
;  add   hl,de

  ld    a,(ClesY)
  sub   a,16
  ld    b,a
  add   a,16
  ld    c,a

  ld    a,(CameraX)         ;camera jumps 16 pixels every page, subtract this value from x Cles
  and   %1111 0000
  
  ld    d,0
  ld    e,a
  
  ld    hl,(ClesX)
  sbc   hl,de               ;take x Cles and subtract the x camer

;  ld    a,h                 ;if the value now is <0 or >256 Cles is out of the screen
;  or    a
;  jp    nz,.outofscreen

  ld    a,l

  cp    32
  jr    nc,.PutPlayerxY
  add   a,32
;  jp    .PutPlayerxY
;.outofscreen:
;  ld    a,255
.PutPlayerxY:

  ld    de,3
  ld    hl,spat+88          
  ld    (hl),b              ;y sprite 22
  inc   hl                  
 
selfmodifyingcode_x_offset_hero_top: equ $+1
  add   a,0

  ld    (hl),a              ;x sprite 22
  add   hl,de
  ld    (hl),b              ;y sprite 23      
  inc   hl 
  ld    (hl),a              ;x sprite 23
  add   hl,de
  
  ld    (hl),c              ;y sprite 24  
  inc   hl      

selfmodifyingcode_x_offset_hero_bottom: equ $+1
  add   a,0

  ld    (hl),a              ;x sprite 24
  add   hl,de
  ld    (hl),c              ;y sprite 25
  inc   hl               
  ld    (hl),a              ;x sprite 25
  add   hl,de

	ld		a,(slot.ram)	;back to full RAM
	out		($a8),a	
  ret
  

switchpageSF2Engine:
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  cp    2
  ret   nz

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
  ld    b,a
  jp    SetPage

Sf2EngineObjects:
;  ld    a,(Mapnumber)
  cp    3
;  ret   nz

  ;handle object 1
  call  restoreBackgroundP1
  call  handleP1Action
  call  putplayer1
  ret


moveplayerleftinscreen:       equ 128
blitpage:                     db  0
screenpage:                   db  2
Player1Spritedatablock:       db  ryuspritedatablock

Player1Framelistblock:        db  ryuframelistblock
Player1Frame:                 dw  ryupage0frame000
Player1FramePage:             db  0

Player1x:                     db  100

putplayer1:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then que page 1 to be restored
  ld    ix,restorebackgroundplayer1page1
  jp    z,.startsetupque
  dec   a                     ;if current page =1 then que page 2 to be restored
  ld    ix,restorebackgroundplayer1page2
  jp    z,.startsetupque      ;if current page =2 then que page 0 to be restored
  ld    ix,restorebackgroundplayer1page0
  .startsetupque:

	ld		a,(slot.page12rom)    ;all RAM except page 1+2
	out		($a8),a	

  ;set framelist in page 2 in rom ($8000 - $bfff)
;  ld    a,(Player1FramePage)
;  add   a,a
;  ld    hl,Player1Framelistblock
;	add   a,(hl)
	
	ld    a,ryuframelistblock
  call	block34

  ;set framedata in page 1 in rom ($4000 - $7fff)
;  ld    a,(Player1FramePage)
;  add   a,a
;  ld    hl,Player1Spritedatablock
;	add   a,(hl)
	
	ld    a,ryuspritedatablock
  call	block12

  ld    a,(player1x)
  dec   a
  ld    (player1x),a

  ld    bc,player1x
  ld    hl,(Player1Frame)     ;points to player width
  ld    iy,Player1SxB1        ;player collision detection blocks

  di
  call  Putplayer
  ei
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
Putplayer:
;screen limit right
  ld    a,(bc)                ;player x
  cp    ScreenLimitxRight
  jp    c,.LimitRight
  ld    a,ScreenLimitxRight
;  ld    (bc),a
  .LimitRight:
;screen limit left
  ld    a,(bc)                ;player x
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
  db    0,2,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage0frame001 | db 1 | dw ryupage0frame000 | db 1
  dw ryupage0frame001 | db 1 | dw ryupage0frame002 | db 1
  ds  12


handleP1Action:
;  ld    ix,P1RightIdleFrame
  ld    ix,RyuActions2.LeftIdleFrame
  ld    iy,Player1Frame
  jp    AnimatePlayer         ;if left NOR right is pressed, then stay in Idle

AnimatePlayer:                ;animates, forces writing spriteframe, out: z=animation ended
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








  
restoreBackgroundP1:
  ld    a,(screenpage)
  or    a                     ;if current page =0 then restore page 2
  ld    hl,restorebackgroundplayer1page2
  jp    z,DoCopy
  dec   a                     ;if current page =1 then restore page 0
  ld    hl,restorebackgroundplayer1page0
  jp    z,DoCopy         ;if current page =2 then restore page 1
  ld    hl,restorebackgroundplayer1page1
  jp    DoCopy

restorebackgroundplayer1page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $2a,0,$50,0
	db    0,0,$d0  
restorebackgroundplayer1page1:
	db    0,0,0,3
	db    0,0,0,1
	db    $2a,0,$50,0
	db    0,0,$d0  
restorebackgroundplayer1page2:
	db    0,0,0,3
	db    0,0,0,2
	db    $2a,0,$50,0
	db    0,0,$d0  


ExitRight256x216: equ 29*8
ExitRight304x216: equ 38*8-3

CheckMapExit:
  ld    a,(ClesY)
  cp    180+8 + 24
  jr    nc,.ExitBottomFound

  ld    a,(ClesY)
  cp    4
  jr    c,.ExitTopFound

  ld    a,(ClesX)
  or    a
  jr    z,.PossibleExitLeftFound

  ld    hl,ExitRight304x216
  ld    de,(ClesX)
  sbc   hl,de
  ret   nc

  ld    hl,(ClesX)
  ld    de,50*8
  sbc   hl,de
  jr    c,.ExitRightFound
  jr    .ExitLeftFound  

  ld    hl,(ClesX)
.selfmodifyingcodeMapexitRight:
  ld    de,000
  add   hl,de
  jr    c,.ExitRightFound  
  ret

.ExitBottomFound:  
  ld    de,WorldMapDataMapLenght*WorldMapDataWidth
  ld    a,6
  ld    (ClesY),a
  ld    a,0
  ld    (CameraY),a
  jp    .LoadnextMap
  
.ExitTopFound:  
  ld    de,-WorldMapDataMapLenght*WorldMapDataWidth
  ld    a,176+8 + 24
  ld    (ClesY),a
  ld    a,44
  ld    (CameraY),a
  jp    .LoadnextMap
  
.ExitRightFound:  
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

  ld    a,(vdp_0)           ;set ei1
  and   %1110 1111          ;ei1 checks for lineint and vblankint
  ld    (vdp_0),a           ;ei0 (which is default at boot) only checks vblankint
;  di
  out   ($99),a
  ld    a,128
;  ei
  out   ($99),a

  ld    a,0
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
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
  push  bc
  push  de
  push  hl
  exx
  ex    af,af'
  push  af
  push  bc
  push  de
  push  hl
  push  ix
  
  ld    a,1               ;set s#1
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge line interrupt
  rrca
  jp    c,lineint ;lineint detected, so jp to that routine

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge vblank interrupt
  rlca
  jp    c,vblank  ;vblank detected, so jp to that routine
 
  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
  pop   af 
  ei
  ret

;on vblank we set page 2
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
  ld    a,23+128
  out   ($99),a
  
  ld    a,(R19onVblank)       ;splitline height
  out   ($99),a
  ld    a,19+128
  out   ($99),a

  ld    a,(PageOnNextVblank)  ;set page
  out   ($99),a
  ld    a,2+128
  out   ($99),a
     
  ld    a,1                   ;vblank flag gets set
  ld    (vblankintflag),a  

  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
  pop   af 
  ei
  ret

;on the lineint we turn the screen off at the end of the line using polling for HR
;then we switch between page 0+1
;we set horizontal and vertical adjust
;and we turn screen on again at the end of the line
;we play music and set s#0 again
lineint:  
;  ld    hl,linesplitvariables

;PREPARE ALL THESE INSTRUCTION TO BE EXECUTED WITH OUTI'S AFTER THE POLLING
;  ld    a,(newlineintpage)
;  ld    (hl),a
;  ld    a,2+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(newlineinthoroff)              ;prepare horizontal screen adjust for next frame
;  ld    (hl),a
;  ld    a,18+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(newlineintveroff)               ;set vertical screen adjust
;  ld    d,a
;  ld    (hl),a
;  ld    a,23+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,d
;  add   a,worldmaplineintheight
;  ld    (hl),a
;  ld    a,19+128            ;set lineinterrupt height  
;  inc   hl  
;  ld    (hl),a
;  inc   hl  

;  ld    a,(VDP_0+1)       ;screen on
;  or    %0100'0000
;  ld    (hl),a
;  ld    a,1+128
;  inc   hl  
;  ld    (hl),a
;  inc   hl
;/PREPARE ALL THESE INSTRUCTION TO BE EXECUTED WITH OUTI'S AFTER THE POLLING

;  ld    hl,linesplitvariables
;  ld    c,$99


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
 
  ld    b,%0010 0000      ;bit to check for HBlank detection
.Waitline1:
;  in    a,($99)           ;Read Status register #2
;  and   b                 ;wait until start of HBLANK
;  jr    nz,.Waitline1

.Waitline2:
  in    a,($99)           ;Read Status register #2
  and   b                 ;wait until end of HBLANK
  jr    z,.Waitline2 

  ld    a,0*32+31         ;set page 0
  out   ($99),a
  ld    a,2+128
  out   ($99),a

  ld    a,0               ;set horizontal screen adjust
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

  ld    a,1                   ;vblank flag gets set
  ld    (lineintflag),a  

  pop   ix
  pop   hl
  pop   de
  pop   bc
  pop   af
  ex    af,af'
  exx
  pop   hl
  pop   de
  pop   bc
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


TempoldY: db 0

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
 .VerticalMovementCamera:               ;vertical movement of camera: Camera just locks on to the player when not jumping.

;follow y position of player with camera


  ld    a,(TempoldY)
  ld    b,a
  ld    a,(Clesy)
  ld    (TempoldY),a

  cp    b
  jr    z,.HorizontalMovementCamera
  
  ld    c,-1           ;vertical camera movent
  jr    c,.HorizontalMovementCamera
  ld    c,+1           ;vertical camera movent


.HorizontalMovementCamera:
.playerfacingRight:



;camera should start moving to the right, when player x>50 and facing right
  ld    a,(PlayerFacingRight?)          ;is player facing right ?
  or    a
  jp    z,.playerfacingLeft

  ld    hl,(ClesX)                      ;is player x>CameraMoveRightXBoundary ?
  ld    de,CameraMoveRightXBoundary
  xor   a 
  sbc   hl,de                           ;hl=playerX - CameraMoveRightXBoundary
  jp    c,CameraEngine304x216.setR18R19R23andPage

  ld    a,(CameraX)                     ;is cameraX > playerX - CameraMoveRightXBoundary ?
  ld    e,a
  sbc   hl,de
  jp    c,CameraEngine304x216.setR18R19R23andPage

  ld    b,1           ;horizontal camera movent
  jp    .movecamera

.playerfacingLeft:
;camera should start moving to the left, when player x<304-50 and facing left
  ld    de,(ClesX)                      ;is player x<CameraMoveLeftXBoundary ?
  ld    hl,CameraMoveLeftXBoundary
  xor   a
  sbc   hl,de                           ;hl=CameraMoveLeftXBoundary - playerX 
  jp    c,CameraEngine304x216.setR18R19R23andPage

  ld    a,(CameraX)  
  sub   64
  neg 
  ld    e,a
  sbc   hl,de
  jp    c,CameraEngine304x216.setR18R19R23andPage
 
  ld    b,-1           ;horizontal camera movent 
;  jp    .movecamera

.movecamera:
  ld    a,(CameraY)
  add   a,c
  jp    m,.negativeYValue
  cp    45
  jr    nc,.maxYRangeFound
  ld    (CameraY),a
  .negativeYValue:
  .maxYRangeFound:

  ld    a,(CameraX)
  add   a,b
  jp    m,.negativeValue
  cp    16
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

  ld    a,(CameraY)
  ld    b,a
  ld    a,lineintheight
  add   a,b  
  ld    (R19onVblank),a
  ret  


CameraEngine304x216:  
 .VerticalMovementCamera:               ;vertical movement of camera: Camera just locks on to the player when not jumping.

;follow y position of player with camera
  ld    a,(Clesy)

;checkplayerbottom of screen  
  cp    100
  ld    c,+1            ;vertical camera movent
  jr    nc,.movecameraY

  cp    80 
  ld    c,-1            ;vertical camera movent
  jr    c,.movecameraY

  ld    c,0             ;vertical camera movent

.movecameraY:
  ld    a,(CameraY)
  add   a,c
  jp    m,.negativeYValue
  cp    45
  jr    nc,.maxYRangeFound
  ld    (CameraY),a
  .negativeYValue:
  .maxYRangeFound:

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

  add   a,lineintheight
  ld    (R19onVblank),a

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

setpage:              ;in a->x*32+31 (x=page)
  ld    a,b
  ld    (currentpage),a
  di
  out   ($99),a
  ld    a,2+128
  ei
  out   ($99),a
  ret

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


;MapData:
;  ds    38 * 27           ;a map is 38 * 27 tiles big  

MapLenght:  equ 38
checktile:  
;get player X in tiles
  ld    hl,(ClesX)
  add   hl,de

  ld    a,h
  or    a
  jp    m,.CheckTileIsOutOfScreenLeft

  srl   h
  rr    l                   ;/2
  srl   l                   ;/4
  srl   l                   ;/8

;get player Y in tiles
  ld    a,(Clesy)
  add   a,b

  srl   a
  srl   a
  srl   a                   ;/8

	ld		de,MapData-80
	add   hl,de
	
.selfmodifyingcodeMapLenght:
	ld		de,000              ;32+2 for 256x216 and 28+2 tiles for 304x216
  jr    z,.yset
  
  ld    b,a
.setmapwidthy:
	add		hl,de
  djnz  .setmapwidthy
.yset:

  ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
  dec   a                   ;1 = wall
	ret

.CheckTileIsOutOfScreenLeft:
  xor   a
  dec   a
  ret

playermovementspeed:    db  2
oldx:                   dw  0
oldy:                   db  0
PlayerFacingRight?:     db  1

RstandingSpriteStand:         equ 0
RsittingSpriteStand:          equ 2
RrunningSpriteStand:          equ 4
LstandingSpriteStand:         equ 6
LsittingSpriteStand:          equ 8
LrunningSpriteStand:          equ 10

;Rstanding,Lstanding,Rsitting,Lsitting,Rrunning,Lrunning,Jump,ClimbDown,ClimbUp,Climb,RAttack,LAttack,ClimbStairsLeftUp
PlayerSpriteStand: dw  Rstanding

PlayerAniCount:     db  0,0
HandlePlayerSprite:
  ld    hl,(PlayerSpriteStand)
  jp    (hl)

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

  ld    a,(NewPrContr)
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

  ld    a,(NewPrContr)
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

  ld    a,RunningTablePointerRunLeftEndValue
  ld    (RunningTablePointer),a ;this will make sure you end the stairs climb with max movement speed in the correct direction
  jp    Set_L_Run

AttackRotator:  db 0
LAttack:
  ld    a,(AttackRotator)
  or    a
  jp    z,LAttack0
  dec   a
  jp    z,LAttack1
  dec   a
  jp    z,LAttack2
  dec   a
  jp    z,LAttack3

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
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2b
  cp    5
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2d
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch2e
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
  jp    Set_L_Stand

LAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_LeftPunch1a
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1b
  cp    5
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1c
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1e
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1f
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1g
  cp    25
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1h
  cp    28
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_LeftPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    32
	ret   nz
  jp    Set_L_Stand

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

RAttack:
  ld    a,(AttackRotator)
  or    a
  jp    z,RAttack0
  dec   a
  jp    z,RAttack1
  dec   a
  jp    z,RAttack2
  dec   a
  jp    z,RAttack3

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
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2b
  cp    5
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2c
  cp    20
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2d
  cp    22
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch2e
  .setSprite:
	ld		(standchar),hl
	
	cp    25
	ret   nz
  jp    Set_R_Stand

RAttack2:
  ld    a,(PlayerAniCount)
  inc   a
  ld    (PlayerAniCount),a
  ld    hl,PlayerSpriteData_Char_RightPunch1a
  cp    3
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1b
  cp    5
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1c
  cp    07
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1d
  cp    09
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1e
  cp    21
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1f
  cp    23
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1g
  cp    25
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1h
  cp    28
  jr    c,.setSprite
  ld    hl,PlayerSpriteData_Char_RightPunch1i
  .setSprite:
	ld		(standchar),hl
	
	cp    32
	ret   nz
  jp    Set_R_Stand

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

StartingJumpSpeed:        equ -5    ;initial starting jump take off speed
FallingJumpSpeed:         equ 1
JumpSpeed:                db  0
MaxDownwardFallSpeed:     equ 5
GravityTimer:             equ 4     ;every x frames gravity changes jump speed
YaddHeadPLayer:           equ 2
YaddmiddlePLayer:         equ 17
YaddFeetPlayer:           equ 33
XaddLeftPlayer:           equ 00 - 8
XaddRightPlayer:          equ 15 - 8

MoveHorizontallyWhileJump:
  ld    b,0                 ;horizontal movement

	ld		a,(Controls)
;	bit		1,a           ;cursor down pressed ?
;	jp		nz,.Maybe_Set_R_sit
;	bit		0,a           ;cursor up pressed ?
;	jp		nz,.R_jump_andcheckpunch
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
	ld		hl,PlayerSpriteData_Char_RightRun9
	ld		(standchar),hl
  ret

.AnimateJumpFacingLeft:
	ld		hl,PlayerSpriteData_Char_LeftRun9
	ld		(standchar),hl
  ret

CheckSnapToStairsWhileJump:
;check if there are stairs when pressing up, if so climb the stairs.
;[Check ladder going Right UP]
  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   3                   ;check for tilenr 4=stairsleftup
  jp    z,.stairsfoundleftup

  ld    b,YaddFeetPlayer-00    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+08-08   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  sub   4                   ;check for tilenr 5=stairssrightup
  ret   nz

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
  
Jump:
  call  MoveHorizontallyWhileJump
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump
  call  AnimateWhileJump
  call  .VerticalMovement
	ld		a,(Controls)
	bit		0,a           ;cursor up pressed ?
  call  nz,CheckSnapToStairsWhileJump

  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?
	jp    nz,.CheckJumpOrClimbLadder  ;while jumping player can double jump can snap to a ladder and start climbing
  ret

  .VerticalMovement:
  ld    hl,JumpSpeed

	ld		a,(PlayerAniCount)
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
	ld		(PlayerAniCount),a

  ;unable to jump through the top of the screen
  ld    a,(Clesy)
  cp    9
  jp    nc,.EndCheckTopOfScreen

  ld    a,(hl)              ;if vertical JumpSpeed is negative then CheckPlatformAbove. If it's positive then CheckPlatformBelow
  or    a
  jp    m,.SkipverticalMovement
  .EndCheckTopOfScreen:
  
  ld    a,(Clesy)
  add   a,(hl)
  ld    (Clesy),a

  .SkipverticalMovement:

  ld    a,(hl)              ;if vertical JumpSpeed is negative then CheckPlatformAbove. If it's positive then CheckPlatformBelow
  or    a
  jp    m,.CheckPlatformAbove
  ret   z

  .CheckPlatformBelow:        ;check platform below
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToPlatformBelow

  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToPlatformBelow  
  
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFound

  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  dec   a                   ;check for tilenr 2=ladder 
  jr    z,.LadderFound
;  scf
  ret

;while falling a ladder tile is found at player's feet. 
;check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .LadderFound:               
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.CheckLadderRightSide

  ld    b,YaddFeetPlayer-9  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2-16   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    nz,.SnapToPlatformBelow

;check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
  .CheckLadderRightSide:
  ld    b,YaddFeetPlayer-1    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   nz

  ld    b,YaddFeetPlayer-9    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2+16  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

  .SnapToPlatformBelow:
  ld    a,(Clesy)           ;on collision snap y player to platform below and switch standing
  and   %1111 1000
  dec   a
  ld    (Clesy),a
 
  ld    a,(PlayerFacingRight?)
  or    a
  jp    z,Set_L_stand       ;on collision change to L_Stand  
  jp    Set_R_stand         ;on collision change to R_Stand    

  .CheckPlatformAbove:    
;check platform above
  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+3   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToCeilingAbove

  ld    b,YaddHeadPLayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-3  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToCeilingAbove
  ret
 
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
	ld		hl,PlayerSpriteData_Char_LeftRun1
	ld		(standchar),hl

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,Rsitting.CheckLadder
	bit		0,a           ;cursor up pressed ?
;	jp		nz,Set_jump
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun

  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
	jp		Set_L_stand
  ret

.CheckLadder:
  ret

Rsitting:
	ld		hl,PlayerSpriteData_Char_RightRun1
	ld		(standchar),hl

  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.CheckLadder
	bit		0,a           ;cursor up pressed ?
;	jp		nz,Set_jump
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
	ld		a,(Controls)
	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun

  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic	
	jp		Set_R_stand
  ret

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
  
AnimateRun:
  ld    a,(framecounter)          ;animate every 4 frames
  and   3
  ret   nz
  
  ld    a,(PlayerAniCount)
  add   a,2                       ;2 bytes used for pointer to sprite frame address
  cp    2 * 10                    ;10 frame addresses
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
	ld    hl,PlayerSpriteData_Colo_LeftRun1-PlayerSpriteData_Char_LeftRun1
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

RunningTablePointer:                  db  18 ;12
RunningTablePointerCenter:            equ 18 ;12
RunningTablePointerRightEnd:          equ 38 ;26
RunningTablePointerRunLeftEndValue:   equ 6
RunningTablePointerRunRightEndValue:  equ 32 ;20
RunningTable1:
;       [run  L]                   C                   [run  R]
;  dw    -1,-1,-1,-1,-1,-1,-1,-1,-1,0,+1,+1,+1,+1,+1,+1,+1,+1,+1
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
 
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl
  
  ld    a,e
  or    a
  jp    m,.PlayerMovedLeft
  ret   z

.PlayerMovedRight:
  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallRight

  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallRight

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
  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallLeft

  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
  call  checktile           ;out z=collision found with wall
  jr    z,.SnapToWallLeft

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
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z

  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  scf
  ret

CheckFloorInclLadder:
  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  

  ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
  ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
  call  checktile           ;out z=collision found with wall
  ret   z
  dec   a                   ;check for tilenr 2=ladder 
  ret   z  
  scf
  ret

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

	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		3,a           ;cursor right pressed ?
	jp		nz,.MoveAndAnimate

;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic

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

	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
	jp		nz,.MoveAndAnimate
;	bit		3,a           ;cursor right pressed ?
;	jp		nz,.AnimateRun

  ld    a,(NewPrContr)
;	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
;	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic

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

Lstanding:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,.EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  .EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;

  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?
	jp		nz,.UpPressed

	bit		4,a           ;space pressed ?
	jp		nz,Set_L_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_L_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_L_attack3


	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
	jp		nz,.Set_L_run_andcheckpunch
	bit		3,a           ;cursor right pressed ?
	jp		nz,.Set_R_run_andcheckpunch

  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic
	ret

.Set_L_run_andcheckpunch:
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_L_standmagic
  jp    Set_L_run

.DownPressed:
;  call  CheckDoubleTapDownF1Menu
  
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_sitpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_sitmagic
	call	Set_L_sit
  call  CheckClimbStairsDown  
  ret

.UpPressed:
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		z,Set_jump

  call  Set_jump
  call  CheckClimbLadderUp
  call  CheckClimbStairsUp
  ret


.Set_R_run_andcheckpunch:
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic
  jp    Set_R_run

Rstanding:
  call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

  ld    a,(SnapToPlatform?)
  or    a
  jr    nz,..EndCheckSnapToPlatform
  call  CheckFloorInclLadder;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
  jp    c,Set_Fall
  ..EndCheckSnapToPlatform:

;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?	
	jp		nz,.UpPressed	
	
	bit		4,a           ;space pressed ?
	jp		nz,Set_R_attack
;	bit		5,a           ;'M' pressed ?
;	jp		nz,Set_R_attack2
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_R_attack3

	ld		a,(Controls)
	bit		1,a           ;cursor down pressed ?
	jp		nz,.DownPressed
	bit		2,a           ;cursor left pressed ?
	jp		nz,.Set_L_run_andcheckpunch
	bit		3,a           ;cursor right pressed ?
	jp		nz,.Set_R_run_andcheckpunch

  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic
	ret

.Set_L_run_andcheckpunch:
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_L_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_L_standmagic
  jp    Set_L_run

.DownPressed:
;  call  CheckDoubleTapDownF1Menu
  
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_sitpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_sitmagic
	call	Set_R_sit
  call  CheckClimbStairsDown  
  ret

.UpPressed:
  call  Set_jump
  call  CheckClimbLadderUp
  call  CheckClimbStairsUp  
  ret
  
.Set_R_run_andcheckpunch:
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
;	jp		nz,Set_R_standpunch
	bit		5,a           ;b pressed ?
;	jp		nz,Set_R_standmagic
  jp    Set_R_run

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

CheckClimbLadderUp:
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

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_Stairs_Climb_RightUp:
	ld		hl,ClimbStairsRightUp
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
  ret

Set_Stairs_Climb_LeftUp:
	ld		hl,ClimbStairsLeftUp
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
  ret


Set_ClimbDown:
	ld		hl,ClimbDown
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_ClimbUp:
	ld		hl,ClimbUp
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_Climb_AndResetAniCount:
  ld    hl,0 
  ld    (PlayerAniCount),hl
  Set_Climb:
	ld		hl,Climb
	ld		(PlayerSpriteStand),hl

	ld		hl,PlayerSpriteData_Char_Climbing1
	ld		(standchar),hl	

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  ret

Set_jump:
  ld    a,1
  ld    (DoubleJumpAvailable?),a

  .SkipTurnOnDoubleJump:  
	ld		hl,Jump
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
	ld    a,StartingJumpSpeed
	ld		(JumpSpeed),a
  ret

Set_Fall:    
  ld    a,1
  ld    (DoubleJumpAvailable?),a

	ld		hl,Jump
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
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
	ld		hl,RSitting
	ld		(PlayerSpriteStand),hl
  ret

Set_L_sit:	
	ld		hl,LSitting
	ld		(PlayerSpriteStand),hl
  ret

Set_R_stand:
	ld		hl,RStanding
	ld		(PlayerSpriteStand),hl
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl
  ret

Set_L_stand:
	ld		hl,LStanding
	ld		(PlayerSpriteStand),hl
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl
  ret



;Totallycentredpose:
;  ld    a,100       ;y offset
;  ld    d,centrex+00    ;x offset top row
;  ld    e,centrex+00    ;x offset middle row
;  ld    h,centrex+00    ;x offset bottom row
;  jp    setxyoffsetsprite

;y_offset_hero:      db  100
;x_offset_hero_top:  db  106
;x_offset_hero_mid:  db  102
;x_offset_hero_bot:  db  103
;setxyoffsetsprite:
;  ld    (y_offset_hero),a
;  ld    a,d
;  ld    (x_offset_hero_top),a
;  ld    a,e
;  ld    (x_offset_hero_mid),a
;  ld    a,h
;  ld    (x_offset_hero_bot),a
;  ret



SetBorderMaskingSprites:
  ld    hl,spat+0           ;y sprite 1
  ld    de,3
  ld    b,11                ;amount of sprites left side screen
  
  ld    a,(CameraX)
;  dec a
  and   %0000 1111
  add   a,15
  ld    (.selfmodifyingcode+1),a
  
  ld    a,(CameraY)
  dec   a
  
  ld    c,2                 ;2 columns of sprites
  .loop:
  ld    (hl),a
  add   a,16                ;next sprite will be 16 pixels lower
  inc   hl                  ;x sprite
  .selfmodifyingcode:
  ld    (hl),000
  add   hl,de
  djnz  .loop

  ld    a,(.selfmodifyingcode+1)
  add   a,225
  ld    (.selfmodifyingcode+1),a  
  ld    b,11                ;amount of sprites right side screen
  ld    a,(CameraY)
  dec   a
  dec   c
  jr    nz,.loop
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

ScreenOn:
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  di
  out   ($99),a
  ld    a,1+128
  ei
  out   ($99),a
  ret

PutSpatToVram:
	ld		hl,(invisspratttableaddress)		;sprite attribute table in VRAM ($17600)
	ld		a,1
	call	SetVdp_Write	
	ld		hl,spat			;sprite attribute table
  ld    c,$98
	call	outix128
  ret

spat:						;sprite attribute table
	db		000,000,000,0	,016,000,004,0	,032,000,008,0	,048,000,012,0
	db		064,000,016,0	,080,000,020,0	,096,000,024,0	,112,000,028,0
	db		128,000,032,0	,144,000,036,0	,160,000,040,0	,000,000,044,0
	db		016,000,048,0	,032,000,052,0	,048,000,056,0	,064,000,060,0
	
	db		080,000,064,0	,096,000,068,0	,112,000,072,0	,128,000,076,0
	db		144,000,080,0	,160,000,084,0	,100,100,088,0	,100,100,092,0
	db		116,100,096,0	,116,100,100,0	,000,000,104,0	,000,000,108,0
	db		000,000,112,0	,000,000,116,0	,000,000,120,0	,000,000,124,0

outix128:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix96:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix80:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi
outix64:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix32:	
	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	outi	
outix16:	
	outi	outi	outi	outi	outi	outi	outi	outi
outix8:	
	outi	outi	outi	outi	outi	outi	outi	outi	
	ret