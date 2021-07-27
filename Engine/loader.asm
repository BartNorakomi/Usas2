loader:
;  ld    hl,level00startingcoordinates
;  ld    a,00 
  call	levelloader

  jp    loadGraphics
  
levelloader:                                            ;in a->level to load, in hl->startingcoordinates for mappointer and mario
;  ld    (currentlevel),a
;  call  .golevel
;  jp    levelloader

;.golevel:
;  call  startingcoordinates                             ;set startingcoordinates for mappointer and mario
;  call  loadmapdatapositionin_ix
;	call	loadgrapx                                       ;in -> mapdatapositionin_ix
;  call  loadmap                                         ;in -> mapdatapositionin_ix
;  call  initcamera                                      ;initieer de camera op een vaste positie rondom mario
  
 ; jp    initmusic_and_goEngine
  
;level00startingcoordinates:  dw 0 |dw 0 | dw 0 | dw 0   ;mappointer y, mappointer x, mario y, mario x

  ret


;mapdata:
;.level:         equ 0
;.empty1:        equ 1
;.empty2:        equ 2
;.maplengt:      equ 3
;.mapheight:     equ 5
;.empty3:        equ 6
;.backgrmapblock:equ 7
;.empty4:        equ 8
;.backgrmapaddr: equ 10
;.grpxblck:      equ 12
;.grpxaddr:      equ 13
;  db    00,0,0 | dw 638 | db 051,0,blockbackgrl00 | dw 00 | dw backgrl00 | db grpxblckl00 | dw grpx00addr

;lenghtmapdata:  equ 14

  
;loadmapdatapositionin_ix:
;  ld    a,(currentlevel)
;  ld    ix,mapdata
;  ld    de,lenghtmapdata
;.loop:
;  cp    (ix)
;  ret   z
;  add   ix,de
;  jp    .loop

loadgrapx:	                                              ;in -> mapdatapositionin_ix
;  ld    a,(ix+mapdata.grpxblck)   
;  ld    b,a
;  ld    a,(ix+mapdata.grpxaddr+1)    
;  ld    h,a
;  ld    a,(ix+mapdata.grpxaddr)    
;  ld    l,a

;  ld    de,$4000
;  call  unpackfrompage3to2                                ;hl->source, de->destiny, b->block, out-> slot.page12rom, loaderblock in block 3 ($8000)

;	ld		a,(slot.page2rom)	                                ;all RAM except page 2
;	out		($a8),a	

;	xor		a
;	ld		hl,$0000		                                      ;character pattern table starts at 0 ($0000)
;	call	SetVdp_Write
;write 2048 bytes	
;	ld		hl,pattaddre	                                    ;character pattern table
;	ld		bc,$0098
;	otir	otir	otir	otir	otir	otir	otir	otir

;	xor		a
;	ld		hl,$2000		                                      ;color table starts at 8192 ($2000)
;	call	SetVdp_Write
;write 2048 bytes	
;	ld		hl,coloraddre	                                    ;color table
;	ld		bc,$0098
;	otir	otir	otir	otir	otir	otir	otir	otir

;	ld		hl,paletaddre
;	call	setpalette
;	ld		hl,paletaddre
;  ld    de,currentpalette
;  ld    bc,16*2
;  ldir

;  ld    hl,currentpalette
;  ld    de,currentpaletteONEtintdarker
;  ld    bc,16*2
;  ldir

;  ld    hl,currentpaletteONEtintdarker
;  ld    b,1                               ;amount of steps to darken

;  ld    c,b                               ;amount of steps to darken stored in c
;  ld    e,16                              ;16 colors
;.loop:
;  call  .darkencolor
;  dec   e
;  jp    nz,.loop
;  ret

loadmap:                                                  ;in -> mapdatapositionin_ix
;set backgroundmap lenght en height
;  ld    l,(ix+mapdata.maplengt)
;  ld    h,(ix+mapdata.maplengt+1)
;  ld    (maplenght),hl                                    ;map lenght
;  ld    de,32
;  xor   a                                                 ;reset carry
;  sbc   hl,de
;  ld    (maplenghtmin32),hl                               ;map lenght - 32

;  ld    a,(ix+mapdata.mapheight)                          ;map height
;	sub		a,23
;	ld		(mapheightmin23),a	
;/set backgroundmap lenght en height

;copy map to ram
 ; ld    b,(ix+mapdata.backgrmapblock)                     ;background map block
 ; ld    l,(ix+mapdata.backgrmapaddr)                      ;backgrmapaddr
 ; ld    h,(ix+mapdata.backgrmapaddr+1)  
 ; ld    de,bgrmapaddr
 ; call  copymaptoram                                      ;hl->source, de->destiny, b->block, out-> slot.page12rom, loaderblock in block 3 ($8000)
;/unpack map to ram
 ; ret
  