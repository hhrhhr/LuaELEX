# Demands
Lua 5.3
lua-zlib

# Unpack map tiles

````lua pak_unpack_map.lua path_to\c_1_na.pak output_dir````

algo:
* the script looks for a file *0_na_img\w_img_0_na.csv* in ````c_1_na.pak````
* reads it for matching hashes to file names (*w_img_0_na_98ca6197.rom -> Map_0000_0057_0029* for example)
* converts the name into a *z-y-x* tile format (-> *elex-5-57-29*)
* copies the tiles in the dds format with new names to the specified ````output_dir````

