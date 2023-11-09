VIC: {
    // Bank constants
    .label BANK_0 = %11
    .label BANK_1 = %10
    .label BANK_2 = %01
    .label BANK_3 = %00

    // Screen constants
    .label SCREEN_RAM = $c000

    .label SPRITE_0_X = $d000
    .label SPRITE_0_Y = $d001
    .label SPRITE_1_X = $d002
    .label SPRITE_1_Y = $d003
    .label SPRITE_2_X = $d004
    .label SPRITE_2_Y = $d005
    .label SPRITE_3_X = $d006
    .label SPRITE_3_Y = $d007
    .label SPRITE_MSB = $d010
    .label CONTROL_REGISTER = $d011
    .label RASTER_COMPARE_IRQ = $d012
    .label SPRITE_ENABLE = $d015
    .label SPRITE_DOUBLE_Y = $d017
    // The location of screen memory can be changed by controlling $D018
    // The upper 4 bits control the location of screen memory, lower control character memory RELATIVE to bank location
    .label MEMORY_SETUP = $d018
    .label INTERRUPT_FLAG_REGISTER = $d019
    .label INTERRUPT_CONTROL = $d01a
    .label SPRITE_MULTICOLOUR = $d01c
    .label BORDER_COLOUR = $d020
    .label SCREEN_COLOUR = $d021
    .label SPRITE_MULTICOLOUR_1 = $d025
    .label SPRITE_MULTICOLOUR_2 = $d026
    .label SPRITE_COLOUR_0 = $d027
    .label SPRITE_COLOUR_1 = $d028
    .label SPRITE_COLOUR_2 = $d029
    .label SPRITE_COLOUR_3 = $d02a
    .label SPRITE_COLOUR_4 = $d02b
    .label SPRITE_COLOUR_5 = $d02c
    .label SPRITE_COLOUR_6 = $d02d
    .label SPRITE_COLOUR_7 = $d02e
    .label COLOUR_RAM = $d800
    .label DATA_PORT = $dd00
}

.macro setVideoBank(bank) {
    lda VIC.DATA_PORT
    and #%11111100
    ora #bank
    sta VIC.DATA_PORT
}

.macro setSpriteMsb(sprite, xAddress) {
    ldx #sprite
    lda xAddress + 1
    beq !+
    lda TABLES.powerOfTwo, x
    ora VIC.SPRITE_MSB
    jmp endMsb
!:
    lda TABLES.invPowerOfTwo, x
    and VIC.SPRITE_MSB
endMsb:
    sta VIC.SPRITE_MSB
}