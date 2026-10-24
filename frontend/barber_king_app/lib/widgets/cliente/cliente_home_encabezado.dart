part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomeEncabezado extends StatelessWidget {
  final String nombre;
  final VoidCallback onPerfil;
  final VoidCallback onCerrarSesion;

  const _ClienteHomeEncabezado({
    required this.nombre,
    required this.onPerfil,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppFormat.greeting().toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
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
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
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
          onPressed: onCerrarSesion,
          icon: const Icon(
            Icons.logout_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ClienteHomeStats extends StatelessWidget {
  final int totalCitas;
  final int completadas;
  final int totalServicios;

  const _ClienteHomeStats({
    required this.totalCitas,
    required this.completadas,
    required this.totalServicios,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.event_note_outlined,
            label: 'Mis citas',
            value: '$totalCitas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            icon: Icons.check_circle_outline_rounded,
            label: 'Completadas',
            value: '$completadas',
            accent: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            icon: Icons.design_services_outlined,
            label: 'Servicios',
            value: '$totalServicios',
            accent: AppColors.info,
          ),
        ),
      ],
    );
  }
}
