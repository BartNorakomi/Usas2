;0000 - 0003 [MBMS]
;0006 - 00E1 [pattern @ pos 0..219]
;00E4 - 00FB [panning]
;             -7  -6  -5  -4  -3  -2  -1  00  +1  +2  +3  +4  +5  +6  +7
;             F9  FA  FB  FC  FD  FE  FF  00  01  02  03  04  05  06  07
;00FE - 0115 [detune]
;             -3  -2  -1  00  +1  +2  +3
;             FA  FC  FE  00  02  04  06
;0146 - 015D [start waves]
;015E - 018D [selected waves]
;018E - 01BD [selected waves VLM/L-D-column]
;			(V00) 3F 3D 3B 39 37 35 33 31   2F 2D 2B 29 27 25 23 21   1F 1D 1B 19 17 15 13 11   0F 0D 0B 09 07 05 03 01  (V31)  L-D on
;			(V00) 3E 3C 3A 38 36 34 32 30   2E 2C 2A 28 26 24 22 20   1E 1C 1A 18 16 14 12 10   0E 0C 0A 08 06 04 02 00  (V31)  L-D off
;01BE - 01EF [songname]
;01F0 - 01F7 [wavekit name]
;01F8 - 7EF7 [patterndata, 80x 25*16, horizontal read-out, then the next row]
;7EF8 - 7EFB [XLFO]
;7EFC - 7EFD [9x 2 bytes] [xxAAABBB 00000CCC]
;		
;' ---------------------------------------
;'  pattern data
;' ---------------------------------------
;00     empty cell
;01..60 c-1..b-8
;92..B1 v0..v31
;C1..D3 L-9..L+9
;D4..E6 P-9..P+9
;F2     DMP
;61     OFF
;62..8F W01..W48
;B2..C0 S-7..S+7
;E7..ED T-3..T+3
;EE..F0 M 1..M 3
;F1     REV
;F3     LFO
;F4     REF
;' ---- cmd ----
;01..16 TMP 1..TMP22
;2B..3D TR- 9..TR+ 9
;19..1B STAT1..STAT3
;4E..D2 B   1..B 133


;--------------------
;--- Start music ---
;--------------------
; In : -
; Out: -
; Mod: all
start_music:
;di
	ld	a,(play_busy)
	or	a
	ret	nz	; already playing?

	ld	hl,0
	ld	(status),hl
	ld	(status+1),hl	; clear status bytes

	ld	a,0ffh
	ld	(play_busy),a	; set busy playing
	xor	a
	ld	(play_hzeql),a	; reset hz equalizer counter

	ld	a,15
	ld	(play_step),a   ; reset step (16 steps per positions/patterns)
	ld	a,255
	ld	(play_pos),a	  ; reset pattern/position

;	call	curbank_FE  ;; Get current segment/bank on 08000h-0BFFFh  ; Out: A = seg/banknr
;	push	af
;	ld	a,(songdata_bank1)
;	call	selbank_FE

;So this tells us that the first 220 bytes of a song is songdata information
	ld	hl,(songdata_adres)   ;$8000
	ld	de,xleng              ;Start of songdata table
	ld	bc,220                ;lenght of that whole table  that starts at xleng
	ldir		                  ; copy song settings
;xleng:	        ds	1	    ; Song length (expressed in patterns I guess)
;xloop:	        ds	1	    ; Loop position
;xwvstpr:	      ds	24	  ; Stereo settings Wave
;xtempo:	      ds	1	    ; Tempo
;xhzequal:	    ds	1	    ; 50/60 Hz Equalizer
;xdetune:	      ds	24	  ; Detune settings
;xmodtab:	      ds	3*16	; Modulation tables
;xbegwav:	      ds	24	  ; Start waves
;xwavnrs:	      ds	48	  ; Wave numbers
;xwavvols:	    ds	48	  ; Wave volumes	

;So this tells us that the next 58 bytes holds the name of the wavekit
	ld	de,58
	add	hl,de	; skip name/wavekit
	ld	(pos_address),hl    ; this is the start of the song I guess. Set this position.
	ld	a,(xleng)
	inc	a
	ld	e,a
	add	hl,de
	ld	(pat_address),hl    ; address of current pattern maybe ?
;	pop	af
;	call	selbank_FE






	        ld      hl,(songdata_adres)
	        ld      de,6
	        add     hl,de
	        ld      (songdata_adres),hl
	        ld      de,xleng
	        ld      bc,220
	        ldir            ; copy song settings
	        ld      de,58
start_music1:   add     hl,de   ; skip name/wavekit
	        ld      (pos_address),hl
	        ld      a,(xleng)
	        inc     a
	        ld      e,a
	        ld	d,0
	        add     hl,de
	        ld      (pat_address),hl



















	call	init_opl4	        ; initialise OPL4
	call	init_voices	      ; set start voices
	ld	a,(xtempo)
	ld	(play_speed),a	    ; set tempo
	sub	3
	ld	(play_timercnt),a   ; initialise timer (tempo)
	xor	a
	ld	(play_tspval),a	    ; transpose off
	IF	FADE
	ld	(play_fading),a
	ld	(play_fadecnt),a
	ld	(play_fadetcnt),a
	ENDIF

;  start_mus_cnt:	di
;	ld	hl,0fd9fh
;	ld	de,old_int
;	ld	bc,5
;	ldir		; save interrupt hook

;	ld	a,(0f342h)
;	ld	(play_int_han+1),a
;	ld	hl,play_int_han
;	ld	de,0fd9fh
;	ld	bc,5
;	ldir		; set music interrupt hook
;	ei
	ret

;----------------
;--- OPL4 out ---
;----------------

opl4_out_bnk1:	ex	af,af'
	ld	a,c
;	opl4_wait	; wait if Turbo-R
	out	(FMIO + 2),a
	ex	af,af'
;	opl4_wait	; wait if Turbo-R
	out	(FMIO + 1),a
	ret

opl4_out_wave:	ex	af,af'
	ld	a,c
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ex	af,af'
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a
	ret

;opl4_in_wave:	opl4_wait	; wait if Turbo-R
;	ld	a,c
;	out	(WVIO),a
;	nop
;	opl4_wait	; wait if Turbo-R
;	in	a,(WVIO+1)
;	ret

;----------------------------
;--- Set Start Voices ---
;----------------------------

init_voices:	ld	b,WAVCHNS	; amount of wave channels (24)
	ld	iy,play_table_wav     ;channel play table info (20 bytes per channel)
	ld	ix,xbegwav            ;Start waves
	ld	de,PTW_SIZE           ; size of Wave playtable line (=20)
init_wavesl:	push	de
	push	bc
	ld	a,(ix - 72)	; xdetune!
	add	a,a
	ld	(iy + 5),a	; detune!

	ld	a,(ix + 0)	; wave/patchnr
	push	af
	call	play_wwavevt2
	pop	af
	ld	hl,xwavvols - 1

;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla1
	inc	h
addhla1:	ld	l,a
;	endm


	ld	a,(hl)	; volume
	ld	(iy + 15),a
	call	play_wchgvol2
	ld	a,(ix - 98)      ; stereo preset
	call	play_wchgste2
	inc	ix
	pop	bc
	pop	de
	add	iy,de
	djnz	init_wavesl
	ret

;--- Play stereo event ---

play_wchgste:	sub	178 + 7
play_wchgste2:	and	1111b
	ld	d,a
	ld	a,(iy+11)
	and	11110000b
	or	d
	ld	(iy+11),a
	ld	a,68h - 1
	add	a,b
	out	(WVIO),a
	ld	(iy + 2),0
;	opl4_wait	; wait if Turbo-R
	in	a,(WVIO + 1)
	and	11110000b
	or	d
;	opl4_wait	; wait if Turbo-R
	out	(WVIO + 1),a
	ret

;--- Play volume event ---
play_wchgvol:	sub	146
	xor	31
	add	a,a
play_wchgvol2:	add	a,a	; * 4, OPL4 can handle 0-127
	add	a,a
	ld	c,a

	IF	FADE
	ld	a,(play_fading)
	or	a
	jr	z,play_wchgvolfd
	ld	a,c
	or	1
	cp	(iy + 15)
	ret	c
	ENDIF
  play_wchgvolfd:
	ld	a,050h - 1
	add	a,b
	out	(WVIO),a
	ld	a,(iy + 15)	; level direct
	and	1
	or	c
	ld	(iy + 15),a
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a
	ret

;--- Play Wave event ---
play_wwavevt:	sub	98 - 1
play_wwavevt2:	ld	(iy + 2),0	; pb off
	ld	c,a
	ld	hl,xwavnrs - 1

;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla2
	inc	h
addhla2:	ld	l,a
;	endm

	ld	a,(hl)
	ld	(iy + 10),a
	ld	a,c
	ld	hl,xwavvols - 1

;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla3
	inc	h
addhla3:	ld	l,a
;	endm

	ld	a,(iy + 15)
	and	1
	ld	d,a
	IF	FADE
	ld	a,(play_fading)
	or	a
	jr	nz,play_wavevtfd
	ENDIF
	ld	a,(hl)
	add	a,a
	add	a,a
	or	d
	ld	(iy + 15),a
	ret

play_wavevtfd:	ld	a,(hl)
	add	a,a
	add	a,a
	or	d
	cp	(iy + 15)
	ret	c
	ld	(iy + 15),a
	ret

;--- initialise OPL4 registers ---

init_opl4:	ld	a,3
	ld	c,5
	call	opl4_out_bnk1	; Set the OPL4 in OPL4 mode

	ld	c,2
	ld	a,10000b
	jp	opl4_out_wave	; init Wave ROM stuff

;--------------------
;--- Stop music  ----
;--------------------
; In : -
; Out: -
; Mod: all

stop_music:	jr	halt_music
;------------------
;--- Halt music ---
;------------------

halt_music:	ld	a,(play_busy)	; already stopped?
	or	a
	ret	z
;	di
	xor	a
	ld	(play_busy),a

	ld	b,WAVCHNS	                      ;amount of wave channels in use (max =24)
	ld	iy,play_table_wav               ;channel play table info (20 bytes per channel)
	ld	de,PTW_SIZE                     ;lenght playtable per channel (20)
halt_musicl3:	call	play_woffevt      ;play an OFF event for all channels
	call	play_chgdmp                   ;damp all channels
	add	iy,de
	djnz	halt_musicl3
;	ei
	ret















;-------------------------------
;--- Music interrupt routine ---
;-------------------------------

play_int:	;di
;	ld	a,(xhzequal)	; 60 Hz equalizer
;	or	a
;	jr	z,play_int3
;	ld	a,(0ffe8h)
;	and	10b
;	jr	nz,play_int3
;	ld	hl,play_hzeql
;	ld	a,(hl)
;	inc	a
;	cp	6
;	jr	c,play_int4
;	ld	(hl),0
;	jp	play_int_end

;  play_int4:	ld	(hl),a
;  play_int3:

	IF	SPTEST
	IF	R800ASM
	ld	bc,5000
	ELSE
	ld	bc,550
	ENDIF
  play__bla:	dec	bc
	ld	a,b
	or	c
	jr	nz,play__bla

	ld	a,255	; white
	out	(099h),a
	ld	a,7+128
	out	(099h),a
	ENDIF

	call	play_pitch	; pitch-bend/modulation handler

	IF	FADE
	ld	a,(play_fading)
	or	a
	jr	z,play_int5
	call	play_fade	; fading
	ld	a,(play_fading)
	or	a
	jp	z,play_int_end
  play_int5:
	ENDIF

;	call	curbank_FE
;	push	af

	ld	a,(play_speed)	; speed
	ld	hl,play_timercnt
	inc	(hl)
	cp	(hl)
	jp	nz,play_int_sec	; almost there?
	ld	(hl),0

;	ld	a,(songdata_bank)
;	call	selbank_FE

	call	play_wtones	; select tones in advance

  play_wvwait:	in	a,(FMIO)	; wait till Wave Load ready
	bit	1,a
	jr	nz,play_wvwait

	IF	SPTEST
	ld	a,15 * 16 + 8	; red
	out	(099h),a
	ld	a,7+128
	out	(099h),a
	ENDIF


	ld	hl,step_buffer	; songdata-adres
	ld	iy,play_table_wav ;wavetable for all 24 channels
	ld	b,WAVCHNS	; amount of Wave channels (=24)
	ld	de,PTW_SIZE ;size of wavetable (=20 bytes)
  play_int_wlus:	ld	a,(hl)
	or	a
	jr	z,play_int_wend2	; empty

	ex	af,af'
	ld	a,b
	exx
	ld	b,a
	ex	af,af'
	ld	de,play_int_wend
	push	de

	cp	97
	jp	c,play_wonevt	; wave on
	jp	z,play_woffevt	; wave off
	cp	146
	jp	c,play_wwavevt	; wave
	cp	178
	jp	c,play_wchgvol	; volume
	cp	193
	jp	c,play_wchgste	; stereo
	cp	212
	jp	c,play_wlnk	    ; link
	cp	231
	jp	c,play_wchgpit	; pitch bending
	cp	238
	jp	c,play_wchgdet	; detune
	cp	241
	jp	c,play_wchgmod	; modulation
	cp	243
	jp	c,play_chgdmp	  ; damp

  play_int_wend:	exx
  play_int_wend2:
	add	iy,de
	inc	hl
	djnz	play_int_wlus

	ld	a,(hl)	; command line
	or	a
	jr	z,play_cmdcnt

	cp	24
	jp	c,play_chgtmp	; change tempo
	jp	z,play_endop	; end of pattern
	cp	28
	jr	c,play_cmdcnt	; status
	cp	76
	jp	c,play_chgtrs	; transpose
  play_cmdcnt:
  play_int_fin:
;	pop	af
;	call	selbank_FE

play_int_end:
	IF	SPTEST
	ld	a,15*16	; black
	out	(099h),a
	ld	a,7+128
	out	(099h),a
	ENDIF

old_int:	ret
	ret
	ret
	ret
	ret



;-------------------------------
;--- Fade interrupt routines ---
;-------------------------------

	IF	FADE

play_fade:	ld	a,(play_fadespd)	; speed
	ld	hl,play_fadecnt
	inc	(hl)
	cp	(hl)
	ret	nz
	ld	(hl),0

	ld	b,WAVCHNS
	ld	iy,play_table_wav
	ld	de,PTW_SIZE
play_fadelp:	ld	a,(iy + 15)
	add	a,8	 ; -4, but bit 0 is not for volume
	jr	nc,play_fade2
	ld	a,255
play_fade2:	ld	(iy + 15),a
	ld	a,050h - 1
	add	a,b
	out	(WVIO),a
	ld	a,(iy + 15)	; level direct
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a
	add	iy,de
	djnz	play_fadelp

	ld	hl,play_fadetcnt	; total counter
	inc	(hl)
	ld	a,(hl)
	cp	33	; will always be faded out in 33 steps
	ret	nz
	xor	a
	ld	(play_fading),a
	jp	stop_music

	ENDIF

;--------------------------
;--- CMD Event routines ---
;--------------------------

;-- change tempo --
play_chgtmp:	cpl
	add	a,25 + 1	; Zelly, shut up!
	ld	(play_speed),a
	jp	play_cmdcnt

;-- end of pattern --
play_endop:	ld	a,15
	ld	(play_step),a
	jp	play_cmdcnt

;--- set transpose ---
play_chgtrs:	sub	52
	ld	(play_tspval),a
	jp	play_cmdcnt

;--- Play ON-event ---
play_wonevt:
	dec	b
	ld	l,(iy + 13)
	ld	h,(iy + 14)
	ld	a,l
	or	h
	jr	z,play_wonevtlp2	; own voice, no header...

	IF	RAMHEADERS
	ld	a,80h	; set header data other than ROM data
	add	a,b
	out	(WVIO),a
	ld	a,(hl)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a
	inc	hl
play_wonevtlp:	ld	a,(hl)
	cp	0ffh
	jr	z,play_wonevtlp2
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	inc	hl
	ld	a,(hl)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; header byte
	inc	hl
	jp	play_wonevtlp
	ENDIF

play_wonevtlp2:
	ld	a,050h	; set volume back to normal
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,(iy + 15)
	or	1	; level direct
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a

	ld	a,068h
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,10000000b
	or	(iy + 11)	; pan pot
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; key on
	ret

;--- Play OFF event ---

play_woffevt:	ld	a,068h - 1
	add	a,b	; calc. register
	out	(WVIO),a
	ld	(iy+2),0	; pb/mod off
;	opl4_wait	; wait if Turbo-R
	in	a,(WVIO + 1)
	and	1111111b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO + 1),a
	ret

;--- Link note ---

play_wlnk:	ld	(iy + 2),0
	push	bc
	sub	202
	add	a,(iy + 0)
	ld	(iy + 0),a

	bit	0,(iy + 6)
	jr	z,play_wlnk2
	bit	7,(iy + 7)
	jr	nz,play_wlnk3

play_wlnk2:	ld	hl,tabdiv12
	ld	c,a
	ld	b,0
	add	hl,bc
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	a,(hl)
	ld	l,(iy + 16)
	ld	h,(iy + 17)
;	add_hl_a	; ptr to freq
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla4
	inc	h
addhla4:	ld	l,a
;	endm

	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl	; HL = freq

play_wlnk_7:	sla	l
	ld	a,h
	rla
	add	a,c

	ld	h,a
	ld	d,0
	ld	e,(iy + 5)
	bit	7,e
	jr	z,play_wlnk_6
	dec	d
play_wlnk_6:	add	hl,de	; detune...
	add	hl,de

	ld	(iy + 18),l	; freq fine
	ld	(iy + 19),h

	pop	bc
	ld	a,20h - 1
	add	a,b
	out	(WVIO),a
	ld	a,l
	or	(iy + 6)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq + tone

	ld	a,38h - 1
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,h
	or	(iy + 12)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq
	ret

play_wlnk3:	ld	l,(iy + 16)	; link own wave
	ld	h,(iy + 17)
	ld	e,a
	ld	d,0
	add	hl,de
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl	; freq
	jp	play_wlnk_7

;--- Pitch bending ---
play_wchgpit:	sub	221
	ld	(iy+2),1	; Pitch bending on
	add	a,a
	add	a,a
	ld	(iy+3),a	; Set pitch bend speed
	rlca		; bit 7,a
	jr	c,play_wchgpit2
	ld	(iy+4),0
	ret
play_wchgpit2:	ld	(iy+4),0ffh
	ret

;--- Modulation event ---
play_wchgmod:	sub	238 - 2
	ld	(iy + 2),a
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	hl,xmodtab - 2 * 16
;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla5
	inc	h
addhla5:	ld	l,a
;	endm
	ld	(iy + 3),l
	ld	(iy + 4),h
	ret

;--- Set detune ---
play_wchgdet:	sub	234
	add	a,a
	add	a,a	; * 4
	ld	(iy + 5),a
	ret

;--- Damp ---
play_chgdmp:	ld	a,068h - 1
	add	a,b	; calc. register
	out	(WVIO),a
	ld	(iy+2),0	; pb/mod off
;	opl4_wait	; wait if Turbo-R
	in	a,(WVIO+1)
	or	1000000b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO + 1),a
	ret




























;-----------------------------------------------
;--- Interrupt routine BEFORE play-interrupt ---
;-----------------------------------------------

play_int_sec:	dec	a
	cp	(hl)
	jp	z,play_int_secit
	dec	a
	cp	(hl)
	jp	nz,play_int_fin

play_int_3rd:	ld	a,(play_step)		; increase current step
	inc	a
	and	01111b
	ld	(play_step),a
	ld	hl,(songdata_ptr)
	call	z,play_nextpos		; step 0 => new position

	IF	SPTEST
	ld	a,15*16 + 4	; blue
	out	(099h),a
	ld	a,7+128
	out	(099h),a
	ENDIF

;	ld	a,(songdata_bank)
;	call	selbank_FE

;--- decrunch one step ---

	ld	de,step_buffer
decr_step_lp:	ld	a,(hl)
	inc	hl
	cp	0ffh	; 0FFh => completely empty
	jp	nz,decr_step_2
	exx
	ld	hl,step_buffer
	ld	de,step_buffer + 1
	ld	bc,25 - 1
	ld	(hl),b
	ldir
	exx
	jp	decr_step_end

decr_step_2:	ld	(de),a	; 1st byte uncrunched
	inc	de
	push	hl
	inc	hl
	inc	hl
	inc	hl
	exx
	pop	hl
	ld	b,3	; decrunch 3 * 8 bytes
decr_step_lp1:	ld	a,(hl)
	exx
	ld	b,8	; decrunch 8 bytes
	ld	c,a
decr_step_lp2:	xor	a
	rlc	c
	jr	nc,decr_step_3	; no carry? then empty event
	ld	a,(hl)
	inc	hl
decr_step_3:	ld	(de),a
	inc	de
	djnz	decr_step_lp2
	exx
	inc	hl
	djnz	decr_step_lp1
	exx
decr_step_end:	ld	(songdata_ptr),hl

;--- Calculate freq. & note nr of wave to play ---

	IF	SPTEST
	ld	a,15*16+3	; green
	out	(099h),a
	ld	a,7+128
	out	(099h),a
	ENDIF

	ld	iy,play_table_wav
	ld	hl,step_buffer	; third interrupt
;	ld_bc (WAVCHNS/2),96	; Wave channels
;ld_bc:	macro @bv, @cv
	ld	bc, 256 * (WAVCHNS/2) + 96
;                endm


	jr	play_int_seclp


play_int_secit: ld	b,WAVCHNS
	ld	hl,step_buffer
	ld	iy,play_table_wav
	ld	de,PTW_SIZE
play_int_secl2: ld	a,(hl)
	dec	a
	cp	96
	jr	nc,play_int_secpb
	ld	(iy + 2),0
play_int_secpb: inc	hl
	add	iy,de
	djnz	play_int_secl2

	ld	iy,play_table_wav + (WAVCHNS/2) * PTW_SIZE
	ld	hl,step_buffer + WAVCHNS / 2   ; second interrupt

;	ld_bc (WAVCHNS/2),96	; Wave channels
;ld_bc:	macro @bv, @cv
;	ld	bc, 256 * @bv + @cv
;                endm
	ld bc,256 * (WAVCHNS/2) + 96	; Wave channels

play_int_seclp:
	ld	de,PTW_SIZE
play_int_secwl: ld	a,(hl)
	dec	a
	cp	c	; 96
	jp	c,calc_wave	; JP to and fro for extra speed
play_int_secwe: add	iy,de
	inc	hl
	djnz	play_int_secwl
	jp	play_int_fin


;--- calc wave stuff ---

calc_wave:	exx
	ld	d,a

;	ld	hl,patch_table	; dit stuk verandert A niet!
	ld	b,0
	ld	c,(iy + 10)
	ld	a,c
;	cp	175
;	jp	z,calc_drm	; gm drum patch
	cp	176
	jp	nc,calc_own	; own wave

calc_drm_cnt:	ld	a,d
	add	hl,bc
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)	; pointer to patch
	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	(iy + 13),c	; pointer to header bytes
	ld	(iy + 14),b
			; search right patch part

	bit	0,e	; transpose
	jr	z,keyb_wonwav7
	ld	b,a
	ld	a,(play_tspval)
	add	a,b
keyb_wonwav7:	ld	b,0
	ld	de,3 + 2
calc_wave_lp:	cp	(hl)
	jr	c,calc_wave_2
	ld	b,(hl)
	add	hl,de
	cp	(hl)	; 4 * the same, saves 30 T-states!
	jr	c,calc_wave_2	; (Anything for some extra speed)
	ld	b,(hl)
	add	hl,de
	cp	(hl)
	jr	c,calc_wave_2
	ld	b,(hl)
	add	hl,de
	cp	(hl)
	jr	c,calc_wave_2
	ld	b,(hl)
	add	hl,de
	jp	calc_wave_lp
calc_wave_2:	ld	d,a	; save note...
	inc	hl
	ld	a,(hl)	; low byte tone
	ld	(iy + 7),a

	inc	hl
	ld	a,(hl)
	and	1	; also resets carry!
	ld	(iy + 6),a	; high byte tone

	ld	a,(hl)	; tone-note
	rra		; note that carry was set 0 earlier!!
	add	a,d
	sub	b
	ld	(iy + 0),a	; last note

	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(iy + 17),d	; pointer to freqtab
	ld	(iy + 16),e

	ld	hl,tabdiv12
	ld	c,a
	ld	b,0
	add	hl,bc
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	a,(hl)
	ex	de,hl

;	add_hl_a	; right ptr to freq
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,.addhla
	inc	h
.addhla:	ld	l,a
;	endm	ld	a,(hl)

	ld	e,(hl)
	inc	hl
	ld	d,(hl)	; DE = freq

	sla	e	; freq fine
	ld	a,d
	rla		; freq rotated 1 left
	add	a,c	; octave

	ld	d,a	; high byte freq

	ld	h,b	; LD H,0!
calc_drmcnt2:	ld	l,(iy + 5)
	bit	7,l
	jr	z,calc_wave_6
	dec	h
	add	hl,hl	; detune...
calc_wave_7:	add	hl,de
	res	3,h
	ld	(iy + 8),l	; freq fine
	ld	(iy + 9),h
	exx		; Yes! Finally, finished...
	jp	play_int_secwe
calc_wave_6:	ex	de,hl
	add	hl,de	; detune...
	ld	d,1000b
	jr	calc_wave_7


;--- Calc GM drums ---

;calc_drm:	ld	a,d
;	cp	36
;	jp	c,calc_drm_cnt	; < 36 => first drum handled as patch
;	cp	82 + 5
;	jp	c,calc_drm2
;	ld	a,81 + 5	; > 86 => 86
;calc_drm2:
;	ld	hl,gmdrm_c4
;	sub	36
;	ld	b,a
;	add	a,a
;	add	a,a
;	add	a,b
;add_hl_a:	macro 	; add A to HL
;	add	a,l	; notice: A is modified!
;	jr	nc,.addhla
;	inc	h
;.addhla:	ld	l,a
;	endm	ld	a,(hl)
;	ld	a,(hl)
;	ld	(iy + 7),a
;	ld	(iy + 6),0
;	inc	hl
;	ld	e,(hl)
;	inc	hl
;	ld	d,(hl)
;	inc	hl
;	ld	a,(hl)
;	ld	(iy + 13),a
;	inc	hl
;	ld	a,(hl)
;	ld	(iy + 14),a
;	ld	h,0
;	jp	calc_drmcnt2

calc_own:	sub	176
	ld	c,a
	add	a,a
	add	a,a
	add	a,a
	ld	l,a
	ld	h,0
	add	hl,hl
;	add_hl_a	; * 24
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,.addhla
	inc	h
.addhla:	ld	l,a
;	endm	ld	a,(hl)

	ld	a,c
;	add_hl_a	; * 25
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,.addhla2
	inc	h
.addhla2:	ld	l,a
;	endm	ld	a,(hl)

	ld	bc,waves
	add	hl,bc	; pointer to patch

	ld	e,(hl)	; transpose
	inc	hl
			; zoek juiste patch-deel
	ld	a,d
	bit	0,e	; transpose
	jr	z,calc_own2
	ld	a,(play_tspval)
	add	a,d

calc_own2:	ld	d,0
	ld	bc,3
calc_own_lp:	cp	(hl)
	jr	c,calc_own_2
	ld	d,(hl)
	add	hl,bc
	jp	calc_own_lp
calc_own_2:	ld	b,a	; save note...
	inc	hl
	ld	a,(hl)	; low byte tone
	ld	e,a
	add	a,128	; tone 384 and above
	ld	(iy + 7),a
	ld	(iy + 6),1	; RAM wave is altijd > 256
	inc	hl

	ld	a,(hl)	; tone-note
	add	a,b
	sub	d
	ld	(iy + 0),a	; last note
	push	af

	ld	(iy + 13),0	; no header
	ld	(iy + 14),0	; can be done faster!

	ld	hl,tones_data
	ld	d,0
	add	hl,de
	ld	a,(hl)
	and	110b
	ld	hl,frqtab_amiga
	jr	z,calc_own3
	ld	hl,frqtab_441khz
	cp	2
	jr	z,calc_own3
	ld	hl,frqtab_turbo
calc_own3:	pop	af
	ld	(iy + 16),l
	ld	(iy + 17),h

	ld	e,a	; D is still 0
	add	hl,de
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	h,0
	jp	calc_drmcnt2

;--------------------------------
;--- Pitch interrupt routines ---
;--------------------------------

;----- pitch bending/modulation -----

play_pitch:	ld	iy,play_table_wav
	ld	de,PTW_SIZE
	ld	hl,play_pitchwvl2
	ld	b,WAVCHNS		; wave channels 24
play_pitchwlus: ld	a,(iy+2)
	or	a
	jp	nz,play_pitch_wdo
play_pitchwvl2: add	iy,de
	djnz	play_pitchwlus
	ret


;--- pitch bending ---

play_pitch_wdo: exx

	ld	c,a

	ld	l,(iy + 3)	; pitch bend speed
	ld	h,(iy + 4)
	dec	c
	jp	nz,play_mod_wdo	; modulation
	ex	de,hl
play_pitch_wd4: ld	h,(iy + 19)
	ld	l,(iy + 18)
	add	hl,de	; sliding
	bit	3,h
	jr	z,play_pitch_wd5
	bit	7,d
	jr	nz,play_pitch_wd6
	ld	a,h
	add	a,1000b
	ld	h,a
	jr	play_pitch_wd5
play_pitch_wd6: res	3,h
play_pitch_wd5: ld	(iy + 18),l	 ; freq fine
	ld	(iy + 19),h

	ld	a,(iy + 1)
	ld	c,a
	out	(WVIO),a
	ld	a,l
	or	(iy + 6)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq + tone

	ld	a,c
	add	a,24
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,h
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq
	exx
	jp	(hl)

;---- modulation ----

play_mod_wdo:
	ld	d,0
	ld	e,(hl)
	sla	e
	sla	e
	jr	nc,play_mod_wdo3
	dec	d
play_mod_wdo3:	inc	hl
	ld	a,(hl)
	cp	10
	jp	nz,play_mod_wdo2
	ld	a,c

	ld	hl,xmodtab - 16
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	
;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,.addhla
	inc	h
.addhla:	ld	l,a
;	endm	ld	a,(hl)
	
	
play_mod_wdo2:	ld	(iy + 3),l
	ld	(iy + 4),h
	jp	play_pitch_wd4
	
;---------------------------
;--- Go to next position ---
;---------------------------

play_nextpos:	;ld	a,(songdata_bank1)
;	call	selbank_FE	; this bank contains pattern addresses

	ld	a,(xleng)
	inc	a
	ld	b,a
	ld	a,(play_pos)
	inc	a
	cp	b
	jp	c,play_nextpos2
	ld	a,(xloop)
	cp	255
	call	z,play_nextstop	; stop song, when loop =OFF

  play_nextpos2:	ld	(play_pos),a
	ld	hl,(pos_address)
;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla6
	inc	h
addhla6:	ld	l,a
;	endm	ld	a,(hl)
	ld	(current_pat),a
	add	a,a
	ld	hl,(pat_address)
;	add_hl_a
;add_hl_a:	macro 	; add A to HL
	add	a,l	; notice: A is modified!
	jr	nc,addhla7
	inc	h
addhla7:	ld	l,a
;	endm	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	a,h
	rlca
	rlca
	and	011b
;	ld	de,songdata_bank1

;	add_de_a
;add_de_a:	macro 	; add A to DE
	add	a,e	; notice: A is modified!
	jr	nc,.adddea
	inc	d
.adddea:	ld	e,a
;	endm
	
;	ld	a,(de)
;	ld	(songdata_bank),a
	ld	a,h
	and	00111111b
	ld	h,a
	ld	de,(songdata_adres)
	add	hl,de
	ret
	
  play_nextstop:	call	stop_music
	xor	a
	ret


;---------------------------
;--- WAVE Event routines ---
;---------------------------

play_wtones:	ld	hl,step_buffer	; songdata address
	ld	b,WAVCHNS	; # channels
	ld	iy,play_table_wav
	ld	de,PTW_SIZE
play_wtonesl:	ld	a,(hl)
	dec	a
	cp	96
	jp	nc,play_wtonese

	ld	a,068h - 1
	add	a,b	; calc. register
	out	(WVIO),a
	xor	a
	nop
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; off

	ld	a,050h - 1
	add	a,b	; calc. register
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	c,a
	ld	a,11111111b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; volume 0!

	ld	a,20h - 1
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,(iy + 8)
	ld	(iy + 18),a
	or	(iy + 6)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq + tone

	ld	a,8 - 1
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,(iy + 7)
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; tone

	ld	a,38h - 1
	add	a,b
;	opl4_wait	; wait if Turbo-R
	out	(WVIO),a
	ld	a,(iy + 9)
	ld	(iy + 19),a
;	opl4_wait	; wait if Turbo-R
	out	(WVIO+1),a	; freq

play_wtonese:	inc	hl
	add	iy,de
	djnz	play_wtonesl
	ret





 











;--- smart table: --

;    - last note played		01: + 0
;    - frequency register		01: + 1
;    - pitch bending on/off		01: + 2
;    - pitch bend speed		02: + 3
;    - detune value			01: + 5
;    - tone nr for next interrupt		02: + 6
;    - freq for next interrupt		02: + 8
;    - current 			01  + 10
;    - current stereo setting		01  + 11
;    - pseudo reverb (currenty not used)	01  + 12
;    - Pointer to header bytes		02  + 13
;    - Volume				01  + 15
;    - Pointer to used freq table		01  + 16
;    - Current pitch freq.		02  + 18
;				--
;    Total:				20
play_table_wav: db	0,$37,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch1
	db	0,$36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch2
	db	0,$35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch3
	db	0,$34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch4
	db	0,$33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch5
	db	0,$32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch6
	db	0,$31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch7
	db	0,$30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch8
	db	0,$2f,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch9
	db	0,$2e,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch10
	db	0,$2d,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch11
	db	0,$2c,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch12
	db	0,$2b,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch13
	db	0,$2a,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch14
	db	0,$29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch15
	db	0,$28,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch16
	db	0,$27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch17
	db	0,$26,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch18
	db	0,$25,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch19
	db	0,$24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch20
	db	0,$23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch21
	db	0,$22,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch22
	db	0,$21,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch23
	db	0,$20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; ch24

tabdiv12:	db	-5*16,0,-5*16,2*1,-5*16,2*2,-5*16,2*3,-5*16,2*4,-5*16,2*5
	db	-5*16,2*6,-5*16,2*7,-5*16,2*8,-5*16,2*9,-5*16,2*10,-5*16,2*11
	db	-4*16,0,-4*16,2*1,-4*16,2*2,-4*16,2*3,-4*16,2*4,-4*16,2*5
	db	-4*16,2*6,-4*16,2*7,-4*16,2*8,-4*16,2*9,-4*16,2*10,-4*16,2*11
	db	-3*16,0,-3*16,2*1,-3*16,2*2,-3*16,2*3,-3*16,2*4,-3*16,2*5
	db	-3*16,2*6,-3*16,2*7,-3*16,2*8,-3*16,2*9,-3*16,2*10,-3*16,2*11
	db	-2*16,0,-2*16,2*1,-2*16,2*2,-2*16,2*3,-2*16,2*4,-2*16,2*5
	db	-2*16,2*6,-2*16,2*7,-2*16,2*8,-2*16,2*9,-2*16,2*10,-2*16,2*11
	db	-1*16,0,-1*16,2*1,-1*16,2*2,-1*16,2*3,-1*16,2*4,-1*16,2*5
	db	-1*16,2*6,-1*16,2*7,-1*16,2*8,-1*16,2*9,-1*16,2*10,-1*16,2*11
	db	0*16,0,0*16,2*1,0*16,2*2,0*16,2*3,0*16,2*4,0*16,2*5
	db	0*16,2*6,0*16,2*7,0*16,2*8,0*16,2*9,0*16,2*10,0*16,2*11
	db	1*16,0,1*16,2*1,1*16,2*2,1*16,2*3,1*16,2*4,1*16,2*5
	db	1*16,2*6,1*16,2*7,1*16,2*8,1*16,2*9,1*16,2*10,1*16,2*11
	db	2*16,0,2*16,2*1,2*16,2*2,2*16,2*3,2*16,2*4,2*16,2*5
	db	2*16,2*6,2*16,2*7,2*16,2*8,2*16,2*9,2*16,2*10,2*16,2*11
	db	3*16,0,3*16,2*1,3*16,2*2,3*16,2*3,3*16,2*4,3*16,2*5
	db	3*16,2*6,3*16,2*7,3*16,2*8,3*16,2*9,3*16,2*10,3*16,2*11
	db	4*16,0,4*16,2*1,4*16,2*2,4*16,2*3,4*16,2*4,4*16,2*5
	db	4*16,2*6,4*16,2*7,4*16,2*8,4*16,2*9,4*16,2*10,4*16,2*11
	db	5*16,0,5*16,2*1,5*16,2*2,5*16,2*3,5*16,2*4,5*16,2*5
	db	5*16,2*6,5*16,2*7,5*16,2*8,5*16,2*9,5*16,2*10,5*16,2*11
	db	6*16,0,6*16,2*1,6*16,2*2,6*16,2*3,6*16,2*4,6*16,2*5
	db	6*16,2*6,6*16,2*7,6*16,2*8,6*16,2*9,6*16,2*10,6*16,2*11
	db	7*16,0,7*16,2*1,7*16,2*2,7*16,2*3,7*16,2*4,7*16,2*5
	db	7*16,2*6,7*16,2*7,7*16,2*8,7*16,2*9,7*16,2*10,7*16,2*11
	db	8*16,0,8*16,2*1,8*16,2*2,8*16,2*3,8*16,2*4,8*16,2*5
	db	8*16,2*6,8*16,2*7,8*16,2*8,8*16,2*9,8*16,2*10,8*16,2*11
	db	9*16,0,9*16,2*1,9*16,2*2,9*16,2*3,9*16,2*4,9*16,2*5
	db	9*16,2*6,9*16,2*7,9*16,2*8,9*16,2*9,9*16,2*10,9*16,2*11
	db	10*16,0,10*16,2*1,10*16,2*2,10*16,2*3,10*16,2*4,10*16,2*5
	db	10*16,2*6,10*16,2*7,10*16,2*8,10*16,2*9,10*16,2*10,10*16,2*11


;--- freq. table for 44.1 kHz

frqtab_441khz:	dw  (-4 * 2048 + 0) * 2
	dw  (-4 * 2048 + 61) * 2
	dw  (-4 * 2048 + 125) * 2
	dw  (-4 * 2048 + 194) * 2
	dw  (-4 * 2048 + 266) * 2
	dw  (-4 * 2048 + 343) * 2
	dw  (-4 * 2048 + 424) * 2
	dw  (-4 * 2048 + 510) * 2
	dw  (-4 * 2048 + 601) * 2
	dw  (-4 * 2048 + 698) * 2
	dw  (-4 * 2048 + 801) * 2
	dw  (-4 * 2048 + 909) * 2
	dw  (-3 * 2048 + 0) * 2
	dw  (-3 * 2048 + 61) * 2
	dw  (-3 * 2048 + 125) * 2
	dw  (-3 * 2048 + 194) * 2
	dw  (-3 * 2048 + 266) * 2
	dw  (-3 * 2048 + 343) * 2
	dw  (-3 * 2048 + 424) * 2
	dw  (-3 * 2048 + 510) * 2
	dw  (-3 * 2048 + 601) * 2
	dw  (-3 * 2048 + 698) * 2
	dw  (-3 * 2048 + 801) * 2
	dw  (-3 * 2048 + 909) * 2
	dw  (-2 * 2048 + 0) * 2
	dw  (-2 * 2048 + 61) * 2
	dw  (-2 * 2048 + 125) * 2
	dw  (-2 * 2048 + 194) * 2
	dw  (-2 * 2048 + 266) * 2
	dw  (-2 * 2048 + 343) * 2
	dw  (-2 * 2048 + 424) * 2
	dw  (-2 * 2048 + 510) * 2
	dw  (-2 * 2048 + 601) * 2
	dw  (-2 * 2048 + 698) * 2
	dw  (-2 * 2048 + 801) * 2
	dw  (-2 * 2048 + 909) * 2
	dw  (-1 * 2048 + 0) * 2
	dw  (-1 * 2048 + 61) * 2
	dw  (-1 * 2048 + 125) * 2
	dw  (-1 * 2048 + 194) * 2
	dw  (-1 * 2048 + 266) * 2
	dw  (-1 * 2048 + 343) * 2
	dw  (-1 * 2048 + 424) * 2
	dw  (-1 * 2048 + 510) * 2
	dw  (-1 * 2048 + 601) * 2
	dw  (-1 * 2048 + 698) * 2
	dw  (-1 * 2048 + 801) * 2
	dw  (-1 * 2048 + 909) * 2
	dw  (-0 * 2048 + 0) * 2
	dw  (-0 * 2048 + 61) * 2
	dw  (-0 * 2048 + 125) * 2
	dw  (-0 * 2048 + 194) * 2
	dw  (-0 * 2048 + 266) * 2
	dw  (-0 * 2048 + 343) * 2
	dw  (-0 * 2048 + 424) * 2
	dw  (-0 * 2048 + 510) * 2
	dw  (-0 * 2048 + 601) * 2
	dw  (-0 * 2048 + 698) * 2
	dw  (-0 * 2048 + 801) * 2
	dw  (-0 * 2048 + 909) * 2
	dw  (+1 * 2048 + 0) * 2
	dw  (+1 * 2048 + 61) * 2
	dw  (+1 * 2048 + 125) * 2
	dw  (+1 * 2048 + 194) * 2
	dw  (+1 * 2048 + 266) * 2
	dw  (+1 * 2048 + 343) * 2
	dw  (+1 * 2048 + 424) * 2
	dw  (+1 * 2048 + 510) * 2
	dw  (+1 * 2048 + 601) * 2
	dw  (+1 * 2048 + 698) * 2
	dw  (+1 * 2048 + 801) * 2
	dw  (+1 * 2048 + 909) * 2
	dw  (+2 * 2048 + 0) * 2
	dw  (+2 * 2048 + 61) * 2
	dw  (+2 * 2048 + 125) * 2
	dw  (+2 * 2048 + 194) * 2
	dw  (+2 * 2048 + 266) * 2
	dw  (+2 * 2048 + 343) * 2
	dw  (+2 * 2048 + 424) * 2
	dw  (+2 * 2048 + 510) * 2
	dw  (+2 * 2048 + 601) * 2
	dw  (+2 * 2048 + 698) * 2
	dw  (+2 * 2048 + 801) * 2
	dw  (+2 * 2048 + 909) * 2
	dw  (+3 * 2048 + 0) * 2
	dw  (+3 * 2048 + 61) * 2
	dw  (+3 * 2048 + 125) * 2
	dw  (+3 * 2048 + 194) * 2
	dw  (+3 * 2048 + 266) * 2
	dw  (+3 * 2048 + 343) * 2
	dw  (+3 * 2048 + 424) * 2
	dw  (+3 * 2048 + 510) * 2
	dw  (+3 * 2048 + 601) * 2
	dw  (+3 * 2048 + 698) * 2
	dw  (+3 * 2048 + 801) * 2
	dw  (+3 * 2048 + 909) * 2

;--- freq table for Amiga ---

frqtab_amiga:

	dw  (-5 * 2048 + 529) * 2
	dw  (-5 * 2048 + 621) * 2
	dw  (-5 * 2048 + 721) * 2
	dw  (-5 * 2048 + 823) * 2
	dw  (-5 * 2048 + 937) * 2
	dw  (-4 * 2048 + 14) * 2
	dw  (-4 * 2048 + 76) * 2
	dw  (-4 * 2048 + 142) * 2
	dw  (-4 * 2048 + 211) * 2
	dw  (-4 * 2048 + 284) * 2
	dw  (-4 * 2048 + 361) * 2
	dw  (-4 * 2048 + 447) * 2

	dw  (-4 * 2048 + 529) * 2
	dw  (-4 * 2048 + 621) * 2
	dw  (-4 * 2048 + 721) * 2
	dw  (-4 * 2048 + 823) * 2
	dw  (-4 * 2048 + 937) * 2
	dw  (-3 * 2048 + 14) * 2
	dw  (-3 * 2048 + 76) * 2
	dw  (-3 * 2048 + 142) * 2
	dw  (-3 * 2048 + 211) * 2
	dw  (-3 * 2048 + 284) * 2
	dw  (-3 * 2048 + 361) * 2
	dw  (-3 * 2048 + 447) * 2

	dw  (-3 * 2048 + 529) * 2
	dw  (-3 * 2048 + 621) * 2
	dw  (-3 * 2048 + 721) * 2
	dw  (-3 * 2048 + 823) * 2
	dw  (-3 * 2048 + 937) * 2
	dw  (-2 * 2048 + 14) * 2
	dw  (-2 * 2048 + 76) * 2
	dw  (-2 * 2048 + 142) * 2
	dw  (-2 * 2048 + 211) * 2
	dw  (-2 * 2048 + 284) * 2
	dw  (-2 * 2048 + 361) * 2
	dw  (-2 * 2048 + 447) * 2

	dw  (-2 * 2048 + 529) * 2
	dw  (-2 * 2048 + 621) * 2
	dw  (-2 * 2048 + 721) * 2
	dw  (-2 * 2048 + 823) * 2
	dw  (-2 * 2048 + 937) * 2
	dw  (-1 * 2048 + 14) * 2
	dw  (-1 * 2048 + 76) * 2
	dw  (-1 * 2048 + 142) * 2
	dw  (-1 * 2048 + 211) * 2
	dw  (-1 * 2048 + 284) * 2
	dw  (-1 * 2048 + 361) * 2
	dw  (-1 * 2048 + 447) * 2

	dw  (-1 * 2048 + 529) * 2
	dw  (-1 * 2048 + 621) * 2
	dw  (-1 * 2048 + 721) * 2
	dw  (-1 * 2048 + 823) * 2
	dw  (-1 * 2048 + 937) * 2
	dw  (-0 * 2048 + 14) * 2
	dw  (-0 * 2048 + 76) * 2
	dw  (-0 * 2048 + 142) * 2
	dw  (-0 * 2048 + 211) * 2
	dw  (-0 * 2048 + 284) * 2
	dw  (-0 * 2048 + 361) * 2
	dw  (-0 * 2048 + 447) * 2

	dw  (-0 * 2048 + 529) * 2
	dw  (-0 * 2048 + 621) * 2
	dw  (-0 * 2048 + 721) * 2
	dw  (-0 * 2048 + 823) * 2
	dw  (-0 * 2048 + 937) * 2
	dw  (+1 * 2048 + 14) * 2
	dw  (+1 * 2048 + 76) * 2
	dw  (+1 * 2048 + 142) * 2
	dw  (+1 * 2048 + 211) * 2
	dw  (+1 * 2048 + 284) * 2
	dw  (+1 * 2048 + 361) * 2
	dw  (+1 * 2048 + 447) * 2

	dw  (+1 * 2048 + 529) * 2
	dw  (+1 * 2048 + 621) * 2
	dw  (+1 * 2048 + 721) * 2
	dw  (+1 * 2048 + 823) * 2
	dw  (+1 * 2048 + 937) * 2
	dw  (+2 * 2048 + 14) * 2
	dw  (+2 * 2048 + 76) * 2
	dw  (+2 * 2048 + 142) * 2
	dw  (+2 * 2048 + 211) * 2
	dw  (+2 * 2048 + 284) * 2
	dw  (+2 * 2048 + 361) * 2
	dw  (+2 * 2048 + 447) * 2

	dw  (+2 * 2048 + 529) * 2
	dw  (+2 * 2048 + 621) * 2
	dw  (+2 * 2048 + 721) * 2
	dw  (+2 * 2048 + 823) * 2
	dw  (+2 * 2048 + 937) * 2
	dw  (+3 * 2048 + 14) * 2
	dw  (+3 * 2048 + 76) * 2
	dw  (+3 * 2048 + 142) * 2
	dw  (+3 * 2048 + 211) * 2
	dw  (+3 * 2048 + 284) * 2
	dw  (+3 * 2048 + 361) * 2
	dw  (+3 * 2048 + 447) * 2


;--- freq table for Turbo-R ---

frqtab_turbo:
	dw  (-5 * 2048 + 439) * 2
	dw  (-5 * 2048 + 526) * 2
	dw  (-5 * 2048 + 618) * 2
	dw  (-5 * 2048 + 716) * 2
	dw  (-5 * 2048 + 819) * 2
	dw  (-5 * 2048 + 929) * 2
	dw  (-4 * 2048 + 10) * 2
	dw  (-4 * 2048 + 72) * 2
	dw  (-4 * 2048 + 137) * 2
	dw  (-4 * 2048 + 206) * 2
	dw  (-4 * 2048 + 279) * 2
	dw  (-4 * 2048 + 357) * 2

	dw  (-4 * 2048 + 439) * 2
	dw  (-4 * 2048 + 526) * 2
	dw  (-4 * 2048 + 618) * 2
	dw  (-4 * 2048 + 716) * 2
	dw  (-4 * 2048 + 819) * 2
	dw  (-4 * 2048 + 929) * 2
	dw  (-3 * 2048 + 10) * 2
	dw  (-3 * 2048 + 72) * 2
	dw  (-3 * 2048 + 137) * 2
	dw  (-3 * 2048 + 206) * 2
	dw  (-3 * 2048 + 279) * 2
	dw  (-3 * 2048 + 357) * 2

	dw  (-3 * 2048 + 439) * 2
	dw  (-3 * 2048 + 526) * 2
	dw  (-3 * 2048 + 618) * 2
	dw  (-3 * 2048 + 716) * 2
	dw  (-3 * 2048 + 819) * 2
	dw  (-3 * 2048 + 929) * 2
	dw  (-2 * 2048 + 10) * 2
	dw  (-2 * 2048 + 72) * 2
	dw  (-2 * 2048 + 137) * 2
	dw  (-2 * 2048 + 206) * 2
	dw  (-2 * 2048 + 279) * 2
	dw  (-2 * 2048 + 357) * 2

	dw  (-2 * 2048 + 439) * 2
	dw  (-2 * 2048 + 526) * 2
	dw  (-2 * 2048 + 618) * 2
	dw  (-2 * 2048 + 716) * 2
	dw  (-2 * 2048 + 819) * 2
	dw  (-2 * 2048 + 929) * 2
	dw  (-1 * 2048 + 10) * 2
	dw  (-1 * 2048 + 72) * 2
	dw  (-1 * 2048 + 137) * 2
	dw  (-1 * 2048 + 206) * 2
	dw  (-1 * 2048 + 279) * 2
	dw  (-1 * 2048 + 357) * 2

	dw  (-1 * 2048 + 439) * 2
	dw  (-1 * 2048 + 526) * 2
	dw  (-1 * 2048 + 618) * 2
	dw  (-1 * 2048 + 716) * 2
	dw  (-1 * 2048 + 819) * 2
	dw  (-1 * 2048 + 929) * 2
	dw  (-0 * 2048 + 10) * 2
	dw  (-0 * 2048 + 72) * 2
	dw  (-0 * 2048 + 137) * 2
	dw  (-0 * 2048 + 206) * 2
	dw  (-0 * 2048 + 279) * 2
	dw  (-0 * 2048 + 357) * 2

	dw  (-0 * 2048 + 439) * 2
	dw  (-0 * 2048 + 526) * 2
	dw  (-0 * 2048 + 618) * 2
	dw  (-0 * 2048 + 716) * 2
	dw  (-0 * 2048 + 819) * 2
	dw  (-0 * 2048 + 929) * 2
	dw  (+1 * 2048 + 10) * 2
	dw  (+1 * 2048 + 72) * 2
	dw  (+1 * 2048 + 137) * 2
	dw  (+1 * 2048 + 206) * 2
	dw  (+1 * 2048 + 279) * 2
	dw  (+1 * 2048 + 357) * 2

	dw  (+1 * 2048 + 439) * 2
	dw  (+1 * 2048 + 526) * 2
	dw  (+1 * 2048 + 618) * 2
	dw  (+1 * 2048 + 716) * 2
	dw  (+1 * 2048 + 819) * 2
	dw  (+1 * 2048 + 929) * 2
	dw  (+2 * 2048 + 10) * 2
	dw  (+2 * 2048 + 72) * 2
	dw  (+2 * 2048 + 137) * 2
	dw  (+2 * 2048 + 206) * 2
	dw  (+2 * 2048 + 279) * 2
	dw  (+2 * 2048 + 357) * 2

	dw  (+2 * 2048 + 439) * 2
	dw  (+2 * 2048 + 526) * 2
	dw  (+2 * 2048 + 618) * 2
	dw  (+2 * 2048 + 716) * 2
	dw  (+2 * 2048 + 819) * 2
	dw  (+2 * 2048 + 929) * 2
	dw  (+3 * 2048 + 10) * 2
	dw  (+3 * 2048 + 72) * 2
	dw  (+3 * 2048 + 137) * 2
	dw  (+3 * 2048 + 206) * 2
	dw  (+3 * 2048 + 279) * 2
	dw  (+3 * 2048 + 357) * 2


waves:	ds	48 * 25
tones_data:	ds	64

songdata_bank:	db	0
play_speed:	    db	0	; current play speed
play_tspval:	  db	0	; current transpose
play_timercnt:	db	0	; tempo counter
play_hzeql:   	db	0 ; hz equalizer counter
current_pat:	  db	0
	IF	FADE
play_fading:	  db	0
play_fadecnt:	  db	0
play_fadespd:	  db	0
play_fadetcnt:	db	0
	ENDIF

xleng:	        ds	1	    ; Song length
xloop:	        ds	1	    ; Loop position
xwvstpr:	      ds	24	  ; Stereo settings Wave
xtempo:	        ds	1	    ; Tempo
xhzequal:	      ds	1	    ; 50/60 Hz Equalizer
xdetune:	      ds	24	  ; Detune settings
xmodtab:	      ds	3*16	; Modulation tables
xbegwav:	      ds	24	  ; Start waves
xwavnrs:	      ds	48	  ; Wave numbers
xwavvols:	      ds	48	  ; Wave volumes

pat_address:	  dw	0
pos_address:	  dw	0
songdata_ptr:	  dw	0

;-------------------------------- PLAYROUTINE --------------------------------

; start_music = start music
; stop_music = stop music
; cont_music = continues music after pause
; halt_music = halts/pauses music

play_busy:	    equ	$da00	  ; status:   0 = not playing	;	 255 = playing
;songdata_bank1: equ	$da01	  ; mapperbank with song data
;songdata_bank2: equ	$da02	  ; mapperbank with song data
;songdata_bank3: equ	$da03	  ; mapperbank with song data
songdata_adres: equ	$da04	  ; address of song data
play_pos:	      equ	$da06	  ; current position
play_step:	    equ	$da07	  ; current step
status:	        equ	$da08	  ; status bytes (0 = off)
step_buffer:	  equ	$da0b	  ; decrunched step, played next int (24 bytes - corresponds to 24 channels I assume)
load_buffer:	  equ	$da23
;freeDOS2segs:	  equ	$da26
;upper_fcb:	    equ	$da40

R800ASM:        equ	0	      ; assembly for R800 on/off
SPTEST:         equ	0 	    ; speed test on/off
FADE:	          equ	1	      ; include code for fade
RAMHEADERS:	    equ	1	      ; don't change ROM headers
                            ; When this is switched OFF the
                            ; replayer will be faster, but only do
                            ; this when you really need the speed!
                            ; It will affect the sound quality.
;PROCNM:	        equ	$fd89
WVIO:	          equ	$7e	    ; wave I/O base port
FMIO:	          equ	$c4
PTW_SIZE:	      equ	20	    ; size of Wave playtable line
WAVCHNS:	      equ	24

;-------------------------------
;--- Initialise BASIC driver ---
;-------------------------------

Initialise:	;di
	ld	hl,play_busy		      ; clear replayer vars
	ld	de,play_busy + 1
	ld	bc,30
	ld	(hl),0
	ldir
;	ld	hl,songdata_bank1
;	ld	(hl),3
;	inc	hl
;	ld	(hl),3
;	inc	hl
;	ld	(hl),3		            ; init default mapper banks
	ld	hl,$8000
	ld	(songdata_adres),hl 	; init default song address


;!!!!!!!!!!! not sure what this is !!!!!!!!!!!!!
;	call	init_calls		      ; init call statements

;copy replayer to ram
;	di
;	ld	a,(0f342h)
;	ld	h,040h
;	call	024h		            ; RAM on page 1
;	ld	hl,start2
;	ld	de,04000h
;	ld	bc,einde - id		      ; copy driver to 04000h
;	ldir

;	di
;	ld	a,(0fcc1h)
;	ld	h,040h
;	call	024h		            ; ROM on page 1
;	ei
	ret

;---- initialise call statements ----

init_calls:	ld	a,($f342)
	push	af
	and	011b
	rlca
	rlca
	rlca
	rlca
	ld	e,a
	ld	d,0
	ld	hl,$fcc9
	add	hl,de
	pop	af
	and	01100b
	ld	e,a
	add	hl,de
	inc	hl
	ld	(hl),32
	ret








































	