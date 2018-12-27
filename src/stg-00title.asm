; Screen off
    lda #$00
    sta $2000
    sta $2001

; make palette table
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
    ldy #$20
copy_pal:
    lda palettes, x
    sta $2007
    inx
    dey
    bne copy_pal

; clear name table (fill name table: pattern 00)
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldy #$00
    lda #$00
    ldx #$04
title_clear:
    sta $2007
    iny
    bne title_clear
    dex
    bne title_clear

; initialize palette of name table
    lda #$23
    sta $2006
    lda #$c0
    sta $2006

    ldy #$20
    lda #%01010101
title_palette_top:
    sta $2007
    dey
    bne title_palette_top

    ldy #$20
    lda #$00
title_palette_bottom:
    sta $2007
    dey
    bne title_palette_bottom


; draw title
    lda #$20
    sta $2006
    lda #$60
    sta $2006
    ldy #$00
    ldx #$c0    
draw_title_cosmic:
    lda title_pattern_cosmic, y
    sta $2007
    iny
    dex
    bne draw_title_cosmic

    lda #$21
    sta $2006
    lda #$40
    sta $2006
    ldy #$00
    ldx #$c0    
draw_title_shooter:
    lda title_pattern_shooter, y
    sta $2007
    iny
    dex
    bne draw_title_shooter

    lda #$23
    sta $2006
    lda #$46
    sta $2006
    ldy #$00
    ldx #$14
draw_title_copyright:
    lda copyright, y
    ora #$80
    sta $2007
    iny
    dex
    bne draw_title_copyright

    lda #$22
    sta $2006
    lda #$8b
    sta $2006
    ldy #$00
    ldx #$0a
draw_title_push_start:
    lda push_start, y
    ora #$80
    sta $2007
    iny
    dex
    bne draw_title_push_start

; scroll setting
    lda #$00
    sta $2005
    sta $2005

; screen on
    ; bit7: nmi interrupt
    ; bit6: PPU type (0=master, 1=slave)
    ; bit5: size of sprite (0=8x8, 1=8x16)
    ; bit4: BG chr table (0=$0000, 1=$1000)
    ; bit3: sprite chr table (0=$0000, 1=$1000)
    ; bit2: address addition (0=+1, 1=+32)
    ; bit1~0: main screen (0=$2000, 1=$2400, 2=$2800, 3=$2c00)
    ;     76543210
    lda #%00011000
    sta $2000
    ; bit7: red
    ; bit6: green
    ; bit5: blue
    ; bit4: sprite
    ; bit3: BG
    ; bit2: visible left-top 8x sprite
    ; bit1: visible left-top 8x BG
    ; bit0: color (0=full, 1=mono)
    lda #%00011110
    sta $2001

title_loop:
    ; clear joy-pad
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    lda $4016   ; A
    lda $4016   ; B 
    lda $4016   ; SELECT
    lda $4016   ; START
    and #$01
    beq title_loop
