BasicUpstart2(main)

#import "butterfly.asm"
#import "enemy.asm"
#import "irq.asm"
#import "macros.asm"
#import "maploader.asm"
#import "memory.asm"
#import "pickup.asm"
#import "player.asm"
#import "tables.asm"
#import "utils.asm"
#import "vic.asm"
#import "zeropage.asm"

*=* "Main"
main:
    // Set the interrupt
    jsr IRQ.setup

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
    jsr BUTTERFLY.initialise
    jsr PICKUP.initialise
    lda #0
    sta.zp LEVEL
    jsr ENEMY.initialise
loop:
    lda performFrameCodeFlag
    beq loop    // Only do stuff if IRQ has been hit
    dec performFrameCodeFlag

    jsr PLAYER.playerControl
    jsr PLAYER.drawPlayer
    jsr BUTTERFLY.moveButterfly
    jsr BUTTERFLY.drawButterfly
    jsr PICKUP.movePickup
    jsr ENEMY.moveEnemy
    jsr ENEMY.drawEnemy
    jsr PLAYER.collisionCheck
    jsr PLAYER.jumpAndFall

    inc FRAME_COUNTER

    jmp loop

performFrameCodeFlag:
    .byte $00

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