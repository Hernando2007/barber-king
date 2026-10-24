import 'package:flutter/material.dart';

import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/barberos/barberos_screen.dart';
import '../screens/chat/chat_contactos_screen.dart';
import '../screens/chat/chat_ia_screen.dart';
import '../screens/citas/citas_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/horarios/horarios_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/servicios/servicios_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const home = "/home";
  static const register = "/register";

  static const servicios = "/servicios";
  static const barberos = "/barberos";
  static const citas = "/citas";
  static const perfil = "/perfil";
  static const chatIA = "/chat-ia";
  static const chatContactos = "/chat-contactos";
  static const horarios = "/horarios";

  static const forgotPassword = "/forgot-password";
  static const resetPassword = "/reset-password";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    servicios: (context) => const ServiciosScreen(),
    barberos: (context) => const BarberosScreen(),
    citas: (context) => const CitasScreen(),
    perfil: (context) => const PerfilScreen(),
    chatIA: (context) => const ChatIAScreen(),
    chatContactos: (context) => const ChatContactosScreen(),
    horarios: (context) => const HorariosScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
  };
}
