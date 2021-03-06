; loop infinite
mainloop:
    ; clear joy-pad
    lda #$01
    sta $4016
    lda #$00
    sta $4016

    ; increment counter
    ldx v_counter
    inx
    stx v_counter

    ; 16フレームに1回敵キャラを出現させる
    txa
    and #$0f
    bne moveloop_inputCheck
mainloop_addNewEnemy:
    ldx v_enemy_idx
    lda v_enemy0_f, x
    bne moveloop_inputCheck ; まだ生きているので登場を抑止
    jsr sub_newEnemy

moveloop_inputCheck:
    lda v_gameOver
    bne mainloop_gameOver
    jsr sub_movePlayer
    jmp mainloop_gameOver_end

mainloop_gameOver:
    cmp #$01
    bne mainloop_gameOver_skipSE

    ; play SE1 (ノイズを使う)
    ;     --cevvvv (c=再生時間カウンタ, e=effect, v=volume)
    lda #%00011111
    sta $400C
    ;     r---ssss (r=乱数種別, s=サンプリングレート)
    lda #%00001101
    sta $400E
    ;     ttttt--- (t=再生時間)
    lda #%11111000
    sta $400F

    ; play SE2 (矩形波2を使う)
    ;     ddcevvvv (d=duty, c=再生時間カウンタ, e=effect, v=volume)
    lda #%11111111
    sta $4004
    ;     csssmrrr (c=周波数変化, s=speed, m=method, r=range)
    lda #%11110011
    sta $4005
    ;     kkkkkkkk (k=音程周波数の下位8bit)
    lda #%01101000
    sta $4006
    ;     tttttkkk (t=再生時間, k=音程周波数の上位3bit)
    lda #%11111001
    sta $4007
    jmp mainloop_gameOver_start

mainloop_gameOver_skipSE:
    cmp #$10
    bcc mainloop_gameOver_start ; 16フレームの間はリトライ禁止
    cmp #$30
    bcs mainloop_gameOver_retryCheck ; 48フレーム目以降ならリトライ許可
    tax
    inx
    stx v_gameOver
    jmp mainloop_gameOver_start

mainloop_gameOver_retryCheck:
    lda $4016   ; A
    lda $4016   ; B 
    lda $4016   ; SELECT
    lda $4016   ; START
    and #$01
    beq mainloop_gameOver_start
    jmp restart

mainloop_gameOver_start:
    lda #%00100001
    sta sp_player1 + 2
    sta sp_player2 + 2
    sta sp_player3 + 2
    sta sp_player4 + 2
    lda v_gameOver
    cmp #$10
    bcs mainloop_gameOver_erasePlayer
    tax
    inx
    stx v_gameOver
    ror
    ror
    and #$03
    clc
    adc #$10
    sta sp_player1 + 1
    adc #$04
    sta sp_player2 + 1
    adc #$04
    sta sp_player3 + 1
    adc #$04
    sta sp_player4 + 1
    jmp mainloop_gameOver_end
mainloop_gameOver_erasePlayer:
    lda #$00
    sta sp_player1 + 1
    sta sp_player2 + 1
    sta sp_player3 + 1
    sta sp_player4 + 1
mainloop_gameOver_end:

    ldx #$00
mainloop_moveShot:
    ; check flag
    lda v_shot0_f, x
    beq mainloop_moveShot_next
    lda v_shot0_y, x
    clc
    adc #$FA
    cmp #$f8
    bcs mainloop_moveShot_erase
    ; store Y
    sta v_shot0_y, x
    sta sp_shot0, x
    jmp mainloop_moveShot_next
mainloop_moveShot_erase:
    lda #$00
    sta v_shot0_f, x
    sta sp_shot0, x
    sta sp_shot0 + 1, x
    sta sp_shot0 + 3, x
mainloop_moveShot_next:
    txa
    clc
    adc #$04
    tax
    and #$0f
    bne mainloop_moveShot

mainloop_moveShotEnd:

    ldx #$00
mainloop_moveEnemy:
    ; check flag
    lda v_enemy0_f, x
    beq mainloop_moveEnemy_next
    tay
    and #$80
    bne mainloop_moveEnemy_typeM ; 補数bitが立っている場合はメダル
    tya
    and #$01
    beq mainloop_moveEnemy_type2
mainloop_moveEnemy_type1:
    jsr sub_moveEnemy_type1
    jmp mainloop_moveEnemy_after
mainloop_moveEnemy_type2:
    jsr sub_moveEnemy_type2
mainloop_moveEnemy_after:
    and #$01
    beq mainloop_moveEnemy_erase
    jsr sub_moveEnemy_hitCheck
    and #$01
    bne mainloop_moveEnemy_next
mainloop_moveEnemy_toMedal: ; 敵をメダルに変化させる
    jsr sub_changeEnemyToMedal
    jmp mainloop_moveEnemy_next
mainloop_moveEnemy_typeM:
    jsr sub_moveEnemy_typeM
    and #$01
    bne mainloop_moveEnemy_next
mainloop_moveEnemy_erase:
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
mainloop_moveEnemy_next:
    txa
    clc
    adc #$04
    and #$1f
    tax
    bne mainloop_moveEnemy
mainloop_moveEnemy_end:

    ldx v_eshot_ng
    beq mainloop_moveEShot
    dex
    stx v_eshot_ng
    ldx #$00
mainloop_moveEShot:
    ; check flag
    lda v_eshot0_f, x
    beq mainloop_moveEShot_next
    ; 落下速度(i)が7未満の場合8フレームに1回の間隔で加速する
    lda v_eshot0_i, x
    cmp #$07
    bcs mainloop_moveEShot_down ; もう最大速度
    pha
    lda v_counter
    and #$07
    beq mainloop_moveEShot_speedUp
    pla
    jmp mainloop_moveEShot_down
mainloop_moveEShot_speedUp:
    pla
    clc
    adc #$01
    sta v_eshot0_i, x
mainloop_moveEShot_down:
    lda v_eshot0_y, x
    clc
    adc v_eshot0_i, x
    bcs mainloop_moveEShot_erase
    ; store Y
    sta v_eshot0_y, x
    sta sp_eshot0, x
    ; animate
    lda v_counter
    and #$04
    ror
    ror
    adc #$0a
    sta sp_eshot0 + 1, x

    ; 自機との当たり判定
    lda v_gameOver
    bne mainloop_moveEShot_next
    ; Y座標のチェック
    lda v_eshot0_y, x
    adc #$EF ; carry が 1 なので #$F0
    cmp v_playerY
    bcs mainloop_moveEShot_next ; eshotY(a) >= playerY+16 is not hit
    adc #$18
    cmp v_playerY
    bcc mainloop_moveEShot_next ; enemyY+8(a) < playerY is not hit
    ; X座標のチェック
    lda v_eshot0_x, x
    clc
    adc #$f0 ; 本当はplayerXを+16したいが難しいのでeshotXを-16する
    cmp v_playerX
    bcs mainloop_moveEShot_next ; eshotX(a) >= playerX+16 is not hit
    adc #$18
    cmp v_playerX
    bcc mainloop_moveEShot_next ; eshotX+8(a) < playerX is not hit
    lda #$01
    sta v_gameOver

mainloop_moveEShot_erase:
    lda #$00
    sta v_eshot0_f, x
    sta sp_eshot0, x
    sta sp_eshot0 + 1, x
    sta sp_eshot0 + 3, x
mainloop_moveEShot_next:
    txa
    clc
    adc #$04
    tax
    and #$1f
    bne mainloop_moveEShot
mainloop_moveEShotEnd:

mainloop_moveBomb:
    lda v_bomb_f
    beq mainloop_moveBomb_end
    ; 描画する爆発パターンを設定: v_bomb_f ÷ 4 + 16 (+0, +4, +8, +12)
    lsr                 ; ÷ 2
    lsr                 ; ÷ 4
    and #$03            ; 念の為 0〜3 になるように調整
    clc
    adc #$10            ; +16
    sta sp_bomb1 + 1    ; 左上のTILEを設定
    adc #$04
    sta sp_bomb3 + 1    ; 左下のTILEを設定
    adc #$04
    sta sp_bomb2 + 1    ; 右上のTILEを設定
    adc #$04
    sta sp_bomb4 + 1    ; 右下のTILEを設定
    ; Y座標を設定 (2フレームに1回Y座標をデクリメント)
    ldx v_bomb_y
    lda v_bomb_f
    and #$01
    bne mainloop_moveBomb_notMoveY
    dex
    stx v_bomb_y
mainloop_moveBomb_notMoveY:
    stx sp_bomb1
    stx sp_bomb3
    txa
    clc
    adc #$08
    tax
    stx sp_bomb2
    stx sp_bomb4
    ; X座標を設定
    ldx v_bomb_x
    stx sp_bomb1 + 3
    stx sp_bomb2 + 3
    txa
    clc
    adc #$08
    tax
    stx sp_bomb3 + 3
    stx sp_bomb4 + 3
    ; 属性を設定
    lda #%00100001
    sta sp_bomb1 + 2
    sta sp_bomb2 + 2
    sta sp_bomb3 + 2
    sta sp_bomb4 + 2
    ; フラグをインクリメントして16になったらクリア
    ldx v_bomb_f
    inx
    txa
    and #$0f
    sta v_bomb_f
    bne mainloop_moveBomb_end
    ; 爆発のスプライトを消す
    lda #$00
    ldx #$00
    ldy #$10
mainloop_moveBomb_eraseLoop:
    sta sp_bomb1, x
    inx
    dey
    bne mainloop_moveBomb_eraseLoop
mainloop_moveBomb_end:

mainloop_sprite_DMA:; WRAM $0300 ~ $03FF -> Sprite
    lda $2002
    bpl mainloop_sprite_DMA ; wait for vBlank
    lda #$3
    sta $4014

    lda v_skip_add
    beq mainloop_skipGetReady
    cmp #$01
    beq mainloop_eraseGetReady
    jmp mainloop_drawGetReady
mainloop_eraseGetReady:
    ldy #$09
    ldx #$00
    lda #$21
    sta $2006
    lda #$a7
    sta $2006
    lda #$00
mainloop_eraseGetReadyLoop:
    sta $2007
    inx
    dey
    bne mainloop_eraseGetReadyLoop
    lda #$00
    sta $2005
    sta $2005
    jmp mainloop_skipGetReady
mainloop_drawGetReady:
    ldy #$09
    ldx #$00
    lda #$21
    sta $2006
    lda #$a7
    sta $2006
mainloop_drawGetReadyLoop:
    lda string_get_ready, x
    clc
    adc #$80
    sta $2007
    inx
    dey
    bne mainloop_drawGetReadyLoop
    lda #$00
    sta $2005
    sta $2005
mainloop_skipGetReady:

    ; 星を4フレームにつき1回動かす
    lda v_counter
    and #$03
    cmp #$02
    bne mainloop_drawStar_skip
    ldx #$00
mainloop_drawStar:
    lda v_star0 + 1, x
    sta $2006
    lda v_star0 + 2, x
    sta $2006
    lda v_star0, x
    clc
    adc #$01
    and #$07
    sta v_star0, x
    sta $2007
    bne mainloop_drawStar_next

    ; change position
    ldy v_star_pos
    iny
    tya
    and #$1f
    sta v_star_pos
    tay
    lda star_high, y
    sta v_star0 + 1, x
    lda star_low, y
    sta v_star0 + 2, x

mainloop_drawStar_next:
    ; increment index
    txa
    adc #$04
    and #$0f
    tax
    bne mainloop_drawStar
    lda #$00
    sta $2005
    sta $2005
    jmp mainloop ; 性能確保のため今回フレームではその他の描画更新を省略
mainloop_drawStar_skip:

    ; メダルの加算/減算
    ldx #$00
    lda v_md_cnt
    clc
    adc v_md_plus
    stx v_md_plus
    cmp #$80
    bcs mainloop_medal_plus_store ; 負数なので0にする
    ldx #$07
    cmp #$08
    bcs mainloop_medal_plus_store ; 8以上なので7にする
    tax
mainloop_medal_plus_store:
    cpx v_md_cnt
    beq mainloop_drawGameOver ; メダル数に変化無し
    stx v_md_cnt

    ; 所持メダル数を表示
mainloop_drawMedals:
    lda #$21
    sta $2006
    lda #$b7
    sta $2006
    ldy #$08
    lda v_md_cnt
    beq mainloop_drawMedals_spaces
    tax
    lda #$09
mainloop_drawMedals_stars:
    sta $2007
    dey
    dex
    bne mainloop_drawMedals_stars
mainloop_drawMedals_spaces:
    lda #$08
mainloop_drawMedals_spaces_loop:
    sta $2007
    dey
    bne mainloop_drawMedals_spaces_loop
mainloop_drawMedals_end:
    lda #$00
    sta $2005
    sta $2005
    jmp mainloop ; 性能確保のため今回フレームではその他の描画更新を省略

    ; ゲームオーバー表示
mainloop_drawGameOver:
    lda v_gameOverD
    bne mainloop_drawScore
    lda v_gameOver
    beq mainloop_drawScore
    lda #$ff
    sta v_gameOverD

    ldy #$09
    ldx #$00
    lda #$21
    sta $2006
    lda #$a7
    sta $2006
mainloop_drawGameOver1:
    lda string_game_over, x
    clc
    adc #$80
    sta $2007
    inx
    dey
    bne mainloop_drawGameOver1

    ldy #$13
    ldx #$00
    lda #$21
    sta $2006
    lda #$e2
    sta $2006
mainloop_drawGameOver2:
    lda string_push_start_to_retry, x
    clc
    adc #$80
    sta $2007
    inx
    dey
    bne mainloop_drawGameOver2
 
    lda #$00
    sta $2005
    sta $2005
    jmp mainloop

mainloop_drawScore:
    ; スコア更新 (描画を伴うのでvBlank中でなければならない)
    ; 負荷軽減のため1フレームにつき最大10加算とする
    ldx v_sc_plus
    beq mainloop_drawScore_end
    jsr sub_addScore10
    dex
    stx v_sc_plus
    lda #$00
    sta $2005
    sta $2005
mainloop_drawScore_end:
    jmp mainloop
