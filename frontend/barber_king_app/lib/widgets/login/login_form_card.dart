import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../common/app_ui.dart';

class LoginFormCard extends StatelessWidget {
  final TextEditingController correo;
  final TextEditingController password;
  final bool ocultarPassword;
  final bool cargando;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const LoginFormCard({
    super.key,
    required this.correo,
    required this.password,
    required this.ocultarPassword,
    required this.cargando,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
            controller: correo,
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
            controller: password,
            obscureText: ocultarPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  ocultarPassword
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
            loading: cargando,
            onPressed: onLogin,
          ),
        ],
      ),
    );
  }
}
