;
; Re-Play player for sound effects
;
RePlayerSFX_CHANNEL_COUNT: equ 1

RePlayerSFX_Initialize:
	ld de,4
	ld ix,RePlayerSFX_channels
	ld b,RePlayerSFX_CHANNEL_COUNT
RePlayerSFX_Initialize_Loop:
	ld (ix + 0),SFX_nop and 0FFH
	ld (ix + 1),SFX_nop >> 8
	ld (ix + 2),usas2sfxrepBlock
	ld (ix + 3),1
	add ix,de
	djnz RePlayerSFX_Initialize_Loop
	ret

; bc = sfx
RePlayerSFX_Play:
	ld ix,RePlayerSFX_channels
	di
	ld (ix + 0),c
	ld (ix + 1),b
	ld (ix + 2),usas2sfxrepBlock
	ei
	ld (ix + 3),1
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
SFX_land: equ 8001H + 4 * 1
SFX_jump: equ 8001H + 4 * 2
SFX_test3: equ 8001H + 4 * 3
SFX_test4: equ 8001H + 4 * 4
SFX_test5: equ 8001H + 4 * 5
SFX_test6: equ 8001H + 4 * 6
SFX_test7: equ 8001H + 4 * 7
SFX_test8: equ 8001H + 4 * 8
SFX_test9: equ 8001H + 4 * 9
SFX_test10: equ 8001H + 4 * 10
SFX_test11: equ 8001H + 4 * 11
SFX_test12: equ 8001H + 4 * 12
SFX_test13: equ 8001H + 4 * 13
SFX_test14: equ 8001H + 4 * 14
SFX_test15: equ 8001H + 4 * 15
SFX_test16: equ 8001H + 4 * 16
SFX_test17: equ 8001H + 4 * 17
SFX_test18: equ 8001H + 4 * 18
