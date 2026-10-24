part of '../../screens/perfil/perfil_screen.dart';

class _PerfilEditView extends StatelessWidget {
  final TextEditingController nombres;
  final TextEditingController apellidos;
  final TextEditingController telefono;
  final TextEditingController fecha;
  final TextEditingController especialidad;
  final TextEditingController experiencia;
  final TextEditingController descripcion;
  final TextEditingController direccion;
  final bool esBarbero;
  final bool guardando;
  final String? Function(String?) requerido;
  final VoidCallback onGuardar;
  final VoidCallback onSeleccionarFecha;

  const _PerfilEditView({
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.fecha,
    required this.especialidad,
    required this.experiencia,
    required this.descripcion,
    required this.direccion,
    required this.esBarbero,
    required this.guardando,
    required this.requerido,
    required this.onGuardar,
    required this.onSeleccionarFecha,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStrong,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: nombres,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombres',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: requerido,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: apellidos,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Apellidos',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: requerido,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: telefono,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: fecha,
          readOnly: true,
          onTap: onSeleccionarFecha,
          decoration: const InputDecoration(
            labelText: 'Fecha de nacimiento',
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
        ),
        if (esBarbero) ...[
          const SizedBox(height: 22),
          const SectionHeader(
            title: 'Perfil profesional',
            icon: Icons.workspace_premium_outlined,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: especialidad,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              prefixIcon: Icon(Icons.content_cut_outlined),
            ),
            validator: requerido,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: experiencia,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Años de experiencia',
              prefixIcon: Icon(Icons.timeline_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descripcion,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción profesional',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: direccion,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryGradientButton(
          label: 'GUARDAR CAMBIOS',
          icon: Icons.save_outlined,
          loading: guardando,
          onPressed: guardando ? null : onGuardar,
        ),
      ],
    );
  }
}
