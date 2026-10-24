part of '../../screens/admin/admin_usuarios_screen.dart';

class _AdminUsuariosCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _AdminUsuariosCard({
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    final rolId = int.tryParse('${usuario['rol_id']}') ?? 0;
    final rol = usuario['rol']?.toString() ?? AppFormat.role(rolId);
    final activo = usuario['estado'] != false;
    final barbero = usuario['barbero'];
    final especialidad = barbero is Map
        ? barbero['especialidad']?.toString()
        : null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      onTap: onEditar,
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                name: nombre.isEmpty ? 'Usuario' : nombre,
                photoUrl: usuario['foto']?.toString(),
                radius: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nombre.isEmpty ? 'Usuario' : nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        StatusPill(
                          label: rol,
                          color: rolId == 1
                              ? AppColors.primary
                              : rolId == 2
                              ? AppColors.info
                              : AppColors.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      usuario['correo']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                    if (especialidad != null && especialidad.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        especialidad,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.subtitle,
                ),
                onSelected: (accion) {
                  if (accion == 'editar') {
                    onEditar();
                  } else {
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                activo
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_outlined,
                size: 15,
                color: activo ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(
                activo ? 'Cuenta activa' : 'Cuenta desactivada',
                style: TextStyle(
                  color: activo ? AppColors.success : AppColors.error,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                usuario['telefono']?.toString() ?? 'Sin teléfono',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
