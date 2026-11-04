part of '../../screens/barbero/mis_servicios_screen.dart';

class _CantidadPill extends StatelessWidget {
  final int cantidad;
  final int total;

  const _CantidadPill({required this.cantidad, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = cantidad > 0 ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 16, color: color),
        const SizedBox(width: 7),
        Text(
          'Atiendes $cantidad de $total servicios',
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ServicioCard extends StatelessWidget {
  final Map<String, dynamic> servicio;
  final bool activo;
  final TextEditingController precio;
  final TextEditingController duracion;
  final ValueChanged<bool> onCambiar;

  const _ServicioCard({
    required this.servicio,
    required this.activo,
    required this.precio,
    required this.duracion,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = servicio['nombre']?.toString() ?? 'Servicio';
    final catalogo = AppFormat.money(servicio['precio']);
    final minutos = servicio['duracion'] ?? 0;

    return AppCard(
      radius: 18,
      borderColor: activo
          ? AppColors.primary.withValues(alpha: .35)
          : AppColors.border,
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
                      nombre,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Catálogo: $catalogo · $minutos min',
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: activo,
                activeThumbColor: AppColors.primary,
                onChanged: onCambiar,
              ),
            ],
          ),
          if (activo) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppField(
                    label: 'Tu precio',
                    hint: 'Igual al catálogo',
                    icon: Icons.payments_outlined,
                    controller: precio,
                    keyboard: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppField(
                    label: 'Tus minutos',
                    hint: '$minutos min',
                    icon: Icons.timer_outlined,
                    controller: duracion,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
