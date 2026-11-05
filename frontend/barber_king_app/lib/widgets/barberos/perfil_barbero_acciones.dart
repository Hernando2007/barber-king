import 'package:flutter/material.dart';

import '../common/app_ui.dart';
import 'barberos_acciones.dart';

/// Los botones de acción del perfil: reservar, solicitar, ver ubicación y
/// calificar la última cita.
class PerfilBarberoAcciones extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final bool puedeReservar;
  final bool puedeSolicitar;
  final bool disponible;
  final bool puedeCalificar;
  final Future<void> Function() onReservar;
  final Future<void> Function() onCalificar;

  const PerfilBarberoAcciones({
    super.key,
    required this.barbero,
    required this.puedeReservar,
    required this.puedeSolicitar,
    required this.disponible,
    required this.puedeCalificar,
    required this.onReservar,
    required this.onCalificar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (puedeReservar) ...[
          PrimaryGradientButton(
            label: 'Reservar cita',
            icon: Icons.calendar_month_outlined,
            onPressed: disponible ? onReservar : null,
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            if (puedeSolicitar) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => BarberosAcciones.solicitar(context, barbero),
                  icon: const Icon(Icons.send_outlined, size: 17),
                  label: const Text('Solicitar'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => BarberosAcciones.abrirMapa(context, barbero),
                icon: const Icon(Icons.map_outlined, size: 17),
                label: const Text('Ubicación'),
              ),
            ),
          ],
        ),
        if (puedeCalificar) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCalificar,
              icon: const Icon(Icons.star_outline_rounded, size: 17),
              label: const Text('Calificar mi cita'),
            ),
          ),
        ],
      ],
    );
  }
}
