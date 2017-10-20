# Demands
* Lua 5.3
* lua-zlib

# Get map tiles

[![map example](/docs/img/map_example.jpg?raw=true "Example map with Leafjet")](https://hhrhhr.github.io/LuaELEX/elex.html)

````
if not exist .\map_dds mkdir .\map_dds
lua pak_unpack_map.lua path_to\c_1_na.pak .\map_dds
````

algo:
* the script looks for a file *0_na_img\w_img_0_na.csv* in ````c_1_na.pak````
* reads it for matching hashes to file names (*w_img_0_na_98ca6197.rom -> Map_0000_0057_0029* for example)
* converts the name into a *z-y-x* tile format (-> *elex-5-57-29*)
* copies the tiles in the dds format with new names to the specified ````.\map_dds```` directory

Most of .dds is in DX10 format with BC7 compression. For mass conversion I used Compressonator (I have not found other CLI-utilities supporting DX10-textures yet):

````
if not exist .\map_tga mkdir .\map_tga
for /r .\map_dds %i in (*.dds) do @CompressonatorCLI "%i" ".\map_tga\%~ni.tga"
````

For a web-map tiles with the size 256x256 are pretty small, so you can combine them into tiles 512x512 by using ImageMagick and the script ````tga_256_to_512_webp.lua````:

![about merge](/docs/img/merge.jpg?raw=true "merge 4 to 1")

````
rem Make filelist
dir /b /s .\map_tga\*.tga > .\map_tga\tga_filelist.txt

if not exist .\map_www mkdir .\map_www
lua tga_256_to_512_webp.lua .\map_tga\tga_filelist.txt .\map_www > convert.cmd

rem Running the resulting batch-file
convert.cmd
````

After that, instead of 1983 pieces of original tiles gets only 540.

To customize the output format, you need to edit the variable ````magick4```` and ````tile```` in ````tga_256_to_512_webp.lua````.

Now the received tiles can be used, for example, [in a Leafjet-based map](https://hhrhhr.github.io/LuaELEX/elex.html).
