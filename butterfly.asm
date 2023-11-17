BUTTERFLY: {
    yFloor:
        .byte $b4
    yCeiling:
        .byte $32
    xMin:
        .byte $32
    xMax:
        .byte $60

    butterfly1Y:
        .byte $00, $00
    butterfly1X:
        .byte $00, $00, $00
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
        lda butterfly2X
        sta VIC.SPRITE_3_X
        setSpriteMsb(3, butterfly2X)
        lda butterfly2Y
        sta VIC.SPRITE_3_Y
    
        rts
    }

    moveButterfly: {
        .var butterflyX = VECTOR1
        .var butterflyY = VECTOR2
        .var butterflyAccX = VECTOR3
        .var butterflyAccY = VECTOR4

        lda #1
        sta currentButterfly
    startSetup:
        beq setupButterfly1
    setupButterfly2:
        lda #<butterfly2X
        sta butterflyX
        lda #>butterfly2X
        sta butterflyX + 1
        lda #<butterfly2Y
        sta butterflyY
        lda #>butterfly2Y + 1
        sta butterflyY + 1
        lda #<butterfly2AccX
        sta butterflyAccX
        lda #>butterfly2AccX
        sta butterflyAccX + 1
        lda #<butterfly2AccY
        sta butterflyAccY
        lda #>butterfly2AccY 
        sta butterflyAccY + 1
        jmp setupComplete
    setupButterfly1:
        lda #<butterfly1X
        sta butterflyX
        lda #>butterfly1X
        sta butterflyX + 1
        lda #<butterfly1Y
        sta butterflyY
        lda #>butterfly1Y + 1
        sta butterflyY + 1
        lda #<butterfly1AccX
        sta butterflyAccX
        lda #>butterfly1AccX
        sta butterflyAccX + 1
        lda #<butterfly1AccY
        sta butterflyAccY
        lda #>butterfly1AccY 
        sta butterflyAccY + 1
    setupComplete:

        ldy #0
        lda currentButterfly
        beq moveRight
    moveLeft:
.break
        lda (butterflyX), y
        sec
        sbc (butterflyAccX), y
        sta (butterflyX), y
        iny
        lda (butterflyX), y
        sbc #0
        sta (butterflyX), y
        iny
        lda (butterflyX), y
        sbc #0
        sta (butterflyX), y
        bne !+
        jmp skip
    !:
        // Check if off the end of the screen
        ldy #1
        lda (butterflyX), y
        cmp xMin
        beq !+
        jmp skip
    !:
        lda #0
        ldy #0
        sta (butterflyX), y
        sta (butterflyY), y
        iny
        lda xMax
        sta (butterflyX), y
        iny
        lda #1
        sta (butterflyX), y
        sta butterfly1Y
        jsr setupButterfly
        getRandom($32, $96)
        ldy #1
        sta (butterflyY), y
        jmp skip
    moveRight:
        // Move butterfly 1 to the right
        ldy #0
        lda (butterflyX), y
        clc
        adc (butterflyAccX), y
        sta (butterflyX), y
        iny
        lda (butterflyX), y
        adc #0
        sta (butterflyX), y
        iny
        lda (butterflyX), y
        adc #0
        sta (butterflyX), y
        beq skip
        // Check if off the end of the screen
        ldy #1
        lda (butterflyX), y
        cmp xMax
        bne skip
        lda #0
        ldy #0
        sta (butterflyX), y
        sta (butterflyY), y
        iny
        sta (butterflyX), y
        iny
        sta (butterflyX), y
        jsr setupButterfly
        getRandom($32, $96)
        ldy #1
        sta (butterflyY), y
    skip:
        ldy #1
        lda (butterflyY), y
        cmp yCeiling
        bcc moveDown
        cmp yFloor
        bcs moveUp
        // Move butterfly 1 up or down
        ldy #0
        lda (butterflyAccY), y
        and #1      // If odd then up then move down, else, move up
        beq moveUp
    moveDown:
        // Move down
        ldy #0
        lda (butterflyY), y
        clc
        adc (butterflyAccY), y
        sta (butterflyY), y
        iny
        lda (butterflyY), y
        adc #0
        sta (butterflyY), y
        jmp checkFinishedFrames
    moveUp:
        ldy #0
        lda (butterflyY), y
        sec
        sbc (butterflyAccY), y
        sta (butterflyY), y
        iny
        lda (butterflyY), y
        sbc #0
        sta (butterflyY), y 
    checkFinishedFrames:
        lda currentButterfly
        beq animateFirst
        dec butterfly2MovementFrames
        lda butterfly2MovementFrames
        bne !+
        jsr setupButterfly
        jmp !+
    animateFirst:
        dec butterfly1MovementFrames
        lda butterfly1MovementFrames
        bne !+
        jsr setupButterfly
    !:
        ldx currentButterfly
        beq complete
        dex
        txa
        sta currentButterfly
        jmp startSetup
    complete:

        rts
    }
}

.macro pickNewYCoord(butterfly) {
    getRandom($64, $bd)
    sta butterfly
}