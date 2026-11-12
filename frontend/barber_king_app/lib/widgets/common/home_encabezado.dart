import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'app_avatar.dart';

/// Encabezado común de los tres inicios: saludo, foto y accesos a perfil y
/// cierre de sesión. Mantiene la misma jerarquía visual en todos los roles.
class HomeEncabezado extends StatelessWidget {
  final String eyebrow;
  final String nombre;
  final String detalle;
  final String? fotoUrl;
  final VoidCallback onPerfil;
  final VoidCallback onSalir;

  const HomeEncabezado({
    super.key,
    required this.eyebrow,
    required this.nombre,
    required this.detalle,
    required this.onPerfil,
    required this.onSalir,
    this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          name: nombre,
          photoUrl: fotoUrl,
          radius: 23,
          fallbackIcon: Icons.person_rounded,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10.5,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detalle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 11.5,
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
          icon: const Icon(Icons.logout_outlined, color: AppColors.primary),
        ),
      ],
    );
  }
}
