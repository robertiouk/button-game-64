PLAYER: {
    .label COLLISION_SOLID = %00010000

    .label PLAYER_1 = %00000001
    .label PLAYER_2 = %00000010

    .label STATE_JUMP       = %00000001
    .label STATE_FALL       = %00000010
    .label STATE_WALK_LEFT  = %00000100
    .label STATE_WALK_RIGHT = %00001000

    .label JOY_UP = %00001
    .label JOY_DN = %00010
    .label JOY_LT = %00100
    .label JOY_RT = %01000
    .label JOY_FR = %10000

    .label JOY_PORT_A = $dc00

    playersActive:
        .byte $00
    player1X:
        .byte $a0, $00  // 1/16th pixel accuracy (Lo / Hi)
    player1Y:
        .byte $a8       // 1 pixel accuracy
    player2X:
        .byte $80       // 1 pixel accuracy
    player2Y:
        .byte $bd       // 1 pixel accuracy  
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

    defaultFrame:
        .byte $40       // dec 64
    jumpDirection:
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

        // For now only enable player 1
        lda VIC.SPRITE_ENABLE
        ora #%00000001
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00000001
        sta VIC.SPRITE_MULTICOLOUR

        lda #1
        sta playersActive
        sta VIC.SPRITE_DOUBLE_Y
        
        rts
    }

    drawPlayer: {
        .var currentFrame = TEMP1

        // Set sprite frame
        lda defaultFrame
        sta currentFrame

        lda player1State
        and #[STATE_WALK_LEFT + STATE_WALK_RIGHT + STATE_FALL + STATE_JUMP]
        beq setFrame    // If neither of these then not walking
        lda player1State
        and #[STATE_FALL + STATE_JUMP]
        beq walkFrame    // If either of these then don't set walk frame
    jumpFrame:
        ldx player1JumpSprite
        lda jumpDirection
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
        stx player1JumpSprite
    !:
        jmp setFrame
    walkFrame:
        // We're walking left or right
        lda FRAME_COUNTER
        and #03             // Update every 4th frame for smooth animation
        bne setPosition
        // Update the frame
        lda player1WalkIndex
        tax
        inx
        cpx #[TABLES.__playerWalkLeft - TABLES.playerWalkLeft]
        bne !+
        ldx #0
    !:  
        stx player1WalkIndex
        // Pick the next walking frame
        lda player1State
        cmp #STATE_WALK_LEFT
        bne right
    left:
        ldx player1WalkIndex
        lda TABLES.playerWalkLeft, x
        sta currentFrame
        jmp setFrame
    right:
        ldx player1WalkIndex
        lda TABLES.playerWalkRight, x
        sta currentFrame
    setFrame:
        lda currentFrame
        sta SPRITE_POINTERS

    setPosition:
        // Set sprite position
        lda player1X
        sta VIC.SPRITE_0_X
        setSpriteMsb(0, player1X)

        lda player1Y
        sta VIC.SPRITE_0_Y

        rts
    }

    playerControl: {
        lda JOY_PORT_A
        sta.zp JOY1_ZP

        // Clear the walking states
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

        lda player1State
        ora #STATE_WALK_LEFT
        sta player1State
        sta jumpDirection

        lda TABLES.playerWalkLeft
        sta defaultFrame

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

        lda player1State
        ora #STATE_WALK_RIGHT
        sta player1State
        sta jumpDirection

        lda TABLES.playerWalkRight
        sta defaultFrame

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

    collisionCheck: {
        // Get floor collisions for each foot for player 1
        lda #00
        ldx #04      // Left foot double-pixel location / 2
        ldy #48     // y Offset. This should be halved for small sprite (#24)
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        sta player1FloorCollision
        
        lda #00
        ldx #14      // Right foot double-pixel location / 2
        ldy #48
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        ora player1FloorCollision
        and #$f0
        sta player1FloorCollision

        // Get left collision
        lda #00
        ldx #00
        ldy #13     // Just beneath chin
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        sta player1LeftCollision

        // Get right collision
        lda #00
        ldx #23
        ldy #13     // Just beneath chin
        jsr PLAYER.getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        sta player1RightCollision
        
        jsr checkButterflyCaught

        rts
    }

    checkButterflyCaught: {
        lda VIC.SPRITE_COLLISION
        tay
        and #%00000001
        beq noCatch
        tya
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
        .var xBorderOffset = 22
        .var yBorderOffset = 49
        stx xPixelOffset
        sty yPixelOffset

        // Calculate x & y in screen space
        ldy #00
        lda player1X, y
        sta playerPosition
        iny
        lda player1X, y
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

        lda player1Y
        
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
        // Check falling first, so we don't apply fall immediately after final jump frame

        // If character is still jumping then skip straight to jump code
        lda player1State
        and #STATE_JUMP
        bne jumpCheck
        // Check if character has hit the ground
        lda player1FloorCollision
        cmp #COLLISION_SOLID
        bne falling
        // Stop falling
        lda player1State
        and #STATE_FALL
        beq jumpCheck
        and #[255 - STATE_FALL]
        sta player1State
        // Snap to lower precision to snap to floor.
        // Floor will be multiple of 8, e.g., 80.
        // Worst case Y will by 7
        lda player1Y
        and #%11111000 // is now a multiple of 8
        ora #%00000111  // ora 101 worked well for small sprite
        sta player1Y
        inc player1Y
        jmp jumpCheck
    falling:
        // If not already falling then set fall state
        lda player1State
        and #STATE_FALL
        bne !+
        ora #STATE_FALL
        sta player1State
        // Pick first falling frame
        lda #[TABLES.__jumpAndFallTable - TABLES.jumpAndFallTable - 1]
        sta player1JumpIndex
    !:
        // If already falling then apply next fall frame
        lda player1JumpIndex
        tax
        lda player1Y
        clc
        adc TABLES.jumpAndFallTable, x
        sta player1Y
        // Proceed fall frame
        cpx #0
        beq jumpCheck   // Fall frame is max (zero)
        dex
        stx player1JumpIndex
    jumpCheck:
        // Check jump state
        lda player1State
        and #STATE_JUMP
        beq jumpCheckFinished
        // Get the current jump frame
        lda player1JumpIndex
        tax
        // Decrement Y by current frame
        lda player1Y
        sec
        sbc TABLES.jumpAndFallTable, x
        sta player1Y
        // Have we reached the final jump frame?
        inx
        stx player1JumpIndex
        cpx #[TABLES.__jumpAndFallTable - TABLES.jumpAndFallTable]
        bne jumpCheckFinished
        lda player1State
        and #[255 - STATE_JUMP]
        ora #STATE_FALL     // If this wasn't here we could double jump...
        dec player1JumpIndex   // ...otherwise we'd be off the end of the table
        sta player1State    // We're now falling
    jumpCheckFinished: 

        rts
    }
}