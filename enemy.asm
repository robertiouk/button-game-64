ENEMY: {
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
}