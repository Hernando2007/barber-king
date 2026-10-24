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

class _CrearCitaHorariosSection extends StatelessWidget {
  final bool seleccionIncompleta;
  final bool consultando;
  final List<String> horarios;
  final String? horaSeleccionada;
  final ValueChanged<String> onSeleccionarHora;

  const _CrearCitaHorariosSection({
    required this.seleccionIncompleta,
    required this.consultando,
    required this.horarios,
    required this.horaSeleccionada,
    required this.onSeleccionarHora,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: 'Horarios disponibles',
          subtitle: seleccionIncompleta
              ? 'Selecciona barbero y servicio para ver la disponibilidad.'
              : null,
        ),
        const SizedBox(height: 14),
        if (consultando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          )
        else if (horarios.isEmpty)
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 22,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy_outlined,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  seleccionIncompleta
                      ? 'Completa los datos para consultar horarios.'
                      : 'No hay horarios disponibles para esta fecha.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: horarios.map((hora) {
              final seleccionado = horaSeleccionada == hora;

              return ChoiceChip(
                label: Text(hora),
                selected: seleccionado,
                onSelected: (_) => onSeleccionarHora(hora),
                labelStyle: TextStyle(
                  color: seleccionado ? AppColors.black : AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
      ],
    );
  }
}
