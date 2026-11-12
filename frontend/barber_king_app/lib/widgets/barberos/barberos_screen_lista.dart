import 'package:flutter/material.dart';

import '../common/app_ui.dart';
import 'barberos_screen_card.dart';

class BarberosLista extends StatelessWidget {
  final List<Map<String, dynamic>> barberos;
  final bool puedeReservar;
  final bool cercaActiva;
  final bool soloVerificados;
  final void Function(Map<String, dynamic>) onReservar;
  final void Function(Map<String, dynamic>) onAbrirPerfil;

  const BarberosLista({
    super.key,
    required this.barberos,
    required this.puedeReservar,
    required this.cercaActiva,
    required this.onReservar,
    required this.onAbrirPerfil,
    this.soloVerificados = false,
  });

  @override
  Widget build(BuildContext context) {
    if (barberos.isEmpty) {
      return EmptyState(
        icon: soloVerificados
            ? Icons.verified_outlined
            : cercaActiva
            ? Icons.location_off_outlined
            : Icons.people_alt_outlined,
        title: soloVerificados
            ? 'Sin barberos verificados'
            : cercaActiva
            ? 'Sin barberos cerca'
            : 'Sin barberos disponibles',
        message: soloVerificados
            ? 'Ningún barbero de esta selección tiene el sello de verificación. Prueba con otro filtro.'
            : cercaActiva
            ? 'Ningún barbero ha compartido su ubicación en tu zona. Toca el botón para ver todo el equipo.'
            : 'El equipo se está actualizando. Vuelve a intentarlo pronto.',
      );
    }

    return Column(
      children: barberos
          .map(
            (barbero) => BarberosScreenCard(
              barbero: barbero,
              puedeReservar: puedeReservar,
              onReservar: () => onReservar(barbero),
              onAbrirPerfil: () => onAbrirPerfil(barbero),
            ),
          )
          .toList(),
    );
  }
}
