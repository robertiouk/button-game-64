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
    .label SPRITE_MSB = $d010
    .label CONTROL_REGISTER = $d011
    .label RASTER_COMPARE_IRQ = $d012
    .label SPRITE_ENABLE = $d015
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
    .label SPRITE_COLOUR_1 = $d027
    .label SPRITE_COLOUR_2 = $d028
    .label SPRITE_COLOUR_3 = $d029
    .label SPRITE_COLOUR_4 = $d02a
    .label SPRITE_COLOUR_5 = $d02b
    .label SPRITE_COLOUR_6 = $d02c
    .label SPRITE_COLOUR_7 = $d02d
    .label SPRITE_COLOUR_8 = $d02e
    .label COLOUR_RAM = $d800
    .label DATA_PORT = $dd00
}

.macro setVideoBank(bank) {
    lda VIC.DATA_PORT
    and #%11111100
    ora #bank
    sta VIC.DATA_PORT
}