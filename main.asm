BasicUpstart2(Main)

#import "maploader.asm"
#import "memory.asm"
#import "vic.asm"
#import "zeropage.asm"

Main:
    // Free kernal and basic memory
    configureMemory(MEMORY.BANK_BASIC_AND_KERNEL_FREE, MEMORY.BANK_IOAREA_IO)

    // Set character memory location
    lda VIC.MEMORY_SETUP
    and #%1111_0000 // Bits 4-7 are screen memory (keep at default $0400)
    ora #%0000_1000 // Char memory is at $2000
    sta VIC.MEMORY_SETUP

    // Black border
    lda #$00
    sta VIC.BORDER_COLOUR
    lda #$06
    sta VIC.SCREEN_COLOUR

    // Load map
    jsr MAPLOADER.drawMap

!:
    jmp !-


#import "assets.asm"