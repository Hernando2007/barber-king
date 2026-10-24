import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/brand_header.dart';
import '../../widgets/common/app_field.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _correo = TextEditingController();
  final _auth = AuthService();
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _irAReset() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResetPasswordScreen(correo: _correo.text.trim()),
    ),
  );

  Future<void> _enviar() async {
    if (_correo.text.trim().isEmpty) {
      _aviso('Ingrese su correo electrónico.');
      return;
    }
    setState(() => _cargando = true);
    final r = await _auth.recuperarPassword(_correo.text.trim());
    if (!mounted) return;
    setState(() => _cargando = false);

    _aviso('${r['message'] ?? 'Solicitud procesada.'}');
    if (r['success'] == true) _irAReset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                  label: const Text('Atrás'),
                ),
              ),
              const SizedBox(height: 16),
              const BrandHeader(subtitle: 'Recupera tu contraseña'),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ingresa tu correo y te enviaremos un código de 6 dígitos para restablecer tu contraseña.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtitle, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: 'Correo electrónico',
                      hint: 'correo@ejemplo.com',
                      icon: Icons.mail_outline,
                      controller: _correo,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _cargando ? null : _enviar,
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.black,
                              ),
                            )
                          : const Text('ENVIAR CÓDIGO'),
                    ),
                    TextButton(
                      onPressed: _irAReset,
                      child: const Text('Ya tengo un código'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
