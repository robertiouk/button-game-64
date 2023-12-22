HUD: {
    drawLives: {
        jsr drawPlayer1Lives
        lda PLAYER.playersActive
        cmp #2
        bne !+
        jsr drawPlayer2Lives
    !:

        rts
    }

    drawPlayer1Lives: {
        .var lifeIcon = TEMP1
        .var lifeColour = TEMP2

        lda #$6c
        sta lifeIcon
        tax
        lda ATTR_DATA, x
        sta lifeColour

        lda #<VIC.SCREEN_RAM + $370
        sta screenMod + 1
        lda #>VIC.SCREEN_RAM + $370
        sta screenMod + 2

        lda #<VIC.COLOUR_RAM + $370
        sta colourMod + 1
        lda #>VIC.COLOUR_RAM + $370
        sta colourMod + 2
        ldy #0
    !:
        cpy PLAYER.player1Lives

        bcc lifePresent
    noLife:
        lda #0
        jmp screenMod
    lifePresent:
        lda lifeIcon
    screenMod:
        sta $DEAD
        beq skipColour
        lda lifeColour
    colourMod:
        sta $BEEF
    skipColour:
        iny
        cpy #10
        beq !+
        inc screenMod + 1
        inc colourMod + 1
        jmp !-
    !:

        rts
    }

    drawPlayer2Lives: {
        .var lifeIcon = TEMP1
        .var lifeColour = TEMP2

        lda #$6c
        sta lifeIcon
        tax
        lda ATTR_DATA, x
        sta lifeColour

        lda #<VIC.SCREEN_RAM + $38F
        sta screenMod + 1
        lda #>VIC.SCREEN_RAM + $38F
        sta screenMod + 2

        lda #<VIC.COLOUR_RAM + $38F
        sta colourMod + 1
        lda #>VIC.COLOUR_RAM + $38F
        sta colourMod + 2
        ldy #9
    !:
        cpy PLAYER.player2Lives
        beq lifePresent
        bcc lifePresent
    noLife:
        lda #0
        jmp screenMod
    lifePresent:
        lda lifeIcon
    screenMod:
        sta $DEAD
        beq skipColour
        lda lifeColour
    colourMod:
        sta $BEEF
    skipColour:
        dey
        beq !+
        inc screenMod + 1
        inc colourMod + 1
        jmp !-
    !:

        rts
    }
}