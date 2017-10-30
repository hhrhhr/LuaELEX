@echo off
Setlocal EnableDelayedExpansion

rem from lua w_strings.lua <w_strings.bin> <output.lua> [lang]
set lang="f:\GG Games\ELEX_unpacked\localization\w_strings_6_utf8.lua"

set lua=E:\devel\lua_x64\lua.exe
set cat=%~dp0%
set arg=

rem path to parse_items.lua location
pushd ..
for /r "%cat%" %%i in (*.sec) do (
    echo %%i
    set arg=!arg! "%%i.lua"
)
%lua% parse_items.lua %arg% %lang% "%cat%items.txt"
popd

pause
