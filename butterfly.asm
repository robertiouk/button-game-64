BUTTERFLY: {
    butterfly1Y:
        .byte $52
    butterfly1X:
        .byte $52, $00

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #WHITE
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #BROWN
        sta VIC.SPRITE_COLOUR_3

        lda #[$40 + $1c]
        sta SPRITE_POINTERS + 2

        // Sprite 2 is reserved for second player
        lda VIC.SPRITE_ENABLE
        ora #%00000100
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00000100
        sta VIC.SPRITE_MULTICOLOUR

        rts
    }

    drawButterfly: {
        // Set sprite position
        lda butterfly1X
        sta VIC.SPRITE_2_X
        //lda butterfly1X + 1
        //sta VIC.SPRITE_MSB
        
        lda butterfly1Y
        sta VIC.SPRITE_2_Y
    
        rts
    }
}