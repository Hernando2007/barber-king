part of '../../screens/citas/citas_screen.dart';

class _CitasScreenFiltros extends StatelessWidget {
  final String filtro;
  final List<String> estados;
  final Map<String, int>? conteos;
  final ValueChanged<String> onSeleccionar;

  const _CitasScreenFiltros({
    required this.filtro,
    required this.estados,
    required this.onSeleccionar,
    this.conteos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final estado in estados)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CitasScreenFiltroChip(
                label: estado,
                seleccionado: filtro == estado,
                conteo: conteos?[estado],
                onTap: () => onSeleccionar(estado),
              ),
            ),
        ],
      ),
    );
  }
}

class _CitasScreenFiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final int? conteo;
  final VoidCallback onTap;

  const _CitasScreenFiltroChip({
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.conteo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: seleccionado ? AppColors.goldGradient : null,
            color: seleccionado ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: seleccionado ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: seleccionado ? AppColors.black : AppColors.subtitle,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (conteo != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.black.withValues(alpha: .16)
                        : AppColors.backgroundSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$conteo',
                    style: TextStyle(
                      color: seleccionado ? AppColors.black : AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CitasScreenEmpty extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CitasScreenEmpty({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy_outlined,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
