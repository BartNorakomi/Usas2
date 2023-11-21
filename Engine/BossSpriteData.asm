BossGoatIdleAndWalkframelistblock:            equ BossSpritesDataStartBlock
phase	$8000
  include "..\grapx\BossGoat\IdleAndWalk\frames.lst" 
	ds		$c000-$,$ff

BossGoatIdleAndWalkspritedatablock:           equ BossGoatIdleAndWalkframelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\IdleAndWalk\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatWalkAndAttackframelistblock:            equ BossGoatIdleAndWalkspritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\WalkAndAttack\frames.lst" 
	ds		$c000-$,$ff

BossGoatWalkAndAttackspritedatablock:           equ BossGoatWalkAndAttackframelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\WalkAndAttack\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatAttackframelistblock:            equ BossGoatWalkAndAttackspritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\Attack\frames.lst" 
	ds		$c000-$,$ff

BossGoatAttackspritedatablock:           equ BossGoatAttackframelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\Attack\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatAttack2framelistblock:            equ BossGoatAttackspritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\Attack2\frames.lst" 
	ds		$c000-$,$ff

BossGoatAttack2spritedatablock:           equ BossGoatAttack2framelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\Attack2\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatAttackAndHitframelistblock:            equ BossGoatAttack2spritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\AttackAndHit\frames.lst" 
	ds		$c000-$,$ff

BossGoatAttackAndHitspritedatablock:           equ BossGoatAttackAndHitframelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\AttackAndHit\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatDyingframelistblock:            equ BossGoatAttackAndHitspritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\Dying\frames.lst" 
	ds		$c000-$,$ff

BossGoatDyingspritedatablock:           equ BossGoatDyingframelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\Dying\frames.dat"
	ds		$4000-$,$ff
dephase

BossGoatDying2framelistblock:            equ BossGoatDyingspritedatablock+1
phase	$8000
  include "..\grapx\BossGoat\Dying2\frames.lst" 
	ds		$c000-$,$ff

BossGoatDying2spritedatablock:           equ BossGoatDying2framelistblock+1
phase	$0000
  incbin "..\grapx\BossGoat\Dying2\frames.dat"
	ds		$4000-$,$ff
dephase

ryuframelistblock:            equ BossGoatDying2spritedatablock+1
phase	$8000
  include "..\grapx\ryu\spritesryuPage0\frames.lst" 
	ds		$c000-$,$ff
dephase

BossDemonframelistblock:            equ ryuframelistblock+1
phase	$8000
  include "..\grapx\ryu\spritesryuPage1\frames.lst" 
	ds		$c000-$,$ff
dephase

BossDemonframelistblock2:            equ BossDemonframelistblock+1
phase	$8000
  include "..\grapx\ryu\spritesryuPage2\frames.lst" 
	ds		$c000-$,$ff
dephase

BossDemonframelistblock3:            equ BossDemonframelistblock2+1
phase	$8000
  include "..\grapx\ryu\spritesryuPage3\frames.lst" 
	ds		$c000-$,$ff
dephase

BossDemonframelistblock4:            equ BossDemonframelistblock3+1
phase	$8000
  include "..\grapx\ryu\spritesryuPage4\frames.lst" 
	ds		$c000-$,$ff
dephase

ryuspritedatablock:           equ BossDemonframelistblock4+1
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage0\frames.dat"
	ds		$4000-$,$ff
dephase

BossDemonspritedatablock:           equ ryuspritedatablock+1
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage1\frames.dat"
	ds		$4000-$,$ff
dephase

BossDemonspritedatablock2:           equ BossDemonspritedatablock+1
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage2\frames.dat"
	ds		$4000-$,$ff
dephase

BossDemonspritedatablock3:           equ BossDemonspritedatablock2+1
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage3\frames.dat"
	ds		$4000-$,$ff
dephase
; block $ce
BossDemonspritedatablock4:           equ BossDemonspritedatablock3+1
phase	$0000
  incbin "..\grapx\ryu\spritesryuPage4\frames.dat"
	ds		$4000-$,$ff
dephase

BossRoomframelistblock:            equ BossDemonspritedatablock4+1
phase	$8000
  include "..\grapx\BossRoom\frames.lst" 
	ds		$c000-$,$ff

BossRoomspritedatablock:           equ BossRoomframelistblock+1
phase	$0000
  incbin "..\grapx\BossRoom\frames.dat"
	ds		$4000-$,$ff
dephase

AreaSignsframelistblock:            equ BossRoomspritedatablock+1
phase	$8000
  include "..\grapx\AreaSigns\frames.lst" 
	ds		$c000-$,$ff

AreaSignsspritedatablock:           equ AreaSignsframelistblock+1
phase	$0000
  incbin "..\grapx\AreaSigns\frames.dat"
	ds		$4000-$,$ff
dephase

BossVoodooWaspIdleframelistblock:            equ AreaSignsspritedatablock+1
phase	$8000
  include "..\grapx\BossVoodooWasp\Idle\frames.lst" 
	ds		$c000-$,$ff

BossVoodooWaspIdlespritedatablock:           equ BossVoodooWaspIdleframelistblock+1
phase	$0000
  incbin "..\grapx\BossVoodooWasp\Idle\frames.dat"
	ds		$4000-$,$ff
dephase

BossVoodooWaspHitframelistblock:            equ BossVoodooWaspIdlespritedatablock+1
phase	$8000
  include "..\grapx\BossVoodooWasp\Hit\frames.lst" 
	ds		$c000-$,$ff

BossVoodooWaspHitspritedatablock:           equ BossVoodooWaspHitframelistblock+1
phase	$0000
  incbin "..\grapx\BossVoodooWasp\Hit\frames.dat"
	ds		$4000-$,$ff
dephase

BossZombieCaterpillarIdleframelistblock:            equ BossVoodooWaspHitspritedatablock+1
phase	$8000
  include "..\grapx\BossZombieCaterpillar\Idle\frames.lst" 
	ds		$c000-$,$ff

BossZombieCaterpillarIdlespritedatablock:           equ BossZombieCaterpillarIdleframelistblock+1
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\Idle\frames.dat"
	ds		$4000-$,$ff
dephase

BossZombieCaterpillarAttackframelistblock:            equ BossZombieCaterpillarIdlespritedatablock+1
phase	$8000
  include "..\grapx\BossZombieCaterpillar\attack\frames.lst" 
	ds		$c000-$,$ff

BossZombieCaterpillarAttackspritedatablock:           equ BossZombieCaterpillarAttackframelistblock+1
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\attack\frames.dat"
	ds		$4000-$,$ff
dephase

BossZombieCaterpillarDyingPart1framelistblock:            equ BossZombieCaterpillarAttackspritedatablock+1
phase	$8000
  include "..\grapx\BossZombieCaterpillar\DyingPart1\frames.lst" 
	ds		$c000-$,$ff

BossZombieCaterpillarDyingPart1spritedatablock:           equ BossZombieCaterpillarDyingPart1framelistblock+1
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\DyingPart1\frames.dat"
	ds		$4000-$,$ff
dephase

BossZombieCaterpillarDyingPart2framelistblock:            equ BossZombieCaterpillarDyingPart1spritedatablock+1
phase	$8000
  include "..\grapx\BossZombieCaterpillar\DyingPart2\frames.lst" 
	ds		$c000-$,$ff

BossZombieCaterpillarDyingPart2spritedatablock:           equ BossZombieCaterpillarDyingPart2framelistblock+1
phase	$0000
  incbin "..\grapx\BossZombieCaterpillar\DyingPart2\frames.dat"
	ds		$4000-$,$ff
dephase

