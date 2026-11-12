part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeHero extends StatelessWidget {
  final int citasHoy;
  final int pendientes;
  final int total;
  final VoidCallback onVerAgenda;

  const _AdminHomeHero({
    required this.citasHoy,
    required this.pendientes,
    required this.total,
    required this.onVerAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = citasHoy == 0
        ? 'Sin citas para hoy'
        : '$citasHoy ${citasHoy == 1 ? 'cita para hoy' : 'citas para hoy'}';
    final detalle = citasHoy == 0
        ? 'La agenda de hoy está libre. Revisa las próximas reservas.'
        : pendientes == 0
        ? 'Todo confirmado. La agenda del día está en orden.'
        : '$pendientes ${pendientes == 1 ? 'reserva espera' : 'reservas esperan'} '
              'confirmación.';

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
                  Icons.calendar_month_rounded,
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
                      'AGENDA DEL NEGOCIO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Hoy en Barber King',
                      style: TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: pendientes == 0 ? 'Al día' : '$pendientes pendientes',
                color: pendientes == 0
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detalle,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12,
              height: 1.45,
            ),
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
                  child: _AdminHomeHeroDato(
                    icon: Icons.today_rounded,
                    label: 'Hoy',
                    valor: '$citasHoy',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdminHomeHeroDato(
                    icon: Icons.pending_actions_outlined,
                    label: 'Pendientes',
                    valor: '$pendientes',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdminHomeHeroDato(
                    icon: Icons.event_note_outlined,
                    label: 'Histórico',
                    valor: '$total',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onVerAgenda,
              icon: const Icon(Icons.event_note_outlined, size: 18),
              label: const Text('VER AGENDA COMPLETA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHomeHeroDato extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _AdminHomeHeroDato({
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
