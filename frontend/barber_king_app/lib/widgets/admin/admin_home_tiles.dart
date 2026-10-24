part of '../../screens/admin/admin_home_screen.dart';

List<Widget> _ultimosUsuarios(_AdminHomeScreenState state) {
  final lista = state._data?['ultimosUsuarios'];

  if (lista is! List || lista.isEmpty) {
    return const [
      EmptyState(
        icon: Icons.people_outline,
        title: 'Sin usuarios registrados',
        message: 'Los nuevos usuarios aparecerán aquí.',
      ),
    ];
  }

  return lista.take(4).map((item) {
    final usuario = Map<String, dynamic>.from(item as Map);
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      radius: 15,
      child: Row(
        children: [
          AppAvatar(name: nombre, radius: 18),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? 'Usuario' : nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  usuario['correo']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppFormat.date(usuario['created_at']),
            style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
          ),
        ],
      ),
    );
  }).toList();
}

List<Widget> _ultimasCitas(_AdminHomeScreenState state) {
  final lista = state._data?['ultimasCitas'];

  if (lista is! List || lista.isEmpty) {
    return const [
      EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Aún no hay reservas',
        message: 'Las citas recientes se mostrarán aquí.',
      ),
    ];
  }

  return lista.take(4).map((item) {
    final cita = Map<String, dynamic>.from(item as Map);
    final cliente = cita['usuarios'];
    final servicio = cita['servicios'];
    final nombre = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : 'Cliente';
    final estado = cita['estado']?.toString() ?? 'Pendiente';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      radius: 15,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? 'Cliente' : nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${servicio is Map ? servicio['nombre'] ?? 'Servicio' : 'Servicio'} · '
                  '${AppFormat.date(cita['fecha'])} ${AppFormat.time(cita['hora'])}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: estado,
            color: AppFormat.statusColor(estado),
          ),
        ],
      ),
    );
  }).toList();
}
