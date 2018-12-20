.setcpu     "6502"
.autoimport on

; iNES header
.segment "HEADER"
    .byte   $4E, $45, $53, $1A  ; "NES" Header
    .byte   $02                 ; PRG-BANKS
    .byte   $01                 ; CHR-BANKS
    .byte   $01                 ; Vertical Mirror
    .byte   $00                 ; 
    .byte   $00, $00, $00, $00  ; 
    .byte   $00, $00, $00, $00  ; 

.segment "STARTUP"
.proc Reset
    sei
    ldx #$ff
    txs

; Screen off
    lda #$00
    sta $2000
    sta $2001

; make palette table
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
    ldy #$20
copy_pal:
    lda palettes, x
    sta $2007
    inx
    dey
    bne copy_pal

; clear name table (fill name table: pattern 00)
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldy #$00
    lda #$00
    ldx #$04
clear_name_table:
    sta $2007
    iny
    bne clear_name_table
    dex
    bne clear_name_table

; initialize palette of name table
; 00000000 - 00000000 - 00000033 - 33333333 (0~175: game area, 176~255: window area)
    lda #$23
    sta $2006
    lda #$c0
    sta $2006
    ldy #$08
init_name_palettes:
    lda #%00000000
    sta $2007
    lda #%00000000
    sta $2007
    lda #%00000000
    sta $2007
    lda #%00000000
    sta $2007
    lda #%00000000
    sta $2007
    lda #%11001100
    sta $2007
    lda #%11111111
    sta $2007
    lda #%11111111
    sta $2007
    dey
    bne init_name_palettes

; make window area to the space
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldy #$1e
make_window:
    ldx #$16
    lda #$00
make_windowL:
    sta $2007
    dex
    bne make_windowL
    ldx #$0a
    lda #$20
make_windowR:
    sta $2007
    dex
    bne make_windowR
    dey
    bne make_window

; write string to the name table (SCORE)
    lda #$20
    sta $2006
    lda #$57
    sta $2006
    ldx #$00
    ldy #$5
draw_score:
    lda string_score, x
    sta $2007
    inx
    dey
    bne draw_score

; write string to the name table (SCORE-PTS)
    lda #$20
    sta $2006
    lda #$97
    sta $2006
    ldx #$00
    ldy #$7
draw_score_pts:
    lda string_pts, x
    sta $2007
    inx
    dey
    bne draw_score_pts

; write string to the name table (TOP)
    lda #$21
    sta $2006
    lda #$17
    sta $2006
    ldx #$00
    ldy #$3
draw_top:
    lda string_top, x
    sta $2007
    inx
    dey
    bne draw_top

; write string to the name table (TOP-PTS)
    lda #$21
    sta $2006
    lda #$57
    sta $2006
    ldx #$00
    ldy #$7
draw_top_pts:
    lda string_pts, x
    sta $2007
    inx
    dey
    bne draw_top_pts

; scroll setting
    lda #$00
    sta $2005
    sta $2005

; screen on
    lda #$08
    sta $2000
    lda #$1e
    sta $2001

; drawing sprite pattern table address
    lda #$00
    sta $2003

    ldx #$00
    lda #$00
clear_sprite_area:
    sta $0300, x
    inx
    bne clear_sprite_area


; setup player variables
    lda #$50
    sta v_playerX
    tax
    lda #$d0
    sta v_playerY
    tay

; setup player sprite (1: left-top)
    tya
    sta sp_player1
    lda #$01
    sta sp_player1 + 1
    lda #%00100000
    sta sp_player1 + 2
    txa
    sta sp_player1 + 3

; setup player sprite (2: right-top)
    tya
    sta sp_player2
    lda #$02
    sta sp_player2 + 1
    lda #%00100000
    sta sp_player2 + 2
    txa
    clc
    adc #$08
    sta sp_player2 + 3

; setup player sprite (3: left-bottom)
    tya
    clc
    adc #$08
    sta sp_player3
    lda #$03
    sta sp_player3 + 1
    lda #%00100000
    sta sp_player3 + 2
    txa
    sta sp_player3 + 3

; setup player sprite (4: right-bottom)
    tya
    clc
    adc #$08
    sta sp_player4
    lda #$04
    sta sp_player4 + 1
    lda #%00100000
    sta sp_player4 + 2
    txa
    clc
    adc #$08
    sta sp_player4 + 3

; setup shot sprites & variables
    lda #$00
    sta v_shot_idx
    sta v_shot_ng
    ldx #$00
    ldy #$04
setup_shot_sprites:
    lda #$00
    sta v_shot0_f, x
    sta sp_shot0, x
    sta sp_shot0 + 3, x
    lda #$04
    sta sp_shot0 + 1, x
    lda #%00100000
    sta sp_shot0 + 2, x
    txa
    clc
    adc #$04
    tax
    dey
    bne setup_shot_sprites

; loop infinite
mainloop:
    ; clear joy-pad
    lda #$01
    sta $4016
    lda #$00
    sta $4016

moveloop_inputCheck:
    lda $4016   ; A
    and #$01
    bne mainloop_addNewShot
    ; reset ng flag if not push A
    lda #$00
    sta v_shot_ng
    jmp mainloop_endFireShot

mainloop_addNewShot:
    lda v_shot_ng
    bne mainloop_suppressFireShot
    lda #$20
    sta v_shot_ng

    ldx v_shot_idx

    ; suppress if shot exist yet
    lda v_shot0_f, x
    bne mainloop_endFireShot

    lda #$01
    sta v_shot0_f, x
    lda v_playerX
    clc
    adc #$04
    sta v_shot0_x, x
    lda v_playerY
    adc #$FF
    sta v_shot0_y, x

    ; initialize sprite of shot
    sta sp_shot0, x
    lda #$05
    sta sp_shot0 + 1, x
    lda #%00100000
    sta sp_shot0 + 2, x
    lda v_shot0_x, x
    sta sp_shot0 + 3, x

    txa
    clc
    adc #$04
    and #$0f
    sta v_shot_idx

mainloop_suppressFireShot:
    ldx v_shot_ng
    dex
    stx v_shot_ng

mainloop_endFireShot:
    lda $4016   ; B
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    and #$01
    bne mainloop_moveUp
    lda $4016   ; DOWN
    and #$01
    bne mainloop_moveDown
    jmp mainloop_inputCheck_LR

mainloop_moveUp:
    lda $4016   ; DOWN (skip)
    ldx v_playerY
    cpx #$28
    bcc mainloop_inputCheck_LR ; do not move if y < 40
    dex
    dex
    txa
    sta v_playerY
    sta sp_player1
    sta sp_player2
    clc
    adc #$08
    sta sp_player3
    sta sp_player4
    jmp mainloop_inputCheck_LR

mainloop_moveDown:
    ldx v_playerY
    cpx #$D8
    bcs mainloop_moveEnd ; do not move if 216 <= y
    inx
    inx
    txa
    sta v_playerY
    sta sp_player1
    sta sp_player2
    clc
    adc #$08
    sta sp_player3
    sta sp_player4

mainloop_inputCheck_LR:
    lda $4016   ; LEFT
    and #$01
    bne mainloop_moveLeft
    lda $4016   ; RIGHT
    and #$01
    bne mainloop_moveRight
    jmp mainloop_moveEnd

mainloop_moveLeft:
    ldx v_playerX
    cpx #$0a
    bcc mainloop_moveEnd ; do not move if x < 10
    dex
    dex
    txa
    sta v_playerX
    sta sp_player1 + 3
    sta sp_player3 + 3
    clc
    adc #$08
    sta sp_player2 + 3
    sta sp_player4 + 3
    jmp mainloop_moveEnd

mainloop_moveRight:
    ldx v_playerX
    cpx #$A0
    bcs mainloop_moveEnd ; do not move if 160 <= x
    inx
    inx
    txa
    sta v_playerX
    sta sp_player1 + 3
    sta sp_player3 + 3
    clc
    adc #$08
    sta sp_player2 + 3
    sta sp_player4 + 3

mainloop_moveEnd:

    ldx #$00
mainloop_moveShot:
    ; check flag
    lda v_shot0_f, x
    beq mainloop_moveShot_erase
    lda v_shot0_y, x
    clc
    adc #$FA
    cmp #$f8
    bcs mainloop_moveShot_erase
    ; store Y
    sta v_shot0_y, x
    sta sp_shot0, x
    jmp mainloop_moveShot_next
mainloop_moveShot_erase:
    lda #$00
    sta v_shot0_f, x
    sta sp_shot0, x
    sta sp_shot0 + 1, x
    sta sp_shot0 + 3, x
mainloop_moveShot_next:
    txa
    clc
    adc #$04
    tax
    and #$0f
    bne mainloop_moveShot

mainloop_sprite_DMA:; WRAM $0300 ~ $03FF -> Sprite
    lda $2002
    bpl mainloop_sprite_DMA ; wait for vBlank
    lda #$3
    sta $4014
    jmp mainloop
.endproc

palettes:
    ; BG
    .byte   $0f, $00, $10, $20 ; Main領域のBGパレット
    .byte   $0f, $06, $16, $26
    .byte   $0f, $08, $18, $28
    .byte   $0c, $0c, $00, $30 ; Window領域のBGパレット
    ; Sprite
    .byte   $0f, $00, $10, $20
    .byte   $0f, $06, $16, $26
    .byte   $0f, $08, $18, $28
    .byte   $0f, $0a, $1a, $2a

string_score:
    .byte   "SCORE"

string_top:
    .byte   "TOP"

string_pts:
    .byte   "     00"

.org $0000
v_playerX:  .byte   $00     ; 自機のX座標
v_playerY:  .byte   $00     ; 自機のY座標
v_shot_idx: .byte   $00     ; ショットのindex
v_shot_ng:  .byte   $00     ; ショットの発射禁止フラグ (0の時のみ発射許可)

v_shot0_f:  .byte   $00     ; ショットの生存フラグ
v_shot0_x:  .byte   $00     ; ショットのX座標
v_shot0_y:  .byte   $00     ; ショットのY座標
v_shot0_i:  .byte   $00     ; 未使用 (バウンダリ)
v_shot1:    .byte   $00, $00, $00, $00
v_shot2:    .byte   $00, $00, $00, $00
v_shot3:    .byte   $00, $00, $00, $00

.org $0300  ;       Y       TILE    ATTR    X         description
sp_player1: .byte   $00,    $00,    $00,    $00     ; player (left-top)
sp_player2: .byte   $00,    $00,    $00,    $00     ; player (right-top)
sp_player3: .byte   $00,    $00,    $00,    $00     ; player (left-bottom)
sp_player4: .byte   $00,    $00,    $00,    $00     ; player (right-bottom)
sp_shot0:   .byte   $00,    $00,    $00,    $00     ; shot (0)
sp_shot1:   .byte   $00,    $00,    $00,    $00     ; shot (1)
sp_shot2:   .byte   $00,    $00,    $00,    $00     ; shot (2)
sp_shot3:   .byte   $00,    $00,    $00,    $00     ; shot (3)

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "stg-bg.chr"
    .incbin "stg-sprite.chr"
