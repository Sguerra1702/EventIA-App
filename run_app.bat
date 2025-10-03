@echo off
echo ================================================
echo         EventIA - Ejecutor de Aplicacion
echo ================================================
echo.

echo Verificando dispositivos disponibles...
flutter devices

echo.
echo ================================================
echo Selecciona donde ejecutar la aplicacion:
echo 1. Web (Chrome)
echo 2. Android (emulador/dispositivo)
echo 3. Windows (escritorio)
echo ================================================
echo.

set /p choice="Ingresa tu opcion (1-3): "

if "%choice%"=="1" (
    echo.
    echo Ejecutando en Chrome...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo.
    echo Ejecutando en Android...
    flutter run
) else if "%choice%"=="3" (
    echo.
    echo Ejecutando en Windows...
    flutter run -d windows
) else (
    echo Opcion invalida. Ejecuta el script nuevamente.
    pause
    exit /b 1
)

pause