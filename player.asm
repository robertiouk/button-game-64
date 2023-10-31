PLAYER: {
    .label COLLISION_SOLID = %00010000

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

    .label JOY_PORT_A = $dc00

    playersActive:
        .byte $00
    player1_X:
        .byte $a0, $00  // 1/16th pixel accuracy (Lo / Hi)
    player1_Y:
        .byte $bd       // 1 pixel accuracy
    player2_X:
        .byte $80       // 1 pixel accuracy
    player2_Y:
        .byte $bd       // 1 pixel accuracy  
    player1State:
        .byte $00
    player1JumpIndex:
        .byte $00
    player1WalkIndex:
        .byte $00
    player1WalkSpeed:
        .byte $02

    player1FloorCollision:
        .byte $00
    player1LeftCollision:
        .byte $00
    player1RightCollision:
        .byte $00
   

    initialise: {
        // Set sprite colours
        lda #DARK_GREY
        sta VIC.SPRITE_MULTICOLOUR_1
        lda #LIGHT_GREEN
        sta VIC.SPRITE_MULTICOLOUR_2

        lda #WHITE
        sta VIC.SPRITE_COLOUR_1

        lda #ORANGE
        sta VIC.SPRITE_COLOUR_2
    
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
        lda player1_X + 1
        sta VIC.SPRITE_MSB
        
        
        lda player1_Y
        sta VIC.SPRITE_0_Y

        rts
    }

    playerControl: {
        lda JOY_PORT_A
        sta.zp JOY1_ZP

        // Clear the walking states
        lda player1State
        and #[255 - STATE_WALK_LEFT - STATE_WALK_RIGHT]     // $11110011
        sta player1State

    !up:
        // If either jumping or falling then skip
        lda player1State
        and #[STATE_FALL + STATE_JUMP]  // if either are TRUE then A will be non-zero (Z == 0)
        bne !+
        // Now check if up has actually been pressed
        lda.zp JOY1_ZP
        and #JOY_UP
        // Joystick ports are high and pulled down when activated, so 0 means up is pressed
        bne !+
        lda player1State
        ora #STATE_JUMP
        sta player1State
        lda #0
        sta player1JumpIndex
    !:

    !left:
        lda.zp JOY1_ZP
        and #JOY_LT
        bne !+

        sec
        lda player1_X
        sbc player1WalkSpeed
        sta player1_X
        lda player1_X + 1
        sbc #0
        sta player1_X + 1
        jmp !done+
    !:

    !right:
        lda.zp JOY1_ZP
        and #JOY_RT
        bne !+

        clc
        lda player1_X
        adc player1WalkSpeed
        sta player1_X
        lda player1_X + 1
        adc #0
        sta player1_X + 1
    !:

    !done:
        rts
    }

    jumpAndFall: {
        // Check jump state
        lda player1State
        and #STATE_JUMP
        beq jumpCheckFinished
        // Get the current jump frame
        lda player1JumpIndex
        tax
        // Decrement Y by current frame
        lda player1_Y
        sec
        sbc TABLES.jumpAndFallTable, x
        sta player1_Y
        // Have we reached the final jump frame?
        inx
        stx player1JumpIndex
        cpx #[TABLES.__jumpAndFallTable - TABLES.jumpAndFallTable]
        bne jumpCheckFinished
        lda #STATE_FALL
        sta player1State    // We're now falling
    jumpCheckFinished: 

        rts
    }
}