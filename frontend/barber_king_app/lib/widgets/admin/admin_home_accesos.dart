part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeVerificacion extends StatelessWidget {
  final int pendientes;
  final VoidCallback onRevisar;

  const _AdminHomeVerificacion({
    required this.pendientes,
    required this.onRevisar,
  });

  @override
  Widget build(BuildContext context) {
    final color = pendientes > 0 ? AppColors.warning : AppColors.success;

    return AppCard(
      onTap: onRevisar,
      gradient: pendientes > 0 ? AppColors.heroGradient : null,
      borderColor: color.withValues(alpha: .45),
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              pendientes > 0
                  ? Icons.verified_outlined
                  : Icons.verified_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pendientes > 0
                      ? '$pendientes '
                            '${pendientes == 1 ? 'barbero espera' : 'barberos esperan'} '
                            'verificación'
                      : 'Verificación al día',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pendientes > 0
                      ? 'Revisa el diploma y otorga el sello profesional.'
                      : 'Ningún diploma pendiente de revisión.',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

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
        'Agenda general del negocio',
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

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      radius: 18,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: items[i].$4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          items[i].$3,
                          color: AppColors.primary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].$1,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.subtitle,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Contador(items[i].$5),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.border,
              ),
          ],
        ],
      ),
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