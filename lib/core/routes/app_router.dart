import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_type_screen.dart';
import '../../screens/register_entregador/register_entregador_screen.dart';
import '../../screens/register_restaurante/register_restaurante_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.home: (_) => const HomeScreen(),
    AppRoutes.registerType: (_) => const RegisterTypeScreen(),
    AppRoutes.registerMotoboy: (_) => const RegisterEntregadorScreen(),
    AppRoutes.registerRestaurante: (_) => const RegisterRestauranteScreen(),
  };
}
