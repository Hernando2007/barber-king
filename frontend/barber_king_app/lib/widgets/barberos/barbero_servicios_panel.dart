import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../common/app_ui.dart';

/// Lo que hace un barbero y lo que cobra por ello. `servicio_id` es el
/// enlace de la vista, no el id del servicio.
class BarberoServiciosPanel extends StatelessWidget {
  final List<Map<String, dynamic>> servicios;

  const BarberoServiciosPanel({super.key, required this.servicios});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final servicio in servicios)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              radius: 15,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.content_cut_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      servicio['nombre']?.toString() ?? 'Servicio',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${servicio['duracion']} min',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppFormat.money(servicio['precio']),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
