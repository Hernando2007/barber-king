part of '../../screens/citas/citas_screen.dart';

class _CitasScreenCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final bool esBarbero;
  final bool esAdmin;
  final Map<int, String> nombresBarberos;
  final void Function(Map<String, dynamic>, String) onCambiarEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onChatCliente;
  final Future<void> Function(Map<String, dynamic>) onChatBarbero;

  const _CitasScreenCard({
    required this.cita,
    required this.esBarbero,
    required this.esAdmin,
    required this.nombresBarberos,
    required this.onCambiarEstado,
    required this.onCancelar,
    required this.onChatCliente,
    required this.onChatBarbero,
  });

  @override
  Widget build(BuildContext context) {
    final cliente = cita['usuarios'];
    final servicio = cita['servicios'];
    final barbero = cita['barberos'];
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final color = AppFormat.statusColor(estado);
    final barberoId = barbero is Map
        ? int.tryParse('${barbero['id']}')
        : null;

    final titulo = esBarbero || esAdmin
        ? cliente is Map
              ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
              : 'Cliente'
        : (nombresBarberos[barberoId]?.isNotEmpty == true
              ? nombresBarberos[barberoId]!
              : 'Barbero');

    final subtitulo = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';

    final puedeCancelar =
        !esBarbero &&
        estado.toLowerCase() != 'cancelada' &&
        estado.toLowerCase() != 'completada';

    final puedeGestionar =
        (esBarbero || esAdmin) &&
        estado.toLowerCase() != 'cancelada' &&
        estado.toLowerCase() != 'completada';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.isEmpty ? 'Cliente' : titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(label: estado, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dato(
                  Icons.calendar_today_outlined,
                  'Fecha',
                  AppFormat.date(cita['fecha']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.schedule_rounded,
                  'Hora',
                  AppFormat.time(cita['hora']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.payments_outlined,
                  'Precio',
                  servicio is Map
                      ? AppFormat.money(servicio['precio'])
                      : '-',
                ),
              ),
            ],
          ),
          if (puedeGestionar || puedeCancelar) ...[
            const SizedBox(height: 13),
            _CitasScreenAcciones(
              cita: cita,
              estado: estado,
              esBarbero: esBarbero,
              esAdmin: esAdmin,
              puedeCancelar: puedeCancelar,
              onCambiarEstado: onCambiarEstado,
              onCancelar: onCancelar,
              onChatCliente: onChatCliente,
              onChatBarbero: onChatBarbero,
            ),
          ],
        ],
      ),
    );
  }
}
