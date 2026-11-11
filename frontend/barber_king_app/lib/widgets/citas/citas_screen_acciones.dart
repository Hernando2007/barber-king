part of '../../screens/citas/citas_screen.dart';

class _CitasScreenAcciones extends StatelessWidget {
  final Map<String, dynamic> cita;
  final String estado;
  final bool esAdmin;
  final bool puedeCancelar;
  final void Function(Map<String, dynamic>, String) onCambiarEstado;
  final Future<void> Function(Map<String, dynamic>) onCancelar;
  final Future<void> Function(Map<String, dynamic>) onReprogramar;

  const _CitasScreenAcciones({
    required this.cita,
    required this.estado,
    required this.esAdmin,
    required this.puedeCancelar,
    required this.onCambiarEstado,
    required this.onCancelar,
    required this.onReprogramar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (esAdmin)
          ElevatedButton(
            onPressed: () => onCambiarEstado(cita, 'Completada'),
            child: const Text('Completar'),
          ),
        if (!esAdmin && estado.toLowerCase() != 'cancelada')
          TextButton.icon(
            onPressed: () => onReprogramar(cita),
            icon: const Icon(Icons.update_rounded, size: 17),
            label: const Text('Reprogramar'),
          ),
        if (puedeCancelar)
          TextButton.icon(
            onPressed: () => onCancelar(cita),
            icon: const Icon(
              Icons.cancel_outlined,
              size: 17,
              color: AppColors.error,
            ),
            label: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

Widget _dato(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.muted, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
