part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeHero extends StatelessWidget {
  final Map<String, dynamic> resumen;
  final Map<String, dynamic> citas;

  const _AdminHomeHero({required this.resumen, required this.citas});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Panel de administración',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Administra usuarios, barberos, servicios y citas desde un solo lugar.',
            style: TextStyle(
              color: AppColors.subtitle,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStat(
                '${resumen['totalResenas'] ?? 0}',
                'Reseñas',
              ),
              const SizedBox(width: 26),
              _heroStat('${citas['pendientes'] ?? 0}', 'Pendientes'),
              const SizedBox(width: 26),
              _heroStat('${citas['completadas'] ?? 0}', 'Completadas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.subtitle, fontSize: 11.5),
        ),
      ],
    );
  }
}
