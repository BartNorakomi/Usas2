;
; MoonSound - Yamaha YMF278B OPL4
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
	jr c,MoonSound_WaitLoad
	jr z,MoonSound_WriteMemory
;	cp 0C2H << 1
	cp ($c2 << 1) and ($ff)
	jr z,MoonSound_Jump
;	sub 0C4H << 1
	sub ($c4 << 1) and ($ff)
	jr c,MoonSound_Call
	jr z,MoonSound_Return
	rrca
	ret
MoonSound_Process_FM:
	jp p,MoonSound_WriteFM1
	jp MoonSound_WriteFM2

; hl = sound data
MoonSound_Jump:
	call Player_Jump
	jp MoonSound_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSound_Call:
	call Player_Call
	jp MoonSound_Process_Loop

; hl = sound data
; ix = stack pointer
MoonSound_Return:
	call Player_Return
	jp MoonSound_Process_Loop

; a = count * 2 - 2
; hl = sound data
MoonSound_WriteFM1:
	add a,02H
	ld b,a
	ld c,MoonSound_FM1_DATA
MoonSound_WriteFM1_Loop:
	dec c
	outi
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	inc c
	outi
	jp nz,MoonSound_WriteFM1_Loop
	jp MoonSound_Process_Loop

; a = 80H + count * 2 - 2
; hl = sound data
MoonSound_WriteFM2:
	add a,82H
	ld b,a
	ld c,MoonSound_FM2_DATA
MoonSound_WriteFM2_Loop:
	dec c
	outi
	nop  ; extra wait for R800 -- wait 1.7 탎 (12 cycles)
	inc c
	outi
	jp nz,MoonSound_WriteFM2_Loop
	jp MoonSound_Process_Loop

; a = count * 2 - 2
; hl = sound data
MoonSound_WriteWave:
	add a,02H
	ld b,a
	ld c,MoonSound_WAVE_DATA
MoonSound_WriteWave_Loop:
	dec c
	outi
	jp $ + 3  ; extra wait for R800 -- wait 2.6 탎 (19 cycles, but 18 works)
	inc c
	outi
	jp nz,MoonSound_WriteWave_Loop
	jp MoonSound_Process_Loop

; hl = sound data
MoonSound_WaitLoad:
	in a,(MoonSound_STATUS)
	and 00000010B
	jr nz,MoonSound_WaitLoad
	jp MoonSound_Process_Loop

; hl = sound data
MoonSound_WriteMemory:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	call MoonSound_WriteWaveMemory
	jp MoonSound_Process_Loop

MoonSound_Mute:
	ld b,9
	ld a,0BDH
	call MoonSound_ReadFM1Register
	and 11100000B
	ld e,a
	ld d,0BDH
	call MoonSound_WriteFM1Register
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
; ade = destination address
; hl = source address
MoonSound_WriteWaveMemory:
	push af
	push de
	ld de,0211H
	call MoonSound_WriteWaveRegister  ; set standard memory layout
	pop de
	pop af
	push de
	ld e,a
	ld d,03H
	call MoonSound_WriteWaveRegister
	pop de
	push de
	ld e,d
	ld d,04H
	call MoonSound_WriteWaveRegister
	pop de
	ld d,05H
	call MoonSound_WriteWaveRegister
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
	ld de,0210H
	jp MoonSound_WriteWaveRegister  ; set standard memory layout