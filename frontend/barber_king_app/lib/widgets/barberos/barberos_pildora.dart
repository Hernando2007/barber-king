import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Píldora compartida por los filtros de barberos: el mismo lenguaje visual
/// dorado de las pestañas de Reservas.
class BarberosPildora extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final int? conteo;
  final IconData? icono;
  final VoidCallback onTap;

  const BarberosPildora({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.conteo,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: seleccionado ? AppColors.goldGradient : null,
              color: seleccionado ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: seleccionado ? Colors.transparent : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(
                    icono,
                    size: 14,
                    color: seleccionado ? AppColors.black : AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: seleccionado ? AppColors.black : AppColors.subtitle,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (conteo != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? AppColors.black.withValues(alpha: .16)
                          : AppColors.backgroundSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$conteo',
                      style: TextStyle(
                        color: seleccionado ? AppColors.black : AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
