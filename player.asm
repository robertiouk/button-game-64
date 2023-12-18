PLAYER: {
    .label COLLISION_SOLID = %00010000
    .label COLLISION_LEFT = $1
    .label COLLISION_RIGHT = $2

    .label PLAYER_1 = %00000001
    .label PLAYER_2 = %00000010

    .label STATE_JUMP       = %00000001
    .label STATE_FALL       = %00000010
    .label STATE_WALK_LEFT  = %00000100
    .label STATE_WALK_RIGHT = %00001000
    .label STATE_HIT        = %00010000

    .label JOY_UP = %00001
    .label JOY_DN = %00010
    .label JOY_LT = %00100
    .label JOY_RT = %01000
    .label JOY_FR = %10000

    .label JOY_PORT_A = $dc00
    .label JOY_PORT_B = $dc01

    playersActive:
        .byte $00

    player1X:
        .byte $a0, $00  // 1/16th pixel accuracy (Lo / Hi)
    player1Y:
        .byte $a8       // 1 pixel accuracy
    player1State:
        .byte $00
    player1JumpIndex:
        .byte $00
    player1JumpSprite:
        .byte $00
    player1WalkIndex:
        .byte $00
    player1WalkSpeed:
        .byte $03
    player1FloorCollision:
        .byte $00
    player1LeftCollision:
        .byte $00
    player1RightCollision:
        .byte $00
    player1SpriteCollisionSide:
        .byte $00

    player2X:
        .byte $c8, $00  // 1/16th pixel accuracy (Lo / Hi)
    player2Y:
        .byte $a8       // 1 pixel accuracy  
    player2State:
        .byte $00
    player2JumpIndex:
        .byte $00
    player2JumpSprite:
        .byte $00
    player2WalkIndex:
        .byte $00
    player2WalkSpeed:
        .byte $03
    player2FloorCollision:
        .byte $00
    player2LeftCollision:
        .byte $00
    player2RightCollision:
        .byte $00
    player2SpriteCollisionSide:
        .byte $00

    player1DefaultFrame:
        .byte $40       // dec 64
    player2DefaultFrame:
        .byte $46
    player1JumpDirection:
        .byte $00
    player2JumpDirection:
        .byte $00

    currentPlayer:
        .byte $00

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #YELLOW
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #WHITE
        sta VIC.SPRITE_COLOUR_0

        lda #ORANGE
        sta VIC.SPRITE_COLOUR_1
    
        lda #$40
        sta SPRITE_POINTERS
        lda #$46
        sta SPRITE_POINTERS + 1

        // Enable players
        lda VIC.SPRITE_ENABLE
        ora #%00000001
        ora playersActive
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00000001
        ora playersActive
        sta VIC.SPRITE_MULTICOLOUR

        lda #1
        ora playersActive
        sta VIC.SPRITE_DOUBLE_Y

        rts
    }

    drawPlayer: {
        .var currentFrame = TEMP1
        .var hitFrame = TEMP2
        .var state = VECTOR1
        .var jumpSprite = VECTOR2
        .var jumpDirection = VECTOR3
        .var walkIndex = VECTOR4

        lda #1
        sta currentPlayer
    drawNext:
        lda currentPlayer
        beq setupPlayer1
    setupPlayer2:
        lda player2DefaultFrame
        sta currentFrame
        lda #<player2State
        sta state
        lda #>player2State
        sta state + 1
        lda #<player2JumpSprite
        sta jumpSprite
        lda #>player2JumpSprite
        sta jumpSprite + 1
        lda #<player2JumpDirection
        sta jumpDirection
        lda #>player2JumpDirection
        sta jumpDirection + 1
        lda #<player2WalkIndex
        sta walkIndex
        lda #>player2WalkIndex + 1
        sta walkIndex + 1
        lda SPRITE_POINTERS + 1
        sta hitFrame
        jmp setupDone
    setupPlayer1:
        // Set sprite frame
        lda player1DefaultFrame
        sta currentFrame
        lda #<player1State
        sta state
        lda #>player1State
        sta state + 1
        lda #<player1JumpSprite
        sta jumpSprite
        lda #>player1JumpSprite
        sta jumpSprite + 1
        lda #<player1JumpDirection
        sta jumpDirection
        lda #>player1JumpDirection
        sta jumpDirection + 1
        lda #<player1WalkIndex
        sta walkIndex
        lda #>player1WalkIndex + 1
        sta walkIndex + 1
        lda SPRITE_POINTERS
        sta hitFrame
    setupDone:

        // Has player been hit?
        ldy #0
        lda (state), y
        and #STATE_HIT
        beq drawNormalFrame
        // Player is hit / alternate hit frame
        lda FRAME_COUNTER
        and #01
        beq !+
        jmp setPosition
    !:
        lda hitFrame
        cmp #82
        beq flipLeft
        lda #82
        sta currentFrame
        jmp setFrame
    flipLeft:
        lda #91
        sta currentFrame
        jmp setFrame

    drawNormalFrame:
        // Player not hit so draw normally
        lda (state), y
        and #[STATE_WALK_LEFT + STATE_WALK_RIGHT + STATE_FALL + STATE_JUMP]
        beq setFrame            // If neither of these then not walking or jumping
    !:
        lda (state), y
        and #[STATE_FALL + STATE_JUMP]
        beq walkFrame    // If either of these then don't set walk frame
    jumpFrame:
        lda (jumpSprite), y
        tax
        lda (jumpDirection), y
        and #[STATE_WALK_LEFT]
        beq jumpRight
    jumpLeft:
        lda TABLES.playerJumpLeft, x
        jmp !+
    jumpRight:
        lda TABLES.playerJumpRight, x
    !:
        sta currentFrame
        inx
        cpx #[TABLES.__playerJumpLeft - TABLES.playerJumpLeft]
        beq !+
        txa
        sta (jumpSprite), y
    !:
        jmp setFrame
    walkFrame:
        // We're walking left or right
        lda FRAME_COUNTER
        and #03             // Update every 4th frame for smooth animation
        bne setPosition
        // Update the frame
        lda (walkIndex), y
        tax
        inx
        cpx #[TABLES.__playerWalkLeft - TABLES.playerWalkLeft]
        bne !+
        ldx #0
    !:  
        txa 
        sta (walkIndex), y
        // Pick the next walking frame
        lda (state), y
        cmp #STATE_WALK_LEFT
        bne right
    left:
        lda (walkIndex), y
        tax
        lda TABLES.playerWalkLeft, x
        sta currentFrame
        jmp setFrame
    right:
        lda (walkIndex), y
        tax
        lda TABLES.playerWalkRight, x
        sta currentFrame
    setFrame:
        lda currentPlayer
        beq setPlayer1Frame
    setPlayer2Frame:
        lda currentFrame
        sta SPRITE_POINTERS + 1
        jmp setPosition
    setPlayer1Frame:
        lda currentFrame
        sta SPRITE_POINTERS

    setPosition:
        lda currentPlayer
        beq drawPlayer1X
    drawPlayer2X:
        // Set sprite position
        lda player2X
        sta VIC.SPRITE_1_X
        setSpriteMsb(1, player2X)

        lda player2Y
        sta VIC.SPRITE_1_Y
        jmp finishedDraw
    drawPlayer1X:
        // Set sprite position
        lda player1X
        sta VIC.SPRITE_0_X
        setSpriteMsb(0, player1X)

        lda player1Y
        sta VIC.SPRITE_0_Y
    finishedDraw:

        // Draw next player
        lda currentPlayer
        beq !+
        dec currentPlayer
        jmp drawNext
    !:

        rts
    }

    playerControl: {
        lda JOY_PORT_A
        sta.zp JOY1_ZP
        lda JOY_PORT_B
        sta.zp JOY2_ZP

        jsr player1Control
        lda playersActive
        cmp #2
        bne !+
        jsr player2Control
    !:

        rts
    }

    player1Control: {
        // Clear the walking states
        lda player1State
        and #STATE_HIT
        beq !+
        lda player1SpriteCollisionSide
        cmp #COLLISION_LEFT
        beq checkRightLimit
        jmp checkLeftLimit
    !:
        lda player1State
        and #[255 - STATE_WALK_LEFT - STATE_WALK_RIGHT]     // $11110011
        sta player1State

    !up:
        // If either jumping or falling then skip
        lda player1State
        and #[STATE_FALL + STATE_JUMP]  // if either are TRUE then A will be non-zero (Z == 0)
        bne !+
        // Now check if up has actually been pressed
        lda.zp JOY1_ZP
        and #JOY_UP
        // Joystick ports are high and pulled down when activated, so 0 means up is pressed
        bne !+
        lda player1State
        ora #STATE_JUMP
        sta player1State
        lda #0
        sta player1JumpIndex
        sta player1JumpSprite
    !:

    !left:
        lda.zp JOY1_ZP
        and #JOY_LT
        bne !+
    checkLeftLimit:
        // Check player has not reached left limit
        lda player1X + 1
        bne applyLeft
        lda player1X
        cmp #22
        bcc !+
    applyLeft:
        lda player1State
        ora #STATE_WALK_LEFT
        sta player1State
        sta player1JumpDirection

        lda TABLES.playerWalkLeft
        sta player1DefaultFrame

        sec
        lda player1X
        sbc player1WalkSpeed
        sta player1X
        lda player1X + 1
        sbc #0
        sta player1X + 1
        jmp !done+
    !:

    !right:
        lda.zp JOY1_ZP
        and #JOY_RT
        bne !+
    checkRightLimit:
        // Check player has not reached right limit
        lda player1X + 1
        beq applyRight
        lda player1X
        cmp #69
        bcs !+
    applyRight:
        lda player1State
        ora #STATE_WALK_RIGHT
        sta player1State
        sta player1JumpDirection

        lda TABLES.playerWalkRight
        sta player1DefaultFrame

        clc
        lda player1X
        adc player1WalkSpeed
        sta player1X
        lda player1X + 1
        adc #0
        sta player1X + 1
    !:

    !done:
        rts
    }

    player2Control: {
        // Clear the walking states
        lda player2State
        and #STATE_HIT
        beq !+
        lda player2SpriteCollisionSide
        cmp #COLLISION_LEFT
        beq checkRightLimit
        jmp checkLeftLimit
    !:
        lda player2State
        and #[255 - STATE_WALK_LEFT - STATE_WALK_RIGHT]     // $11110011
        sta player2State

    !up:
        // If either jumping or falling then skip
        lda player2State
        and #[STATE_FALL + STATE_JUMP]  // if either are TRUE then A will be non-zero (Z == 0)
        bne !+
        // Now check if up has actually been pressed
        lda.zp JOY2_ZP
        and #JOY_UP
        // Joystick ports are high and pulled down when activated, so 0 means up is pressed
        bne !+
        lda player2State
        ora #STATE_JUMP
        sta player2State
        lda #0
        sta player2JumpIndex
        sta player2JumpSprite
    !:

    !left:
        lda.zp JOY2_ZP
        and #JOY_LT
        bne !+
    checkLeftLimit:
        // Check player has not reached left limit
        lda player2X + 1
        bne applyLeft
        lda player2X
        cmp #22
        bcc !+
    applyLeft:
        lda player2State
        ora #STATE_WALK_LEFT
        sta player2State
        sta player2JumpDirection

        lda TABLES.playerWalkLeft
        sta player2DefaultFrame

        sec
        lda player2X
        sbc player2WalkSpeed
        sta player2X
        lda player2X + 1
        sbc #0
        sta player2X + 1
        jmp !done+
    !:

    !right:
        lda.zp JOY2_ZP
        and #JOY_RT
        bne !+
    checkRightLimit:
        // Check player has not reached right limit
        lda player2X + 1
        beq applyRight
        lda player2X
        cmp #69
        bcs !+
    applyRight:
        lda player2State
        ora #STATE_WALK_RIGHT
        sta player2State
        sta player2JumpDirection

        lda TABLES.playerWalkRight
        sta player2DefaultFrame

        clc
        lda player2X
        adc player2WalkSpeed
        sta player2X
        lda player2X + 1
        adc #0
        sta player2X + 1
    !:

    !done:
        rts
    }

    collisionCheck: {
        .var floorCollision = VECTOR1
        .var leftCollision = VECTOR2
        .var rightCollision = VECTOR3
        // Get floor collisions for each foot for player 1
        lda #01
        sta currentPlayer
    setupNext:
        beq setupPlayer1
    setupPlayer2:
        lda #<player2FloorCollision
        sta floorCollision
        lda #>player2FloorCollision
        sta floorCollision + 1
        lda #<player2LeftCollision
        sta leftCollision
        lda #>player2LeftCollision
        sta leftCollision + 1
        lda #<player2RightCollision
        sta rightCollision
        lda #>player2RightCollision
        sta rightCollision + 1        
        jmp setupDone
    setupPlayer1:
        lda #<player1FloorCollision
        sta floorCollision
        lda #>player1FloorCollision
        sta floorCollision + 1
        lda #<player1LeftCollision
        sta leftCollision
        lda #>player1LeftCollision
        sta leftCollision + 1
        lda #<player1RightCollision
        sta rightCollision
        lda #>player1RightCollision
        sta rightCollision + 1
    setupDone:
        ldx #04      // Left foot double-pixel location / 2
        ldy #48     // y Offset. This should be halved for small sprite (#24)
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ldy #0
        sta (floorCollision), y
        
        ldx #14      // Right foot double-pixel location / 2
        ldy #48
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ldy #0
        ora (floorCollision), y
        and #$f0
        sta (floorCollision), y

        // Get left collision
        ldx #00
        ldy #13     // Just beneath chin
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ldy #0
        sta (leftCollision), y

        // Get right collision
        ldx #23
        ldy #13     // Just beneath chin
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ldy #0
        sta (rightCollision), y
        lda currentPlayer
        beq !+
        dec currentPlayer
        lda currentPlayer
        jmp setupNext
    !:
        
        jsr checkSpriteCollisions

        rts
    }

    checkSpriteCollisions: {
        .var spriteCollision = TEMP1

        lda #1
        sta currentPlayer

        lda VIC.SPRITE_COLLISION
        sta spriteCollision
        tay

    nextPlayer:
        beq player1Collision
    player2Collision:
        lda spriteCollision
        tay
        and #%00000010
        jmp !+
    player1Collision:
        lda spriteCollision
        tay
        and #%00000001
    !:
        beq noCollision
        tya
        pha     // Store the collision value in the stack for now as it the vic register gets wiped
        and #%00000100
        bne caughtButterfly1
        tya
        and #%00001000
        beq noCatch
    caughtButterfly2:
        lda BUTTERFLY.butterfly2State
        and #BUTTERFLY.STATE_CAUGHT
        bne noCatch
        lda #1
        jmp !+
    caughtButterfly1:
        lda BUTTERFLY.butterfly1State
        and #BUTTERFLY.STATE_CAUGHT
        bne noCatch
        lda #0
    !:
        sta BUTTERFLY.currentButterfly
        jsr BUTTERFLY.checkCollision
        beq noCatch
        jsr BUTTERFLY.catchButterfly
    noCatch:

    pla

    checkEnemyCollisions:
        tay
        and #%01000000
        bne hitEnemy1
        tya
        and #%10000000
        bne hitEnemy2
        jmp noCollision
    hitEnemy1:
        lda #0
        jmp damagePlayer
    hitEnemy2:
        lda #1
    damagePlayer:
        sta ENEMY.collidingEnemy
        jsr ENEMY.checkCollision
        beq noCollision
        jsr playerHit
    noCollision:

    checkPickupCollisions:
        lda spriteCollision
        and #%00010000
        bne pickup1
        lda spriteCollision
        and #%00100000
        bne pickup2
        jmp noPickup
    pickup1:
        lda #0
        sta PICKUP.currentPickup
        jmp getPickup
    pickup2:
        lda #1
        sta PICKUP.currentPickup
    getPickup:
        jsr PICKUP.checkCollision
        beq noPickup
        jsr PICKUP.getPickup
    noPickup:

    checkNextPlayer:
        lda currentPlayer
        beq !+
        sec
        sbc #1
        sta currentPlayer
        jmp nextPlayer
    !:

        rts
    }

    // Grab the top left corner of sprite and store in zero page
    getCollisionPoint: {
        // x register contains x offset (half coordinates)
        // y register contains y offset

        // Setup variables
        .var xPixelOffset = TEMP1
        .var yPixelOffset = TEMP2
        .var playerPosition = TEMP3 // uses both TEMP3 & 4 - Lo/Hi
        .var xPos = VECTOR4
        .var yPos = VECTOR5
        .var xBorderOffset = 22
        .var yBorderOffset = 49
        stx xPixelOffset
        sty yPixelOffset

        lda currentPlayer
        beq setupPlayer1
    setupPlayer2:
        lda #<player2X
        sta xPos
        lda #>player2X
        sta xPos + 1
        lda #<player2Y
        sta yPos
        lda #>player2Y
        sta yPos + 1
        jmp setupDone
    setupPlayer1:
        lda #<player1X
        sta xPos
        lda #>player1X
        sta xPos + 1
        lda #<player1Y
        sta yPos
        lda #>player1Y
        sta yPos + 1
    setupDone:

        // Calculate x & y in screen space
        ldy #00
        lda (xPos), y
        sta playerPosition
        iny
        lda (xPos), y
        sta playerPosition + 1
        // Convert from 1:1/16 to 1:1
        lda playerPosition + 1  // Hi
        bne !+          // If > 0 skip
        lda playerPosition      // Lo
        cmp #xBorderOffset         // Left border edge
        bcs !+          // If it's > border edge do nothing
        lda #xBorderOffset         // Assume it's at the edge of the screen
        sta playerPosition
    !:
        lda playerPosition
        clc
        adc xPixelOffset
        sta playerPosition
        lda playerPosition + 1
        adc #0
        sta playerPosition + 1
        // Done 16 bit addition ^
        lda playerPosition
        sec
        sbc #xBorderOffset
        sta playerPosition
        lda playerPosition + 1
        sbc #0
        sta playerPosition + 1

        // We now have a value between 0 and 160. We need do turn into 
        // a value between 0 and 40, so divide by 4.
        lda playerPosition
        lsr playerPosition + 1
        ror 
        lsr playerPosition + 1
        ror 
        lsr playerPosition + 1
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

    jumpAndFall: {
        .var state = VECTOR1
        .var floorCollision = VECTOR2
        .var yPos = VECTOR3
        .var jumpIndex = VECTOR4

        lda #1
        sta currentPlayer
    setupNext:
        beq setupPlayer1
    setupPlayer2:
        lda #<player2State
        sta state
        lda #>player2State
        sta state + 1
        lda #<player2FloorCollision
        sta floorCollision
        lda #>player2FloorCollision
        sta floorCollision + 1
        lda #<player2Y
        sta yPos
        lda #>player2Y
        sta yPos + 1
        lda #<player2JumpIndex
        sta jumpIndex
        lda #>player2JumpIndex
        sta jumpIndex + 1
        jmp setupDone
    setupPlayer1:
        lda #<player1State
        sta state
        lda #>player1State
        sta state + 1
        lda #<player1FloorCollision
        sta floorCollision
        lda #>player1FloorCollision
        sta floorCollision + 1
        lda #<player1Y
        sta yPos
        lda #>player1Y
        sta yPos + 1
        lda #<player1JumpIndex
        sta jumpIndex
        lda #>player1JumpIndex
        sta jumpIndex + 1
    setupDone:

        // Check falling first, so we don't apply fall immediately after final jump frame

        // If character is still jumping then skip straight to jump code
        ldy #0
        lda (state), y
        and #STATE_JUMP
        bne jumpCheck
        // Check if character has hit the ground
        lda (floorCollision), y
        cmp #COLLISION_SOLID
        bne falling
        // Stop falling
        lda (state), y
        and #STATE_FALL
        beq jumpCheck
        and #[255 - STATE_FALL]
        sta (state), y
        // Snap to lower precision to snap to floor.
        // Floor will be multiple of 8, e.g., 80.
        // Worst case Y will by 7
        lda (yPos), y
        and #%11111000 // is now a multiple of 8
        ora #%00000111  // ora 101 worked well for small sprite
        clc
        adc #1
        sta (yPos), y
        // Player will not be hit now
        lda (state), y
        and #[255 - STATE_HIT]
        sta (state), y
        jmp jumpCheck
    falling:
        // If not already falling then set fall state
        lda (state), y
        and #STATE_FALL
        bne !+
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
        sec
        sbc TABLES.jumpAndFallTable, x
        sta (yPos), y
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
        lda currentPlayer
        beq !+
        sec
        sbc #1
        sta currentPlayer
        jmp setupNext
    !:

        rts
    }

    playerHit: {
        lda #STATE_HIT
        ora #STATE_JUMP
        tax

        lda currentPlayer
        beq player1Hit
    player2Hit:
        stx player2State
        jmp !+
    player1Hit:
        stx player1State
    !:
    
        rts
    }
}