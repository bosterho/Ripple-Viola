@echo off

set INPUT_FILE=%1
set OUTPUT_FILE=%~n1_vertical_strip%~x1
set NUM_FRAMES=128

:: Create a blank image for the vertical strip
gm convert -size %NUM_FRAMES%x1^! xc:none -alpha transparent -resize 1x%NUM_FRAMES%^! vertical_strip.png

:: Loop through the frames and composite them onto the vertical strip
for /l %%i in (0,1,%NUM_FRAMES%) do (
    set /a OPACITY=255*%%i/(%NUM_FRAMES%-1)
    gm convert "%INPUT_FILE%" -alpha off -alpha set -channel A -evaluate set %%OPACITY%% +channel frame_%%i.png
    gm composite -compose over -geometry +0+%%i frame_%%i.png vertical_strip.png vertical_strip.png
)

:: Save the vertical strip image
gm convert vertical_strip.png "%OUTPUT_FILE%"

:: Clean up temporary files
del frame_*.png vertical_strip.png

echo Vertical image strip created: %OUTPUT_FILE%