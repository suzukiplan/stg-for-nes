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
    ; Y座標のチェック
    lda v_enemy0_y, x
    clc
    adc #$E8 ; 敵のYは+8から始まるので-8しつつplayerY+16としたいので更に-16
    cmp v_playerY
    bcs sub_moveEnemy_typeM_noHit ; enemyY-8(a) >= playerY+16 is not hit
    adc #$28
    cmp v_playerY
    bcc sub_moveEnemy_typeM_noHit ; enemyY+16(a) < playerY is not hit
    ; X座標のチェック
    lda v_enemy0_x, x
    cmp #$10
    bcs sub_moveEnemy_typeM_over16 ; 16以上の時の判定
    ; 16未満の時はxが16以下ならhitとして縦のチェック（xのレンジチェックをskip）
    lda v_playerX
    cmp #$10
    bcs sub_moveEnemy_typeM_noHit
    jmp sub_moveEnemy_typeM_hit
sub_moveEnemy_typeM_over16:
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_typeM_noHit ; enemyX(a) >= playerX+16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_typeM_noHit ; enemyX+16(a) < playerX is not hit

sub_moveEnemy_typeM_hit:
    ; play SE (矩形波2を使う)
    ;     ddcevvvv (d=duty, c=再生時間カウンタ, e=effect, v=volume)
    lda #%10010111
    sta $4004
    ;     csssmrrr (c=周波数変化, s=speed, m=method, r=range)
    lda #%11111010
    sta $4005
    ;     kkkkkkkk (k=音程周波数の下位8bit)
    lda #%01101000
    sta $4006
    ;     tttttkkk (t=再生時間, k=音程周波数の上位3bit)
    lda #%10001000
    sta $4007

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
