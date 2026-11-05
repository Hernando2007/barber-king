import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../common/brand_logo.dart';

class BrandHeader extends StatelessWidget {
  final String subtitle;

  const BrandHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrandLogo(size: 80),
        const SizedBox(height: 18),
        Text(
          'BARBER KING',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.subtitle, fontSize: 13),
        ),
      ],
    );
  }
}
