@REM This file is used to build and debug the project

@ECHO OFF
SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
SETLOCAL EnableDelayedExpansion
@REM  Check if a parameter was passed
if "%1"=="" (
    echo !ESC![31mError: No file name passed.!ESC![0m

    exit /b 1
)

@REM Run build.cmd
call build.cmd %1

@REM Check if build was successful
if errorlevel 1 (
    echo !ESC![31mError: Build failed. See above for details.!ESC![0m
    exit /b 1
)

@REM Run debug.cmd
echo !ESC![32mRunning debug.cmd...!ESC![0m
call debug.cmd bin/%~n1.exe