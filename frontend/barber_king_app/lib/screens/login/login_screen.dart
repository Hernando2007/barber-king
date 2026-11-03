import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/login/login_brand.dart';
import '../../widgets/login/login_form_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final correo = _correo.text.trim();
    final password = _password.text;

    if (correo.isEmpty || password.isEmpty) {
      showAppSnack(
        context,
        'Completa tu correo y contraseña.',
        error: true,
      );
      return;
    }

    setState(() => _cargando = true);

    final respuesta = await _auth.login(
      correo: correo,
      contrasena: password,
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (respuesta['success'] == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'No se pudo iniciar sesión.',
      error: true,
    );
  }

  void _togglePassword() =>
      setState(() => _ocultarPassword = !_ocultarPassword);

  void _onGoogleExito() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _glow(260, AppColors.primary.withValues(alpha: .10)),
            ),
            Positioned(
              bottom: -140,
              left: -110,
              child: _glow(300, AppColors.info.withValues(alpha: .05)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        const LoginBrand(),
                        const SizedBox(height: 34),
                        LoginFormCard(
                          correo: _correo,
                          password: _password,
                          ocultarPassword: _ocultarPassword,
                          cargando: _cargando,
                          onTogglePassword: _togglePassword,
                          onLogin: _login,
                          onGoogleExito: _onGoogleExito,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Aún no tienes cuenta?',
                              style: TextStyle(
                                color: AppColors.subtitle,
                                fontSize: 12.5,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: const Text('Crear cuenta'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'CORTE  •  ESTILO  •  EXPERIENCIA',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
