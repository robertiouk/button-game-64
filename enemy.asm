ENEMY: {
    .label MOVE_LEFT  = %00000001
    .label MOVE_RIGHT = %00000010
    .label STATE_JUMP = %00000100
    .label STATE_FALL = %00001000

    .label COLLISION_SOLID = %00010000
    .label COLLISION_TURN  = %00110000
    .label COLLISION_JUMP  = %01010000

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
    enemy1CollisionPoint:
        .byte $00
    enemy1JumpIndex:
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
    enemy2CollisionPoint:
        .byte $00
    enemy2JumpIndex:
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
        .var collision = VECTOR5
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
        lda #<enemy2CollisionPoint
        sta collision
        lda #>enemy2CollisionPoint
        sta collision + 1
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
        lda #<enemy1CollisionPoint
        sta collision
        lda #>enemy1CollisionPoint
        sta collision + 1
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
        and #STATE_JUMP
        beq !noJump+
        ldx #2
        jmp left
    !noJump:
        ldx #0
    left:
        ldy #0
        lda (state), y
        and #MOVE_LEFT
        beq rightCheck
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
        bcc switchDirection
        ldy #0
        lda (collision), y
        cmp #03
        beq switchDirection
        jmp !+
    switchDirection:
        ldy #0
        lda (state), y
        and #[255 - MOVE_LEFT]
        ora #MOVE_RIGHT
        sta (state), y
    !:
        cpx #0
        beq !+
        dex
        jmp left
    !:
        jmp done
    rightCheck:
        lda (state), y
        and #STATE_JUMP
        beq !noJump+
        ldx #2
        jmp right
    !noJump:
        ldx #0
    right:
        ldy #0
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
        beq !+
        ldy #1
        lda (xPos), y
        cmp #MAX_X
        bcs !switchDirection+
        ldy #0
        lda (collision), y
        cmp #03
        beq !switchDirection+
        jmp !+
    !switchDirection:
        ldy #0
        lda (state), y
        and #[255 - MOVE_RIGHT]
        ora #MOVE_LEFT
        sta (state), y
    !:
        cpx #0
        beq !+
        dex
        jmp right
    !:
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

    jumpAndFall: {
        .var state = VECTOR1
        .var floorCollision = VECTOR2
        .var yPos = VECTOR3
        .var jumpIndex = VECTOR4
        .var currentEnemy = TEMP1

        jsr floorCollisionCheck
        
        lda #1
        sta currentEnemy
    setupNext:
        beq setupEnemy1
    setupEnemy2:
        lda enemy2Type
        cmp #ENEMY_SPIDER
        beq !+
        dec currentEnemy
        jmp setupNext
    !:
        lda #<enemy2State
        sta state
        lda #>enemy2State
        sta state + 1
        lda #<enemy2CollisionPoint
        sta floorCollision
        lda #>enemy2CollisionPoint
        sta floorCollision + 1
        lda #<enemy2Y
        sta yPos
        lda #>enemy2Y
        sta yPos + 1
        lda #<enemy2JumpIndex
        sta jumpIndex
        lda #>enemy2JumpIndex
        sta jumpIndex + 1
        jmp setupDone
    setupEnemy1:
        lda enemy1Type
        cmp #ENEMY_SPIDER
        beq !+
        jmp done
    !:
        lda #<enemy1State
        sta state
        lda #>enemy1State
        sta state + 1
        lda #<enemy1CollisionPoint
        sta floorCollision
        lda #>enemy1CollisionPoint
        sta floorCollision + 1
        lda #<enemy1Y
        sta yPos
        lda #>enemy1Y
        sta yPos + 1
        lda #<enemy1JumpIndex
        sta jumpIndex
        lda #>enemy1JumpIndex
        sta jumpIndex + 1
    setupDone:

        // ********* Check Enemy 1 **********
        ldy #0
        lda (floorCollision), y
        cmp #COLLISION_JUMP
        bne !+
        // Jump
        lda (state), y
        ora #STATE_JUMP
        sta (state), y
    !:

        // If character is still jumping then skip straight to jump code
        lda (state), y
        and #STATE_JUMP
        bne jumpCheck
        // Check if character has hit the ground
        lda (floorCollision), y
        and #COLLISION_SOLID
        beq falling
        // Stop falling
        lda #0
        sta (jumpIndex), y

        lda (state), y
        and #STATE_FALL
        beq jumpCheck
        lda (state), y
        and #[255 - STATE_FALL]
        sta (state), y
        // Snap to lower precision to snap to floor.
        // Floor will be multiple of 8, e.g., 80.
        // Worst case Y will by 7
        lda (yPos), y
        and #%11111000 // is now a multiple of 8
        ora #%00000101  // ora 101 worked well for small sprite
        sta (yPos), y
        jmp jumpCheck
    falling:
        // If not already falling then set fall state
        lda (state), y
        and #STATE_FALL
        bne !+
        lda (state), y
        ora #STATE_FALL
        sta (state), y
        // Pick first falling frame
        lda #[TABLES.__jumpAndFallTable - TABLES.jumpAndFallTable - 1]
        sta (jumpIndex), y
    !:
        // If already falling then apply next fall frame
        lda (jumpIndex), y
        tax
        lda (yPos), y
        clc
        adc TABLES.jumpAndFallTable, x
        sta (yPos), y
        // Proceed fall frame
        cpx #0
        beq jumpCheck   // Fall frame is max (zero)
        dex
        txa
        sta (jumpIndex), y
    jumpCheck:
        // Check jump state
        lda (state), y
        and #STATE_JUMP
        beq jumpCheckFinished
        // Get the current jump frame
        lda (jumpIndex), y
        tax
        // Decrement Y by current frame
        lda (yPos), y
        cmp #$8
        bcc jumpApplied
        sec
        sbc TABLES.jumpAndFallTable, x
        sta (yPos), y
    jumpApplied:
        // Have we reached the final jump frame?
        inx
        txa 
        sta (jumpIndex), y
        cpx #[TABLES.__jumpAndFallTable - TABLES.jumpAndFallTable]
        bne jumpCheckFinished
        lda (state), y
        and #[255 - STATE_JUMP]
        ora #STATE_FALL     // If this wasn't here we could double jump...
        sta (state), y    // We're now falling
        lda (jumpIndex), y
        sec
        sbc #1
        sta (jumpIndex), y   // ...otherwise we'd be off the end of the table
    jumpCheckFinished: 
        lda currentEnemy
        beq !+
        sec
        sbc #1
        sta currentEnemy
        jmp setupNext
    !:

    done:

        rts
    }

    floorCollisionCheck: {
        // Assume values for spider, as only spider can jump and fall
        lda enemy1Type
        cmp #ENEMY_SPIDER
        bne checkSecond
        // Do collision check for enemy 1
        // Left foot
        lda #0
        ldx #0      // Left double-pixel location / 2
        ldy #25      // y Offset. This should be halved for small sprite (#24)
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        and #$f0
        sta enemy1CollisionPoint
        // Right foot
        lda #0
        ldx #22     // Right double-pixel location / 2
        ldy #25
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ora enemy1CollisionPoint
        and #$f0
        sta enemy1CollisionPoint

    checkSecond:
        lda enemy2Type
        cmp #ENEMY_SPIDER
        bne done
        // Do collision check for pickup 2
        // Left foot
        lda #1
        ldx #0      // Left foot double-pixel location / 2
        ldy #25      // y Offset. This should be halved for small sprite (#24)
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        and #$f0
        sta enemy2CollisionPoint
        // Right foot
        lda #1
        ldx #22     // Right double-pixel location / 2
        ldy #25
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ora enemy2CollisionPoint
        and #$f0
        sta enemy2CollisionPoint
        
    done:
        rts
    }

    // Grab the top left corner of sprite and store in zero page
    getCollisionPoint: {
        // a register contains the pickup to assess
        // x register contains x offset (half coordinates)
        // y register contains y offset

        // Setup variables
        .var xPixelOffset = TEMP1
        .var yPixelOffset = TEMP2
        .var enemyPosition = TEMP3 // uses both TEMP3 & 4 - Lo/Hi
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var xBorderOffset = 22
        .var yBorderOffset = 49
        stx xPixelOffset
        sty yPixelOffset

        cmp #0
        beq setup1
    setup2:
        lda #<enemy2X
        sta xPos
        lda #>enemy2X
        sta xPos + 1
        lda #<enemy2Y
        sta yPos
        lda #>enemy2Y
        sta yPos + 1
        jmp setupComplete
    setup1:
        lda #<enemy1X
        sta xPos
        lda #>enemy1X
        sta xPos + 1
        lda #<enemy1Y
        sta yPos
        lda #>enemy1Y
        sta yPos + 1
    setupComplete:

        // Calculate x & y in screen space
        ldy #01
        lda (xPos), y   // screen x
        sta enemyPosition
        iny
        lda (xPos), y   // msb
        sta enemyPosition + 1
        // Convert from 1:1/16 to 1:1
        lda enemyPosition + 1  // Hi
        bne !+          // If > 0 skip
        lda enemyPosition     // Lo
        cmp #xBorderOffset         // Left border edge
        bcs !+          // If it's > border edge do nothing
        lda #xBorderOffset         // Assume it's at the edge of the screen
        sta enemyPosition
    !:
        lda enemyPosition
        clc
        adc xPixelOffset
        sta enemyPosition
        lda enemyPosition + 1
        adc #0
        sta enemyPosition + 1
        // Done 16 bit addition ^
        lda enemyPosition
        sec
        sbc #xBorderOffset
        sta enemyPosition
        lda enemyPosition + 1
        sbc #0
        sta enemyPosition + 1

        // We now have a value between 0 and 160. We need do turn into 
        // a value between 0 and 40, so divide by 4.
        lda enemyPosition
        lsr enemyPosition + 1
        ror 
        lsr enemyPosition + 1
        ror 
        lsr enemyPosition + 1
        ror 

        tax

        ldy #0
        lda (yPos), y
        
        cmp #yBorderOffset         // Top of screen
        bcs !+
        lda #yBorderOffset
    !:
        clc
        adc yPixelOffset
        sec 
        sbc #yBorderOffset
        // Divide by 8 because while x is stored in half values, y
        // is stored in quarter values
        lsr             
        lsr
        lsr

        tay

        rts
    }
}