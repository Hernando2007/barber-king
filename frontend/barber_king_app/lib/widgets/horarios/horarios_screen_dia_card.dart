part of '../../screens/horarios/horarios_screen.dart';

class _DiaCardView extends StatelessWidget {
  final int dia;
  final String nombre;
  final List<Map<String, dynamic>> items;
  final Future<void> Function(int dia) onAgregar;
  final Future<void> Function(Map<String, dynamic> horario) onEditar;
  final Future<void> Function(Map<String, dynamic> horario) onAlternar;
  final Future<void> Function(Map<String, dynamic> horario) onEliminar;

  const _DiaCardView({
    required this.dia,
    required this.nombre,
    required this.items,
    required this.onAgregar,
    required this.onEditar,
    required this.onAlternar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final esHoy = DateTime.now().weekday == dia;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      radius: 17,
      borderColor: esHoy
          ? AppColors.primary.withValues(alpha: .34)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: esHoy
                      ? AppColors.primary.withValues(alpha: .16)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$dia',
                  style: TextStyle(
                    color: esHoy ? AppColors.primary : AppColors.subtitle,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    if (esHoy) ...[
                      const SizedBox(width: 8),
                      const StatusPill(
                        label: 'Hoy',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onAgregar(dia),
                icon: const Icon(Icons.add_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Agregar jornada',
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 47, top: 2, bottom: 4),
              child: Text(
                'Día libre',
                style: TextStyle(
                  color: AppColors.muted.withValues(alpha: .9),
                  fontSize: 12,
                ),
              ),
            )
          else
            ...items.map(
              (item) => _JornadaRow(
                item: item,
                onEditar: onEditar,
                onAlternar: onAlternar,
                onEliminar: onEliminar,
              ),
            ),
        ],
      ),
    );
  }
}
