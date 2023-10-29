BasicUpstart2(main)

#import "maploader.asm"
#import "memory.asm"
#import "player.asm"
#import "vic.asm"
#import "zeropage.asm"

*=* "Main"
main:
    // Free kernal and basic memory
    configureMemory(MEMORY.BANK_BASIC_AND_KERNEL_FREE, MEMORY.BANK_IOAREA_IO)

    // Set VIC bank
    setVideoBank(VIC.BANK_3)    // $C000 - $FFFF

    // Set character memory location
    lda VIC.MEMORY_SETUP
    and #%1110_0000 // Bits 4-7 are screen memory (use first available: $C000)
    ora #%0000_1100 // Char memory is at $C000 + $3000 ($F000)
    sta VIC.MEMORY_SETUP

    // Black border
    lda #$00
    sta VIC.BORDER_COLOUR
    sta VIC.SCREEN_COLOUR

    // Clear the screen
    jsr clearScreen

    // Load map
    jsr MAPLOADER.drawMap
    jsr PLAYER.initialise

loop:

    jsr PLAYER.playerControl
    jsr PLAYER.drawPlayer

    jmp loop

clearScreen:
    // $0400 - $07FF (1024 chars)
    ldx #0
    lda #0
!:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x

    dex
    bne !-
    rts

#import "assets.asm"