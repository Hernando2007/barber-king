part of '../../screens/perfil/perfil_screen.dart';

class _PerfilUbicacionCard extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final bool cargando;
  final VoidCallback onCompartir;

  const _PerfilUbicacionCard({
    required this.barbero,
    required this.cargando,
    required this.onCompartir,
  });

  String get _lugar {
    final lugar = [barbero['ciudad'], barbero['zona']]
        .where((valor) => valor != null && valor.toString().trim().isNotEmpty)
        .join(', ');

    return lugar.isEmpty ? 'Sin ciudad ni zona definidas' : lugar;
  }

  String get _estado {
    final fecha = DateTime.tryParse(
      '${barbero['ubicacion_actualizada'] ?? ''}',
    );

    if (fecha == null) {
      return 'Aún no compartes tu ubicación';
    }

    final diferencia = DateTime.now().difference(fecha.toLocal());

    if (diferencia.inMinutes < 1) {
      return 'Actualizada hace un momento';
    }

    if (diferencia.inMinutes < 60) {
      return 'Actualizada hace ${diferencia.inMinutes} min';
    }

    if (diferencia.inHours < 24) {
      return 'Actualizada hace ${diferencia.inHours} h';
    }

    return 'Actualizada hace ${diferencia.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final compartida =
        barbero['latitud'] != null && barbero['longitud'] != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Ubicación',
          icon: Icons.my_location_rounded,
          subtitle: 'Para que los clientes te encuentren',
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _estado,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _lugar,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: compartida ? 'Visible' : 'Sin ubicación',
                    color: compartida ? AppColors.success : AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ElevatedButton.icon(
                onPressed: cargando ? null : onCompartir,
                icon: cargando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed_rounded, size: 17),
                label: Text(
                  cargando
                      ? 'Obteniendo ubicación...'
                      : 'Compartir ubicación actual',
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Los clientes solo ven la distancia aproximada y tu ciudad; nunca tus coordenadas exactas.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
