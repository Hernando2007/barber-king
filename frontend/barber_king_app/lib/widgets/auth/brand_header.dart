import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';

class BrandHeader extends StatelessWidget {
  final String subtitle;

  const BrandHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: const Icon(Icons.content_cut, color: AppColors.primary, size: 34),
        ),
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