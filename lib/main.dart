import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_type_screen.dart';
import 'screens/register_entregador/register_entregador_screen.dart';
import 'screens/register_restaurante/register_restaurante_screen.dart';
import 'services/auth_storage.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/theme_notifier.dart';

void main() {
  runApp(const MotoboyApp());
}

class MotoboyApp extends StatefulWidget {
  const MotoboyApp({super.key});

  @override
  State<MotoboyApp> createState() => _MotoboyAppState();
}

class _MotoboyAppState extends State<MotoboyApp> {
  final _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.load();
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifierProvider(
      notifier: _themeNotifier,
      child: ListenableBuilder(
        listenable: _themeNotifier,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'transDelivery',
          themeMode: _themeNotifier.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0B3D91),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0B3D91),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthGate(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.registerType: (context) => const RegisterTypeScreen(),
            AppRoutes.registerMotoboy: (context) =>
                const RegisterEntregadorScreen(),
            AppRoutes.registerRestaurante: (context) =>
                const RegisterRestauranteScreen(),
          },
        ),
      ),
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

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }

  Future<String?> _checkTokenAndNavigate() async {
    final storage = AuthStorage();
    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final isValid = await storage.isTokenValid();
    if (!isValid) {
      await storage.logout();
      return null;
    }

    return token;
  }
}
