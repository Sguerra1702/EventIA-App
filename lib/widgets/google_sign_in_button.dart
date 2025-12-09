import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import - solo importa dart:ui_web en web
import 'google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      registerGoogleButtonViewFactory();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        height: 44,
        constraints: const BoxConstraints(maxWidth: 320),
        child: widget.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : buildWebButton(),
      );
    } else {
      // Mobile: Show custom button
      return OutlinedButton.icon(
        onPressed: widget.isLoading ? null : widget.onPressed,
        icon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
        label: const Text(
          'Continuar con Google',
          style: TextStyle(fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
