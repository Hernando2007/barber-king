part of 'notificacion_segundo_plano.dart';

const String _prefijoRecordatorio = 'recordatorio_cita_';
const Duration _vidaRecordatorios = Duration(days: 15);

/// De la más ajustada a la más amplia: se avisa una vez por ventana.
const List<({Duration adelanto, String etiqueta})> _ventanasRecordatorio = [
  (adelanto: Duration(hours: 2), etiqueta: '2h'),
  (adelanto: Duration(hours: 24), etiqueta: '24h'),
];

Future<void> _avisarCitasCercanas() async {
  final sesion = await _leerSesion();

  if (sesion == null) return;

  final citas = await _pedirCitasProximas(sesion.token);

  if (citas.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  final ahora = DateTime.now();

  await _podarRecordatoriosVistos(prefs, ahora);

  final plugin = await _prepararCanalRecordatorio();

  if (plugin == null) return;

  for (final cita in citas) {
    final cuando = _momentoCita(cita);

    if (cuando == null) continue;

    final restante = cuando.difference(ahora);

    if (restante <= Duration.zero) continue;

    ({Duration adelanto, String etiqueta})? ventana;

    for (final opcion in _ventanasRecordatorio) {
      if (restante <= opcion.adelanto) {
        ventana = opcion;
        break;
      }
    }

    if (ventana == null) continue;

    final clave = '$_prefijoRecordatorio${cita['id']}_${ventana.etiqueta}';

    if (prefs.containsKey(clave)) continue;

    await prefs.setInt(clave, ahora.millisecondsSinceEpoch);

    await _avisarCita(plugin, cita, cuando, ventana.etiqueta == '2h');
  }
}

/// La agenda guarda fecha y hora locales de la barbería; sin zona en el texto,
/// DateTime.parse usa la zona del teléfono, que es la misma en la práctica.
DateTime? _momentoCita(Map<String, dynamic> cita) {
  final fecha = cita['fecha']?.toString();
  final hora = cita['hora']?.toString();

  if (fecha == null || hora == null || fecha.length < 10) return null;

  return DateTime.tryParse('${fecha.substring(0, 10)}T${hora.substring(0, 5)}');
}

Future<void> _podarRecordatoriosVistos(
  SharedPreferences prefs,
  DateTime ahora,
) async {
  final corte = ahora.subtract(_vidaRecordatorios).millisecondsSinceEpoch;

  final viejos = prefs
      .getKeys()
      .where((clave) => clave.startsWith(_prefijoRecordatorio))
      .where((clave) => (prefs.getInt(clave) ?? 0) < corte)
      .toList();

  for (final clave in viejos) {
    await prefs.remove(clave);
  }
}

Future<List<Map<String, dynamic>>> _pedirCitasProximas(String token) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    ),
  );

  try {
    final respuesta = await dio.get('/citas/proximas');
    final data = respuesta.data;
    final lista = data is Map ? data['data'] : null;

    if (lista is! List) return const [];

    return lista
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  } catch (_) {
    return const [];
  } finally {
    dio.close(force: true);
  }
}
