import 'package:barber_king_app/widgets/auth/auth_layout.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../widgets/auth/auth_fields.dart';
import '../../widgets/common/feedback_cards.dart';

class RegisterForm extends StatelessWidget {
  final int rol;
  final bool loading;
  final bool hidePassword;
  final bool hideConfirmation;
  final TextEditingController nombres;
  final TextEditingController apellidos;
  final TextEditingController correo;
  final TextEditingController telefono;
  final TextEditingController fecha;
  final TextEditingController password;
  final TextEditingController confirmar;
  final ValueChanged<int?> onRoleChanged;
  final VoidCallback onDateTap;
  final VoidCallback onPasswordToggle;
  final VoidCallback onConfirmationToggle;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  const RegisterForm({
    super.key,
    required this.rol,
    required this.loading,
    required this.hidePassword,
    required this.hideConfirmation,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fecha,
    required this.password,
    required this.confirmar,
    required this.onRoleChanged,
    required this.onDateTap,
    required this.onPasswordToggle,
    required this.onConfirmationToggle,
    required this.onSubmit,
    required this.onLogin,
  });

  Widget _roleSelector() {
    return DropdownButtonFormField<int>(
      initialValue: rol,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        labelText: 'Tipo de cuenta',
        prefixIcon: Icon(
          Icons.badge_outlined,
          color: AppColors.primary,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 3,
          child: Text('Cliente'),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Barbero'),
        ),
      ],
      onChanged: onRoleChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          _roleSelector(),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Nombres',
            icon: Icons.person_outline,
            controller: nombres,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Apellidos',
            icon: Icons.person_outline,
            controller: apellidos,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            controller: correo,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            controller: telefono,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            label: 'Fecha de nacimiento',
            icon: Icons.calendar_month_outlined,
            controller: fecha,
            readOnly: true,
            onTap: onDateTap,
          ),
          const SizedBox(height: 18),
          AuthPasswordField(
            label: 'Contraseña',
            controller: password,
            obscureText: hidePassword,
            onToggle: onPasswordToggle,
          ),
          const SizedBox(height: 18),
          AuthPasswordField(
            label: 'Confirmar contraseña',
            controller: confirmar,
            obscureText: hideConfirmation,
            onToggle: onConfirmationToggle,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: 'Crear cuenta',
            loading: loading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onLogin,
            child: const Text('Ya tengo una cuenta'),
          ),
        ],
      ),
    );
  }
}
