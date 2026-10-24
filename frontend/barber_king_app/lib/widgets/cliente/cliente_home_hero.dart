part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomeHeroCita extends StatelessWidget {
  final bool cargando;
  final Map<String, dynamic>? cita;
  final VoidCallback onBuscarBarbero;
  final VoidCallback onVerCitas;

  const _ClienteHomeHeroCita({
    required this.cargando,
    required this.cita,
    required this.onBuscarBarbero,
    required this.onVerCitas,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const AppCard(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cita == null) {
      return AppCard(
        gradient: AppColors.heroGradient,
        borderColor: AppColors.primary.withValues(alpha: .3),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.content_cut_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu próximo look comienza aquí',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Reserva con los mejores barberos y disfruta de una experiencia premium.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBuscarBarbero,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('BUSCAR BARBERO'),
              ),
            ),
          ],
        ),
      );
    }

    final servicio = cita!['servicios'];
    final estado = cita!['estado']?.toString() ?? 'Pendiente';

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
                Icons.event_available_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'TU PRÓXIMA CITA',
                  style: TextStyle(
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
          const SizedBox(height: 13),
          Text(
            servicio is Map
                ? servicio['nombre']?.toString() ?? 'Servicio'
                : 'Servicio',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormat.dateLong(cita!['fecha'])} · '
            '${AppFormat.time(cita!['hora'])}',
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: onVerCitas,
            icon: const Icon(Icons.event_note_outlined, size: 17),
            label: const Text('Ver mis citas'),
          ),
        ],
      ),
    );
  }
}
