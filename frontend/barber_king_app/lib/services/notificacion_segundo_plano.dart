import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../core/config/api_config.dart';

part 'notificacion_segundo_plano_aviso.dart';

class NotificacionSegundoPlano {
  NotificacionSegundoPlano._();

  static const String claveUltimo = 'chat_aviso_ultimo_';
  static const String _nombreTarea = 'barber-king-chat';
  static const String _tarea = 'barberKingChatSegundoPlano';
  static const String _canalId = 'chat_mensajes';

  static Future<void> iniciar() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await Workmanager().initialize(notificacionSegundoPlanoDispatcher);
      await Workmanager().registerPeriodicTask(
        _nombreTarea,
        _tarea,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {
      // Si el sistema no permite programarla, queda el aviso en primer plano.
    }
  }

  static Future<void> detener() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await Workmanager().cancelByUniqueName(_nombreTarea);
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
void notificacionSegundoPlanoDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    try {
      await _revisarChat();
    } catch (_) {}

    return true;
  });
}

Future<void> _revisarChat() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final crudo = await storage.read(key: 'usuario');

  if (token == null || token.isEmpty || crudo == null) return;

  final decodificado = jsonDecode(crudo);
  final usuarioId = decodificado is Map
      ? int.tryParse('${decodificado['id']}') ?? 0
      : 0;

  if (usuarioId <= 0) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  final clave = '${NotificacionSegundoPlano.claveUltimo}$usuarioId';
  final ultimo = prefs.getInt(clave) ?? 0;
  final abiertaHasta = prefs.getInt('chat_app_abierta_en') ?? 0;
  final appAbierta =
      (prefs.getBool('chat_app_abierta') ?? false) &&
      DateTime.now().millisecondsSinceEpoch - abiertaHasta < 180000;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ),
  );

  final respuesta = await dio.get(
    '/chat/directo/novedades',
    queryParameters: {'desde_id': ultimo},
  );

  final data = respuesta.data is Map ? respuesta.data['data'] : null;

  if (data is! Map) return;

  final mensajes = (data['mensajes'] as List? ?? [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();

  final nuevo = int.tryParse('${data['ultimo_id']}') ?? ultimo;

  if (mensajes.isNotEmpty && !appAbierta && ultimo > 0) {
    final plugin = FlutterLocalNotificationsPlugin();

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final visibles = mensajes.length > 3
        ? mensajes.sublist(mensajes.length - 3)
        : mensajes;

    for (final mensaje in visibles) {
      await _avisarChat(plugin, mensaje);
    }
  }

  if (nuevo != ultimo) {
    await prefs.setInt(clave, nuevo);
  }
}
