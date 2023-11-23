@echo off
strata-sh strata

REM check if exit code is 0. if it's not, exit
if not %errorlevel%==0 (
    exit /b %errorlevel%
)
REM if an argument was passed, run strata.exe with it
echo.

if not "%1"=="" (
    SETLOCAL EnableExtensions DisableDelayedExpansion
    for /F %%a in ('echo prompt $E ^| cmd') do (
    set "ESC=%%a"
    )
    SETLOCAL EnableDelayedExpansion
    echo !ESC![35mRunning strata.exe with argument %1...!ESC![0m
    strata.exe %1
)