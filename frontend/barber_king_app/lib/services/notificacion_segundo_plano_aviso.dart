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
      NotificacionSegundoPlano.canalId,
      'Mensajes de clientes',
      description: 'Avisos de mensajes nuevos en el chat',
      importance: Importance.high,
    ),
  );

  return plugin;
}

Future<void> _avisarChat(
  FlutterLocalNotificationsPlugin plugin,
  Map<String, dynamic> mensaje,
) async {
  final nombre = mensaje['emisor_nombre']?.toString() ?? 'Usuario';
  final tieneImagen =
      mensaje['imagen_url']?.toString().isNotEmpty ?? false;
  final texto = tieneImagen
      ? 'Te envió una imagen.'
      : mensaje['mensaje']?.toString() ?? 'Nuevo mensaje';

  const detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      NotificacionSegundoPlano.canalId,
      'Mensajes de clientes',
      channelDescription: 'Avisos de mensajes nuevos en el chat',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    ),
  );

  final id =
      int.tryParse('${mensaje['id']}') ??
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  try {
    await plugin.show(
      id: id,
      title: 'Nuevo mensaje de $nombre',
      body: texto,
      notificationDetails: detalles,
      payload: '${mensaje['usuario_id']}',
    );
  } catch (_) {
    // El canal puede no existir aún en el primer ciclo tras la instalación.
  }
}
