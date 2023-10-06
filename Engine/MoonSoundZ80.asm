;
; MoonSound - Yamaha YMF278B OPL4
;
; Z80 optimised version, up to 8.85 MHz.
;

; f <- c: found
;MoonSoundZ80_Detect:
;	call Utils_IsR800
;	ccf
;	ret nc
;	jp MoonSound_Detect

MoonSoundZ80_JumpTable:
	jp MoonSoundZ80_Process
	jp MoonSound_Mute
	jp MoonSound_Restore

; hl = sound data
; ix = stack pointer
; a <- wait amount
MoonSoundZ80_Process:
MoonSoundZ80_Process_Loop:
	ld a,(hl)
	inc hl
	add a,a
	jr nc,MoonSoundZ80_Process_FM
	jp p,MoonSoundZ80_WriteWave
;	cp 0C1H << 1
	cp ($c1 << 1) and ($ff)
	jr c,MoonSoundZ80_WaitLoad
	jr z,MoonSoundZ80_WriteMemory
;	cp 0C2H << 1
	cp ($c2 << 1) and ($ff)
	jr z,MoonSoundZ80_Jump
;	sub 0C4H << 1
	sub ($c4 << 1) and ($ff)
	jr c,MoonSoundZ80_Call
	jr z,MoonSoundZ80_Return
	rrca
	ret
MoonSoundZ80_Process_FM:
	jp p,MoonSoundZ80_WriteFM1
	jp MoonSoundZ80_WriteFM2

; hl = sound data
MoonSoundZ80_Jump:
	call Player_Jump
	jp MoonSoundZ80_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSoundZ80_Call:
	call Player_Call
	jp MoonSoundZ80_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSoundZ80_Return:
	call Player_Return
	jp MoonSoundZ80_Process_Loop

; a = count * 2 - 2
; hl = sound data
MoonSoundZ80_WriteFM1:
	xor 80H - 2
	ld c,MoonSound_FM1_DATA
	jp MoonSoundZ80_WriteBlock

; a = 80H + count * 2 - 2
; hl = sound data
MoonSoundZ80_WriteFM2:
	xor 100H - 2
	ld c,MoonSound_FM2_DATA
	jp MoonSoundZ80_WriteBlock

; a = count * 2 - 2
; hl = sound data
MoonSoundZ80_WriteWave:
	xor 80H - 2
	ld c,MoonSound_WAVE_DATA
	jp MoonSoundZ80_WriteBlock

; hl = sound data
MoonSoundZ80_WaitLoad:
	in a,(MoonSound_STATUS)
	and 00000010B
	jr nz,MoonSoundZ80_WaitLoad
	jp MoonSoundZ80_Process_Loop

; hl = sound data
MoonSoundZ80_WriteMemory:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	call MoonSound_WriteWaveMemory
	jp MoonSoundZ80_Process_Loop

; a = (40H - count) * 2
; c = data port
; hl = sound data
MoonSoundZ80_WriteBlock:
	ld e,a
	ld d,0
	ld iy,MoonSoundZ80_WriteBlock_Unrolled
	add iy,de
	sla e
	add iy,de
	jp (iy)
MoonSoundZ80_WriteBlock_Unrolled:
;	REPT 40H
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi

	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi

	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi

	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
	dec c |	outi | inc c | outi
;	ENDM
	jp MoonSoundZ80_Process_Loop