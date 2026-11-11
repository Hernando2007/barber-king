part of '../../screens/admin/admin_home_screen.dart';

class _AdminHomeUltimosUsuarios extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _AdminHomeUltimosUsuarios({required this.data});

  @override
  Widget build(BuildContext context) {
    final lista = data?['ultimosUsuarios'];

    if (lista is! List || lista.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'Sin usuarios registrados',
        message: 'Los nuevos usuarios aparecerán aquí.',
      );
    }

    final usuarios = lista
        .take(4)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      radius: 18,
      child: Column(
        children: [
          for (var i = 0; i < usuarios.length; i++) ...[
            _fila(usuarios[i]),
            if (i < usuarios.length - 1)
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _fila(Map<String, dynamic> usuario) {
    final nombre = '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
        .trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          AppAvatar(name: nombre, radius: 17),
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
                const SizedBox(height: 2),
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
          const SizedBox(width: 8),
          Text(
            AppFormat.date(usuario['created_at']),
            style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _AdminHomeUltimasCitas extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _AdminHomeUltimasCitas({required this.data});

  @override
  Widget build(BuildContext context) {
    final lista = data?['ultimasCitas'];

    if (lista is! List || lista.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Aún no hay reservas',
        message: 'Las citas recientes se mostrarán aquí.',
      );
    }

    final citas = lista
        .take(4)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      radius: 18,
      child: Column(
        children: [
          for (var i = 0; i < citas.length; i++) ...[
            _fila(citas[i]),
            if (i < citas.length - 1)
              const Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _fila(Map<String, dynamic> cita) {
    final cliente = cita['usuarios'];
    final nombre = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : '';
    final servicio = cita['servicios'];
    final estado = cita['estado']?.toString() ?? 'Pendiente';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppFormat.time(cita['hora']),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormat.date(cita['fecha']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
                Text(
                  servicio is Map
                      ? servicio['nombre']?.toString() ?? 'Servicio'
                      : 'Servicio',
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
          const SizedBox(width: 8),
          StatusPill(label: estado, color: AppFormat.statusColor(estado)),
        ],
      ),
    );
  }
}
