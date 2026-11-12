import 'package:flutter/material.dart';

class BarberosScreenAcciones extends StatelessWidget {
  final bool disponible;
  final VoidCallback onReservar;
  final VoidCallback onVerPerfil;

  const BarberosScreenAcciones({
    super.key,
    required this.disponible,
    required this.onReservar,
    required this.onVerPerfil,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onVerPerfil,
            icon: const Icon(Icons.person_outline_rounded, size: 17),
            label: const Text('Ver perfil'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: disponible ? onReservar : null,
            icon: const Icon(Icons.calendar_month_outlined, size: 17),
            label: const Text('Reservar'),
          ),
        ),
      ],
    );
  }
}
