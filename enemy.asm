ENEMY: {
    .label MOVE_LEFT  = %00000001
    .label MOVE_RIGHT = %00000010
    .label HEDGEHOG_SPEED = $7f
    .label HEDGEHOG_ANIMATION_SPEED = %11111000  // every 8th frame
    .label BIRD_SPEED = $ff
    .label BIRD_ANIMATION_SPEED = %11111100 // every 4th frame
    .label SPIDER_SPEED = $ff
    .label SPIDER_ANIMATION_SPEED = %11111110 // every 2nd frame
    .label MIN_X = $1c
    .label MAX_X = $3c
    .label ENEMY_HEDGEHOG = $01
    .label ENEMY_BIRD = $02
    .label ENEMY_SPIDER = $03

    enemy1X:
        .byte $00, $00, $00
    enemy1Y:
        .byte $00
    enemy1Type:
        .byte $00
    enemy1Frame:
        .byte $00
    enemy1Frames:
        .byte $00
    enemy1AnimationSpeed:
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
    enemy2Frame:
        .byte $00
    enemy2Frames:
        .byte $00
    enemy2AnimationSpeed:
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
        cmp #ENEMY_HEDGEHOG
        beq hedgehogRight
        cmp #ENEMY_BIRD
        beq birdRight
        cmp #ENEMY_SPIDER
        beq spiderRight
    hedgehogRight:
        // Set the number of animation frames
        lda #[TABLES.__hedgehogWalkRight - TABLES.hedgehogWalkRight - 1]
        sta enemy1Frames
        lda #<TABLES.hedgehogWalkRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE
        lda #>TABLES.hedgehogWalkRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.hedgehogWalkLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE
        lda #>TABLES.hedgehogWalkLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE + 1

        lda #HEDGEHOG_ANIMATION_SPEED
        sta enemy1AnimationSpeed

        lda #0
        sta enemy1Frame
        sta SPRITE_POINTERS + 6
        lda #BROWN
        sta VIC.SPRITE_COLOUR_6
        
        lda #HEDGEHOG_SPEED
        sta enemy1Speed
        jmp setSprite1Pos
    birdRight:
        // Set the number of animation frames
        lda #[TABLES.__birdFlyRight - TABLES.birdFlyRight - 1]
        sta enemy1Frames
        lda #<TABLES.birdFlyRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE
        lda #>TABLES.birdFlyRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.birdFlyLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE
        lda #>TABLES.birdFlyLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE + 1

        lda #BIRD_ANIMATION_SPEED
        sta enemy1AnimationSpeed

        lda #0
        sta enemy1Frame
        sta SPRITE_POINTERS + 6
        lda #BROWN
        sta VIC.SPRITE_COLOUR_6

        lda #BIRD_SPEED
        sta enemy1Speed
        jmp setSprite1Pos
    spiderRight:
        // Set the number of animation frames
        lda #[TABLES.__spiderWalkRight - TABLES.spiderWalkRight - 1]
        sta enemy1Frames
        lda #<TABLES.spiderWalkRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE
        lda #>TABLES.spiderWalkRight
        sta.zp ENEMY1_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.spiderWalkLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE
        lda #>TABLES.spiderWalkLeft
        sta.zp ENEMY1_LEFT_FRAME_TABLE + 1

        lda #SPIDER_ANIMATION_SPEED
        sta enemy1AnimationSpeed

        lda #0
        sta enemy1Frame
        sta SPRITE_POINTERS + 6
        lda #BROWN
        sta VIC.SPRITE_COLOUR_6

        lda #SPIDER_SPEED
        sta enemy1Speed

    setSprite1Pos:
        // Set sprite1 pos
        lda TABLES.levelEnemy1XLo, x
        sta enemy1X + 1
        lda TABLES.levelEnemy1XHi, x
        sta enemy1X + 2
        lda TABLES.levelEnemy1Y, x
        sta enemy1Y
        lda #MOVE_RIGHT
        sta enemy1State


    // ************ Second Enemy *************
    setupSecond:
        // Setup the second enemy
        lda TABLES.levelEnemy2Type, x
        sta enemy2Type
        cmp #ENEMY_HEDGEHOG
        beq hedgehogLeft
        cmp #ENEMY_BIRD
        beq birdLeft
        cmp #ENEMY_SPIDER
        beq spiderLeft
    hedgehogLeft:
        // Set the number of animation frames
        lda #[TABLES.__hedgehogWalkLeft - TABLES.hedgehogWalkLeft - 1]
        sta enemy2Frames
        lda #<TABLES.hedgehogWalkRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE
        lda #>TABLES.hedgehogWalkRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.hedgehogWalkLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE
        lda #>TABLES.hedgehogWalkLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE + 1

        lda #HEDGEHOG_ANIMATION_SPEED
        sta enemy2AnimationSpeed

        lda #0
        sta enemy2Frame
        sta SPRITE_POINTERS + 7
        lda #BROWN
        sta VIC.SPRITE_COLOUR_7

        lda #HEDGEHOG_SPEED
        sta enemy2Speed
        jmp setSprite2Pos
    birdLeft:
        // Set the number of animation frames
        lda #[TABLES.__birdFlyLeft - TABLES.birdFlyLeft - 1]
        sta enemy2Frames
        lda #<TABLES.birdFlyRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE
        lda #>TABLES.birdFlyRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.birdFlyLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE
        lda #>TABLES.birdFlyLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE + 1

        lda #BIRD_ANIMATION_SPEED
        sta enemy2AnimationSpeed

        lda #0
        sta enemy2Frame
        sta SPRITE_POINTERS + 7
        lda #BROWN
        sta VIC.SPRITE_COLOUR_7

        lda #BIRD_SPEED
        sta enemy2Speed
        jmp setSprite2Pos
    spiderLeft:
        // Set the number of animation frames
        lda #[TABLES.__spiderWalkRight - TABLES.spiderWalkRight - 1]
        sta enemy2Frames
        lda #<TABLES.spiderWalkRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE
        lda #>TABLES.spiderWalkRight
        sta.zp ENEMY2_RIGHT_FRAME_TABLE + 1
        lda #<TABLES.spiderWalkLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE
        lda #>TABLES.spiderWalkLeft
        sta.zp ENEMY2_LEFT_FRAME_TABLE + 1

        lda #SPIDER_ANIMATION_SPEED
        sta enemy2AnimationSpeed

        lda #0
        sta enemy2Frame
        sta SPRITE_POINTERS + 7
        lda #BROWN
        sta VIC.SPRITE_COLOUR_7

        lda #SPIDER_SPEED
        sta enemy2Speed

    setSprite2Pos:
        // Set sprite2 pos
        lda TABLES.levelEnemy2XLo, x
        sta enemy2X + 1
        lda TABLES.levelEnemy2XHi, x
        sta enemy2X + 2
        lda TABLES.levelEnemy2Y, x
        sta enemy2Y
        lda #MOVE_LEFT
        sta enemy2State

        rts
    }

    drawEnemy: {
        .var actualAnimationSpeed1 = TEMP1
        .var actualAnimationSpeed2 = TEMP2

        // Initial setup
        lda enemy1AnimationSpeed
        sta actualAnimationSpeed1
        lda enemy2AnimationSpeed
        sta actualAnimationSpeed2
        // Check for player super sense and adjust animation speed
        lda PLAYER.player1State
        and #PLAYER.STATE_SUPER_SENSE
        bne slowSpeed
        lda PLAYER.player2State
        and #PLAYER.STATE_SUPER_SENSE
        bne slowSpeed
        jmp speedSet
    slowSpeed:
        clc
        rol actualAnimationSpeed1
        clc
        rol actualAnimationSpeed2
    speedSet:

        // ********* Draw Enemy 1 ***********
        // Set sprite position
        lda enemy1X + 1
        sta VIC.SPRITE_6_X
        setSpriteMsb(6, enemy1X + 1)
        lda enemy1Y
        sta VIC.SPRITE_6_Y
        lda.zp FRAME_COUNTER
        and actualAnimationSpeed1
        cmp FRAME_COUNTER   
        bne drawSecond
        // Set sprite frame
        lda enemy1State
        and #MOVE_LEFT
        beq drawRight1
    drawLeft1:
        ldy enemy1Frame
        lda (ENEMY1_LEFT_FRAME_TABLE), y
        jmp drawFrame
    drawRight1:
        ldy enemy1Frame
        lda (ENEMY1_RIGHT_FRAME_TABLE), y
    drawFrame:
        sta SPRITE_POINTERS + 6
    incFrame:
        lda enemy1Frame
        cmp enemy1Frames
        beq resetFrame
        inc enemy1Frame
        jmp drawSecond
    resetFrame:
        lda #0
        sta enemy1Frame

    // ********* Draw Enemy 2 ***********
    drawSecond:
        // Set sprite position
        lda enemy2X + 1
        sta VIC.SPRITE_7_X
        setSpriteMsb(7, enemy2X + 1)
        lda enemy2Y
        sta VIC.SPRITE_7_Y
        lda.zp FRAME_COUNTER
        and actualAnimationSpeed2
        cmp FRAME_COUNTER   
        bne done
        // Set sprite frame
        lda enemy2State
        and #MOVE_LEFT
        beq drawRight2
    drawLeft2:
        ldy enemy2Frame
        lda (ENEMY2_LEFT_FRAME_TABLE), y
        jmp drawFrame2
    drawRight2:
        ldy enemy2Frame
        lda (ENEMY2_RIGHT_FRAME_TABLE), y
    drawFrame2:
        sta SPRITE_POINTERS + 7
    incFrame2:
        lda enemy2Frame
        cmp enemy2Frames
        beq !resetFrame+
        inc enemy2Frame
        jmp done
    !resetFrame:
        lda #0
        sta enemy2Frame

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