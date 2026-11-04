part of '../../screens/citas/crear_cita_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

/// Servicio y barbero se filtran mutuamente. Al elegir un servicio solo quedan
/// los barberos que lo prestan; al elegir barbero solo quedan sus servicios,
/// con el precio y la duración que él haya fijado.
extension _CrearCitaFiltros on _CrearCitaScreenState {
  List<Map<String, dynamic>> get _serviciosVisibles =>
      _serviciosDelBarbero.isNotEmpty ? _serviciosDelBarbero : _listaServicios;

  Map<String, dynamic>? get _servicioSeleccionado {
    for (final servicio in _serviciosVisibles) {
      if (servicio['id'] == _servicioId) return servicio;
    }
    return null;
  }

  void _onServicioChanged(int? value) {
    setState(() {
      _servicioId = value;
      _hora = null;
    });
    _filtrarBarberosPorServicio(value);
  }

  void _onBarberoChanged(int? value) {
    setState(() {
      _barberoId = value;
      _hora = null;
    });
    _cargarServiciosDelBarbero(value);
  }

  Future<void> _filtrarBarberosPorServicio(int? servicioId) async {
    final crudos = await _barberos.obtenerBarberos(servicioId: servicioId);

    if (!mounted) return;

    final lista = _mapearBarberos(crudos);

    setState(() {
      _listaBarberos = lista;

      if (_barberoId != null && !lista.any((b) => b['id'] == _barberoId)) {
        _barberoId = null;
        _serviciosDelBarbero = [];
      }
    });

    _consultarDisponibilidad();
  }

  Future<void> _cargarServiciosDelBarbero(int? barberoId) async {
    if (barberoId == null) {
      setState(() => _serviciosDelBarbero = []);
      _consultarDisponibilidad();
      return;
    }

    final crudos = await _serviciosBarbero.obtenerDeBarbero(barberoId);

    if (!mounted) return;

    final lista = crudos
        .whereType<Map>()
        .map((fila) => Map<String, dynamic>.from(fila))
        .map(
          (fila) => <String, dynamic>{
            'id': fila['servicio_id'],
            'nombre': fila['nombre'],
            'descripcion': fila['descripcion'],
            'imagen': fila['imagen'],
            'precio': fila['precio'],
            'duracion': fila['duracion'],
          },
        )
        .toList();

    setState(() {
      _serviciosDelBarbero = lista;

      if (_servicioId != null && !lista.any((s) => s['id'] == _servicioId)) {
        _servicioId = null;
      }
    });

    _consultarDisponibilidad();
  }

  List<Map<String, dynamic>> _mapearBarberos(List<dynamic> crudos) {
    return crudos
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['disponible'] != false)
        .toList();
  }
}
