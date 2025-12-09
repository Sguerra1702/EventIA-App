import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Diálogo que se muestra cuando el token de autenticación ha expirado
class TokenExpiredDialog extends StatelessWidget {
  const TokenExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Sesión Expirada'),
        ],
      ),
      content: const Text(
        'Tu sesión ha expirado. Por favor, inicia sesión nuevamente para continuar.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);

            // Intentar sign-in silencioso primero
            final success = await AuthService().silentSignIn();

            if (!success && context.mounted) {
              // Si falla, mostrar pantalla de login
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Reiniciar Sesión'),
        ),
      ],
    );
  }

  /// Método estático para mostrar el diálogo fácilmente
  static Future<void> show(BuildContext context) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TokenExpiredDialog(),
    );
  }
}
