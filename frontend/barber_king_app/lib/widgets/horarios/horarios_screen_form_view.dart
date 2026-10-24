part of '../../screens/horarios/horarios_screen.dart';

class _HorarioFormView extends StatelessWidget {
  final bool editando;
  final int dia;
  final List<String> dias;
  final TimeOfDay inicio;
  final TimeOfDay fin;
  final bool activo;
  final String? error;
  final bool guardando;
  final ValueChanged<int> onDiaChanged;
  final Future<void> Function({required bool inicio}) onSeleccionarHora;
  final ValueChanged<bool> onActivoChanged;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;

  const _HorarioFormView({
    required this.editando,
    required this.dia,
    required this.dias,
    required this.inicio,
    required this.fin,
    required this.activo,
    required this.error,
    required this.guardando,
    required this.onDiaChanged,
    required this.onSeleccionarHora,
    required this.onActivoChanged,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando ? 'Editar jornada' : 'Nueva jornada',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Elige el día y el rango de atención.',
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        DropdownButtonFormField<int>(
          initialValue: dia,
          dropdownColor: AppColors.card,
          decoration: const InputDecoration(
            labelText: 'Día de trabajo',
            prefixIcon: Icon(Icons.calendar_today_rounded),
          ),
          items: List.generate(dias.length, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(dias[index]),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              onDiaChanged(value);
            }
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _TimeBox(
                label: 'Hora de inicio',
                value: inicio,
                onTap: () => onSeleccionarHora(inicio: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeBox(
                label: 'Hora de fin',
                value: fin,
                onTap: () => onSeleccionarHora(inicio: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: activo,
            onChanged: onActivoChanged,
            title: const Text(
              'Jornada activa',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Los clientes solo pueden reservar en jornadas activas.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 11,
              ),
            ),
            activeThumbColor: AppColors.primary,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 20),
        PrimaryGradientButton(
          label: editando ? 'Guardar cambios' : 'Crear jornada',
          icon: Icons.check_rounded,
          loading: guardando,
          onPressed: onGuardar,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: guardando ? null : onCancelar,
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
