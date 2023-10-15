;
; MoonSound - Yamaha YMF278B OPL4
;
; Z80 optimised version, up to 8.85 MHz.
;
MoonSound_FM_BASE: equ 0C4H
MoonSound_STATUS: equ MoonSound_FM_BASE
MoonSound_FM1_ADDRESS: equ MoonSound_FM_BASE
MoonSound_FM1_DATA: equ MoonSound_FM_BASE + 1
MoonSound_FM2_ADDRESS: equ MoonSound_FM_BASE + 2
MoonSound_FM2_DATA: equ MoonSound_FM_BASE + 3
MoonSound_WAVE_BASE: equ 07EH
MoonSound_WAVE_ADDRESS: equ MoonSound_WAVE_BASE
MoonSound_WAVE_DATA: equ MoonSound_WAVE_BASE + 1

; f <- c: found
MoonSound_Detect:
	call MoonSound_ReadStatusRegister  ; skip potential 02H read
	call MoonSound_ReadStatusRegister
	and a
	ret nz
	ld de,0503H
	call MoonSound_WriteFM2Register  ; enable FM2, WAVE
	ld a,02H
	call MoonSound_ReadWaveRegister  ; check ID
	and 11100000B
	xor 00100000B
	ret nz
	ld de,0210H
	call MoonSound_WriteWaveRegister  ; set standard memory layout
	scf
	ret

MoonSound_JumpTable:
	jp MoonSound_Process
	jp MoonSound_Mute
	jp MoonSound_Restore

; hl = sound data
; ix = stack pointer
; a <- wait amount
MoonSound_Process:
MoonSound_Process_Loop:
	ld a,(hl)
	inc hl
	add a,a
	jr nc,MoonSound_Process_FM
	jp p,MoonSound_WriteWave
;	cp 0C1H << 1
	cp ($c1 << 1) and ($ff)
	jp c,MoonSound_Call
	jp z,MoonSound_Return
;	cp 0C3H << 1
	cp ($c3 << 1) and ($ff)
	jp c,MoonSound_Jump
	jp z,MoonSound_WaitLoad
;	sub 0C4H << 1
	sub ($c4 << 1) and ($ff)
	jr z,MoonSound_WriteMemory
	rrca
	ret
MoonSound_Process_FM:
	jp p,MoonSound_WriteFM1
	jp MoonSound_WriteFM2

; a = count * 2 - 2
; hl = sound data
MoonSound_WriteFM1:
	xor 80H - 2
	ld c,MoonSound_FM1_DATA
	jp MoonSound_WriteBlock

; a = 80H + count * 2 - 2
; hl = sound data
MoonSound_WriteFM2:
	xor 100H - 2
	ld c,MoonSound_FM2_DATA
	jp MoonSound_WriteBlock

; a = count * 2 - 2
; hl = sound data
MoonSound_WriteWave:
	xor 80H - 2
	ld c,MoonSound_WAVE_DATA
	jp MoonSound_WriteBlock

; hl = sound data
MoonSound_WaitLoad:
	in a,(MoonSound_STATUS)
	and 00000010B
	jr nz,MoonSound_WaitLoad
	jp MoonSound_Process_Loop

; hl = sound data
MoonSound_WriteMemory:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	call MoonSound_WriteWaveMemory
	jp MoonSound_Process_Loop

; a = (40H - count) * 2
; c = data port
; hl = sound data
MoonSound_WriteBlock:
	ld e,a
	ld d,0
	ld iy,MoonSound_WriteBlock_Unrolled
	add iy,de
	sla e
	add iy,de
	jp (iy)
MoonSound_WriteBlock_Unrolled:
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
	jp MoonSound_Process_Loop

; hl = sound data
MoonSound_Jump:
;	RePlayer_Jump_M
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(RePlayer_currentBank)
	add a,(hl)
	inc hl
	add hl,de
	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
	ld (7000H),a
	jp MoonSound_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSound_Call:
;	RePlayer_Call_M
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld a,(RePlayer_currentBank)
;	RePlayer_Push_M
	ld (ix + 0),l
	ld (ix + 1),h
	ld (ix + 2),a
	inc ix
	inc ix
	inc ix
	add hl,de
	add a,b
	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
	ld (7000H),a
	jp MoonSound_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSound_Return:
;	RePlayer_Return_M
;	RePlayer_Pop_M
	dec ix
	dec ix
	dec ix
	ld l,(ix + 0)
	ld h,(ix + 1)
	ld a,(ix + 2)
	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
	ld (7000H),a
	jp MoonSound_Process_Loop

MoonSound_Mute:
	ld a,0BDH
	call MoonSound_ReadFM1Register
	and 11100000B
	ld e,a
	ld d,0BDH
	call MoonSound_WriteFM1Register
	ld b,9
MoonSound_MuteFM1_Loop:
	ld a,0B9H
	sub b
	ld d,a
	call MoonSound_ReadFM1Register
	and 11011111B
	ld e,a
	call MoonSound_WriteFM1Register
	djnz MoonSound_MuteFM1_Loop
	ld b,9
MoonSound_MuteFM2_Loop:
	ld a,0B9H
	sub b
	ld d,a
	call MoonSound_ReadFM2Register
	and 11011111B
	ld e,a
	call MoonSound_WriteFM2Register
	djnz MoonSound_MuteFM2_Loop
	ld b,24
MoonSound_MuteWave_Loop:
	ld a,80H
	sub b
	ld d,a
	call MoonSound_ReadWaveRegister
	and 00111111B
	or 01000000B
	ld e,a
	call MoonSound_WriteWaveRegister
	djnz MoonSound_MuteWave_Loop
	ret

MoonSound_Restore:
	ret

; d = register
; e = value
MoonSound_WriteFM1Register:
	ld a,d
	out (MoonSound_FM1_ADDRESS),a
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	ld a,e
	out (MoonSound_FM1_DATA),a
	ret

; a = register
; a = value
MoonSound_ReadFM1Register:
	out (MoonSound_FM1_ADDRESS),a
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	nop
	in a,(MoonSound_FM1_DATA)
	ret

; d = register
; e = value
MoonSound_WriteFM2Register:
	ld a,d
	out (MoonSound_FM2_ADDRESS),a
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	ld a,e
	out (MoonSound_FM2_DATA),a
	ret

; a = register
; a = value
MoonSound_ReadFM2Register:
	out (MoonSound_FM2_ADDRESS),a
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	nop
	in a,(MoonSound_FM2_DATA)
	ret

; d = register
; e = value
MoonSound_WriteWaveRegister:
	ld a,d
	out (MoonSound_WAVE_ADDRESS),a
	cp (ix)  ; extra wait for R800 -- wait 2.6 탎 (19 cycles, but 18 works)
	ld a,e
	out (MoonSound_WAVE_DATA),a
	ret

; a = register
; a = value
MoonSound_ReadWaveRegister:
	out (MoonSound_WAVE_ADDRESS),a
	cp (ix)  ; extra wait for R800 -- wait 2.6 탎 (19 cycles, but 18 works)
	nop
	in a,(MoonSound_WAVE_DATA)
	ret

; a = value
MoonSound_ReadStatusRegister:
	in a,(MoonSound_STATUS)
	ret

; bc = byte count
; hl = source address
MoonSound_WriteWaveMemory:
	ld a,06H
	out (MoonSound_WAVE_ADDRESS),a
	dec bc
	inc b
	inc c
	ld a,b
	ld b,c
	ld c,MoonSound_WAVE_DATA
MoonSound_WriteMemory_Loop:
	otir
	dec a
	jr nz,MoonSound_WriteMemory_Loop
	ret
