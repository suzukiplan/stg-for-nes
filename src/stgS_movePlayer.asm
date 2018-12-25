;----------------------------------------------------------
; サブルーチン: 自機の操作
; * 全レジスタ: サブルーチン内で自由に使える
;----------------------------------------------------------
sub_movePlayer:
    lda $4016   ; A
    and #$01
    bne sub_movePlayer_addNewShot
    ; reset ng flag if not push A
    lda #$00
    sta v_shot_ng
    jmp sub_movePlayer_endFireShot

sub_movePlayer_addNewShot:
    lda v_shot_ng
    bne sub_movePlayer_suppressFireShot
    lda #$20
    sta v_shot_ng

    ldx v_shot_idx

    ; suppress if shot exist yet
    lda v_shot0_f, x
    bne sub_movePlayer_endFireShot

    lda #$01
    sta v_shot0_f, x
    lda v_playerX
    clc
    adc #$04
    sta v_shot0_x, x
    lda v_playerY
    adc #$FF
    sta v_shot0_y, x

    ; initialize sprite of shot
    sta sp_shot0, x
    lda #$05
    sta sp_shot0 + 1, x
    lda #%00100000
    sta sp_shot0 + 2, x
    lda v_shot0_x, x
    sta sp_shot0 + 3, x

    txa
    clc
    adc #$04
    and #$0f
    sta v_shot_idx

sub_movePlayer_suppressFireShot:
    ldx v_shot_ng
    dex
    stx v_shot_ng

sub_movePlayer_endFireShot:
    lda $4016   ; B
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    and #$01
    bne sub_movePlayer_up
    lda $4016   ; DOWN
    and #$01
    bne sub_movePlayer_down
    jmp sub_movePlayer_inputCheck_LR

sub_movePlayer_up:
    lda $4016   ; DOWN (skip)
    ldx v_playerY
    cpx #$28
    bcc sub_movePlayer_inputCheck_LR ; do not move if y < 40
    dex
    dex
    txa
    sta v_playerY
    sta sp_player1
    sta sp_player2
    clc
    adc #$08
    sta sp_player3
    sta sp_player4
    jmp sub_movePlayer_inputCheck_LR

sub_movePlayer_down:
    ldx v_playerY
    cpx #$D8
    bcs sub_movePlayer_inputCheck_LR ; do not move if 216 <= y
    inx
    inx
    txa
    sta v_playerY
    sta sp_player1
    sta sp_player2
    clc
    adc #$08
    sta sp_player3
    sta sp_player4

sub_movePlayer_inputCheck_LR:
    lda $4016   ; LEFT
    and #$01
    bne sub_movePlayer_left
    lda $4016   ; RIGHT
    and #$01
    bne sub_movePlayer_right
    rts

sub_movePlayer_left:
    ldx v_playerX
    cpx #$0a
    bcc sub_movePlayer_end ; do not move if x < 10
    dex
    dex
    txa
    sta v_playerX
    sta sp_player1 + 3
    sta sp_player3 + 3
    clc
    adc #$08
    sta sp_player2 + 3
    sta sp_player4 + 3
    rts

sub_movePlayer_right:
    ldx v_playerX
    cpx #$A0
    bcs sub_movePlayer_end ; do not move if 160 <= x
    inx
    inx
    txa
    sta v_playerX
    sta sp_player1 + 3
    sta sp_player3 + 3
    clc
    adc #$08
    sta sp_player2 + 3
    sta sp_player4 + 3

sub_movePlayer_end:
    rts
