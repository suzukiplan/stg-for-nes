restart:
; Screen off
    lda #$00
    sta $2000
    sta $2001

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

; write string to the name table (TOP)
    lda #$20
    sta $2006
    lda #$77
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
    lda #$20
    sta $2006
    lda v_hi1000000
    bne draw_top_pts_1000000
    lda v_hi100000
    bne draw_top_pts_100000
    lda v_hi10000
    bne draw_top_pts_10000
    lda v_hi1000
    bne draw_top_pts_1000
    lda v_hi100
    bne draw_top_pts_100
    jmp draw_top_pts_10
draw_top_pts_1000000:
    lda #$b7
    sta $2006
    clc
    adc #$30
    sta $2007
draw_top_pts_100000_start:
    lda v_hi100000
    clc
    adc #$30
    sta $2007
draw_top_pts_10000_start:
    lda v_hi10000
    clc
    adc #$30
    sta $2007
draw_top_pts_1000_start:
    lda v_hi1000
    clc
    adc #$30
    sta $2007
draw_top_pts_100_start:
    lda v_hi100
    clc
    adc #$30
    sta $2007
draw_top_pts_10_start:
    lda v_hi10
    clc
    adc #$30
    sta $2007
    lda #$30
    sta $2007
    jmp draw_top_pts_end
draw_top_pts_100000:
    lda #$b8
    sta $2006
    jmp draw_top_pts_100000_start
draw_top_pts_10000:
    lda #$b9
    sta $2006
    jmp draw_top_pts_10000_start
draw_top_pts_1000:
    lda #$ba
    sta $2006
    jmp draw_top_pts_1000_start
draw_top_pts_100:
    lda #$bb
    sta $2006
    jmp draw_top_pts_100_start
draw_top_pts_10:
    lda #$bc
    sta $2006
    jmp draw_top_pts_10_start
draw_top_pts_end:

; write string to the name table (SCORE)
    lda #$21
    sta $2006
    lda #$37
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
    lda #$21
    sta $2006
    lda #$77
    sta $2006
    ldx #$00
    ldy #$7
draw_score_pts:
    lda string_pts, x
    sta $2007
    inx
    dey
    bne draw_score_pts

    ldx #$00
    lda #$00
clear_sprite_area:
    sta $0300, x
    inx
    bne clear_sprite_area

; setup player variables
    lda #$00
    sta v_gameOver
    sta v_gameOverD
    sta v_level
    sta v_level_cnt
    lda #$08
    sta v_skip_add
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

; setup shot variables
    lda #$00
    sta v_shot_idx
    sta v_shot_ng
    sta v_eshot_idx
    sta v_eshot_ng
    sta v_sc
    sta v_sc + 1
    sta v_sc + 2
    sta v_sc_plus
    sta v_sc10
    sta v_sc100
    sta v_sc1000
    sta v_sc10000
    sta v_sc100000
    sta v_sc1000000
    sta v_hi_update
    sta v_md_cnt
    sta v_md_plus
    ldx #$00
    ldy #$04
    lda #$00
setup_shot_vars:
    sta v_shot0_f, x
    inx
    inx
    inx
    inx
    dey
    bne setup_shot_vars

; setup enemy variables
    lda #$00
    sta v_enemy_idx
    sta v_enemy_xi
    ldx #$00
    ldy #$08
    lda #$00
setup_enemy_vars:
    sta v_enemy0_f, x
    inx
    inx
    inx
    inx
    dey
    bne setup_enemy_vars

; setup enemy shot variables
    ldx #$00
    ldy #$08
    lda #$00
setup_eshot_vars:
    sta v_eshot0_f, x
    inx
    inx
    inx
    inx
    dey
    bne setup_eshot_vars

; setup Stars
    ldx #$00
    ldy #$00
setup_stars:
    tya
    sta v_star0, x
    txa
    lda star_high, y
    sta v_star0 + 1, x
    sta $2006
    lda star_low, y
    sta v_star0 + 2, x
    sta $2006
    lda v_star0, x
    sta $2007
    iny
    txa
    clc
    adc #$04
    and #$0f
    tax
    bne setup_stars

; setup APU
    lda #%00001111
    sta $4015
    sta v_eshot_se

; scroll setting
    lda #$00
    sta $2005
    sta $2005

; screen on
    ; bit7: nmi interrupt
    ; bit6: PPU type (0=master, 1=slave)
    ; bit5: size of sprite (0=8x8, 1=8x16)
    ; bit4: BG chr table (0=$0000, 1=$1000)
    ; bit3: sprite chr table (0=$0000, 1=$1000)
    ; bit2: address addition (0=+1, 1=+32)
    ; bit1~0: main screen (0=$2000, 1=$2400, 2=$2800, 3=$2c00)
    ;     76543210
    lda #%00001000
    sta $2000
    ; bit7: red
    ; bit6: green
    ; bit5: blue
    ; bit4: sprite
    ; bit3: BG
    ; bit2: visible left-top 8x sprite
    ; bit1: visible left-top 8x BG
    ; bit0: color (0=full, 1=mono)
    lda #%00011110
    sta $2001
