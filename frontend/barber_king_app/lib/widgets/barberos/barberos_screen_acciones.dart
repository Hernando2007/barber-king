import 'package:flutter/material.dart';

class BarberosScreenAcciones extends StatelessWidget {
  final bool puedeChatear;
  final bool puedeReservar;
  final bool disponible;
  final VoidCallback onChat;
  final VoidCallback onReservar;

  const BarberosScreenAcciones({
    super.key,
    required this.puedeChatear,
    required this.puedeReservar,
    required this.disponible,
    required this.onChat,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: puedeChatear ? onChat : null,
            icon: const Icon(Icons.forum_outlined, size: 17),
            label: const Text('Chatear'),
          ),
        ),
        if (puedeReservar) ...[
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: disponible ? onReservar : null,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 17,
              ),
              label: const Text('Reservar'),
            ),
          ),
        ],
      ],
    );
  }
}
