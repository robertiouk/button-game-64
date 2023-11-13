BUTTERFLY: {
    butterfly1Y:
        .byte $52
    butterfly1X:
        .byte $00, $00
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

        getRandom($64, $bd)
        sta butterfly1Y
        getRandom($64, $bd)
        sta butterfly2Y

        rts
    }

    setupButterfly: {
        .var accX = VECTOR1
        .var accY = VECTOR2
        .var movementFrames = VECTOR3
        
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
    setupComplete:
        ldy #0
        getRandom($01, $04)
        sta (accX), y
        getRandom($01, $03)
        sta (accY), y
        getRandom($01, $0a)
        sta (movementFrames), y

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

    moveButterfly: {
        // Move butterfly 1 to the right
        lda butterfly1X
        clc
        adc butterfly1AccX
        sta butterfly1X
        lda butterfly1X + 1
        adc #0
        sta butterfly1X + 1
        // Move butterfly 1 up or down
        lda butterfly1AccY
        and #1      // If odd then up then move down, else, move up
        beq moveUp
        // Move down
        lda butterfly1Y
        adc butterfly1AccY
        sta butterfly1Y
        jmp checkFinishedFrames
    moveUp:
        lda butterfly1Y
        sec
        sbc butterfly1AccY
        sta butterfly1Y
    checkFinishedFrames:
        dec butterfly1MovementFrames
        lda butterfly1MovementFrames
        bne moveSecond
        lda #0
        sta currentButterfly
        jsr setupButterfly

    moveSecond:
        // Move butterfly 2 to the left

        rts
    }
}

.macro pickNewYCoord(butterfly) {
    getRandom($64, $bd)
    sta butterfly
}