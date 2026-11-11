part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeEstadoCitas extends StatelessWidget {
  final Map<String, dynamic> citas;
  final dynamic totalCitas;

  const _AdminHomeEstadoCitas({required this.citas, required this.totalCitas});

  @override
  Widget build(BuildContext context) {
    final total = int.tryParse('${totalCitas ?? 0}') ?? 0;
    final pendientes = int.tryParse('${citas['pendientes'] ?? 0}') ?? 0;
    final completadas = int.tryParse('${citas['completadas'] ?? 0}') ?? 0;
    final canceladas = int.tryParse('${citas['canceladas'] ?? 0}') ?? 0;
    final confirmadas = (total - pendientes - completadas - canceladas).clamp(
      0,
      total,
    );

    final segmentos = [
      (confirmadas, AppColors.info, 'Confirmadas'),
      (pendientes, AppColors.warning, 'Pendientes'),
      (completadas, AppColors.success, 'Completadas'),
      (canceladas, AppColors.error, 'Canceladas'),
    ];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Total histórico',
                style: TextStyle(color: AppColors.subtitle, fontSize: 11.5),
              ),
              const Spacer(),
              Text(
                '$total ${total == 1 ? 'cita' : 'citas'}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: AppColors.surface)
                  : Row(
                      children: [
                        for (final segmento in segmentos)
                          if (segmento.$1 > 0)
                            Expanded(
                              flex: segmento.$1,
                              child: Container(color: segmento.$2),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          for (final segmento in segmentos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: segmento.$2,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      segmento.$3,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${segmento.$1}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    child: Text(
                      total == 0
                          ? '0%'
                          : '${(segmento.$1 * 100 / total).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}