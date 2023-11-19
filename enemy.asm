ENEMY: {
    .label MOVE_LEFT  = %00000001
    .label MOVE_RIGHT = %00000010
    .label HEDGEHOG_SPEED = $01

    enemy1X:
        .byte $00, $00
    enemy1Y:
        .byte $00
    enemy1Type:
        .byte $00
    enemy1Frame:
        .byte $00
    enemy1MaxFrame:
        .byte $00
    enemy1State:
        .byte $00
    enemy1Speed:
        .byte $00

    enemy2X:
        .byte $00, $00
    enemy2Y:
        .byte $00
    enemy2Type:
        .byte $00
    enemy2Frame:
        .byte $00
    enemy2MaxFrame:
        .byte $00
    enemy2State:
        .byte $00
    enemy2Speed:
        .byte $00

    initialise: {
        ldx LEVEL

        // Enable enemy sprites
        lda VIC.SPRITE_ENABLE
        ora #%11000000
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%11000000
        sta VIC.SPRITE_MULTICOLOUR

        // Get the first enemy type
        lda TABLES.levelEnemy1Type, x
        sta enemy1Type
        cmp #1
        beq hedgehogRight
    hedgehogRight:
        lda #$64
        sta enemy1Frame
        sta enemy1MaxFrame
        inc enemy1MaxFrame
        sta SPRITE_POINTERS + 6
        lda #BROWN
        sta VIC.SPRITE_COLOUR_6
        
        // Set sprite1 pos
        lda TABLES.levelEnemy1XLo, x
        sta enemy1X
        lda TABLES.levelEnemy1XHi, x
        sta enemy1X + 1
        lda TABLES.levelEnemy1Y, x
        sta enemy1Y
        lda #MOVE_RIGHT
        sta enemy1State
        lda #HEDGEHOG_SPEED
        sta enemy1Speed

        // Setup the second enemy
        lda TABLES.levelEnemy2Type, x
        sta enemy2Type
        cmp #1
        beq hedgehogLeft
    hedgehogLeft:
        lda #$62
        sta enemy2Frame
        sta enemy2MaxFrame
        inc enemy2MaxFrame
        sta SPRITE_POINTERS + 7
        lda #BROWN
        sta VIC.SPRITE_COLOUR_7

        // Set sprite2 pos
        lda TABLES.levelEnemy2XLo, x
        sta enemy2X
        lda TABLES.levelEnemy2XHi, x
        sta enemy2X + 1
        lda TABLES.levelEnemy2Y, x
        sta enemy2Y
        lda #MOVE_LEFT
        sta enemy2State
        lda #HEDGEHOG_SPEED
        sta enemy2Speed

        rts
    }

    drawEnemy: {
        // Set sprite position
        lda enemy1X
        sta VIC.SPRITE_6_X
        setSpriteMsb(6, enemy1X)
        lda enemy1Y
        sta VIC.SPRITE_6_Y
        lda.zp FRAME_COUNTER
        and #%11111000  // every 8th frame
        cmp FRAME_COUNTER   
        bne drawSecond
        // Set sprite frame
        lda enemy1Frame
        cmp enemy1MaxFrame
        beq decFrame
        inc enemy1Frame
        jmp !+
    decFrame:
        dec enemy1Frame
    !:
        lda enemy1Frame
        sta SPRITE_POINTERS + 6

    drawSecond:
        // Set sprite position
        lda enemy2X
        sta VIC.SPRITE_7_X
        setSpriteMsb(7, enemy2X)
        lda enemy2Y
        sta VIC.SPRITE_7_Y
        lda.zp FRAME_COUNTER
        and #%11111000  // every 8th frame
        cmp FRAME_COUNTER   
        bne done
        // Set sprite frame
        lda enemy2Frame
        cmp enemy2MaxFrame
        beq decFrame2
        inc enemy2Frame
        jmp !+
    decFrame2:
        dec enemy2Frame
    !:
        lda enemy2Frame
        sta SPRITE_POINTERS + 7
    done:

        rts
    }

    moveEnemy: {
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var speed = VECTOR3
        .var state = VECTOR4
        .var currentEnemy = TEMP1

        lda #1
        sta currentEnemy
    next:
        beq setupEnemy1
    setupEnemy2:
        lda #<enemy2X
        sta xPos
        lda #>enemy2X
        sta xPos + 1
        lda #<enemy2Y
        sta yPos
        lda #>enemy2Y 
        sta yPos + 1
        lda #<enemy2State
        sta state
        lda #>enemy2State
        sta state + 1
        lda #<enemy2Speed
        sta speed
        lda #>enemy2Speed
        sta speed + 1
        jmp setupComplete
    setupEnemy1:
        lda #<enemy1X
        sta xPos
        lda #>enemy1X
        sta xPos + 1
        lda #<enemy1Y
        sta yPos
        lda #>enemy1Y 
        sta yPos + 1
        lda #<enemy1State
        sta state
        lda #>enemy1State
        sta state + 1
        lda #<enemy1Speed
        sta speed
        lda #>enemy1Speed
        sta speed + 1
    setupComplete:

        ldy #0
        lda (state), y
    left:
        and #MOVE_LEFT
        beq right
        sec
        lda (xPos), y
        sbc (speed), y
        sta (xPos), y
        iny
        lda (xPos), y
        sbc #0
        sta (xPos), y
        jmp done
    right:
        lda (state), y
        and #MOVE_RIGHT
        beq done
        clc
        lda (xPos), y
        adc (speed), y
        sta (xPos), y
        iny
        lda (xPos), y
        adc #0
        sta (xPos), y
    done:
        lda currentEnemy
        beq !+
        dec currentEnemy
        lda currentEnemy
        jmp next
    !:

        rts
    }
}