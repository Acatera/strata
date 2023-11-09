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
echo Building project !ESC![32m%1!ESC![0m...

@REM Check if file exists. File is passed as first argument
if not exist %1 (
    echo !ESC![31mError: File %1 does not exist.!ESC![0m
    exit /b 1
)

@REM Strip file extension
set "filename=%~n1"

@REM If obj file exists, delete it
if exist %filename%.o (
    echo Deleting old object file...
    del %filename%.o
)
@REM Compile file to object file. Treat warnings as errors
@REM nasm -f win32 -o obj/%filename%.o %1 -w+all -w+error
nasm -f win64 -g %1 -o %filename%.o

@REM del %1
@REM Check if compilation was successful
if errorlevel 1 (
    echo !ESC![31mError: Compilation failed. See above for details.!ESC![0m
    exit /b 1
)

@REM If executable exists, delete it
if exist %filename%.exe (
    echo Deleting old executable...
    del %filename%.exe
)

@REM Link object file to executable
ld -e _start %filename%.o -o %filename%.exe -lkernel32 -lWs2_32 -Llib

del %filename%.o
@REM Check if linking was successful
if errorlevel 1 (
    echo !ESC![31mError: Linking failed. See above for details.!ESC![0m
    exit /b 1
)

@REM If everything went well, print success message
echo !ESC![32mBuild success.!ESC![0m
echo Executable is located at !ESC![32m%filename%.exe!ESC![0m


