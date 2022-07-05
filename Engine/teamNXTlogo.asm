TeamNXTLogoRoutine:
  ld    d,TeamNXTLogoTransparantGraphicsblock
  ld    hl,$0000                  ;page 0 - screen 5
  ld    b,0
  call  copyGraphicsToScreen      ;copies $8000 bytes (256x256) to screen

  ld    d,TeamNXTLogoNonTransparantGraphicsblock
  ld    hl,$8000                  ;page 1 - screen 5
  ld    b,0
  call  copyGraphicsToScreen      ;copies $8000 bytes (256x256) to screen

  ld    d,LightTunnelGraphicsblock
  ld    hl,$8000                  ;page 3 - screen 5
  ld    b,1
  call  copyGraphicsToScreen      ;copies $8000 bytes (256x256) to screen

  
  ld    a,2*32+31
  call  setpage                   ;in a->x*32+31 (x=page)

  ld    hl,TeamNXTLogoPalette
  call  setpalette

  ld    hl,CleanPage2
  call  DoCopy

  ld    a,0
  call  CopyLogoPartRoutine
  ld    a,1
  call  CopyLogoPartRoutine
  
  xor   a
  ld    (LogoAnimationPhase),a
  ld    (LogoAnimationTimer1),a
  ld    (LogoAnimationTimer2),a
  ld    (LogoAnimationTimer3),a
  ld    (LogoAnimationVar1),a
  ld    (LogoAnimationVar2),a
  ld    (LogoAnimationVar3),a
  
  .loop:
  halt  
  ld    a,(framecounter)
  inc   a
  ld    (framecounter),a
  call  .HandlePhase
  jp    .loop

.HandlePhase:
  ld    a,(LogoAnimationPhase)
  or    a
  jp    z,LogoAnimationPhase0     ;0 = transparant block rotating
  dec   a
  jp    z,LogoAnimationPhase1     ;1 = transition from transparant block to non transparant blocks
  dec   a
  jp    z,LogoAnimationPhase2     ;2 = non transparant blocks only for a while
  dec   a
  jp    z,LogoAnimationPhase3     ;3 = transition from non transparant blocks to black blocks
  dec   a
  jp    z,LogoAnimationPhase4     ;4 = Light Tunnel
  ret

WhichBlocksTable1: ;from transparant to non transparant
  db    1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,1,0,1,1,0,1,1,1,0,1,1,1,1,0,1,1,1,1,1,0
WhichBlocksTable2: ;non transparant to black
  db    1,1,2,1,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,1,1,2,1,1,2,1,2,2,1,2,2,2,1,2,2,2,2,1,2,2,2,2,2,1,2

LogoAnimationPhase4:
  ld    a,(framecounter)
  and   7
  ret   nz

  ld    a,(LogoAnimationVar1)
  inc   a
  ld    (LogoAnimationVar1),a  
  and   7
  jr    nz,.NotEndColor
  ld    a,(LogoAnimationVar2)
  inc   a
  ld    (LogoAnimationVar2),a  

  .NotEndColor:
  ld    c,a
  add   a,a                       ;*2
  add   a,a                       ;*4
  add   a,a                       ;*8
  add   a,a                       ;*16
  add   a,c
  ld    b,a

;  ld    a,(LogoAnimationVar2)     ;write to this palette color
  ld    a,4                       ;write to this palette color
	out		($99),a
	ld		a,16+128
	out		($99),a
  ld    a,b                       ;0 R2 R1 R0 0 B2 B1 B0

  .loop:

  bit   0,b
  jr    z,.Setb
  ld    a,%0111 0111
  .Setb:
  out   ($9a),a
  ld    a,c                       ;0 0 0 0 0 G2 G1 G0

  bit   0,c
  jr    z,.Setc
  ld    a,%0000 0111
  .Setc:
  out   ($9a),a
  or    a
  ret   z
  
  dec   c
  ld    a,b
  sub   %0001 0001
  ld    b,a
  jp    .loop

LogoAnimationPhase3:              ;transition from non transparant blocks to black blocks
  ld    a,(LogoAnimationVar2)
  inc   a
  ld    (LogoAnimationVar2),a
  cp    46
  jr    nz,.EndTableCheck
  ld    a,4
  ld    (LogoAnimationPhase),a
  xor   a
  ld    (LogoAnimationVar1),a
  ld    (LogoAnimationVar3),a
  ld    a,4
  ld    (LogoAnimationVar2),a     ;write to this palette color

  ld    a,3*32+31
  call  setpage                   ;in a->x*32+31 (x=page)

  ld    hl,TeamNXTLogoTunnelBlackPalette
  jp    setpalette
  .EndTableCheck:

  ld    hl,WhichBlocksTable2-1
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)
  ld    (CopyLogoPart+sPage),a    ;0=transparant blocks, 1=non transparant blocks, 2=black blocks

  call  SmallBlock
  call  BigBlock
  ret
  
LogoAnimationPhase2:              ;non transparant blocks only for a while
  ld    a,1                       ;sPage
  ld    (CopyLogoPart+sPage),a    ;0=transparant blocks, 1=non transparant blocks, 2=black blocks
  
  call  SmallBlock
  call  BigBlock
  ld    a,(LogoAnimationVar1)
  inc   a
  ld    (LogoAnimationVar1),a
  
  cp    150
  
  ret   nz
  ld    a,3
  ld    (LogoAnimationPhase),a
  xor   a
  ld    (LogoAnimationVar2),a  
  ret

LogoAnimationPhase1:              ;transition from transparant block to non transparant blocks
  ld    a,(LogoAnimationVar2)
  inc   a
  ld    (LogoAnimationVar2),a
  cp    39
  jr    nz,.EndTableCheck
  ld    a,2
  ld    (LogoAnimationPhase),a
  ret
  .EndTableCheck:

  ld    hl,WhichBlocksTable1-1
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)
  ld    (CopyLogoPart+sPage),a    ;0=transparant blocks, 1=non transparant blocks, 2=black blocks

  call  SmallBlock
  call  BigBlock
  ret
  
LogoAnimationPhase0:              ;transparant block rotating
  xor   a                         ;sPage
  ld    (CopyLogoPart+sPage),a    ;0=transparant blocks, 1=non transparant blocks, 2=black blocks
  
  call  SmallBlock
  call  BigBlock
  ld    a,(LogoAnimationVar1)
  inc   a
  inc   a
  inc   a
  inc   a
  ld    (LogoAnimationVar1),a
  ret   nz
  ld    a,1
  ld    (LogoAnimationPhase),a
  ret

BigBlock:                         ;rotate big block
  ld    a,(LogoAnimationTimer3)
  inc   a
  cp    6
  jr    nz,.EndCheckLastStepTimer3
  xor   a
  .EndCheckLastStepTimer3:
  ld    (LogoAnimationTimer3),a

  jr    z,.go
  ld    a,(LogoAnimationTimer2)
  dec   a
  ld    (LogoAnimationTimer2),a
  .go:
  
  ld    a,(LogoAnimationTimer2)
  inc   a
  cp    10
  jr    nz,.EndCheckLastStep
  xor   a
  .EndCheckLastStep:
  ld    (LogoAnimationTimer2),a
  add   a,2 + 10
  jp    CopyLogoPartRoutine
  
SmallBlock:                       ;rotate small block
  ld    a,(framecounter)
  and   3
  jr    z,.go
  ld    a,(LogoAnimationTimer1)
  dec   a
  ld    (LogoAnimationTimer1),a
  .go:
  
  ld    a,(LogoAnimationTimer1)
  inc   a
  cp    10
  jr    nz,.EndCheckLastStep
  xor   a
  .EndCheckLastStep:
  ld    (LogoAnimationTimer1),a
  add   a,2
  jp    CopyLogoPartRoutine

SetTransparantOrNonTransparant:  
  ld    a,(Framecounter)
  or    a
  ld    a,1                       ;sPage
  jp    p,.SetsPage
  xor   a  
  .SetsPage:
  ld    (CopyLogoPart+sPage),a
  ret

CopyLogoPartRoutine:
  add   a,a                       ;*2
  ld    b,a
  add   a,a                       ;*4
  add   a,b                       ;*6  
  
  ld    d,0
  ld    e,a
  ld    ix,CopyInstructionsLogo
  add   ix,de

  ld    a,2
  ld    (CopyLogoPart+dPage),a

  ld    a,(ix+0)                  ;sx
  ld    (CopyLogoPart+sx),a
  ld    a,(ix+1)                  ;sy
  ld    (CopyLogoPart+sy),a
  ld    a,(ix+2)                  ;nx
  ld    (CopyLogoPart+nx),a
  ld    a,(ix+3)                  ;ny
  ld    (CopyLogoPart+ny),a
  ld    a,(ix+4)                  ;dx
  ld    (CopyLogoPart+dx),a
  ld    a,(ix+5)                  ;dy
  ld    (CopyLogoPart+dy),a

  ld    hl,CopyLogoPart

  ld    a,(CopyLogoPart+sPage)
  cp    2
  jp    nz,DoCopy

  xor   a
  ld    (CopyLogoPart+sx),a
  ld    (CopyLogoPart+sy),a
  jp    DoCopy
  
TeamNXTLogoPalette:
  incbin "..\grapx\TeamNXTLogo\TeamNXTLogoPalette.PL" ;file palette 
TeamNXTLogoTunnelBlackPalette:
  incbin "..\grapx\TeamNXTLogo\TeamNXTLogoTunnelBlackPalette.PL" ;file palette 

CleanPage2:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,002   ;dx,--,dy,dpage
  db    000,001,000,001   ;nx,--,ny,--
  db    %1111 1111,000,$C0       ;fill   
  
CopyInstructionsLogo: ;sx, sy, nx, ny, dx, dy
;0: total logo transparant
  db    092,144,108,050,050,080
  db    200,135,056,065,158,071
;2: small transparant block
  db    000,118,032,026,052,101
  db    032,118,032,026,052,101
  db    064,118,032,026,052,101
  db    096,118,032,026,052,101
  db    128,118,032,026,052,101
  db    160,118,032,026,052,101
  db    000,144,032,026,052,101
  db    032,144,032,026,052,101
  db    000,170,032,026,052,101
  db    032,170,032,026,052,101
;12: big transparant block
  db    000,000,046,059,158,074
  db    046,000,046,059,158,074
  db    092,000,046,059,158,074
  db    138,000,046,059,158,074
  db    184,000,046,059,158,074
  db    000,059,046,059,158,074
  db    046,059,046,059,158,074
  db    092,059,046,059,158,074
  db    138,059,046,059,158,074
  db    184,059,046,059,158,074