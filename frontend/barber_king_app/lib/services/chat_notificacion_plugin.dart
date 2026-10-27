part of 'chat_notificacion_service.dart';

extension _ChatNotificacionPlugin on ChatNotificacionService {
  Future<void> _prepararPlugin() async {
    if (_listo) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _listo = true;
  }

  Future<void> _mostrar(Map<String, dynamic> mensaje) async {
    final nombre = mensaje['emisor_nombre']?.toString() ?? 'Usuario';
    final tieneImagen =
        mensaje['imagen_url']?.toString().isNotEmpty ?? false;
    final texto = tieneImagen
        ? 'Te envió una imagen.'
        : mensaje['mensaje']?.toString() ?? 'Nuevo mensaje';

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        ChatNotificacionService._canalId,
        'Mensajes de clientes',
        channelDescription: 'Avisos de mensajes nuevos en el chat',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final id =
        int.tryParse('${mensaje['id']}') ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _plugin.show(
      id: id,
      title: 'Nuevo mensaje de $nombre',
      body: texto,
      notificationDetails: detalles,
      payload: '${mensaje['usuario_id']}',
    );
  }
}
