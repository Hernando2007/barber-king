import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';

class ServicioFormHeader extends StatelessWidget {
  final bool esEdicion;

  const ServicioFormHeader({super.key, required this.esEdicion});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.design_services_outlined,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              esEdicion
                  ? 'Actualiza la información del servicio'
                  : 'Agrega un servicio al catálogo',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
