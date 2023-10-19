VIC: {
    .label SCREEN_RAM = $0400
    // The location of screen memory can be changed by controlling $D018
    // The upper 4 bits control the location of screen memory, lower control character memory RELATIVE to bank location
    .label MEMORY_SETUP = $d018
    .label BORDER_COLOUR = $d020
    .label SCREEN_COLOUR = $d021
    .label COLOUR_RAM = $d800
}