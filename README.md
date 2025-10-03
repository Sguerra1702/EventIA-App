# EventIA - App de Eventos con IA

Una aplicación Flutter para descubrir y asistir a eventos locales con recomendaciones inteligentes basadas en IA.

## Características

- **Recomendaciones IA**: Sugerencias personalizadas de eventos basadas en preferencias
- **Búsqueda y Filtros**: Busca eventos por categoría, ubicación y fecha
- **Detalles Completos**: Información detallada de eventos con ubicación, precio y reseñas
- **Confirmación de Asistencia**: Sistema de registro para eventos
- **Integración de Calendario**: Añade eventos automáticamente a tu calendario
- **Notificaciones**: Recordatorios antes de los eventos

## Screenshots

La aplicación incluye las siguientes pantallas:
- Pantalla de inicio (Splash)
- Pantalla principal con recomendaciones IA
- Lista de eventos con filtros
- Detalle completo del evento
- Confirmación de asistencia

## Tecnologías

- **Flutter 3.35.5**
- **Dart**
- **Material Design 3**

## Instalación y Configuración

### Prerrequisitos

1. **Flutter SDK**: Descargar e instalar desde [flutter.dev](https://flutter.dev)
2. **Android Studio**: Para desarrollo Android desde [developer.android.com](https://developer.android.com/studio)
3. **VS Code** (opcional): Con extensión de Flutter

### Pasos de Instalación

1. **Clonar o descargar el proyecto**
```bash
cd eventia_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Verificar configuración**
```bash
flutter doctor
```

### Ejecutar la Aplicación

#### En Web (Chrome)
```bash
flutter run -d chrome
```

#### En Android (Emulador o Dispositivo)
```bash
# Asegúrate de tener un emulador ejecutándose o dispositivo conectado
flutter devices
flutter run
```

#### Compilar APK para Android
```bash
# APK para testing
flutter build apk

# APK optimizado para release
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

### Instalar en Android

1. **Desde APK**: Transfiere el archivo APK a tu dispositivo Android e instálalo
2. **Desde código fuente**: Con el dispositivo conectado, ejecuta `flutter install`
3. **Desde Android Studio**: Abre el proyecto y usa el botón Run

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── event.dart           # Modelo de datos para eventos
├── screens/
│   ├── splash_screen.dart   # Pantalla de inicio
│   ├── main_screen.dart     # Pantalla principal con IA
│   ├── events_screen.dart   # Lista de eventos
│   ├── event_detail_screen.dart  # Detalle del evento
│   └── confirmation_screen.dart  # Confirmación de asistencia
└── data/
    └── mock_data.dart       # Datos precargados de eventos
```

## Datos Precargados

La aplicación incluye 8 eventos de ejemplo en diferentes categorías:
- 🎵 Música (Rock, Jazz, Electrónica)
- 🍽️ Gastronomía (Ferias gastronómicas)
- 🎨 Arte (Exposiciones)
- 🏃 Deportes (Maratones)
- 🎭 Entretenimiento (Stand-up Comedy)
- 📚 Educativo (Workshops)

## Funcionalidades Implementadas

- ✅ Pantalla de inicio animada
- ✅ Recomendaciones IA con rotación automática
- ✅ Navegación entre pantallas
- ✅ Lista de eventos con búsqueda y filtros
- ✅ Detalle completo de eventos
- ✅ Sistema de confirmación de asistencia
- ✅ Animaciones y transiciones suaves
- ✅ Diseño responsive
- ✅ Material Design 3

## Compilación para Producción

### Android App Bundle (Recomendado para Google Play)
```bash
flutter build appbundle --release
```

### APK Firmado
```bash
flutter build apk --release
```

## Para Instalar Android Studio (Requerido para APK)

1. Descarga Android Studio desde: https://developer.android.com/studio
2. Instala y ejecuta Android Studio
3. Sigue el setup wizard para instalar Android SDK
4. Ejecuta `flutter doctor` para verificar la instalación
5. Acepta las licencias con: `flutter doctor --android-licenses`

## Autor

Desarrollado como proyecto académico para IETI - Integración de Soluciones Telemáticas
