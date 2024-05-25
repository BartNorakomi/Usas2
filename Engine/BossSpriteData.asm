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

;20250525;ro;What is this?
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
							include "..\grapx\AreaSigns\frames.lst" 
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
AreaSignsspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\AreaSigns\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block

;Teleporter
Teleportframelistblock:		equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							phase	$8000
							include "..\grapx\TeleportRoom\frames.lst"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block
							dephase
Teleportspritedatablock:	equ ($-RomStartAddress) and (romsize-1) /RomBlockSize
							incbin "..\grapx\TeleportRoom\frames.dat"
							DS RomBlockSize- $ and (RomBlockSize-1),-1	;fill remainder of block


