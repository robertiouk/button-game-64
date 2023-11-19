TABLES: {
    screenRowsLsb:
        // Any given row begins at address: $c000 + row * 40
        // (screen is 40x25)
        .fill 25, <[$c000 + i * 40]    // .byte (lsb) $c0[00], $c0[28], $c0[50], ...
    screenRowMsb:
        .fill 25, >[$c000 + i * 40]    // .byte (msb) $[c0]00, $[c0]28, $[c0]50, ...

    jumpAndFallTable:
        .byte $07, $06, $05, $05, $05 
        .byte $04, $04, $03, $03, $02 
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

        .byte 81, 81, 81, 82, 82
        .byte 82, 82, 83, 83, 83
        .byte 84, 84, 84, 84, 84
    __playerJumpLeft:

    playerJumpRight:
        .byte 85, 85, 86, 86, 86
        .byte 87, 87, 87, 87, 88
        .byte 88, 88, 89, 89, 89    // peak of jump

        .byte 90, 90, 90, 91, 91
        .byte 91, 91, 92, 92, 92
        .byte 93, 93, 93, 93, 93
    __playerJumpRight:

    powerOfTwo:
        .byte 1, 2, 4, 8, 16, 32, 64, 128
    invPowerOfTwo:
        .byte 255-1, 255-2, 255-4, 255-8, 255-16, 255-32, 255-64, 255-128

    butterflyTypes:
        .byte WHITE, CYAN, LIGHT_RED, PURPLE
    
    levelEnemy1XLo:
        .byte $30
    levelEnemy1XHi:
        .byte $00
    levelEnemy1Y:
        .byte $bd
    levelEnemy1Type:
        .byte $01
    levelEnemy2XLo:
        .byte $20
    levelEnemy2XHi:
        .byte $01
    levelEnemy2Y:
        .byte $bd
    levelEnemy2Type:
        .byte $01
}