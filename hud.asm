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

    drawHungerBars: {
        jsr drawPlayer1HungerBar
        lda PLAYER.playersActive
        cmp #2
        bne !+
        jsr drawPlayer2HungerBar
    !:

        rts
    }

    drawPlayer1Lives: {
        .var lifeIcon = TEMP1
        .var lifeColour = TEMP2

        lda #$6e
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

        lda #$6e
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
        sta screenModTop + 1
        lda #<VIC.SCREEN_RAM + $3c0
        sta screenModBottom + 1
        lda #>VIC.SCREEN_RAM + $398
        sta screenModTop + 2
        lda #>VIC.SCREEN_RAM + $3c0
        sta screenModBottom + 2

        // Define colour address
        lda #<VIC.COLOUR_RAM + $398
        sta colourModTop + 1
        lda #<VIC.COLOUR_RAM + $3c0
        sta colourModBottom + 1
        lda #>VIC.COLOUR_RAM + $398
        sta colourModTop + 2
        lda #>VIC.COLOUR_RAM + $3c0
        sta colourModBottom + 2

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

        lda TABLES.hungerBarCharsTop, x
        clc 
        adc segmentOffset
    screenModTop:
        sta $DEAD

        lda TABLES.hungerBarCharsBottom, x
        clc 
        adc segmentOffset
    screenModBottom:
        sta $DEAD
    
        lda #GREEN
    colourModTop:
        sta $BEEF
    colourModBottom:
        sta $BEEF

        inc screenModBottom + 1
        inc screenModTop + 1
        inc colourModTop + 1
        inc colourModBottom + 1

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
        sta screenModTop + 1
        lda #<VIC.SCREEN_RAM + $3df
        sta screenModBottom + 1
        lda #>VIC.SCREEN_RAM + $3b7
        sta screenModTop + 2
        lda #>VIC.SCREEN_RAM + $3df
        sta screenModBottom + 2

        // Define colour address
        lda #<VIC.COLOUR_RAM + $3b7
        sta colourModTop + 1
        lda #<VIC.COLOUR_RAM + $3df
        sta colourModBottom + 1
        lda #>VIC.COLOUR_RAM + $3b7
        sta colourModTop + 2
        lda #>VIC.COLOUR_RAM + $3df
        sta colourModBottom + 2

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

        lda TABLES.hungerBarCharsTop, x
        clc 
        adc segmentOffset
    screenModTop:
        sta $DEAD

        lda TABLES.hungerBarCharsBottom, x
        clc 
        adc segmentOffset
    screenModBottom:
        sta $DEAD
    
        lda #GREEN
    colourModTop:
        sta $BEEF
    colourModBottom:
        sta $BEEF

        inc screenModBottom + 1
        inc screenModTop + 1
        inc colourModTop + 1
        inc colourModBottom + 1

        inx

        lda currentFull
        clc
        adc TABLES.hungerBarCharIncrements, x
        sta currentFull

        cpx #9
        bne !-

       rts
    }
}