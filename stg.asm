.setcpu		"6502"
.autoimport	on

; iNES header
.segment "HEADER"
	.byte	$4E, $45, $53, $1A	; "NES" Header
	.byte	$02					; PRG-BANKS
	.byte	$01					; CHR-BANKS
	.byte	$01					; Vertical Mirror
	.byte	$00					; 
	.byte	$00, $00, $00, $00	; 
	.byte	$00, $00, $00, $00	; 

.segment "STARTUP"
.proc	Reset
	sei
	ldx	#$ff
	txs

; Screen off
	lda	#$00
	sta	$2000
	sta	$2001

; make palette table
	lda	#$3f
	sta	$2006
	lda	#$00
	sta	$2006
	ldx	#$00
	ldy	#$20
copy_pal:
	lda	palettes, x
	sta	$2007
	inx
	dey
	bne	copy_pal

; write string to the name table (Presented by)
	lda	#$21
	sta	$2006
	lda	#$aa
	sta	$2006
	ldx	#$00
	ldy	#$0c
copy_map1:
	lda	string_presented, x
	sta	$2007
	inx
	dey
	bne	copy_map1

; write string to the name table (SUZUKI PLAN.)
	lda	#$21
	sta	$2006
	lda	#$ea
	sta	$2006
	ldx	#$00
	ldy	#$0c
copy_map2:
	lda	string_suzuki, x
	sta	$2007
	inx
	dey
	bne	copy_map2

; scroll setting
	lda	#$00
	sta	$2005
	sta	$2005

; screen on
	lda	#$08
	sta	$2000
	lda	#$1e
	sta	$2001

; drawing sprite pattern table address
	lda #$00
	sta $2003

; setup player variables
	lda #$70
	sta v_playerX
	tax
	lda #$d0
	sta v_playerY
	tay

; setup player sprite (1: left-top)
	tya
	sta sp_player1
	lda #$00
	sta sp_player1 + 1
	lda #$00
	sta sp_player1 + 2
	txa
	sta sp_player1 + 3

; setup player sprite (2: right-top)
	tya
	sta sp_player2
	lda #$01
	sta sp_player2 + 1
	lda #$00
	sta sp_player2 + 2
	txa
	adc #$08
	sta sp_player2 + 3

; setup player sprite (3: left-bottom)
	tya
	adc #$08
	sta sp_player3
	lda #$02
	sta sp_player3 + 1
	lda #$00
	sta sp_player3 + 2
	txa
	sta sp_player3 + 3

; setup player sprite (4: right-bottom)
	tya
	adc #$08
	sta sp_player4
	lda #$03
	sta sp_player4 + 1
	lda #$00
	sta sp_player4 + 2
	txa
	adc #$08
	sta sp_player4 + 3

; loop infinite
mainloop:
	; clear joy-pad
	lda #$01
	sta $4016
	lda #$00
	sta $4016

moveloop_inputCheck:
	lda $4016	; A
	lda $4016	; B
	lda $4016	; SELECT
	lda $4016	; START
	lda $4016	; UP
	lda $4016	; DOWN
	lda $4016	; LEFT
	and #$01
	bne mainloop_moveLeft
	lda $4016	; RIGHT
	and #$01
	bne mainloop_moveRight
	jmp mainloop_moveEnd

mainloop_moveLeft:
	ldx v_playerX
	cpx #$10
	bcc mainloop_moveEnd ; do not move if x < 16
	dex
	dex
	txa
	sta v_playerX
	sta sp_player1 + 3
	sta sp_player3 + 3
	adc #$07 ; NOTE: 原因不明だが左移動時は+8すると1pxズレるので+7にしておく
	sta sp_player2 + 3
	sta sp_player4 + 3
	jmp mainloop_moveEnd

mainloop_moveRight:
	ldx v_playerX
	cpx #$E0
	bcs mainloop_moveEnd ; do not move if 224 <= x
	inx
	inx
	txa
	sta v_playerX
	sta sp_player1 + 3
	sta sp_player3 + 3
	adc #$08
	sta sp_player2 + 3
	sta sp_player4 + 3

mainloop_moveEnd:

mainloop_sprite_DMA:; WRAM $0300 ~ $03FF -> Sprite
	lda $2002
	bpl mainloop_sprite_DMA
	lda #$3
	sta $4014

	jmp	mainloop
.endproc

palettes:
	; BG
	.byte	$0f, $00, $10, $20
	.byte	$0f, $06, $16, $26
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0a, $1a, $2a
	; Sprite
	.byte	$0f, $00, $10, $20
	.byte	$0f, $06, $16, $26
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0a, $1a, $2a

string_suzuki:
	.byte	"SUZUKI PLAN."

string_presented:
	.byte	"Presented by"

string_copyright:
	.byte	"(C)2018 SUZUKI PLAN."

.org $0000
v_playerX:	.byt	$00
v_playerY:	.byt	$00

.org $0300	;    	Y   	TILE	ATTR	X		  description
sp_player1:	.byt	$00,	$00,	$00,	$00		; player (left-top)
sp_player2:	.byt	$00,	$00,	$00,	$00		; player (right-top)
sp_player3:	.byt	$00,	$00,	$00,	$00		; player (left-bottom)
sp_player4:	.byt	$00,	$00,	$00,	$00		; player (right-bottom)

.segment "VECINFO"
	.word	$0000
	.word	Reset
	.word	$0000

; pattern table
.segment "CHARS"
	.incbin	"stg-bg.chr"
	.incbin	"stg-sprite.chr"
