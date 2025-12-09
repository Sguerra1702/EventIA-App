// Stub implementation for non-web platforms (Android, iOS, etc.)
import 'package:flutter/material.dart';

void registerGoogleButtonViewFactory() {
  // No-op on non-web platforms
  print("ℹ️ Google button: Using native implementation");
}

Widget buildWebButton() {
  // This should never be called on non-web platforms
  return const SizedBox.shrink();
}
