part of 'notificacion_segundo_plano.dart';

enum _Ciclo {
  /// Hay sesión válida: la próxima revisión puede volver en un minuto.
  seguir,

  /// La app está abierta o el token fue rechazado: conviene esperar más.
  lento,

  /// No hay sesión: se apagan las tareas de fondo.
  cerrar,
}

class _Sesion {
  const _Sesion(this.token, this.usuarioId);

  final String token;
  final int usuarioId;
}

Future<void> _revisarAvisos() async {
  // Un fallo puntual (sin red, token corrupto) no debe romper la cadena.
  final ciclo = await _avisarAvisosNuevos().catchError((_) => _Ciclo.lento);

  switch (ciclo) {
    case _Ciclo.cerrar:
      await NotificacionSegundoPlano.detener();
    case _Ciclo.lento:
      await NotificacionSegundoPlano.encolar(const Duration(minutes: 5));
    case _Ciclo.seguir:
      await NotificacionSegundoPlano.encolar(const Duration(seconds: 60));
  }
}

Future<_Ciclo> _avisarAvisosNuevos() async {
  final sesion = await _leerSesion();

  if (sesion == null) return _Ciclo.cerrar;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  // Con la app visible ya avisa AvisosNotificacionService; no duplicar.
  if (_appEnPrimerPlano(prefs)) return _Ciclo.lento;

  final clave = '${NotificacionSegundoPlano.claveUltimo}${sesion.usuarioId}';
  final ultimo = prefs.getInt(clave) ?? 0;

  final data = await _pedirNovedades(sesion.token, ultimo);

  if (data == null) return _Ciclo.lento;

  final nuevoUltimo = int.tryParse('${data['ultimo_id']}') ?? ultimo;

  if (nuevoUltimo != ultimo) {
    await prefs.setInt(clave, nuevoUltimo);
  }

  final crudos = (data['avisos'] as List? ?? [])
      .whereType<Map>()
      .map((aviso) => Map<String, dynamic>.from(aviso))
      .toList();

  final pendientes = ultimo <= 0 ? _soloRecientes(crudos) : crudos;

  if (pendientes.isEmpty) return _Ciclo.seguir;

  final plugin = await _prepararCanalAviso();

  if (plugin == null) return _Ciclo.seguir;

  final visibles = pendientes.length > 3
      ? pendientes.sublist(pendientes.length - 3)
      : pendientes;

  for (final aviso in visibles) {
    await _avisarAviso(plugin, aviso);
  }

  return _Ciclo.seguir;
}

Future<_Sesion?> _leerSesion() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  final token = prefs.getString(NotificacionSegundoPlano.claveToken) ?? '';
  final usuarioId = prefs.getInt(NotificacionSegundoPlano.claveUsuarioId) ?? 0;

  if (token.isNotEmpty && usuarioId > 0) {
    return _Sesion(token, usuarioId);
  }

  const storage = FlutterSecureStorage();
  final tokenSeguro = await storage.read(key: 'token');
  final crudo = await storage.read(key: 'usuario');

  if (tokenSeguro == null || tokenSeguro.isEmpty || crudo == null) {
    return null;
  }

  final decodificado = jsonDecode(crudo);
  final id = decodificado is Map
      ? int.tryParse('${decodificado['id']}') ?? 0
      : 0;

  if (id <= 0) return null;

  await prefs.setString(NotificacionSegundoPlano.claveToken, tokenSeguro);
  await prefs.setInt(NotificacionSegundoPlano.claveUsuarioId, id);

  return _Sesion(tokenSeguro, id);
}

bool _appEnPrimerPlano(SharedPreferences prefs) {
  final abiertaHasta =
      prefs.getInt(NotificacionSegundoPlano.claveAppAbiertaEn) ?? 0;

  return (prefs.getBool(NotificacionSegundoPlano.claveAppAbierta) ?? false) &&
      DateTime.now().millisecondsSinceEpoch - abiertaHasta < 180000;
}

/// Devuelve `null` si no hay datos (error de red o token rechazado).
Future<Map<String, dynamic>?> _pedirNovedades(String token, int desdeId) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    ),
  );

  try {
    final respuesta = await dio.get(
      '/avisos/novedades',
      queryParameters: {'desde_id': desdeId},
    );

    final data = respuesta.data;

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    return null;
  } catch (_) {
    return null;
  } finally {
    dio.close(force: true);
  }
}

/// Sin marcador previo avisa solo lo último, para no spam de avisos viejos.
List<Map<String, dynamic>> _soloRecientes(List<Map<String, dynamic>> avisos) {
  final limite = DateTime.now().subtract(const Duration(minutes: 20));

  return avisos.where((aviso) {
    final fecha = DateTime.tryParse('${aviso['creado']}');

    return fecha != null && fecha.toLocal().isAfter(limite);
  }).toList();
}
