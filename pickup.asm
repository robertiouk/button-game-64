PICKUP: {
    .label STATE_FALL_UP   = %00000010
    .label STATE_FALL_DOWN = %00000100
    .label STATE_LANDED    = %00001000
    .label COLLISION_SOLID = %00010000

    pickup1X:
        .byte $00, $00
    pickup1Y:
        .byte $00
    pickup1State:
        .byte $00
    pickup1FallIndex:
        .byte $00
    pickup1CollisionPoint:
        .byte $00

    pickup2X:
        .byte $00, $00
    pickup2Y:
        .byte $00
    pickup2State:
        .byte $00
    pickup2FallIndex:
        .byte $00
    pickup2CollisionPoint:
        .byte $00

    dropFrame:
        .byte $66

    activePickups: // %xxxx_11xx = set first one used / switch if picked up and other still active
        .byte $00
    
    caughtType:
        .byte $00
    caughtButterfly:
        .byte $00

    initialise: {
        lda VIC.SPRITE_ENABLE
        ora #%00110000
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00110000
        sta VIC.SPRITE_MULTICOLOUR

        rts
    }

    generatePickup: {
        lda activePickups
        beq pickFirst
        cmp #$0000_0001
        beq pickSecond
        // Check the next two bytes to see which one was picked first
        and #%0000_0100
        bne pickSecond
        jmp pickFirst
    pickFirst:
        lda dropFrame
        sta SPRITE_POINTERS + 4
        // Set colour
        lda caughtType
        sta VIC.SPRITE_COLOUR_4

        // Set the position
        lda caughtButterfly
        beq butterfly1PosFirst
        lda BUTTERFLY.butterfly2X + 1
        sta pickup1X
        lda BUTTERFLY.butterfly2X + 2
        sta pickup1X + 1
        lda BUTTERFLY.butterfly2Y + 1
        sta pickup1Y
        jmp setStateFirst
    butterfly1PosFirst:
        lda BUTTERFLY.butterfly1X + 1
        sta pickup1X
        lda BUTTERFLY.butterfly1X + 2
        sta pickup1X + 1
        lda BUTTERFLY.butterfly1Y + 1
        sta pickup1Y

    setStateFirst:
        lda #STATE_FALL_UP
        sta pickup1State

        lda activePickups
        ora #%0000_0001
        and #%1111_0111 // If pickup 2 was the older pickup, it isn't any more
        sta activePickups
        and #%0000_0010 // Is the second pickup also active?
        beq done
        // Second is active, so this is now the oldest pickup
        lda activePickups
        ora #%0000_0100
        sta activePickups

        jmp done       
    pickSecond:
        lda dropFrame
        sta SPRITE_POINTERS + 5
        // Set colour
        lda caughtType
        sta VIC.SPRITE_COLOUR_5

        // Set the position
        lda caughtButterfly
        beq butterfly1PosSecond
        lda BUTTERFLY.butterfly2X + 1
        sta pickup2X
        lda BUTTERFLY.butterfly2X + 2
        sta pickup2X + 1
        lda BUTTERFLY.butterfly2Y + 1
        sta pickup2Y
        jmp setStateSecond
    butterfly1PosSecond:
        lda BUTTERFLY.butterfly1X + 1
        sta pickup2X
        lda BUTTERFLY.butterfly1X + 2
        sta pickup2X + 1
        lda BUTTERFLY.butterfly1Y + 1
        sta pickup2Y

    setStateSecond:
        lda #STATE_FALL_UP
        sta pickup2State

        lda activePickups
        ora #%0000_0010
        and #%1111_1011 // If pickup 1 was the older pickup, it isn't any more
        sta activePickups
        and #%0000_0001 // Is the first pickup also active?
        beq done
        // Second is active, so this is now the oldest pickup
        lda activePickups
        ora #%0000_1000
        sta activePickups
    done:       

        rts
    }

    collisionCheck: {
        // Before we do anything check that there is a moveable pickup
        lda pickup1State
        cmp #STATE_FALL_DOWN
        bne checkSecond
        // Do collision check for pickup 1
        lda #0
        ldx #10      // Left double-pixel location / 2
        ldy #25      // y Offset. This should be halved for small sprite (#24)
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        //tax
        //lda #11
        //sta (TEMP1), y
        //txa
        tax
        lda ATTR_DATA, x
        and #$f0
        sta pickup1CollisionPoint

    checkSecond:
        lda pickup2State
        cmp #STATE_FALL_DOWN
        bne done
        // Do collision check for pickup 2
        lda #1
        ldx #10      // Left foot double-pixel location / 2
        ldy #25      // y Offset. This should be halved for small sprite (#24)
        jsr getCollisionPoint
        jsr UTILS.getCharacterAt
        tax
        lda ATTR_DATA, x
        and #$f0
        sta pickup2CollisionPoint
        
    done:
        rts
    }

    movePickup: {
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var state = VECTOR3
        .var fallIndex = VECTOR4
        .var collision = VECTOR5
        .var current = TEMP1

        // Before we do anything check that there is a moveable pickup
        lda pickup1State
        and #[STATE_FALL_DOWN + STATE_FALL_UP]
        bne start
        lda pickup2State
        and #[STATE_FALL_DOWN + STATE_FALL_UP]
        bne start
        jmp finished
    start:
        lda #1
        sta current       
    setupNext:
        lda current
        beq setupFirst
    setupSecond:
        lda #<pickup2X
        sta xPos
        lda #>pickup2X
        sta xPos + 1
        lda #<pickup2Y
        sta yPos
        lda #>pickup2Y
        sta yPos + 1
        lda #<pickup2State
        sta state
        lda #>pickup2State
        sta state + 1
        lda #<pickup2FallIndex
        sta fallIndex
        lda #>pickup2FallIndex
        sta fallIndex + 1
        lda #<pickup2CollisionPoint
        sta collision
        lda #>pickup2CollisionPoint
        sta collision + 1
        jmp doneSetup
    setupFirst:
        lda #<pickup1X
        sta xPos
        lda #>pickup1X
        sta xPos + 1
        lda #<pickup1Y
        sta yPos
        lda #>pickup1Y
        sta yPos + 1
        lda #<pickup1State
        sta state
        lda #>pickup1State
        sta state + 1
        lda #<pickup1FallIndex
        sta fallIndex
        lda #>pickup1FallIndex
        sta fallIndex + 1
        lda #<pickup1CollisionPoint
        sta collision
        lda #>pickup1CollisionPoint
        sta collision + 1
    doneSetup:
        ldy #0
        lda (state), y
        and #[STATE_FALL_UP + STATE_FALL_DOWN]
        beq done

        // Pickup is falling, so move it
        lda (state), y
        cmp #STATE_FALL_UP
        bne fallDown
    fallUp:
        // Pickup will pop upwards before falling down
        ldy #0
        lda (fallIndex), y
        tax
        lda (yPos), y
        sec
        sbc TABLES.pickupFall, x
        sta (yPos), y
        
        // Check fall state
        lda TABLES.pickupFall, x
        bne !+
        // Hit 0, start to fall down
        lda #STATE_FALL_DOWN
        sta (state), y
    !:
        lda (fallIndex), y
        clc
        adc #1
        sta (fallIndex), y
        jmp done
    fallDown:
        // Check for floor collision
        lda (collision), y
        cmp #COLLISION_SOLID
        bne !+
        lda #STATE_LANDED
        sta (state), y
        lda #0
        sta (fallIndex), y
        // Snap to lower precision to snap to floor.
        // Floor will be multiple of 8, e.g., 80.
        // Worst case Y will by 7
        lda (yPos), y
        and #%11111000 // is now a multiple of 8
        ora #%00000101  // ora 101 worked well for small sprite
        sta (yPos), y

        jmp done
    !:

        // Move pickup down
        ldy #0
        lda (fallIndex), y
        tax
        lda (yPos), y
        clc
        adc TABLES.pickupFall, x
        sta (yPos), y

        // Check fall state
        txa
        cmp #[TABLES.__pickupFall - TABLES.pickupFall - 1]
        beq done
        lda (fallIndex), y
        clc
        adc #1
        sta (fallIndex), y
    done:
        lda current
        beq finished
        dec current
        jmp setupNext
    finished:

        rts
    }

    drawPickup: {
        lda activePickups
        and #%00000011
        beq finished

        lda activePickups
        and #%00000001
        beq drawSecond
    drawFirst:
        lda pickup1X
        sta VIC.SPRITE_4_X
        setSpriteMsb(4, pickup1X)

        lda pickup1Y
        sta VIC.SPRITE_4_Y
    drawSecond:
        lda activePickups
        and #%00000010
        beq finished
        lda pickup2X
        sta VIC.SPRITE_5_X
        setSpriteMsb(5, pickup2X)

        lda pickup2Y
        sta VIC.SPRITE_5_Y
    finished:

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
        .var pickupPosition = TEMP3 // uses both TEMP3 & 4 - Lo/Hi
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var xBorderOffset = 22
        .var yBorderOffset = 49
        stx xPixelOffset
        sty yPixelOffset

        cmp #0
        beq setup1
    setup2:
        lda #<pickup2X
        sta xPos
        lda #>pickup2X
        sta xPos + 1
        lda #<pickup2Y
        sta yPos
        lda #>pickup2Y
        sta yPos + 1
        jmp setupComplete
    setup1:
        lda #<pickup1X
        sta xPos
        lda #>pickup1X
        sta xPos + 1
        lda #<pickup1Y
        sta yPos
        lda #>pickup1Y
        sta yPos + 1
    setupComplete:

        // Calculate x & y in screen space
        ldy #00
        lda (xPos), y
        sta pickupPosition
        iny
        lda (xPos), y
        sta pickupPosition + 1
        // Convert from 1:1/16 to 1:1
        lda pickupPosition + 1  // Hi
        bne !+          // If > 0 skip
        lda pickupPosition      // Lo
        cmp #xBorderOffset         // Left border edge
        bcs !+          // If it's > border edge do nothing
        lda #xBorderOffset         // Assume it's at the edge of the screen
        sta pickupPosition
    !:
        lda pickupPosition
        clc
        adc xPixelOffset
        sta pickupPosition
        lda pickupPosition + 1
        adc #0
        sta pickupPosition + 1
        // Done 16 bit addition ^
        lda pickupPosition
        sec
        sbc #xBorderOffset
        sta pickupPosition
        lda pickupPosition + 1
        sbc #0
        sta pickupPosition + 1

        // We now have a value between 0 and 160. We need do turn into 
        // a value between 0 and 40, so divide by 4.
        lda pickupPosition
        lsr pickupPosition + 1
        ror 
        lsr pickupPosition + 1
        ror 
        lsr pickupPosition + 1
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