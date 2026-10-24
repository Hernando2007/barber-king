part of '../../screens/perfil/perfil_screen.dart';

class _PerfilHeaderCard extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final bool esBarbero;
  final String rolLabel;
  final String? especialidad;
  final bool subiendoFoto;
  final VoidCallback? onCambiarFoto;
  final VoidCallback onEditar;
  final VoidCallback onCambiarPassword;

  const _PerfilHeaderCard({
    required this.nombre,
    required this.fotoUrl,
    required this.esBarbero,
    required this.rolLabel,
    required this.especialidad,
    required this.subiendoFoto,
    required this.onCambiarFoto,
    required this.onEditar,
    required this.onCambiarPassword,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Stack(
            children: [
              AppAvatar(
                name: nombre.isEmpty ? 'Usuario' : nombre,
                photoUrl: fotoUrl,
                radius: 46,
                fallbackIcon: esBarbero
                    ? Icons.content_cut_rounded
                    : Icons.person_rounded,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onCambiarFoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.card,
                        width: 2,
                      ),
                    ),
                    child: subiendoFoto
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.black,
                            size: 15,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            nombre.isEmpty ? 'Usuario' : nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          StatusPill(
            label: rolLabel,
            color: AppColors.primary,
          ),
          if (esBarbero && especialidad?.isNotEmpty == true) ...[
            const SizedBox(height: 7),
            Text(
              especialidad!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 9),
              OutlinedButton.icon(
                onPressed: onCambiarPassword,
                icon: const Icon(Icons.key_outlined, size: 17),
                label: const Text('Contraseña'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
