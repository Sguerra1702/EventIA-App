import 'package:flutter/foundation.dart' show kIsWeb, VoidCallback;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'gsi_web_listener.dart';
import 'token_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final GoogleSignIn _googleSignIn;

  bool _isGuest = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  GoogleSignInAccount? _googleUser;
  bool _isInitialized = false;

  // Callbacks para notificar cambios de autenticación
  final List<VoidCallback> _authChangeListeners = [];

  bool get isGuest => _isGuest;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  GoogleSignInAccount? get googleUser => _googleUser;

  // Registrar/desregistrar listeners
  void addAuthChangeListener(VoidCallback listener) {
    _authChangeListeners.add(listener);
  }

  void removeAuthChangeListener(VoidCallback listener) {
    _authChangeListeners.remove(listener);
  }

  void _notifyAuthChange() {
    for (var listener in _authChangeListeners) {
      listener();
    }
  }

  // Obtener usuario actual
  static Future<User?> getCurrentUser() async {
    final instance = AuthService();
    if (!instance._isInitialized) {
      await instance.initialize();
    }
    return instance._currentUser;
  }

  // Inicializar autenticación
  Future<void> initialize() async {
    if (_isInitialized) return;

    print("🚀 Initializing AuthService...");

    // Listener Web (GIS)
    if (kIsWeb) {
      GsiWebListener.initialize((idToken) async {
        print("🌐 GIS → Flutter ID Token recibido");
        final ok = await _verifyWithBackend(idToken);
        if (ok) {
          print("🎉 Login Web exitoso");
          _notifyAuthChange(); // Notificar a los listeners
        }
      });
    }

    // Google Sign In (Mobile/Web fallback)
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // Server Client ID (Web Client ID) necesario para Android
      serverClientId:
          '590803344083-5bm93f67a1ln4p8m5fftnmpa4veq6cd2.apps.googleusercontent.com',
    );

    _isInitialized = true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isGuest') ?? false) {
      _isGuest = true;
      return;
    }

    // Intento de login silencioso
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print("🔍 Silent sign-in OK");
        await _handleGoogleSignIn(account);
      }
    } catch (_) {
      print("ℹ️ Silent sign-in no disponible");
    }
  }

  // Login manual (Mobile y fallback en Web)
  Future<bool> signInWithGoogle() async {
    await initialize();

    try {
      GoogleSignInAccount? account;

      if (kIsWeb) {
        print("🌐 Web → intentando signIn()");
        account = await _googleSignIn.signIn();
      } else {
        print("📱 Mobile → signIn()");
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        print("❌ Usuario canceló el login");
        return false;
      }

      await _handleGoogleSignIn(account);
      _notifyAuthChange(); // Notificar a los listeners en mobile también
      return true;
    } catch (e) {
      print("❌ Error en signIn: $e");

      // Dar más contexto sobre el error
      if (e.toString().contains('sign_in_failed')) {
        print("❌ Google Sign-In no está configurado para Android");
        print("   Necesitas:");
        print("   1. Agregar google-services.json");
        print("   2. Configurar SHA-1 en Firebase Console");
        print("   3. Habilitar Google Sign-In en Firebase");
      }

      return false;
    }
  }

  // Manejar login (Mobile y Web fallback)
  Future<void> _handleGoogleSignIn(GoogleSignInAccount account) async {
    print("🔑 Autenticando a: ${account.email}");

    _googleUser = account;

    final auth = await account.authentication;

    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    print("🔑 ID Token: ${idToken != null ? '✓' : '✗'}");
    print("🔑 Access Token: ${accessToken != null ? '✓' : '✗'}");

    // En Web, google_sign_in NO provee idToken → usar GIS
    if (kIsWeb && idToken == null) {
      print("⚠️ Web sin ID Token — usar GIS (botón renderizado JS)");
      return;
    }

    final tokenToUse = idToken ?? accessToken!;

    // Guardar token con duración de 1 hora (3600 segundos)
    await TokenManager.saveToken(tokenToUse, expiresInSeconds: 3600);

    // Configurar token en ApiService
    ApiService.setAuthToken(tokenToUse);

    await _verifyWithBackend(tokenToUse);
  }

  // Enviar token al backend
  Future<bool> _verifyWithBackend(String token) async {
    print("🌐 Enviando token al backend…");
    print("📍 Backend URL: ${ApiService.baseUrl}/api/auth/verify");
    print("🔑 Token length: ${token.length}");

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': token}),
      );

      print("📡 Backend response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("❌ Backend rechazó el token: ${response.body}");
        return false;
      }

      final data = json.decode(response.body);
      print("📦 Backend response data: $data");

      // Validar que el backend retorne los datos necesarios
      if (data['token'] == null) {
        print("❌ Backend no retornó token");
        print("   Response data: $data");
        throw Exception("Backend authentication failed: no token returned");
      }

      if (data['user'] == null) {
        print("❌ Backend no retornó datos de usuario");
        print("   Response data: $data");
        throw Exception("Backend authentication failed: no user data returned");
      }

      final backendToken = data['token'] as String;

      // Guardar token con duración de 1 hora (3600 segundos)
      await TokenManager.saveToken(backendToken, expiresInSeconds: 3600);

      ApiService.setAuthToken(backendToken);
      _currentUser = User.fromJson(data['user']);
      _isAuthenticated = true;
      _isGuest = false;

      print("✅ Usuario autenticado: ${_currentUser?.email}");
      return true;
    } catch (e, stack) {
      print("❌ Error al verificar con backend: $e");
      print("Stack: $stack");
      return false;
    }
  }

  Future<void> signOut() async {
    if (_isInitialized) await _googleSignIn.signOut();
    _isGuest = false;
    _isAuthenticated = false;
    _currentUser = null;
    ApiService.setAuthToken(null);
    await TokenManager.clearToken();
    _notifyAuthChange();
  }

  Future<void> setGuestMode() async {
    _isGuest = true;
    _isAuthenticated = false;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGuest', true);
  }

  Future<void> refreshUserProfile() async {
    if (_isAuthenticated) {
      _currentUser = await ApiService.getUserProfile();
    }
  }

  /// Re-autenticación silenciosa para renovar tokens expirados
  Future<bool> silentSignIn() async {
    try {
      await initialize();
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        final idToken = auth.idToken;
        if (idToken != null) {
          await TokenManager.saveToken(idToken, expiresInSeconds: 3600);
          ApiService.setAuthToken(idToken);
          await _verifyWithBackend(idToken);
          _notifyAuthChange();
          print('✅ Silent sign-in successful');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Silent sign-in failed: $e');
      return false;
    }
  }
}
