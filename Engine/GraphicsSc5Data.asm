;Raw scraphics

GfxObjectsForVramBlock: equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
;GfxObjectsForVram:
		incbin "..\grapx\GfxObjectsForVram.SC5",7,128 * 128 ;skip header, 128 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

Graphicsblock4: equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;GfxObjectsForVramBlock+2
phase	$000
itemsKarniMataPage3:
		incbin "..\grapx\itemsKarniMataPage3.SC5",7,128 * 40 ;skip header, 40 lines
dephase
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	;ds		$c000-$,$ff

Graphicsblock5:			equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;Graphicsblock4+1 
phase	$8000
scoreboard:
		incbin "..\grapx\scoreboard\scoreboard.SC5",7,39*128  ;39 lines high
itemsKarniMata:
		incbin "..\grapx\itemsKarniMata.SC5",7,40*128  ;40 lines high
ElementalWeapons:
		incbin "..\grapx\ElementalWeapons.SC5",7,22*128  ;22 lines high
dephase
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

TeamNXTLogoTransparantGraphicsblock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;Graphicsblock5+1
		incbin "..\grapx\TeamNXTLogo\TransparantBlocks.SC5",7,200*128  ;skip header, height is 200, total bytes = $6400
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
TeamNXTLogoNonTransparantGraphicsblock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;TeamNXTLogoTransparantGraphicsblock+2
		incbin "..\grapx\TeamNXTLogo\NonTransparantBlocks.SC5",7,200*128  ;kip header, height is 200, total bytes = $6400
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


F1MenuGraphicsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;BossAreaTilesBlock+2
		incbin "..\grapx\F1Menu\F1Menu.SC5",7,212 * 128      ;212 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

PrimaryWeaponSelectGraphicsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;F1MenuGraphicsBlock+2
		incbin "..\grapx\F1Menu\PrimaryWeaponSelectScreen.SC5",7,212 * 128      ;212 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

F2MenuGraphicsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;Worldmap
		incbin "..\grapx\F2Menu\worldmap.SC5",0,212 * 128      ;212 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


NPCDialogueFontBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;IceTempleTilesBlock+2
phase	$4000
;NPCDialogueFontAddress:
;  incbin "..\grapx\font\NPCDialogueFont.SC5",7,016 * 128      ;016 lines
NPCDialogueFontAndBackgroundAddress:
		incbin "..\grapx\font\FontAndBackground.SC5",7,075 * 128      ;068 lines
dephase
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

CharacterPortraitsBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize ;NPCDialogueFontBlock+1
phase	$4000
CharacterPortraits:
		incbin "..\grapx\font\CharacterPortraits.SC5",7,056 * 128      ;016 lines
dephase
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


WaterfallSceneBlock1:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
		incbin "..\grapx\WaterfallScene\Backdrop1.SC5",7,128 * 128      ;128 lines
		incbin "..\grapx\WaterfallScene\Backdrop4.SC5",7,128 * 128      ;128 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

WaterfallSceneBlock2:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
		incbin "..\grapx\WaterfallScene\Backdrop3.SC5",7,128 * 128      ;128 lines
		incbin "..\grapx\WaterfallScene\Backdrop2.SC5",7,128 * 128      ;128 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


KonarkLavaSceneBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
		incbin "..\grapx\animated backgrounds\KonarkLava\KonarkLava4Steps.SC5",7,160 * 128      ;160 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossPlantBackdropBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
		incbin "..\grapx\BossPlant\BossPlantBackdrop.SC5",7,212 * 128      ;212 lines
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

AreaSignTestBlock:  equ   ($-RomStartAddress) and (romsize-1) /RomBlockSize
phase	$4000
AreaSign01:   incbin "..\grapx\AreaSigns\01-hub.SC5.pck"      ;048 lines
AreaSign02:   incbin "..\grapx\AreaSigns\02-Lemniscate.SC5.pck"      ;048 lines
AreaSign03:   incbin "..\grapx\AreaSigns\03-Forest.SC5.pck"      ;048 lines
AreaSign04:   incbin "..\grapx\AreaSigns\04-Pegu.SC5.pck"      ;048 lines
AreaSign05:   incbin "..\grapx\AreaSigns\05-Shalabha.SC5.pck"      ;048 lines
AreaSign06:   incbin "..\grapx\AreaSigns\06-Karni Mata.SC5.pck"      ;048 lines
AreaSign07:   incbin "..\grapx\AreaSigns\07-Konark.SC5.pck"      ;048 lines
AreaSign08:   incbin "..\grapx\AreaSigns\08-Ashoka.SC5.pck"      ;048 lines
AreaSign09:   incbin "..\grapx\AreaSigns\09-Taxila.SC5.pck"      ;048 lines
AreaSign10:   incbin "..\grapx\AreaSigns\10-Euderus Set.SC5.pck"      ;048 lines
AreaSign11:   incbin "..\grapx\AreaSigns\11-Akna.SC5.pck"      ;048 lines
AreaSign12:   incbin "..\grapx\AreaSigns\12-Fate.SC5.pck"      ;048 lines
AreaSign13:   incbin "..\grapx\AreaSigns\13-Sepa.SC5.pck"      ;048 lines
AreaSign14:   ;incbin "..\grapx\AreaSigns\14- .SC5.pck"      ;048 lines >new:worldRoots
AreaSign15:   incbin "..\grapx\AreaSigns\15-Chi.SC5.pck"      ;048 lines
AreaSign16:   incbin "..\grapx\AreaSigns\16-Sui.SC5.pck"      ;048 lines
AreaSign17:   incbin "..\grapx\AreaSigns\17-Vala.SC5.pck"      ;048 lines
AreaSign18:   incbin "..\grapx\AreaSigns\18-Tiwanaku.SC5.pck"      ;048 lines
AreaSign19:   incbin "..\grapx\AreaSigns\19-Aggayu.SC5.pck"      ;048 lines

;these next area signs don't fit the block
;AreaSign20:   incbin "..\grapx\AreaSigns\20-Ka.SC5.pck"      ;048 lines
;AreaSign21:   incbin "..\grapx\AreaSigns\21-Genbu.SC5.pck"      ;048 lines
;AreaSign22:   incbin "..\grapx\AreaSigns\22-Fuu.SC5.pck"      ;048 lines
;AreaSign23:   incbin "..\grapx\AreaSigns\23-Indra.SC5.pck"      ;048 lines
;AreaSign24:   incbin "..\grapx\AreaSigns\24-Morana.SC5.pck"      ;048 lines
dephase
		DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
