part of '../../screens/perfil/perfil_screen.dart';

/// El bloque de documento profesional: qué subió el barbero y en qué
/// estado está su sello.
class _PerfilBloqueDiploma extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final VoidCallback onSubir;

  const _PerfilBloqueDiploma({required this.barbero, required this.onSubir});

  @override
  Widget build(BuildContext context) {
    final url = barbero['diploma_url']?.toString();
    final nombre = barbero['diploma_nombre']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        const SectionHeader(
          title: 'Documento profesional',
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: 12),
        _DiplomaCard(
          url: url,
          nombre: nombre,
          estado: barbero['verificacion_estado']?.toString(),
          onSubir: onSubir,
        ),
      ],
    );
  }
}

class _DiplomaCard extends StatelessWidget {
  final String? url;
  final String? nombre;
  final String? estado;
  final VoidCallback onSubir;

  const _DiplomaCard({
    required this.url,
    required this.nombre,
    required this.estado,
    required this.onSubir,
  });

  (String, Color) get _sello {
    if (estado == 'aprobado') {
      return ('Sello de verificado activo.', AppColors.success);
    }

    if (estado == 'rechazado') {
      return ('El documento no convenció: sube otro.', AppColors.error);
    }

    return ('Un administrador revisa tu perfil.', AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    final (detalle, color) = _sello;
    final abierta = url == null ? null : () => _abrirDiploma(context, url);

    return AppCard(
      padding: const EdgeInsets.all(15),
      onTap: abierta,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              url == null
                  ? Icons.upload_file_outlined
                  : Icons.verified_outlined,
              color: color,
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
                  url == null ? detalle : '$detalle · Toca para ver',
                  style: TextStyle(color: color, fontSize: 11),
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

void _abrirDiploma(BuildContext context, String? url) {
  final resuelta = ApiConfig.resolveMedia(url);

  if (resuelta == null) return;

  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => VisorFoto(urls: [resuelta])));
}
