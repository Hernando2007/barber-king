part of '../../screens/barbero/barbero_home_screen.dart';

/// Lo que no cabe en la barra inferior. Citas, chats y horarios ya tienen su
/// pestaña, así que duplicarlos aquí solo alargaría el panel.
class _BarberoHerramientasGrid extends StatelessWidget {
  final Future<void> Function(String ruta) onAcceso;

  const _BarberoHerramientasGrid({required this.onAcceso});

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
        _BarberoAcceso(
          'Servicios que atiendo',
          Icons.content_cut_outlined,
          onTap: () => onAcceso(AppRoutes.misServicios),
        ),
        _BarberoAcceso(
          'Mis fotos',
          Icons.photo_library_outlined,
          onTap: () => onAcceso(AppRoutes.misFotos),
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
    );
  }
}

class _BarberoAcceso extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final VoidCallback onTap;

  const _BarberoAcceso(
    this.titulo,
    this.icon, {
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
