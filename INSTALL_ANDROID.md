# EventIA - Guía de Instalación Android

## Opción 1: Para Testing Rápido (Web)

Si solo quieres probar la aplicación rápidamente:

```bash
flutter run -d chrome
```

## Opción 2: Compilar APK (Requiere Android Studio)

### Paso 1: Instalar Android Studio

1. **Descarga Android Studio**: Ve a https://developer.android.com/studio
2. **Instala Android Studio**: Ejecuta el instalador y sigue las instrucciones
3. **Configura SDK**: En el primer inicio, acepta descargar Android SDK
4. **Acepta Licencias**: Ejecuta `flutter doctor --android-licenses` y acepta todo

### Paso 2: Verificar Configuración

```bash
flutter doctor
```

Deberías ver checkmarks (✓) en:
- Flutter
- Android toolchain
- VS Code

### Paso 3: Compilar APK

#### Opción A: APK de Debug (Para testing)
```bash
flutter build apk --debug
```
Archivo generado: `build\app\outputs\flutter-apk\app-debug.apk`

#### Opción B: APK de Release (Optimizado)
```bash
flutter build apk --release
```
Archivo generado: `build\app\outputs\flutter-apk\app-release.apk`

#### Opción C: Usar Script Automatizado
```bash
# En Windows
build_apk.bat

# En macOS/Linux  
chmod +x build_apk.sh
./build_apk.sh
```

### Paso 4: Instalar en Android

#### Método 1: Con dispositivo conectado
```bash
flutter install
```

#### Método 2: Transferir APK manualmente
1. Copia el archivo `.apk` a tu teléfono Android
2. En el teléfono, ve a **Configuración > Seguridad > Fuentes desconocidas** y habilítalo
3. Abre el archivo APK desde el explorador de archivos
4. Toca **Instalar**

## Opción 3: Emulador Android

### Crear emulador en Android Studio:
1. Abre Android Studio
2. Ve a **Tools > AVD Manager**
3. Crea un **Virtual Device**
4. Elige un dispositivo (ej: Pixel 6)
5. Descarga una imagen del sistema (ej: API 34)
6. Inicia el emulador

### Ejecutar en emulador:
```bash
flutter run
```

## Troubleshooting

### Error: "Android toolchain not found"
```bash
# Instalar Android Studio y luego:
flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"
flutter doctor --android-licenses
```

### Error: "No connected devices"
```bash
# Verificar dispositivos
flutter devices

# Si usas dispositivo físico, habilita Developer Options y USB Debugging
```

### APK muy grande
```bash
# Crear APKs separados por arquitectura
flutter build apk --split-per-abi
```

### Error de compilación
```bash
# Limpiar y recompilar
flutter clean
flutter pub get
flutter build apk --release
```

## Tamaños de APK Esperados

- **Debug APK**: ~40-50 MB
- **Release APK**: ~15-25 MB  
- **Split APKs**: ~8-12 MB cada una

## Alternativas si no puedes instalar Android Studio

1. **Web**: `flutter run -d chrome`
2. **Windows**: `flutter run -d windows` (requiere Visual Studio)
3. **Online IDE**: Usar DartPad o GitHub Codespaces

## Requisitos del Sistema

### Para compilar APK:
- **Windows 10/11**
- **8 GB RAM** (mínimo)
- **4 GB espacio libre** para Android Studio
- **Conexión a internet** para descargas

### Para ejecutar en dispositivo:
- **Android 5.0** (API 21) o superior
- **2 GB RAM** recomendado
- **100 MB espacio libre**