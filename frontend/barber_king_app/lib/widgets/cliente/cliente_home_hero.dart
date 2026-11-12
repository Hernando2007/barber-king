part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomeHeroCita extends StatelessWidget {
  final bool cargando;
  final Map<String, dynamic>? cita;
  final String nombreBarbero;
  final VoidCallback onBuscarBarbero;
  final VoidCallback onVerCitas;

  const _ClienteHomeHeroCita({
    required this.cargando,
    required this.cita,
    required this.nombreBarbero,
    required this.onBuscarBarbero,
    required this.onVerCitas,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const AppCard(
        padding: EdgeInsets.symmetric(vertical: 34),
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
                onPressed: onBuscarBarbero,
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
              StatusPill(
                label: estado,
                color: AppFormat.statusColor(estado),
              ),
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
                  child: _ClienteHomeHeroDato(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha',
                    valor: AppFormat.date(cita!['fecha']),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ClienteHomeHeroDato(
                    icon: Icons.schedule_rounded,
                    label: 'Hora',
                    valor: AppFormat.time(cita!['hora']),
                  ),
                ),
                if (precio != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ClienteHomeHeroDato(
                      icon: Icons.payments_outlined,
                      label: 'Precio',
                      valor: precio,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerCitas,
              icon: const Icon(Icons.event_note_outlined, size: 17),
              label: const Text('Ver mis reservas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClienteHomeHeroDato extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _ClienteHomeHeroDato({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 8.5,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
