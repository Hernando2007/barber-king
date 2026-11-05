part of '../../screens/solicitudes/solicitudes_screen.dart';

/// Las piezas de la respuesta: los botones del barbero y la caja donde
/// el cliente lee lo que ya respondió.
class _OpcionRespuesta extends StatelessWidget {
  final String texto;
  final bool aceptada;
  final bool ocupada;
  final VoidCallback onTap;

  const _OpcionRespuesta({
    required this.texto,
    required this.aceptada,
    required this.ocupada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = aceptada ? AppColors.success : AppColors.muted;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      radius: 12,
      color: AppColors.surface,
      borderColor: color,
      onTap: ocupada ? null : onTap,
      child: Row(
        children: [
          Icon(
            aceptada
                ? Icons.check_circle_outline_rounded
                : Icons.do_not_disturb_on_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: aceptada ? AppColors.white : AppColors.subtitle,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (ocupada)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(
              Icons.north_east_rounded,
              size: 15,
              color: AppColors.muted,
            ),
        ],
      ),
    );
  }
}

class _CajaRespuesta extends StatelessWidget {
  final String texto;
  final Color color;

  const _CajaRespuesta({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(Icons.mark_email_read_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: AppColors.white, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Esperando extends StatelessWidget {
  const _Esperando();

  @override
  Widget build(BuildContext context) {
    return const _Linea(
      icon: Icons.hourglass_empty_rounded,
      texto: 'Esperando la respuesta del barbero.',
    );
  }
}
