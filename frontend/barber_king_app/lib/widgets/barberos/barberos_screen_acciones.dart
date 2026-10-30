import 'package:flutter/material.dart';

class BarberosScreenAcciones extends StatelessWidget {
  final bool ubicacionVigente;
  final bool puedeChatear;
  final bool puedeReservar;
  final bool disponible;
  final VoidCallback onChat;
  final VoidCallback onReservar;
  final VoidCallback onMapa;

  const BarberosScreenAcciones({
    super.key,
    required this.ubicacionVigente,
    required this.puedeChatear,
    required this.puedeReservar,
    required this.disponible,
    required this.onChat,
    required this.onReservar,
    required this.onMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (ubicacionVigente) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onMapa,
              icon: const Icon(Icons.map_outlined, size: 17),
              label: const Text('Ver ubicación en el mapa'),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
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
        ),
      ],
    );
  }
}
