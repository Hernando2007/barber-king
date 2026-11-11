part of '../../screens/citas/citas_screen.dart';

class _ClienteReservasHero extends StatelessWidget {
  final Map<String, dynamic>? cita;
  final String nombreBarbero;
  final VoidCallback onReservar;

  const _ClienteReservasHero({
    required this.cita,
    required this.nombreBarbero,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    if (cita == null) {
      return AppCard(
        gradient: AppColors.heroGradient,
        borderColor: AppColors.primary.withValues(alpha: .35),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.black,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sin reservas próximas',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Tu próximo corte empieza con una reserva.',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReservar,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('RESERVAR AHORA'),
              ),
            ),
          ],
        ),
      );
    }

    final servicio = cita!['servicios'];
    final estado = '${cita!['estado'] ?? 'Confirmada'}';
    final color = AppFormat.statusColor(estado);
    final relativo = AppFormat.relativeDay(cita!['fecha']);
    final precio = servicio is Map ? AppFormat.money(servicio['precio']) : null;

    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  relativo.isEmpty
                      ? 'TU PRÓXIMA RESERVA'
                      : 'TU PRÓXIMA RESERVA · ${relativo.toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusPill(label: estado, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            servicio is Map
                ? servicio['nombre']?.toString() ?? 'Servicio'
                : 'Servicio',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppColors.subtitle,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  nombreBarbero.isEmpty
                      ? 'Barbero por confirmar'
                      : nombreBarbero,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: .7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _dato(
                    Icons.calendar_today_outlined,
                    'Fecha',
                    AppFormat.date(cita!['fecha']),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dato(
                    Icons.schedule_rounded,
                    'Hora',
                    AppFormat.time(cita!['hora']),
                  ),
                ),
                if (precio != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dato(Icons.payments_outlined, 'Precio', precio),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClienteReservaCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final String nombreBarbero;
  final bool calificada;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onReprogramar;
  final Future<void> Function(Map<String, dynamic>) onCalificar;

  const _ClienteReservaCard({
    required this.cita,
    required this.nombreBarbero,
    required this.calificada,
    required this.onCancelar,
    required this.onReprogramar,
    required this.onCalificar,
  });

  @override
  Widget build(BuildContext context) {
    final servicio = cita['servicios'];
    final estado = '${cita['estado'] ?? 'Confirmada'}';
    final color = AppFormat.statusColor(estado);
    final estadoLower = estado.toLowerCase();
    final activa = estadoLower == 'confirmada' || estadoLower == 'pendiente';
    final relativo = AppFormat.relativeDay(cita['fecha']);
    final precio = servicio is Map ? AppFormat.money(servicio['precio']) : '-';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderColor: activa
          ? AppColors.primary.withValues(alpha: .28)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ClienteReservaFecha(
                dia: AppFormat.dayNumber(cita['fecha']),
                mes: AppFormat.monthShort(cita['fecha']),
                activa: activa,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            servicio is Map
                                ? servicio['nombre']?.toString() ?? 'Servicio'
                                : 'Servicio',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(label: estado, color: color),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.muted,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            nombreBarbero.isEmpty ? 'Barbero' : nombreBarbero,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _ClienteReservaDato(
                          icon: Icons.schedule_rounded,
                          texto: AppFormat.time(cita['hora']),
                        ),
                        _ClienteReservaDato(
                          icon: Icons.payments_outlined,
                          texto: precio,
                        ),
                        if (relativo.isNotEmpty)
                          _ClienteReservaDato(
                            icon: Icons.today_rounded,
                            texto: relativo,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _acciones(),
        ],
      ),
    );
  }

  Widget _acciones() {
    final estadoLower = '${cita['estado'] ?? 'Confirmada'}'.toLowerCase();
    final activa = estadoLower == 'confirmada' || estadoLower == 'pendiente';

    if (activa) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onReprogramar(cita),
              icon: const Icon(Icons.update_rounded, size: 17),
              label: const Text('Reprogramar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton.icon(
              onPressed: () => onCancelar(cita),
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColors.error,
              ),
              label: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (estadoLower == 'completada' && !calificada)
          OutlinedButton.icon(
            onPressed: () => onCalificar(cita),
            icon: const Icon(Icons.star_outline_rounded, size: 17),
            label: const Text('Calificar'),
          ),
        TextButton.icon(
          onPressed: () => onReprogramar(cita),
          icon: const Icon(Icons.replay_rounded, size: 17),
          label: const Text('Reservar de nuevo'),
        ),
      ],
    );
  }
}

class _ClienteReservaFecha extends StatelessWidget {
  final String dia;
  final String mes;
  final bool activa;

  const _ClienteReservaFecha({
    required this.dia,
    required this.mes,
    required this.activa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: activa
            ? AppColors.primary.withValues(alpha: .1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activa
              ? AppColors.primary.withValues(alpha: .3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            dia,
            style: TextStyle(
              color: activa ? AppColors.primary : AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            mes,
            style: TextStyle(
              color: activa ? AppColors.primary : AppColors.muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClienteReservaDato extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? color;

  const _ClienteReservaDato({
    required this.icon,
    required this.texto,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tono = color ?? AppColors.subtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: tono, size: 12),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: tono,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
