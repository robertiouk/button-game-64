PICKUP: {
    .label STATE_FALL_UP   = %00000010
    .label STATE_FALL_DOWN = %00000100

    pickup1X:
        .byte $00, $00
    pickup1Y:
        .byte $00

    pickup2X:
        .byte $00, $00
    pickup2Y:
        .byte $00

    dropFrame:
        .byte $66

    activePickups: // %xxxx_11xx = set first one used / switch if picked up and other still active
        .byte $00
    
    caughtType:
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
}