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

Future<void> _avisarCita(
  FlutterLocalNotificationsPlugin plugin,
  Map<String, dynamic> cita,
  DateTime cuando,
  bool esInminente,
) async {
  final esBarbero = cita['para']?.toString() == 'barbero';
  final contraparte = '${cita['contraparte'] ?? ''}'.trim();
  final servicio = '${cita['servicio'] ?? ''}'.trim();
  final cuandoTexto = _cuandoRelativo(cuando, DateTime.now());
  final horaTexto =
      '${cuando.hour.toString().padLeft(2, '0')}:'
      '${cuando.minute.toString().padLeft(2, '0')}';
  final sufijo = servicio.isEmpty ? '' : ' · $servicio';

  final titulo = esBarbero
      ? (esInminente
            ? 'Llega un cliente en menos de 2 horas'
            : 'Recordatorio de tu agenda')
      : (esInminente
            ? 'Tu cita es en menos de 2 horas'
            : 'Recordatorio de tu cita');

  final cuerpo = esBarbero
      ? '$cuandoTexto a las $horaTexto'
            '${contraparte.isEmpty ? '' : ' · $contraparte'}$sufijo'
      : '$cuandoTexto a las $horaTexto'
            '${contraparte.isEmpty ? '' : ' con $contraparte'}$sufijo';

  final detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      NotificacionSegundoPlano.canalRecordatorioId,
      'Recordatorios de citas',
      channelDescription: 'Avisos antes de cada cita agendada',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    ),
  );

  final id =
      ((int.tryParse('${cita['id']}') ?? 0) % 100000) * 10 +
      (esInminente ? 1 : 2);

  try {
    await plugin.show(
      id: id,
      title: titulo,
      body: cuerpo,
      notificationDetails: detalles,
    );
  } catch (_) {
    // El canal puede faltar en el primer ciclo tras la instalación.
  }
}

String _cuandoRelativo(DateTime cuando, DateTime ahora) {
  final dia = DateTime(cuando.year, cuando.month, cuando.day);
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final dias = dia.difference(hoy).inDays;

  if (dias <= 0) return 'hoy';
  if (dias == 1) return 'mañana';

  return AppFormat.dateLong(dia);
}

Future<FlutterLocalNotificationsPlugin?> _prepararCanalRecordatorio() async {
  final plugin = FlutterLocalNotificationsPlugin();

  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  final android = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  if (android == null) return null;

  if (!(await android.areNotificationsEnabled() ?? false)) {
    return null;
  }

  await android.createNotificationChannel(
    const AndroidNotificationChannel(
      NotificacionSegundoPlano.canalRecordatorioId,
      'Recordatorios de citas',
      description: 'Avisos antes de cada cita agendada',
      importance: Importance.high,
    ),
  );

  return plugin;
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
