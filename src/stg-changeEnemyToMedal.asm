;----------------------------------------------------------
; サブルーチン: 敵をメダルに変化させる
; * xレジスタ: 敵機(メダル)のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_changeEnemyToMedal:
    lda v_enemy0_y, x
    cmp #$30
    bcs sub_changeEnemyToMedal_enable
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
    rts
sub_changeEnemyToMedal_enable:
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
