// Stub implementation for non-web platforms (Android, iOS, etc.)
// This file is used when dart.library.js_interop is NOT available

void initializeWeb(Function(String) onToken) {
  // No-op on non-web platforms
  print("ℹ️ GsiWebListener stub: No web support on this platform");
}
