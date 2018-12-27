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
    ; フラグにより動作を変える
    lda v_enemy0_i, x
    and #$ff
    beq sub_moveEnemy_type1_downOnly
    and #$01
    bne sub_moveEnemy_type1_right

sub_moveEnemy_type1_left:
    ldy v_enemy0_x, x
    dey
    bcs sub_moveEnemy_type1_left_over ; 負数になったので消す
    tya
    sta v_enemy0_x, x
    sta sp_enemy0lb + 3, x
    clc
    adc #$08
    sta sp_enemy0rb + 3, x
    jmp sub_moveEnemy_type1_hitCheck_before
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
    sta sp_enemy0lb + 3, x
    adc #$08
    sta sp_enemy0rb + 3, x
    jmp sub_moveEnemy_type1_hitCheck_before
sub_moveEnemy_type1_right_over:
    lda #$00
    rts

sub_moveEnemy_type1_hitCheck_before:
    ; 左右移動時はパタパタする
    lda v_counter
    and #$04
    ror
    clc
    adc #$06
    sta sp_enemy0lb + 1, x
    adc #$01
    sta sp_enemy0rb + 1, x

sub_moveEnemy_type1_hitCheck:
    ; 自機との当たり判定
    lda v_gameOver
    bne sub_moveEnemy_type1_noHit ; ゲームオーバーフラグが立っている場合はチェックしない
    ; Y座標の衝突チェック
    lda v_enemy0_y, x
    clc
    adc #$F0 ; playerY+16としたいが難しいので敵を-16にしておく
    cmp v_playerY
    bcs sub_moveEnemy_type1_noHit ; enemyY(a) >= playerY+16 is not hit
    adc #$18
    cmp v_playerY
    bcc sub_moveEnemy_type1_noHit ; enemyY+8(a) < playerY is not hit
    ; X座標の衝突チェック
    lda v_enemy0_x, x
    cmp #$10
    bcs sub_moveEnemy_type1_over16 ; 16以上の時の判定
    ; 16未満の時はxが16以下ならhitとして縦のチェック（xのレンジチェックをskip）
    lda v_playerX
    cmp #$10
    bcs sub_moveEnemy_type1_noHit
    ; 衝突したのでgame overにする
    lda #$01
    sta v_gameOver
    lda #$01
    rts
sub_moveEnemy_type1_over16:
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_type1_noHit ; enemyX(a) >= playerX+16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_type1_noHit ; enemyX+16(a) < playerX is not hit
    ; 衝突したのでgame overにする
    lda #$01
    sta v_gameOver
sub_moveEnemy_type1_noHit:
    lda #$01
    rts
