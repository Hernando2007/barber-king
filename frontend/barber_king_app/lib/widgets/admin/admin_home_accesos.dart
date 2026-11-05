part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeAccesos extends StatelessWidget {
  final VoidCallback onRefresh;
  final int revisionPendiente;

  const _AdminHomeAccesos({
    required this.onRefresh,
    required this.revisionPendiente,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Usuarios',
        'Clientes, barberos y admins',
        Icons.group_outlined,
        () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUsuariosScreen()),
          );
          onRefresh();
        },
        0,
      ),
      (
        'Verificar barberos',
        'Diplomas y cuentas sin sello',
        Icons.verified_outlined,
        () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminRevisionScreen()),
          );
          onRefresh();
        },
        revisionPendiente,
      ),
      (
        'Servicios',
        'Catálogo y precios',
        Icons.design_services_outlined,
        () => Navigator.pushNamed(context, AppRoutes.servicios),
        0,
      ),
      (
        'Citas',
        'Agenda general',
        Icons.event_note_outlined,
        () => Navigator.pushNamed(context, AppRoutes.citas),
        0,
      ),
      (
        'Barberos',
        'Equipo profesional',
        Icons.content_cut_outlined,
        () => Navigator.pushNamed(context, AppRoutes.barberos),
        0,
      ),
    ];

    return Column(
      children: [
        for (final item in items)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            radius: 16,
            onTap: item.$4,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$3, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _Contador(item.$5),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
      ],
    );
  }
}

class _Contador extends StatelessWidget {
  final int total;

  const _Contador(this.total);

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        total > 9 ? '9+' : '$total',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
