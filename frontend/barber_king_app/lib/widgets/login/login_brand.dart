import 'package:flutter/material.dart';

import '../../core/colors.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .28),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.content_cut_rounded,
            color: AppColors.black,
            size: 37,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'BARBER KING',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
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
