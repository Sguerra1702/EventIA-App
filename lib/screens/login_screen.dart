import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de autenticación (para web GSI)
    _authService.addAuthChangeListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeAuthChangeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    // Llamado cuando la autenticación cambia (ej: login web exitoso)
    if (_authService.isAuthenticated && mounted) {
      print("🎯 Auth changed, navigating to home...");
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.signInWithGoogle();
      
      if (success && mounted) {
        // Navigate to home screen on successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        // Show error if sign in was cancelled or failed
        String message = 'Inicio de sesión cancelado';
        
        // Show additional message for web if not configured
        if (kIsWeb) {
          message = 'Inicio de sesión cancelado.\n\nSi ves un error, asegúrate de configurar el Client ID de Google en web/index.html (ver WEB_SETUP.md)';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al iniciar sesión';
        
        if (kIsWeb && e.toString().contains('ClientID')) {
          errorMessage = 'Google Sign In no está configurado para web.\n\n'
              'Por favor revisa el archivo WEB_SETUP.md para instrucciones.\n\n'
              'Por ahora, puedes usar "Continuar como Invitado" desde la pantalla inicial.';
        } else if (!kIsWeb && e.toString().contains('sign_in_failed')) {
          errorMessage = 'Google Sign In no está configurado para Android.\n\n'
              'Se requiere configuración de Firebase:\n'
              '• Archivo google-services.json\n'
              '• SHA-1 en Firebase Console\n'
              '• OAuth 2.0 Client ID\n\n'
              'Por ahora, puedes usar "Continuar como Invitado".';
        } else {
          errorMessage = 'Error al iniciar sesión: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Logo and Welcome
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? '¡Bienvenido de nuevo!' : '¡Únete a EventIA!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin 
                        ? 'Inicia sesión para continuar'
                        : 'Crea tu cuenta para descubrir eventos',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Form Fields
            if (!_isLogin) ...[
              _buildTextField('Nombre completo', Icons.person),
              const SizedBox(height: 16),
            ],
            
            _buildTextField('Email', Icons.email),
            const SizedBox(height: 16),
            _buildTextField('Contraseña', Icons.lock, isPassword: true),
            
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              _buildTextField('Confirmar contraseña', Icons.lock, isPassword: true),
            ],
            
            const SizedBox(height: 24),
            
            // Login/Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _showConstructionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Switch between Login/Register
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: _isLogin 
                            ? '¿No tienes cuenta? ' 
                            : '¿Ya tienes cuenta? ',
                      ),
                      TextSpan(
                        text: _isLogin ? 'Regístrate' : 'Inicia sesión',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Social Login Options
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'O continúa con',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Google Sign-In Button
            Center(
              child: GoogleSignInButton(
                onPressed: _handleGoogleSignIn,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  void _showConstructionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            SizedBox(width: 8),
            Text('En Construcción'),
          ],
        ),
        content: const Text(
          'La funcionalidad de autenticación se conectará con el backend próximamente.\n\n'
          'Por ahora puedes continuar como invitado desde la pantalla de inicio.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}