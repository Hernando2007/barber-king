part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeStatsGrid extends StatelessWidget {
  final Map<String, dynamic> resumen;

  const _AdminHomeStatsGrid({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        StatTile(
          icon: Icons.people_alt_outlined,
          label: 'Usuarios',
          value: '${resumen['totalUsuarios'] ?? 0}',
        ),
        StatTile(
          icon: Icons.content_cut_outlined,
          label: 'Barberos',
          value: '${resumen['totalBarberos'] ?? 0}',
          accent: AppColors.info,
        ),
        StatTile(
          icon: Icons.design_services_outlined,
          label: 'Servicios',
          value: '${resumen['totalServicios'] ?? 0}',
          accent: AppColors.success,
        ),
        StatTile(
          icon: Icons.calendar_month_outlined,
          label: 'Citas',
          value: '${resumen['totalCitas'] ?? 0}',
          accent: AppColors.warning,
        ),
      ],
    );
  }
}
