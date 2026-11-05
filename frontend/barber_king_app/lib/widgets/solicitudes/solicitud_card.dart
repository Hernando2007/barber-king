part of '../../screens/solicitudes/solicitudes_screen.dart';

/// Una solicitud. El barbero ve los botones de respuesta; el cliente ve la
/// contestación que ya quedó guardada.
class _SolicitudesCard extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  final bool esBarbero;
  final bool ocupada;
  final ValueChanged<String> onResponder;
  final VoidCallback onConNota;
  final VoidCallback? onVerBarbero;

  const _SolicitudesCard({
    required this.solicitud,
    required this.esBarbero,
    required this.ocupada,
    required this.onResponder,
    required this.onConNota,
    this.onVerBarbero,
  });

  String get _estado => '${solicitud['estado'] ?? 'pendiente'}';

  bool get _pendiente => _estado == 'pendiente';

  Color get _colorEstado {
    if (_estado == 'aceptada') return AppColors.success;
    if (_estado == 'rechazada') return AppColors.error;

    return AppColors.primary;
  }

  String get _quien {
    final valor =
        (esBarbero ? solicitud['cliente_nombre'] : solicitud['barbero_nombre'])
            ?.toString()
            .trim() ??
        '';

    if (valor.isNotEmpty) return valor;

    return esBarbero ? 'Cliente' : 'Barbero';
  }

  String _texto(String campo) => solicitud[campo]?.toString().trim() ?? '';

  Map<String, dynamic>? _mapa(String campo) {
    final valor = solicitud[campo];

    return valor is Map ? Map<String, dynamic>.from(valor) : null;
  }

  String get _titulos {
    final motivo = _texto('motivo_etiqueta');
    final fecha = _texto('fecha_propuesta');

    if (fecha.isEmpty) return motivo;

    return '$motivo · ${AppFormat.dateLong(fecha)}';
  }

  @override
  Widget build(BuildContext context) {
    final servicio = _mapa('servicios');
    final cita = _mapa('citas');
    final nota = _texto('nota');
    final respuesta = solicitud['respuesta_texto']?.toString();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
      radius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: _quien, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onVerBarbero,
                      child: Text(
                        _quien,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _titulos,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(label: _estado, color: _colorEstado),
            ],
          ),
          if (servicio != null || cita != null || nota.isNotEmpty) ...[
            const SizedBox(height: 10),
            if (servicio?['nombre'] != null)
              _Linea(
                icon: Icons.content_cut_rounded,
                texto: '${servicio?['nombre']}',
              ),
            if (cita != null)
              _Linea(
                icon: Icons.event_available_outlined,
                texto:
                    '${AppFormat.dateLong(cita['fecha'])} · '
                    '${cita['estado']} (${AppFormat.time(cita['hora'])})',
              ),
            if (nota.isNotEmpty)
              _Linea(icon: Icons.edit_note_rounded, texto: nota),
          ],
          if (_pendiente && esBarbero) ...[
            const SizedBox(height: 12),
            _BotoneraRespuesta(
              opciones: _listas('opciones'),
              ocupada: ocupada,
              onResponder: onResponder,
              onConNota: onConNota,
            ),
          ],
          if (_pendiente && !esBarbero) ...[
            const SizedBox(height: 10),
            const _Esperando(),
          ],
          if (!_pendiente && respuesta != null && respuesta.isNotEmpty) ...[
            const SizedBox(height: 11),
            _CajaRespuesta(texto: respuesta, color: _colorEstado),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _listas(String campo) {
    final valor = solicitud[campo];

    if (valor is! List) {
      return [];
    }

    return valor.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}
