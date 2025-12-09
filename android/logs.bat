@echo off
echo ============================================
echo EventIA App - Android Logs Monitor
echo ============================================
echo.
echo Limpiando logs anteriores...
adb logcat -c
echo.
echo Monitoreando logs (Presiona Ctrl+C para detener)...
echo ============================================
echo.

REM Filtrar logs de Flutter y AuthService
adb logcat | findstr /I "flutter AuthService GoogleSignIn PlatformException"
