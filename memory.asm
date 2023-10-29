MEMORY: {
    // Configuration for memory areas $A000-$BFFF, $D000-$DFFF and $E000-$FFFF.
    // BASIC ROM @ $A000-$BFFF
    // Character or I/O ROM $D000-$DFFF 
    // Kernel ROM @ $E000-$FFFF
    /*Bits #0-#2: Configuration for memory areas $A000-$BFFF, $D000-$DFFF and $E000-$FFFF. Values
        - %x00: RAM visible in all three areas.
        - %x01: RAM visible at $A000-$BFFF and $E000-$FFFF.
        - %x10: RAM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
        - %x11: BASIC ROM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
        - %0xx: Character ROM visible at $D000-$DFFF. (Except for the value %000, see above.)
        - %1xx: I/O area visible at $D000-$DFFF. (Except for the value %100, see above.)*/    
    .label IO_REGISTER = $01
    .label CIA_INTERRUPT_CONTROL = $dc0d
    .label CIA_INTERRUPT_CONTROL_REGISTER = $dd0d
    .label INTERRUPT_EXECUTION_ADDRESS_LO = $fffe
    .label INTERRUPT_EXECUTION_ADDRESS_HI = $ffff

    .label BANK_ALL_FREE = $00
    .label BANK_BASIC_AND_KERNEL_FREE = $01
    .label BANK_BASIC_FREE = $02
    .label BANK_KERNEL_AND_KERNAL_VISIBLE = $03
    .label BANK_IOAREA_CHARACTER_ROM = $00
    .label BANK_IOAREA_IO = $04
}    

.macro configureMemory(ramConfig, ioAreaConfig) {
    sei     // Disable interrupts

    // CIAs control timers and diskdrives etc
    // CIAs interrupt vectors will be executing code.
    // If we don't disable this it will try and execute something in RAM, given we are about to bank
    // out the Kernal  
    lda #$7f        // Disable CIA IRQ's
    sta MEMORY.CIA_INTERRUPT_CONTROL       // CIA Interrupt control
    sta MEMORY.CIA_INTERRUPT_CONTROL_REGISTER   // CIA Interrupt control register    

    lda MEMORY.IO_REGISTER
    // Blank the lower bits
    and #%1111_1000
    ora #ramConfig
    ora #ioAreaConfig
    sta MEMORY.IO_REGISTER

    cli  
}