phase	engaddr

LevelEngine:
;  call  CheckSwitchNextSong
;  call  BackdropBlue
  call  CameraEngine              ;Move camera in relation to Player's position. prepare R18, R19, R23 and page to be set on Vblank.
;  call  BackdropBlack
;  call  BackdropRed
  call  Sf2EngineObjects          ;di, restore background object, handle action object, put object in screen, handle interaction object and player, prepare page to be set on Vblank, ei 
;  call  BackdropBlack
;  call  BackdropRed
  call  Handle_HardWareSprite_Enemies_And_objects ;handle movement, out character, color and spat data
;  call  BackdropBlack
;  call  BackdropGreen
;.SelfModifyingCallBMS:
  call  SetBorderMaskingSprites   ;set border masking sprites position in Spat
;  call  BackdropBlack
;  call  BackdropGreen
  call  PutPlayersprite           ;outs char data to Vram, col data to Vram and sets spat data for player (coordinates depend on camera x+y)
;  call  PutPlayerspriteSF2Engine
;  call  BackdropBlack
;  call  BackdropGreen
  call  PutSpatToVram             ;outs all spat data to Vram
;  call  BackdropBlack
  call  CheckMapExit              ;check if you exit the map (top, bottom, left or right)
  call  CheckF1Menu               ;check if F1 is pressed and the menu can be entered
  call  CheckF2Menu               ;check if F2 is pressed and the map can be entered
;  call  BackdropBlue
  call  RePlayer_Tick             ;music routine
;  call  BackdropBlack

;Routines starting at lineint:
  xor   a                         ;wait for lineint flag to be set. It's better (for now) to put the VRAM objects directly after the lineint
  ld    hl,lineintflag
;  ld    (hl),a
.checkflag1:
  cp    (hl)
  jr    z,.checkflag1

  call  SwapSpatColAndCharTable2

;  call  BackdropGreen
  call  RestoreBackground         ;remove all vdp copies/software sprites that were put in screen last frame
  
  ;DEZE ROUTINE KAN INDIEN NODIG HELEMAAL NAAR MovementPatternsFixedPage1.asm
  call  HandlePlayerSprite        ;handles all stands, moves player, checks collision, prepares sprite offsets
  call  HandlePlayerWeapons       ;primary (sword, spear, axe, dagger) and secondary weapons (arrow, fireball, iceweapon, earthweapon, waterweapon)
;  call  BackdropBlack

  xor   a
  ld    (SnapToPlatForm?),a

;  call  BackdropOrange
	call	handle_enemies_and_objects  ;handle software sprites
;  call  BackdropBlack

  call  PopulateControls
;  call  FadeOutScreenEdges        ;routine that fades out the screen the closer you are to the edges

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

;herospritenrTimes2:       equ 12*2
herospritenrTimes2:       equ 28*2

CurrentPalette: ds  32
fadeoutsteps: equ 2
FadeOutScreenEdges:
		ld    bc,fadeoutsteps           ;fade out steps per x pixels              
		xor   a
		ld    hl,(clesX)                ;301 = rightmost position
		ld    de,fadeoutsteps*7                   
		sbc   hl,de
		jp    c,FadeOutLeftSide
		ld    hl,(clesX)                ;301 = rightmost position
		ld    de,301 - (fadeoutsteps*7)                   
		sbc   hl,de
		jp    nc,FadeOutRightSide
		ret

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
ForceMoveLeft:
		ld    a,(Controls)
		and   %1111 0111                ;right unpressed
		or    %0000 0100                ;left pressed
		ld    (Controls),a  
		ret

ForceMoveRight:
		ld    a,(Controls)
		and   %1111 1011                ;left unpressed
		or    %0000 1000                ;right pressed
		ld    (Controls),a  
		ret
  
FadeOutRightSide:
		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		call  z,ForceMoveLeft
		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		call  nz,ForceMoveRight

		sbc   hl,bc
		ld    d,0                       ;palette step (0=normal map palette, 7=completely black)
.loop:
		jr    c,SetPaletteFadeStep
		inc   d
		sbc   hl,bc
		jr    .loop

FadeOutLeftSide:
		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		call  nz,ForceMoveRight
		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		call  z,ForceMoveLeft

		add   hl,bc
		ld    d,0                       ;palette step (0=normal map palette, 7=completely black)
		.loop:
		jr    c,SetPaletteFadeStep
		inc   d
		add   hl,bc
		jr    .loop

SetPaletteFadeStep:
		xor		a                         ;start writing to palette color 0
		di
		out		($99),a
		ld		a,16+128
		out		($99),a  

		ld    b,16                      ;16 colors
		ld    hl,CurrentPalette
.loop:                          ;in d=palette step, b=amount of colors
;blue
		ld    a,(hl)                    ;0 R2 R1 R0 0 B2 B1 B0
		and   %0000 1111                ;only blue
		sub   a,d                       ;extract palette step / apply darkening
		jr    nc,.EndCheckOverFlowBlue  ;overflow ?
		xor   a                         ;no green
.EndCheckOverFlowBlue:
		ld    c,a
;red
		ld    a,(hl)                    ;0 R2 R1 R0 0 B2 B1 B0
		and   %1111 0000                ;only red
		srl   a                         ;shift all bits 1 step right
		srl   a                         ;shift all bits 1 step right
		srl   a                         ;shift all bits 1 step right
		srl   a                         ;shift all bits 1 step right
		sub   a,d                       ;extract palette step / apply darkening
		jr    nc,.EndCheckOverFlowRed   ;overflow ?
		xor   a                         ;no green
.EndCheckOverFlowRed:
		add   a,a                       ;shift all bits 1 step left
		add   a,a                       ;shift all bits 1 step left
		add   a,a                       ;shift all bits 1 step left
		add   a,a                       ;shift all bits 1 step left
		or    a,c                       ;add blue to red
		out   ($9a),a                   ;red + blue
;green
		inc   hl
		ld    a,(hl)                    ;0 0 0 0 0 G2 G1 G0
		sub   a,d                       ;extract palette step / apply darkening
		jr    nc,.EndCheckOverFlowGreen ;overflow ?
		xor   a                         ;no green
.EndCheckOverFlowGreen:
		out   ($9a),a                   ;green
		inc   hl  
		djnz  .loop

		ei
		ret



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

;objects using this: area sign, npc interaction, BreakableWall
FreeToUseFastCopy:                    ;freely usable anywhere
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,074,000   ;dx,--,dy,dpage
  db    004,000,004,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

FreeToUseFastCopy2:                   ;freely usable anywhere
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     

FreeToUseFastCopy3:                   ;freely usable anywhere
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,000,000   ;dx,--,dy,dpage
  db    000,000,000,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     
  
FreeToUseFastCopyF1Menu:               ;freely usable in F1 menu
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,074,000   ;dx,--,dy,dpage
  db    004,000,004,000   ;nx,--,ny,--
  db    000,%0000 0000,$D0       ;fast copy -> Copy from right to left     


; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;Check for F2 key to enter the world map screen
CheckF2Menu:
		ld		a,(NewPrContr)	
		and		0x80
		ret		z
		call	enableWorldMap
		jp		F2MenuRoutine

enableWorldMap:
		ld	 a,(slot.page1rom)            ;RAMROMRAMRAM
		out	 ($a8),a
		ld		a,2
		out   ($fe),A
		ld	 a,F2Menublock
		jp	 block12


; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;check if F1 is pressed and the menu can be entered
CheckF1Menu:
		ld		a,(NewPrContr)	
		; bit		6,a
		and		0x40
		ret 	z
		ld    a,(slot.page1rom)            ;RAMROMRAMRAM
		out   ($a8),a
		ld    a,F1Menublock                 ;F1 Menu routine at $4000
		call  block12
		jp    F1MenuRoutine
  
RestoreBackground:                  ;all background restores should be done simultaneously at start of frame (after vblank)
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

		ld    hl,CleanOb5+restorebackground?
		bit   0,(hl)
		call  nz,.Restore

		ld    hl,CleanOb6+restorebackground?
		bit   0,(hl)
		call  nz,.Restore
		ret

.Restore:
		ld    (hl),0
		inc   hl
		jp    DoCopy
  

;switch to next page
switchpageSF2Engine:
	ld    a,(screenpage)
	inc   a
	cp    4 ;4 would be the new way, 3 is the old way
	jr    nz,SetSF2DisplayPage
	xor   a
SetSF2DisplayPage:
	ld    (screenpage),a
	add   a,a                   ;x32
	add   a,a
	add   a,a
	add   a,a
	add   a,a
	add   a,31
	ld    (PageOnNextVblank),a
	ret


;handle movement
;out: character, color and spat data  > ro: which regs, and why?
;several optimizations are possible here:
;1. selfmodifying ld hl,(invissprchatableaddress) into ld hl,nn
;2. several calls can be written out, like call SetVdp_Write
;3. the call outix32 can be changed into their respective numbers with a jp endOutChar at the end
;4. ld a,(CameraX) and %1111 0000 neg can be hardcoded
Handle_HardWareSprite_Enemies_And_objects:
		ld		a,(slot.page12rom)	;RAMROMROMRAM
		out		($a8),a	

;set the general movement pattern block at address $4000 in page 1
		ld		a,MovementPatternsFixedPage1block
		call	block12

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

		;set the movement pattern block of this enemy/object at address $8000 in page 2 
		ld    a,(ix+enemies_and_objects.movementpatternsblock)
		call	block34
		call	invokeObjectMovementPattern ;movement_enemies_and_objects            ;handle sprite movement and animation
;out hl -> address of sprite character data to out to Vram
;out a -> EnemySpritesblock
;out exx
;out de -> spritenumber*26 (used for character and color data addreess)

;set block containing sprite data of this enemy/object at address $8000 in page 2 
		call	block34

;set address to write sprite character data to
		ld		hl,(invissprchatableaddress)		        ;sprite character table in VRAM ($17800)   
		add		hl,de
		add		hl,de

		call	Backdropred	;[debug]

		ld		a,1
		call	SetVdp_WriteRemainDI

;!! ro: the next portion of code is dangerous, as is depends on data in objects..
;out character data
		exx                                           ;recall hl. hl now points to character data
		ld    a,(ix+enemies_and_objects.nrsprites)    ;amount of sprites (1 spr=64, 2 spr=60, 3 spr=54, 4 spr=48, 5 spr=42, 6 spr=36, 7 spr=30, 8 spr=24, 9 spr=18, 10 spr=12, 11 spr=6, 12 spr=0   (72 - (amount of sprites*6)))  
		ld    (RightSideOfMap.SelfModifyinJRColorData),a	;!!
		ld    (.SelfModifyinJRCharacterData),a				;!!
		ld		c,$98
			
.SelfModifyinJRCharacterData:  equ $+1
		jr    .Charloop
		call  outix384 | jp .endOutChar |call  outix352 | jp .endOutChar |call  outix320 | jp .endOutChar |call  outix288 | jp .endOutChar |call  outix256 | jp .endOutChar | call  outix224 | jp .endOutChar | call  outix192 | jp .endOutChar | call  outix160 | jp .endOutChar | call  outix128 | jp .endOutChar | call  outix96 | jp .endOutChar | call  outix64 | jp .endOutChar
.CharLoop:  
		call  outix32 ; | jp .endOutChar
.endOutChar:
;!! -- end dangerouse code
		ei

		exx											;store hl. hl now points to color data
;set address to write sprite color data to
		ld		hl,(invissprcoltableaddress)		;sprite color table in VRAM ($17400)
		add		hl,de
		ld		a,1
		call	SetVdp_WriteRemainDI

;check if sprite is left or right part of map
		ld    l,(ix+enemies_and_objects.x)  
		ld    h,(ix+enemies_and_objects.x+1)      ;x
		ld    de,304/2                            ;half of the map width > !! ro: hardcoded engine.roomlength
		sbc   hl,de
		jp    c,LeftSideOfMap

RightSideOfMap:
;out color data
		exx                                           ;recall hl. hl now points to color data 
		bit   1,(ix+enemies_and_objects.hit?)         ;check if enemy is hit ? If so, out white sprite
		jr    nz,.OutWhiteSprite

;!! ro: another piece of dangerous code depending on object data
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

		ld    a,(CameraX)                             ;camera jumps 16 pixels every page, subtract this value from x
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

		call  BackdropBlack	;[debug]
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

		call  BackdropBlack	;[debug]
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


;handle software sprites
handle_enemies_and_objects:
		ld    a,(scrollEngine)                              ;1= 304x216 engine  2=256x216 SF2 engine
		dec   a
		ret   nz

		ld		a,(slot.page12rom)	                          ; all RAM except page 1+2
		out		($a8),a	

;set the general movement pattern block at address $4000 in page 1
		ld    a,MovementPatternsFixedPage1block
		call	block12
		
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
		ld    ixl,e
		ld    ixh,d
;set the movement pattern block of this enemy/object at address $8000 in page 2 
		ld    a,(ix+enemies_and_objects.movementpatternsblock)
		call	block34
		call	invokeObjectMovementPattern
		ret
  
movementpatternsblock:  db  movementpatterns1block
; movement_enemies_and_objects:
invokeObjectMovementPattern:
		ld    l,(ix+enemies_and_objects.movementpattern)
		ld    h,(ix+enemies_and_objects.movementpattern+1)
		jp    (hl)


;copy any object into screen in the normal engine
CopyObject:
		db    000,000,216,001   ;sx,--,sy,spage
		db    000,000,000,000   ;dx,--,dy,dpage
		db    000,000,000,000   ;nx,--,ny,--
		db    000,%0000 0100,$90       ;slow transparant copy -> Copy from right to left

CleanObjectTableLenght: equ CleanOb2-CleanOb1
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

		db    0                 ;restorebackground?
CleanOb5:
		db    000,000,000,000   ;sx,--,sy,spage
		db    000,000,000,000   ;dx,--,dy,dpage
		db    002,000,001,000   ;nx,--,ny,--
		db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

		db    0                 ;restorebackground?
CleanOb6:
		db    000,000,000,000   ;sx,--,sy,spage
		db    000,000,000,000   ;dx,--,dy,dpage
		db    002,000,001,000   ;nx,--,ny,--
		db    000,%0000 0100,$D0       ;fast copy -> Copy from right to left     

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

PuzzleSwitchTable1: db  3,0,1,0,2,3,1,0,2,3
PuzzleSwitchTable2: db  0,1,2,3,1,3,0,   0,0,0
PuzzleSwitchTable3: db  0,1,2,3   ,0,0,0,0,0,0
PuzzleSwitchTable4: db  3,1,3,2,0   ,0,0,0,0,0
PuzzleSwitchTable5: db  2,3,3,   0,0,0,0,0,0,0
PuzzleSwitchTable6: db  0,3,2,1,   0,0,0,0,0,0
PuzzleSwitchTable7: db  2,1,   0,0,0,0,0,0,0,0
PuzzleSwitchTable8: db  2,2,2,   0,0,0,0,0,0,0
PuzzleSwitchTable9: db  3,   0,0,0,0,0,0,0,0,0
PuzzleSwitchTable10: db 0,3,2,0,1,   0,0,0,0,0
ShowOverView?:  db  1

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

PuzzleSwitch46On?:db  000
PuzzleSwitch47On?:db  000
PuzzleSwitch48On?:db  000

PuzzleSwitch49On?:db  000
PuzzleSwitch50On?:db  000
PuzzleSwitch51On?:db  000
PuzzleSwitch52On?:db  000

PuzzleSwitch53On?:db  000
PuzzleSwitch54On?:db  000

PuzzleSwitch55On?:db  000
PuzzleSwitch56On?:db  000
PuzzleSwitch57On?:db  000
PuzzleSwitch58On?:db  000

PuzzleSwitch59On?:db  000

PuzzleSwitch60On?:db  000
PuzzleSwitch61On?:db  000
PuzzleSwitch62On?:db  000
PuzzleSwitch63On?:db  000
PuzzleSwitch64On?:db  000


;Fill RAM
;in: HL=start, BC=length, A=value
fillRam:
		push de
		push hl
		pop	 de
		inc	 de
		ld 	 (hl),A
		dec bc
		ldir
		pop	de
		ret


;Clear the pushStone table
ResetPushStones:
		ld	 hl,pushStoneTable.data
		ld	 bc,pushStoneTable.numrec*pushStoneTable.reclen
		ld	 a,-1
		jp	 fillRam

AmountOfPushingStonesInCurrentRoom: ds  1
PushStoneTable:
.numRec:	equ 31
.recLen:	equ 4
.stoneY:	equ +0
.stoneX:	equ +1
.roomX:		equ +2
.roomY:		equ +3
.data:		ds pushStoneTable.numrec*pushStoneTable.reclen



SnapToPlatform?:  db  0

;check collision with player - and handle interaction of player with object.
;in: IX=objectRecord
;Out: b=255 collision right side of object. b=254 collision left side of object (ro: u sure?)
CheckCollisionObjectPlayer:
		xor   a
		ld    (ix+enemies_and_objects.SnapPlayer?),a

;check player collides with object on the bottom side. This little part is preparing b. THIS CAN BE SPED UP BY SETTING THIS AS A FIXED VARIABLE IN THE OBJECT LIST
		ld    a,(ix+enemies_and_objects.ny)
		add   a,30
		ld    b,a
;check player collides with object on the top side. c= no collision
		ld    a,(ClesY)
;check +8 pixels lower for: Rsitting,RRolling,RSitPunch,RSitShootArrow (and same for left)
SelfModifyingCodeHitBoxPlayerTopY:  equ $+1
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
		add   hl,de	;cy=0
		; ld    d,0 ;is already zero
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
 .skip:	jp    Set_Dying
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

		ld    a,(PlayerDead?)
		or    a
		ret   nz

		ld    (ClesX),hl	;ro: what happens here?
		ld    hl,(PlayerSpriteStand)
		ld    de,ClimbLadder
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
		;ld	 b,playerFeetOffsetY-4
;		ld    b,YaddFeetPLayer-4   ;add y to check (y is expressed in pixels)
;		ld    de,XaddRightPlayer-4  ;add 0 to x to check left side of player for collision (player moved left)
;		call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.rightside-4
		ld	 b,playerstanding.feet-4
		call checkTilePlayer
		jp    z,Set_Dying

		ld    b,255                       ;collision right side of object detected (used for the pushing blocks)            
		ret
    
.CollisionLeftOfObject:
		ld    a,(ix+enemies_and_objects.x)		;8bit X?
		sub   7
		ld    h,0
		ld    l,a
		;  ld    b,254                       ;collision leftside of object detected (used for the pushing blocks)            
		ld    a,(PlayerDead?)	;ro: uhm... weird place to check
		or    a
		ret   nz
		ld    (ClesX),hl                   ;ro: what's goin on here???

		;check at height of waiste if player is pushed into a wall on the left side
		;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
		; ld    b,YaddFeetPLayer-4   ;add y to check (y is expressed in pixels)
		; ld    de,XaddLeftPlayer+4   ;add 0 to x to check left side of player for collision (player moved left)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.leftside+4
		ld	 b,playerstanding.feet-4
		call checkTilePlayer
		jp    z,Set_Dying

		ld    b,254                       ;collision leftside of object detected (used for the pushing blocks)            
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

		ld    a,(PlayerFacingRight?)              ;is player facing right ?
		or    a
		jp    z,Set_L_stand
		jp    Set_R_stand

.CollisionBottomOfObject:
		ld    a,(PlayerDead?)
		or    a
		ret   nz

		ld    a,(SelfModifyingCodeHitBoxPlayerTopY)
		cp    PlayerTopYHitBoxSoftSpritesSitting  ;are we sitting ?
		jr    z,.YesWeAreSitting
		;at this point we hit our head into an object. If we are jumping, then no need to force sitting

		ld		hl,(PlayerSpriteStand)
		ld		de,Jump
		or    a
		sbc   hl,de
		jr    z,.YesWeAreJumping

		ld    a,(PlayerFacingRight?)              ;is player facing right ?
		or    a
		jp    z,Set_L_sit
		jp    Set_R_sit

.YesWeAreJumping:
.YesWeAreSitting:
		ld    a,(ix+enemies_and_objects.y)
		add   a,(ix+enemies_and_objects.ny)
		add   a,14d
		ld    (ClesY),a

;		ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
;		ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
;		call  checktile           ;out z=collision found with wall  

;check at height of waiste if player runs into a wall on the left side
		; ld    b,YaddFeetPlayer    ;add y to check (y is expressed in pixels)
		; ld    de,XaddLeftPlayer+8 ;add 0 to x to check left side of player for collision (player moved left)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.leftside+8
		ld	 b,playerstanding.feet
		call checkTilePlayer
		call  z,Set_Dying
		ret

PutPlayerspriteSF2Engine:
		ld    a,$05
		di
		out   ($99),a       ;set bits 15-17
		ld    a,14+128
		ei
		out   ($99),a       ;/first set register 14 (actually this only needs to be done once)

PutPlayerSpriteMeditateSplit:
		ld    hl,(ClesX)
		push  hl
		ld    a,(ClesY)
		push  af

		ld    hl,100
		ld    (ClesX),hl
		ld    a,90
		ld    (ClesY),a

		ld    hl,PlayerSpriteData_Char_RightMeditate5
		call  ContinueAfterMeditateSplit

		pop   af
		ld    (ClesY),a
		pop   hl
		ld    (ClesX),hl
		ret

PutPlayersprite:
	ld		a,(slot.page12rom)	;all RAM except page 1+2
	out		($a8),a	

;standchar:	equ	$+1
		ld	 hl,(standchar) ;PlayerSpriteData_Char_RightStand  ;sprite character in ROM
ContinueAfterMeditateSplit:
		ld	 a,PlayerSpritesBlock 
		bit	 0,l                                   ;if bit 0 of address of character is set, then add 4 blocks to starting blocks
		jr	 z,.go
		add	 a,2
.go:	call block1234		;set blocks in page 1/2
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

;  ld    a,(framecounter)
;  and   1
;  jr    z,.skip
;  ld    hl,PlayerSpriteData_Char_Empty+2
;  .skip:

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
		ld    c,a
		; sub   a,16
		add	 a,playerSpriteOffsetY
		ld    b,a
;		add   a,16
;		ld    c,a

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
  dec   a
  ret   z

	ld		a,(slot.page12rom)	                          ; all RAM except page 1+2
	out		($a8),a	
;  ld    a,movepatblo1 ; (movementpatternsblock)
;	call	block1234			                                ;at address $4000 / page 1+2

  ld    de,enemies_and_objects+(0*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck
  ld    de,enemies_and_objects+(1*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck
  ld    de,enemies_and_objects+(2*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck
  ld    de,enemies_and_objects+(3*lenghtenemytable)   ;if alive?=2 (SF2 engine) object is found                                    
  ld    a,(de) | cp 2 | call z,.docheck

	ld		a,(slot.ram)	      ;back to full RAM
	out		($a8),a	
  ret

  .docheck:
  ld    ixl,e
  ld    ixh,d    

  ;set the general movement pattern block at address $4000 in page 1
  di
  ld    a,MovementPatternsFixedPage1block
	ld		(memblocks.1),a
	ld		($6000),a
;  ei

  ;set the movement pattern block of this enemy/object at address $8000 in page 2 
  ld    a,(ix+enemies_and_objects.movementpatternsblock)
;  di
	ld		(memblocks.2),a
	ld		($7000),a
	ei

  ld    l,(ix+enemies_and_objects.movementpattern)    ;movementpattern
  ld    h,(ix+enemies_and_objects.movementpattern+1)  ;movementpattern
  jp    (hl)

Object1RestoreBackgroundTable:
  dw    RestoreBackgroundObject1Page3,RestoreBackgroundObject1Page0,RestoreBackgroundObject1Page1,RestoreBackgroundObject1Page2
Object2RestoreBackgroundTable:
  dw    RestoreBackgroundObject2Page3,RestoreBackgroundObject2Page0,RestoreBackgroundObject2Page1,RestoreBackgroundObject2Page2
Object3RestoreBackgroundTable:
  dw    RestoreBackgroundObject3Page3,RestoreBackgroundObject3Page0,RestoreBackgroundObject3Page1,RestoreBackgroundObject3Page2
Object4RestoreBackgroundTable:
  dw    RestoreBackgroundObject4Page3,RestoreBackgroundObject4Page0,RestoreBackgroundObject4Page1,RestoreBackgroundObject4Page2
Object5RestoreBackgroundTable:
  dw    RestoreBackgroundObject5Page3,RestoreBackgroundObject5Page0,RestoreBackgroundObject5Page1,RestoreBackgroundObject5Page2
Object6RestoreBackgroundTable:
  dw    RestoreBackgroundObject6Page3,RestoreBackgroundObject6Page0,RestoreBackgroundObject6Page1,RestoreBackgroundObject6Page2
Object7RestoreBackgroundTable:
  dw    RestoreBackgroundObject7Page3,RestoreBackgroundObject7Page0,RestoreBackgroundObject7Page1,RestoreBackgroundObject7Page2

;if we are in page 0 we prepare to restore page 1 in the next frame
;if we are in page 1 we prepare to restore page 2 in the next frame
;if we are in page 2 we prepare to restore page 3 in the next frame
;if we are in page 3 we prepare to restore page 0 in the next frame
restoreBackgroundObject1:
  ld    hl,Object1RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject2:
  ld    hl,Object2RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject3:
  ld    hl,Object3RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject4:
  ld    hl,Object4RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject5:
  ld    hl,Object5RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject6:
  ld    hl,Object6RestoreBackgroundTable
  jp    GoRestoreObject
restoreBackgroundObject7:
  ld    hl,Object7RestoreBackgroundTable
  jp    GoRestoreObject

GoRestoreObject:
  ld    a,(screenpage)
  add   a,a
  ld    b,0
  ld    c,a
  add   hl,bc
  ld    a,(hl)
  inc   hl
  ld    h,(hl)
  ld    l,a
  jp    docopy



RestoreBackgroundObject1Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject1Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject1Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject1Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject2Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject2Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject2Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject2Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject3Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject3Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject3Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject3Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0

RestoreBackgroundObject4Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject4Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject4Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject4Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject5Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject5Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject5Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject5Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0  

RestoreBackgroundObject6Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject6Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject6Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject6Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0

RestoreBackgroundObject7Page0:
	db    0,0,0,3
	db    0,0,0,0
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject7Page1:
	db    0,0,0,0
	db    0,0,0,1
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject7Page2:
	db    0,0,0,1
	db    0,0,0,2
	db    $02,0,$02,0
	db    0,0,$d0  
RestoreBackgroundObject7Page3:
	db    0,0,0,2
	db    0,0,0,3
	db    $02,0,$02,0
	db    0,0,$d0    


;SF2 global properties for current object and frame
HugeObjectFrame:	db  -1
blitpage:			db  0
screenpage:			db  2
Player1Frame:		dw  0 ;ryupage0frame000
;Player1FramePage:             db  0
Object1y:			db  0
Object1x:			db  0
PutObjectInPage3?:				db  0
RestoreBackgroundSF2Object?:	db  1

;Frameinfo looks like this:
;width, height, offset x, offset y
;x offset for first line
;lenght ($1f)+increment ($80) next spriteline, source address (base+00000h etc)
;  dw 01F80h,base+00000h
ScreenLimitxRight:				equ 256-10
ScreenLimitxLeft:				equ 10
moveplayerleftinscreen:			equ 128

Object1RestoreTable:
  dw    RestoreBackgroundObject1Page1,RestoreBackgroundObject1Page2,RestoreBackgroundObject1Page3,RestoreBackgroundObject1Page0
Object2RestoreTable:
  dw    RestoreBackgroundObject2Page1,RestoreBackgroundObject2Page2,RestoreBackgroundObject2Page3,RestoreBackgroundObject2Page0
Object3RestoreTable:
  dw    RestoreBackgroundObject3Page1,RestoreBackgroundObject3Page2,RestoreBackgroundObject3Page3,RestoreBackgroundObject3Page0
Object4RestoreTable:
  dw    RestoreBackgroundObject4Page1,RestoreBackgroundObject4Page2,RestoreBackgroundObject4Page3,RestoreBackgroundObject4Page0
Object5RestoreTable:
  dw    RestoreBackgroundObject5Page1,RestoreBackgroundObject5Page2,RestoreBackgroundObject5Page3,RestoreBackgroundObject5Page0
Object6RestoreTable:
  dw    RestoreBackgroundObject6Page1,RestoreBackgroundObject6Page2,RestoreBackgroundObject6Page3,RestoreBackgroundObject6Page0
Object7RestoreTable:
  dw    RestoreBackgroundObject7Page1,RestoreBackgroundObject7Page2,RestoreBackgroundObject7Page3,RestoreBackgroundObject7Page0

PutSF2Object:	;section#1
  ld    hl,Object1RestoreTable
;  ld    ix,RestoreBackgroundCopyObject1
  jp    PutSF2ObjectSlice
PutSF2Object2:	;section#2
  ld    hl,Object2RestoreTable
;  ld    ix,RestoreBackgroundCopyObject2
  jp    PutSF2ObjectSlice
PutSF2Object3:	;section#3
  ld    hl,Object3RestoreTable
;  ld    ix,RestoreBackgroundCopyObject3
  jp    PutSF2ObjectSlice
PutSF2Object4:	;section#4
  ld    hl,Object4RestoreTable
;  ld    ix,RestoreBackgroundCopyObject4
  jp    PutSF2ObjectSlice
PutSF2Object5:	;section#5
  ld    hl,Object5RestoreTable
;  ld    ix,RestoreBackgroundCopyObject5
  jp    PutSF2ObjectSlice
PutSF2Object6:	;section#5
  ld    hl,Object6RestoreTable
;  ld    ix,RestoreBackgroundCopyObject5
  jp    PutSF2ObjectSlice
PutSF2Object7:	;section#5
  ld    hl,Object7RestoreTable
;  ld    ix,RestoreBackgroundCopyObject5
  jp    PutSF2ObjectSlice

;if we are in page 0 we prepare to restore page 1 in the next frame
;if we are in page 1 we prepare to restore page 2 in the next frame
;if we are in page 2 we prepare to restore page 3 in the next frame
;if we are in page 3 we prepare to restore page 0 in the next frame
PutSF2ObjectSlice:
  bit   0,(ix+enemies_and_objects.v1-3)     ;v1-3=boss got hit this frame (1=hit normal/no damage, 3=hit with correct element)
  jr    z,.EndChangeColorBoss               ;not hit = don't change colors
  bit   1,(ix+enemies_and_objects.v1-3)     ;v1-3=boss got hit this frame (1=hit normal/no damage, 3=hit with correct element)
  ld    c,TotallyRedSpritedatablock
  jr    z,.EndChangeColorBoss
  ld    c,TotallyWhiteSpritedatablock
  .EndChangeColorBoss:

	ld    a,(screenpage)
  add   a,a
  ld    d,0
  ld    e,a
  add   hl,de
  ld    a,(hl)
  ld    ixl,a
  inc   hl
  ld    a,(hl)
  ld    ixh,a

;	ld    a,(screenpage)
;  ld    (ix+sPage),a
;  inc   a
;  and   3
;  ld    (ix+dPage),a

;Put a section of an SF2 object on screen, max 5 sections.
;in b->framelistblock, c->spritedatablock
	ld		a,(slot.page12rom)		;all RAM except page 1+2
	out		($a8),a	
	ld		a,(memblocks.2)
	push	af		;store current block
	ld		a,c		;set framedata in page 1 in rom ($4000 - $7fff)  
	call	block12
	ld		a,b		;set framelist in page 2 in rom ($8000 - $bfff)
	call	block34
 
	di
	call  GoPutSF2Object
	ei

;edit: general movement pattern block is not required anymore at this point
;set the general movement pattern block at address $4000 in page 1
;	di
	ld	a,MovementPatternsFixedPage1block
	ld	(memblocks.1),a
	ld	($6000),a
;*** LITTLE CORRECTION for PutSf2Object3Frames when using   jp    switchpageSF2Engine after putting SF2 object
;set the movement pattern block of this enemy/object at address $8000 in page 2 
	pop	af                    ;recall movement pattern block of current object
	ld	(memblocks.2),a
	ld	($7000),a
;	ei
  ret




GoPutSF2Object:
	ld    bc,(object1y)		;b=x,c=y ;bc,Object1y
	ld    hl,(Player1Frame)	;points to object width
	ld    iy,Player1SxB1	;player collision detection blocks

;20240531;ro;removed as it didn't do anything, really
;;screen limit right
;	ld    a,(bc)                ;object x
;	cp    ScreenLimitxRight
;	jp    c,.LimitRight
;	ld    a,ScreenLimitxRight
;;	ld    (bc),a
;.LimitRight:
;;screen limit left
;	ld    a,(bc)                ;object x
;	cp    ScreenLimitxLeft
;	jp    nc,.LimitLeft
;	ld    a,ScreenLimitxLeft
;; 	ld    (bc),a
;.LimitLeft:

;Prep restore-copy for this slice. IX=copyTable
	ld    a,(hl)		;(sliceWidth)
	inc   hl
	ld    (ix+nx),a		
	ld    a,(hl)		;(sliceHeight)
	inc   hl
	ld    (ix+ny),a
;set sy,dy by adding offset y to object y
	ld    a,c ;(bc)		;object Y
	inc   hl
	add   a,(hl)		;(sliceY)
	dec   hl
	ld    d,a
	ld    (ix+sy),a
	ld    (ix+dy),a
	ld    (iy+1),a		;Player1SyB1 (set block 1 sy)
;set sx,dx by adding slice.x to object.x
	ld    e,(hl)		;(sliceX)
	inc   hl			;=sliceY
	inc   hl			;=sliceOffset
	ld    a,b ;(bc)		;object x
	or    a
	jp    p,PutSpriteleftSideOfScreen

PutSpriteRightSideOfScreen:
	sub   a,moveplayerleftinscreen
	add   a,e
	jp    c,putplayer_clipright_totallyoutofscreenright

	ld    (ix+sx),a		;set sx/dx to restore by background
	ld    (ix+dx),a

;clipping check
	ld    a,b			;(bc)		;object X
	sub   moveplayerleftinscreen
	add   a,e			;object.X+frame.X
	add   a,(ix+nx)
	jp    c,putplayer_clipright
	jp    putplayer_noclip

 
PutSpriteleftSideOfScreen:
	sub   a,moveplayerleftinscreen
	add   a,e	;e=frame.X
	jr    c,.carry
	xor   a
.carry:
	ld    (ix+sx),a             ;set sx/dx to restore by background
	ld    (ix+dx),a
;set sy,dy by adding offset y to object y
;	inc   hl
;	dec   bc
;	ld    a,(bc)		;object Y
;	add   a,(hl)		;FrameY
;	ld    d,a
;	ld    (ix+sy),a		;set sy/dy to restore by background
;	ld    (ix+dy),a
;	ld    (iy+1),a		;Player1SyB1 (set block 1 sy)
;Set up restore background que player
;	inc   bc			;=object x
;clipping check
	ld    a,b		;(bc)		;object X
	sub   a,moveplayerleftinscreen
	add   a,e			;object.X+frame.X
	jp    nc,putplayer_clipleft
	jp    putplayer_noclip


;The old list files had unused bytes, skip if that version is used.
SkipFrameBytes:
	inc   hl
	ld    a,(hl)
	dec   hl
	and   A
	ret   nz
	ld    bc,7			;skip unused bytes
	add   hl,bc  
	ret

;in: HL=frameHeader.frameOffset
putplayer_noclip:
	ld    a,b ;(bc)		;object.X
	add   a,(hl)		;add frameOffset for first line to destination x
	inc   hl
	sub   a,moveplayerleftinscreen
	ld    e,a

	call	SkipFrameBytes

	ld    a,(PutObjectInPage3?)
	or    a
	jr    nz,.not3
  ;if screenpage=0 then blit in page 1
  ;if screenpage=1 then blit in page 2
  ;if screenpage=2 then blit in page 3
  ;if screenpage=3 then blit in page 0
	ld    a,(screenpage)
	inc   a

;	cp    4 ;4 would be the new way, 3 is the old way
;	jr    nz,.not3
;	xor   a
	and   3
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
	set   6,d                   ;set write access

;Transfer pixel array to screen
	ld    (spatpointer),sp  
	ld    sp,hl

	ld    a,e
	ld    c,$98
.loop:
	out   ($99),a               ;set x to write to
	ld    a,d
	out   ($99),a               ;set y to write to

	pop   hl                    ;  
	ld    b,h                   ;numPix
	ld    a,l                   ;totalLength (numpix+whitespace)
	pop   hl                    ;pop array address
	otir
	or    a						;is there more?
	jr    z,.exit

	add   a,e                   ;To next array
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
  ld    (Player1Frame),sp     ;store end of this slice (when will be the start of the next slice)
	ld    sp,(spatpointer)
	ret
  
  
;Player1Frame: ds  2

putplayer_clipright_totallyoutofscreenright:
;20240531;ro;this does absolutely nothing...
;  inc   hl                    ;player y offset
;  inc   hl                    ;=frameOffset
;  inc   hl                    ;=...
;  inc   bc                    ;player x
;  ld    a,(bc)                ;player x
;  sub   a,moveplayerleftinscreen
;  add   a,(hl)                ;add player x offset for first line
;  ld    e,a
;;  jp    SetOffsetBlocksAndAttackpoints
	ret
  
putplayer_clipright:
	ld    a,b ;(bc)		;object.X
	add   a,(hl)		;add frameOffset for first line to destination x
	inc   hl
	sub   a,moveplayerleftinscreen
	ld    e,a

	call  SkipFrameBytes

	ld    a,(PutObjectInPage3?)
	or    a
	jr    nz,.not3
;if screenpage=0 then blit in page 1
;if screenpage=1 then blit in page 2
;if screenpage=2 then blit in page 0
	ld    a,(screenpage)
	inc   a
;	cp    4 ;4 would be the new way, 3 is the old way
;	jr    nz,.not3
;	xor   a
	and   3
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

;Transfer pixel array to screen
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

	ld    a,l                   ;totalLength (numpix+whitespace)
	pop   hl                    ;pop array address
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
  ld    (Player1Frame),sp
	ld    sp,(spatpointer)
	ret

.totallyoutofscreenright:
	ld    a,l
	pop   hl
	jp    .skipotir             ;piece is totally out of screen, dont otir


putplayer_clipleft:
	ld    a,b	;X (bc)
	add   a,(hl)
	inc   hl
	sub   a,moveplayerleftinscreen
	ld    e,a
	jp    nc,.notcarry
	dec   d
.notcarry:
	call	SkipFrameBytes

	ld    a,(PutObjectInPage3?)
	or    a
	jr    nz,.not3
  ;if screenpage=0 then blit in page 1
  ;if screenpage=1 then blit in page 2
  ;if screenpage=2 then blit in page 0
	ld    a,(screenpage)
	inc   a
;	cp    4 ;4 would be the new way, 3 is the old way
;	jr    nz,.not3
;	xor   a
	and   3
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
	set   6,d                   ;set write access

;Transfer pixel array to screen
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
  ld    (Player1Frame),sp
	ld    sp,(spatpointer)
	ret  



  

;SetOffsetBlocksAndAttackpoints:


;  Setblock1:
;  ld    a,(bc)                ;player x
;  or    a
;  jp    p,PlayerLeftOfscreenSetBlocksAndattackpoints

;.PlayerRightOfscreenSetBlocksAndattackpoints:
  ;block 1
;  sub   a,moveplayerleftinscreen
;  inc   hl                    ;offsetx Block1
;  add   a,(hl)
;  jp    nc,.notcarry1
;  ld    a,252                 ;if Sx Block1 is out of screen right, then set sx Block to 252
;  .notcarry1:
;  ld    (iy+0),a              ;Sx block 1
;  inc   hl                    ;Nx block 1
;  ld    a,(hl)
;  ld    (iy+2),a              ;Nx block 1
;  inc   hl                    ;Ny block 1
;  ld    a,(hl)
;  ld    (iy+3),a              ;Ny block 1
;  add   a,(iy+1)              ;Ny block 1 + Sy block 1
;  ld    (iy+5),a              ;Sy block 2

  ;block 2
;  ld    a,(bc)                ;player x
;  sub   a,moveplayerleftinscreen
;  inc   hl                    ;offsetx Block1
;  add   a,(hl)
;  jp    nc,.notcarry2
;  ld    a,252                 ;if Sx Block1 is out of screen right, then
;  .notcarry2:
;  ld    (iy+4),a              ;Sx block 2
;  inc   hl                    ;Nx block 2
;  ld    a,(hl)
;  ld    (iy+6),a              ;Nx block 2
;  ld    a,(ix+ny)             ;player height total (=Ny block 1 + Ny block 2)
;  sub   a,(iy+3)
;  ld    (iy+7),a              ;Ny block 2

  ;attack point1
;  inc   hl                    ;attack point 1 offset x
;  ld    a,(hl)
;  or    a
;  jr    z,.setattackpoint1sx  ;if there is no attack point, then set attackpoint1sx to 0

;  ld    a,(bc)                ;player x
;  add   a,(hl)
;  jp    c,.carry1
;  sub   a,moveplayerleftinscreen
;  jp    .setattackpoint1sx
;  .carry1:
;  sub   a,moveplayerleftinscreen
;  jp    c,.setattackpoint1sx
;  ld    a,254
;  .setattackpoint1sx:
;  ld    (iy+8),a              ;attack point 1 sx
;  inc   hl                    ;attack point 1 offset y
;  dec   bc                    ;player y
;  ld    a,(bc)                ;player y
;  add   a,(hl)
;  ld    (iy+9),a              ;attack point 1 sy

  ;attack point2
;  inc   hl                    ;attack point 2 offset x
;  inc   bc
;  ld    a,(bc)                ;player x
;  add   a,(hl)
;  jp    c,.carry2
;  sub   a,moveplayerleftinscreen
;  jp    .setattackpoint2sx
;  .carry2:
;  sub   a,moveplayerleftinscreen
;  jp    c,.setattackpoint2sx
;  ld    a,254
;  .setattackpoint2sx:
;  ld    (iy+10),a             ;attack point 2 sx
;  inc   hl                    ;attack point 2 offset y
;  dec   bc
;  ld    a,(bc)                ;player y
;  add   a,(hl)
;  ld    (iy+11),a             ;attack point 2 sy
;  ret

;PlayerLeftOfscreenSetBlocksAndattackpoints:
  ;block 1
;  sub   a,moveplayerleftinscreen
;  inc   hl                    ;offsetx Block1
;  add   a,(hl)
;  jp    c,.notcarry1
;  ld    (iy+0),0              ;Sx block 1
;  inc   hl                    ;Nx block 1
;  add   a,(hl)
;  jp    p,.positive1
;  ld    a,1
;  jp    .positive1
;  .notcarry1:
;  ld    (iy+0),a              ;Sx block 1
;  inc   hl                    ;Nx block 1
;  ld    a,(hl)
;  .positive1:
;  ld    (iy+2),a              ;Nx block 1
;  inc   hl                    ;Ny block 1
;  ld    a,(hl)
;  ld    (iy+3),a              ;Ny block 1
;  add   a,(iy+1)              ;Ny block 1 + Sy block 1
;  ld    (iy+5),a              ;Sy block 2

  ;block 2
;  ld    a,(bc)                ;player x
;  sub   a,moveplayerleftinscreen
;  inc   hl                    ;offsetx block 2
;  add   a,(hl)
;  jp    c,.notcarry2
;  ld    (iy+4),0              ;Sx block 2
;  inc   hl                    ;Nx block 2
;  add   a,(hl)
;  jp    p,.positive2
;  ld    a,1
;  jp    .positive2
;  .notcarry2:
;  ld    (iy+4),a              ;Sx block 2
;  inc   hl                    ;Nx block 2
;  ld    a,(hl)
;  .positive2:
;  ld    (iy+6),a              ;Nx block 2
;  ld    a,(ix+ny)             ;player height total (=Ny block 1 + Ny block 2)
;  sub   a,(iy+3)
;  ld    (iy+7),a              ;Ny block 2

  ;attack point1
;  inc   hl                    ;attack point 1 offset x
;  ld    a,(hl)
;  or    a
;  jr    z,.setattackpoint1sx  ;if there is no attack point, then set attackpoint1sx to 0

;  ld    a,(bc)                ;player x
;  add   a,(hl)
;  jp    nc,.notcarry3
;  sub   a,moveplayerleftinscreen
;  jp    .setattackpoint1sx
  
;  .notcarry3:
;  sub   a,moveplayerleftinscreen
;  jr    z,.set1a
;  cp    200
;  jp    c,.setattackpoint1sx
;  .set1a:
;  ld    a,1
;  .setattackpoint1sx:
;  ld    (iy+8),a              ;attack point 1 sx
;  inc   hl                    ;attack point 1 offset y
;  dec   bc                    ;player y
;  ld    a,(bc)                ;player y
;  add   a,(hl)
;  ld    (iy+9),a              ;attack point 1 sy

  ;attack point2
;  inc   hl                    ;attack point 2 offset x
;  inc   bc
;  ld    a,(bc)                ;player x
;  add   a,(hl)
;  sub   a,moveplayerleftinscreen
;  jr    z,.set1b
;  cp    224
;  jr    c,.setattackpoint2sx
;.set1b:
;  ld    a,1
;  .setattackpoint2sx:
;  ld    (iy+10),a             ;attack point 2 sx
;  inc   hl                    ;attack point 2 offset y
;  dec   bc
;  ld    a,(bc)                ;player y
;  add   a,(hl)
;  ld    (iy+11),a             ;attack point 2 sy
;  ret
	
base:                         equ   $4000         ;address of heroframes
;RyuActions2:
;.LeftIdleFrame:                ;current spriteframe, total animationsteps
;  db    0,4
;.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
;  db    0,8,1                 ;animation every 2,5 frames
;.LeftIdleTable:
;  dw ryupage0frame000 | db 1 | dw ryupage0frame001 | db 1
;  dw ryupage0frame002 | db 1 | dw ryupage0frame003 | db 1
;  ds  12

;GlassBallAnimationRight:
;.LeftIdleFrame:                ;current spriteframe, total animationsteps
;  db    0,8
;.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
;  db    0,1,0                 ;animation every 2,5 frames
;.LeftIdleTable:
;  dw ryupage0frame004 | db 1 | dw ryupage0frame005 | db 1
;  dw ryupage0frame006 | db 1 | dw ryupage0frame007 | db 1
;  dw ryupage0frame008 | db 1 | dw ryupage0frame009 | db 1
;  dw ryupage0frame010 | db 1 | dw ryupage0frame011 | db 1

;GlassBallAnimationLeft:
;.LeftIdleFrame:                ;current spriteframe, total animationsteps
;  db    0,8
;.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
;  db    0,1,0                 ;animation every 2,5 frames
;.LeftIdleTable:
;  dw ryupage0frame011 | db 1 | dw ryupage0frame010 | db 1
;  dw ryupage0frame009 | db 1 | dw ryupage0frame008 | db 1
;  dw ryupage0frame007 | db 1 | dw ryupage0frame006 | db 1
;  dw ryupage0frame005 | db 1 | dw ryupage0frame004 | db 1

;GlassBallAnimationFallingDown:
;.LeftIdleFrame:                ;current spriteframe, total animationsteps
;  db    0,2
;.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
;  db    0,1,0                 ;animation every 2,5 frames
;.LeftIdleTable:
;  dw ryupage0frame004 | db 1 | dw ryupage0frame008 | db 1
;  ds    18
  
;ObjectAnimation:              ;animates, forces writing spriteframe, out: z=animation ended
;  ld    ix,RyuActions2.LeftIdleFrame
;ObjectAnimationIXgiven:       ;animates, forces writing spriteframe, out: z=animation ended
;  ld    iy,Player1Frame
              
;check speed of animation
;  ld    a,(ix+3)              ;PxLeftIdleAnimationSpeed+1
;  ld    b,a
;  ld    a,(ix+2)              ;P1LeftIdleAnimationSpeed+0
;  inc   a
;  cp    b                     ;overflow check
;  jr    nz,.setanimationspeed

;  ld    a,(ix+4)              ;P1LeftIdleAnimationSpeed+2
;  or    a                     ;should animation speed fluctuate ?
;  jp    z,.endcheckfluctuate
;  ld    b,a
;  neg
;  ld    (ix+4),a              ;P1LeftIdleAnimationSpeed+2
;  ld    a,(ix+3)              ;PxLeftIdleAnimationSpeed+1
;  add   a,b
;  ld    (ix+3),a              ;PxLeftIdleAnimationSpeed+1
;  .endcheckfluctuate:
;  xor   a
;  .setanimationspeed:
;  ld    (ix+2),a              ;P1LeftIdleAnimationSpeed+0
;  jr    nz,.endchangespriteframe
;/check speed of animation

;change/animate sprite
;  ld    a,(ix+1)              ;P1LeftIdleFrame+1
;  ld    b,a
;  ld    a,(ix+0)              ;P1LeftIdleFrame+0

;  inc   a
;  cp    b                     ;overflow check
;  jr    nz,.setstep
;  xor   a
;  .setstep:
;  ld    (ix+0),a              ;P1LeftIdleFrame+0
;  .endchangespriteframe:  
;/change/animate sprite  

;  ld    a,(ix+0)              ;P1LeftIdleFrame+0
;  ld    b,a
;  add   a,a
;  add   a,b                   ;*3 to fetch frame in table
;  ld    b,0
;  ld    c,a
;  add   ix,bc
  
;  ld    a,(ix+7)              ;framepage
;  ld    (iy+2),a              ;write to framepage

;  ld    a,(ix+5)              ;fetch current Idle frame
;  ld    (iy+0),a              ;and write it to PlayerxFrame
;  ld    a,(ix+6)
;  ld    (iy+1),a

;  ld    a,(ix+0)              ;Check if animation ended
;  or    (ix+2)
;  ret

ExitRight256x216: equ 32*8-4
ExitRight304x216: equ 38*8-3
CheckMapExit:
		ld    a,(ClesY)		;Bottom?
		cp    MapHeight*8-4 ;180+8 + 24
		jr    nc,.ExitBottomFound
		cp    5				;top?
		jr    c,.ExitTopFound

		ld    a,(ClesX)		;left?
		or    a
		jp    z,.PossibleExitLeftFound
.selfmodifyingcodeMapexitRight:	;right?
		ld	 hl,ExitRight304x216
		ld	 hl,(roomMap.widthPix)
		ld	 de,(ClesX)
		sbc	 hl,de
		ret	 nc

		ld    hl,(ClesX)
		ld    de,50*8
		sbc   hl,de
		;  jr    c,.ExitRightFound
		jp    c,.ExitRightFound
		jp    .ExitLeftFound  

.ExitBottomFound:
;check if player was climbing stairs left up/ right down
		ld    de,ClimbStairsLeftUp
		ld    hl,(PlayerSpriteStand)
		xor   a
		sbc   hl,de
		jr    nz,.EndCheckClimbStairsLeftUp1
		ld    hl,(ClesX)	;adjust X position on new schreen
		ld    de,18 - 8
		add   hl,de
		ld    (ClesX),hl
.EndCheckClimbStairsLeftUp1:
;check if player was climbing stairs right up/left down
		ld    de,ClimbStairsRightUp
		ld    hl,(PlayerSpriteStand)
		xor   a
		sbc   hl,de
		jr    nz,.EndCheckClimbStairsRightUp1
		ld    hl,(ClesX)
		ld    de,-18+ 8
		add   hl,de
		ld    (ClesX),hl
.EndCheckClimbStairsRightUp1:
;  ld    de,WorldMapDataMapLenght*WorldMapDataWidth
		ld    a,6
		ld    (ClesY),a
		ld    a,0
		ld    (CameraY),a

		call enableWorldMap	;add bottom connector to next worldmap room
		ld	 de,(WorldMapPosition)
		call bwmr

		ld	 a,(WorldMapPosition.Y)
		inc	 a
		ld	 (WorldMapPosition.Y),a
		call .LoadnextMap
		ret
  
.ExitTopFound:  
;check if player was climbing stairs left up
		ld    de,ClimbStairsLeftUp
		ld    hl,(PlayerSpriteStand)
		xor   a
		sbc   hl,de
		jr    nz,.EndCheckClimbStairs2
		ld    hl,(ClesX)
		ld    de,-19 + 8 - 1
		add   hl,de
		ld    (ClesX),hl
		jp	 .EndCheckClimbStairsRightUp2
.EndCheckClimbStairs2:
;check if player was climbing stairs right up
		ld    de,ClimbStairsRightUp
		ld    hl,(PlayerSpriteStand)
		xor   a
		sbc   hl,de
		jr    nz,.EndCheckClimbStairsRightUp2
		ld    hl,(ClesX)
		ld    de,12 ;19
		add   hl,de
		ld    (ClesX),hl
.EndCheckClimbStairsRightUp2:
		ld    a,208
		ld    (ClesY),a
		ld    a,44
		ld    (CameraY),a

		ld    a,(WorldMapPosition.Y)
		dec   a
		ld    (WorldMapPosition.Y),a
		call    .LoadnextMap

		call enableWorldMap	;add bottom connector to next worldmap room
		ld	 de,(WorldMapPosition)
		call bwmr
		ret
  
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
  
;  ld    de,WorldMapDataMapLenght
		ld    hl,1
		ld    (ClesX),hl
		xor   a
		ld    (CameraX),a

		call enableWorldMap	;add right exit connector to current worldmap room
		ld	 de,(WorldMapPosition)
		call rwmr

		ld    a,(WorldMapPosition.x)
		inc   a
		ld    (WorldMapPosition.x),a
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
		ld    hl,ExitRight304x216
		ld    (ClesX),hl
		ld    a,63
		ld    (CameraX),a

		ld	 a,(WorldMapPosition.x)
		dec	 a
		ld	 (WorldMapPosition.x),a
		call .LoadnextMap

		call enableWorldMap
		ld	 de,(WorldMapPosition)
		call rwmr
		ret


.LoadnextMap:
		call  CameraEngine304x216.setR18R19R23andPage  
		xor   a
		ld    (CheckNewPressedControlUpForDoubleJump),a
		call  DisableLineint	
		jp    loadRoom

  
DisableLineint:
  di
  
; set temp ISR
;	ld		hl,tempisr2
;	ld		de,$38
;	ld		bc,6
;	ldir
		ld    hl,InterruptHandlerLoader
		ld    ($38+1),hl          ;set new normal interrupt
		ld    a,$c3               ;jump command
		ld    ($38),a

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


CheckNewPressedControlUpForDoubleJump:  db    0
InterruptHandlerLoader:
		push	af
		push	bc
		push	de
		push	hl
		push	ix
		push	iy

		in		a,($99)             ;check and acknowledge vblank int (ei0 is set)

		in	  a,($a8)
		push	af					      ;store current RAM/ROM state
		ld    a,(memblocks.1)
		push  af                ;store current memblock1 
		ld    a,(memblocks.2)
		push  af                ;store current memblock2 

		call  RePlayer_Tick     ;music player

		ld		a,(NewPrContr)
		push  af
		ld		a,(Controls)
		push  af

  call  PopulateControls  ;this allows for a double jump as soon as you enter a new map

;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(Controls)
  bit   0,a               ;check  if up is pressed
  jr    nz,.EndCheckUpPressed
  ;at this point up is not pressed, if CheckNewPressedControlUpForDoubleJump=0 then CheckNewPressedControlUpForDoubleJump=1
  ld    a,(CheckNewPressedControlUpForDoubleJump)
  or    a
  jr    nz,.EndCheckUpPressed
  inc   a
  ld    (CheckNewPressedControlUpForDoubleJump),a
  .EndCheckUpPressed:

  ld    a,(Controls)
  bit   0,a               ;check  if up is pressed
  jr    z,.EndCheckUpNotPressed
  ;at this point up is not pressed, if CheckNewPressedControlUpForDoubleJump=0 then CheckNewPressedControlUpForDoubleJump=1
  ld    a,(CheckNewPressedControlUpForDoubleJump)
  dec   a
  jr    nz,.EndCheckUpNotPressed
  ld    a,2
  ld    (CheckNewPressedControlUpForDoubleJump),a
  .EndCheckUpNotPressed:

		pop   af
		ld		(Controls),a

		pop   af
		ld		(NewPrContr),a

		pop   af                ;pop current memblock2 
		ld    (memblocks.2),a
		ld		($7000),a
		pop   af                ;pop current memblock1 
		ld    (memblocks.1),a
		ld		($6000),a
		pop	  af					      ;back to former RAM/ROM state
		out	  ($a8),a	

		pop		iy
		pop		ix
		pop		hl
		pop		de
		pop		bc
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
  .SelfmodyfyingLineIntRoutine:  equ $+1
  jp    c,lineint         ;ScoreboardSplit/BorderMaskingSplit
  
  xor   a                 ;set s#0
  out   ($99),a
  ld    a,15+128
  out   ($99),a
  in    a,($99)           ;check and acknowledge vblank interrupt
  rlca
  jp    c,vblank          ;vblank detected, so jp to that routine
 
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
  
;  ld    (r19),a
  out   ($99),a
  ld    a,19+128
  out   ($99),a

  ld    a,(PageOnNextVblank)  ;set page
;  ld    a,3*32+31           ;x*32+31 (x=page)
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
		ld		b,16
		ld    (BorderMaskingSpat+00),a | add a,b ;add   a,16				;rm: I'd do ADD A,B (have LD B,16)
		ld    (BorderMaskingSpat+01),a | add a,b ;add   a,16
		ld    (BorderMaskingSpat+02),a | add a,b ;add   a,16
		ld    (BorderMaskingSpat+03),a | add a,b ; add   a,16
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

LineIntNPCInteractions:
		ld    a,(SpriteSplitAtY100?)				;rm:why? you set LNI Y pos, right? each LNI is unique that way
		or    a
		jp    nz,lineintBorderMaskingSplit

;on the lineint we turn the screen off at the end of the line using polling for HR
;then we switch page
;we set horizontal and vertical adjust
;and we turn screen on again at the end of the line
;and set s#0 again
;LineIntAtScoreboard:
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

	push  hl
	ld    hl,NPCtableForR23
	ld    a,(hl)

	;  ld    a,-40 ;44+39             ;set vertical screen adjust  
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

	push  bc
	push  de
;  ld    b,38*3
	ld    b,39*1	;RM: use LD BC,39*256+0x99
	ld    c,$99

.loop:
	ld    d,(hl)
	inc   hl
	ld    e,(hl)
	inc   hl

;  .Waitline1:
;  in    a,($99)           ;Read Status register #2
;  and   %0010 0000        ;bit to check for HBlank detection
;  jr    nz,.Waitline1
.Waitline2:
nop |nop |nop |nop |nop |nop |nop |nop |nop |nop |nop |			;RM:why?
nop |nop |nop |nop |nop |nop |nop |nop |nop |

	out   (c),d			;RM: outi perhaps? as E is always 23+128
	out   (c),e			;and... D is always D+2.. so, why bother with a table?

.Waitline1:
	in    a,($99)           ;Read Status register #2
	and   %0010 0000        ;bit to check for HBlank detection
	jr    nz,.Waitline1

	djnz  .loop

	xor   a                 ;set s#0
	out   ($99),a
	ld    a,15+128
	out   ($99),a

	ld    (lineintflag),a   ;lineine flag gets set

	pop   de
	pop   bc
	pop   hl
	pop   af 
	ei
ret  

NPCtableForR23:
  db    +082-000,23+128,+082-002,23+128,+082-004,23+128,+082-006,23+128,+082-008,23+128,+082-010,23+128,+082-012,23+128,+082-014,23+128,+082-016,23+128,+082-018,23+128
  db    +082-020,23+128,+082-022,23+128,+082-024,23+128,+082-026,23+128,+082-028,23+128,+082-030,23+128,+082-032,23+128,+082-034,23+128,+082-036,23+128,+082-038,23+128
  db    +082-040,23+128,+082-042,23+128,+082-044,23+128,+082-046,23+128,+082-048,23+128,+082-050,23+128,+082-052,23+128,+082-054,23+128,+082-056,23+128,+082-058,23+128
  db    +082-060,23+128,+082-062,23+128,+082-064,23+128,+082-066,23+128,+082-068,23+128,+082-070,23+128,+082-072,23+128,+082-074,23+128,+082-076,23+128


 
LineInt:
		ld    a,(SpriteSplitAtY100?)
		or    a
		jp    nz,lineintBorderMaskingSplit

;on the lineint we turn the screen off at the end of the line using polling for HR
;then we switch page
;we set horizontal and vertical adjust
;and we turn screen on again at the end of the line
;and set s#0 again
;LineIntAtScoreboard:
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

  ld    a,(AmountOfFramesUntilScreenTurnsOn?)
  dec   a
  jp    m,.SetScreenOn
  ld    (AmountOfFramesUntilScreenTurnsOn?),a
  jr    .EndSetScreenOn

  .SetScreenOn:
  ld    a,(VDP_0+1)       ;screen on
  or    %0100 0000
  out   ($99),a
  ld    a,1+128
  out   ($99),a
  .EndSetScreenOn:

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

;  xor   a
;  jr    .SetR18onVlbank


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
  .SetR18onVlbank:
  ld    (R18onVblank),a

  ld    a,(CameraY)
  ld    (R23onVblank),a

;  add   a,lineintheight
;  ld    (R19onVblank),a
  ret

ShakeScreen?: db 0
ForceVerticalMovementCamera?:     db  1 ;1=down, -1=up
ForceVerticalMovementCameraTimer: db  0 ;1=down, -1=up
ForceVerticalMovementCameraTimerBackup: db  0 ;1=down, -1=up

VerticalMovementCamera:
  ld    a,(ShakeScreen?)
  or    a
  call  nz,.ShakeScreen
  
  ld    a,(ForceVerticalMovementCamera?)
  or    a
  jr    nz,.ForceCameraY
  
  ld    a,(JumpSpeed)
  cp    5
  jr    z,.ForceCameraDown 
  
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

  .ForceCameraDown:
  ld    a,(ClesY)
  cp    $48 ;$27
  ret   c

;  ld    a,r
;  and   %0000 0001
;  inc   a
;  ld    c,a
  ld    c,2

	ld		hl,(PlayerSpriteStand)
  ld    de,jump
  xor   a
  sbc   hl,de
  jr    z,.movecameraY
  xor   a
  ld    (JumpSpeed),a

  .ForceCameraY:
  ld    c,a
  xor   a
  ld    (ForceVerticalMovementCamera?),a
  jr    .movecameraY

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
  .GoPlayerFacingRight:
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




;ASCII16-EX:
;----------------------------------------
;Bank #1 low: 6000h - 67FFh (6000h used)
;Bank #1 high: 8000h - 87FFh (should recommend to use 6000h)
;----------------------------------------
;Bank #2 low: 7000h - 77FFh (7000h and 77FFh used)
;Bank #2 high: 9000h - 97FFh (should recommend to use 9000h)

;Feature set:

;  * Flash ROM memory with commands for per-sector erasing and programming.
;  * Extended addressable capacity up to 64 MB (design provided for 8 MB).
;  * Two 16K mapper pages, mirrored to the full address range.
;  * Two bank selection registers accessible in all pages.
;  * Backwards compatible with ASCII16.

;The two 16K pages are available at 4000H and 8000H, and mirrored to C000H and
;0000H respectively. The two bank select registers exist at 6000H and 7000H just
;like in ASCII16, but are also accessible at A000H, E000H and 2000H. The bank
;number is passed as the data, and for ROM sizes > 4 MB the MSB of the bank
;number is passed in address bits 8-11. Unused bits are ignored.

;Initial banks after power on / reset are 0, however note that the BIOS selects
;a different bank in the 2nd page during boot-up, due to slot expander detection
;writing to mirrored bank select registers if the mapper is in a primary slot.
;So it is recommended to boot from 4000H and manually initialise the banks.

;Below is some example code, assuming the correct cartridge slot is already
;selected at the addresses written to.

;    ld a,47H
;    ld (6000H),a  ; select bank 47H in 1st page (4000-7FFF, C000-FFFF)
;    ld a,47H
;    ld (7000H),a  ; select bank 47H in 2nd page (8000-BFFF, 0000-3FFF)
;    ld a,47H
;    ld (0E000H),a ; select bank 47H in 1st page (4000-7FFF, C000-FFFF)
;    ld a,47H
;    ld (3000H),a  ; select bank 47H in 2nd page (8000-BFFF, 0000-3FFF)
;    ld a,47H
;    ld (6100H),a  ; select bank 147H in 1st page (4000-7FFF, C000-FFFF)
;    ld hl,6147H
;    ld (hl),l     ; select bank 147H in 1st page (4000-7FFF, C000-FFFF)

block12:	
		di
		ld		(memblocks.1),a
		ld		($6000),a
		ei
		ret
block34:	
		di
		ld		(memblocks.2),a
		ld		($7000),a
		ei
		ret
block1234:	 
		di
		ld		(memblocks.1),a
		ld		($6000),a
		inc   a
		ld		(memblocks.2),a
		ld		($7000),a
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
		;	ld    hl,$7400        ;spr color table $17400
		;	ld    de,$6c00        ;spr color table buffer $16c00
		ex	 de,hl
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


CollisionObjectPlayerBoss:
CollisionObjectPlayerDemon:
;  ld    a,-50
;  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

;  ld    hl,(Clesx)                          ;hl = x player
;  ld    bc,30                               ;reduction to hitbox sx (left side)
;  jp    CollisionEnemyPlayer.ObjectEntry
;  call  CollisionEnemyPlayer.ObjectEntry

;  ld    a,CollisionSYStanding
;  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a
  ret

;Check if player hits object with X=8bit
;in:	IX=objectrec, DE=hitboxObjectPaddingXXYY
;out:	C=true (hit)
checkPlayerObjectHitboxCollision8:
		ld		a,(ClesY)						
		sub		a,e
		sub		(ix+enemies_and_objects.y) 
		ccf
		ret		nC
		add		a,e
		add		a,e
		sub		(ix+enemies_and_objects.ny)
		ret		nc

		ld		a,(clesX)
		sub		a,d
		sub		(ix+enemies_and_objects.x) 
		ccf
		ret		nc
		add		a,d
		add		a,d
		sub		(ix+enemies_and_objects.nx)
		ret		nc
		ret


CollisionObjectPlayer:  
;  ld    hl,(Clesx)                          ;hl = x player
  ld    bc,20-2-16                          ;reduction to hitbox sx (left side)
  jp    CollisionEnemyPlayer.ObjectEntry


;Check if Player collides with object
;in:	IX=objectrecord, BC=hitboxOffsetXXYY
CollisionEnemyPlayer:
		ld    bc,20-2	;reduction to hitbox sx (left side). Ro: why 18?
.ObjectEntry:
;left
		ld    hl,(Clesx)                          ;hl = x player
		add   hl,bc	;Cy=0
		ld    e,(ix+enemies_and_objects.x)  
		ld    d,(ix+enemies_and_objects.x+1)      ;de = x enemy/object
		; or    a                                   ;reset flag
		sbc   hl,de
		ret   c
;right
		ld    c,(ix+enemies_and_objects.nx)       ;width object
		ld a,09-4 ;nx + 10                          ;reduce this value to reduce the hitbox size (on the right side)
		add a,c
		ld c,a
		sbc   hl,bc  
		ret   nc
;top
		ld    a,(Clesy)
.SelfModifyingCodeCollisionSY:  equ $+1		;ro: we've gotta loose this shit
		add   a,07; + 8                            ;increase this value to reduce the hitbox size (on the yop side)
		sub   (ix+enemies_and_objects.y)
		ret   c
;bottom
		ld    c,(ix+enemies_and_objects.ny)       ;width object
		ld e,a ;store a
.SelfModifyingCodeCollisionSYBottom:  equ $+1 ;WE STILL NEED TO ADD THIS!!> ro: no, we don't. Loose this shit
		ld a,20-4 ;ny + 20   ;if this is 20-8 it would be same reduction top as bottom, but at the bottom its better if there is less reduction                         ;reduce this value to reduce the hitbox size (on the bottom side)
		add a,c
		ld c,a
		ld a,e
		sub   a,c
		ret   nc
  
.PlayerIsHit:		;ro: the CheckCollision should not adjust anything, this should be a seperate function.
		ld    a,(PlayerInvulnerable?)
		or    a
		ret   nz

		ld    a,(PlayerDead?)
		or    a
		ret   nz

		ld    a,(PlayerFacingRight?)
		or    a
		jp    z,Set_L_BeingHit
		jp    Set_R_BeingHit




;20241005;ro;refactored and moved
;in:	DE=X-offset, B=Y-offset
;this looks a lot like CheckTileEnemyInHL:  
checktileObject:   ;same as checktile for player, but now for object
		ld    l,(ix+enemies_and_objects.x)        ;x object
		ld    h,(ix+enemies_and_objects.x+1) ;0
		add   hl,de
		ld    a,(ix+enemies_and_objects.y)        ;y object
		add   a,b
		jp    getRoomMapData	;getRoomMapTile ;CheckTile.XandYset

;Check tile PLAYER (replacement code for checktile:)
;in DE=X-offset, B=Y-offset
checkTilePlayer:            
		ld	 a,(Clesy)
		add	 a,b
		ld	 hl,(ClesX)
		add	 hl,de
		bit	 7,h	;left edge
		jp	 z,.ctp0
		ld	 hl,0	;this is a bit sketsy...
.ctp0:	call getRoomMapData
		dec	 A
		ret



;Get room map data (tile) class (replaced getRoomMapTile)
;in: HL=X, A=Y
;out:HL=address, A=value
getRoomMapData:	;.XandYset:	;y/8, x/8
		srl   h		;/2
		rr    l
		srl   l		;/4
		srl   l		;/8
		rrca		;/2
		rrca		;/4
		rrca		;/8
		and 0x1f
;at this point: HL=TileX, A=TileY
		ld	 de,roomMap.data
		add   hl,de
		ex    de,hl               ;de->roommapadr+x in tiles
		ld	 bc,roomMap.numcol
		call mulAxBC
		add	 hl,de               ;(amount of Y tiles * map lenght ) + x in tiles
		ld	 a,(hl)
		;dec	 a
		ret


;HL=AxBC
mulAxBC:
.Mult12:
  ld    hl,0
.Mult12_Loop:
  add   a,a
  jp    nc,.Mult12_NoAdd
  add   hl,bc
.Mult12_NoAdd:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd2
  add   hl,bc
.Mult12_NoAdd2:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd3
  add   hl,bc
.Mult12_NoAdd3:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd4
  add   hl,bc
.Mult12_NoAdd4:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd5
  add   hl,bc
.Mult12_NoAdd5:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd6
  add   hl,bc
.Mult12_NoAdd6:
  add   hl,hl
  add   a,a
  jp    nc,.Mult12_NoAdd7
  add   hl,bc
.Mult12_NoAdd7:
  add   hl,hl
  add   a,a
;  jp    nc,.Mult12_NoAdd8
	ret	 nc
  add   hl,bc
;.Mult12_NoAdd8:
ret

PrimaryWeaponActivatedWhileJumping?:  db  0
MagicWeaponDurationValue:     equ 29
MagicWeaponDuration:          db  MagicWeaponDurationValue
DaggerRandomizer:             db  0
CurrentMagicWeapon:           db  0 ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water, 10=kinetic energy
CurrentPrimaryWeapon:         db  0 ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

ArrowSpeed:                   equ 6
FireballSpeed:                equ 4
IceWeaponSpeed:               equ 4
EarthWeaponSpeed:             equ 3
WaterWeaponSpeed:             equ 3
KineticWeaponSpeed:           equ 3

PrimaryWeaponActive?:         db  0         ;(ix+0)
PrimaryWeaponY:               db  000       ;(ix+1)
PrimaryWeaponX:               dw  000       ;(ix+2)
PrimaryWeaponSY:              db  216+24    ;(ix+4)
PrimaryWeaponSX_RightSide:    db  229       ;(ix+5) 
PrimaryWeaponSX_LeftSide:     db  000+00    ;(ix+6)
PrimaryWeaponNY:              db  005       ;(ix+7)
PrimaryWeaponNX:              db  009       ;(ix+8)

PrimaryWeaponXRightSide:      dw  000       ;(ix+9)
PrimaryWeaponYBottom:         db  000       ;(ix+11)

SecundaryWeaponActive?:       db  0         ;(ix+0)
SecundaryWeaponY:             db  100       ;(ix+1)
SecundaryWeaponX:             dw  100       ;(ix+2)
SecundaryWeaponSY:            db  216+29    ;(ix+4)
SecundaryWeaponSX_RightSide:  db  000       ;(ix+5)
SecundaryWeaponSX_LeftSide:   db  000+10    ;(ix+6)
SecundaryWeaponNY:            db  011       ;(ix+7)
SecundaryWeaponNX:            db  016       ;(ix+8)

SecundaryWeaponYBottom:       db  000       ;(ix+9)

HandlePlayerWeapons:
  ld    a,(SecundaryWeaponActive?)
  or    a
  jp    nz,SecundaryWeapon

  ld    a,(PrimaryWeaponActive?)
  or    a
  jp    nz,PrimaryWeapon
  ret

  PrimaryWeapon:
  ld    ix,PrimaryWeaponActive?

  ld    a,(CurrentPrimaryWeapon)    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
  cp    4
  jp    c,GoHandlePlayerWeapon      ;if primary weapon uses a software sprite, then put software sprite weapon in display

  ld    a,(PrimaryWeaponActive?)    ;if PrimaryWeaponActive?=128 bow animation should be put in screen
  cp    128
  jp    z,GoHandlePlayerWeapon
  ret
  
SecundaryWeapon:
		ld    ix,SecundaryWeaponActive?

		;SecundaryWeapon animation
		ld    b,128               ;sx of first ice weapon going right
		jp    p,.DirectionFound
		ld    b,192               ;sx of first ice weapon going left 
.DirectionFound:
		ld    a,(SecundaryWeaponNY)
		dec   a                   ;check if NY=1 (arrow)
		jp    z,.CollisionCheck   ;skip elementary weapon animation and duration if we are using arrow

		ld    a,(framecounter)
		and   7
		and   %0000 0110          ;0, 2, 4 or 6
		add   a,a                 ;*2
		add   a,a                 ;*4
		add   a,a                 ;*8 (0, 16, 32, 48)    
		add   a,b
		ld    (ix+5),a            ;IceWeaponSX_RightSide
		add   a,15
		ld    (ix+6),a            ;IceWeaponSX_LeftSide
		;/SecundaryWeapon animation

		ld    a,(MagicWeaponDuration)
		dec   a
		ld    (MagicWeaponDuration),a
		jp    z,GoHandlePlayerWeapon.RemoveWeapon

.CollisionCheck:
		ld    l,(ix+2)            ;FireballX
		ld    h,(ix+3)            ;FireballX
		ld    de,20 - 16
		add   hl,de  
		ld    a,(ix+1)            ;FireballY
		;  add   a,16 + 2
		; call  getRoomMapTile ;checktile.XandYset  ;out z=collision found with wall  
		add a,2
		call getRoomMapData		;in: HL=x, A=y
		dec	 a
		jp    z,GoHandlePlayerWeapon.RemoveWeapon
		inc   hl                  ;also check next tile
		ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a                   ;1 = wall
		jp    z,GoHandlePlayerWeapon.RemoveWeapon
		call  GoHandlePlayerWeapon  
;move
		ld    a,(ix+2)            ;FireballX
		add   a,(ix+0)            ;Weapon active?/ movement speed. move arrow with arrow speed (which is set in ArrowActive?)
		ld    (ix+2),a            ;FireballX
		ret
  
GoHandlePlayerWeapon:
  ld    a,(ix+4)          ;sy  
  ld    (CopyPlayerProjectile+sy),a
  ld    a,(ix+7)          ;ny
  ld    (CopyPlayerProjectile+ny),a
  ld    (CleanPlayerProjectile+ny),a
  ld    a,(ix+8)          ;nx
  ld    (CopyPlayerProjectile+nx),a
  ld    (CleanPlayerProjectile+nx),a
  
  ld    iy,CleanPlayerProjectile

  ld    a,(scrollEngine)                ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  jp    nz,PlayerWeaponSf2Engine
    
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

  ld    a,(PrimaryWeaponActive?)
  or    a
  jp    nz,.GoPutWeaponRightSideScreen
 
  ld    a,(ix+0)            ;SecundaryWeaponActive? / movement speed
  or    a
  jp    p,.movingRight1
   
  ;at this point in the right side of the screen, a secundary weapon is moving to the left 
  .movingLeft1:
  ld    a,(ix+2)            ;FireballX
  cp    16
  ret   c                   ;if arrow went through the edge of the map (on the right side) remove the arrow from play
  jp    .GoPutWeaponRightSideScreen
  ;at this point in the right side of the screen, a secundary weapon is moving to the right
  .movingRight1:
  ld    a,(CopyPlayerProjectile+dx)  ;dont put arrow in screen (on the left side) if it went through the screen on the right side
  cp    255-40
  jp    nc,.RemoveWeapon         ;if arrow went through the edge of the map (on the right side) remove the arrow from play

  .GoPutWeaponRightSideScreen:
  ;put arrow
  ld    hl,CopyPlayerProjectile
  call  docopy
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerProjectile+restorebackground?),a   
  ret

  .RemoveWeapon:
  ld    (ix+0),0

  ld    a,MagicWeaponDurationValue
  ld    (MagicWeaponDuration),a  
  
  xor   a
  ld    (SecundaryWeaponActive?),a  
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
  add   a,d
  add   a,(ix+8)            ;nx
  ld    (CopyPlayerProjectile+dx),a
  ld    (iy+dx),a
  add   a,e
  ld    (iy+sx),a

  ld    a,(PrimaryWeaponActive?)
  or    a
  jr    nz,.GoPutWeaponLeftSideScreen
  
  ld    a,(ix+0)            ;SecundaryWeaponActive? / movement speed
  or    a
  jp    p,.movingRight2
   
  ;at this point in the left side of the screen, a secundary weapon is moving to the left 
  .movingLeft2:
  ld    a,(ix+2)            ;FireballX
  cp    16
  jp    c,.RemoveWeapon         ;if arrow went through the edge of the map (on the right side) remove the arrow from play
  jr    .GoPutWeaponLeftSideScreen
  ;at this point in the left side of the screen, a secundary weapon is moving to the right
  .movingRight2:
  ld    a,(CopyPlayerProjectile+dx)  ;dont put arrow in screen (on the left side) if it went through the screen on the right side
  cp    255-20
  ret   nc
  
  .GoPutWeaponLeftSideScreen:
  ;put arrow
  ld    hl,CopyPlayerProjectile
  call  docopy
  
  ld    a,1                   ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerProjectile+restorebackground?),a   
  ret

;this is the old version of the routine, that restores the background from current page + 2
;PlayerWeaponSf2Engine:  
;  ld    a,(ix+5)                      ;SX right side
;  ld    (CopyPlayerProjectile+sx),a  
;  ld    a,%0000 0000                  ;set copy direction. Copy from left to right
;  ld    (iy+copydirection),a
;  ld    (CopyPlayerProjectile+copydirection),a  

;  ld    a,(screenpage)                ;we put weapon/projectile in current page
;  ld    (CopyPlayerProjectile+dpage),a  
;  ld    (iy+dpage),a
;  add   a,2                           ;we restore weapon/projectile from current page + 2 (this is always a clean buffer page)
;  and   3
;  ld    (iy+spage),a

;set object sy,dy,sx,dx,nx,ny
;  ld    a,(ix+1)                      ;y
;  ld    (iy+sy),a
;  ld    (iy+dy),a
;  ld    (CopyPlayerProjectile+dy),a
  
;  ld    a,(ix+2)                      ;x
;  ld    (CopyPlayerProjectile+dx),a
;  ld    (iy+dx),a
;  ld    (iy+sx),a
  ;remove weapon when going out of screen
;  ld    a,(ix+2)                      ;x
;  cp    7
;  jp    c,GoHandlePlayerWeapon.RemoveWeapon
;  cp    255-7
;  jp    nc,GoHandlePlayerWeapon.RemoveWeapon

  ;put object
;  ld    hl,CopyPlayerProjectile
;  call  docopy

  ;remove object at start of next frame
;  ld    a,1                           ;all background restores should be done simultaneously at start of frame (after vblank)
;  ld    (CleanPlayerProjectile+restorebackground?),a   
;  ret

PlayerWeaponSf2Engine:  
  ld    a,(screenpage)                ;we put weapon/projectile in current page
  ld    (BackupBackground+spage),a  

;set object sy,dy,sx,dx,nx,ny
  ld    a,(ix+1)                      ;y
  ld    (BackupBackground+sy),a
  
  ld    a,(ix+2)                      ;x
  ld    (BackupBackground+sx),a
  ;remove weapon when going out of screen
;  ld    a,(ix+2)                      ;x
  cp    7
  jp    c,GoHandlePlayerWeapon.RemoveWeapon
  cp    255-7
  jp    nc,GoHandlePlayerWeapon.RemoveWeapon

  ;backup background where we will put object
  ld    a,(CopyPlayerProjectile+nx)
  ld    (BackupBackground+nx),a
  ld    a,(CopyPlayerProjectile+ny)
  ld    (BackupBackground+ny),a
  ld    hl,BackupBackground           ;a backup of the background piece where we will place our software sprite will be stored at (0,216) in page 3
  call  docopy

  ld    (iy+sy),216                   ;a backup of the background piece will be stored at (0,216) in page 3
  ld    (iy+sx),0                     ;a backup of the background piece will be stored at (0,216) in page 3
  ld    (iy+spage),3
  ld    (iy+copydirection),0
  ld    a,(BackupBackground+sy)
  ld    (CopyPlayerProjectile+dy),a
  ld    (iy+dy),a
  ld    a,(BackupBackground+sx)
  ld    (CopyPlayerProjectile+dx),a
  ld    (iy+dx),a
  ld    a,(screenpage)                ;we put weapon/projectile in current page
  ld    (CopyPlayerProjectile+dpage),a  
  ld    (iy+dpage),a
  ld    a,%0000 0000                  ;set copy direction. Copy from left to right
  ld    (CopyPlayerProjectile+copydirection),a  
  ld    a,(ix+5)                      ;SX right side
  ld    (CopyPlayerProjectile+sx),a  
  xor   a
  ld    (BigEnemyPresentInVramPage3),a;we are using the same vram space big enemies get, so these enemies are now no longer present

  ;put object
  ld    hl,CopyPlayerProjectile
  call  docopy

  ;remove object at start of next frame
  ld    a,1                           ;all background restores should be done simultaneously at start of frame (after vblank)
  ld    (CleanPlayerProjectile+restorebackground?),a   
  ret

BackupBackground:
  db    000,000,000,000   ;sx,--,sy,spage
  db    000,000,216,003   ;dx,--,dy,dpage
  db    016,000,001,000   ;nx,--,ny,--
  db    000,%0000 0000,$90       ;fast copy -> Copy from left to right

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

CopyCharacter:            ;used for the NPC interactions
  db    000,000,044,000   ;sx,--,sy,spage
  db    003,000,003,000   ;dx,--,dy,dpage
  db    006,000,009,000   ;nx,--,ny,--
  db    000,%0000 0000,$98       ;fast copy command -> Copy from left to right

playermovementspeed:    db  2
PlayerFacingRight?:     db  1
PlayerInvulnerable?:    db  0

;Rstanding,Lstanding,Rsitting,Lsitting,Rrunning,Lrunning,Jump,ClimbDown,ClimbUp,Climb,RAttack,LAttack,ClimbStairsLeftUp, ClimbStairsRightUp, RPushing, LPushing, RRolling, LRolling, RBeingHit, LBeingHit
;RSitPunch, LSitPunch, Dying, Charging, LBouncingBack, RBouncingBack, LMeditate, RMeditate, LShootArrow, RShootArrow, LSitShootArrow, RSitShootArrow, LShootFireball, RShootFireball, LSilhouetteKick, RSilhouetteKick
;LShootIce, RShootIce, LShootEarth, RShootEarth, LShootWater, RShootWater, DoNothing, Teleporting
PlayerSpriteStand: dw  Rstanding

PlayerAniCount:     db  0,0
HandlePlayerSprite:
;	ld		a,(slot.page12rom)	;all RAM except page 1+2
;	out		($a8),a	

	ld		a,PlayerMovementRoutinesBlock
	call	block12		          ;set block in page 1

  ld    hl,(PlayerSpriteStand)
  jp    (hl)

DoNothing:
  ret

RShootKineticEnergy:
;Animate
  ld    hl,RightShootFireballAnimation
  call  AnimateShootFireball             ;animate

  ld    a,(PlayerAniCount)
  cp    2 * 10
  ret   c
  ld    a,2 * 10
  ld    (PlayerAniCount),a

  .EntranceWhileJumping:
  ld    a,(scrollEngine)      ;1= 304x216 engine  2=256x216 SF2 engine
  dec   a
  ld    de,-26                ;normal engine
  jr    z,.engineFound
  ld    de,-21                ;SF2 engine  
  .engineFound:

  ld    a,-KineticWeaponSpeed
  ld    (SecundaryWeaponActive?),a
  ld    hl,(ClesX)
  add   hl,de                 ;adjust x starting placement projectile
  ld    a,l
  bit   0,h
  jr    z,.SetX
  ld    a,255
  .SetX:
  ld    (SecundaryWeaponX),a
  ld    a,(ClesY)
  ld    (SecundaryWeaponY),a


jp Set_Fall
  ret

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

AttackRotator:  db 0

;For now all hitboxes are 16x16, so we only need SX and SY
;EnableHitbox?:  db  0
;HitBoxSX:       dw  0
;HitBoxSY:       db  0
;HitBoxNX:       db  0
;HitBoxNY:       db  0

InitiateNewAttack?:  db  0

StartingJumpSpeedEqu:     equ -6   ;initial starting jump take off speed
StartingJumpSpeed:        db -6 ;equ -5    ;initial starting jump take off speed
StartingDoubleJumpSpeed:  db -3 ;-4 ;equ -5    ;initial starting jump take off speed
StartingJumpSpeedWhenHit: db -4 ;equ -5    ;initial starting jump take off speed
FallingJumpSpeed:         equ 1
JumpSpeed:                db  0
JumpStartY:				db 0 ;Where did the jump start?
MaxDownwardFallSpeed:     equ 6
GravityTimer:             equ 4     ;every x frames gravity changes jump speed
; YaddHeadPLayer:           equ 2 + 6 ;(changed) player can now jump further into ceilings above
; YaddmiddlePLayer:         equ 17
; YaddFeetPlayer:           equ 33

;-- 20241007;ro;new
playerSpriteOffsetY:	equ -16
playerSpriteOffsetX:	equ -8
playerStanding:
.centerY:	equ 15
.centerX:	equ 8 ;?
.head:	equ	0-.centerY	;0-7
.torso:	equ	8-.centery	;8-15
.legs:	equ	16-.centerY	;16-23
.feet:	equ 24-.centerY	;24-31
.leftSide: equ 0-.centerX
.rightSide: equ 15-.centerX
playerKneeling:
.centerY:	equ 15
.centerX:	equ 8 ;?
.head:	equ	8-.centerY	;0-7
.torso:	equ	16-.centery	;8-15
.legs:	equ	24-.centerY	;16-23
.feet:	equ 24-.centerY	;24-31
.leftSide: equ 0-.centerX
.rightSide: equ 15-.centerX
playerRolling:
.centerY:	equ 15
.centerX:	equ 8 ;?
.head:	equ	16-.centerY	;0-7
.torso:	equ	16-.centery	;8-15
.legs:	equ	24-.centerY	;16-23
.feet:	equ 24-.centerY	;24-31
.leftSide: equ 0-.centerX
.rightSide: equ 15-.centerX
;--

; XaddLeftPlayer:           equ 00 - 8
; XaddRightPlayer:          equ 15 - 8
KickWhileJumpDuration:    equ 10

;PrimaryAttackWhileJump?:  db  1
KickWhileJump?:           db  1
ShootMagicWhileJump?:     db  0
ShootArrowWhileJump?:     db  0

;ro: why not make this general, just "lastkey" or something
HowManyFramesAgoWasLeftPressed?:    db  0
HowManyFramesAgoWasRightPressed?:   db  0


; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
CheckWallbashRight:         ;check if right+right are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  ld    a,(NewPrContr)
  bit   3,a                 ;is right pressed ?
  jr    z,.RightIsNotPressed

  ld    a,(HowManyFramesAgoWasRightPressed?)
  cp    10
  ld    a,0
  ld    (HowManyFramesAgoWasRightPressed?),a
  ret   nc
  pop   af                          ;don't return to the current pose
  ld    a,1
  ld    (PlayerFacingRight?),a
  jp    set_charging

  .RightIsNotPressed:
  ld    a,(HowManyFramesAgoWasRightPressed?)
  inc   a
  ret   z
  ld    (HowManyFramesAgoWasRightPressed?),a
  ret

CheckWallbashLeft:         ;check if left+left are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  ld    a,(NewPrContr)
  bit   2,a                 ;is left pressed ?
  jr    z,.LeftIsNotPressed

  ld    a,(HowManyFramesAgoWasLeftPressed?)
  cp    10
  ld    a,0
  ld    (HowManyFramesAgoWasLeftPressed?),a
  ret   nc
  pop   af                          ;don't return to the current pose
  xor   a
  ld    (PlayerFacingRight?),a
  jp    set_charging

  .LeftIsNotPressed:
  ld    a,(HowManyFramesAgoWasLeftPressed?)
  inc   a
  ret   z
  ld    (HowManyFramesAgoWasLeftPressed?),a
  ret


; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
CheckWallwalk:              ;check if triga + trigb are pressed while standing. if so, setwallwalk pose and DON'T return to this routine
		ld    a,(Controls)
		and   %0011 0010                  ;check if triga+trigb are pressed
		cp    %0011 0000
		ret   nz

		pop   af                          ;don't return to the current pose
		;  xor   a
		;  ld    (PrimaryWeaponActive?),a    ;this interrupts any weapon animation (punch, draw bow etc)
		;  ld    (SecundaryWeaponActive?),a    ;this interrupts any weapon animation (punch, draw bow etc)

		ld    a,(PlayerFacingRight?)
		or    a
		jp    z,Set_L_SilhouetteKick
		jp    Set_R_SilhouetteKick


; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
CheckMeditateAndRolling:
		ld    a,(Controls)
		and   %0011 0010                  ;check if down+triga+trigb are pressed
		cp    %0011 0010
		ret   nz

		pop   af                          ;don't return to the current pose
		xor   a
		ld    (PrimaryWeaponActive?),a    ;this interrupts any weapon animation (punch, draw bow etc)

		ld    a,(Controls)
		bit   3,a                         ;check if right is pressed. if so, roll right
		jp    nz,Set_R_Rolling
		bit   2,a                         ;check if left is pressed. if so, roll left
		jp    nz,Set_L_Rolling

		ld    a,(PlayerFacingRight?)
		or    a
		jp    z,Set_L_Meditate
		jp    Set_R_Meditate

Lsitting:
		ld    a,(ForceVerticalMovementCameraTimer)
		ld    (ForceVerticalMovementCameraTimerBackup),a
		xor   a
		ld    (ForceVerticalMovementCameraTimer),a
		xor   a
		ld    (PlayerFacingRight?),a		
		call  CheckMeditateAndRolling               ;check if triga + trigb are pressed while sitting. if so, set meditate pose and DON'T return to this routine
		ld		hl,PlayerSpriteData_Char_LeftSitting
		ld		(standchar),hl
		call  EndMovePlayerHorizontally   ;slowly come to a full stop after running

		ld    a,(SnapToPlatform?)         ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
		or    a
		call  nz,CheckWallSides

		ld    a,(SnapToPlatform?)
		or    a
		jr    nz,..EndCheckSnapToPlatform
		call  CheckFloorInclLadder	;out: cy=not
		jp    c,Set_Fall
..EndCheckSnapToPlatform:
		call  CheckLavaPoisonSpikes       ;out: z-> lava poison or spikes found
		jp    z,Set_L_BeingHit

; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
		ld    a,(NewPrContr)
		bit		4,a           ;space pressed ?
.PrimaryWeaponLeftSelfModifyingJump:
		nop | nop | nop     ;e.g.   jp		nz,Set_R_attack
		;	jp		nz,Set_L_SitPunch
	
		bit		5,a           ;'M' pressed ?
.MagicWeaponLeftSelfModifyingJump:
		nop | nop | nop
  
		ld		a,(Controls)
		bit		2,a           ;cursor left pressed ?
		jp		nz,.EndCheckLeftPressed
		bit		3,a           ;cursor right pressed ?
		jp		nz,.Set_R_sit
.EndCheckLeftPressed:
		bit		1,a           ;cursor down pressed ?
		ld		hl,PlayerSpriteData_Char_LeftSitLookDown
		jp		nz,Rsitting.CheckLadder

		;	bit		0,a           ;cursor up pressed ?
		;	jp		nz,Set_jump
		;	bit		2,a           ;cursor left pressed ?
		;	jp		nz,.Set_L_run_andcheckpunch
		;	ld		a,(Controls)
		;	bit		3,a           ;cursor right pressed ?
		;	jp		nz,.AnimateRun
		jp		Set_L_stand

.Set_R_sit:
		call Set_R_sit
		ld	 hl,PlayerSpriteData_Char_RightSitLookDown
		jp	 Rsitting.CheckLadder


Rsitting:
		ld    a,(ForceVerticalMovementCameraTimer)
		ld    (ForceVerticalMovementCameraTimerBackup),a
		xor   a
		ld    (ForceVerticalMovementCameraTimer),a

		ld    a,1
		ld    (PlayerFacingRight?),a		
		call  CheckMeditateAndRolling               ;check if triga + trigb are pressed while sitting. if so, set meditate pose and DON'T return to this routine
		ld		hl,PlayerSpriteData_Char_RightSitting
		ld		(standchar),hl
		call  EndMovePlayerHorizontally   ;slowly come to a full stop after running
		ld    a,(SnapToPlatform?)         ;if snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
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
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
		ld    a,(NewPrContr)
		bit		4,a           ;space pressed ?
.PrimaryWeaponRightSelfModifyingJump:
		nop | nop | nop     ;e.g.   jp		nz,Set_R_attack
		;	jp		nz,Set_R_SitPunch
		bit		5,a           ;'M' pressed ?
.MagicWeaponRightSelfModifyingJump:
		nop | nop | nop

		ld		a,(Controls)
		bit		3,a           ;cursor right pressed ?
		jp		nz,.EndCheckRightPressed
		bit		2,a           ;cursor left pressed ?
		jp		nz,.Set_L_sit
.EndCheckRightPressed:
		bit		1,a           ;cursor down pressed ?
		ld		hl,PlayerSpriteData_Char_RightSitLookDown
		jp		nz,.CheckLadder
		;	bit		0,a           ;cursor up pressed ?
		;	jp		nz,Set_jump
		;	bit		2,a           ;cursor left pressed ?
		;	jp		nz,.Set_L_run_andcheckpunch
		;	ld		a,(Controls)
		;	bit		3,a           ;cursor right pressed ?
		;	jp		nz,.AnimateRun
		jp		Set_R_stand

.Set_L_sit:
		call  Set_L_sit
		ld		hl,PlayerSpriteData_Char_LeftSitLookDown  
		;  jp    Rsitting.CheckLadder

;check if there is a ladder tile below left foot or right foot
.CheckLadder:
		ld    a,(ForceVerticalMovementCameraTimerBackup)	;ro: what's going on here?
		ld    (ForceVerticalMovementCameraTimer),a
		add   a,2
		cp    120
		jr    c,.SetTimer
		ld		(standchar),hl
		ld    a,1
		ld    (ForceVerticalMovementCamera?),a  
		ld    a,120
.SetTimer:
		ld    (ForceVerticalMovementCameraTimer),a

		; ld    de,XaddLeftPlayer+6   ;X-offset
		; ld    b,YaddFeetPlayer-0    ;Y-offset
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.leftSide+6 ;x-offset
		; ld	 de,playerStanding.centerx-1
		ld	 b,playerStanding.feet+8	;y-offset=tile under feet
		call checkTilePlayer
		dec	 a                   ;tileClass 2=ladder 
		jp	 z,.ladderfound
		; ld    de,XaddRightPlayer-7
		; ld    b,YaddFeetPlayer-0 
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.rightside-7 ;x-offset
		; ld	 de,playerStanding.centerx
		ld	 b,playerStanding.feet+8	;y-offset=tile under feet
		call checkTilePlayer		
		dec   a
		ret   nz
.ladderfound:
		call  Set_ClimbDown
;		ld    hl,(ClesX)          ;snap X to ladder
;		ld    a,l
		ld	 a,(clesx)
		and   %1111 1000
		ld    l,a
		ld	 (clesx),a
;		ld    (ClesX),hl
;after snapping player could be 1 tile too much to theright. Check again for ladder under right foot. If not, then move 1 tile to the left
		; ld    de,XaddRightPlayer-2  ;add x to check (x is expressed in pixels)
		; ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.rightside-2 ;x-offset
		ld	 b,playerStanding.feet+8	;y-offset=tile under feet
		call checkTilePlayer
		dec   a                   ;check for tilenr 2=ladder 
		jr    z,.NowCheckLeft
		ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
		ld    de,8
		sbc   hl,de
		ld    (ClesX),hl
		ret
.NowCheckLeft:
		; ld    de,XaddLeftPlayer+2   ;add x to check (x is expressed in pixels)
		; ld    b,YaddFeetPlayer-0    ;add y to check (y is expressed in pixels)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.leftSide+2 ;x-offset
		ld	 b,playerSTanding.feet+8	;y-offset=tile under feet
		call checkTilePlayer		
		dec   a                   ;check for tilenr 2=ladder 
		ret   z
		ld    hl,(ClesX)          ;in case ladder is detected, snap to the x position of the ladder
		ld    de,8
		add   hl,de
		ld    (ClesX),hl
		ret
 


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

;in:  A, runningTablePointer value (it's not really a pointer, tho)
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

;20241007;ro;refactored
.PlayerMovedRight:
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallRight

;  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
;  ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallRight

;when player is rolling we don't have to check for collision on eye height
		ld		hl,(PlayerSpriteStand)
		ld		de,RRolling
		xor   a
		sbc   hl,de
		jr    z,.RollingRight
;check at height of waist if player runs into a wall on the right side
		; ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
		; ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.RightSide+1	;x-offset is tile right of player
		ld	 b,playerStanding.torso
		call checkTilePlayer
		jr	 z,.SnapToWallRight
		ld	 bc,roomMap.numcol
		add	 hl,bc				;legs (1 tile lower)
		ld 	 a,(hl)				;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec	 a					;1=wall
		jr	 z,.SnapToWallRight
		add	 hl,bc				;feet (1 tile lower)
		ld    a,(hl)			;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a					;1=wall
		jr    z,.SnapToWallRight
		; ld    b,YaddHeadPLayer+1  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
		ld	 de,playerStanding.RightSide+1
		ld	 b,playerStanding.head+4
		call checkTilePlayer           ;out z=collision found with wall
		jr    z,.SnapToWallRight
		ret

.RollingRight:
		;check at height of waiste if player runs into a wall on the right side
		; ld    b,YaddmiddlePLayer-1+8  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.RightSide+1
		ld	 b,playerStanding.legs
		call checkTilePlayer           ;out z=collision found with wall
		jr    z,.SnapToWallRight
		ld	 bc,roomMap.numcol
		add	 hl,bc				;feet (1 tile lower)
		ld 	 a,(hl)				;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec	 a					;1=wall
		jr	 z,.SnapToWallRight
		ret

.SnapToWallRight:
		;ld    hl,(ClesX)          ;in case collision with wall is detected after the momevent, snap to the wall
		;ld    a,l
		ld a,(clesX)
		and   %1111 1000
		; ld    l,a
		; ld    (ClesX),hl
		ld (clesx),a

		ld    a,(WallJumpObtained?)
		or    a
		jr    z,.end  

		ld		hl,(PlayerSpriteStand)
		ld		de,Jump
		xor   a
		sbc   hl,de
		jr    nz,.end

		ld		a,(Controls)
		bit		1,a                       ;if down pressed, release walljump stickyness
		jr    nz,.end

		; ld    b,YaddmiddlePLayer+5  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer+4  ;add 15 to x to check right side of player for collision (player moved right)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.RightSide+1
		ld	 b,playerStanding.legs
		call checkTilePlayer           ;out z=collision found with wall
		jr    nz,.end
		
		ld    hl,JumpSpeed
		bit   7,(hl)
		jp    z,Set_R_Walljump
.end:
		scf                       ;carry: collision detected
		ret


;20241007;ro;refactored
.PlayerMovedLeft:
;  ld    b,YaddmiddlePLayer  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallLeft

;  ld    b,YaddFeetPlayer-1  ;add y to check (y is expressed in pixels)
;  ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;  call  checktile           ;out z=collision found with wall
;  jr    z,.SnapToWallLeft

		ld    a,(ClesX+1)
		bit   7,a
		ret   nz                  ;no need to perform tilecheck when player is out of screen on the left side

;when player is rolling we don't have to check for collision on eye height
		ld		hl,(PlayerSpriteStand)
		ld		de,LRolling
		xor   a
		sbc   hl,de
		jr    z,.RollingLeft

;check at height of waiste if player runs into a wall on the left side
;   ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
;   ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;   call  checktile           ;out z=collision found with wall
;   jr    z,.SnapToWallLeft
;   ;now do the same check, but 2 tiles lower
; 	add		hl,bc               ;1 tile lower
; 	add		hl,bc               ;1 tile lower
;   ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
;   dec   a                   ;1 = wall
;   jr    z,.SnapToWallLeft

;   ld    b,YaddHeadPLayer+1  ;add y to check (y is expressed in pixels)
;   ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;   call  checktile           ;out z=collision found with wall
;   jr    z,.SnapToWallLeft
;   ret
		ld	 de,playerStanding.LeftSide	;x-offset is tile right of player
		ld	 b,playerStanding.torso
		call checkTilePlayer
		jr	 z,.SnapToWallLeft
		ld	 bc,roomMap.numcol
		add	 hl,bc				;legs (1 tile lower)
		ld 	 a,(hl)				;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec	 a					;1=wall
		jr	 z,.SnapToWallLeft
		add	 hl,bc				;feet (1 tile lower)
		ld    a,(hl)			;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a					;1=wall
		jr    z,.SnapToWallLeft
		; ld    b,YaddHeadPLayer+1  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer  ;add 15 to x to check right side of player for collision (player moved right)
		ld	 de,playerStanding.LeftSide
		ld	 b,playerStanding.head+4
		call checkTilePlayer           ;out z=collision found with wall
		jr    z,.SnapToWallLeft
		ret

.RollingLeft:
  ;check at height of waiste if player runs into a wall on the right side
;   ld    b,YaddmiddlePLayer-1+8  ;add y to check (y is expressed in pixels)
;   ld    de,XaddLeftPlayer   ;add 0 to x to check left side of player for collision (player moved left)
;   call  checktile           ;out z=collision found with wall
;   jr    z,.SnapToWallLeft
;   ret
		ld	 de,playerStanding.LeftSide
		ld	 b,playerStanding.legs
		call checkTilePlayer           ;out z=collision found with wall
		jr    z,.SnapToWallleft
		ld	 bc,roomMap.numcol
		add	 hl,bc				;feet (1 tile lower)
		ld 	 a,(hl)				;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec	 a					;1=wall
		jr	 z,.SnapToWallLeft
		ret

.SnapToWallLeft:
		ld    hl,(ClesX)          ;in case collision with wall is detected after the momevent, snap to the wall
		ld    a,l
		and   %1111 1000
		ld    l,a
		ld    de,playerStanding.centerX
		add   hl,de
		ld    (ClesX),hl

		ld    a,(WallJumpObtained?)
		or    a
		jr    z,.end  

		ld		hl,(PlayerSpriteStand)
		ld		de,Jump
		xor   a
		sbc   hl,de
		jr    nz,.end

		ld		a,(Controls)
		bit		1,a                       ;down pressed ?
		jr    nz,.end

  ;check at height of waiste if player runs into a wall on the left side
		; ld    b,YaddmiddlePLayer+5  ;add y to check (y is expressed in pixels)
		; ld    de,XaddLeftPlayer-4   ;add 0 to x to check left side of player for collision (player moved left)
		; call  checktile           ;out z=collision found with wall
		ld	 de,playerStanding.LeftSide-4
		ld	 b,playerStanding.legs
		call checkTilePlayer           ;out z=collision found with wall
		jr    nz,.end

		ld    hl,JumpSpeed
		bit   7,(hl)
		jp    z,Set_L_Walljump
		jp .end


;20241007;ro
;checkFloorPlayer
;out:	Cy,floor not found
CheckFloor:
		ld	 de,playerStanding.LeftSide+3
		ld	 b,playerStanding.feet+8
		call checkTilePlayer           ;out z=collision found with wall
		ret   z
		inc   hl                  ;check next tile
		ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a                   ;1 = wall
		ret   z

		scf
		ret

;20241007;ro
;checkFloorPlayer
;out:	Cy,floor or ladder not found
CheckFloorInclLadder:
		ld	 de,playerStanding.LeftSide+3
		ld	 b,playerStanding.feet+8
		call checkTilePlayer           ;out z=collision found with wall
		ret   z
		dec   a                   ;check for tilenr 2=ladder 
		ret   z  
		inc   hl                  ;check next tile
		ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a                   ;1 = wall
		ret   z
		dec   a                   ;check for tilenr 2=ladder 
		ret   z  

		scf
		ret

;20241007;ro
;checkFloorPlayer
;out:	Cy,floor or ladder not found
CheckFloorInclLadderWhileRolling:
		call CheckFloorInclLadder
		ret	 nc

		ld    a,(PlayerFacingRight?)          ;is player facing right ?
		or    a
		ld    de,-6
		jr    z,.ChangeClesX
		ld    de,+6
.ChangeClesX:
		ld    hl,(ClesX)	;ro: why is this, Bart?
		add   hl,de
		ld    (ClesX),hl
		ld    a,(ClesY)
		add   a,4
		ld    (ClesY),a

		scf
		ret

;20241007;ro > this only checks for spike/poison, is that correct?
;Lava, Poison or Spikes under player?
;Z, yes
CheckLavaPoisonSpikes:      ;out z-> lava poison or spikes found
		ld		a,(PlayerInvulnerable?)
		or		a
		ret		nz
  		ld		de,playerStanding.LeftSide
		ld		b,playerStanding.feet+8
		call	checkTilePlayer
		sub		SpikeId-1		;check for tilenr 3=Spike/Poison
		ret		z
		inc		hl                  ;check next tile
		ld		a,(hl)
		sub		SpikeId		;check for tilenr 3=Spike/Poison
		ret


Lrunning:
		call  CheckWallbashLeft           ;check if left+left  are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
		call  CheckWallbashRight          ;check if right+right are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
		call  CheckWallwalk               ;check if triga + trigb are pressed while standing. if so, setwallwalk pose and DON'T return to this routine
;  call  checkfloor
;	jp		nc,Set_R_fall   ;not carry means foreground tile NOT found
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;	bit		1,a           ;cursor down pressed ?
;	jp		nz,.Maybe_Set_R_sit
		ld    a,(NewPrContr)
		bit		0,a           ;cursor up pressed ?
		jr		nz,.UpPressed
		bit		4,a           ;space pressed ?
.PrimaryWeaponLeftSelfModifyingJump:
		nop | nop | nop     ;e.g.   jp		nz,Set_R_attack
		bit		5,a           ;'M' pressed ?
.MagicWeaponLeftSelfModifyingJump:
		nop | nop | nop
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
		call  CheckFloorInclLadder ;ladder is considered floor when running. out: c-> no floor. check if there is floor under the player
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

Rrunning:
		call  CheckWallbashLeft           ;check if left+left  are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
		call  CheckWallbashRight          ;check if right+right are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
		call  CheckWallwalk               ;check if triga + trigb are pressed while standing. if so, setwallwalk pose and DON'T return to this routine
;
; bit	7	6	  5		    4		    3		    2		  1		  0
;		  0	0	  trig-b	trig-a	right	  left	down	up	(joystick)
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
;	bit		1,a           ;cursor down pressed ?
;	jp		nz,.Maybe_Set_R_sit
  ld    a,(NewPrContr)
	bit		0,a           ;cursor up pressed ?
	jr		nz,.UpPressed
;	bit		2,a           ;cursor left pressed ?
;	jp		nz,.Set_L_run_andcheckpunch
	bit		4,a           ;space pressed ?
  .PrimaryWeaponRightSelfModifyingJump:
  nop | nop | nop     ;e.g.   jp		nz,Set_R_attack
;	jp		nz,Set_R_attack

	bit		5,a           ;'M' pressed ?
  .MagicWeaponRightSelfModifyingJump:
  nop | nop | nop
		
;	bit		6,a           ;F1 pressed ?
;	jp		nz,Set_Charging

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
  
CheckWallSides:                     ;if we are snapped to a platform or object, check if we get pushed into a wall, if so snap to wall
  call  DoMovePlayer.PlayerMovedRight
  jp    DoMovePlayer.PlayerMovedLeft
  
Lstanding:
  call  CheckWallbashLeft           ;check if left+left  are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  call  CheckWallbashRight          ;check if right+right are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  call  CheckWallwalk               ;check if triga + trigb are pressed while standing. if so, setwallwalk pose and DON'T return to this routine

  ld    a,(framecounter)
  and   127
  cp    32
	ld		hl,PlayerSpriteData_Char_LeftStand
  jr    c,.SetStand
  cp    64
	ld		hl,PlayerSpriteData_Char_LeftIdle2
  jr    c,.SetStand
  cp    96
	ld		hl,PlayerSpriteData_Char_LeftStand
  jr    c,.SetStand
	ld		hl,PlayerSpriteData_Char_LeftIdle3
  .SetStand:
	ld		(standchar),hl	

  ld    a,(ForceVerticalMovementCameraTimer)
  ld    (ForceVerticalMovementCameraTimerBackup),a
  xor   a
  ld    (ForceVerticalMovementCameraTimer),a
  
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
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
  .PrimaryWeaponLeftSelfModifyingJump:
  nop | nop | nop     ;e.g.   jp		nz,Set_L_attack
  
;	jp		nz,Set_L_attack
;	jp		nz,Set_L_Dagger_attack



	bit		5,a           ;'M' pressed ?
  .MagicWeaponLeftSelfModifyingJump:
  nop | nop | nop
	
	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_run
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_run
	bit		0,a           ;cursor up pressed ?
	ld		hl,PlayerSpriteData_Char_LeftStandLookUp
	jp    nz,Rstanding.ForceCameraUp
	bit		1,a           ;cursor down pressed ?
  ret   z

.DownPressed:  
	call	Set_L_sit
  jp    CheckClimbStairsDown  

.UpPressed:
  call  Set_jump
  call  CheckClimbLadderUp
  jp    CheckClimbStairsUp

;NoMagicWeapon:
;  ret
	
Rstanding:
  call  CheckWallbashLeft           ;check if left+left  are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  call  CheckWallbashRight          ;check if right+right are quickly pressed in succession. if so, wallbash pose and DON'T return to this routine
  call  CheckWallwalk               ;check if triga + trigb are pressed while standing. if so, setwallwalk pose and DON'T return to this routine

  ld    a,(framecounter)
  and   127
  cp    32
	ld		hl,PlayerSpriteData_Char_RightStand
  jr    c,.SetStand
  cp    64
	ld		hl,PlayerSpriteData_Char_RightIdle2
  jr    c,.SetStand
  cp    96
	ld		hl,PlayerSpriteData_Char_RightStand
  jr    c,.SetStand
	ld		hl,PlayerSpriteData_Char_RightIdle3
  .SetStand:
	ld		(standchar),hl

  ld    a,(ForceVerticalMovementCameraTimer)
  ld    (ForceVerticalMovementCameraTimerBackup),a
  xor   a
  ld    (ForceVerticalMovementCameraTimer),a

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
;		 F2	F1	'M'		  space	  right	  left	down	up	(keyboard)
;
  ld    a,(NewPrContr)
	bit		4,a           ;space pressed ?
  .PrimaryWeaponRightSelfModifyingJump:
  nop | nop | nop     ;e.g.   jp		nz,Set_R_attack
  
;	jp		nz,Set_R_attack
;	jp		nz,Set_R_Dagger_attack
	
	bit		5,a           ;'M' pressed ?
  .MagicWeaponRightSelfModifyingJump:
  nop | nop | nop     ;e.g.   jp		nz,Set_R_ShootIce             ;magic 7 (shoot ice)

	ld		a,(Controls)
	bit		2,a           ;cursor left pressed ?
	jp		nz,Set_L_run
	bit		3,a           ;cursor right pressed ?
	jp		nz,Set_R_run
	bit		0,a           ;cursor up pressed ?
	ld		hl,PlayerSpriteData_Char_RightStandLookUp
	jr    nz,.ForceCameraUp
	bit		1,a           ;cursor down pressed ?
  ret   z

  .DownPressed:
	call	Set_R_sit
  jp    CheckClimbStairsDown  

  .ForceCameraUp:		  
  ld    a,(ForceVerticalMovementCameraTimerBackup)
  ld    (ForceVerticalMovementCameraTimer),a
  add   a,2
  cp    80
  jr    c,.SetTimer

	ld		(standchar),hl
	
  ld    a,-1
  ld    (ForceVerticalMovementCamera?),a  
  ld    a,80
  .SetTimer:
  ld    (ForceVerticalMovementCameraTimer),a  
  ret

PlayShootSfx:    
  ld    bc,SFX_shoot1
  jp    RePlayerSFX_PlayCh1

PlayShootArrowSfx:
  ld    bc,SFX_arrow
  jp    RePlayerSFX_PlayCh1

Set_R_ShootKineticEnergy:
	ld		hl,RShootKineticEnergy
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  jp    PlayShootSfx

Set_L_SilhouetteKick:
  call  PlayShootSfx

  ld    a,6
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

	ld		hl,LSilhouetteKick
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  jp    SetHitBoxPlayerStanding
  
Set_R_SilhouetteKick:
  call  PlayShootSfx

  ld    a,6
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

	ld		hl,RSilhouetteKick
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  jp    SetHitBoxPlayerStanding

Set_L_SitShootArrow:
	ld		hl,LSitShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  
  jp    PlayShootArrowSfx

Set_R_SitShootArrow:
	ld		hl,RSitShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  
  jp    PlayShootArrowSfx

Set_L_ShootWater:
	ld		hl,LShootWater
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_R_ShootWater:
	ld		hl,RShootWater
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx
  
Set_L_ShootEarth:
	ld		hl,LShootEarth
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_R_ShootEarth:
	ld		hl,RShootEarth
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_L_ShootIce:
	ld		hl,LShootIce
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_R_ShootIce:
	ld		hl,RShootIce
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_L_ShootFireball:
	ld		hl,LShootFireball
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx

Set_R_ShootFireball:
	ld		hl,RShootFireball
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a
  jp    PlayShootSfx
  
Set_L_ShootArrow:
	ld		hl,LShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a

;  ld    a,RunningTablePointerCenter
;  ld    (RunningTablePointer),a  
  jp    PlayShootArrowSfx

Set_R_ShootArrow:
;  ld    a,(ArrowActive?)                    ;remove arrow when enemy is hit
;  or    a
;  ret   nz

	ld		hl,RShootArrow
	ld		(PlayerSpriteStand),hl

  ld    a,0 
  ld    (PlayerAniCount),a
 
;  ld    a,RunningTablePointerCenter
;  ld    (RunningTablePointer),a
  jp    PlayShootArrowSfx

Set_L_Meditate:
	ld		hl,LMeditate
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_meditate
  jp    RePlayerSFX_PlayCh1

Set_R_Meditate:
	ld		hl,RMeditate
	ld		(PlayerSpriteStand),hl

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_meditate
  jp    RePlayerSFX_PlayCh1

Set_L_BouncingBack:
  xor   a
;  ld    (EnableHitbox?),a
  ld    (PrimaryWeaponActivatedWhileJumping?),a  
  ld    (PrimaryWeaponActive?),a
  
	ld		hl,LBouncingBack
	ld		(PlayerSpriteStand),hl

;  ld    a,1
;  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a
  ld    bc,SFX_bouncingback
  jp    RePlayerSFX_PlayCh1
  
Set_R_BouncingBack:
  xor   a
;  ld    (EnableHitbox?),a
  ld    (PrimaryWeaponActivatedWhileJumping?),a  
  ld    (PrimaryWeaponActive?),a
    
	ld		hl,RBouncingBack
	ld		(PlayerSpriteStand),hl

;  ld    a,1
;  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    a,(StartingJumpSpeedWhenHit)
	ld		(JumpSpeed),a
  ld    bc,SFX_bouncingback
  jp    RePlayerSFX_PlayCh1


Set_Charging:
		xor   a
		ld    (HowManyFramesAgoWasLeftPressed?),a
		ld    (HowManyFramesAgoWasRightPressed?),a

		ld    bc,SFX_dash
		call  RePlayerSFX_PlayCh1

		ld    a,5
		ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

		ld    a,(PlayerFacingRight?)
		or    a
		jr    z,.FacingLeft
.FacingRight:
;check at height of waiste if player is near on the right side
		; ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
		; ld    de,XaddRightPlayer+16 ;add 15 to x to check right side of player for collision (player moved right)
		ld	 de,playerStanding.rightside+16
		jr    .PerformCheckTile
.FacingLeft:
;check at height of waiste if player is near on the right side
		; ld    b,YaddmiddlePLayer-1  ;add y to check (y is expressed in pixels)
		; ld    de,XaddLeftPlayer-16  ;add 0 to x to check left side of player for collision (player moved left)
		ld	 de,playerStanding.leftSide-16
		;  ld    a,(ClesX+1)
		;  bit   7,a
		;  ret   nz                  ;no need to perform tilecheck when player is out of screen on the left side
.PerformCheckTile:
		; call  checktile           ;out z=collision found with wall
		ld	 b,playerStanding.torso
		call checkTilePlayer
		ret   z
  ;now do the same check, but 2 tiles lower
		ld	 bc,roomMap.numcol
		add		hl,bc               ;1 tile lower=legs
		ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a                   ;1 = wall
		ret   z
        inc	 hl     ;1 tile lower=feet
		ld    a,(hl)              ;0=background, 1=hard foreground, 2=ladder, 3=lava.
		dec   a                   ;1 = wall
		ret   z		
		ld		hl,Charging
		ld		(PlayerSpriteStand),hl

		ld    hl,0 
		ld    (PlayerAniCount),hl  
		jp    SetHitBoxPlayerStanding



Set_Dying:
		ld		hl,Dying
		ld		(PlayerSpriteStand),hl
		xor   a
		ld    (PrimaryWeaponActivatedWhileJumping?),a
		ld    (PrimaryWeaponActive?),a  
		ret

Set_R_attack:
  ld    bc,SFX_punch
  call  RePlayerSFX_PlayCh1

  ld    a,4
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

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

Set_L_Sword_attack:
	ld		hl,LSwordAttack
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_Sword_attack:
	ld		hl,RSwordAttack
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1


Set_L_Dagger_attack:
  ld    a,r
  ld    (DaggerRandomizer),a

  ld    a,2
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

	ld		hl,LDaggerAttack
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_Dagger_attack:
  ld    a,r
  ld    (DaggerRandomizer),a

  ld    a,2
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

	ld		hl,RDaggerAttack
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_L_Axe_attack:
	ld		hl,LAxeAttack
	ld		(PlayerSpriteStand),hl

  ld    a,3
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_Axe_attack:
	ld		hl,RAxeAttack
	ld		(PlayerSpriteStand),hl

  ld    a,3
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_L_Spear_attack:
	ld		hl,LSpearAttack
	ld		(PlayerSpriteStand),hl

  ld    a,0
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_Spear_attack:
	ld		hl,RSpearAttack
	ld		(PlayerSpriteStand),hl

  ld    a,0
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  ld    a,1
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_L_Attack:
  ld    a,(AttackRotator)
  inc   a
  cp    5
  jr    nz,.SetAttackRotator
  xor   a
  .SetAttackRotator:
  ld    (AttackRotator),a

  ld    a,4
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

	ld		hl,LAttack
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (PlayerFacingRight?),a

  ld    hl,0 
  ld    (PlayerAniCount),hl
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_Rolling:
;  ld    bc,SFX_roll
;  call  RePlayerSFX_PlayCh1
  call  SetHitBoxPlayerRolling

  ld    a,7
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  ld    hl,0 
  ld    (PlayerAniCount),hl
  .SkipPlayerAniCount:
	ld		hl,RRolling
	ld		(PlayerSpriteStand),hl
  jp    ResetForceVerticalMovementCamera

ResetForceVerticalMovementCamera:
  xor   a
  ld    (ForceVerticalMovementCamera?),a  
  ld    (ForceVerticalMovementCameraTimer),a
  ld    (ForceVerticalMovementCameraTimerBackup),a
  ret

Set_L_Rolling:
;  ld    bc,SFX_roll
;  call  RePlayerSFX_PlayCh1
  call  SetHitBoxPlayerRolling

  ld    a,7
  ld    (CurrentPrimaryWeapon),a    ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling

  ld    hl,0 
  ld    (PlayerAniCount),hl
  .SkipPlayerAniCount:
	ld		hl,LRolling
	ld		(PlayerSpriteStand),hl
  jp    ResetForceVerticalMovementCamera

Set_Stairs_Climb_RightUp:
  call  SetHitBoxPlayerStanding
  
	ld		hl,ClimbStairsRightUp
	ld		(PlayerSpriteStand),hl

  xor   a
	ld		(PlayerAniCount),a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
;  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before climbing
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
  ret

Set_Stairs_Climb_LeftUp:
		call  SetHitBoxPlayerStanding
		ld		hl,ClimbStairsLeftUp
		ld		(PlayerSpriteStand),hl
		xor   a
		ld		(PlayerAniCount),a
		ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
		ld    (ShootArrowWhileJump?),a
		ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before climbing
		ld    (PrimaryWeaponActivatedWhileJumping?),a
		ld    (PrimaryWeaponActive?),a  
		ret

Set_ClimbDown:
  call  SetHitBoxPlayerStanding
  
	ld		hl,ClimbDown
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
;  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
  ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before climbing
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
  
  ld    hl,0 
  ld    (PlayerAniCount),hl
  ret

Set_ClimbUp:
		call  SetHitBoxPlayerStanding

		ld		hl,ClimbLadderUp
		ld		(PlayerSpriteStand),hl

		xor   a
		ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
		ld    (ShootArrowWhileJump?),a
		ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before climbing
		ld    (PrimaryWeaponActivatedWhileJumping?),a
		ld    (PrimaryWeaponActive?),a  
			
		ld    hl,0 
		ld    (PlayerAniCount),hl
		ret

Set_Climb_AndResetAniCount:
		ld    hl,0 
		ld    (PlayerAniCount),hl
Set_Climb:
		call  SetHitBoxPlayerStanding

		ld		hl,ClimbLadder
		ld		(PlayerSpriteStand),hl

		xor   a
		ld    (JumpSpeed),a                 ;this is reset so that CheckCollisionObjectPlayer works for the Pushing Block Switches
		;  ld    (EnableHitbox?),a
		ld    (ShootArrowWhileJump?),a
		ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before climbing
		ld    (PrimaryWeaponActivatedWhileJumping?),a
		ld    (PrimaryWeaponActive?),a  

		ld		hl,PlayerSpriteData_Char_Climbing1
		ld		(standchar),hl	

		ld    a,RunningTablePointerCenter
		ld    (RunningTablePointer),a
		ret

Set_jump:
		ld    bc,SFX_jump
		call  RePlayerSFX_PlayCh1

		call  SetHitBoxPlayerStanding

		;  ld    a,(ClesY)
		;  sub   a,3
		;  ld    (ClesY),a

		;  xor   a
		;  ld    (EnableHitbox?),a

		ld    a,(FlyingObtained?)
		or    a
		ld    a,1
		jr    z,.SetAmountOfDoubleJumps
		ld    a,2
.SetAmountOfDoubleJumps:
		ld    (DoubleJumpAvailable?),a

.SkipTurnOnDoubleJump:  
		ld		hl,Jump
		ld		(PlayerSpriteStand),hl

		ld    a,(StartingJumpSpeed)
		ld		(JumpSpeed),a
		ld		a,(clesy)
		ld		(jumpStartY),a

		ld    a,(PrimaryWeaponActivatedWhileJumping?)  
		or    a
		ret   nz                                                      ;don't reset PlayerAnicount if we initiate a double jump while primary attack is used

		;  ld    hl,0
		;	ld		(PlayerAniCount),hl

		xor   a
		ld		(PlayerAniCount),a
		ld    a,3
		ld		(PlayerAniCount+1),a
		ret

Set_Fall: 
  call  SetHitBoxPlayerStanding
  
  xor   a
;  ld    (EnableHitbox?),a
  ld    (ShootMagicWhileJump?),a                                ;check if player was shooting magic weapon right before getting hit

  ld    a,(FlyingObtained?)
  or    a
  ld    a,1
  jr    z,.SetAmountOfDoubleJumps
  ld    a,2
  .SetAmountOfDoubleJumps:
  ld    (DoubleJumpAvailable?),a

	ld		hl,Jump
	ld		(PlayerSpriteStand),hl

  ld    hl,0
	ld		(PlayerAniCount),hl
	ld    a,FallingJumpSpeed
	ld		(JumpSpeed),a
  ret

Set_L_Walljump:
	ld		hl,Lwalljump
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
	xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
  ret

Set_R_Walljump:
	ld		hl,Rwalljump
	ld		(PlayerSpriteStand),hl
  xor   a
	ld		(PlayerAniCount),a
	xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
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
		call  SetHitBoxPlayerSitting
		ld		hl,RSitting
		ld		(PlayerSpriteStand),hl
		ld		hl,PlayerSpriteData_Char_RightSitting
		ld		(standchar),hl
		xor   a
		ld    (PrimaryWeaponActivatedWhileJumping?),a
		ld    (PrimaryWeaponActive?),a
		ret


CollisionSYStanding:  equ 07 + 0
CollisionSYSitting:   equ 07 + 6
CollisionSYRolling:   equ 07 + 10

PlayerTopYHitBoxSoftSpritesSitting:   equ 17+8
PlayerTopYHitBoxSoftSpritesStanding:  equ 17
PlayerTopYHitBoxSoftSpritesRolling:   equ 17+8
SetHitBoxPlayerSitting:
  ld    a,CollisionSYSitting                    ;1st one is for hardware sprites (collision player-enemy)
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  ld    a,PlayerTopYHitBoxSoftSpritesSitting    ;2nd one is for software sprites (collision player-platforms)
  ld    (SelfModifyingCodeHitBoxPlayerTopY),a
  ret

SetHitBoxPlayerStanding:
		ld    a,CollisionSYStanding                   ;1st one is for hardware sprites (collision player-enemy)
		ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

		ld    a,PlayerTopYHitBoxSoftSpritesStanding   ;2nd one is for software sprites (collision player-platforms)
		ld    (SelfModifyingCodeHitBoxPlayerTopY),a
		ret

SetHitBoxPlayerRolling:
  ld    a,CollisionSYRolling                    ;1st one is for hardware sprites (collision player-enemy)
  ld    (CollisionEnemyPlayer.SelfModifyingCodeCollisionSY),a

  ld    a,PlayerTopYHitBoxSoftSpritesRolling    ;2nd one is for software sprites (collision player-platforms)
  ld    (SelfModifyingCodeHitBoxPlayerTopY),a
  ret

Set_L_sit:	
  call  SetHitBoxPlayerSitting

	ld		hl,LSitting
	ld		(PlayerSpriteStand),hl

	ld		hl,PlayerSpriteData_Char_LeftSitting
	ld		(standchar),hl

  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a
  ret

Set_L_stand:
  call  SetHitBoxPlayerStanding

  xor   a
  ld    (PlayerFacingRight?),a	

  ;check bow and arrow weapon active while landing
  ld    a,(ShootArrowWhileJump?)
  or    a
  jr    z,.EndCheckShootArrowWhileJump
  xor   a
  ld    (ShootArrowWhileJump?),a
	ld		hl,LShootArrow
	ld		(PlayerSpriteStand),hl
	ret
  .EndCheckShootArrowWhileJump:

  ;check primary weapon active while landing
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jr    z,.EndCheckPrimaryWeaponWhileJump

  ld    a,(CurrentPrimaryWeapon)                                ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
  or    a
	ld		hl,LSpearAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,LSwordAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,LDaggerAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,LAxeAttack
  jr    nz,.EndCheckPrimaryWeaponWhileJump

  .setPrimaryAttack:
	ld		(PlayerSpriteStand),hl
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a	
	ret
  .EndCheckPrimaryWeaponWhileJump:

  ;check secondary weapon active while landing
  ld    a,(ShootMagicWhileJump?)                                ;check if player was shooting magic weapon while jumping
  or    a
  jr    z,.EndCheckSecundaryWeaponWhileJump
  xor   a
  ld    (ShootMagicWhileJump?),a                                ;end shoot magic while jumping. commence shoot magic when standing

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  

  ld    a,(CurrentMagicWeapon)                                  ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  cp    5
  jp    z,.Fireball
  cp    7
  jp    z,.Ice
  cp    8
  jp    z,.Earth
  cp    9
  jp    z,.Water
  ret

  .Fireball:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,LShootFireball
  jr    .SetMagicShootingStand

  .Ice:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,LShootIce
  jr    .SetMagicShootingStand

  .Earth:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,LShootEarth
  jr    .SetMagicShootingStand

  .Water:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,LShootWater
	.SetMagicShootingStand:
	ld		(PlayerSpriteStand),hl
  xor   a
;  ld    (PlayerAniCount),a  
  ld    (ShootMagicWhileJump?),a                                ;end shoot magic while jumping. commence shoot magic when standing
  ret

  .EndCheckSecundaryWeaponWhileJump:
	ld		hl,PlayerSpriteData_Char_LeftStand
	ld		(standchar),hl
	ld		hl,LStanding
	ld		(PlayerSpriteStand),hl	
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
  ret

Set_R_stand:
  call  SetHitBoxPlayerStanding
;  xor   a
;  ld    (EnableHitbox?),a
  ld    a,1
  ld    (PlayerFacingRight?),a	

  ;check bow and arrow weapon active while landing
  ld    a,(ShootArrowWhileJump?)
  or    a
  jr    z,.EndCheckShootArrowWhileJump
  xor   a
  ld    (ShootArrowWhileJump?),a
	ld		hl,RShootArrow
	ld		(PlayerSpriteStand),hl
	ret
  .EndCheckShootArrowWhileJump:

  ;check primary weapon active while landing
  ld    a,(PrimaryWeaponActivatedWhileJumping?)
  or    a
  jr    z,.EndCheckPrimaryWeaponWhileJump

  ld    a,(CurrentPrimaryWeapon)                                ;0=spear, 1=sword, 2=dagger, 3=axe, 4=punch/kick, 5=charge, 6=silhouette kick, 7=rolling
  or    a
	ld		hl,RSpearAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,RSwordAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,RDaggerAttack
  jr    z,.setPrimaryAttack
  dec   a
	ld		hl,RAxeAttack
  jr    nz,.EndCheckPrimaryWeaponWhileJump

  .setPrimaryAttack:
	ld		(PlayerSpriteStand),hl
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a
	ret
  .EndCheckPrimaryWeaponWhileJump:

  ;check secondary weapon active while landing
  ld    a,(ShootMagicWhileJump?)                                ;check if player was shooting magic weapon while jumping
  or    a
  jr    z,.EndCheckSecundaryWeaponWhileJump
  xor   a
  ld    (ShootMagicWhileJump?),a                                ;end shoot magic while jumping. commence shoot magic when standing

  ld    a,RunningTablePointerCenter
  ld    (RunningTablePointer),a  

  ld    a,(CurrentMagicWeapon)                                  ;0=nothing, 1=rolling, 2=charging, 3=meditate, 4=shoot arrow, 5=shoot fireball, 6=silhouette kick, 7=shoot ice, 8=shoot earth, 9=shoot water
  cp    5
  jp    z,.Fireball
  cp    7
  jp    z,.Ice
  cp    8
  jp    z,.Earth
  cp    9
  jp    z,.Water
  ret

  .Fireball:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,RShootFireball
  jr    .SetMagicShootingStand

  .Ice:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,RShootIce
  jr    .SetMagicShootingStand

  .Earth:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,RShootEarth
  jr    .SetMagicShootingStand

  .Water:
  ld    a,(SecundaryWeaponActive?)                                     ;check if fireball is already being shot
  or    a
  ret   nz
	ld		hl,RShootWater
	.SetMagicShootingStand:
	ld		(PlayerSpriteStand),hl
  xor   a
;  ld    (PlayerAniCount),a  
  ld    (ShootMagicWhileJump?),a                                ;end shoot magic while jumping. commence shoot magic when standing
  ret

  .EndCheckSecundaryWeaponWhileJump:
	ld		hl,PlayerSpriteData_Char_RightStand
	ld		(standchar),hl
	ld		hl,RStanding
	ld		(PlayerSpriteStand),hl	
  xor   a
  ld    (PrimaryWeaponActivatedWhileJumping?),a  
  ld    (PrimaryWeaponActive?),a
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
  ld    bc,SFX_beinghit
  call  RePlayerSFX_PlayCh1
  call  SetHitBoxPlayerStanding
  
	ld		hl,LBeingHit
	ld		(PlayerSpriteStand),hl
  xor   a
;  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
;  ld    a,1
;  ld    (KickWhileJump?),a  
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  

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
  ld    bc,SFX_beinghit
  call  RePlayerSFX_PlayCh1
  call  SetHitBoxPlayerStanding
  
	ld		hl,RBeingHit
	ld		(PlayerSpriteStand),hl
  xor   a
;  ld    (EnableHitbox?),a
  ld    (ShootArrowWhileJump?),a
;  ld    a,1
;  ld    (KickWhileJump?),a  
  ld    (PrimaryWeaponActivatedWhileJumping?),a
  ld    (PrimaryWeaponActive?),a  
  
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
  call  SetHitBoxPlayerSitting
  
	ld		hl,LSitPunch
	ld		(PlayerSpriteStand),hl

  xor   a
  ld    (PlayerFacingRight?),a	
	ld		(PlayerAniCount),a
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1

Set_R_SitPunch:
  call  SetHitBoxPlayerSitting
  
	ld		hl,RSitPunch
	ld		(PlayerSpriteStand),hl

  ld    a,1
  ld    (PlayerFacingRight?),a
	
  xor   a
	ld		(PlayerAniCount),a
  ld    bc,SFX_punch
  jp    RePlayerSFX_PlayCh1


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



;##### generic base functions #####

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
;out:	HL=adr of 32bytes palrecord
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

;Palettes table
palettes:
.reclen:		equ 32
.numrec:		equ 32
.data:
.0:				DS .reclen		;incBin filename,0,.reclen
.1Pollux:		DB $06,$05,$12,$01,$32,$03,$34,$03,$20,$01,$21,$02,$07,$05,$73,$06,$05,$03,$77,$07,$53,$05,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.2Lemniscate:	DB $06,$05,$12,$01,$32,$03,$34,$03,$20,$01,$21,$02,$07,$05,$73,$06,$05,$03,$77,$07,$53,$05,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.3WorldForrest:	DB $32,$03,$12,$01,$20,$05,$34,$03,$10,$01,$00,$03,$21,$02,$73,$06,$00,$02,$77,$07,$40,$06,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.4Pegu:		    DB $60,$05,$12,$01,$20,$05,$34,$03,$20,$01,$00,$03,$50,$03,$73,$06,$40,$02,$77,$07,$40,$06,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.5Shalabha:		DB $61,$03,$12,$01,$20,$05,$34,$03,$20,$01,$00,$03,$41,$02,$73,$06,$00,$02,$77,$07,$40,$06,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.6KarniMata:	DB 71,5,18,1,32,5,52,3,32,1,0,3,80,3,115,6,0,2,119,7,64,6,35,2,69,4,112,5,112,2,0,0
.7Konark:		DB $77,$04,$12,$01,$42,$03,$34,$03,$20,$01,$31,$02,$61,$03,$73,$06,$41,$02,$77,$07,$53,$04,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.8:				DS .reclen
.9Taxila:		DB $47,$05,$12,$01,$20,$05,$34,$03,$21,$01,$00,$03,$41,$02,$73,$06,$00,$02,$77,$07,$40,$06,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.10:			DS .reclen
.11Akna:		DB $71,$06,$12,$01,$04,$02,$34,$03,$26,$04,$03,$01,$50,$03,$73,$06,$20,$01,$77,$07,$15,$03,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.12:			DB $77,$04,$10,$00,$40,$02,$34,$03,$20,$00,$30,$01,$60,$04,$73,$06,$12,$01,$77,$07,$50,$03,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.13:			DS .reclen
.14:			DS .reclen
.15:			DS .reclen
.16_23:			DS .reclen*8
.24_30:			DS .reclen*7
.31Teleport:	DB $00,$00,$12,$01,$50,$02,$34,$03,$20,$00,$30,$01,$00,$00,$73,$06,$00,$00,$77,$07,$70,$04,$23,$02,$45,$04,$70,$05,$70,$02,$00,$00
.32Worldmap:	DB $00,$00,$12,$01,$30,$00,$50,$00,$23,$02,$70,$02,$73,$06,$70,$05,$34,$03,$40,$00,$77,$07,$45,$04,$00,$04,$45,$05,$00,$00,$00,$00
.33_39:			DS .reclen*7

;Write pal data [HL] to VDP
SetPalette:
		xor		a
		di
		out		($99),a
		ld		a,16+128
		out		($99),a
		ld		bc,$209A
		otir
		ei
		ret


;Set VDP port #98 to start reading at address AHL (17-bit)
SetVdp_Read:  
		rlc     h
		rla
		rlc     h
		rla
		srl     h
		srl     h
		di
		out     ($99),a         ;set A16-A14
		ld      a,14+128
		out     ($99),a
		ld      a,l             ;set A7-A0
		out     ($99),a
		ld      a,h             ;set A8-A13 (bit 6=0, read mode)
		and		0x3F		;read mode
		ei
		out     ($99),a
		ret
              
;
;Set VDP to start writing at address AHL (17-bit)
SetVdp_Write: 
		rlc     h
		rla
		rlc     h
		rla
		srl     h
		srl     h
		di
		out     ($99),a         ;set A16-A14
		ld      a,14+128
		out     ($99),a
		ld      a,l             ;set A7-A0
		out     ($99),a
		ld      a,h             ;set A8-A13 (bit 6=1, write mode)
		or      64				;mode=write
		ei
		out     ($99),a       
		ret

SetVdp_WriteRemainDI: 
		rlc     h
		rla
		rlc     h
		rla
		srl     h
		srl     h
		di
		out     ($99),a         ;set A16-A14
		ld      a,14+128
		out     ($99),a
		ld      a,l             ;set A7-A0
		out     ($99),a
		ld      a,h             ;set A8-A13 (bit 6=1, write mode)
		or      64				;mode=write
		out     ($99),a
		ret


;set vPage
setpage:              ;in a->x*32+31 (x=page)
		di
		out   ($99),a
		ld    a,2+128
		ei
		out   ($99),a
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


SpritesOn:
  ld    a,(VDP_8)             ;sprites on
  and   %11111101
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
  ei
  out   ($99),a
  ret

SpritesOff:
  ld    a,(VDP_8)         ;sprites off
  or    %00000010
  ld    (VDP_8),a
  di
  out   ($99),a
  ld    a,8+128
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

endengine:
enLength: equ $-engaddr
dephase