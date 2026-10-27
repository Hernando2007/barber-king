part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoHerramientasGrid extends StatelessWidget {
  final Future<void> Function(String ruta) onAcceso;

  const _BarberoHerramientasGrid({required this.onAcceso});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ChatNotificacionService.instance.noLeidos,
      builder: (context, pendientes, _) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 1.55,
        children: [
          _BarberoAcceso(
            'Mis citas',
            Icons.calendar_month_outlined,
            onTap: () => onAcceso(AppRoutes.citas),
          ),
          _BarberoAcceso(
            'Chats de clientes',
            Icons.forum_outlined,
            badge: pendientes,
            onTap: () => onAcceso(AppRoutes.chatContactos),
          ),
          _BarberoAcceso(
            'Mis horarios',
            Icons.schedule_outlined,
            onTap: () => onAcceso(AppRoutes.horarios),
          ),
          _BarberoAcceso(
            'Servicios',
            Icons.content_cut_outlined,
            onTap: () => onAcceso(AppRoutes.servicios),
          ),
          _BarberoAcceso(
            'Mi perfil',
            Icons.badge_outlined,
            onTap: () => onAcceso(AppRoutes.perfil),
          ),
          _BarberoAcceso(
            'Asesor IA',
            Icons.auto_awesome_outlined,
            onTap: () => onAcceso(AppRoutes.chatIA),
          ),
        ],
      ),
    );
  }
}

class _BarberoAcceso extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _BarberoAcceso(
    this.titulo,
    this.icon, {
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 17,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.primary, size: 23),
              if (badge > 0)
                Positioned(
                  right: -10,
                  top: -7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
