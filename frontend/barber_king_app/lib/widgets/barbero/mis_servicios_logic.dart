part of '../../screens/barbero/mis_servicios_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _MisServiciosLogica on _MisServiciosScreenState {
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final perfil = await _usuarios.obtenerPerfilActual();
    final barbero = perfil?['barbero'];

    if (barbero is! Map) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error =
            'No encontramos tu perfil de barbero. '
            'Actualiza tus datos desde Mi perfil.';
      });
      return;
    }

    final catalogo = (await _servicios.obtenerServicios(
      soloActivos: true,
    )).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    final mios = await _mios.obtenerMis();

    if (!mounted) return;

    _limpiar();

    final propios = <int, Map>{};
    for (final fila in mios.whereType<Map>()) {
      final id = int.tryParse('${fila['servicio_id']}');
      if (id != null) propios[id] = fila;
    }

    for (final servicio in catalogo) {
      final id = int.tryParse('${servicio['id']}');
      if (id == null) continue;

      final propio = propios[id];

      _atiendo[id] = propio != null;
      _precios[id] = TextEditingController(
        text: _texto(propio?['precio_propio']),
      );
      _duraciones[id] = TextEditingController(
        text: _texto(propio?['duracion_propia']),
      );
    }

    setState(() {
      _catalogo = catalogo
          .where((servicio) => int.tryParse('${servicio['id']}') != null)
          .toList();
      _cargando = false;
      _error = catalogo.isEmpty ? 'El catálogo de servicios está vacío.' : null;
    });
  }

  Widget _cardDelServicio(Map<String, dynamic> servicio) {
    final id = int.tryParse('${servicio['id']}') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _ServicioCard(
        servicio: servicio,
        activo: _atiendo[id] == true,
        precio: _precios[id]!,
        duracion: _duraciones[id]!,
        onCambiar: (value) => setState(() => _atiendo[id] = value),
      ),
    );
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    final lista = <Map<String, dynamic>>[];

    for (final servicio in _catalogo) {
      final id = int.tryParse('${servicio['id']}');
      if (id == null || _atiendo[id] != true) continue;

      lista.add({
        'servicio_id': id,
        'precio': _numero(_precios[id]?.text),
        'duracion': _numero(_duraciones[id]?.text, entero: true),
      });
    }

    if (lista.isEmpty) {
      showAppSnack(
        context,
        'Marca al menos un servicio que atiendas.',
        error: true,
      );
      return;
    }

    setState(() => _guardando = true);

    final respuesta = await _mios.guardarMis(lista);

    if (!mounted) return;

    setState(() => _guardando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Servicios actualizados.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) await _cargar();
  }

  void _limpiar() {
    for (final controller in [..._precios.values, ..._duraciones.values]) {
      controller.dispose();
    }
    _atiendo.clear();
    _precios.clear();
    _duraciones.clear();
  }

  /// Devuelve el número sin decimales ni ceros sobrantes para pintar el campo.
  String _texto(dynamic valor) {
    final numero = num.tryParse('$valor');
    if (numero == null) return '';
    return numero == numero.round() ? '${numero.round()}' : '$numero';
  }

  /// Campo vacío = null = "cobra la tarifa del catálogo".
  Object? _numero(String? texto, {bool entero = false}) {
    final limpio = (texto ?? '').trim().replaceAll(',', '.');
    if (limpio.isEmpty) return null;

    final numero = entero ? int.tryParse(limpio) : num.tryParse(limpio);
    if (numero == null || numero <= 0) return null;

    return numero;
  }
}
