IRQ: {
    setup: {
        sei     // Disable interrupts

        // CIAs control timers and diskdrives etc
        // CIAs interrupt vectors will be executing code.
        // If we don't disable this it will try and execute something in RAM, given we are about to bank
        // out the Kernal  
        lda #$7f        // Disable CIA IRQ's
        sta MEMORY.CIA_INTERRUPT_CONTROL            // CIA Interrupt control
        sta MEMORY.CIA_INTERRUPT_CONTROL_REGISTER   // CIA Interrupt control register

        // Enable the raster interrupt
        lda VIC.INTERRUPT_CONTROL
        ora #%00000001     // Bit #0: 1 = Raster interrupt enabled.
        sta VIC.INTERRUPT_CONTROL

        // Set the interrupt routine
        lda #<mainIrq
        ldx #>mainIrq
        // Because we've banked out the Kernal, we are responsible for restoring the register values
        sta MEMORY.INTERRUPT_EXECUTION_ADDRESS_LO      // If Kernal was banked in this would be 0314/5
        stx MEMORY.INTERRUPT_EXECUTION_ADDRESS_HI

        // Set the IRQ trigger
        lda #$ff
        sta VIC.RASTER_COMPARE_IRQ       // Set the raster interrupt line
        lda VIC.CONTROL_REGISTER
        and #%01111111  // clear the high bit - set Raster Compare
        sta VIC.CONTROL_REGISTER

        asl VIC.INTERRUPT_FLAG_REGISTER       // Acknowledge the raster
        cli     // Clear interrupt disable

        rts
    }

    // The main interrupt routine
    mainIrq: {
        :storeState()

        lda #01
        sta performFrameCodeFlag

        asl VIC.INTERRUPT_FLAG_REGISTER       // Acknowledge the raster interrupt
        :restoreState()
        rti     // Return from interrupt
    }
}