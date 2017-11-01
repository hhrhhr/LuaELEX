@echo off
Setlocal EnableDelayedExpansion

set XXX=sec
set XXX_DIR=f:\GG Games\ELEX_unp\0_na_%XXX%
set PATCH_DIR=f:\GG Games\ELEX_unp\_work\p00_v2

set CSV=%XXX_DIR%\w_%XXX%_0_na.csv
set CMD=`findstr _Items "%CSV%"`


for /f "usebackq tokens=1,2 delims=|" %%i in (%CMD%) do (
    echo %%i

    if exist "%PATCH_DIR%\w_%XXX%_0_na_%%i.rom" (
        copy /y "%PATCH_DIR%\w_%XXX%_0_na_%%i.rom" .\%%j.sec
    ) else (
        set a=%%i
        set a=!a:~0,1!
        copy /y "%XXX_DIR%\0\!a!\w_%XXX%_0_na_%%i.rom" .\%%j.sec
    )
)

pause
