import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';

/// Cabecera del equipo: resume cuántos barberos hay y cuántos están
/// verificados, con el mismo tono premium de las demás secciones.
class BarberosEncabezado extends StatelessWidget {
  final int total;
  final int verificados;

  const BarberosEncabezado({
    super.key,
    required this.total,
    required this.verificados,
  });

  String get _resumen {
    final profesionales = total == 1 ? '1 profesional' : '$total profesionales';
    final sellados = verificados == 1
        ? '1 verificado'
        : '$verificados verificados';

    return '$profesionales · $sellados';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              color: AppColors.black,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu barbero ideal',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _resumen,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (verificados > 0)
            const Icon(
              Icons.verified_rounded,
              color: AppColors.primary,
              size: 22,
            ),
        ],
      ),
    );
  }
}
