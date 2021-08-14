LevelEngine:
  ld    a,(framecounter)
  inc   a
  ld    (framecounter),a

;  ld    a,1
;  ld    hl,vblankflag
;.checkflag:
;  cp    (hl)
;  jp    nc,.checkflag

;  ld    (hl),0

  call  switchpage
;  call  putStarFoxSprite
  call  PopulateControls
  call  CameraEngine              ;sets R18 and R23
  call  movePlayer
;  call  VramObjects
  call  Sf2EngineObjects          ;restore background P1, handle action P1, put P1 in screen, play music, 
                              ;restore background P2, handle action P2, put P2 in screen, collision detection, set prepared collision action
  call  SetBorderMaskingSprites
  call  SetClesSprites
  call  putspattovram
  call  swap_spat_col_and_char_table
  call  checkmapexit              ;check if you exit the map top bottom left or right

  ld    a,0           
  ld    hl,vblankintflag
.checkflag:
  cp    (hl)
  jr    z,.checkflag
.endcheckflag:  
  ld    (hl),0
  jp    LevelEngine

switchpage:
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

Player1x:                     db  230

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
  dw ryupage1frame001 | db 1 | dw ryupage1frame000 | db 1
  dw ryupage1frame001 | db 1 | dw ryupage1frame002 | db 1
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

VramObjectX:  db  100
VramObjectY:  db  100
VramObjects:
;first clean the object
  ld    hl,.CleanObject
  call  docopy

;press space to increase width of object
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
  jr    z,.endcheckSpacepressed

  ld    a,(.CopyObject+nx)
  add   a,2
  cp    40
  jr    nz,.endnx  
  ld    a,10
  .endnx:
  ld    (.CopyObject+nx),a  
  ld    (.CleanObject+nx),a  
  .endcheckSpacepressed:

  ld    a,(NewPrContr)
	bit		5,a           ;m pressed ?
  jr    z,.endcheckMpressed

  ld    a,(.CopyObject+ny)
  add   a,2
  cp    40
  jr    nz,.endny
  ld    a,10
  .endny:
  ld    (.CopyObject+ny),a  
  ld    (.CleanObject+ny),a  
  .endcheckMpressed:  

;set pages to copy to and to clean from
  ld    a,(currentpage)
  cp    0*32+31           ;x*32+31 (x=page)
  ld    b,0               ;copy to page 0
  ld    c,1               ;clean object from vram data in page 1
  ld    d,+000            ;x offset CopyObject
  ld    e,-016            ;x offset CleanObject 
  jr    z,.pagefound

  cp    1*32+31           ;x*32+31 (x=page)
  ld    b,1               ;copy to page 1
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-016            ;x offset CopyObject
  ld    e,-016            ;x offset CleanObject 
  jr    z,.pagefound

  ld    a,(currentpage)
  cp    2*32+31           ;x*32+31 (x=page)
  ld    b,2               ;copy to page 2
  ld    c,3               ;clean object from vram data in page 3
  ld    d,-032            ;x offset CopyObject
  ld    e,-016            ;x offset CleanObject 
  jr    z,.pagefound

  ld    b,3               ;copy to page 3
  ld    c,2               ;clean object from vram data in page 2
  ld    d,-048            ;x offset CopyObject
  ld    e,+016            ;x offset CleanObject 
  jr    z,.pagefound

.pagefound:
  ld    a,b
  ld    (.CopyObject+dpage),a  
  ld    (.CleanObject+dpage),a
  ld    a,c
  ld    (.CleanObject+spage),a

;move object
  ld    a,(VramObjectY)
  inc   a
  cp    180
  jr    c,.go
  xor   a
  .go:
  ld    (VramObjectY),a
  ld    (.CleanObject+sy),a
  ld    (.CleanObject+dy),a
  ld    (.CopyObject+dy),a

  ld    a,(VramObjectX)
  add   d
  ld    (.CopyObject+dx),a
  ld    (.CleanObject+dx),a
  add   e
  ld    (.CleanObject+sx),a

;put object
  ld    hl,.CopyObject
  call  docopy
  ret

.CleanObject:
  db    084,000,100,001   ;sx,--,sy,spage
  db    100,000,100,000   ;dx,--,dy,dpage
  db    010,000,010,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy     
  
.CopyObject:
  db    000,000,220,000   ;sx,--,sy,spage
  db    100,000,100,000   ;dx,--,dy,dpage
  db    010,000,010,000   ;nx,--,ny,--
  db    000,000,$D0       ;fast copy     

checkmapexit:
  ld    hl,(ClesX)
  ld    de,-6
  add   hl,de
  jr    nc,.ExitLeftFound

  ld    hl,(ClesX)
.selfmodifyingcodeMapexitRight:
  ld    de,-35*8
  add   hl,de
  jr    c,.ExitRightFound  

  ld    a,(ClesY)
  cp    8
  jr    c,.ExitTopFound

  ld    a,(ClesY)
  cp    180
  jr    nc,.ExitBottomFound
  ret

.ExitBottomFound:  
  ld    a,(Mapnumber)
  add   3
  ld    (Mapnumber),a

  ld    a,10
  ld    (ClesY),a

  ld    a,0
  ld    (CameraY),a
  jp    .LoadnextMap
  
.ExitTopFound:  
  ld    a,(Mapnumber)
  sub   3
  ld    (Mapnumber),a

  ld    a,176
  ld    (ClesY),a

  ld    a,45
  ld    (CameraY),a
  jp    .LoadnextMap
  
.ExitRightFound:  
  ld    a,(Mapnumber)
  inc   a
  ld    (Mapnumber),a

  ld    hl,8
  ld    (ClesX),hl

  xor   a
  ld    (CameraX),a
  jp    .LoadnextMap
  
.ExitLeftFound:  
  ld    a,(Mapnumber)
  cp    3
  jr    z,.ExitleftButStartingMap
  
  dec   a
  ld    (Mapnumber),a

  ld    hl,34*8
  ld    (ClesX),hl

  ld    a,63
  ld    (CameraX),a
  jp    .LoadnextMap

.ExitleftButStartingMap:
  ld    hl,11
  ld    (ClesX),hl
  ret

.LoadnextMap:
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
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a

  ld    a,(VDP_8)         ;sprites on
  and   %11111101
  ld    (VDP_8),a
  out   ($99),a
  ld    a,8+128
  out   ($99),a

   
;  ld    a,2*32+31         ;set page 2
;  out   ($99),a
;  ld    a,2+128
;  out   ($99),a

;R#18 (register 18) uses bits 3 - 0 for horizontal screen adjust
;MSB  7   6   5   4   3   2   1   0
;R#18 v3  v2  v1  v0  h3  h2  h1  h0
;h can have a value from 0 - 15 and the screen adjusts horizontally according to the table below
;     7   6   5   4   3   2   1   0   15  14  13  12  11  10  9   8
;H  left                       centre  
;  ld    a,0               ;set horizontal screen adjust
;  out   ($99),a
;  ld    a,18+128
;  out   ($99),a

;  ld    a,0               ;set vertical screen adjust
;  out   ($99),a
;  ld    a,23+128
;  out   ($99),a

;If you have a split and are changing the vertical scrollregister (r#23) on it,
;then you should always re-set the splitline (r#19). This because the splitline
;is calculated from line 0 in the VRAM, and not from line 0 of the screen. 
;In order to set the splitline to the ‘screenline’ it’s easiest to simply add 
;the value of r#23 to it.
;  ld    a,lineintheight
;  out   ($99),a
;  ld    a,19+128            ;set lineinterrupt height
;  out   ($99),a

;  ld    a,(VDP_8)         ;sprites off
;  or    %00000010
;  ld    (VDP_8),a
;  out   ($99),a
;  ld    a,8+128
;  out   ($99),a

;  xor   a                 ;set s#0
;  out   ($99),a
;  ld    a,15+128
;  out   ($99),a

;  ld    a,1               ;lineint flag gets set
;  ld    (Worldmapvblankintflag),a  

;this flag sais we can now swap horizontal& vertical offset 
;we can swap page and we can swap sprite tables
;  ld    a,(swaptablesonvblank?)
;  or    a
;  jr    z,.end
;  call  Worldmapswap_spat_col_and_char_table

;  ld    a,(currentpage)
;  ld    (newlineintpage),a

;  ld    a,(horizontalscreenoffset)              ;prepare horizontal screen adjust for next frame
;  ld    (newlineinthoroff),a

;  ld    a,(verticalscreenoffset)               ;set vertical screen adjust
;  ld    (newlineintveroff),a
  
  ld    a,1               ;lineint flag gets set
  ld    (vblankintflag),a  

;  xor   a
;  ld    (swaptablesonvblank?),a


;.end:

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
  ld    a,2               ;Set Status register #2
  out   ($99),a
  ld    a,15+128          ;we are about to check for HR
  out   ($99),a

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
 
  ld    b,%0010 0000      ;bit to check for HBlank detection
.Waitline1:
  in    a,($99)           ;Read Status register #2
  and   b                 ;wait until start of HBLANK
  jr    nz,.Waitline1

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

  
.Waitline3:
;  in    a,($99)           ;Read Status register #2
;  and   b                 ;wait until end of HBLANK
;  jr    z,.Waitline3

;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi
;  outi

  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a

  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a

;  ld    a,3
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  call  handlemusicint     ;handle this from page3 or else!!

;  ld    a,4
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  in    a,($a8)
;  push  af                  ;store current RAM/ROM page settings
;  ld    a,(slot.page12rom)        ;all RAM except page 1+2
;  out   ($a8),a         

;  call  handlesfxint

;  ld    a,7
;  out   ($99),a
;  ld    a,7+128 ;backdrop
;  out   ($99),a

;  ld a,(lineintflag)
;  inc a
;  ld (lineintflag),a

;  pop   af                  ;recall RAM/ROM page setting
;  out   ($a8),a         

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
CameraEngine:
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
  di
  out   ($99),a
  ld    a,18+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  di
  out   ($99),a
  ld    a,23+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  ld    b,a
  ld    a,lineintheight
  add   a,b
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  out   ($99),a

ret  
  

CameraEngine304x216:  
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
  di
  out   ($99),a
  ld    a,18+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  di
  out   ($99),a
  ld    a,23+128
  ei
  out   ($99),a

  ld    a,(CameraY)
  ld    b,a
  ld    a,lineintheight
  add   a,b
  out   ($99),a
  ld    a,19+128            ;set lineinterrupt height
  out   ($99),a

ret

  ;set page. page 0=camerax 0-15 page 1=camerax 16-31 page 2=camerax 32-47 page 3=camerax 48-63
  ld    a,(CameraX)
  ld    b,0*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,1*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,2*32+31           ;x*32+31 (x=page)
  sub   a,16
  jp    c,setpage
  ld    b,3*32+31           ;x*32+31 (x=page)
  jp    setpage
  
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

swap_spat_col_and_char_table:
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

;putStarFoxSprite:
;	ld		a,(slot.page12rom)	;all RAM except page 1+2
;	out		($a8),a	
	
;	ld		hl,(invissprchatableaddress)		;sprite character table in VRAM ($17800)
;	ld		a,1
;	call	SetVdp_Write	

;	ld		a,StarFoxSpritesBlock
;	call	block1234		        ;set blocks in page 1/2

;	ld		hl,StarFoxShipSprite1Color
;	ld		c,$98
;	call	outix128
;	call	outix128
;	call	outix128            ;12 sprites (12 * 32 = 384 bytes)
;	call	outix128
;	call	outix128
;	call	outix128
;	call	outix128
;	call	outix128            ;32 sprites (32 * 32 = 384 bytes)

;	ld		hl,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
;	ld		a,1
;	call	SetVdp_Write

;  ld    a,15
;  ld    b,0
;  ld    c,2
;  .loop:
;  out   ($98),a
;  djnz  .loop
;  dec   c
;  jr    nz,.loop
;  ret


;  ld    a,(CameraX)
;  and   %0000 1111
;  ld    d,0
;  ld    e,a
;  ld    hl,R18ConversionTable
;  add   hl,de
;  ld    a,(hl)
;  di
;  out   ($99),a
;  ld    a,18+128
;  ei
;  out   ($99),a

;MapData:
;  ds    38 * 27           ;a map is 38 * 27 tiles big  

MapLenght:  equ 38
checktile:  
  ld    a,(Clesy)
  add   a,b

  srl   a
  srl   a
  srl   a                   ;/8

	ld		hl,MapData ;-1
.selfmodifyingcodeMapLenght:
	ld		de,MapLenght        ;38 tiles
  jr    z,.yset
  
  ld    b,a
.setmapwidthy:
	add		hl,de
  djnz  .setmapwidthy
.yset:


;now check for collision
  ld    de,(ClesX)

  srl   d
  rr    e                   ;/2
  srl   e                   ;/4
  srl   e                   ;/8

	add		hl,de
  ld    e,c
	add		hl,de
  
  ld    a,(hl)
  cp    1                   ;1 = wall
	ret

playermovementspeed:    db  2
oldx:                   dw  0
oldy:                   db  0
PlayerFacingRight?:     db  1
movePlayer:
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
  jr    z,.endcheckSpacepressed
  ld    a,(playermovementspeed)
  inc   a
  and   7
  ld    (playermovementspeed),a
  .endcheckSpacepressed:

;store old x and y, and recall these values in case of collision with a wall
  ld    hl,(ClesX)
  ld    (oldx),hl
  ld    a,(Clesy)
  ld    (oldy),a
  
  call  .move
  
  ld    b,000               ;add y to check (y is expressed in pixels)
  ld    c,1                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided
  ld    b,000               ;add y to check (y is expressed in pixels)
  ld    c,2                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided

  ld    b,016               ;add y to check (y is expressed in pixels)
  ld    c,1                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided
  ld    b,016               ;add y to check (y is expressed in pixels)
  ld    c,2                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided  

  ld    b,032               ;add y to check (y is expressed in pixels)
  ld    c,1                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided
  ld    b,032               ;add y to check (y is expressed in pixels)
  ld    c,2                 ;add x to check (x is expressed in tiles)
  call  checktile           ;out z=collision found with wall
  jr    z,.collided  
  ret
  
.collided:    
  ld    hl,(oldx)
  ld    (ClesX),hl
  ld    a,(oldy)
  ld    (Clesy),a
  ret

.move:
  ld    a,(playermovementspeed)
  ld    d,0
  ld    e,a
  
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		  0	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(Controls)
	bit		5,a           ;m pressed ?
  ret   nz

  ld    a,(Controls)
	bit		0,a           ;up pressed ?
  call  nz,.up

  ld    a,(Controls)
	bit		1,a           ;down pressed ?
  call  nz,.down

  ld    a,(Controls)
	bit		2,a           ;left pressed ?
  call  nz,.left

  ld    a,(Controls)
	bit		3,a           ;right pressed ?
  ret   z

.right:  
  ld    hl,(ClesX)
  add   hl,de
  ld    (ClesX),hl
  
  ld    a,1
  ld    (PlayerFacingRight?),a
  ret

.left:  
  xor   a
  ld    hl,(ClesX)
  sbc   hl,de
  ld    (ClesX),hl

;  xor   a
  ld    (PlayerFacingRight?),a
  ret
  
.up:  
  ld    a,(Clesy)
  sub   e
  ld    (Clesy),a
  ret

.down:  
  ld    a,(Clesy)
  add   e
  ld    (Clesy),a
  ret

ClesX:  dw 11
ClesY:  db 150
SetClesSprites:
  ld    a,(ClesY)
  ld    b,a
  add   a,16
  ld    c,a

  ld    a,(CameraX)         ;camera jumps 16 pixels every page, subtract this value from x Cles
  and   %1111 0000
  
  ld    d,0
  ld    e,a
  
  ld    hl,(ClesX)
  sbc   hl,de               ;take x Cles and subtract the x camer

  ld    a,h                 ;if the value now is <0 or >256 Cles is out of the screen
  or    a
;  jp    m,.outofscreenleft
  jp    nz,.outofscreen

  ld    a,l
  jp    .putx

.outofscreen:
  ld    a,255
.putx:

  ld    de,3
  ld    hl,spat+88          ;y sprite 22
  ld    (hl),b
  inc   hl                  ;x sprite 22
  ld    (hl),a
  add   hl,de
  ld    (hl),b
  inc   hl                  ;x sprite 22
  ld    (hl),a
  add   hl,de
  ld    (hl),c
  inc   hl                  ;x sprite 22
  ld    (hl),a
  add   hl,de
  ld    (hl),c
  inc   hl                  ;x sprite 22
  ld    (hl),a
  add   hl,de
  ret

SetBorderMaskingSprites:
  ld    hl,spat+0           ;y sprite 1
  ld    de,3
  ld    b,11                ;amount of sprites left side screen
  
  ld    a,(CameraX)
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

putspattovram:
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