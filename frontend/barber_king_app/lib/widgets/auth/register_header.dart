import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/brand_logo.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.center, child: BrandLogo(size: 74)),
        SizedBox(height: 12),
        Text(
          'ÚNETE A BARBER KING',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Crea tu cuenta y vive la experiencia premium.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.subtitle, fontSize: 14),
        ),
      ],
    );
  }
}
