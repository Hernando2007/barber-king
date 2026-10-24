part of '../../screens/admin/admin_usuario_form_screen.dart';

class _AdminUsuarioFormBarbero extends StatelessWidget {
  final TextEditingController especialidad;
  final TextEditingController experiencia;
  final TextEditingController descripcion;
  final TextEditingController direccion;
  final int rol;
  final bool disponible;
  final ValueChanged<bool> onDisponibleChanged;

  const _AdminUsuarioFormBarbero({
    required this.especialidad,
    required this.experiencia,
    required this.descripcion,
    required this.direccion,
    required this.rol,
    required this.disponible,
    required this.onDisponibleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Perfil profesional',
          subtitle: 'Información visible para los clientes',
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: especialidad,
          decoration: const InputDecoration(
            labelText: 'Especialidad *',
            hintText: 'Ej. Fade, barbería clásica',
            prefixIcon: Icon(Icons.content_cut_outlined),
          ),
          validator: (value) {
            if (rol != 2) return null;
            if (value == null || value.trim().isEmpty) {
              return 'La especialidad es obligatoria.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: experiencia,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Años de experiencia',
            prefixIcon: Icon(Icons.timeline_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final years = int.tryParse(value.trim());
            if (years == null || years < 0 || years > 70) {
              return 'Ingresa un valor entre 0 y 70.';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descripcion,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción profesional',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: direccion,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: disponible,
            onChanged: onDisponibleChanged,
            title: const Text(
              'Disponible para reservas',
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
