// ignore_for_file: invalid_use_of_protected_member

part of '../../screens/solicitudes/solicitudes_screen.dart';

/// Lectura de la bandeja y respuesta de un toque.
extension _SolicitudesHoja on _SolicitudesScreenState {
  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final usuario = await _auth.obtenerUsuario();
    final rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
    final data = await _solicitudes.mis();

    if (!mounted) return;

    setState(() {
      _rol = rol;
      _pendientes = int.tryParse('${data?['pendientes'] ?? 0}') ?? 0;
      _lista = _filas(data?['solicitudes']);
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'todas') return _lista;

    return _lista.where((solicitud) {
      return '${solicitud['estado'] ?? 'pendiente'}' == _filtro;
    }).toList();
  }

  void _elegirBarbero() {
    Navigator.pushNamed(context, AppRoutes.barberos);
  }

  void _abrirBarbero(Map<String, dynamic> solicitud) {
    final barbero = solicitud['barberos'];

    if (barbero is! Map) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilBarberoScreen(barbero: {'id': barbero['id']}),
      ),
    );
  }

  Future<void> _responder(
    Map<String, dynamic> solicitud,
    String clave, {
    String? nota,
  }) async {
    final id = int.tryParse('${solicitud['id']}');

    if (id == null) return;

    setState(() => _ocupada = id);

    final respuesta = await _solicitudes.responder(id, clave, nota: nota);

    if (!mounted) return;

    setState(() => _ocupada = null);

    if (respuesta['success'] != true) {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo responder.',
        error: true,
      );

      return;
    }

    await _cargar();
  }

  /// Los mismos botones, pero dejando que el barbero escriba una línea antes.
  Future<void> _conNota(Map<String, dynamic> solicitud) async {
    final elegida = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _DialogoNota(solicitud: solicitud),
    );

    if (elegida == null || !mounted) return;

    await _responder(
      solicitud,
      '${elegida['clave']}',
      nota: elegida['nota']?.toString(),
    );
  }
}

List<Map<String, dynamic>> _filas(dynamic valor) {
  if (valor is! List) {
    return [];
  }

  return valor.whereType<Map>().map(Map<String, dynamic>.from).toList();
}
