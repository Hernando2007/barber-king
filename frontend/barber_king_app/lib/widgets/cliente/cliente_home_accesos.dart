part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomeAccesos extends StatelessWidget {
  final void Function(String) onIr;

  const _ClienteHomeAccesos({required this.onIr});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 11,
      mainAxisSpacing: 11,
      childAspectRatio: 1.55,
      children: [
        _ClienteHomeAcceso(
          'Reservar cita',
          Icons.calendar_month_outlined,
          () => onIr(AppRoutes.citas),
        ),
        _ClienteHomeAcceso(
          'Nuestros barberos',
          Icons.content_cut_rounded,
          () => onIr(AppRoutes.barberos),
        ),
        _ClienteHomeAcceso(
          'Servicios',
          Icons.design_services_outlined,
          () => onIr(AppRoutes.servicios),
        ),
        _ClienteHomeAcceso(
          'Mis citas',
          Icons.event_available_outlined,
          () => onIr(AppRoutes.citas),
        ),
        _ClienteHomeAcceso(
          'Chat con barbero',
          Icons.forum_outlined,
          () => onIr(AppRoutes.chatContactos),
        ),
        _ClienteHomeAcceso(
          'Mi perfil',
          Icons.person_outline_rounded,
          () => onIr(AppRoutes.perfil),
        ),
      ],
    );
  }
}

class _ClienteHomeAcceso extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final VoidCallback onTap;

  const _ClienteHomeAcceso(this.titulo, this.icon, this.onTap);

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
          Icon(icon, color: AppColors.primary, size: 23),
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
