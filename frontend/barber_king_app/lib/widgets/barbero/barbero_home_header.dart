part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoHomeHeader extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final VoidCallback onPerfil;
  final VoidCallback onSalir;

  const _BarberoHomeHeader({
    required this.nombre,
    required this.especialidad,
    required this.onPerfil,
    required this.onSalir,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PANEL PROFESIONAL',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.5,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hola, $nombre',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                especialidad,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Mi perfil',
          onPressed: onPerfil,
          icon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: onSalir,
          icon: const Icon(
            Icons.logout_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

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
