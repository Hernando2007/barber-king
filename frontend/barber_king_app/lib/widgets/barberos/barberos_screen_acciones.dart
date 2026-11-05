import 'package:flutter/material.dart';

class BarberosScreenAcciones extends StatelessWidget {
  final bool puedeSolicitar;
  final bool puedeReservar;
  final bool disponible;
  final VoidCallback onSolicitar;
  final VoidCallback onReservar;

  const BarberosScreenAcciones({
    super.key,
    required this.puedeSolicitar,
    required this.puedeReservar,
    required this.disponible,
    required this.onSolicitar,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: puedeSolicitar ? onSolicitar : null,
            icon: const Icon(Icons.send_outlined, size: 17),
            label: const Text('Solicitar'),
          ),
        ),
        if (puedeReservar) ...[
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: disponible ? onReservar : null,
              icon: const Icon(Icons.calendar_month_outlined, size: 17),
              label: const Text('Reservar'),
            ),
          ),
        ],
      ],
    );
  }
}
