.const TILE_WIDTH = 2
.const TILE_HEIGHT = 2

.const MAP_TILE_WIDTH = 20
.const MAP_TILE_HEIGHT = 11

MAPLOADER: {
    // The total number of bytes per tile
    .const TILE_DATA_LENGTH = TILE_WIDTH * TILE_HEIGHT
    tileToScreenOffsets:
        // .fill 4, (i%2) + (i/2) * 40      // 40 = screen row length
        /*
            [
                0%2 + 0/2 * 40 = 0 + 0 * 40 = 0
                1%2 + 1/2 * 40 = 1 + 0 * 40 = 1
                2%2 + 2/2 * 40 = 0 + 1 * 40 = 40
                3%2 + 3/2 * 40 = 1 + 1 * 40 = 41
            ]
        */
        .fill TILE_DATA_LENGTH, mod(i, TILE_WIDTH) + floor(i/TILE_WIDTH) * $28    // 0,1,40,41
    drawMap: {
        // Load the map location
        lda #$00
        sta.zp MAPLOADER_MAP_LOOKUP
        lda #>MAP_DATA  // grab the high byte of the map data location
        sta.zp MAPLOADER_MAP_LOOKUP + 1

        // Set screen and colour locations (start at top left corner)
        lda #$00
        sta.zp MAPLOADER_ROW
        sta screenMod + 1   // low byte should always be 0
        sta colourMod + 1   // low byte should always be 0
        lda #>VIC.SCREEN_RAM
        sta screenMod + 2
        lda #>VIC.COLOUR_RAM
        sta colourMod + 2

    !rowLoop:
        // Draw row
        lda #$00    // start at left most column and work right
        sta.zp MAPLOADER_COLUMN
        tay
    !columnLoop:
        // Tile number 
        lda (MAPLOADER_MAP_LOOKUP), y
        // We need TILE_DATA + TILE_DATA_LENGTH * tile number
        sta.zp MULTIPLY_NUM1
        lda #TILE_DATA_LENGTH
        sta.zp MULTIPLY_NUM2
        jsr multiply // store low byte in A/X and high byte in Y
        sta.zp MAPLOADER_TILE_LOOKUP
        // Add the high byte to the TILE_DATA memory location high byte
        tya
        clc
        adc #>TILE_DATA     // i.e., A + $29
        sta.zp MAPLOADER_TILE_LOOKUP + 1
        // The current tile memory address is now set to MAP_LOADER_TILE_LOOKUP

        ldy #$00
    !:
        // Load the current map character into A
        lda (MAPLOADER_TILE_LOOKUP), y    // Indirect address load that points to the first tile character, + Y
        // Load the screen location to paint to into X
        ldx tileToScreenOffsets, y        // The current tile character
    screenMod:  // Set the screen location using self-modifying code
        sta $DEAD, x          // Store the current tile character to the relative screen location
        // Load the character colour
        tax
        lda ATTR_DATA, x
        ldx tileToScreenOffsets, y        // The current tile character (again)
    colourMod:  // Set the screen colour using self-modifying code
        sta $BEEF, x

        iny
        cpy #TILE_DATA_LENGTH
        bne !-
        // Tile is now drawn

        // Increment the screen and colour ram
        lda screenMod + 1   // Lo 
        clc
        adc #TILE_WIDTH
        sta screenMod + 1
        bcc !+      // Slight cheat - we're only ever adding 8 bits so can simply increment the Hi byte
        inc screenMod + 2
    !:
        lda colourMod + 1   // Lo
        clc
        adc #TILE_WIDTH
        sta colourMod + 1
        bcc !+
        inc colourMod + 2
    !:
        // Increment the column
        ldy.zp MAPLOADER_COLUMN
        iny
        cpy #MAP_TILE_WIDTH
        beq !nextRow+
        sty.zp MAPLOADER_COLUMN

        jmp !columnLoop-

    !nextRow:
        ldy.zp MAPLOADER_ROW
        iny
        cpy #MAP_TILE_HEIGHT
        beq !rowsComplete+
        sty.zp MAPLOADER_ROW

        // Increment the row
        clc
        lda.zp MAPLOADER_MAP_LOOKUP
        adc #MAP_TILE_WIDTH
        sta.zp MAPLOADER_MAP_LOOKUP
        lda.zp MAPLOADER_MAP_LOOKUP + 1
        adc #0
        sta.zp MAPLOADER_MAP_LOOKUP + 1

        // Row advance will be:
        // (number of chars drawn) + (tile height - 1) * (cols in screen row)
        // so for 2x2 tiles...
        // (40 - 20 * 2) + (1) * 40 == 40
        .var screenAdvance = (40 - MAP_TILE_WIDTH * TILE_WIDTH) + (TILE_HEIGHT - 1) * 40
        // Increment the screen row
        clc
        lda screenMod + 1
        adc #screenAdvance
        sta screenMod + 1
        lda screenMod + 2
        adc #0
        sta screenMod + 2
        clc
        lda colourMod + 1
        adc #screenAdvance
        sta colourMod + 1
        lda colourMod + 2
        adc #0
        sta colourMod + 2
        
        jmp !rowLoop-
    !rowsComplete:
        rts
    }

    multiply: {
        /* 8bit * 8bit = 16bit multiply
         Multiplies "num1" by "num2" and stores result in .A (low byte, also in .X) and .Y (high byte)
         uses extra zp var "num1Hi"

         .X and .Y get clobbered.  Change the tax/txa and tay/tya to stack or zp storage if this is an issue.
          idea to store 16-bit accumulator in .X and .Y instead of zp from bogax

         In this version, both inputs must be unsigned
         Remove the noted line to turn this into a 16bit(either) * 8bit(unsigned) = 16bit multiply. */

        lda #$00
        tay
        sty.zp MULTIPLY_NUM1_HIGH  // remove this line for 16*8=16bit multiply
        beq enterLoop

        doAdd:
        clc
        adc.zp MULTIPLY_NUM1
        tax

        tya
        adc.zp MULTIPLY_NUM1_HIGH
        tay
        txa

        loop:
        asl.zp MULTIPLY_NUM1
        rol.zp MULTIPLY_NUM1_HIGH
        enterLoop:  // accumulating multiply entry point (enter with .A=lo, .Y=hi)
        lsr.zp MULTIPLY_NUM2
        bcs doAdd
        bne loop

        rts
    }
}