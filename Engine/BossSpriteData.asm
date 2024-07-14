BossGoatIdleAndWalkframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossGoat\IdleAndWalk\frames.lst" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossGoatIdleAndWalkspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossGoat\IdleAndWalk\frames.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatWalkAndAttackframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										phase	$8000
										include "..\grapx\BossGoat\WalkAndAttack\frames.lst" 
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
										dephase
BossGoatWalkAndAttackspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										incbin "..\grapx\BossGoat\WalkAndAttack\frames.dat"
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatAttackframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\BossGoat\Attack\frames.lst" 
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
BossGoatAttackspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\BossGoat\Attack\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatAttack2framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\BossGoat\Attack2\frames.lst" 
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
BossGoatAttack2spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\BossGoat\Attack2\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatAttackAndHitframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										phase	$8000
										include "..\grapx\BossGoat\AttackAndHit\frames.lst" 
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
										dephase
BossGoatAttackAndHitspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										incbin "..\grapx\BossGoat\AttackAndHit\frames.dat"
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatDyingframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\BossGoat\Dying\frames.lst" 
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
BossGoatDyingspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\BossGoat\Dying\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossGoatDying2framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\BossGoat\Dying2\frames.lst" 
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
BossGoatDying2spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\BossGoat\Dying2\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;20250525;ro;What is this? > it contains big objects, like big block and balls
ryuframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
					phase	$8000
					include "..\grapx\ryu\spritesryuPage0\frames.lst" 
					DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
					dephase
ryuspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
					incbin "..\grapx\ryu\spritesryuPage0\frames.dat"
					DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossDemonframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\ryu\spritesryuPage1\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
BossDemonspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\ryu\spritesryuPage1\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossDemonframelistblock2: 	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\ryu\spritesryuPage2\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
BossDemonspritedatablock2:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\ryu\spritesryuPage2\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossDemonframelistblock3:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\ryu\spritesryuPage3\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
BossDemonspritedatablock3:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\ryu\spritesryuPage3\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossDemonframelistblock4:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\ryu\spritesryuPage4\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
BossDemonspritedatablock4:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\ryu\spritesryuPage4\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossRoomframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\BossRoom\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
BossRoomspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\BossRoom\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Wasp
BossVoodooWaspIdleframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossVoodooWasp\Idle\frames.lst" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossVoodooWaspIdlespritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossVoodooWasp\Idle\frames.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossVoodooWaspHitframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossVoodooWasp\Hit\frames.lst" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossVoodooWaspHitspritedatablock:   equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossVoodooWasp\Hit\frames.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Zombie Cater pillar
BossZombieCaterpillarIdleframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
											phase	$8000
											include "..\grapx\BossZombieCaterpillar\Idle\frames.lst" 
											DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
											dephase
BossZombieCaterpillarIdlespritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
											incbin "..\grapx\BossZombieCaterpillar\Idle\frames.dat"
											DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossZombieCaterpillarAttackframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
											phase	$8000
											include "..\grapx\BossZombieCaterpillar\attack\frames.lst" 
											DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
											dephase
BossZombieCaterpillarAttackspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
											incbin "..\grapx\BossZombieCaterpillar\attack\frames.dat"
											DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossZombieCaterpillarDyingPart1framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
												phase	$8000
												include "..\grapx\BossZombieCaterpillar\DyingPart1\frames.lst" 
												DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
												dephase
BossZombieCaterpillarDyingPart1spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
												incbin "..\grapx\BossZombieCaterpillar\DyingPart1\frames.dat"
												DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossZombieCaterpillarDyingPart2framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
												phase	$8000
												include "..\grapx\BossZombieCaterpillar\DyingPart2\frames.lst" 
												DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
												dephase
BossZombieCaterpillarDyingPart2spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
												incbin "..\grapx\BossZombieCaterpillar\DyingPart2\frames.dat"
												DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Area Sign
AreaSignsframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase $8000
							include "..\grapx\AreaSigns\frames.new.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
AreaSignsspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\AreaSigns\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Teleporter part 1
;TeleportPart1framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
;								phase	$8000
; 								include "..\grapx\TeleportRoom\Part1\frames.new.lst"
; 								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
; 								dephase
; TeleportPart1spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
; 								incbin "..\grapx\TeleportRoom\Part1\frames.dat"
; 								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

; ;Teleporter part 2
; TeleportPart2framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
; 								phase	$8000
; 								include "..\grapx\TeleportRoom\Part2\frames.new.lst"
; 								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
; 								dephase
; TeleportPart2spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
; 								incbin "..\grapx\TeleportRoom\Part2\frames.dat"
; 								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Teleporter part 3
TeleportPart3framelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\TeleportRoom\Part3\frames.new.lst"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
TeleportPart3spritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\TeleportRoom\Part3\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

BossDemonIdleframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								phase	$8000
								include "..\grapx\BossDemon\Idle\frames.lst" 
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
								dephase
BossDemonIdlespritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
								incbin "..\grapx\BossDemon\Idle\frames.dat"
								DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block



BossDemonIdleNewframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonIdle.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonIdleNewspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonIdle.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block								

BossDemonWalkNewframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonWalk.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonWalkNewspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonWalk.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	

BossDemonHitNewframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonHit.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonHitNewspritedatablock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonHit.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	

BossDemonCleave0to5Newframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										phase	$8000
										include "..\grapx\BossDemon\BossDemonCleave0to5.asm" 
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
										dephase
BossDemonCleave0to5Newspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										incbin "..\grapx\BossDemon\BossDemonCleave0to5.dat"
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	

BossDemonCleave6to7Newframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										phase	$8000
										include "..\grapx\BossDemon\BossDemonCleave6to7.asm" 
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
										dephase
BossDemonCleave6to7Newspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										incbin "..\grapx\BossDemon\BossDemonCleave6to7.dat"
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	

BossDemonCleave8to12Newframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										phase	$8000
										include "..\grapx\BossDemon\BossDemonCleave8to12.asm" 
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
										dephase
BossDemonCleave8to12Newspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
										incbin "..\grapx\BossDemon\BossDemonCleave8to12.dat"
										DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	
										
BossDemonCastingNewframelistblock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonCasting.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonCastingNewspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonCasting.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	
BossDemonDying1to4Newframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonDying1to4.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonDying1to4Newspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonDying1to4.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	
BossDemonDying4to14Newframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									phase	$8000
									include "..\grapx\BossDemon\BossDemonDying5to14.asm" 
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
									dephase
BossDemonDying4to14Newspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									incbin "..\grapx\BossDemon\BossDemonDying5to14.dat"
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block	

TotallyWhiteSpritedatablock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
									ds	$4000,9+9*16
									DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block								

