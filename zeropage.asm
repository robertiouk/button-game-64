.label MULTIPLY_NUM1 = $02
.label MULTIPLY_NUM1_HIGH = $03
.label MULTIPLY_NUM2 = $04
// The address if the next tile to load onto the map, to be used as an indirect pointer
.label MAPLOADER_TILE_LOOKUP = $05 // 2 bytes
// The address of the map, to be used as an indirect pointer
.label MAPLOADER_MAP_LOOKUP = $07 // 2 bytes
.label MAPLOADER_COLUMN = $09
.label MAPLOADER_ROW = $0a
.label JOY1_ZP = $0b
.label JOY2_ZP = $0c

// Some temp variables
.label TEMP1 = $0f
.label TEMP2 = $10
.label TEMP3 = $11
.label TEMP4 = $12

.label FRAME_COUNTER = $13
.label LAST_RANDOM = $14

// Some temp vectors
.label VECTOR1 = $15
.label VECTOR2 = $17
.label VECTOR3 = $19
.label VECTOR4 = $1b
.label VECTOR5 = $1d

// Current level
.label LEVEL = $1f

.label SPRITE_COLLISION = $20