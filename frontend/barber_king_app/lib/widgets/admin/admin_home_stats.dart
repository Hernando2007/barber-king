part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeKpis extends StatelessWidget {
  final Map<String, dynamic> resumen;
  final Map<String, dynamic> citas;
  final VoidCallback onUsuarios;
  final VoidCallback onBarberos;
  final VoidCallback onServicios;
  final VoidCallback onCitas;

  const _AdminHomeKpis({
    required this.resumen,
    required this.citas,
    required this.onUsuarios,
    required this.onBarberos,
    required this.onServicios,
    required this.onCitas,
  });

  @override
  Widget build(BuildContext context) {
    final pendientes = int.tryParse('${citas['pendientes'] ?? 0}') ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _AdminKpi(
                icon: Icons.people_alt_outlined,
                label: 'Usuarios',
                value: '${resumen['totalUsuarios'] ?? 0}',
                pie: 'Gestionar cuentas',
                onTap: onUsuarios,
              ),
              const SizedBox(height: 12),
              _AdminKpi(
                icon: Icons.design_services_outlined,
                label: 'Servicios',
                value: '${resumen['totalServicios'] ?? 0}',
                accent: AppColors.success,
                pie: 'Ver catálogo',
                onTap: onServicios,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _AdminKpi(
                icon: Icons.content_cut_outlined,
                label: 'Barberos',
                value: '${resumen['totalBarberos'] ?? 0}',
                accent: AppColors.info,
                pie: 'Ver equipo',
                onTap: onBarberos,
              ),
              const SizedBox(height: 12),
              _AdminKpi(
                icon: Icons.calendar_month_outlined,
                label: 'Citas',
                value: '${resumen['totalCitas'] ?? 0}',
                accent: AppColors.warning,
                pie: pendientes == 0
                    ? 'Sin pendientes'
                    : '$pendientes '
                          '${pendientes == 1 ? 'pendiente' : 'pendientes'}',
                onTap: onCitas,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminKpi extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String pie;
  final Color accent;
  final VoidCallback onTap;

  const _AdminKpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.pie,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const Spacer(),
              const Icon(
                Icons.north_east_rounded,
                color: AppColors.muted,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.subtitle, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pie,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent.withValues(alpha: .9),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}