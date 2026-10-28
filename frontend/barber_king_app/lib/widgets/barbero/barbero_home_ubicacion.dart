part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoUbicacionCard extends StatefulWidget {
  const _BarberoUbicacionCard();

  @override
  State<_BarberoUbicacionCard> createState() => _BarberoUbicacionCardState();
}

class _BarberoUbicacionCardState extends State<_BarberoUbicacionCard> {
  final UbicacionService _ubicacion = UbicacionService();
  final BarberoService _barberos = BarberoService();

  Timer? _timer;
  bool _activo = false;
  bool _enviando = false;
  DateTime? _ultima;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _alternar(bool valor) async {
    if (!valor) {
      _timer?.cancel();
      setState(() => _activo = false);
      return;
    }

    setState(() => _activo = true);

    if (!await _enviar()) {
      if (mounted) setState(() => _activo = false);
      return;
    }

    _timer = Timer.periodic(const Duration(minutes: 3), (_) async {
      if (!await _enviar() && mounted) {
        _timer?.cancel();
        setState(() => _activo = false);
      }
    });
  }

  Future<bool> _enviar() async {
    if (_enviando) return true;

    setState(() => _enviando = true);

    try {
      final posicion = await _ubicacion.obtenerPosicion();
      final respuesta = await _barberos.actualizarUbicacion(
        latitud: posicion.latitud,
        longitud: posicion.longitud,
      );

      if (respuesta['success'] != true) {
        if (mounted) {
          showAppSnack(
            context,
            respuesta['message']?.toString() ??
                'No fue posible compartir tu ubicación.',
            error: true,
          );
        }
        return false;
      }

      if (mounted) {
        setState(() => _ultima = DateTime.now());
      }

      return true;
    } on UbicacionException catch (e) {
      if (mounted) {
        showAppSnack(context, e.mensaje, error: true);
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  String get _detalle {
    if (_enviando) return 'Actualizando ubicación...';

    if (!_activo) {
      return 'Actívala para aparecer en "cerca de mí"';
    }

    final fecha = _ultima;

    if (fecha == null) return 'Compartiendo ubicación...';

    final minutos = DateTime.now().difference(fecha).inMinutes;

    return minutos < 1
        ? 'Compartiendo · ahora'
        : 'Compartiendo · hace $minutos min';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación en tiempo real',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _detalle,
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
              Switch.adaptive(
                value: _activo,
                activeThumbColor: AppColors.primary,
                onChanged: _enviando ? null : _alternar,
              ),
            ],
          ),
          if (_activo) ...[
            const SizedBox(height: 10),
            const Text(
              'Se actualiza cada 3 minutos mientras la app esté abierta. Los clientes solo ven la distancia aproximada.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
