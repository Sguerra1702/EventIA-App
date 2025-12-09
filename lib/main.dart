import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/profile_screen.dart';
import 'models/event.dart';
import 'services/auth_service.dart';
import 'services/token_manager.dart';
import 'widgets/token_expired_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log app start
  print('========================================');
  print('🚀 EventIA App Starting...');
  print('========================================');

  // Initialize auth service
  print('⚙️ Initializing AuthService...');
  await AuthService().initialize();
  print('✅ AuthService initialized');

  print('========================================');
  print('🎯 Running EventIA App');
  print('========================================');

  runApp(const EventiaApp());
}

class EventiaApp extends StatefulWidget {
  const EventiaApp({super.key});

  @override
  State<EventiaApp> createState() => _EventiaAppState();
}

class _EventiaAppState extends State<EventiaApp> {
  Timer? _tokenRefreshTimer;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _startTokenRefreshTimer();
  }

  void _startTokenRefreshTimer() {
    // Verificar token cada 45 minutos
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 45), (_) async {
      print('⏰ Periodic token validation check...');
      final isValid = await TokenManager.ensureValidToken();
      if (!isValid) {
        print('⚠️ Token no válido, intentando re-autenticación silenciosa...');

        // Intentar re-autenticación silenciosa
        final authService = AuthService();
        final success = await authService.silentSignIn();

        if (!success) {
          print('❌ Re-autenticación fallida, usuario debe iniciar sesión');
          _showTokenExpiredDialog();
        }
      } else {
        print('✅ Token is still valid');
      }
    });
  }

  void _showTokenExpiredDialog() {
    final context = _navigatorKey.currentContext;
    if (context != null && mounted) {
      TokenExpiredDialog.show(context);
    }
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'EventIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/main': (context) => const MainScreen(),
        '/events': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return EventsScreen(filterCategory: args?['category']);
        },
        '/event-detail': (context) {
          final event = ModalRoute.of(context)!.settings.arguments as Event;
          return EventDetailScreen(event: event);
        },
        '/confirmation': (context) {
          final event = ModalRoute.of(context)!.settings.arguments as Event;
          return ConfirmationScreen(event: event);
        },
        '/login': (context) => const LoginScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
