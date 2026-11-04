part of '../../screens/perfil/perfil_screen.dart';

class _PerfilInfoPersonal extends StatelessWidget {
  final Map<String, dynamic>? usuario;

  const _PerfilInfoPersonal({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Información personal',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        InfoRow(
          icon: Icons.email_outlined,
          label: 'Correo electrónico',
          value: usuario?['correo']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.phone_outlined,
          label: 'Teléfono',
          value: usuario?['telefono']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.cake_outlined,
          label: 'Fecha de nacimiento',
          value: AppFormat.date(usuario?['fecha_nacimiento']),
        ),
        InfoRow(
          icon: Icons.verified_user_outlined,
          label: 'Estado de la cuenta',
          value: usuario?['estado'] == false ? 'Desactivada' : 'Activa',
        ),
      ],
    );
  }
}

class _PerfilInfoProfesional extends StatelessWidget {
  final Map<String, dynamic> barbero;

  const _PerfilInfoProfesional({required this.barbero});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Información profesional',
          icon: Icons.workspace_premium_outlined,
          subtitle: 'Visible para los clientes',
        ),
        const SizedBox(height: 12),
        InfoRow(
          icon: Icons.content_cut_outlined,
          label: 'Especialidad',
          value: barbero['especialidad']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.timeline_outlined,
          label: 'Experiencia',
          value: '${barbero['experiencia'] ?? 0} años',
        ),
        InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Dirección',
          value: barbero['direccion']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.location_city_outlined,
          label: 'Ciudad',
          value: barbero['ciudad']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.map_outlined,
          label: 'Zona o barrio',
          value: barbero['zona']?.toString() ?? '-',
        ),
        InfoRow(
          icon: Icons.notes_outlined,
          label: 'Descripción',
          value: barbero['descripcion']?.toString() ?? '-',
        ),
      ],
    );
  }
}
