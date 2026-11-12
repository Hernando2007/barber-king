part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoStatsGrid extends StatelessWidget {
  final Map<String, dynamic>? resumen;

  const _BarberoStatsGrid({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        StatTile(
          icon: Icons.event_outlined,
          label: 'Citas totales',
          value: '${resumen?['totalCitas'] ?? 0}',
        ),
        StatTile(
          icon: Icons.pending_actions_outlined,
          label: 'Pendientes',
          value: '${resumen?['pendientes'] ?? 0}',
          accent: AppColors.warning,
        ),
        StatTile(
          icon: Icons.check_circle_outline_rounded,
          label: 'Completadas',
          value: '${resumen?['completadas'] ?? 0}',
          accent: AppColors.success,
        ),
        StatTile(
          icon: Icons.star_outline_rounded,
          label: 'Calificación',
          value: '${resumen?['promedioCalificacion'] ?? '0.0'}',
          accent: AppColors.primaryLight,
        ),
      ],
    );
  }
}
