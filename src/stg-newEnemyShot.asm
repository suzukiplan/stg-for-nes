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
    and #$1f
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

    ; play SE (三角波を使う)
    ;     cttttttt (c=再生時間カウンタ, t=再生時間)
    lda #%00000011
    sta $4008
    ;     ssssssss (s=サンプリングレート下位8bit)
    lda v_eshot_se
    adc #%10011001
    sta v_eshot_se
    sta $400A
    ;     tttttsss (t=再生時間, s=サンプリングレート上位3bit)
    lda #%00000001
    sta $400B

    ; 7フレームの間、新規ショットを発射禁止にする
    lda #$07
    sta v_eshot_ng
sub_newEnemyShot_end:
    rts
