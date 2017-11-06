# Demands
* [Lua 5.3](https://www.lua.org/)
* [lua-zlib](https://github.com/brimworks/lua-zlib)
* [detex](https://github.com/hglm/detex)
* [ImageMagick](https://www.imagemagick.org/script/index.php)

# Get map tiles

[![map example](/docs/img/map_example.jpg?raw=true "Example low quality map with Leaflet")](https://hhrhhr.github.io/LuaELEX/elex_map.html)

````
if not exist .\map_dds mkdir .\map_dds
lua pak_unpack_map.lua path_to\c_1_na.pak .\map_dds
````

algo:
* the script looks for a file *0_na_img\w_img_0_na.csv* in ````c_1_na.pak````
* reads it for matching hashes to file names (*w_img_0_na_98ca6197.rom -> Map_0000_0057_0029* for example)
* converts the name into a *z-y-x* tile format (-> *elex-5-57-29*)
* copies the tiles in the dds format with new names to the specified ````.\map_dds```` directory

Most of .dds is in DX11 format with BC7 compression. For mass conversion I used detex:

````
if not exist .\map_png mkdir .\map_png
for /r .\map_dds %i in (*.dds) do @detex-convert -o RGB8 "%i" ".\map_png\%~ni.png"
````

For a web-map tiles with the size 256x256 px are pretty small, so you can combine them into tiles 512x512 px by using ImageMagick and the script ````256_to_512.lua````:

![about merge](/docs/img/merge.jpg?raw=true "merge 4 to 1")

````
rem Make filelist
dir /b /s .\map_png\*.png > .\map_png\filelist.txt

if not exist .\map_512 mkdir .\map_512
lua 256_to_512.lua .\map_png\filelist.txt .\map_512 > convert.cmd

rem Running the resulting batch-file
convert.cmd
````

After that, instead of 1983 pieces of original tiles gets only 540.

To customize the output format, you need to edit the variable ````magick4```` and ````tile```` in ````256_to_512.lua````.

Now the received tiles can be used, for example, [in a Leaflet-based map](https://hhrhhr.github.io/LuaELEX/elex_map.html) (low quality, only 4 levels).

# Parse World_Teleporter.sec

First, you need to generate a hash table of all the strings in the file (*...\ELEX\system\ELEX.exe*). Using *nix-utilities do this is very simple:

````
strings -3 ELEX.exe | grep "^[A-Za-z][0-9a-zA-Z _<>*-]\+$" | LANG=C sort | uniq > strings.txt
````

Second, language table must be extracted (see #Localization). Then create a *strings2.txt* file (for manually added values), and after that it is required to generate a hash table for further use:

````
lua generate_hash.lua > names.lua
````

*also you can use precompiled names_%PLAT%.luac from repo*

Beforehand, you need to unpack some .rom file, for example, to find the coordinates of teleports you need ````...\0_na_sec\0\9\w_sec_0_na_935f1e52.rom````. The correspondence of the hexadecimal code of the file name can be found in ````...\0_na_sec\w_sec_0_na.csv````, in this case, the name of the file is ````World_Teleporter.sec````.

Now everything is ready to run a fairly universal *gar5_parser.lua*:

````
lua gar5_parser.lua World_Teleporter.sec
````

A file *World_Teleporter.sec.lua* appears next to the file *World_Teleporter.sec*. Use another script to get coordinates and descriptions of teleports:

````
lua parse_teleports.lua World_Teleporter.sec.lua language.lua teleport.js
````

The resulting file contains a JS script that can be connected to the LeafJet based map.

# Patch unpacker

Show the list of files in the archive or unpack them all:

````
lua pXX_unpack.lua <path_to.p00> [output_dir]
````

# Localization

Convert ````\localization\w_strings.bin```` to Lua table:

````
lua w_strings.lua <w_strings.bin> <output.lua> [lang]
````

*lang* — language code, 0...7 is main table, 8...15 is comments (in patch 1.1).
