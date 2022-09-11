for /R %%A in (*.ogg) do D:\ffmpeg -i "%%A" -c:v copy -b:a 320k "%%~dpnA.mp3"
pause