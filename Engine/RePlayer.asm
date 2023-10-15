;
; Re-Play player
;
	INCLUDE "MoonSound.asm"

RePlayer_STACK_CAPACITY: equ 128
FormatOPL4_ID: equ 1

; a = format ID (first byte of sound data)
; f <- c: found
RePlayer_Detect:
	call RePlayer_Detect_Format
	jp c,RePlayer_SetJumpTable
	jp RePlayer_ClearJumpTable

; a = format ID (first byte of sound data)
; f <- c: found
RePlayer_Detect_Format:
;	cp FormatOPN_ID
;	jp z,FormatOPN_Detect
	cp FormatOPL4_ID
	jp z,FormatOPL4_Detect
;	cp FormatOPLLPSG_ID
;	jp z,FormatOPLLPSG_Detect
	and a
	ret

FormatOPL4_Detect:
	call MoonSound_Detect
	ld hl,MoonSound_JumpTable
	ret

; f <- c: found
; hl = jump table
RePlayer_SetJumpTable:
	ld de,RePlayer_Process
	ld bc,3 * 3
	ldir
	ret

; f <- c: found
RePlayer_ClearJumpTable:
	ld hl,RePlayer_Process
	ld de,RePlayer_Process + 1
	ld bc,3 * 3 - 1
	ld (hl),0C9H  ; ret
	ldir
	ret

; bc = track number
; ahl = sound data (after format ID, so +1)
RePlayer_Play:
	add hl,bc
	add hl,bc
	add hl,bc
	add hl,bc
	ld b,a
	xor a
	ld (RePlayer_playing),a
	ld a,b
	ld ix,RePlayer_stack
;	RePlayer_Push_M
	ld (ix + 0),l
	ld (ix + 1),h
	ld (ix + 2),a
	inc ix
	inc ix
	inc ix
	ld a,1
	ld (ix),a
	ld (RePlayer_stackPointer),ix
	ld (RePlayer_playing),a
	ret

RePlayer_Stop:
	xor a
	ld (RePlayer_playing),a
	call RePlayer_Mute
	ret

RePlayer_Resume:
	call RePlayer_Restore
	ld a,1
	ld (RePlayer_playing),a
	ret

;RePlayer_TogglePause:
;	ld a,(RePlayer_playing)
;	and a
;	jr z,RePlayer_Resume
;	jr RePlayer_Stop

RePlayer_Tick:
  ld    a,(slot.page12rom)             ;all RAM except page 1+2
  out   ($a8),a
  
	ld a,(RePlayer_playing)
	and a
	ret z
	ld ix,(RePlayer_stackPointer)
	dec (ix)
	ret nz
	ld a,(RePlayer_currentBank)
	push af
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
	call RePlayer_Process
	ld b,a
	ld a,(RePlayer_currentBank)
;	RePlayer_Push_M
	ld (ix + 0),l
	ld (ix + 1),h
	ld (ix + 2),a
	inc ix
	inc ix
	inc ix
	ld (ix),b
	ld (RePlayer_stackPointer),ix
	pop af
	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
	ld (7000H),a
	ret

; hl = sound data
;RePlayer_Jump_M: MACRO
;	ld e,(hl)
;	inc hl
;	ld d,(hl)
;	inc hl
;	ld a,(RePlayer_currentBank)
;	add a,(hl)
;	inc hl
;	add hl,de
;	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
;	ENDM

; hl = sound data
; ix = stack pointer
;RePlayer_Call_M: MACRO
;	ld e,(hl)
;	inc hl
;	ld d,(hl)
;	inc hl
;	ld b,(hl)
;	inc hl
;	ld a,(RePlayer_currentBank)
;	RePlayer_Push_M
;	add hl,de
;	add a,b
;	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
;	ENDM

; hl = sound data
; ix = stack pointer
;RePlayer_Return_M: MACRO
;	RePlayer_Pop_M
;	ld (RePlayer_currentBank),a
;	RePlayer_SetBank_M
;	ENDM

; hl = value
; ix = stack pointer
; ix <- stack pointer
;RePlayer_Push_M: MACRO
;	ld (ix + 0),l
;	ld (ix + 1),h
;	ld (ix + 2),a
;	inc ix
;	inc ix
;	inc ix
;	ENDM

; ix = stack pointer
; hl <- value
; ix <- stack pointer
;RePlayer_Pop_M: MACRO
;	dec ix
;	dec ix
;	dec ix
;	ld l,(ix + 0)
;	ld h,(ix + 1)
;	ld a,(ix + 2)
;	ENDM

RePlayer_playing:
	db 0
RePlayer_currentBank: equ memblocks.2
	; db 0
RePlayer_stackPointer:
	dw RePlayer_stack
RePlayer_stack:
	ds RePlayer_STACK_CAPACITY * 3 + 1
RePlayer_Process:
	db 0C9H, 0, 0
RePlayer_Mute:
	db 0C9H, 0, 0
RePlayer_Restore:
	db 0C9H, 0, 0
