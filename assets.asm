.label MAP_DATA = $9000
.label HUD_TILE_DATA = $8100
.label TILE_DATA = $8200
.label ATTR_DATA = $8000
.label CHAR_DATA = $f000

// Sprite pointers occupy the last 8 bytes of screen memory.
// The formula for setting a sprite pointer is:
// LOCATION = (BANK * $4000) + (SPRITE POINTER * $40)
.label SPRITE_POINTERS = VIC.SCREEN_RAM + $3f8

*= $d000 "Character sprites"    // Sprites must be within 16K of screen ram (start of page so divisible by 64)
    .import binary "assets\character-sprites.bin"
*= ATTR_DATA "Colours"
    .import binary "maps\colours.bin"
*= HUD_TILE_DATA "Hud Tiles (4x3)"
    .import binary "maps\arch-gauge-tiles.bin"
*= TILE_DATA "Tiles"    // $8000 + 256 attributes    
    .import binary "maps\tiles.bin"
*= MAP_DATA "Map Data"
    .import binary "maps\map.bin"
*= CHAR_DATA "Character set"
    .import binary "maps\chars.bin"

