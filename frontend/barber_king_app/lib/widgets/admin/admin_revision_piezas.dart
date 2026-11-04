part of '../../screens/admin/admin_revision_screen.dart';

class _Perfil extends StatelessWidget {
  final Map<String, dynamic> barbero;

  const _Perfil({required this.barbero});

  @override
  Widget build(BuildContext context) {
    final especialidad = barbero['especialidad']?.toString().trim();
    final experiencia = int.tryParse('${barbero['experiencia']}');

    final detalle = <String?>[
      if (especialidad != null && especialidad.isNotEmpty) especialidad,
      if (experiencia != null) '$experiencia años de experiencia',
      barbero['telefono']?.toString().trim(),
    ].whereType<String>().where((parte) => parte.isNotEmpty).join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.content_cut_outlined,
            color: AppColors.muted,
            size: 15,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            detalle.isEmpty ? 'Sin perfil profesional cargado.' : detalle,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpinionIA extends StatelessWidget {
  final dynamic ia;
  final bool sinDiploma;

  const _OpinionIA({required this.ia, required this.sinDiploma});

  @override
  Widget build(BuildContext context) {
    if (ia is! Map) {
      return sinDiploma
          ? const _Nota(
              icon: Icons.info_outline_rounded,
              color: AppColors.muted,
              texto: 'Se registró sin diploma: solo tú puedes darle el sello.',
            )
          : const SizedBox.shrink();
    }

    final veredicto = Map<String, dynamic>.from(ia as Map);
    final confianza = int.tryParse('${veredicto['confianza']}') ?? 0;
    final motivo = veredicto['motivo']?.toString().trim() ?? '';
    final rechazado = veredicto['estado'] == 'rechazado';

    return _Nota(
      icon: rechazado ? Icons.gpp_bad_outlined : Icons.auto_awesome_outlined,
      color: rechazado ? AppColors.error : AppColors.primary,
      texto:
          'La IA lo vio ${rechazado ? "inválido" : "válido"} con $confianza% '
          'de confianza.${motivo.isEmpty ? "" : " $motivo"}',
    );
  }
}

class _Nota extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String texto;

  const _Nota({required this.icon, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Documento extends StatelessWidget {
  final String nombre;
  final VoidCallback onTap;

  const _Documento({required this.nombre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 17,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.white, fontSize: 12),
              ),
            ),
            const Icon(Icons.zoom_in_rounded, color: AppColors.muted, size: 16),
          ],
        ),
      ),
    );
  }
}
