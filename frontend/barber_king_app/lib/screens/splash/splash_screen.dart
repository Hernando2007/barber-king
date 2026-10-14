import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/auth/brand_header.dart';

/// Pantalla de inicio: si ya hay una sesión válida entra directo al Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    final espera = Future.delayed(const Duration(milliseconds: 2200));
    var destino = AppRoutes.login;

    // La sesión guardada solo vale si el servidor sigue aceptando el token.
    if (await AuthService().estaAutenticado() && await UsuarioService().obtenerPerfilActual() != null) {
      destino = AppRoutes.home;
    }

    await espera;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, destino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandHeader(subtitle: 'Premium Barber Experience'),
              const SizedBox(height: 48),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}