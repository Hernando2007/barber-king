part of 'notificacion_segundo_plano.dart';

/// Deja listo el canal de avisos; devuelve `null` si el usuario los bloqueó.
Future<FlutterLocalNotificationsPlugin?> _prepararCanalAviso() async {
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
      NotificacionSegundoPlano.canalAvisosId,
      'Avisos',
      description: 'Novedades de tus citas y reservas',
      importance: Importance.high,
    ),
  );

  return plugin;
}

Future<void> _avisarAviso(
  FlutterLocalNotificationsPlugin plugin,
  Map<String, dynamic> aviso,
) async {
  const detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      NotificacionSegundoPlano.canalAvisosId,
      'Avisos',
      channelDescription: 'Novedades de tus citas y reservas',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    ),
  );

  final id =
      int.tryParse('${aviso['id']}') ??
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  try {
    await plugin.show(
      id: id,
      title: aviso['titulo']?.toString() ?? 'Nuevo aviso',
      body: aviso['cuerpo']?.toString() ?? '',
      notificationDetails: detalles,
      payload: aviso['tipo']?.toString(),
    );
  } catch (_) {
    // El canal puede no existir aún en el primer ciclo tras la instalación.
  }
}
