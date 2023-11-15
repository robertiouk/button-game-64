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

        /*////// DEBUG /////
        tax
        lda #$16
        sta (collisionVector), y
        txa
        /////////////////*/

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
