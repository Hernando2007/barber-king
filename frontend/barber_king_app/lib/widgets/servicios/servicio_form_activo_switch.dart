import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';

class ServicioFormActivoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ServicioFormActivoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: const Text(
          'Servicio activo',
          style: TextStyle(color: AppColors.white, fontSize: 14),
        ),
        subtitle: const Text(
          'Los servicios inactivos no aparecen en las reservas.',
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
