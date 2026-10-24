import 'package:flutter/material.dart';

import '../common/app_ui.dart';

class RegisterSubmitButtons extends StatelessWidget {
  final bool esBarbero;
  final bool cargando;
  final VoidCallback onRegister;
  final VoidCallback onCancel;

  const RegisterSubmitButtons({
    super.key,
    required this.esBarbero,
    required this.cargando,
    required this.onRegister,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryGradientButton(
          label: esBarbero
              ? 'REGISTRARME COMO BARBERO'
              : 'CREAR CUENTA',
          icon: Icons.person_add_alt_1_rounded,
          loading: cargando,
          onPressed: cargando ? null : onRegister,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: cargando ? null : onCancel,
          child: const Text('Ya tengo una cuenta'),
        ),
      ],
    );
  }
}
