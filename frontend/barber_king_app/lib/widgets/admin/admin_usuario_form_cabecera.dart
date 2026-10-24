part of '../../screens/admin/admin_usuario_form_screen.dart';

class _AdminUsuarioFormCabecera extends StatelessWidget {
  final String nombreCompleto;
  final String? foto;
  final bool esEdicion;
  final int rol;
  final bool activo;

  const _AdminUsuarioFormCabecera({
    required this.nombreCompleto,
    required this.foto,
    required this.esEdicion,
    required this.rol,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: Row(
        children: [
          AppAvatar(
            name: nombreCompleto,
            photoUrl: foto,
            radius: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esEdicion ? nombreCompleto.trim() : 'Crear nueva cuenta',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${AppFormat.role(rol)} · ${activo ? 'Activa' : 'Desactivada'}',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
