import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/brand_header.dart';
import '../../widgets/common/app_field.dart';

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

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _login() async {
    final correo = _correo.text.trim();
    final password = _password.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mensaje('Complete todos los campos.');
      return;
    }

    setState(() => _cargando = true);

    // POST /api/auth/login -> guarda token y usuario en storage seguro
    final r = await _auth.login(correo: correo, contrasena: password);

    if (!mounted) return;
    setState(() => _cargando = false);

    if (r['success'] == true) {
      // HomeScreen decide la vista según rol_id (admin, barbero, cliente)
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      _mensaje(r['message']?.toString() ?? 'No se pudo iniciar sesión.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              children: [
                const BrandHeader(subtitle: 'Inicia sesión para continuar'),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      AppField(
                        label: 'Correo electrónico',
                        hint: 'correo@ejemplo.com',
                        icon: Icons.person_outline,
                        controller: _correo,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        label: 'Contraseña',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _password,
                        password: true,
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
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _cargando ? null : _login,
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.black,
                                ),
                              )
                            : const Text('INICIAR SESIÓN'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(color: AppColors.subtitle, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
