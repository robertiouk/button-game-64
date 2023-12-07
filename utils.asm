UTILS: {    
    getCharacterAt: {
        // x register = x char position
        // y register = y char position

        .var collisionVector = TEMP1

        // User the screen table to get the row...
        // Get the screen address LSB
        lda TABLES.screenRowsLsb, y
        sta collisionVector
        // Get the screen address MSB
        lda TABLES.screenRowMsb, y
        sta collisionVector + 1

        // Now lookup the column
        txa
        tay
        lda (collisionVector), y

        /*///// DEBUG /////
        tax
        lda #11
        sta (collisionVector), y
        txa
        /////////////////*/
        rts  
    }

    checkPlayerSpriteCollision: {
        .var playerX = VECTOR1
        .var playerY = VECTOR2
        .var otherX = VECTOR3
        .var otherY = VECTOR4
        .var collisionSide = VECTOR5
        .var xDelta = TEMP1
        .var yDelta = TEMP2
        .var otherYOffset = TEMP3

        lda PLAYER.currentPlayer
        beq setupPlayer1
        jmp playerDone
    setupPlayer1:
        lda #<PLAYER.player1X
        sta playerX
        lda #>PLAYER.player1X
        sta playerX + 1
        lda #<PLAYER.player1Y
        sta playerY
        lda #>PLAYER.player1Y
        sta playerY + 1
        lda #<PLAYER.player1SpriteCollisionSide
        sta collisionSide
        lda #>PLAYER.player1SpriteCollisionSide
        sta collisionSide + 1
    playerDone:

        // Get x delta - are both MSBs set?
        ldy #2
        lda (otherX), y
        dey
        cmp (playerX), y
        bne notEqual
        // Now compare actual x pos
        lda (otherX), y
        ldy #0
        sec
        sbc (playerX), y
        // We need the absolute value, so check negative
        bmi !+
        tax
        lda #PLAYER.COLLISION_RIGHT
        sta (collisionSide), y
        txa
        jmp absoluteX
    !:
        eor #$ff
        clc
        adc #1
        tax
        lda #PLAYER.COLLISION_LEFT
        sta (collisionSide), y
        txa
    absoluteX:
        cmp #14
        bcs notEqual

        // Get y delta
        ldy otherYOffset
        lda (otherY), y
        ldy #0
        sec
        sbc (playerY), y
        // We need absolute value, so check negative
        bpl absoluteY
        eor #$ff
        clc
        adc #1
    absoluteY:
        cmp #24
        bcs notEqual
        // Collision detected
        lda #1
        jmp done
    notEqual:
        lda #0
    done:       

        rts

    }
}

.macro getRandom(lower, upper) {
pickNumber:
    // Get the current raster line
    lda $d012
    eor $dc04
    sbc $dc05
    sta LAST_RANDOM

    ldx #0
    lda #[upper - lower]
nextPower:
    cmp TABLES.powerOfTwo, x
    bcc pickFromTable     // less than current power? 
    beq pickFromTable     // equal to current power?    
    inx
    cpx #8
    bcs !+          // greater than or equal to
    jmp nextPower
!:
    lda #$ff
    jmp gotMask
pickFromTable:
    ldy TABLES.powerOfTwo, x
    dey
    tya
gotMask:
    and LAST_RANDOM
    cmp #[upper - lower]
    
    bcc !+  // carry bit set if < limit
    sec
    sbc #[upper - lower]
!:
    clc
    adc #lower
    sta LAST_RANDOM
}

/** Assumes the value is in A register */
.macro modulo(modulo) {
    sec
modulus:
    sbc #modulo
    bcs modulus
    adc #modulo
}
