import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'account_type_selector.dart';

class RegisterAccountType extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const RegisterAccountType({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tipo de cuenta',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        AccountTypeSelector(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
