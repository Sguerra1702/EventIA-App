// Web-specific implementation using dart:js_interop
// This file is used when dart.library.js_interop IS available

import 'package:web/web.dart' as web;
import 'dart:js_interop';

void initializeWeb(Function(String) onToken) {
  print("🎧 GsiWebListener: Registering event listener for 'google_credential'");
  
  web.window.addEventListener(
    'google_credential',
    (web.Event event) {
      print("📨 GsiWebListener: Event received!");
      try {
        final customEvent = event as web.CustomEvent;
        final detail = customEvent.detail;
        
        // El detail es un JSAny que contiene el token (string)
        // Usamos dartify() para convertir el valor JS a Dart
        final dartValue = detail.dartify();
        
        if (dartValue != null) {
          final token = dartValue.toString();
          
          if (token.isNotEmpty) {
            print("🔑 Token recibido desde GSI (${token.length} chars)");
            print("🔑 Token preview: ${token.substring(0, 50)}...");
            onToken(token);
          } else {
            print("❌ Token vacío");
          }
        } else {
          print("❌ Token null");
        }
      } catch (e, stack) {
        print("❌ Error procesando token: $e");
        print("Stack: $stack");
      }
    }.toJS,
  );
  
  print("✅ GsiWebListener: Listener registered successfully");
}
