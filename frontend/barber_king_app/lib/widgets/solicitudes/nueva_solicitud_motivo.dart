part of 'nueva_solicitud_sheet.dart';

/// Un motivo, con las dos respuestas que el barbero va a poder pulsar.
/// Se muestran por adelantado para que el cliente sepa qué va a pasar.
class _MotivoTile extends StatelessWidget {
  final Map<String, dynamic> motivo;
  final bool activo;
  final VoidCallback onTap;

  const _MotivoTile({
    required this.motivo,
    required this.activo,
    required this.onTap,
  });

  List<Map<String, dynamic>> get _opciones {
    final valor = motivo['opciones'];

    if (valor is! List) {
      return [];
    }

    return valor.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppColors.primary : AppColors.border;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      radius: 14,
      color: activo ? AppColors.surface : AppColors.card,
      borderColor: color,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            activo
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motivo['etiqueta']?.toString() ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  motivo['descripcion']?.toString() ?? '',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                  ),
                ),
                for (final opcion in _opciones)
                  _VistaRespuesta(
                    texto: opcion['texto']?.toString() ?? '',
                    aceptada: opcion['estado'] == 'aceptada',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaRespuesta extends StatelessWidget {
  final String texto;
  final bool aceptada;

  const _VistaRespuesta({required this.texto, required this.aceptada});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(
            aceptada
                ? Icons.check_circle_outline_rounded
                : Icons.do_not_disturb_on_outlined,
            size: 13,
            color: aceptada ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
