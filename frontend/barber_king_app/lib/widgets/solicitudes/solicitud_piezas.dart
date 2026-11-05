part of '../../screens/solicitudes/solicitudes_screen.dart';

/// Filtro por estado, igual que el de citas.
class _SolicitudesFiltros extends StatelessWidget {
  final String filtro;
  final ValueChanged<String> onSeleccionar;

  const _SolicitudesFiltros({
    required this.filtro,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final estado in const [
            'pendiente',
            'aceptada',
            'rechazada',
            'todas',
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(estado[0].toUpperCase() + estado.substring(1)),
                selected: filtro == estado,
                onSelected: (_) => onSeleccionar(estado),
                labelStyle: TextStyle(
                  color: filtro == estado
                      ? AppColors.primary
                      : AppColors.subtitle,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Linea({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.subtitle),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los botones que manda el servidor: uno por cada respuesta posible.
class _BotoneraRespuesta extends StatelessWidget {
  final List<Map<String, dynamic>> opciones;
  final bool ocupada;
  final ValueChanged<String> onResponder;
  final VoidCallback onConNota;

  const _BotoneraRespuesta({
    required this.opciones,
    required this.ocupada,
    required this.onResponder,
    required this.onConNota,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opcion in opciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OpcionRespuesta(
              texto: opcion['texto']?.toString() ?? '',
              aceptada: opcion['estado'] == 'aceptada',
              ocupada: ocupada,
              onTap: () => onResponder(opcion['clave']?.toString() ?? ''),
            ),
          ),
        if (opciones.isNotEmpty)
          TextButton.icon(
            onPressed: ocupada ? null : onConNota,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.subtitle,
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
            icon: const Icon(Icons.edit_note_rounded, size: 16),
            label: const Text(
              'Responder con una línea',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _SolicitudesVacio extends StatelessWidget {
  final bool esBarbero;

  const _SolicitudesVacio({required this.esBarbero});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox_rounded,
      title: esBarbero ? 'Bandeja vacía' : 'Sin solicitudes',
      message: esBarbero
          ? 'Cuando un cliente te pregunte por un hueco, aparecerá aquí.'
          : 'Pide hora, presupuesto o cambiar una cita sin escribir nada.',
    );
  }
}
