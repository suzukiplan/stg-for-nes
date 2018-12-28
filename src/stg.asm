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

    ; ハイスコアの初期値（再スタートしても消えない変数を初期化）
    lda #$03
    sta v_hi10
    lda #$07
    sta v_hi100
    lda #$05
    sta v_hi1000
    lda #$00
    sta v_hi10000
    sta v_hi100000
    sta v_hi1000000
    lda #$3d
    sta v_hi
    lda #$02
    sta v_hi + 1
    lda #$00
    sta v_hi + 2

.include "stg-00title.asm"
.include "stg-01setup.asm"
.include "stg-02mainloop.asm"
.include "stg-movePlayer.asm"
.include "stg-moveEnemy_type1.asm"
.include "stg-moveEnemy_type2.asm"
.include "stg-moveEnemy_typeM.asm"
.include "stg-changeEnemyToMedal.asm"
.include "stg-moveEnemy_hitCheck.asm"
.include "stg-newEnemy.asm"
.include "stg-newEnemyShot.asm"
.include "stg-addScore.asm"

.endproc

palettes:
    ; BG
    .byte   $0f, $00, $10, $20 ; Main領域のBGパレット
    .byte   $0f, $28, $11, $30 ; タイトル文字のBGパレット
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

star_high:; 星を表示する位置の上位8bit ($20, $21, $22 or $23)
    .byte   $23, $20, $21, $22, $20, $22, $20, $21
    .byte   $23, $21, $20, $21, $23, $21, $22, $20
    .byte   $23, $21, $22, $20, $20, $21, $20, $22
    .byte   $23, $20, $20, $21, $21, $20, $22, $21

star_low:; 星を表示する位置の下位8bit
    .byte   $21, $af, $43, $70, $95, $29, $62, $85
    .byte   $43, $29, $b2, $91, $68, $24, $41, $82
    .byte   $25, $ab, $43, $62, $94, $25, $62, $85
    .byte   $47, $23, $b5, $91, $68, $23, $41, $82

title_pattern_cosmic:;       | C                   O               S               M                   I   C           |
    .byte   $00,$00,$00,$00,$00,$30,$40,$40,$40,$33,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$41,$00,$00,$00,$37,$38,$40,$40,$39,$38,$40,$40,$39,$38,$40,$4e,$40,$39,$4f,$38,$40,$39,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$41,$00,$00,$00,$00,$3a,$00,$00,$3b,$3a,$00,$00,$4a,$3a,$00,$3b,$00,$3b,$41,$3a,$00,$4a,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$41,$00,$00,$00,$00,$3a,$00,$00,$3b,$3c,$40,$40,$39,$3a,$00,$3b,$00,$3b,$41,$3a,$00,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$41,$00,$00,$00,$48,$3a,$00,$00,$3b,$4b,$00,$00,$3b,$3a,$00,$3b,$00,$3b,$41,$3a,$00,$4c,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$32,$40,$40,$40,$31,$3c,$40,$40,$3d,$3c,$40,$40,$3d,$50,$00,$51,$00,$51,$45,$3c,$40,$3d,$00,$00,$00,$00,$00
title_pattern_shooter:;      | S                   h               o           o           t   e           r           |
    .byte   $00,$00,$00,$00,$00,$00,$30,$40,$40,$33,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$30,$31,$00,$00,$34,$35,$33,$00,$30,$44,$00,$00,$00,$35,$40,$47,$40,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$32,$33,$00,$00,$00,$00,$41,$00,$41,$00,$00,$00,$00,$00,$00,$41,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$00,$32,$40,$40,$33,$00,$43,$40,$46,$38,$40,$39,$38,$40,$39,$41,$38,$40,$39,$4f,$30,$44,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$00,$00,$00,$30,$31,$00,$41,$00,$41,$3a,$00,$3b,$3a,$00,$3b,$41,$3a,$36,$3d,$43,$31,$00,$00,$00,$00,$00,$00
    .byte   $00,$00,$00,$00,$00,$35,$40,$40,$31,$00,$36,$31,$00,$37,$3c,$40,$3d,$3c,$40,$3d,$45,$3c,$40,$3e,$45,$00,$00,$00,$00,$00,$00,$00
push_start:
    .byte   "PUSH START"
copyright:
    .byte   "(C)2018, SUZUKI PLAN"

.org $0000
v_gameOver: .byte   $00     ; 0: ゲームオーバーカウンタ
v_gameOverD:.byte   $00     ; 1: ゲームオーバー描画済みフラグ
v_playerX:  .byte   $00     ; 2: 自機のX座標
v_playerY:  .byte   $00     ; 3: 自機のY座標
v_shot_idx: .byte   $00     ; 4: ショットのindex
v_shot_ng:  .byte   $00     ; 5: ショットの発射禁止フラグ (0の時のみ発射許可)
v_counter:  .byte   $00     ; 6: tick counter
v_enemy_idx:.byte   $00     ; 7: 敵のindex
v_enemy_xi: .byte   $00     ; 8: 敵の出現位置のindex
v_bomb_f:   .byte   $00     ; 9: 爆発フラグ (#$00〜#$0F)
v_bomb_x:   .byte   $00     ; 10: 爆発のX座標
v_bomb_y:   .byte   $00     ; 11: 爆発のY座標
v_eshot_idx:.byte   $00     ; 12: 敵ショットのindex
v_eshot_ng: .byte   $00     ; 13: 敵ショットの発射禁止フラグ (0の時のみ発射許可)
v_eshot_se: .byte   $00     ; 14: 敵ショットの効果音下位8bit (発射の都度変化)
v_sc_plus:  .byte   $00     ; 15: 1フレームあたりのスコア加算回数
v_sc10:     .byte   $00     ; 16: スコア(10の位)
v_sc100:    .byte   $00     ; 17: スコア(100の位)
v_sc1000:   .byte   $00     ; 18: スコア(1000の位)
v_sc10000:  .byte   $00     ; 19: スコア(10000の位)
v_sc100000: .byte   $00     ; 20: スコア(100000の位)
v_sc1000000:.byte   $00     ; 21: スコア(1000000の位)
v_sc:       .byte   $00, $00, $00 ; 22-24: スコア数値
v_hi10:     .byte   $00     ; 25: ハイスコア(10の位)
v_hi100:    .byte   $00     ; 26: ハイスコア(100の位)
v_hi1000:   .byte   $00     ; 27: ハイスコア(1000の位)
v_hi10000:  .byte   $00     ; 28: ハイスコア(10000の位)
v_hi100000: .byte   $00     ; 29: ハイスコア(100000の位)
v_hi1000000:.byte   $00     ; 30: ハイスコア(1000000の位)
v_hi:       .byte   $00, $00, $00 ; 31-33: ハイスコア数値
v_hi_update:.byte   $00     ; 34: ハイスコア更新フラグ
v_star_pos: .byte   $00     ; 35: 星の乱数位置
v_md_cnt:   .byte   $00     ; 36: 所持メダル数
v_md_plus:  .byte   $00     ; 37: 1フレームでのメダル増加/減少数
; 自機ショット構造体（16bytes）
v_shot0_f:  .byte   $00     ; ショットの生存フラグ
v_shot0_x:  .byte   $00     ; ショットのX座標
v_shot0_y:  .byte   $00     ; ショットのY座標
v_shot0_i:  .byte   $00     ; 未使用 (バウンダリ)
v_shot1:    .byte   $00, $00, $00, $00
v_shot2:    .byte   $00, $00, $00, $00
v_shot3:    .byte   $00, $00, $00, $00
; 敵ショット構造体（32bytes）
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
; 敵構造体（32bytes）
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
; 星構造体 (16bytes)
;                   ptn, high low  rno
v_star0:    .byte   $00, $00, $00, $00
v_star1:    .byte   $00, $00, $00, $00
v_star2:    .byte   $00, $00, $00, $00
v_star3:    .byte   $00, $00, $00, $00

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

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "stg-bg.chr"
    .incbin "stg-sprite.chr"
