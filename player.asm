PLAYER: {
    .label PLAYER_1 = %00000001
    .label PLAYER_2 = %00000010

    .label STATE_JUMP       = %00000001
    .label STATE_FALL       = %00000010
    .label STATE_WALK_LEFT  = %00000100
    .label STATE_WALK_RIGHT = %00001000

    .label JOY_UP = %00001
    .label JOY_DN = %00010
    .label JOY_LT = %00100
    .label JOY_RT = %01000
    .label JOY_FR = %10000

    playersActive:
        .byte $00
    player1_X:
        .byte $a0       // 1 pixel accuracy
    player1_Y:
        .byte $bd       // 1 pixel accuracy
    player2_X:
        .byte $80       // 1 pixel accuracy
    player2_Y:
        .byte $bd       // 1 pixel accuracy  

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #LIGHT_GREEN
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #WHITE
        sta VIC.SPRITE_COLOUR_1

        //lda #ORANGE
        //sta VIC.SPRITE_COLOUR_2
    
        lda #$40
        sta SPRITE_POINTERS

        // For now only enable player 1
        lda VIC.SPRITE_ENABLE
        ora #%00000001
        sta VIC.SPRITE_ENABLE

        // Set sprite to multicolour
        lda VIC.SPRITE_MULTICOLOUR
        ora #%00000001
        sta VIC.SPRITE_MULTICOLOUR

        lda #1
        sta playersActive

        rts
    }

    drawPlayer: {
        lda player1_X
        sta VIC.SPRITE_0_X
        lda player1_Y
        sta VIC.SPRITE_0_Y

        rts
    }
}