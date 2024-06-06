;VoodooWaspTilesBlock:  equ   GraphicsSc5DataStartBlock   ;ruin Euderus Set (10)
;phase	$4000
;  incbin "..\grapx\tilesheets\sVoodooWasp.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sVoodooWaspBottom48Lines.SC5",7,48 * 128 ;48 lines
;	ds		$c000-$,$ff
;dephase

;GoddessTilesBlock:  equ   VoodooWaspTilesBlock+2	;ruin Fate (12)
;phase	$4000
;  incbin "..\grapx\tilesheets\sGoddess.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sGoddessBottom48Lines.SC5",7,48 * 128 ;48 lines
;	ds		$c000-$,$ff
;dephase

;KarniMataTilesBlock:  equ   GoddessTilesBlock+2		;ruin Karni Mata (6)
;phase	$4000
;  incbin "..\grapx\tilesheets\sKarniMata.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sKarniMataBottom48Lines.SC5",7,48 * 128 ;48 lines
;	incbin "..\grapx\tilesheets\KarniMataTiles.sc5" ;full 256*212
;	ds		$c000-$,$ff
;dephase

;BlueTempleTilesBlock:  equ   KarniMataTilesBlock+2	; ruin Akna (11)
;phase	$4000
;  incbin "..\grapx\tilesheets\sBlueTemple.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sBlueTempleBottom48Lines.SC5",7,48 * 128 ;48 lines
;	ds		$c000-$,$ff
;dephase

;KonarkTilesBlock:  equ   BlueTempleTilesBlock+2	; ruin Konark (7)
;phase	$4000
 ; incbin "..\grapx\tilesheets\sKonark.SC5",7,208 * 128      ;208 lines
 ; incbin "..\grapx\tilesheets\sKonarkBottom48Lines.SC5",7,48 * 128 ;48 lines
;	ds		$c000-$,$ff
;dephase

GfxObjectsForVramBlock:     equ ($-RomStartAddress) and (romsize-1) /RomBlockSize ;KonarkTilesBlock+2	;ruin Taxilla (9)
;phase	$4000
;GfxObjectsForVram:
  incbin "..\grapx\GfxObjectsForVram.SC5",7,128 * 128 ;skip header, 128 lines
	DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block ;ds		$c000-$,$ff
;dephase

Graphicsblock4:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;GfxObjectsForVramBlock+2
phase	$8000
itemsKarniMataPage3:	incbin "..\grapx\itemsKarniMataPage3.SC5",7,128 * 40 ;skip header, 40 lines
						DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	;ds		$c000-$,$ff
dephase

Graphicsblock5:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;Graphicsblock4+1 
phase	$8000
scoreboard:
  incbin "..\grapx\scoreboard\scoreboard.SC5",7,39*128  ;39 lines high
itemsKarniMata:
  incbin "..\grapx\itemsKarniMata.SC5",7,40*128  ;40 lines high
ElementalWeapons:
  incbin "..\grapx\ElementalWeapons.SC5",7,22*128  ;22 lines high
	ds		$c000-$,$ff
dephase

TeamNXTLogoTransparantGraphicsblock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;Graphicsblock5+1
phase	$4000
  incbin "..\grapx\TeamNXTLogo\TransparantBlocks.SC5",7,200*128  ;skip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

TeamNXTLogoNonTransparantGraphicsblock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;TeamNXTLogoTransparantGraphicsblock+2
phase	$4000
  incbin "..\grapx\TeamNXTLogo\NonTransparantBlocks.SC5",7,200*128  ;kip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

BossAreaTilesBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;TeamNXTLogoNonTransparantGraphicsblock+2
phase	$4000
  incbin "..\grapx\tilesheets\sBossArea.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sBossAreaBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

F1MenuGraphicsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;BossAreaTilesBlock+2
phase	$4000
  incbin "..\grapx\F1Menu\F1Menu.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

PrimaryWeaponSelectGraphicsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;F1MenuGraphicsBlock+2
phase	$4000
  incbin "..\grapx\F1Menu\PrimaryWeaponSelectScreen.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

;IceTempleTilesBlock:  equ   PrimaryWeaponSelectGraphicsBlock+2	;ruin Morana (24)
;phase	$4000
;  incbin "..\grapx\tilesheets\sIceTemple.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sIceTempleBottom48Lines.SC5",7,48 * 128 ;48 lines;
;	ds		$c000-$,$ff
;dephase

NPCDialogueFontBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;IceTempleTilesBlock+2
phase	$4000
;NPCDialogueFontAddress:
;  incbin "..\grapx\font\NPCDialogueFont.SC5",7,016 * 128      ;016 lines
NPCDialogueFontAndBackgroundAddress:
  incbin "..\grapx\font\FontAndBackground.SC5",7,075 * 128      ;068 lines
	ds		$8000-$,$ff
dephase

CharacterPortraitsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;NPCDialogueFontBlock+1
phase	$4000
CharacterPortraits:
  incbin "..\grapx\font\CharacterPortraits.SC5",7,056 * 128      ;016 lines
	ds		$8000-$,$ff
dephase

WaterfallSceneBlock1:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
phase	$4000
  incbin "..\grapx\WaterfallScene\Backdrop1.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

WaterfallSceneBlock2:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
phase	$4000
  incbin "..\grapx\WaterfallScene\Backdrop2.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

WaterfallSceneBlock3:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
phase	$4000
  incbin "..\grapx\WaterfallScene\Backdrop3.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

WaterfallSceneBlock4:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
phase	$4000
  incbin "..\grapx\WaterfallScene\Backdrop4.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase
