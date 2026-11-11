part of '../../screens/barbero/agenda_screen.dart';

class _AgendaDetalle extends StatelessWidget {
  final Map<String, dynamic> cita;
  final Future<void> Function(Map<String, dynamic>, String) onEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;

  const _AgendaDetalle({
    required this.cita,
    required this.onEstado,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final cliente = cita['usuarios'];
    final correo = cliente is Map ? '${cliente['correo'] ?? ''}' : '';
    final servicio = cita['servicios'];
    final nombreServicio = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';
    final precio = servicio is Map ? servicio['precio'] : null;
    final inicio = _minutosDe(cita['hora']);
    final duracion = _duracionDe(cita);
    final observaciones = '${cita['observaciones'] ?? ''}'.trim();
    final nombre = _nombreCliente(cita);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AppAvatar(name: nombre, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre.isEmpty ? 'Cliente' : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (correo.isNotEmpty)
                        Text(
                          correo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.subtitle,
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(
                  label: estado,
                  color: AppFormat.statusColor(estado),
                ),
              ],
            ),
            const SizedBox(height: 18),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: _capital(AppFormat.dateLong(cita['fecha'])),
            ),
            InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Hora',
              value: duracion > 0
                  ? '${_horaTexto(inicio)} – ${_horaTexto(inicio + duracion)} '
                        '($duracion min)'
                  : _horaTexto(inicio),
            ),
            InfoRow(
              icon: Icons.content_cut_outlined,
              label: 'Servicio',
              value: nombreServicio,
            ),
            InfoRow(
              icon: Icons.payments_outlined,
              label: 'Precio',
              value: AppFormat.money(precio),
            ),
            InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Observaciones del cliente',
              value: observaciones.isEmpty ? 'Sin observaciones' : observaciones,
            ),
            const SizedBox(height: 6),
            _AgendaAcciones(
              cita: cita,
              onEstado: (cita, estado) async {
                Navigator.of(context).pop();
                await onEstado(cita, estado);
              },
              onCancelar: (cita) async {
                Navigator.of(context).pop();
                await onCancelar(cita);
              },
            ),
          ],
        ),
      ),
    );
  }
}