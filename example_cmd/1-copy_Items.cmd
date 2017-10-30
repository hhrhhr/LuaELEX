@echo off
Setlocal EnableDelayedExpansion

set XXX=sec
set XXX_DIR=f:\GG Games\ELEX_unpacked\0_na_%XXX%

set CSV=%XXX_DIR%\w_%XXX%_0_na.csv
set CMD=`findstr _Items "%CSV%"`

for /f "usebackq tokens=1,2 delims=|" %%i in (%CMD%) do (
    echo %%i
    set a=%%i
    set a=!a:~0,1!
    copy "%XXX_DIR%\0\!a!\w_%XXX%_0_na_%%i.rom" .\%%j.sec
)
