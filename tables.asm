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
    butterflyTypeFill:
        .byte 1, 2, 3, 4
    butterflyTypePoints:
        .byte 1, 2, 4, 10
    
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

    hedgehogWalkLeft:
        .byte $62, $63
    __hedgehogWalkLeft:

    hedgehogWalkRight:
        .byte $64, $65
    __hedgeHogWalkRight:

    pickupFall:
        .byte $03, $02, $02, $02, $01 
        .byte $01, $00, $00, $01, $02
        .byte $03, $03, $04, $04, $05
        .byte $05, $06, $07   
    __pickupFall:

    hungerBarChars:
        .byte $0f, $16, $16, $16, $16, $16, $16, $16, $1f
    hungerBarCharIncrements:
        .byte $07, $09, $09, $09, $09, $09, $09, $09, $07

    negativeStateTable:
        .byte $01, $02, $04
    negativeStateTiles:
        .byte $0d, $0e, $0f     // Confusion, Poison, Bomb
    negativeStateCureTable:
        .byte $01, $00, $02     // Cyan, White, Red
    cureQuantityTable:
        .byte $02, $03, $01

    positiveStateTable:
        .byte $20, $40, $80     // Light, Double-Jump, Super Sense
    positiveStateTiles:
        .byte $10, $11, $12

    statusGaugeTiles:
        .byte $00, $0e, $0d, $0c, $0b, $0a, $09, $08, $07, $06, $05, $04, $03, $02, $01
    __statusGaugeTiles:

    confusedChars:
        .byte $00, $00, $00, $00, $00
        .byte $94, $95, $96, $91, $00

    poisonedChars:
        .byte $00, $00, $00, $00, $00
        .byte $8e, $8f, $90, $91, $00

    bombChars:
        .byte $00, $00, $00, $00, $00
        .byte $92, $93, $00, $00, $00
    
    lightChars:
        .byte $97, $98, $99, $00, $00
        .byte $9a, $9b, $9c, $00, $00

    doubleJumpChars:
        .byte $9d, $9e, $8d, $00, $00
        .byte $9f, $a0, $00, $00, $00

    superSenseChars:
        .byte $a1, $a2, $a3, $00, $00
        .byte $a4, $a5, $a6, $00, $00

    invincibleChars:
        .byte $00, $00, $00, $00, $00
        .byte $89, $8a, $8b, $8c, $8d

    extraLifeChars:
        .byte $a7, $a8, $a9, $00, $00
        .byte $97, $aa, $00, $00, $00  
}