import 'package:flutter/material.dart';

import '../common/app_ui.dart';

class RegisterFieldsSections extends StatelessWidget {
  final TextEditingController nombres;
  final TextEditingController apellidos;
  final TextEditingController correo;
  final TextEditingController telefono;
  final TextEditingController fecha;
  final TextEditingController password;
  final TextEditingController confirmar;
  final bool ocultarPassword;
  final bool ocultarConfirmar;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmar;

  const RegisterFieldsSections({
    super.key,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fecha,
    required this.password,
    required this.confirmar,
    required this.ocultarPassword,
    required this.ocultarConfirmar,
    required this.onTogglePassword,
    required this.onToggleConfirmar,
  });

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (value == null) return;

    fecha.text =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Datos personales',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nombres,
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(
            'Nombres',
            Icons.person_outline_rounded,
          ),
          validator: _requerido,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: apellidos,
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(
            'Apellidos',
            Icons.badge_outlined,
          ),
          validator: _requerido,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: correo,
          keyboardType: TextInputType.emailAddress,
          decoration: _decoration(
            'Correo electrónico',
            Icons.email_outlined,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Ingresa tu correo.';
            if (!text.contains('@') || !text.contains('.')) {
              return 'Ingresa un correo válido.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: telefono,
          keyboardType: TextInputType.phone,
          decoration: _decoration(
            'Teléfono',
            Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: fecha,
          readOnly: true,
          onTap: () => _seleccionarFecha(context),
          decoration: _decoration(
            'Fecha de nacimiento',
            Icons.calendar_month_outlined,
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Seguridad',
          icon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: password,
          obscureText: ocultarPassword,
          decoration: _decoration(
            'Contraseña',
            Icons.lock_outline_rounded,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                ocultarPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Mínimo 6 caracteres.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: confirmar,
          obscureText: ocultarConfirmar,
          decoration: _decoration(
            'Confirmar contraseña',
            Icons.lock_reset_outlined,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggleConfirmar,
              icon: Icon(
                ocultarConfirmar
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: _requerido,
        ),
      ],
    );
  }
}
