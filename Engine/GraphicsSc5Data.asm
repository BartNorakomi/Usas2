VoodooWaspTilesBlock:  equ   GraphicsSc5DataStartBlock
phase	$4000
  incbin "..\grapx\tilesheets\sVoodooWasp.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sVoodooWaspBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

GoddessTilesBlock:  equ   VoodooWaspTilesBlock+2
phase	$4000
  incbin "..\grapx\tilesheets\sGoddess.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sGoddessBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

KarniMataTilesBlock:  equ   GoddessTilesBlock+2
phase	$4000
  incbin "..\grapx\tilesheets\sKarniMata.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sKarniMataBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

BlueTempleTilesBlock:  equ   KarniMataTilesBlock+2
phase	$4000
;  incbin "..\grapx\tilesheets\sBlueTemple.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sBlueTempleBottom48Lines.SC5",7,48 * 128 ;48 lines
incbin "..\tools\karnimatatiles.sc5"
	ds		$c000-$,$ff
dephase

KonarkTilesBlock:  equ   BlueTempleTilesBlock+2
phase	$4000
  incbin "..\grapx\tilesheets\sKonark.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sKonarkBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

BurialTilesBlock:  equ   KonarkTilesBlock+2
phase	$4000
  incbin "..\grapx\tilesheets\sBurial.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sBurialBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

Graphicsblock4:  equ   BurialTilesBlock+2
phase	$8000
itemsKarniMataPage3:
  incbin "..\grapx\itemsKarniMataPage3.SC5",7,128 * 40 ;skip header, 40 lines
	ds		$c000-$,$ff
dephase

Graphicsblock5:  equ   Graphicsblock4+1 
phase	$8000
scoreboard:
  incbin "..\grapx\scoreboard\scoreboard.SC5",7,39*128  ;skip header
itemsKarniMata:
  incbin "..\grapx\itemsKarniMata.SC5",7,$1400  ;skip header
ElementalWeapons:
  incbin "..\grapx\ElementalWeapons.SC5",7,128*22  ;=$b00 - skip header
	ds		$c000-$,$ff
dephase

TeamNXTLogoTransparantGraphicsblock:  equ   Graphicsblock5+1
phase	$4000
  incbin "..\grapx\TeamNXTLogo\TransparantBlocks.SC5",7,200*128  ;skip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

TeamNXTLogoNonTransparantGraphicsblock:  equ   TeamNXTLogoTransparantGraphicsblock+2
phase	$4000
  incbin "..\grapx\TeamNXTLogo\NonTransparantBlocks.SC5",7,200*128  ;kip header, height is 200, total bytes = $6400
	ds		$c000-$,$ff
dephase

BossAreaTilesBlock:  equ   TeamNXTLogoNonTransparantGraphicsblock+2
phase	$4000
  incbin "..\grapx\tilesheets\sBossArea.SC5",7,208 * 128      ;208 lines
;  incbin "..\grapx\tilesheets\sBossAreaBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

F1MenuGraphicsBlock:  equ   BossAreaTilesBlock+2
phase	$4000
  incbin "..\grapx\F1Menu\F1Menu.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

PrimaryWeaponSelectGraphicsBlock:  equ   F1MenuGraphicsBlock+2
phase	$4000
  incbin "..\grapx\F1Menu\PrimaryWeaponSelectScreen.SC5",7,212 * 128      ;212 lines
	ds		$c000-$,$ff
dephase

IceTempleTilesBlock:  equ   PrimaryWeaponSelectGraphicsBlock+2
phase	$4000
  incbin "..\grapx\tilesheets\sIceTemple.SC5",7,208 * 128      ;208 lines
  incbin "..\grapx\tilesheets\sIceTempleBottom48Lines.SC5",7,48 * 128 ;48 lines
	ds		$c000-$,$ff
dephase

NPCDialogueFontBlock:  equ   IceTempleTilesBlock+2
phase	$4000
;NPCDialogueFontAddress:
;  incbin "..\grapx\font\NPCDialogueFont.SC5",7,016 * 128      ;016 lines
NPCDialogueFontAndBackgroundAddress:
  incbin "..\grapx\font\FontAndBackground.SC5",7,075 * 128      ;068 lines
	ds		$8000-$,$ff
dephase

CharacterPortraitsBlock:  equ   NPCDialogueFontBlock+1
phase	$4000
CharacterPortraits:
  incbin "..\grapx\font\CharacterPortraits.SC5",7,056 * 128      ;016 lines
	ds		$8000-$,$ff
dephase
