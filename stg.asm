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

; setup shot variables
    lda #$00
    sta v_shot_idx
    sta v_shot_ng
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

; loop infinite
mainloop:
    ; clear joy-pad
    lda #$01
    sta $4016
    lda #$00
    sta $4016

    ; increment counter
    ldx v_counter
    inx
    stx v_counter

    ; 16フレームに1回敵キャラを出現させる
    txa
    and #$0f
    bne moveloop_inputCheck

mainloop_addNewEnemy:
    ldx v_enemy_idx
    lda #$01 ; TODO: 暫定的に同じ種類の敵だけ出現させている
    sta v_enemy0_f, x
    lda #$00
    sta v_enemy0_i, x
    ; X座標 (enemy_x_tableから持ってくる)
    ldy v_enemy_xi
    iny
    tya
    and #$0f
    sta v_enemy_xi
    tay
    lda enemy_x_table, y
    sta v_enemy0_x, x
    ; Y座標は0だがこれは下半分のオブジェクトのY座標（上半分は-8）
    lda #$00
    sta v_enemy0_y, x

    ; Y of sprites
    sta sp_enemy0lb, x
    sta sp_enemy0rb, x
    clc
    adc #$F8
    sta sp_enemy0lt, x
    sta sp_enemy0rt, x

    ; TILE of sprites
    lda #$06
    sta sp_enemy0lt + 1, x
    lda #$07
    sta sp_enemy0rt + 1, x
    lda #$08
    sta sp_enemy0lb + 1, x
    lda #$09
    sta sp_enemy0rb + 1, x

    ; ATTR of sprites
    lda #%00100011
    sta sp_enemy0lt + 2, x
    sta sp_enemy0rt + 2, x
    sta sp_enemy0lb + 2, x
    sta sp_enemy0rb + 2, x

    ; X of sprites
    lda v_enemy0_x, x
    sta sp_enemy0lt + 3, x
    sta sp_enemy0lb + 3, x
    adc #$08
    sta sp_enemy0rt + 3, x
    sta sp_enemy0rb + 3, x

    ; increment index
    txa
    clc
    adc #$04
    and #$1f
    sta v_enemy_idx

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
    beq mainloop_moveShot_next
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

mainloop_moveShotEnd:

    ldx #$00
mainloop_moveEnemy:
    ; check flag
    lda v_enemy0_f, x
    beq mainloop_moveEnemy_next
    ; TODO: とりあえず全部同じ敵キャラとして動かしておく
    ; v_enemy0_f の値を見て敵の種別毎に異なる動きをするようにしたい
    ; 残敵的に単純に上から下へ降りてくるだけ（もっと複雑な動きにしたい）
    ; 恐らく敵の種類毎にサブルーチン化する必用がある
    lda v_enemy0_y, x
    adc #$02
    bcs mainloop_moveEnemy_erase
    sta v_enemy0_y, x
    sta sp_enemy0lb, x
    sta sp_enemy0rb, x
    adc #$f8
    sta sp_enemy0lt, x
    sta sp_enemy0rt, x
    jsr sub_moveEnemy_hitCheck
    and #$01
    bne mainloop_moveEnemy_next
    ; jmp mainloop_moveEnemy_erase

mainloop_moveEnemy_erase:
    lda #$00
    sta v_enemy0_f, x
    sta sp_enemy0lt, x
    sta sp_enemy0lt + 1, x
    sta sp_enemy0lt + 3, x
    sta sp_enemy0rt, x
    sta sp_enemy0rt + 1, x
    sta sp_enemy0rt + 3, x
    sta sp_enemy0lb, x
    sta sp_enemy0lb + 1, x
    sta sp_enemy0lb + 3, x
    sta sp_enemy0rb, x
    sta sp_enemy0rb + 1, x
    sta sp_enemy0rb + 3, x

mainloop_moveEnemy_next:
    txa
    clc
    adc #$04
    and #$1f
    tax
    bne mainloop_moveEnemy

mainloop_sprite_DMA:; WRAM $0300 ~ $03FF -> Sprite
    lda $2002
    bpl mainloop_sprite_DMA ; wait for vBlank
    lda #$3
    sta $4014
    jmp mainloop

;----------------------------------------------------------
; サブルーチン: 敵機と自機ショットの当たり判定
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * yレジスタ: 自機ショットのindexとして使う
; * aレジスタ: ヒットしなかった場合1, ヒットした場合0 でリターン
;----------------------------------------------------------
sub_moveEnemy_hitCheck:
    ldy #$00
sub_moveEnemy_hitCheck_loop:
    lda v_shot0_f, y
    beq sub_moveEnemy_hitCheck_next
    lda v_enemy0_x, x
    clc
    adc #$fc ; 本当はshotXを+4したいが難しいので敵Xを-4する
    cmp v_shot0_x, y
    bcs sub_moveEnemy_hitCheck_next ; enemyX(a) >= shotX + 4 is not hit
    adc #$10
    cmp v_shot0_x, y
    bcc sub_moveEnemy_hitCheck_next ; enemyX+16(a) < shotX + 4 is not hit
    lda v_enemy0_y, x
    adc #$F3 ; carry が 1 なので #$F4 (本当は-8すべきだが-12にすることでshotY+4で判定)
    cmp v_shot0_y, y
    bcs sub_moveEnemy_hitCheck_next ; enemyY-8(a) >= shotY + 4 is not hit
    adc #$10
    cmp v_shot0_y, y
    bcc sub_moveEnemy_hitCheck_next ; enemyY+8(a) < shotY + 4 is not hit
    ; ヒットした (自機ショットを消滅させつつ, a = 0 でリターン)
    lda #$00
    sta v_shot0_f, y
    sta sp_shot0, y
    sta sp_shot0 + 1, y
    sta sp_shot0 + 3, y
    rts
sub_moveEnemy_hitCheck_next:
    tya
    clc
    adc #$04
    tay
    and #$0f
    bne sub_moveEnemy_hitCheck_loop
    ; TODO: 敵の爆破アニメーションの開始指示をするならココがベスト
    lda #$01 ; a = 1 でリターン（ヒットしなかった）
    rts

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

enemy_x_table:; $08〜$B0
    .byte   $08, $18, $38, $B0, $A0, $80, $50, $20
    .byte   $16, $1a, $24, $30, $B0, $A9, $95, $8f

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
v_counter:  .byte   $00     ; tick counter
v_enemy_idx:.byte   $00     ; 敵のindex
v_enemy_xi: .byte   $00     ; 敵の出現位置のindex

.org $0400
v_shot0_f:  .byte   $00     ; ショットの生存フラグ
v_shot0_x:  .byte   $00     ; ショットのX座標
v_shot0_y:  .byte   $00     ; ショットのY座標
v_shot0_i:  .byte   $00     ; 未使用 (バウンダリ)
v_shot1:    .byte   $00, $00, $00, $00
v_shot2:    .byte   $00, $00, $00, $00
v_shot3:    .byte   $00, $00, $00, $00

v_enemy0_f: .byte   $00     ; 敵の生存フラグ（兼種別判定フラグ）
v_enemy0_x: .byte   $00     ; 敵のX座標
v_enemy0_y: .byte   $00     ; 敵のY座標
v_enemy0_i: .byte   $00     ; 敵の汎用変数
v_enemy1:   .byte   $00, $00, $00, $00
v_enemy2:   .byte   $00, $00, $00, $00
v_enemy3:   .byte   $00, $00, $00, $00
v_enemy4:   .byte   $00, $00, $00, $00
v_enemy5:   .byte   $00, $00, $00, $00
v_enemy6:   .byte   $00, $00, $00, $00
v_enemy7:   .byte   $00, $00, $00, $00

.org $0300  ;       Y       TILE    ATTR    X         No: description
sp_player1: .byte   $00,    $00,    $00,    $00     ; 01: player (left-top)
sp_player2: .byte   $00,    $00,    $00,    $00     ; 02: player (right-top)
sp_player3: .byte   $00,    $00,    $00,    $00     ; 03: player (left-bottom)
sp_player4: .byte   $00,    $00,    $00,    $00     ; 04: player (right-bottom)
sp_shot0:   .byte   $00,    $00,    $00,    $00     ; 05: shot (0)
sp_shot1:   .byte   $00,    $00,    $00,    $00     ; 06: shot (1)
sp_shot2:   .byte   $00,    $00,    $00,    $00     ; 07: shot (2)
sp_shot3:   .byte   $00,    $00,    $00,    $00     ; 08: shot (3)
sp_enemy0lt:.byte   $00,    $00,    $00,    $00     ; 09: enemy (0) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 10: enemy (1) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 11: enemy (2) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 12: enemy (3) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 13: enemy (4) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 14: enemy (5) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 15: enemy (6) (left-top)
            .byte   $00,    $00,    $00,    $00     ; 16: enemy (7) (left-top)
sp_enemy0rt:.byte   $00,    $00,    $00,    $00     ; 17: enemy (0) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 18: enemy (1) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 19: enemy (2) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 20: enemy (3) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 21: enemy (4) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 22: enemy (5) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 23: enemy (6) (right-top)
            .byte   $00,    $00,    $00,    $00     ; 24: enemy (7) (right-top)
sp_enemy0lb:.byte   $00,    $00,    $00,    $00     ; 25: enemy (0) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 26: enemy (1) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 27: enemy (2) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 28: enemy (3) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 29: enemy (4) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 30: enemy (5) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 31: enemy (6) (left-bottom)
            .byte   $00,    $00,    $00,    $00     ; 32: enemy (7) (left-bottom)
sp_enemy0rb:.byte   $00,    $00,    $00,    $00     ; 33: enemy (0) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 34: enemy (1) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 35: enemy (2) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 36: enemy (3) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 37: enemy (4) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 38: enemy (5) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 39: enemy (6) (right-bottom)
            .byte   $00,    $00,    $00,    $00     ; 40: enemy (7) (right-bottom)

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "stg-bg.chr"
    .incbin "stg-sprite.chr"
