*= $2000 "Character set"
    .import binary "maps\chars.bin"
*= $2800 "Colours / Attributes (0x2000 + 256 chars = 8192 + (256*8) = 10240 = 0x2800)"
    .import binary "maps\colours.bin"
*= $2900 "Tiles (0x2800 + 32 chars = 0x2800 + 0x100)"
    .import binary "maps\tiles.bin"
*= $3000 "Map"
    .import binary "maps\map.bin"

