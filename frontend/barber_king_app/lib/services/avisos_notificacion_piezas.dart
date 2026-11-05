part of 'avisos_notificacion_service.dart';

/// Canal, disparo de notificaciones y latido de "app abierta".
extension _AvisosNotificacionPiezas on AvisosNotificacionService {
  Future<void> _prepararPlugin() async {
    if (_listo) return;

    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
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

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            NotificacionSegundoPlano.canalAvisosId,
            'Avisos de solicitudes',
            description: 'Novedades de tus solicitudes y respuestas',
            importance: Importance.high,
          ),
        );

    _listo = true;
  }

  Future<void> _avisarNuevos(
    Map<String, dynamic> data, {
    required bool primera,
  }) async {
    final lista = (data['avisos'] as List? ?? [])
        .whereType<Map>()
        .map((aviso) => Map<String, dynamic>.from(aviso))
        .toList();

    if (primera || lista.isEmpty) return;

    // Sin marcador previo solo se cuenta, para no disparar el historial entero.
    final visibles = lista.length > 3 ? lista.sublist(lista.length - 3) : lista;

    for (final aviso in visibles) {
      await _mostrarAviso(aviso);
    }

    noLeidos.value += lista.length;
  }

  Future<void> _mostrarAviso(Map<String, dynamic> aviso) async {
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificacionSegundoPlano.canalAvisosId,
        'Avisos de solicitudes',
        channelDescription: 'Novedades de tus solicitudes y respuestas',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final id =
        int.tryParse('${aviso['id']}') ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    try {
      await _plugin.show(
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

  Future<void> _refrescarPendientes() async {
    solicitudesPendientes.value = await _solicitudes.pendientes();
  }

  Future<void> _marcarAppAbierta(bool abierta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificacionSegundoPlano.claveAppAbierta, abierta);

    if (abierta) {
      _ultimoLatido = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(
        NotificacionSegundoPlano.claveAppAbiertaEn,
        _ultimoLatido,
      );

      return;
    }

    // Al irse a segundo plano toma el control la revisión de WorkManager.
    await NotificacionSegundoPlano.encenderAhora();
  }

  Future<void> _latir() async {
    final ahora = DateTime.now().millisecondsSinceEpoch;

    if (ahora - _ultimoLatido < 60000) return;

    _ultimoLatido = ahora;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(NotificacionSegundoPlano.claveAppAbiertaEn, ahora);
  }

  void _alCambiarCiclo(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _marcarAppAbierta(true);
      _reiniciarTimer();
      _consultar();

      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _marcarAppAbierta(false);
    }
  }
}
