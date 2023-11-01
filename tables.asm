TABLES: {
    screenRowsLsb:
        // Any given row begins at address: $c000 + row * 40
        // (screen is 40x25)
        .fill 25, <[$c000 + i * 40]    // .byte (lsb) $c0[00], $c0[28], $c0[50], ...
    screenRowMsb:
        .fill 25, >[$c000 + i * 40]    // .byte (msb) $[c0]00, $[c0]28, $[c0]50, ...

    jumpAndFallTable:
        .byte $05, $04, $04, $03, $03 
        .byte $02, $02, $02, $01 
        .byte $01, $01, $01, $01, $00, $00
    __jumpAndFallTable:
}