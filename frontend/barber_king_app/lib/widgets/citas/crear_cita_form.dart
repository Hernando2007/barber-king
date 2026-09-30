import 'package:barber_king_app/widgets/common/section_widgets.dart';
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/common/feedback_cards.dart';

class CrearCitaForm extends StatelessWidget {
  final List servicios;
  final List barberos;
  final List horarios;
  final dynamic servicioSeleccionado;
  final dynamic barberoSeleccionado;
  final String? horaSeleccionada;
  final DateTime fecha;
  final bool creando;
  final ValueChanged<dynamic> onServicioChanged;
  final ValueChanged<dynamic> onBarberoChanged;
  final ValueChanged<String> onHoraChanged;
  final VoidCallback onDateTap;
  final VoidCallback onSubmit;

  const CrearCitaForm({
    super.key,
    required this.servicios,
    required this.barberos,
    required this.horarios,
    required this.servicioSeleccionado,
    required this.barberoSeleccionado,
    required this.horaSeleccionada,
    required this.fecha,
    required this.creando,
    required this.onServicioChanged,
    required this.onBarberoChanged,
    required this.onHoraChanged,
    required this.onDateTap,
    required this.onSubmit,
  });

  String _nombreBarbero(dynamic item) {
    final usuario = item is Map ? item['usuarios'] : null;
    if (usuario is! Map) return 'Barbero';
    return '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          icon: Icons.calendar_month,
          title: 'Reserva tu cita',
          text:
              'Agenda tu servicio con un barbero disponible '
              'en la fecha que prefieras.',
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Servicio'),
        const SizedBox(height: 10),
        DropdownButtonFormField<dynamic>(
          initialValue: servicioSeleccionado,
          dropdownColor: AppColors.surface,
          decoration: const InputDecoration(
            hintText: 'Seleccione un servicio',
          ),
          items: servicios.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(
                item['nombre']?.toString() ?? 'Servicio',
              ),
            );
          }).toList(),
          onChanged: onServicioChanged,
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Barbero'),
        const SizedBox(height: 10),
        DropdownButtonFormField<dynamic>(
          initialValue: barberoSeleccionado,
          dropdownColor: AppColors.surface,
          decoration: const InputDecoration(
            hintText: 'Seleccione un barbero',
          ),
          items: barberos.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(_nombreBarbero(item)),
            );
          }).toList(),
          onChanged: onBarberoChanged,
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Fecha'),
        const SizedBox(height: 10),
        InkWell(
          onTap: onDateTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  fecha.toIso8601String().split('T').first,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.subtitle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const SectionTitle(title: 'Horarios disponibles'),
        const SizedBox(height: 15),
        if (horarios.isEmpty)
          const Text(
            'Selecciona servicio, barbero y fecha para consultar '
            'los horarios disponibles.',
            style: TextStyle(
              color: AppColors.subtitle,
              height: 1.4,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: horarios.map<Widget>((item) {
              final hora = item.toString();
              final selected = horaSeleccionada == hora;

              return ChoiceChip(
                label: Text(hora),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => onHoraChanged(hora),
              );
            }).toList(),
          ),
        const SizedBox(height: 36),
        PrimaryButton(
          label: 'Confirmar reserva',
          loading: creando,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
