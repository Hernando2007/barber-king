part of '../../screens/barbero/agenda_screen.dart';

class _AgendaResumen extends StatelessWidget {
  final DateTime dia;
  final List<Map<String, dynamic>> citas;

  const _AgendaResumen({required this.dia, required this.citas});

  @override
  Widget build(BuildContext context) {
    final vivas = citas
        .where((cita) => '${cita['estado'] ?? ''}'.toLowerCase() != 'cancelada')
        .toList();
    final porConfirmar = vivas
        .where((cita) => '${cita['estado'] ?? ''}'.toLowerCase() == 'pendiente')
        .length;
    final confirmadas = vivas
        .where((cita) => '${cita['estado'] ?? ''}'.toLowerCase() == 'confirmada')
        .length;
    final completadas = citas
        .where((cita) => '${cita['estado'] ?? ''}'.toLowerCase() == 'completada')
        .length;
    final ingreso = vivas.fold<num>(0, (suma, cita) {
      final servicio = cita['servicios'];

      return suma +
          (servicio is Map ? num.tryParse('${servicio['precio']}') ?? 0 : 0);
    });

    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capital(AppFormat.dateLong(dia)),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vivas.length} '
                      '${vivas.length == 1 ? 'reserva' : 'reservas'} en el día',
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppFormat.money(ingreso),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _contador('$porConfirmar', 'Por confirmar', AppColors.warning),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(
                child: _contador('$confirmadas', 'Confirmadas', AppColors.info),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(
                child: _contador('$completadas', 'Completadas', AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contador(String valor, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.subtitle, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}