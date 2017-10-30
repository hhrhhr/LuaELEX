@echo off

set lua=E:\devel\lua_x64\lua.exe
set cat=%~dp0%

rem path to gar5_parser.lua location
pushd ..
for /r "%cat%" %%i in (*.sec) do (
    echo %%i
    %lua% gar5_parser.lua "%%i"
)
popd

pause
