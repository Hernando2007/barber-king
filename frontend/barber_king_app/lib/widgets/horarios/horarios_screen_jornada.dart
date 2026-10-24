part of '../../screens/horarios/horarios_screen.dart';

bool _activo(dynamic value) {
  return value == true || value == 1 || '$value' == 'true';
}

String _hora(dynamic value) {
  final parts = '${value ?? ''}'.split(':');

  if (parts.length < 2) return '--:--';

  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

class _JornadaRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final Future<void> Function(Map<String, dynamic> horario) onEditar;
  final Future<void> Function(Map<String, dynamic> horario) onAlternar;
  final Future<void> Function(Map<String, dynamic> horario) onEliminar;

  const _JornadaRow({
    required this.item,
    required this.onEditar,
    required this.onAlternar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final activo = _activo(item['activo']);

    return Padding(
      padding: const EdgeInsets.only(left: 47, top: 6, bottom: 2),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: activo ? AppColors.primary : AppColors.muted,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_hora(item['hora_inicio'])} - ${_hora(item['hora_fin'])}',
                  style: TextStyle(
                    color: activo ? AppColors.white : AppColors.subtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StatusPill(
                  label: activo ? 'Activo' : 'Inactivo',
                  color: activo ? AppColors.success : AppColors.muted,
                  icon: activo
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.subtitle,
              size: 19,
            ),
            color: AppColors.card,
            tooltip: 'Opciones',
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  onEditar(item);
                  break;
                case 'estado':
                  onAlternar(item);
                  break;
                case 'eliminar':
                  onEliminar(item);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'estado',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    activo
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  title: Text(
                    activo ? 'Desactivar' : 'Activar',
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 19,
                  ),
                  title: Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
