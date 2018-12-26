;----------------------------------------------------------
; サブルーチン: スコアを加算+描画 (vBlank中にのみ実行できる)
; * xレジスタ: unused (このサブルーチン内では使わない)
; * yレジスタ: unused (このサブルーチン内では使わない)
; * aレジスタ: 計算用のワーク
;----------------------------------------------------------
sub_addScore10:
    lda v_sc10
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore10_display
    jsr sub_addScore100
    lda #$00
sub_addScore10_display:
    sta v_sc10
    lda #$21
    sta $2006
    lda #$7c
    sta $2006
    lda v_sc10
    clc
    adc #$30
    sta $2007
    rts

sub_addScore100:
    lda v_sc100
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore100_display
    jsr sub_addScore1000
    lda #$00
sub_addScore100_display:
    sta v_sc100
    lda #$21
    sta $2006
    lda #$7b
    sta $2006
    lda v_sc100
    clc
    adc #$30
    sta $2007
    rts

sub_addScore1000:
    lda v_sc1000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore1000_display
    jsr sub_addScore10000
    lda #$00
sub_addScore1000_display:
    sta v_sc1000
    lda #$21
    sta $2006
    lda #$7a
    sta $2006
    lda v_sc1000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore10000:
    lda v_sc10000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore10000_display
    jsr sub_addScore100000
    lda #$00
sub_addScore10000_display:
    sta v_sc10000
    lda #$21
    sta $2006
    lda #$79
    sta $2006
    lda v_sc10000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore100000:
    lda v_sc100000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore100000_display
    jsr sub_addScore1000000
    lda #$00
sub_addScore100000_display:
    sta v_sc100000
    lda #$21
    sta $2006
    lda #$78
    sta $2006
    lda v_sc100000
    clc
    adc #$30
    sta $2007
    rts

sub_addScore1000000:
    lda v_sc1000000
    clc
    adc #$01
    cmp #$0a
    bcc sub_addScore1000000_display
    rts
sub_addScore1000000_display:
    sta v_sc1000000
    lda #$21
    sta $2006
    lda #$77
    sta $2006
    lda v_sc1000000
    clc
    adc #$30
    sta $2007
    rts
