TABLES: {
    screenRowsLsb:
        // Any given row begins at address: $c000 + row * 40
        // (screen is 40x25)
        .fill 25, <[$c000 + i * 40]    // .byte (lsb) $c0[00], $c0[28], $c0[50], ...
    screenRowMsb:
        .fill 25, >[$c000 + i * 40]    // .byte (msb) $[c0]00, $[c0]28, $[c0]50, ...

    jumpAndFallTable:
        .byte $07, $06, $05, $05, $04 
        .byte $04, $03, $03, $03, $02 
        .byte $02, $02, $01, $01, $00
    __jumpAndFallTable:

    playerWalkLeft:
        .byte 70, 71, 72, 73, 74, 75
    __playerWalkLeft:
        
    playerWalkRight:
        .byte 64, 65, 66, 67, 68, 69
    __playerWalkRight:

    playerJumpLeft:
        .byte 76, 76, 77, 77, 77
        .byte 78, 78, 78, 78, 79
        .byte 79, 79, 80, 80, 80    // peak of jump

        .byte 81, 81, 81, 81, 81
        .byte 81, 82, 82, 82, 82
        .byte 82, 82, 82, 82, 82
    __playerJumpLeft:
}