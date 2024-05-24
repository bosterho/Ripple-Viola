@echo off

:: Check if GraphicsMagick is installed
where gm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo GraphicsMagick is not installed. Please install it first.
    exit /b 1
)

:: Check if input files are provided
if "%~1" == "" (
    echo No input files provided. Please provide file names as arguments.
    echo Usage: %0 file1.png file2.jpg ...
    exit /b 1
)

:: Loop through each input file
:loop
if "%~1" == "" goto :done

    :: Check if the file is an image
    gm identify "%~1" >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo "%~1 is not a valid image file."
        goto :next
    )

    :: Get the filename without extension
    set "filename=%~n1"

    :: Create a temporary directory
    set "tmpdir=%TEMP%\spritesheet_%RANDOM%"
    mkdir "%tmpdir%"

    :: Generate frames with varying opacity
    for /l %%i in (0,1,127) do (
        set /a "opacity=%%i*100/127"
        gm convert "%~1" -alpha set -channel A -evaluate set "!opacity!/100" "%tmpdir%\frame_%%i.png"
    )

    :: Create the vertical spritesheet
    gm convert +append "%tmpdir%\frame_"* "%filename%_spritesheet.png"

    :: Clean up the temporary directory
    rd /s /q "%tmpdir%"

    echo Spritesheet created: %filename%_spritesheet.png

:next
shift
goto :loop
:done