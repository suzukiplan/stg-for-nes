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

.include "stg-00setup.asm"
.include "stg-01mainloop.asm"
.include "stg-movePlayer.asm"
.include "stg-moveEnemy_type1.asm"
.include "stg-moveEnemy_typeM.asm"
.include "stg-changeEnemyToMedal.asm"
.include "stg-newEnemyShot.asm"
.include "stg-moveEnemy_hitCheck.asm"
.include "stg-addScore.asm"

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

star_high:; 星を表示する位置の上位8bit ($20, $21, $22 or $23)
    .byte   $23, $20, $21, $22, $20, $22, $20, $21
    .byte   $23, $21, $20, $21, $23, $21, $22, $20
    .byte   $23, $21, $22, $20, $20, $21, $20, $22
    .byte   $23, $20, $20, $21, $21, $20, $22, $21

star_low1:; 星を表示する位置の下位8bit
    ; $20毎に +$01〜$16 が対象（+$00, +$16〜$1F を含めない）
    .byte   $01, $0f, $03, $10, $15, $09, $02, $05
    .byte   $03, $09, $12, $11, $08, $04, $01, $02
    .byte   $05, $0b, $03, $12, $14, $05, $02, $05
    .byte   $07, $03, $15, $11, $08, $03, $01, $02

star_low2:; ($20, $40, $60, $80, $A0 ※mod4が0の時は$A0を禁止)
    .byte   $20, $A0, $40, $60, $80, $20, $60, $80
    .byte   $40, $20, $A0, $80, $60, $20, $40, $80
    .byte   $20, $A0, $40, $60, $80, $20, $60, $80
    .byte   $40, $20, $A0, $80, $60, $20, $40, $80

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
v_eshot_se: .byte   $00     ; 的ショットの効果音下位8bit (発射の都度変化)
v_sc:       .byte   $00     ; 1フレームあたりのスコア加算回数
v_sc10:     .byte   $00     ; スコア(10の位)
v_sc100:    .byte   $00     ; スコア(100の位)
v_sc1000:   .byte   $00     ; スコア(1000の位)
v_sc10000:  .byte   $00     ; スコア(10000の位)
v_sc100000: .byte   $00     ; スコア(100000の位)
v_sc1000000:.byte   $00     ; スコア(1000000の位)
v_star_pos: .byte   $00
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
