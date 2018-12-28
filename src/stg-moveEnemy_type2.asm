;----------------------------------------------------------
; サブルーチン: 敵アルゴリズム（type2）
; * xレジスタ: 敵機のindex (このサブルーチン内ではread only)
; * a,yレジスタ: サブルーチン内で自由に使える
; * 戻り値: 敵が生存中の場合はa=1を返し、敵を消す場合はa=0を返す
;----------------------------------------------------------

sub_moveEnemy_type2:
    lda v_enemy0_i, x
    beq sub_moveEnemy_type2_moveDown
    clc
    and #$80
    bne sub_moveEnemy_type2_moveLeft

sub_moveEnemy_type2_moveRight:
    ; 右に移動
    lda v_enemy0_x, x
    adc #$01
    cmp #$b0
    bcc sub_moveEnemy_type2_moveRight_alive
    lda #$00
    rts
 sub_moveEnemy_type2_moveRight_alive:
    sta v_enemy0_x, x
    sta sp_enemy0lb + 3, x
    sta sp_enemy0lt + 3, x
    adc #$08
    sta sp_enemy0rb + 3, x
    sta sp_enemy0rt + 3, x
    ; アニメーション
    lda v_counter
    and #$04
    clc
    adc #$68
    sta sp_enemy0lt + 1, x
    adc #$01
    sta sp_enemy0rt + 1, x
    adc #$01
    sta sp_enemy0lb + 1, x
    adc #$01
    sta sp_enemy0rb + 1, x
    jmp sub_moveEnemy_type2_hitCheck

sub_moveEnemy_type2_moveLeft:
    ; 左に移動
    lda v_enemy0_x, x
    sbc #$01
    cmp #$f0
    bcc sub_moveEnemy_type2_moveLeft_alive
    lda #$00
    rts
sub_moveEnemy_type2_moveLeft_alive:
    sta v_enemy0_x, x
    sta sp_enemy0lb + 3, x
    sta sp_enemy0lt + 3, x
    adc #$08
    sta sp_enemy0rb + 3, x
    sta sp_enemy0rt + 3, x
    ; アニメーション
    lda v_counter
    and #$04
    clc
    adc #$70
    sta sp_enemy0lt + 1, x
    adc #$01
    sta sp_enemy0rt + 1, x
    adc #$01
    sta sp_enemy0lb + 1, x
    adc #$01
    sta sp_enemy0rb + 1, x
    jmp sub_moveEnemy_type2_hitCheck

sub_moveEnemy_type2_moveDown:
    ; 下に移動
    lda v_counter
    and #$07
    adc v_enemy0_y, x
    bcc sub_moveEnemy_type2_storeY
    ; 下限に達したので消す
    lda #$00
    rts
sub_moveEnemy_type2_storeY:
    ; Y座標を記憶
    sta v_enemy0_y, x
    sta sp_enemy0lb, x
    sta sp_enemy0rb, x
    clc
    adc #$f8
    sta sp_enemy0lt, x
    sta sp_enemy0rt, x
    ; アニメーション
    lda v_counter
    and #$04
    clc
    adc #$60
    sta sp_enemy0lt + 1, x
    adc #$01
    sta sp_enemy0rt + 1, x
    adc #$01
    sta sp_enemy0lb + 1, x
    adc #$01
    sta sp_enemy0rb + 1, x
    ; プレイヤーのY座標と重なったら移動方向を転換
    lda v_gameOver
    bne sub_moveEnemy_type2_noHit ; ゲームオーバーフラグが立っている場合はチェックしない
    ; Y座標の衝突チェック
    lda v_enemy0_y, x
    clc
    sbc #$18
    cmp v_playerY
    bcs sub_moveEnemy_type2_noHit ; enemyY(a)-8 >= playerY+16 is not hit
    adc #$20
    cmp v_playerY
    bcc sub_moveEnemy_type2_noHit ; enemyY+8(a) < playerY is not hit

    lda v_enemy0_x, x
    cmp v_playerX
    bcc sub_moveEnemy_type2_toRight
sub_moveEnemy_type2_toLeft:; 左へ方向転換
    lda #$fa
    sta v_enemy0_i, x
    jmp sub_moveEnemy_type2_hitCheckX
sub_moveEnemy_type2_toRight:; 右へ方向転換
    lda #$04
    sta v_enemy0_i, x
    jmp sub_moveEnemy_type2_hitCheckX

sub_moveEnemy_type2_hitCheck:
    ; 自機との当たり判定
    lda v_gameOver
    bne sub_moveEnemy_type2_noHit ; ゲームオーバーフラグが立っている場合はチェックしない
    ; Y座標の衝突チェック
    lda v_enemy0_y, x
    clc
    sbc #$18
    cmp v_playerY
    bcs sub_moveEnemy_type2_noHit ; enemyY(a)-8 >= playerY+16 is not hit
    adc #$20
    cmp v_playerY
    bcc sub_moveEnemy_type2_noHit ; enemyY+8(a) < playerY is not hit
sub_moveEnemy_type2_hitCheckX:; X座標の衝突チェック
    lda v_enemy0_x, x
    cmp #$10
    bcs sub_moveEnemy_type2_over16 ; 16以上の時の判定
    ; 16未満の時はxが16以下ならhitとして縦のチェック（xのレンジチェックをskip）
    lda v_playerX
    cmp #$10
    bcs sub_moveEnemy_type2_noHit
    ; 衝突したのでgame overにする
    lda #$01
    sta v_gameOver
    lda #$01
    rts
sub_moveEnemy_type2_over16:
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいので敵Xを-16する
    cmp v_playerX
    bcs sub_moveEnemy_type2_noHit ; enemyX(a) >= playerX+16 is not hit
    adc #$20
    cmp v_playerX
    bcc sub_moveEnemy_type2_noHit ; enemyX+16(a) < playerX is not hit
    ; 衝突したのでgame overにする
    lda #$01
    sta v_gameOver
sub_moveEnemy_type2_noHit:
    lda #$01
    rts
