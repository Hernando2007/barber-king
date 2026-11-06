import 'package:flutter/material.dart';

class BarberosScreenAcciones extends StatelessWidget {
  final bool disponible;
  final VoidCallback onReservar;

  const BarberosScreenAcciones({
    super.key,
    required this.disponible,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: disponible ? onReservar : null,
        icon: const Icon(Icons.calendar_month_outlined, size: 17),
        label: const Text('Reservar'),
      ),
    );
  }
}