@echo off
Setlocal EnableDelayedExpansion

set SEC_DIR=f:\GG Games\ELEX_unp\0_na_sec\
set CSV=%SEC_DIR%\w_sec_0_na.sorted.csv

set CMD=`findstr _Items "%CSV%"`


for /f "usebackq tokens=1,2 delims=|" %%i in (%CMD%) do (
    echo %%i
    set a=%%i
    set a=!a:~0,1!
    copy "%SEC_DIR%\0\!a!\w_sec_0_na_%%i.rom" .\%%j.sec
)
