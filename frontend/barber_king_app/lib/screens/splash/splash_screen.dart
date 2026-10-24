import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -90,
              child: _glow(280, AppColors.primary.withValues(alpha: .14)),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _glow(320, AppColors.info.withValues(alpha: .06)),
            ),
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacity.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .3),
                            blurRadius: 36,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.content_cut_rounded,
                        color: AppColors.black,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'BARBER KING',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 5.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'CORTE  •  ESTILO  •  EXPERIENCIA',
                      style: TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 10.5,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(flex: 4),
                    const SizedBox(
                      width: 88,
                      height: 2.4,
                      child: LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.border,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'GESTIÓN PROFESIONAL PARA TU BARBERÍA',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 9,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
