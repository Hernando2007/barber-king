import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../common/app_ui.dart';

class LoginGoogleAcceso extends StatefulWidget {
  final VoidCallback onExito;

  const LoginGoogleAcceso({super.key, required this.onExito});

  @override
  State<LoginGoogleAcceso> createState() => _LoginGoogleAccesoState();
}

class _LoginGoogleAccesoState extends State<LoginGoogleAcceso> {
  final _auth = AuthService();
  bool _cargando = false;

  Future<void> _entrar() async {
    if (_cargando) return;

    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);

    final respuesta = await _auth.loginConGoogle();

    if (!mounted) return;
    setState(() => _cargando = false);

    if (respuesta['success'] == true) {
      widget.onExito();
      return;
    }

    if (respuesta['cancelado'] == true) return;

    showAppSnack(
      context,
      respuesta['message']?.toString() ??
          'No se pudo iniciar sesión con Google.',
      error: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _Linea()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o continúa con',
                style: TextStyle(
                  color: AppColors.muted.withValues(alpha: .9),
                  fontSize: 11.5,
                ),
              ),
            ),
            const Expanded(child: _Linea()),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: _cargando ? null : _entrar,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MarcaGoogle(),
                      SizedBox(width: 10),
                      Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.border);
  }
}

class _MarcaGoogle extends StatelessWidget {
  const _MarcaGoogle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
