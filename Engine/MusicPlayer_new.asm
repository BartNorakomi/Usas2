; DOS2.XX Moonsound Wave Driver
; Start Date: 25-09-1998

;--- Defines ---
R800ASM:		equ	0	; assembly for R800 on/off
Z80HASM:		equ	0	; assembly for 7Mhz on/off
SPTEST:		equ	0	; speed test on/off
FADE:		equ	0	; include code for fade
RAMHEADERS:	equ	0	; don't change ROM headers

				; When this is switched OFF the
				; replayer will be faster, but only do
				; this when you really need the speed!
				; It will affect the sound quality.

play_busy:		db	0	; status:   0 = not playing ; #ff =playing
songdata_adres:		dw	08012h	; address of song data (+18 bytes for XLFO data)
play_pos:		db	0	; current position
play_step:		db	0	; current step
status:			dw	0	; status bytes (0 = off)
step_buffer:		ds	25,0	; decrunched step, played next int
load_buffer:		ds	3,0
