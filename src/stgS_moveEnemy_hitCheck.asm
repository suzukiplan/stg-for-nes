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