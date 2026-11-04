import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// El sello que el administrador concede; la misma señal en lista y perfil.
class SelloVerificado extends StatelessWidget {
  final bool visible;
  final double size;

  const SelloVerificado({super.key, required this.visible, this.size = 17});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Tooltip(
      message: 'Barbero verificado por Barber King',
      child: Icon(Icons.verified_rounded, color: AppColors.primary, size: size),
    );
  }
}
