part of '../../screens/citas/citas_screen.dart';

class _CitasScreenFiltros extends StatelessWidget {
  final String filtro;
  final ValueChanged<String> onSeleccionar;

  const _CitasScreenFiltros({
    required this.filtro,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final estado in const [
            'Todas',
            'Pendiente',
            'Confirmada',
            'Completada',
            'Cancelada',
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(estado),
                selected: filtro == estado,
                onSelected: (_) => onSeleccionar(estado),
                labelStyle: TextStyle(
                  color: filtro == estado
                      ? AppColors.primary
                      : AppColors.subtitle,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CitasScreenEmpty extends StatelessWidget {
  final bool esBarbero;
  final VoidCallback? onNuevaCita;

  const _CitasScreenEmpty({required this.esBarbero, this.onNuevaCita});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy_outlined,
      title: 'Sin citas',
      message: esBarbero
          ? 'Aún no tienes reservas registradas.'
          : 'No hay citas que coincidan con este filtro.',
      actionLabel: esBarbero ? null : 'Reservar ahora',
      onAction: esBarbero ? null : onNuevaCita,
    );
  }
}
