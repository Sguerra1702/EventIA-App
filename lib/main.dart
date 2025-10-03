import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'screens/events_screen.dart';  
import 'screens/event_detail_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'models/event.dart';

void main() {
  runApp(const EventiaApp());
}

class EventiaApp extends StatelessWidget {
  const EventiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
      },
    );
  }
}
