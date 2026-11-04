part of '../../screens/citas/crear_cita_screen.dart';

class _CrearCitaHorariosSection extends StatelessWidget {
  final DateTime fecha;
  final bool seleccionIncompleta;
  final bool consultando;
  final List<String> horarios;
  final String? horaSeleccionada;
  final ValueChanged<String> onSeleccionarHora;

  const _CrearCitaHorariosSection({
    required this.fecha,
    required this.seleccionIncompleta,
    required this.consultando,
    required this.horarios,
    required this.horaSeleccionada,
    required this.onSeleccionarHora,
  });

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final pasadas = horarios
        .where((hora) => horaYaPaso(fecha, hora, ahora: ahora))
        .toSet();
    final todasPasaron = pasadas.length == horarios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: 'Horarios disponibles',
          subtitle: seleccionIncompleta
              ? 'Selecciona barbero y servicio para ver la disponibilidad.'
              : AppFormat.dateLong(fecha),
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
        else ...[
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: horarios.map((hora) {
              final seleccionada = horaSeleccionada == hora;
              final pasada = pasadas.contains(hora);

              return _ChipHora(
                hora: hora,
                seleccionada: seleccionada,
                pasada: pasada,
                onSeleccionarHora: onSeleccionarHora,
              );
            }).toList(),
          ),
          if (pasadas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.schedule_send_outlined,
                  size: 15,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    todasPasaron
                        ? 'Todas las horas de este día ya pasaron. '
                              'Elige otra fecha.'
                        : 'Las horas en gris ya pasaron. '
                              'Solo puedes reservar horas futuras.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _ChipHora extends StatelessWidget {
  final String hora;
  final bool seleccionada;
  final bool pasada;
  final ValueChanged<String> onSeleccionarHora;

  const _ChipHora({
    required this.hora,
    required this.seleccionada,
    required this.pasada,
    required this.onSeleccionarHora,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(hora),
      selected: seleccionada && !pasada,
      onSelected: pasada ? null : (_) => onSeleccionarHora(hora),
      labelStyle: TextStyle(
        color: pasada
            ? AppColors.muted
            : (seleccionada ? AppColors.black : AppColors.white),
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: pasada ? AppColors.card : AppColors.surface,
      side: BorderSide(
        color: pasada ? AppColors.border : Colors.transparent,
      ),
    );
  }
}
