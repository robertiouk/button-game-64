BUTTERFLY: {
    butterfly1Y:
        .byte $52
    butterfly1X:
        .byte $52, $00
    butterfly2Y:
        .byte $50
    butterfly2X:
        .byte $20, $01

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #WHITE
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #BROWN
        sta VIC.SPRITE_COLOUR_2
        sta VIC.SPRITE_COLOUR_3

        lda #[$40 + $1c]
        sta SPRITE_POINTERS + 2
        lda #[$40 + $1e]
        sta SPRITE_POINTERS + 3

        // Sprite 2 is reserved for second player
        lda VIC.SPRITE_ENABLE
        ora #%00001100
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00001100
        sta VIC.SPRITE_MULTICOLOUR

        rts
    }

    drawButterfly: {
        // Set sprite position
        lda butterfly1X
        sta VIC.SPRITE_2_X
        setSpriteMsb(2, butterfly1X)
        lda butterfly1Y
        sta VIC.SPRITE_2_Y

        lda butterfly2X
        sta VIC.SPRITE_3_X
        setSpriteMsb(3, butterfly2X)
        lda butterfly2Y
        sta VIC.SPRITE_3_Y
    
        rts
    }
}