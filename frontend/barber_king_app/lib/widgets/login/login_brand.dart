import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/brand_logo.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BrandLogo(size: 92),
        SizedBox(height: 18),
        Text(
          'BARBER KING',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Gestión profesional para tu barbería',
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
