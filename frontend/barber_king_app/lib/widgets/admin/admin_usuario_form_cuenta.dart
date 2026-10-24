part of '../../screens/admin/admin_usuario_form_screen.dart';

class _AdminUsuarioFormCuenta extends StatelessWidget {
  final TextEditingController nombres;
  final TextEditingController apellidos;
  final TextEditingController correo;
  final TextEditingController telefono;
  final TextEditingController fecha;
  final TextEditingController password;
  final bool esEdicion;
  final int rol;
  final String? Function(String?) requerido;
  final ValueChanged<int> onRolChanged;
  final VoidCallback onFechaTap;
  final VoidCallback onCampoCambiado;

  const _AdminUsuarioFormCuenta({
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.fecha,
    required this.password,
    required this.esEdicion,
    required this.rol,
    required this.requerido,
    required this.onRolChanged,
    required this.onFechaTap,
    required this.onCampoCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: rol,
          decoration: const InputDecoration(
            labelText: 'Rol',
            prefixIcon: Icon(Icons.shield_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 3, child: Text('Cliente')),
            DropdownMenuItem(value: 2, child: Text('Barbero')),
            DropdownMenuItem(value: 1, child: Text('Administrador')),
          ],
          onChanged: (value) {
            if (value == null) return;
            onRolChanged(value);
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: nombres,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onCampoCambiado(),
          decoration: const InputDecoration(
            labelText: 'Nombres',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: requerido,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: apellidos,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onCampoCambiado(),
          decoration: const InputDecoration(
            labelText: 'Apellidos',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: requerido,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: correo,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            final texto = value?.trim() ?? '';
            if (texto.isEmpty) return 'Ingresa el correo.';
            if (!texto.contains('@') || !texto.contains('.')) {
              return 'Ingresa un correo válido.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: telefono,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: fecha,
          readOnly: true,
          onTap: onFechaTap,
          decoration: const InputDecoration(
            labelText: 'Fecha de nacimiento',
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: esEdicion
                ? 'Nueva contraseña (opcional)'
                : 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            helperText: esEdicion
                ? 'Déjala vacía para conservar la actual.'
                : 'Mínimo 6 caracteres.',
          ),
        ),
      ],
    );
  }
}

class _AdminUsuarioFormSwitchActiva extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AdminUsuarioFormSwitchActiva({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: const Text(
          'Cuenta activa',
          style: TextStyle(color: AppColors.white, fontSize: 14),
        ),
        subtitle: const Text(
          'Los usuarios desactivados no pueden iniciar sesión.',
          style: TextStyle(color: AppColors.subtitle, fontSize: 11.5),
        ),
      ),
    );
  }
}
