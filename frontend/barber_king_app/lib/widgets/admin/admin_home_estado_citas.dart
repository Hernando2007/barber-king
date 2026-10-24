part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeEstadoCitas extends StatelessWidget {
  final Map<String, dynamic> citas;
  final dynamic totalCitas;

  const _AdminHomeEstadoCitas({
    required this.citas,
    required this.totalCitas,
  });

  @override
  Widget build(BuildContext context) {
    final pendientes = citas['pendientes'] ?? 0;
    final completadas = citas['completadas'] ?? 0;
    final canceladas = citas['canceladas'] ?? 0;

    return AppCard(
      child: Column(
        children: [
          _barra(
            'Pendientes',
            pendientes,
            AppColors.warning,
          ),
          const SizedBox(height: 14),
          _barra(
            'Completadas',
            completadas,
            AppColors.success,
          ),
          const SizedBox(height: 14),
          _barra(
            'Canceladas',
            canceladas,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _barra(String label, dynamic value, Color color) {
    final total = (int.tryParse('${totalCitas ?? 0}') ?? 0);
    final numero = int.tryParse('$value') ?? 0;
    final ratio = total == 0 ? 0.0 : numero / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12.5,
                ),
              ),
            ),
            Text(
              '$numero',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 6,
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}
