HUD: {
    .label SCORE_COLOUR = WHITE
    .label LIFE_CHAR = $4d

    scoreChars:
        .byte $38, $28, $34, $37, $2a, $4a
    digits:
        .byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49

    player1Status:
        .byte $00
    player2Status:
        .byte $00

    initialise: {
        jsr drawLives
        jsr drawHungerBars

        // Draw Score labels
        ldx #0
    !:
        lda scoreChars, x
        sta VIC.SCREEN_RAM + $3c0, x
        sta VIC.SCREEN_RAM + $3de, x

        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3c0, x
        sta VIC.COLOUR_RAM + $3de, x

        inx
        cpx #6
        bne !-

        jsr drawScores

        rts
    }

    drawLives: {
        jsr drawPlayer1Lives
        lda PLAYER.playersActive
        cmp #2
        bne !+
        jsr drawPlayer2Lives
    !:

        rts
    }

    drawHungerBars: {
        jsr drawPlayer1HungerBar
        lda PLAYER.playersActive
        cmp #2
        bne !+
        jsr drawPlayer2HungerBar
    !:

        rts
    }

    drawScores: {
        jsr drawPlayer1Score
        lda PLAYER.playersActive
        cmp #2
        bne !+
        jsr drawPlayer2Score
    !:

        rts
    }

    drawPlayer1Lives: {
        .var lifeIcon = TEMP1
        .var lifeColour = TEMP2

        lda #LIFE_CHAR
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

        lda #LIFE_CHAR
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

    drawPlayer1HungerBar: {
        .var segmentOffset = TEMP1
        .var currentFull = TEMP2
        .var drawBlanks = TEMP3

        // Define screen address
        lda #<VIC.SCREEN_RAM + $398
        sta screenMod + 1
        lda #>VIC.SCREEN_RAM + $398
        sta screenMod + 2

        // Define colour address
        lda #<VIC.COLOUR_RAM + $398
        sta colourMod + 1
        lda #>VIC.COLOUR_RAM + $398
        sta colourMod + 2

        ldx #0
        lda TABLES.hungerBarCharIncrements, x
        sta currentFull
        stx drawBlanks
        lda #0
        sta segmentOffset
    !:        
        lda drawBlanks
        bne getEmptyFragment
        lda PLAYER.player1Eaten
        cmp currentFull

        bcc getPartialFragment
    getFullFragment:
        lda TABLES.hungerBarCharIncrements, x
        sta segmentOffset
        dec segmentOffset
        jmp gotChar
    getPartialFragment:
        lda currentFull
        sec
        sbc PLAYER.player1Eaten
        sta segmentOffset
        lda TABLES.hungerBarCharIncrements, x
        sec
        sbc segmentOffset
        sta segmentOffset

        lda #1
        sta drawBlanks
        jmp gotChar
    getEmptyFragment:
        lda #0
        sta segmentOffset
    gotChar:

        lda TABLES.hungerBarChars, x
        clc 
        adc segmentOffset
    screenMod:
        sta $DEAD
    
        lda #GREEN
    colourMod:
        sta $BEEF

        inc screenMod + 1
        inc colourMod + 1

        inx

        lda currentFull
        clc
        adc TABLES.hungerBarCharIncrements, x
        sta currentFull

        cpx #9
        bne !-

        rts
    }

    drawPlayer2HungerBar: {
         .var segmentOffset = TEMP1
        .var currentFull = TEMP2
        .var drawBlanks = TEMP3

        // Define screen address
        lda #<VIC.SCREEN_RAM + $3b7
        sta screenMod + 1
        lda #>VIC.SCREEN_RAM + $3b7
        sta screenMod + 2

        // Define colour address
        lda #<VIC.COLOUR_RAM + $3b7
        sta colourMod + 1
        lda #>VIC.COLOUR_RAM + $3b7
        sta colourMod + 2

        ldx #0
        lda TABLES.hungerBarCharIncrements, x
        sta currentFull
        stx drawBlanks
        lda #0
        sta segmentOffset
    !:        
        lda drawBlanks
        bne getEmptyFragment
        lda PLAYER.player2Eaten
        cmp currentFull

        bcc getPartialFragment
    getFullFragment:
        lda TABLES.hungerBarCharIncrements, x
        sta segmentOffset
        dec segmentOffset
        jmp gotChar
    getPartialFragment:
        lda currentFull
        sec
        sbc PLAYER.player2Eaten
        sta segmentOffset
        lda TABLES.hungerBarCharIncrements, x
        sec
        sbc segmentOffset
        sta segmentOffset

        lda #1
        sta drawBlanks
        jmp gotChar
    getEmptyFragment:
        lda #0
        sta segmentOffset
    gotChar:

        lda TABLES.hungerBarChars, x
        clc 
        adc segmentOffset
    screenMod:
        sta $DEAD
    
        lda #GREEN
    colourMod:
        sta $BEEF

        inc screenMod + 1
        inc colourMod + 1

        inx

        lda currentFull
        clc
        adc TABLES.hungerBarCharIncrements, x
        sta currentFull

        cpx #9
        bne !-

       rts
    }

    drawPlayer1Score: {
        // Thousands... [9]999
        lda PLAYER.player1Score + 1
        lsr
        lsr
        lsr
        lsr
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3c6
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3c6
        // Hundreds... 9[9]99
        lda PLAYER.player1Score + 1
        and #$0f
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3c7
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3c7
        // Tens... 99[9]9
        lda PLAYER.player1Score
        lsr
        lsr
        lsr
        lsr
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3c8
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3c8
        // Units... 999[9]
        lda PLAYER.player1Score
        and #$0f
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3c9
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3c9        

        rts
    }

    drawPlayer2Score: {
        // Thousands... [9]999
        lda PLAYER.player2Score + 1
        lsr
        lsr
        lsr
        lsr
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3e4
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3e4
        // Hundreds... 9[9]99
        lda PLAYER.player2Score + 1
        and #$0f
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3e5
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3e5
        // Tens... 99[9]9
        lda PLAYER.player2Score
        lsr
        lsr
        lsr
        lsr
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3e6
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3e6
        // Units... 999[9]
        lda PLAYER.player2Score
        and #$0f
        tax
        lda digits, x
        sta VIC.SCREEN_RAM + $3e7
        lda #SCORE_COLOUR
        sta VIC.COLOUR_RAM + $3e7
    
        rts
    }

    drawPlayer1Status: {
        lda #<VIC.SCREEN_RAM + $3a3
        sta screenMod + 1
        lda #>VIC.SCREEN_RAM + $3a3
        sta screenMod + 2
        lda #<VIC.COLOUR_RAM + $3a3
        sta colourMod + 1
        lda #>VIC.COLOUR_RAM + $3a3
        sta colourMod + 2

        lda player1Status
        sta.zp MULTIPLY_NUM1
        lda #MAPLOADER.TILE_DATA_LENGTH
        sta.zp MULTIPLY_NUM2
        jsr UTILS.multiply
        sta.zp MAPLOADER_TILE_LOOKUP
        lda #>TILE_DATA
        sta.zp MAPLOADER_TILE_LOOKUP + 1

        ldx #4
        ldy #0
    !:
        lda (MAPLOADER_TILE_LOOKUP), y
    screenMod:
        sta $DEAD

        lda #WHITE
    colourMod:
        sta $BEEF

        iny
        cpy #2
        beq newRow
        inc screenMod + 1
        inc colourMod + 1
        jmp doneScreenInc
    newRow:
        lda screenMod + 1
        clc
        adc #39
        sta screenMod + 1
        sta colourMod + 1
    doneScreenInc:

        dex
        
        bne !-

        rts
    }

    drawPlayer2Status: {
        rts
    }
}