// Backup X, Y & Z to stack
.macro storeState() {
        pha     // A
        txa
        pha     // X
        tya
        pha     // Y
}

// Restore X, Y & Z from stack
.macro restoreState() {
        pla
        tay
        pla
        tax
        pla
}