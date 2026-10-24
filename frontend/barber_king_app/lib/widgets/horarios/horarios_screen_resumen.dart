part of '../../screens/horarios/horarios_screen.dart';

class _ResumenCard extends StatelessWidget {
  final int diasActivos;
  final int jornadasActivas;
  final VoidCallback onAgregar;

  const _ResumenCard({
    required this.diasActivos,
    required this.jornadasActivas,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .16),
          AppColors.card,
        ],
      ),
      borderColor: AppColors.primary.withValues(alpha: .26),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jornadasActivas == 0
                      ? 'Sin jornadas activas'
                      : '$diasActivos ${diasActivos == 1 ? 'día activo' : 'días activos'}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  jornadasActivas == 0
                      ? 'Agrega tu primera jornada para recibir reservas.'
                      : '$jornadasActivas '
                          '${jornadasActivas == 1 ? 'jornada configurada' : 'jornadas configuradas'}',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAgregar,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
            tooltip: 'Nueva jornada',
          ),
        ],
      ),
    );
  }
}
