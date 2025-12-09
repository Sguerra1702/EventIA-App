@echo off
echo ============================================
echo EventIA App - Guardar Logs
echo ============================================
echo.

set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOGFILE=logs\app_log_%TIMESTAMP%.txt

echo Creando directorio de logs...
if not exist logs mkdir logs

echo.
echo Capturando logs...
echo Los logs se guardaran en: %LOGFILE%
echo Presiona Ctrl+C cuando termines de reproducir el error
echo.

adb logcat -c
adb logcat -v time | findstr /I "flutter AuthService GoogleSignIn PlatformException eventia" > %LOGFILE%

echo.
echo Logs guardados en: %LOGFILE%
pause
