;----------------------------------------------------------
; サブルーチン: 敵追加
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_newEnemy:
    ; 一定の確率でハサミを登場させる
    lda v_counter
    and #%00100000 ; 下位4bitは出現判定に使っているので上位4bitのbit3を見れば4回目になる
    bne sub_newEnemy_type2

sub_newEnemy_type1:
    lda #$01
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
    ; 登場時点では下半身のみ使う (16x8)
    lda #$00
    sta v_enemy0_y, x

    ; Y of sprites (即座に再設定されるので実行しなくても良い)
;   sta sp_enemy0lb, x
;   sta sp_enemy0rb, x

    ; TILE of sprites
    lda #$06
    sta sp_enemy0lb + 1, x
    lda #$07
    sta sp_enemy0rb + 1, x

    ; ATTR of sprites
    lda #%00100011
    sta sp_enemy0lb + 2, x
    sta sp_enemy0rb + 2, x

    ; X of sprites
    lda v_enemy0_x, x
    sta sp_enemy0lb + 3, x
    clc
    adc #$08
    sta sp_enemy0rb + 3, x
    jmp sub_newEnemy_end

sub_newEnemy_type2:
    lda #$02
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
    ; ※type2は最初から上半身も使う
    lda #$00
    sta v_enemy0_y, x

    ; Y of sprites (即座に再設定されるので実行しなくても良い)
;   sta sp_enemy0lb, x
;   sta sp_enemy0rb, x
;   clc
;   adc #$f8
;   sta sp_enemy0lt, x
;   sta sp_enemy0rt, x

    ; TILE of sprites (即座に再設定されるので実行しなくても良い)
;   lda #$60
;   sta sp_enemy0lt + 1, x
;   lda #$61
;   sta sp_enemy0rt + 1, x
;   lda #$62
;   sta sp_enemy0lb + 1, x
;   lda #$63
;   sta sp_enemy0rb + 1, x

    ; ATTR of sprites
    lda #%00100000
    sta sp_enemy0lt + 2, x
    sta sp_enemy0rt + 2, x
    sta sp_enemy0lb + 2, x
    sta sp_enemy0rb + 2, x

    ; X of sprites
    lda v_enemy0_x, x
    sta sp_enemy0lt + 3, x
    sta sp_enemy0lb + 3, x
    clc
    adc #$08
    sta sp_enemy0rt + 3, x
    sta sp_enemy0rb + 3, x

sub_newEnemy_end:
    ; increment index
    txa
    clc
    adc #$04
    and #$1f
    sta v_enemy_idx
    rts
