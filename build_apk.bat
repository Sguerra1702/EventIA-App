@echo off
echo ================================================
echo         EventIA - Compilador de APK
echo ================================================
echo.

echo Verificando configuracion de Flutter...
flutter doctor

echo.
echo Instalando dependencias...
flutter pub get

echo.
echo ================================================
echo Selecciona el tipo de compilacion:
echo 1. APK de desarrollo (debug)
echo 2. APK de produccion (release)
echo 3. Android App Bundle (para Google Play)
echo ================================================
echo.

set /p choice="Ingresa tu opcion (1-3): "

if "%choice%"=="1" (
    echo.
    echo Compilando APK de desarrollo...
    flutter build apk --debug
    echo.
    echo APK generado en: build\app\outputs\flutter-apk\app-debug.apk
) else if "%choice%"=="2" (
    echo.
    echo Compilando APK de produccion...
    flutter build apk --release
    echo.
    echo APK generado en: build\app\outputs\flutter-apk\app-release.apk
) else if "%choice%"=="3" (
    echo.
    echo Compilando Android App Bundle...
    flutter build appbundle --release
    echo.
    echo App Bundle generado en: build\app\outputs\bundle\release\app-release.aab
) else (
    echo Opcion invalida. Ejecuta el script nuevamente.
    pause
    exit /b 1
)

echo.
echo ================================================
echo Compilacion completada exitosamente!
echo ================================================
echo.

echo ¿Deseas instalar la app en un dispositivo conectado? (s/n)
set /p install="Respuesta: "

if /i "%install%"=="s" (
    echo.
    echo Buscando dispositivos conectados...
    flutter devices
    echo.
    echo Instalando aplicacion...
    flutter install
) else (
    echo.
    echo Para instalar manualmente:
    echo 1. Transfiere el APK a tu dispositivo Android
    echo 2. Habilita "Fuentes desconocidas" en configuracion
    echo 3. Abre el archivo APK en tu dispositivo para instalarlo
)

echo.
pause