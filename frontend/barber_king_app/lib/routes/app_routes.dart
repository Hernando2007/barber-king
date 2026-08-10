import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/servicios/servicios_screen.dart';
import '../screens/barberos/barberos_screen.dart';
import '../screens/citas/citas_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const home = "/home";

  static const servicios = "/servicios";
  static const barberos = "/barberos";
  static const citas = "/citas";
  static const perfil = "/perfil";

  static const forgotPassword = "/forgot-password";
  static const resetPassword = "/reset-password";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),

    servicios: (context) => const ServiciosScreen(),
    barberos: (context) => const BarberosScreen(),
    citas: (context) => const CitasScreen(),
    perfil: (context) => const PerfilScreen(),

    forgotPassword: (context) =>
        const ForgotPasswordScreen(),

    // Ruta temporal
    resetPassword: (context) =>
        const ResetPasswordScreen(
          token: "",
        ),
  };

  static String? get crearServicio => null;
}