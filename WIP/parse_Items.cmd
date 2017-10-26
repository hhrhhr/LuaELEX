@echo off
Setlocal EnableDelayedExpansion

set lua=E:\devel\lua_x64\lua.exe
set cat=%~dp0%

set arg=

pushd ..
for /r "%cat%" %%i in (*.sec) do (
    %lua% gar5_parser.lua "%%i"
    set arg=!arg! "%%i.lua"
)
%lua% parse_items.lua %arg% > "%cat%items.txt"
popd

pause
