PICKUP: {
    .label STATE_FALL_UP   = %00000010
    .label STATE_FALL_DOWN = %00000100
    .label STATE_LANDED    = %00001000

    pickup1X:
        .byte $00, $00
    pickup1Y:
        .byte $00
    pickup1State:
        .byte $00

    pickup2X:
        .byte $00, $00
    pickup2Y:
        .byte $00
    pickup2State:
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

    movePickup: {
        .var xPos = VECTOR1
        .var yPos = VECTOR2
        .var state = VECTOR3
        .var current = TEMP1

        // Before we do anything check that there is a moveable pickup
        lda pickup1State
        and #[STATE_FALL_DOWN + STATE_FALL_UP]
        bne start
        lda pickup2State
        and #[STATE_FALL_DOWN + STATE_FALL_UP]
        beq finished
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
    doneSetup:

        lda state
        and #[STATE_FALL_DOWN + STATE_FALL_DOWN]
        beq done

        // Pickup is falling, so move it
        lda state
        cmp #STATE_FALL_UP
        bne fallDown
    fallUp:
        // Pickup will pop upwards before falling down
    fallDown:
        // Move pickup down
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
}