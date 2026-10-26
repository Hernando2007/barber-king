import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

part '../../widgets/splash/splash_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _auth = AuthService();

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _scale = Tween<double>(begin: .82, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    final autenticado = await _auth.estaAutenticado();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      autenticado ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildSplash();
}
