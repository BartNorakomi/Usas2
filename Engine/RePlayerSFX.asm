;
; Re-Play player for sound effects
;
RePlayerSFX_CHANNEL_COUNT: equ 2

RePlayerSFX_Initialize:
	ld de,4
	ld ix,RePlayerSFX_channels
	ld b,RePlayerSFX_CHANNEL_COUNT
RePlayerSFX_Initialize_Loop:
	ld (ix + 0),SFX_nop and 0FFH
	ld (ix + 1),SFX_nop >> 8
	ld (ix + 2),usas2sfx1repBlock
	ld (ix + 3),1
	add ix,de
	djnz RePlayerSFX_Initialize_Loop
	ret

; Play sound effect on stream channel 1.
; Recommended for sounds originating from player.
; For example: player attacks, player impacts, jump, land.
; bc = sfx
RePlayerSFX_PlayCh1:
	ld iy,RePlayerSFX_channels
	di
	ld (iy + 0),c
	ld (iy + 1),b
	ld (iy + 2),usas2sfx1repBlock
	ei
	ld (iy + 3),1
	ret

; Play sound effect on stream channel 2.
; Recommended for sounds not originating from player.
; For example: enemy attacks, enemy impacts, coins.
; bc = sfx
RePlayerSFX_PlayCh2:
	ld iy,RePlayerSFX_channels + 4
	di
	ld (iy + 0),c
	ld (iy + 1),b
	ld (iy + 2),usas2sfx2repBlock
	ei
	ld (iy + 3),1
	ret

RePlayerSFX_Tick:
	ld a,(RePlayer_currentBank)
	push af
	ld ix,RePlayerSFX_channels
	ld b,RePlayerSFX_CHANNEL_COUNT
RePlayerSFX_Tick_Loop:
	dec (ix + 3)
	jr nz,RePlayerSFX_Tick_Next
	push bc
	ld l,(ix + 0)
	ld h,(ix + 1)
	ld a,(ix + 2)
	ld (RePlayer_currentBank),a
;	RePlayerSFX_SetBank_M
	ld (7000H),a
	call RePlayer_Process
	ld (ix + 3),a
	ld a,(RePlayer_currentBank)
	ld (ix + 0),l
	ld (ix + 1),h
	ld (ix + 2),a
	pop bc
RePlayerSFX_Tick_Next:
	inc ix
	inc ix
	inc ix
	inc ix
	djnz RePlayerSFX_Tick_Loop
	pop af
	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
	ld (7000H),a
	ret

RePlayerSFX_channels:
	ds RePlayerSFX_CHANNEL_COUNT * 4

; Sound effects list (base address + 4 * track nr)
SFX_nop: equ 8001H + 4 * 0
SFX_click: equ 8001H + 4 * 1
SFX_jump: equ 8001H + 4 * 2
SFX_land: equ 8001H + 4 * 3
SFX_coin: equ 8001H + 4 * 4
SFX_meditate: equ 8001H + 4 * 4
SFX_dash: equ 8001H + 4 * 5
SFX_punch: equ 8001H + 4 * 6
SFX_bouncingback: equ 8001H + 4 * 7
SFX_beinghit: equ 8001H + 4 * 8
SFX_test9: equ 8001H + 4 * 9
SFX_shoot1: equ 8001H + 4 * 10
SFX_shoot2: equ 8001H + 4 * 11
SFX_enemyhit: equ 8001H + 4 * 11
SFX_shoot3: equ 8001H + 4 * 12
SFX_enemyexplosionsmall: equ 8001H + 4 * 12
SFX_shoot4: equ 8001H + 4 * 13
SFX_enemyexplosionbig: equ 8001H + 4 * 13
SFX_bossdemonshoot: equ 8001H + 4 * 13
SFX_arrow: equ 8001H + 4 * 14
SFX_roll: equ 8001H + 4 * 15
SFX_test16: equ 8001H + 4 * 16
SFX_bossdemoncleaveattack: equ 8001H + 4 * 16
SFX_test17: equ 8001H + 4 * 17
SFX_bossdemonbeinghit: equ 8001H + 4 * 17
SFX_test18: equ 8001H + 4 * 18
SFX_bossdemondead: equ 8001H + 4 * 18
