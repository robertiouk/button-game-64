ENEMY: {
    .label MOVE_LEFT  = %00000001
    .label MOVE_RIGHT = %00000010
    .label HEDGEHOG_SPEED = $7f
    .label MIN_X = $1c
    .label MAX_X = $3c

    enemy1X:
        .byte $00, $00, $00
    enemy1Y:
        .byte $00
    enemy1Type:
        .byte $00
    enemy1LeftTable:
        .byte $00, $00
    enemy1RightTable:
        .byte $00, $00
    enemy1Frame:
        .byte $00
    enemy1State:
        .byte $00
    enemy1Speed:
        .byte $00

    enemy2X:
        .byte $00, $00, $00
    enemy2Y:
        .byte $00
    enemy2Type:
        .byte $00
    enemy2LeftTable:
        .byte $00, $00
    enemy2RightTable:
        .byte $00, $00
    enemy2Frame:
        .byte $00
    enemy2State:
        .byte $00
    enemy2Speed:
        .byte $00

    collidingEnemy:
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
        lda TABLES.hedgehogWalkLeft
        sta enemy1LeftTable
        lda TABLES.hedgehogWalkLeft + 1
        sta enemy1LeftTable + 1
        lda TABLES.hedgehogWalkRight
        sta enemy1RightTable
        lda TABLES.hedgehogWalkRight + 1
        sta enemy1RightTable + 1
        lda #0
        sta enemy1Frame
        sta SPRITE_POINTERS + 6
        lda #BROWN
        sta VIC.SPRITE_COLOUR_6
        
        // Set sprite1 pos
        lda TABLES.levelEnemy1XLo, x
        sta enemy1X + 1
        lda TABLES.levelEnemy1XHi, x
        sta enemy1X + 2
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
        lda TABLES.hedgehogWalkLeft
        sta enemy2LeftTable
        lda TABLES.hedgehogWalkLeft + 1
        sta enemy2LeftTable + 1
        lda TABLES.hedgehogWalkRight
        sta enemy2RightTable
        lda TABLES.hedgehogWalkRight + 1
        sta enemy2RightTable + 1
        lda #0
        sta enemy2Frame
        sta SPRITE_POINTERS + 7
        lda #BROWN
        sta VIC.SPRITE_COLOUR_7

        // Set sprite2 pos
        lda TABLES.levelEnemy2XLo, x
        sta enemy2X + 1
        lda TABLES.levelEnemy2XHi, x
        sta enemy2X + 2
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
        lda enemy1X + 1
        sta VIC.SPRITE_6_X
        setSpriteMsb(6, enemy1X + 1)
        lda enemy1Y
        sta VIC.SPRITE_6_Y
        lda.zp FRAME_COUNTER
        and #%11111000  // every 8th frame
        cmp FRAME_COUNTER   
        bne drawSecond
        // Set sprite frame
        lda enemy1State
        and #MOVE_LEFT
        beq drawRight1
    drawLeft1:
        ldx enemy1Frame
        lda enemy1LeftTable, x
        jmp drawFrame
    drawRight1:
        ldx enemy1Frame
        lda enemy1RightTable, x
    drawFrame:
        sta SPRITE_POINTERS + 6
    incFrame:
        lda enemy1Frame
        cmp #1
        beq decFrame
        inc enemy1Frame
        jmp drawSecond
    decFrame:
        dec enemy1Frame

    drawSecond:
        // Set sprite position
        lda enemy2X + 1
        sta VIC.SPRITE_7_X
        setSpriteMsb(7, enemy2X + 1)
        lda enemy2Y
        sta VIC.SPRITE_7_Y
        lda.zp FRAME_COUNTER
        and #%11111000  // every 8th frame
        cmp FRAME_COUNTER   
        bne done
        // Set sprite frame
        lda enemy2State
        and #MOVE_LEFT
        beq drawRight2
    drawLeft2:
        ldx enemy2Frame
        lda enemy2LeftTable, x
        jmp drawFrame2
    drawRight2:
        ldx enemy2Frame
        lda enemy2RightTable, x
    drawFrame2:
        sta SPRITE_POINTERS + 7
    incFrame2:
        lda enemy2Frame
        cmp #1
        beq decFrame2
        inc enemy2Frame
        jmp done
    decFrame2:
        dec enemy2Frame

    done:

        rts
    }

    moveEnemy: {
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var speed = VECTOR3
        .var state = VECTOR4
        .var currentEnemy = TEMP1
        .var actualSpeed = TEMP2

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
        lda (speed), y
        sta actualSpeed
        lda PLAYER.player1State
        and #PLAYER.STATE_SUPER_SENSE
        bne slowSpeed
        lda PLAYER.player2State
        and #PLAYER.STATE_SUPER_SENSE
        bne slowSpeed
        jmp speedSet
    slowSpeed:
        clc
        ror actualSpeed
    speedSet:
        lda (state), y
    left:
        and #MOVE_LEFT
        beq right
        sec
        lda (xPos), y
        sbc actualSpeed
        sta (xPos), y
        iny
        lda (xPos), y
        sbc #0
        sta (xPos), y
        iny 
        lda (xPos), y
        sbc #0
        sta (xPos), y
        bne !+
        ldy #1
        lda (xPos), y
        cmp #MIN_X
        bcs !+
        ldy #0
        lda (state), y
        and #[255 - MOVE_LEFT]
        ora #MOVE_RIGHT
        sta (state), y
    !:
        jmp done
    right:
        lda (state), y
        and #MOVE_RIGHT
        beq done
        clc
        lda (xPos), y
        adc actualSpeed
        sta (xPos), y
        iny
        lda (xPos), y
        adc #0
        sta (xPos), y
        iny
        lda (xPos), y
        adc #0
        sta (xPos), y
        beq done
        ldy #1
        lda (xPos), y
        cmp #MAX_X
        bcc done
        ldy #0
        lda (state), y
        and #[255 - MOVE_RIGHT]
        ora #MOVE_LEFT
        sta (state), y
    done:
        lda currentEnemy
        beq !+
        dec currentEnemy
        lda currentEnemy
        jmp next
    !:

        rts
    }

    checkCollision: {
        .var enemyX = VECTOR3
        .var enemyY = VECTOR4
        .var otherYByte = TEMP3
        .var otherXByte = TEMP4

        lda collidingEnemy
        beq setupEnemy1
    setupEnemy2:
        lda #<enemy2X
        sta enemyX
        lda #>enemy2X
        sta enemyX + 1
        lda #<enemy2Y
        sta enemyY
        lda #>enemy2Y
        sta enemyY + 1
        jmp enemyDone
    setupEnemy1:
        lda #<enemy1X
        sta enemyX
        lda #>enemy1X
        sta enemyX + 1
        lda #<enemy1Y
        sta enemyY
        lda #>enemy1Y
        sta enemyY + 1
    enemyDone:

        lda #0
        sta otherYByte
        lda #1
        sta otherXByte
        jsr UTILS.checkPlayerSpriteCollision

        rts
    }
}