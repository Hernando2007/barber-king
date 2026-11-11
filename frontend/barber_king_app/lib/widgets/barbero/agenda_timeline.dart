part of '../../screens/barbero/agenda_screen.dart';

class _AgendaTimeline extends StatelessWidget {
  final DateTime dia;
  final List<Map<String, dynamic>> citas;
  final Future<void> Function(Map<String, dynamic>, String) onEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onDetalle;

  const _AgendaTimeline({
    required this.dia,
    required this.citas,
    required this.onEstado,
    required this.onCancelar,
    required this.onDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final esHoy = _mismoDia(dia, ahora);
    final minutosAhora = ahora.hour * 60 + ahora.minute;
    final filas = <Widget>[];
    var ahoraPintada = false;

    for (var i = 0; i < citas.length; i++) {
      final cita = citas[i];
      final inicio = _minutosDe(cita['hora']);

      if (esHoy && !ahoraPintada && inicio > minutosAhora) {
        filas.add(_AgendaAhora(minutos: minutosAhora));
        ahoraPintada = true;
      }

      if (i > 0) {
        final anterior = citas[i - 1];
        final finAnterior =
            _minutosDe(anterior['hora']) + _duracionDe(anterior);
        final hueco = inicio - finAnterior;

        if (hueco >= 20 && !_estaCerrada(anterior) && !_estaCerrada(cita)) {
          filas.add(_AgendaHueco(minutos: hueco));
        }
      }

      filas.add(
        _AgendaFila(
          cita: cita,
          onEstado: onEstado,
          onCancelar: onCancelar,
          onDetalle: onDetalle,
        ),
      );
    }

    if (esHoy && !ahoraPintada) {
      filas.add(_AgendaAhora(minutos: minutosAhora));
    }

    return Stack(
      children: [
        Positioned(
          left: 56,
          top: 12,
          bottom: 12,
          child: Container(width: 2, color: AppColors.border),
        ),
        Column(children: filas),
      ],
    );
  }
}

class _AgendaFila extends StatelessWidget {
  final Map<String, dynamic> cita;
  final Future<void> Function(Map<String, dynamic>, String) onEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onDetalle;

  const _AgendaFila({
    required this.cita,
    required this.onEstado,
    required this.onCancelar,
    required this.onDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final inicio = _minutosDe(cita['hora']);
    final duracion = _duracionDe(cita);
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final color = AppFormat.statusColor(estado);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _horaTexto(inicio),
                  style: TextStyle(
                    color: _estaCerrada(cita)
                        ? AppColors.muted
                        : AppColors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (duracion > 0)
                  Text(
                    _horaTexto(inicio + duracion),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 18,
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _AgendaCitaCard(
            cita: cita,
            onEstado: onEstado,
            onCancelar: onCancelar,
            onDetalle: onDetalle,
          ),
        ),
      ],
    );
  }
}

class _AgendaCitaCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final Future<void> Function(Map<String, dynamic>, String) onEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onDetalle;

  const _AgendaCitaCard({
    required this.cita,
    required this.onEstado,
    required this.onCancelar,
    required this.onDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final color = AppFormat.statusColor(estado);
    final servicio = cita['servicios'];
    final nombreServicio = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';
    final precio = servicio is Map ? servicio['precio'] : null;
    final observaciones = '${cita['observaciones'] ?? ''}'.trim();
    final nombre = _nombreCliente(cita);

    return AppCard(
      onTap: () => onDetalle(cita),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      radius: 16,
      borderColor: estado.toLowerCase() == 'pendiente'
          ? AppColors.warning.withValues(alpha: .45)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: nombre, radius: 18),
              const SizedBox(width: 10),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$nombreServicio · ${_duracionDe(cita)} min',
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
              StatusPill(label: estado, color: color),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Text(
                AppFormat.money(precio),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (observaciones.isNotEmpty)
                Tooltip(
                  message: observaciones,
                  child: const Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.muted,
                    size: 15,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),
          _AgendaAcciones(
            cita: cita,
            onEstado: onEstado,
            onCancelar: onCancelar,
            onDetalle: onDetalle,
          ),
        ],
      ),
    );
  }
}

class _AgendaAcciones extends StatelessWidget {
  final Map<String, dynamic> cita;
  final Future<void> Function(Map<String, dynamic>, String) onEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>)? onDetalle;

  const _AgendaAcciones({
    required this.cita,
    required this.onEstado,
    required this.onCancelar,
    this.onDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final estado = '${cita['estado'] ?? ''}'.toLowerCase();

    return Row(
      children: [
        Expanded(
          child: switch (estado) {
            'pendiente' => ElevatedButton.icon(
              onPressed: () => onEstado(cita, 'Confirmada'),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
              label: const Text('Confirmar'),
            ),
            'confirmada' => ElevatedButton.icon(
              onPressed: () => onEstado(cita, 'Completada'),
              icon: const Icon(Icons.task_alt_rounded, size: 17),
              label: const Text('Completar'),
            ),
            _ => Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Text(
                estado == 'completada' ? 'Cita completada' : 'Cita cancelada',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
              ),
            ),
          },
        ),
        const SizedBox(width: 6),
        PopupMenuButton<String>(
          tooltip: 'Más opciones',
          color: AppColors.surfaceAlt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.subtitle,
            size: 20,
          ),
          onSelected: (opcion) {
            if (opcion == 'cancelar') onCancelar(cita);
            if (opcion == 'reabrir') onEstado(cita, 'Confirmada');
            if (opcion == 'detalle') onDetalle?.call(cita);
          },
          itemBuilder: (_) => [
            if (estado == 'pendiente' || estado == 'confirmada')
              const PopupMenuItem(
                value: 'cancelar',
                child: Text(
                  'Cancelar cita',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            if (estado == 'completada')
              const PopupMenuItem(
                value: 'reabrir',
                child: Text('Volver a confirmada'),
              ),
            if (onDetalle != null)
              const PopupMenuItem(
                value: 'detalle',
                child: Text('Ver detalle'),
              ),
          ],
        ),
      ],
    );
  }
}

class _AgendaAhora extends StatelessWidget {
  final int minutos;

  const _AgendaAhora({required this.minutos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              _horaTexto(minutos),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.background, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Ahora',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.primary.withValues(alpha: .35),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaHueco extends StatelessWidget {
  final int minutos;

  const _AgendaHueco({required this.minutos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const SizedBox(width: 18),
          const SizedBox(width: 6),
          const Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.muted,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            '$minutos min libres',
            style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}