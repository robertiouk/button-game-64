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