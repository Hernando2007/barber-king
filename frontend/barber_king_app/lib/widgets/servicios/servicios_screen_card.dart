part of '../../screens/servicios/servicios_screen.dart';

class _ServiciosCard extends StatelessWidget {
  final Map<String, dynamic> servicio;
  final bool esAdmin;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ServiciosCard({
    required this.servicio,
    required this.esAdmin,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final activo = servicio['estado'] != false;
    final precio = AppFormat.money(servicio['precio']);
    final duracion = servicio['duracion'] ?? 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: AppColors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio['nombre']?.toString() ?? 'Servicio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      servicio['descripcion']?.toString().isNotEmpty == true
                          ? servicio['descripcion'].toString()
                          : 'Servicio profesional Barber King',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (esAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.subtitle,
                  ),
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      onEditar();
                    } else if (accion == 'eliminar') {
                      onEliminar();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined, size: 19),
                        title: Text('Editar'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.error,
                        ),
                        title: Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                precio,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.schedule_rounded,
                color: AppColors.muted,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '$duracion min',
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              StatusPill(
                label: activo ? 'Activo' : 'Inactivo',
                color: activo ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          if (!esAdmin) ...[
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CrearCitaScreen(
                        servicioInicial: int.tryParse('${servicio['id']}'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Reservar este servicio'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
