part of '../../screens/citas/crear_cita_screen.dart';

class _CrearCitaFechaCard extends StatelessWidget {
  final DateTime fecha;
  final Map<String, dynamic>? servicio;
  final Future<void> Function() onElegirFecha;

  const _CrearCitaFechaCard({
    required this.fecha,
    required this.onElegirFecha,
    this.servicio,
  });

  @override
  Widget build(BuildContext context) {
    final servicio = this.servicio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          title: 'Fecha',
          icon: Icons.event_outlined,
        ),
        const SizedBox(height: 12),
        AppCard(
          onTap: onElegirFecha,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          radius: 14,
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppFormat.dateLong(fecha),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
        if (servicio != null) ...[
          const SizedBox(height: 12),
          Text(
            '${AppFormat.money(servicio['precio'])} · '
            '${servicio['duracion'] ?? 0} min',
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12.5,
            ),
          ),
        ],
      ],
    );
  }
}
