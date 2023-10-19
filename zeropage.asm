.label MULTIPLY_NUM1 = $02
.label MULTIPLY_NUM1_HIGH = $03
.label MULTIPLY_NUM2 = $04
// The address if the next tile to load onto the map, to be used as an indirect pointer
.label MAPLOADER_TILE_LOOKUP = $05 // 2 bytes
// The address of the map, to be used as an indirect pointer
.label MAPLOADER_MAP_LOOKUP = $07 // 2 bytes
.label MAPLOADER_COLUMN = $09
.label MAPLOADER_ROW = $0a
/**= $02 virtual
    MULTIPLY_NUM1: .byte $00
    MULTIPLY_NUM1_HIGH: .byte $00
    MULTIPLY_NUM2: .byte $00*/