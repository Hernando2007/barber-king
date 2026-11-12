part of '../../screens/perfil/perfil_screen.dart';

class _PerfilHeaderCard extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final bool esBarbero;
  final bool verificado;
  final bool disponible;
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
    required this.verificado,
    required this.disponible,
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
      padding: EdgeInsets.zero,
      radius: 24,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              height: 96,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -26,
                    child: Icon(
                      esBarbero
                          ? Icons.content_cut_rounded
                          : Icons.person_rounded,
                      size: 140,
                      color: AppColors.primary.withValues(alpha: .06),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: esBarbero && disponible
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          esBarbero
                              ? 'PERFIL PROFESIONAL'
                              : 'MI CUENTA',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -38),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.card,
                              width: 2,
                            ),
                          ),
                          child: AppAvatar(
                            name: nombre.isEmpty ? 'Usuario' : nombre,
                            photoUrl: fotoUrl,
                            radius: 41,
                            fallbackIcon: esBarbero
                                ? Icons.content_cut_rounded
                                : Icons.person_rounded,
                          ),
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
                    const SizedBox(height: 13),
                    Text(
                      nombre.isEmpty ? 'Usuario' : nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        StatusPill(
                          label: rolLabel,
                          color: AppColors.primary,
                          icon: Icons.badge_outlined,
                        ),
                        if (esBarbero && verificado)
                          const StatusPill(
                            label: 'Verificado',
                            color: AppColors.success,
                            icon: Icons.verified_rounded,
                          ),
                        if (esBarbero)
                          StatusPill(
                            label: disponible ? 'Disponible' : 'No disponible',
                            color: disponible
                                ? AppColors.success
                                : AppColors.muted,
                            icon: disponible
                                ? Icons.storefront
                                : Icons.storefront_outlined,
                          ),
                      ],
                    ),
                    if (esBarbero && especialidad?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
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
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEditar,
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCambiarPassword,
                            icon: const Icon(Icons.key_outlined, size: 17),
                            label: const Text('Contraseña'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Manual, privacidad y cierre de sesión agrupados para que el final del
/// perfil no parezca una lista de botones sueltos.
class _PerfilAccionesCuenta extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onPrivacidad;
  final VoidCallback onSalir;
  final VoidCallback onEliminar;

  const _PerfilAccionesCuenta({
    required this.onManual,
    required this.onPrivacidad,
    required this.onSalir,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Manual de usuario',
        'Guía paso a paso de la app',
        Icons.menu_book_outlined,
        AppColors.primary,
        onManual,
      ),
      (
        'Política de privacidad',
        'Cómo cuidamos tus datos',
        Icons.privacy_tip_outlined,
        AppColors.info,
        onPrivacidad,
      ),
      (
        'Cerrar sesión',
        'Salir de tu cuenta en este equipo',
        Icons.logout_outlined,
        AppColors.error,
        onSalir,
      ),
      (
        'Eliminar cuenta',
        'Borra tu perfil y todos tus datos',
        Icons.delete_forever_outlined,
        AppColors.error,
        onEliminar,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Cuenta y soporte',
          subtitle: 'Ayuda, privacidad y sesión',
          icon: Icons.manage_accounts_outlined,
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          radius: 18,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: items[i].$5,
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
                              color: items[i].$4.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              items[i].$3,
                              color: items[i].$4,
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
                                  style: TextStyle(
                                    color: items[i].$4 == AppColors.error
                                        ? AppColors.error
                                        : AppColors.white,
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
        ),
      ],
    );
  }
}
