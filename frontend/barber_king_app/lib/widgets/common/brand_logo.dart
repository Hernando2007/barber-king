import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Emblema de Barber King: medallón dorado con el logo oficial de la marca.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 82});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .26),
            blurRadius: size * .34,
            spreadRadius: size * .02,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .16),
      child: Image.asset(
        'assets/logo/logo_negro.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.content_cut_rounded, color: AppColors.black),
      ),
    );
  }
}
