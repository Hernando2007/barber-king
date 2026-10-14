import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/brand_header.dart';
import '../../widgets/common/app_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? correo;

  const ResetPasswordScreen({super.key, this.correo});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final _correo = TextEditingController(text: widget.correo);
  final _codigo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  final _auth = AuthService();
  bool _cargando = false;

  @override
  void dispose() {
    for (final c in [_correo, _codigo, _password, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  String? _validar() {
    if ([
      _correo,
      _codigo,
      _password,
      _confirmar,
    ].any((c) => c.text.trim().isEmpty)) {
      return 'Complete todos los campos.';
    }
    if (_codigo.text.trim().length != 6) {
      return 'El código debe tener 6 dígitos.';
    }
    if (_password.text.length < 6) {
      return 'La contraseña debe tener mínimo 6 caracteres.';
    }
    if (_password.text != _confirmar.text) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  Future<void> _cambiar() async {
    final error = _validar();
    if (error != null) {
      _aviso(error);
      return;
    }
    setState(() => _cargando = true);
    final r = await _auth.restablecerPassword(
      correo: _correo.text.trim(),
      codigo: _codigo.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    _aviso('${r['message'] ?? 'Solicitud procesada.'}');
    if (r['success'] == true) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const sep = SizedBox(height: 12);

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
              const BrandHeader(subtitle: 'Crea tu nueva contraseña'),
              const SizedBox(height: 24),
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
                      icon: Icons.mail_outline,
                      controller: _correo,
                      keyboard: TextInputType.emailAddress,
                    ),
                    sep,
                    AppField(
                      label: 'Código de 6 dígitos',
                      hint: '123456',
                      icon: Icons.pin_outlined,
                      controller: _codigo,
                      keyboard: TextInputType.number,
                    ),
                    sep,
                    AppField(
                      label: 'Nueva contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      controller: _password,
                      password: true,
                    ),
                    sep,
                    AppField(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      controller: _confirmar,
                      password: true,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _cargando ? null : _cambiar,
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.black,
                              ),
                            )
                          : const Text('CAMBIAR CONTRASEÑA'),
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
