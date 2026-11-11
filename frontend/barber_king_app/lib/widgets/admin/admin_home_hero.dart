part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeCabecera extends StatelessWidget {
  final String nombre;
  final VoidCallback onPerfil;
  final VoidCallback onSalir;

  const _AdminHomeCabecera({
    required this.nombre,
    required this.onPerfil,
    required this.onSalir,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = AppFormat.dateLong(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'PANEL DE CONTROL',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'Hola, $nombre',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${fecha[0].toUpperCase()}${fecha.substring(1)} · Administrador',
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