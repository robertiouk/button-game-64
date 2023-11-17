BUTTERFLY: {
    yFloor:
        .byte $b4
    yCeiling:
        .byte $32
    xMin:
        .byte $12
    xMax:
        .byte $60

    butterfly1Y:
        .byte $00, $00
    butterfly1X:
        .byte $00, $00, $00
    butterfly2Y:
        .byte $00, $00
    butterfly2X:
        .byte $00, $60, $01

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

        getRandom($32, $96)
        sta butterfly1Y + 1
        getRandom($32, $96)
        sta butterfly2Y + 1

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
        getRandom($01, $ff)
        ldy #0
        sta (accX), y
        getRandom($01, $7f)
        ldy #0
        sta (accY), y
        getRandom($01, $14)
        ldy #0
        sta (movementFrames), y

        rts
    }

    drawButterfly: {
        // Set sprite position
        lda butterfly1X + 1
        sta VIC.SPRITE_2_X
        setSpriteMsb(2, butterfly1X + 1)
        lda butterfly1Y + 1
        sta VIC.SPRITE_2_Y
        lda.zp FRAME_COUNTER
        and #3
        bne drawSecond
        // Set sprite frame
        lda butterfly1Frame
        cmp #$5d
        beq decFrame
        inc butterfly1Frame
        jmp !+
    decFrame:
        dec butterfly1Frame
    !:
        lda butterfly1Frame
        sta SPRITE_POINTERS + 2

    drawSecond:
        lda butterfly2X + 1
        sta VIC.SPRITE_3_X
        setSpriteMsb(3, butterfly2X + 1)
        lda butterfly2Y + 1
        sta VIC.SPRITE_3_Y
        lda.zp FRAME_COUNTER
        and #3
        bne done
        // Set sprite frame
        lda butterfly2Frame
        cmp #$5f
        beq decFrame2
        inc butterfly2Frame
        jmp !+
    decFrame2:
        dec butterfly2Frame
    !:
        lda butterfly2Frame
        sta SPRITE_POINTERS + 3
    done:

        rts
    }

    moveButterfly: {
    butterfly1:
        // Move butterfly 1 to the right
        lda butterfly1X
        clc
        adc butterfly1AccX
        sta butterfly1X
        lda butterfly1X + 1
        adc #0
        sta butterfly1X + 1
        lda butterfly1X + 2
        adc #0
        sta butterfly1X + 2
        beq butterfly2
        // Check if off the end of the screen (right)
        lda butterfly1X + 1
        cmp xMax
        bne butterfly2
        lda #0
        sta butterfly1X
        sta butterfly1Y
        sta butterfly1X + 1
        sta butterfly1X + 2
        jsr setupButterfly
        getRandom($32, $96)
        sta butterfly1Y + 1
    butterfly2:
        lda butterfly2X
        sec
        sbc butterfly2AccX
        sta butterfly2X
        lda butterfly2X + 1
        sbc #0
        sta butterfly2X + 1
        lda butterfly2X + 2
        sbc #0
        sta butterfly2X + 2
        bne moveY
        // Check if off the end of the screen (left)
        lda butterfly2X + 1
        cmp xMin
        bne moveY
        lda #0
        sta butterfly2X
        sta butterfly2Y
        lda xMax
        sta butterfly2X + 1
        lda #1
        sta butterfly2X + 2
        sta currentButterfly
        jsr setupButterfly
        getRandom($32, $96)
        sta butterfly2Y + 1
    moveY:
        jsr moveSpritesY
    checkFinishedFrames:
        dec butterfly1MovementFrames
        lda butterfly1MovementFrames
        bne !+
        lda #0
        sta currentButterfly
        jsr setupButterfly
    !:
        dec butterfly2MovementFrames
        lda butterfly2MovementFrames
        bne done
        lda #1
        sta currentButterfly
        jsr setupButterfly
    done:
        rts
    }

    moveSpritesY: {
        .var yPos = VECTOR1
        .var yAcc = VECTOR2

        lda #1
        sta currentButterfly
    moveNext:
        beq move1
    move2:
        lda #<butterfly2Y
        sta yPos
        lda #>butterfly2Y
        sta yPos +1
        lda #<butterfly2AccY
        sta yAcc
        lda #>butterfly2AccY
        sta yAcc +1
        jmp setupComplete
    move1:  
        lda #<butterfly1Y
        sta yPos
        lda #>butterfly1Y
        sta yPos +1
        lda #<butterfly1AccY
        sta yAcc
        lda #>butterfly1AccY
        sta yAcc +1
    setupComplete:

        ldy #1
        lda (yPos), y
        cmp yCeiling
        bcc moveDown
        cmp yFloor
        bcs moveUp
        // Move butterfly 1 up or down
        ldy #0
        lda (yAcc), y
        and #1      // If odd then up then move down, else, move up
        beq moveUp
    moveDown:
        ldy #0
        // Move down
        lda (yPos), y
        clc
        adc (yAcc), y
        sta (yPos), y
        iny
        lda (yPos), y
        adc #0
        sta (yPos), y
        jmp done
    moveUp:
        ldy #0
        lda (yPos), y
        sec
        sbc (yAcc), y
        sta (yPos), y
        iny
        lda (yPos), y
        sbc #0
        sta (yPos), y 
    done:
        lda currentButterfly
        beq !+
        dec currentButterfly
        jmp moveNext
    !:

        rts
    }
}

.macro pickNewYCoord(butterfly) {
    getRandom($64, $bd)
    sta butterfly
}