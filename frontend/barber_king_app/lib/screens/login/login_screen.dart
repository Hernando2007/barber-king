import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_ui.dart';

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
                        _brand(),
                        const SizedBox(height: 34),
                        AppCard(
                          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Bienvenido de nuevo',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ingresa para gestionar tus citas y servicios.',
                                style: TextStyle(
                                  color: AppColors.subtitle,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _correo,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Correo electrónico',
                                  hintText: 'tu@correo.com',
                                  prefixIcon: Icon(Icons.alternate_email_rounded),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _password,
                                obscureText: _ocultarPassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _ocultarPassword = !_ocultarPassword,
                                    ),
                                    icon: Icon(
                                      _ocultarPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              PrimaryGradientButton(
                                label: 'Iniciar sesión',
                                icon: Icons.login_rounded,
                                loading: _cargando,
                                onPressed: _login,
                              ),
                            ],
                          ),
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

  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .28),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.content_cut_rounded,
            color: AppColors.black,
            size: 37,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'BARBER KING',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gestión profesional para tu barbería',
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 12.5,
          ),
        ),
      ],
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
