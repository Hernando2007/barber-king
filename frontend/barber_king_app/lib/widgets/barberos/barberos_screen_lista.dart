import 'package:flutter/material.dart';

import '../common/app_ui.dart';
import 'barberos_screen_card.dart';

class BarberosLista extends StatelessWidget {
  final List<Map<String, dynamic>> barberos;
  final bool puedeChatear;
  final bool puedeReservar;
  final bool cercaActiva;
  final void Function(Map<String, dynamic>) onChat;
  final void Function(Map<String, dynamic>) onReservar;
  final void Function(Map<String, dynamic>) onMapa;

  const BarberosLista({
    super.key,
    required this.barberos,
    required this.puedeChatear,
    required this.puedeReservar,
    required this.cercaActiva,
    required this.onChat,
    required this.onReservar,
    required this.onMapa,
  });

  @override
  Widget build(BuildContext context) {
    if (barberos.isEmpty) {
      return EmptyState(
        icon: cercaActiva
            ? Icons.location_off_outlined
            : Icons.people_alt_outlined,
        title: cercaActiva ? 'Sin barberos cerca' : 'Sin barberos disponibles',
        message: cercaActiva
            ? 'Ningún barbero ha compartido su ubicación en tu zona. Toca el botón para ver todo el equipo.'
            : 'El equipo se está actualizando. Vuelve a intentarlo pronto.',
      );
    }

    return Column(
      children: barberos
          .map(
            (barbero) => BarberosScreenCard(
              barbero: barbero,
              puedeChatear: puedeChatear,
              puedeReservar: puedeReservar,
              onChat: () => onChat(barbero),
              onReservar: () => onReservar(barbero),
              onMapa: () => onMapa(barbero),
            ),
          )
          .toList(),
    );
  }
}
