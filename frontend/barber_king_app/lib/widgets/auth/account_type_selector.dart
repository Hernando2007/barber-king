import 'package:flutter/material.dart';

import '../../core/colors.dart';

class AccountTypeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const AccountTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de cuenta',
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _option(
                context,
                3,
                Icons.person_outline,
                'Cliente',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _option(
                context,
                2,
                Icons.content_cut,
                'Barbero',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _option(
    BuildContext context,
    int role,
    IconData icon,
    String label,
  ) {
    final selected = value == role;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .16)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
