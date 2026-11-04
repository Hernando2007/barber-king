part of '../../screens/barberos/perfil_barbero_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _PerfilBarberoDatos on _PerfilBarberoScreenState {
  String? get _foto => _usuario['foto']?.toString();

  String get _especialidad {
    final valor = _datos['especialidad']?.toString().trim() ?? '';
    return valor.isEmpty ? 'Barbero profesional' : valor;
  }

  String? get _descripcion => _datos['descripcion']?.toString().trim();

  bool get _disponible => _datos['disponible'] != false;

  int get _experiencia => int.tryParse('${_datos['experiencia'] ?? 0}') ?? 0;

  double get _promedio =>
      (_datos['calificacion_promedio'] as num?)?.toDouble() ?? 0;

  int get _totalResenas => int.tryParse('${_datos['total_resenas'] ?? 0}') ?? 0;

  double? get _distancia =>
      double.tryParse('${_datos['distancia_km'] ?? ''}') ??
      double.tryParse('${widget.barbero['distancia_km'] ?? ''}');

  String get _lugar => [
    _datos['ciudad']?.toString(),
    _datos['zona']?.toString(),
  ].where((valor) => valor != null && valor.trim().isNotEmpty).join(' · ');

  Future<void> _cargar() async {
    final id = int.tryParse('${widget.barbero['id']}');

    if (id == null) {
      setState(() => _cargando = false);
      return;
    }

    final futuraDetalle = _barberos.obtenerBarbero(id);
    final futuraUsuario = _auth.obtenerUsuario();
    final futuraResenas = _resenas.obtenerMias();
    final futuraCitas = _citas.obtenerCitas();
    final futuraServicios = _serviciosBarbero.obtenerDeBarbero(id);

    final detalle = await futuraDetalle;
    final usuario = await futuraUsuario;
    final propias = (await futuraResenas).whereType<Map>();
    final citas = (await futuraCitas).whereType<Map>();
    final servicios = _mapearServicios(await futuraServicios);

    if (!mounted) return;

    final calificadas = propias
        .map((resena) => int.tryParse('${resena['cita_id']}'))
        .whereType<int>()
        .toSet();

    setState(() {
      if (detalle != null) {
        _datos = detalle;
      }
      _miPerfil =
          usuario != null &&
          detalle != null &&
          detalle['usuario_id'] == usuario['id'];
      _rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
      _servicios = servicios;
      _citaPendiente = _pendientePorCalificar(citas, id, calificadas);
      _cargando = false;
    });
  }

  /// La primera cita completada de este barbero que el cliente aún no
  /// ha calificado.
  int? _pendientePorCalificar(
    Iterable<Map<dynamic, dynamic>> citas,
    int barberoId,
    Set<int> calificadas,
  ) {
    for (final cita in citas) {
      final citaId = int.tryParse('${cita['id']}');
      final dueno = cita['barberos'];
      final barbero = dueno is Map ? int.tryParse('${dueno['id']}') : null;
      final completada =
          '${cita['estado'] ?? ''}'.toLowerCase() == 'completada';

      if (citaId == null || barbero != barberoId || !completada) continue;
      if (calificadas.contains(citaId)) continue;

      return citaId;
    }

    return null;
  }

  List<Map<String, dynamic>> _mapearServicios(List<dynamic> crudos) {
    return crudos
        .whereType<Map>()
        .where((fila) => fila['servicio_activo'] != false)
        .map((fila) => Map<String, dynamic>.from(fila))
        .toList();
  }

  Future<void> _calificar() async {
    final citaId = _citaPendiente;
    final barberoId = _barberoId;

    if (citaId == null || barberoId == null) return;

    final publicada = await mostrarHojaResena(
      context,
      nombreBarbero: _nombre,
      citaId: citaId,
      barberoId: barberoId,
    );

    if (publicada) {
      await _cargar();
    }
  }

  Future<void> _reservar() async {
    await BarberosAcciones.reservar(context, _datos);
  }
}
