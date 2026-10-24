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
          icon: Icons.notes_outlined,
          label: 'Descripción',
          value: barbero['descripcion']?.toString() ?? '-',
        ),
      ],
    );
  }
}

class _DiplomaCard extends StatelessWidget {
  final String? url;
  final String? nombre;
  final VoidCallback onSubir;

  const _DiplomaCard({
    required this.url,
    required this.nombre,
    required this.onSubir,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              url == null
                  ? Icons.upload_file_outlined
                  : Icons.verified_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  url == null
                      ? 'Sin documento adjunto'
                      : (nombre ?? 'Diploma o certificado'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  url == null
                      ? 'Sube una foto o captura de tu certificado.'
                      : 'Documento cargado correctamente.',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSubir,
            icon: const Icon(
              Icons.file_upload_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Subir documento',
          ),
        ],
      ),
    );
  }
}
