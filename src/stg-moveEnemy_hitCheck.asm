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
    lda v_enemy0_y, x
    clc
    adc #$F8
    cmp v_shot0_y, y
    bcs sub_moveEnemy_hitCheck_next ; enemyY(a) >= shotY + 8 is not hit
    adc #$10
    cmp v_shot0_y, y
    bcc sub_moveEnemy_hitCheck_next ; enemyY+8(a) < shotY is not hit
    lda v_enemy0_x, x
    adc #$f7 ; 本当はshotXを+8したいが難しいので敵Xを-8する
    cmp v_shot0_x, y
    bcs sub_moveEnemy_hitCheck_next ; enemyX(a) >= shotX + 8 is not hit
    adc #$18
    cmp v_shot0_x, y
    bcc sub_moveEnemy_hitCheck_next ; enemyX+16(a) < shotX is not hit
    jmp sub_moveEnemy_hitCheck_destruct
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

sub_moveEnemy_hitCheck_destruct:
    ; play SE1 (ノイズを使う)
    ;     --cevvvv (c=再生時間カウンタ, e=effect, v=volume)
    lda #%00010100
    sta $400C
    ;     r---ssss (r=乱数種別, s=サンプリングレート)
    lda #%00001001
    sta $400E
    ;     ttttt--- (t=再生時間)
    lda #%01111000
    sta $400F

    ; play SE2 (矩形波2を使う)
    ;     ddcevvvv (d=duty, c=再生時間カウンタ, e=effect, v=volume)
    lda #%11110100
    sta $4004
    ;     csssmrrr (c=周波数変化, s=speed, m=method, r=range)
    lda #%11110010
    sta $4005
    ;     kkkkkkkk (k=音程周波数の下位8bit)
    lda #%01101000
    sta $4006
    ;     tttttkkk (t=再生時間, k=音程周波数の上位3bit)
    lda #%10001010
    sta $4007

    ; 現在の敵座標位置から爆発を描画
    lda #$01
    sta v_bomb_f
    lda v_enemy0_x, x
    sta v_bomb_x
    lda v_enemy0_y, x
    clc
    adc #$f8
    sta v_bomb_y
    ; スコアを加算 (10 + メダル所持数 * 10点)
    lda v_sc_plus
    clc
    adc #$01
    adc v_md_cnt
    sta v_sc_plus
    ; 自機ショットを消滅させつつ, a = 0 でリターン
    lda #$00
    sta v_shot0_f, y
    sta sp_shot0, y
    sta sp_shot0 + 1, y
    sta sp_shot0 + 3, y
    rts
