BUTTERFLY: {
    butterfly1Y:
        .byte $52
    butterfly1X:
        .byte $52, $00
    butterfly2Y:
        .byte $50
    butterfly2X:
        .byte $20, $01

    butterfly1AccX:
        .byte $00
    butterfly1AccY:
        .byte $00
    butterfly1MovementFrames:
        .byte $00
    butterfly1Frame:
        .byte $5c       // 40 = 1c

    butterfly2AccX:
        .byte $00
    butterfly2AccY:
        .byte $00
    butterfly2MovementFrames:
        .byte $00
    butterfly2Frame:
        .byte $5e       // 40 = 1e

    currentButterfly:
        .byte $00

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #WHITE
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #BROWN
        sta VIC.SPRITE_COLOUR_2
        sta VIC.SPRITE_COLOUR_3

        lda butterfly1Frame
        sta SPRITE_POINTERS + 2
        lda butterfly2Frame
        sta SPRITE_POINTERS + 3

        // Sprite 2 is reserved for second player
        lda VIC.SPRITE_ENABLE
        ora #%00001100
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00001100
        sta VIC.SPRITE_MULTICOLOUR

        lda #0
        sta currentButterfly
        jsr setupButterfly
        inc currentButterfly
        jsr setupButterfly

        rts
    }

    setupButterfly: {
        .var accX = VECTOR1
        .var accY = VECTOR2
        .var movementFrames = VECTOR3
        .var yPos = VECTOR4
        
        lda currentButterfly
        beq setupButterfly1
    setupButterfly2:
        lda #<butterfly2AccX
        sta accX
        lda #>butterfly2AccX
        sta accX+1
        lda #<butterfly2AccY
        sta accY
        lda #>butterfly2AccY
        sta accY+1
        lda #<butterfly2MovementFrames
        sta movementFrames
        lda #>butterfly2MovementFrames
        sta movementFrames+1
        lda #<butterfly2Y
        sta yPos
        lda #>butterfly2Y
        sta yPos + 1
        jmp setupComplete
    setupButterfly1:
        lda #<butterfly1AccX
        sta accX
        lda #>butterfly1AccX
        sta accX+1
        lda #<butterfly1AccY
        sta accY
        lda #>butterfly1AccY
        sta accY+1
        lda #<butterfly1MovementFrames
        sta movementFrames
        lda #>butterfly1MovementFrames
        sta movementFrames+1
        lda #<butterfly1Y
        sta yPos
        lda #>butterfly1Y
        sta yPos + 1
    setupComplete:
        ldy #0
        getRandom($01, $0a)
        sta (accX), y
        getRandom($01, $0a)
        sta (accY), y
        getRandom($01, $0a)
        sta (movementFrames), y
        getRandom($64, $bd)
        sta (yPos), y


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

.macro pickNewYCoord(butterfly) {
    getRandom($64, $bd)
    sta butterfly
}