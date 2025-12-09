// Conditional imports para evitar dependencias web en Android/iOS
import 'package:flutter/foundation.dart' show kIsWeb;

// Solo importar web cuando estamos en web
import 'gsi_web_listener_stub.dart'
    if (dart.library.js_interop) 'gsi_web_listener_web.dart';

class GsiWebListener {
  static void initialize(Function(String) onToken) {
    if (kIsWeb) {
      initializeWeb(onToken);
    } else {
      print("ℹ️ GsiWebListener: Skipping (not web platform)");
    }
  }
}
