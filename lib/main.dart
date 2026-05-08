import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_storage.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const MotoboyApp());
}

class MotoboyApp extends StatelessWidget {
  const MotoboyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'transDelivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B3D91)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _checkTokenAndNavigate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If token exists and is valid, go to home
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return const HomeScreen();
        }

        // No token or invalid - go to login
        return const LoginScreen();
      },
    );
  }

  /// Checks token and returns it if valid, null otherwise
  Future<String?> _checkTokenAndNavigate() async {
    final storage = AuthStorage();
    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    // Optional: Validate token format here
    // If token is expired/invalid, logout and return null
    final isValid = await storage.isTokenValid();
    if (!isValid) {
      await storage.logout();
      return null;
    }

    return token;
  }
}
