part of 'notificacion_segundo_plano.dart';

/// Arma el canal de recordatorios y deja el plugin listo para mostrar.
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
