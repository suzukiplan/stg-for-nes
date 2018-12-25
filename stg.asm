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

restart:
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
    lda #$b7
    sta $2006
    ldx #$00
    ldy #$7
draw_top_pts:
    lda string_pts, x
    sta $2007
    inx
    dey
    bne draw_top_pts

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

    ldx #$00
    lda #$00
clear_sprite_area:
    sta $0300, x
    inx
    bne clear_sprite_area

; setup player variables
    lda #$00
    sta v_gameOver
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
    sta v_sc10
    sta v_sc100
    sta v_sc1000
    sta v_sc10000
    sta v_sc100000
    sta v_sc1000000
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
    ldy #$10
    lda #$00
setup_eshot_vars:
    sta v_eshot0_f, x
    inx
    inx
    inx
    inx
    dey
    bne setup_eshot_vars

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
    lda v_enemy0_f, x
    bne moveloop_inputCheck ; まだ生きているので登場を抑止
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
    lda v_gameOver
    bne mainloop_gameOver
    jsr sub_movePlayer
    jmp mainloop_gameOver_end

mainloop_gameOver:
    lda $4016   ; A
    lda $4016   ; B 
    lda $4016   ; SELECT
    lda $4016   ; START
    and #$01
    beq mainloop_gameOver_start
    jmp restart

mainloop_gameOver_start:
    lda #%00100001
    sta sp_player1 + 2
    sta sp_player2 + 2
    sta sp_player3 + 2
    sta sp_player4 + 2
    lda v_gameOver
    cmp #$10
    bcs mainloop_gameOver_erasePlayer
    tax
    inx
    stx v_gameOver
    ror
    ror
    and #$03
    clc
    adc #$10
    sta sp_player1 + 1
    adc #$04
    sta sp_player2 + 1
    adc #$04
    sta sp_player3 + 1
    adc #$04
    sta sp_player4 + 1
    jmp mainloop_gameOver_end
mainloop_gameOver_erasePlayer:
    lda #$00
    sta sp_player1 + 1
    sta sp_player2 + 1
    sta sp_player3 + 1
    sta sp_player4 + 1
mainloop_gameOver_end:

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
    and #$80
    bne mainloop_moveEnemy_typeM ; 補数bitが立っている場合はメダル
mainloop_moveEnemy_type1:
    jsr sub_moveEnemy_type1
    and #$01
    beq mainloop_moveEnemy_erase
    jsr sub_moveEnemy_hitCheck
    and #$01
    bne mainloop_moveEnemy_next
mainloop_moveEnemy_toMedal: ; 敵をメダルに変化させる
    jsr sub_changeEnemyToMedal
    jmp mainloop_moveEnemy_next
mainloop_moveEnemy_typeM:
    jsr sub_moveEnemy_typeM
    and #$01
    beq mainloop_moveEnemy_erase
    jmp mainloop_moveEnemy_next
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
mainloop_moveEnemy_end:

    ldx v_eshot_ng
    beq mainloop_moveEShot
    dex
    stx v_eshot_ng
    ldx #$00
mainloop_moveEShot:
    ; check flag
    lda v_eshot0_f, x
    beq mainloop_moveEShot_next
    lda v_eshot0_y, x
    clc
    adc #$05
    bcs mainloop_moveEShot_erase
    ; store Y
    sta v_eshot0_y, x
    sta sp_eshot0, x

    ; 自機との当たり判定
    lda v_gameOver
    bne mainloop_moveEShot_next
    lda v_eshot0_x, x
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいのでeshotXを-16する
    cmp v_playerX
    bcs mainloop_moveEShot_next ; eshotX(a) >= playerX+16 is not hit
    adc #$18
    cmp v_playerX
    bcc mainloop_moveEShot_next ; eshotX+8(a) < playerX is not hit
    lda v_eshot0_y, x
    adc #$EF ; carry が 1 なので #$F0
    cmp v_playerY
    bcs mainloop_moveEShot_next ; eshotY(a) >= playerY+16 is not hit
    adc #$18
    cmp v_playerY
    bcc mainloop_moveEShot_next ; enemyY+8(a) < playerY is not hit
    lda #$01
    sta v_gameOver

mainloop_moveEShot_erase:
    lda #$00
    sta v_eshot0_f, x
    sta sp_eshot0, x
    sta sp_eshot0 + 1, x
    sta sp_eshot0 + 3, x
mainloop_moveEShot_next:
    txa
    clc
    adc #$04
    tax
    and #$3f
    bne mainloop_moveEShot
mainloop_moveEShotEnd:

mainloop_moveBomb:
    lda v_bomb_f
    beq mainloop_moveBomb_end
    ; 描画する爆発パターンを設定: v_bomb_f ÷ 4 + 16 (+0, +4, +8, +12)
    lsr                 ; ÷ 2
    lsr                 ; ÷ 4
    and #$03            ; 念の為 0〜3 になるように調整
    clc
    adc #$10            ; +16
    sta sp_bomb1 + 1    ; 左上のTILEを設定
    adc #$04
    sta sp_bomb3 + 1    ; 左下のTILEを設定
    adc #$04
    sta sp_bomb2 + 1    ; 右上のTILEを設定
    adc #$04
    sta sp_bomb4 + 1    ; 右下のTILEを設定
    ; Y座標を設定 (2フレームに1回Y座標をデクリメント)
    ldx v_bomb_y
    lda v_bomb_f
    and #$01
    bne mainloop_moveBomb_notMoveY
    dex
    stx v_bomb_y
mainloop_moveBomb_notMoveY:
    stx sp_bomb1
    stx sp_bomb3
    txa
    clc
    adc #$08
    tax
    stx sp_bomb2
    stx sp_bomb4
    ; X座標を設定
    ldx v_bomb_x
    stx sp_bomb1 + 3
    stx sp_bomb2 + 3
    txa
    clc
    adc #$08
    tax
    stx sp_bomb3 + 3
    stx sp_bomb4 + 3
    ; 属性を設定
    lda #%00100001
    sta sp_bomb1 + 2
    sta sp_bomb2 + 2
    sta sp_bomb3 + 2
    sta sp_bomb4 + 2
    ; フラグをインクリメントして16になったらクリア
    ldx v_bomb_f
    inx
    txa
    and #$0f
    sta v_bomb_f
    bne mainloop_moveBomb_end
    ; 爆発のスプライトを消す
    lda #$00
    ldx #$00
    ldy #$10
mainloop_moveBomb_eraseLoop:
    sta sp_bomb1, x
    inx
    dey
    bne mainloop_moveBomb_eraseLoop
mainloop_moveBomb_end:

mainloop_sprite_DMA:; WRAM $0300 ~ $03FF -> Sprite
    lda $2002
    bpl mainloop_sprite_DMA ; wait for vBlank
    lda #$3
    sta $4014

    ; ゲームオーバー表示 (５フレーム目にのみ描画)
    lda v_gameOver
    cmp #$05
    bne mainloop_drawScore

    ldy #$09
    ldx #$00
    lda #$21
    sta $2006
    lda #$a7
    sta $2006
mainloop_drawGameOver1:
    lda string_game_over, x
    clc
    adc #$80
    sta $2007
    inx
    dey
    bne mainloop_drawGameOver1

    ldy #$13
    ldx #$00
    lda #$21
    sta $2006
    lda #$e2
    sta $2006
mainloop_drawGameOver2:
    lda string_push_start_to_retry, x
    clc
    adc #$80
    sta $2007
    inx
    dey
    bne mainloop_drawGameOver2
 
    lda #$00
    sta $2005
    sta $2005
    jmp mainloop

mainloop_drawScore:
    ; スコア更新 (描画を伴うのでvBlank中でなければならない)
    ; 負荷軽減のため1フレームにつき最大10加算とする
    ldx v_sc
    beq mainloop_drawScore_end
    jsr sub_addScore10
    dex
    stx v_sc
    lda #$00
    sta $2005
    sta $2005
mainloop_drawScore_end:
    jmp mainloop

;----------------------------------------------------------
; サブルーチン: 自機の操作
; * 全レジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_movePlayer:
    lda $4016   ; A
    and #$01
    bne sub_movePlayer_addNewShot
    ; reset ng flag if not push A
    lda #$00
    sta v_shot_ng
    jmp sub_movePlayer_endFireShot

sub_movePlayer_addNewShot:
    lda v_shot_ng
    bne sub_movePlayer_suppressFireShot
    lda #$20
    sta v_shot_ng

    ldx v_shot_idx

    ; suppress if shot exist yet
    lda v_shot0_f, x
    bne sub_movePlayer_endFireShot

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

sub_movePlayer_suppressFireShot:
    ldx v_shot_ng
    dex
    stx v_shot_ng

sub_movePlayer_endFireShot:
    lda $4016   ; B
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    and #$01
    bne sub_movePlayer_up
    lda $4016   ; DOWN
    and #$01
    bne sub_movePlayer_down
    jmp sub_movePlayer_inputCheck_LR

sub_movePlayer_up:
    lda $4016   ; DOWN (skip)
    ldx v_playerY
    cpx #$28
    bcc sub_movePlayer_inputCheck_LR ; do not move if y < 40
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
    jmp sub_movePlayer_inputCheck_LR

sub_movePlayer_down:
    ldx v_playerY
    cpx #$D8
    bcs sub_movePlayer_inputCheck_LR ; do not move if 216 <= y
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

sub_movePlayer_inputCheck_LR:
    lda $4016   ; LEFT
    and #$01
    bne sub_movePlayer_left
    lda $4016   ; RIGHT
    and #$01
    bne sub_movePlayer_right
    rts

sub_movePlayer_left:
    ldx v_playerX
    cpx #$0a
    bcc sub_movePlayer_end ; do not move if x < 10
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
    rts

sub_movePlayer_right:
    ldx v_playerX
    cpx #$A0
    bcs sub_movePlayer_end ; do not move if 160 <= x
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

sub_movePlayer_end:
    rts

;----------------------------------------------------------
; サブルーチン: 敵アルゴリズム（type1）
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
; * 戻り値: 敵が生存中の場合はa=1を返し、敵を消す場合はa=0を返す
;----------------------------------------------------------
sub_moveEnemy_type1:
    ; 自機のX座標が近い場合はショットを発射する
    lda v_enemy0_x, x
    clc
    adc #$f0 ; 本当は自機Xを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_type1_endFire ; enemyX(a) >= playerX + 16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_type1_endFire ; enemyX(a) + 16 < shotX is not hit
    jsr sub_newEnemyShot
sub_moveEnemy_type1_endFire:
    ; 下に移動
    lda v_enemy0_y, x
    adc #$02
    bcc sub_moveEnemy_type1_alive
    ; 下限に達したので消す
    lda #$00
    rts
sub_moveEnemy_type1_alive:
    ; Y座標を記憶
    sta v_enemy0_y, x
    sta sp_enemy0lb, x
    sta sp_enemy0rb, x
    adc #$f8
    sta sp_enemy0lt, x
    sta sp_enemy0rt, x
    ; フラグにより動作を変える
    lda v_enemy0_i, x
    and #$ff
    beq sub_moveEnemy_type1_downOnly
    and #$01
    bne sub_moveEnemy_type1_right

sub_moveEnemy_type1_left:
    ldy v_enemy0_x, x
    dey
    bcc sub_moveEnemy_type1_left_over ; 負数になったので消す
    tya
    sta v_enemy0_x, x
    sta sp_enemy0lt + 3, x
    sta sp_enemy0lb + 3, x
    clc
    adc #$08
    sta sp_enemy0rt + 3, x
    sta sp_enemy0rb + 3, x
    jmp sub_moveEnemy_hitCheck
sub_moveEnemy_type1_left_over:
    lda #$00
    rts

sub_moveEnemy_type1_downOnly:
    lda v_enemy0_y, x
    cmp #$40
    bcc sub_moveEnemy_type1_downOnly_keep

    lda v_enemy0_x, x
    cmp v_playerX
    bcc sub_moveEnemy_type1_downOnly_toRight
sub_moveEnemy_type1_downOnly_toLeft:
    lda #$02
    sta v_enemy0_i, x
    jmp sub_moveEnemy_type1_hitCheck
sub_moveEnemy_type1_downOnly_toRight:
    lda #$01
    sta v_enemy0_i, x
sub_moveEnemy_type1_downOnly_keep:
    jmp sub_moveEnemy_type1_hitCheck

sub_moveEnemy_type1_right:
    ldy v_enemy0_x, x
    iny
    cpy #$b0
    bcs sub_moveEnemy_type1_right_over ; 176以上なので消す
    tya
    sta v_enemy0_x, x
    sta sp_enemy0lt + 3, x
    sta sp_enemy0lb + 3, x
    adc #$08
    sta sp_enemy0rt + 3, x
    sta sp_enemy0rb + 3, x
    jmp sub_moveEnemy_type1_hitCheck
sub_moveEnemy_type1_right_over:
    lda #$00
    rts

sub_moveEnemy_type1_hitCheck:
    ; 自機との当たり判定
    lda v_gameOver
    bne sub_moveEnemy_type1_noHit ; ゲームオーバーフラグが立っている場合はチェックしない
    lda v_enemy0_x, x
    cmp #$10
    bcs sub_moveEnemy_type1_over16 ; 16以上の時の判定
    ; 16未満の時はxが16以下ならhitとして縦のチェック（xのレンジチェックをskip）
    lda v_playerX
    cmp #$10
    bcs sub_moveEnemy_type1_noHit
    jmp sub_moveEnemy_type1_checkY
sub_moveEnemy_type1_over16:
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_type1_noHit ; enemyX(a) >= playerX+16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_type1_noHit ; enemyX+16(a) < playerX is not hit
sub_moveEnemy_type1_checkY:
    lda v_enemy0_y, x
    clc
    adc #$E8 ; 敵のYは+8から始まるので-8しつつplayerY+16としたいので更に-16
    cmp v_playerY
    bcs sub_moveEnemy_type1_noHit ; enemyY-8(a) >= playerY+16 is not hit
    adc #$28
    cmp v_playerY
    bcc sub_moveEnemy_type1_noHit ; enemyY+16(a) < playerY is not hit

    ; 衝突したのでgame overにする
    lda #$01
    sta v_gameOver

sub_moveEnemy_type1_noHit:
    lda #$01
    rts

;----------------------------------------------------------
; サブルーチン: 敵をメダルに変化させる
; * xレジスタ: 敵機(メダル)のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_changeEnemyToMedal:
    lda #$80
    sta v_enemy0_f, x
    lda #$fe
    sta v_enemy0_i, x
    lda #$20
    sta sp_enemy0lt + 1, x
    lda #$24
    sta sp_enemy0rt + 1, x
    lda #$28
    sta sp_enemy0lb + 1, x
    lda #$2c
    sta sp_enemy0rb + 1, x
    lda #%00100010
    sta sp_enemy0lt + 2, x
    sta sp_enemy0rt + 2, x
    sta sp_enemy0lb + 2, x
    sta sp_enemy0rb + 2, x
    rts

;----------------------------------------------------------
; サブルーチン: メダル (敵の構造体とスプライトを流用)
; * xレジスタ: 敵機(メダル)のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
; * 戻り値: 敵が生存中の場合はa=1を返し、敵を消す場合はa=0を返す
;----------------------------------------------------------
sub_moveEnemy_typeM:
    ; Y座標をiで加算
    lda v_enemy0_y, x
    clc
    adc v_enemy0_i, x
    cmp #$f6
    bcc sub_moveEnemy_typeM_alive ; 加算後のYが$f6未満なら生存中としておく
    lda #$00
    rts
sub_moveEnemy_typeM_alive:
    sta v_enemy0_y, x
    sta sp_enemy0lb, x
    sta sp_enemy0rb, x
    clc
    adc #$f8
    sta sp_enemy0lt, x
    sta sp_enemy0rt, x

    ; 自機との当たり判定
    lda v_gameOver
    bne sub_moveEnemy_typeM_noHit ; ゲームオーバーフラグが立っている場合はチェックしない
    lda v_enemy0_x, x
    cmp #$10
    bcs sub_moveEnemy_typeM_over16 ; 16以上の時の判定
    ; 16未満の時はxが16以下ならhitとして縦のチェック（xのレンジチェックをskip）
    lda v_playerX
    cmp #$10
    bcs sub_moveEnemy_typeM_noHit
    jmp sub_moveEnemy_typeM_checkY
sub_moveEnemy_typeM_over16:
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_typeM_noHit ; enemyX(a) >= playerX+16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_typeM_noHit ; enemyX+16(a) < playerX is not hit
sub_moveEnemy_typeM_checkY:
    lda v_enemy0_y, x
    clc
    adc #$E8 ; 敵のYは+8から始まるので-8しつつplayerY+16としたいので更に-16
    cmp v_playerY
    bcs sub_moveEnemy_typeM_noHit ; enemyY-8(a) >= playerY+16 is not hit
    adc #$28
    cmp v_playerY
    bcc sub_moveEnemy_typeM_noHit ; enemyY+16(a) < playerY is not hit

    ; 衝突したので消す
    lda v_sc
    clc
    adc #$0a
    sta v_sc
    lda #$00
    rts

sub_moveEnemy_typeM_noHit:
    ; フラグの下位bitをインクリメント
    lda v_enemy0_f, x
    clc
    adc #$01
    and #$0f
    bne sub_moveEnemy_typeM_notInc
    ; 16フレームに1回落下速度を上げる
    lda v_enemy0_i, x
    cmp #$03
    beq sub_moveEnemy_typeM_notInc ; 落下速度3以上ならもうこれ以上早くしない
    clc
    adc #$01
    sta v_enemy0_i, x
    lda #$00
sub_moveEnemy_typeM_notInc:
    ; 回転させる
    pha
    ror
    ror
    and #$03
    clc
    adc #$20
    sta sp_enemy0lt + 1, x
    adc #$04
    sta sp_enemy0rt + 1, x
    adc #$04
    sta sp_enemy0lb + 1, x
    adc #$04
    sta sp_enemy0rb + 1, x
    pla
    ora #$80
    sta v_enemy0_f, x
    lda #$01
    rts

;----------------------------------------------------------
; サブルーチン: 敵ショット追加
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_newEnemyShot:
    lda v_eshot_ng
    bne sub_newEnemyShot_end ; 発射禁止中
    ldy v_eshot_idx
    lda v_eshot0_f, y
    bne sub_newEnemyShot_end ; 発射上限に達しているので禁止しておく
    ; インデックスを加算しておく
    tya
    clc
    adc #$04
    and #$3f
    sta v_eshot_idx
    ; フラグを設定
    lda #$01 ; 弾の種類を増やす場合はココの値を2とかにする
    sta v_eshot0_f, y
    ; X座標を設定
    lda v_enemy0_x, x
    clc
    adc #$04
    sta v_eshot0_x, y
    sta sp_eshot0 + 3, y
    ; Y座標を設定
    lda v_enemy0_y, x
    sta v_eshot0_y, y
    sta sp_eshot0, y
    ; 変数を初期化
    lda #$00
    sta v_eshot0_i, y
    ; TILEを設定
    lda #$0a
    sta sp_eshot0 + 1, y
    ; ATTRを設定
    lda #%00100010
    sta sp_eshot0 + 2, y
    ; 7フレームの間、新規ショットを発射禁止にする
    lda #$07
    sta v_eshot_ng
sub_newEnemyShot_end:
    rts

;----------------------------------------------------------
; サブルーチン: 敵機との当たり判定
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * yレジスタ: 自機ショットのindexとして使う
; * aレジスタ: 自機ショットに敵機がヒットしなかった場合1, ヒットした場合0 でリターン
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
    ; 現在の敵座標位置から爆発を描画
    lda #$01
    sta v_bomb_f
    lda v_enemy0_x, x
    sta v_bomb_x
    lda v_enemy0_y, x
    clc
    adc #$f8
    sta v_bomb_y
    ; スコアを+30点加算
    lda v_sc
    clc
    adc #$03
    sta v_sc
    ; 自機ショットを消滅させつつ, a = 0 でリターン
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

;----------------------------------------------------------
; サブルーチン: スコアを加算+描画
; * xレジスタ: unused (このサブルーチン内では使わない)
; * yレジスタ: unused (このサブルーチン内では使わない)
; * aレジスタ: 計算用のワーク
;----------------------------------------------------------
sub_addScore10:
    lda v_sc10
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore10_display
    jsr sub_addScore100
    lda #$00
sub_addScore10_display:
    sta v_sc10
    lda #$21
    sta $2006
    lda #$7c
    sta $2006
    lda v_sc10
    clc
    adc #$30
    sta $2007
    rts

sub_addScore100:
    lda v_sc100
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore100_display
    jsr sub_addScore1000
    lda #$00
sub_addScore100_display:
    sta v_sc100
    lda #$21
    sta $2006
    lda #$7b
    sta $2006
    lda v_sc100
    clc
    adc #$30
    sta $2007
    rts

sub_addScore1000:
    lda v_sc1000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore1000_display
    jsr sub_addScore10000
    lda #$00
sub_addScore1000_display:
    sta v_sc1000
    lda #$21
    sta $2006
    lda #$7a
    sta $2006
    lda v_sc1000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore10000:
    lda v_sc10000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore10000_display
    jsr sub_addScore100000
    lda #$00
sub_addScore10000_display:
    sta v_sc10000
    lda #$21
    sta $2006
    lda #$79
    sta $2006
    lda v_sc10000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore100000:
    lda v_sc100000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore100000_display
    jsr sub_addScore1000000
    lda #$00
sub_addScore100000_display:
    sta v_sc100000
    lda #$21
    sta $2006
    lda #$78
    sta $2006
    lda v_sc100000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore1000000:
    lda v_sc1000000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore1000000_display
    rts
sub_addScore1000000_display:
    sta v_sc1000000
    lda #$21
    sta $2006
    lda #$77
    sta $2006
    lda v_sc1000000
    clc
    adc #$30
    sta $2007
    rts

.endproc

palettes:
    ; BG
    .byte   $0f, $00, $10, $20 ; Main領域のBGパレット
    .byte   $0f, $06, $16, $26
    .byte   $0f, $08, $18, $28
    .byte   $0c, $0c, $00, $30 ; Window領域のBGパレット
    ; Sprite
    .byte   $0f, $00, $10, $20 ; 自機 (mask, 暗い灰色, 灰色, 白)
    .byte   $0f, $06, $28, $20 ; 爆発 (mask, 赤, 黄, 白)
    .byte   $0f, $28, $11, $30 ; 敵弾, ボーナス (mask, 黄色, 青, 白)
    .byte   $0f, $0a, $1a, $2a ; 敵 (mask, 暗い緑, 緑, 明るい緑)

enemy_x_table:; $08〜$B0
    .byte   $08, $18, $38, $B0, $A0, $80, $50, $20
    .byte   $16, $1a, $24, $30, $B0, $A9, $95, $8f

string_score:
    .byte   "SCORE"

string_top:
    .byte   "TOP"

string_pts:
    .byte   "     00"

string_game_over:
    .byte   "GAME OVER"

string_push_start_to_retry:
    .byte   "PUSH START TO RETRY"

.org $0000
v_gameOver: .byte   $00     ; ゲームオーバーカウンタ
v_playerX:  .byte   $00     ; 自機のX座標
v_playerY:  .byte   $00     ; 自機のY座標
v_shot_idx: .byte   $00     ; ショットのindex
v_shot_ng:  .byte   $00     ; ショットの発射禁止フラグ (0の時のみ発射許可)
v_counter:  .byte   $00     ; tick counter
v_enemy_idx:.byte   $00     ; 敵のindex
v_enemy_xi: .byte   $00     ; 敵の出現位置のindex
v_bomb_f:   .byte   $00     ; 爆発フラグ (#$00〜#$0F)
v_bomb_x:   .byte   $00     ; 爆発のX座標
v_bomb_y:   .byte   $00     ; 爆発のY座標
v_eshot_idx:.byte   $00     ; 敵ショットのindex
v_eshot_ng: .byte   $00     ; 敵ショットの発射禁止フラグ (0の時のみ発射許可)
v_sc:       .byte   $00     ; 1フレームあたりのスコア加算回数
v_sc10:     .byte   $00     ; スコア(10の位)
v_sc100:    .byte   $00     ; スコア(100の位)
v_sc1000:   .byte   $00     ; スコア(1000の位)
v_sc10000:  .byte   $00     ; スコア(10000の位)
v_sc100000: .byte   $00     ; スコア(100000の位)
v_sc1000000:.byte   $00     ; スコア(1000000の位)

.org $0400
v_shot0_f:  .byte   $00     ; ショットの生存フラグ
v_shot0_x:  .byte   $00     ; ショットのX座標
v_shot0_y:  .byte   $00     ; ショットのY座標
v_shot0_i:  .byte   $00     ; 未使用 (バウンダリ)
v_shot1:    .byte   $00, $00, $00, $00
v_shot2:    .byte   $00, $00, $00, $00
v_shot3:    .byte   $00, $00, $00, $00

v_eshot0_f: .byte   $00     ; 敵ショットの生存フラグ
v_eshot0_x: .byte   $00     ; 敵ショットのX座標
v_eshot0_y: .byte   $00     ; 敵ショットのY座標
v_eshot0_i: .byte   $00     ; 敵未使用 (バウンダリ)
v_eshot1:   .byte   $00, $00, $00, $00
v_eshot2:   .byte   $00, $00, $00, $00
v_eshot3:   .byte   $00, $00, $00, $00
v_eshot4:   .byte   $00, $00, $00, $00
v_eshot5:   .byte   $00, $00, $00, $00
v_eshot6:   .byte   $00, $00, $00, $00
v_eshot7:   .byte   $00, $00, $00, $00
v_eshot8:   .byte   $00, $00, $00, $00
v_eshot9:   .byte   $00, $00, $00, $00
v_eshotA:   .byte   $00, $00, $00, $00
v_eshotB:   .byte   $00, $00, $00, $00
v_eshotC:   .byte   $00, $00, $00, $00
v_eshotD:   .byte   $00, $00, $00, $00
v_eshotE:   .byte   $00, $00, $00, $00
v_eshotF:   .byte   $00, $00, $00, $00

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
sp_bomb1:   .byte   $00,    $00,    $00,    $00     ; 41: bomb (left-top)
sp_bomb2:   .byte   $00,    $00,    $00,    $00     ; 42: bomb (right-top)
sp_bomb3:   .byte   $00,    $00,    $00,    $00     ; 43: bomb (left-bottom)
sp_bomb4:   .byte   $00,    $00,    $00,    $00     ; 44: bomb (right-bottom)
sp_eshot0:  .byte   $00,    $00,    $00,    $00     ; 45: enemy shot (0)
sp_eshot1:  .byte   $00,    $00,    $00,    $00     ; 46: enemy shot (1)
sp_eshot2:  .byte   $00,    $00,    $00,    $00     ; 47: enemy shot (2)
sp_eshot3:  .byte   $00,    $00,    $00,    $00     ; 48: enemy shot (3)
sp_eshot4:  .byte   $00,    $00,    $00,    $00     ; 49: enemy shot (4)
sp_eshot5:  .byte   $00,    $00,    $00,    $00     ; 50: enemy shot (5)
sp_eshot6:  .byte   $00,    $00,    $00,    $00     ; 51: enemy shot (6)
sp_eshot7:  .byte   $00,    $00,    $00,    $00     ; 52: enemy shot (7)
sp_eshot8:  .byte   $00,    $00,    $00,    $00     ; 53: enemy shot (8)
sp_eshot9:  .byte   $00,    $00,    $00,    $00     ; 54: enemy shot (9)
sp_eshotA:  .byte   $00,    $00,    $00,    $00     ; 55: enemy shot (10)
sp_eshotB:  .byte   $00,    $00,    $00,    $00     ; 56: enemy shot (11)
sp_eshotC:  .byte   $00,    $00,    $00,    $00     ; 57: enemy shot (12)
sp_eshotD:  .byte   $00,    $00,    $00,    $00     ; 58: enemy shot (13)
sp_eshotE:  .byte   $00,    $00,    $00,    $00     ; 59: enemy shot (14)
sp_eshotF:  .byte   $00,    $00,    $00,    $00     ; 60: enemy shot (15)

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "stg-bg.chr"
    .incbin "stg-sprite.chr"
