part of '../../screens/admin/admin_revision_screen.dart';

class _AdminRevisionCard extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final bool ocupado;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final VoidCallback onDocumento;

  const _AdminRevisionCard({
    required this.barbero,
    required this.ocupado,
    required this.onAprobar,
    required this.onRechazar,
    required this.onDocumento,
  });

  String get _nombre => barbero['nombre']?.toString().trim() ?? '';

  Map<String, dynamic>? get _diploma {
    final value = barbero['diploma'];

    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Color get _colorEstado {
    final estado = barbero['verificacion_estado']?.toString();

    if (estado == 'rechazado') return AppColors.error;
    if (estado == 'aprobado') return AppColors.success;

    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final diploma = _diploma;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      radius: 17,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: _nombre, radius: 21),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombre.isEmpty ? 'Barbero' : _nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      barbero['correo']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label:
                    barbero['verificacion_estado']?.toString() ?? 'pendiente',
                color: _colorEstado,
              ),
            ],
          ),
          const SizedBox(height: 11),
          _Perfil(barbero: barbero),
          const SizedBox(height: 11),
          _OpinionIA(ia: barbero['ia'], sinDiploma: diploma == null),
          if (diploma != null) ...[
            const SizedBox(height: 8),
            _Documento(
              nombre: diploma['nombre']?.toString() ?? 'documento',
              onTap: onDocumento,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryGradientButton(
                  label: 'APROBAR',
                  icon: Icons.verified_outlined,
                  loading: ocupado,
                  onPressed: ocupado ? null : onAprobar,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ocupado ? null : onRechazar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 46),
                  ),
                  icon: const Icon(Icons.block_outlined, size: 18),
                  label: const Text('RECHAZAR'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
