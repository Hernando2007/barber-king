part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomeStats extends StatelessWidget {
  final int totalCitas;
  final int completadas;
  final int totalServicios;

  const _ClienteHomeStats({
    required this.totalCitas,
    required this.completadas,
    required this.totalServicios,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.event_note_outlined,
            label: 'Mis reservas',
            value: '$totalCitas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            icon: Icons.check_circle_outline_rounded,
            label: 'Completadas',
            value: '$completadas',
            accent: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            icon: Icons.design_services_outlined,
            label: 'Servicios',
            value: '$totalServicios',
            accent: AppColors.info,
          ),
        ),
      ],
    );
  }
}
