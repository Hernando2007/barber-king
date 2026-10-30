part of 'notificacion_segundo_plano.dart';

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
      NotificacionSegundoPlano._canalId,
      'Mensajes de clientes',
      channelDescription: 'Avisos de mensajes nuevos en el chat',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  final id =
      int.tryParse('${mensaje['id']}') ??
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  await plugin.show(
    id: id,
    title: 'Nuevo mensaje de $nombre',
    body: texto,
    notificationDetails: detalles,
    payload: '${mensaje['usuario_id']}',
  );
}
