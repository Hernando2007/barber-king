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
import '../core/formatters.dart';

part 'notificacion_segundo_plano_aviso.dart';
part 'notificacion_segundo_plano_citas.dart';
part 'notificacion_segundo_plano_recordatorio.dart';
part 'notificacion_segundo_plano_revisa.dart';

/// Revisa los avisos del servidor aunque la app esté cerrada y avisa con una
/// notificación local.
class NotificacionSegundoPlano {
  NotificacionSegundoPlano._();

  static const String claveUltimo = 'aviso_ultimo_';
  static const String claveToken = 'sesion_token';
  static const String claveUsuarioId = 'sesion_usuario_id';
  static const String claveAppAbierta = 'chat_app_abierta';
  static const String claveAppAbiertaEn = 'chat_app_abierta_en';
  static const String canalId = 'chat_mensajes';
  static const String canalAvisosId = 'avisos_solicitudes';
  static const String canalRecordatorioId = 'citas_recordatorios';

  static const String _nombrePeriodico = 'barber-king-chat';
  static const String _nombreCadena = 'barber-king-chat-cadena';
  static const String _tarea = 'barberKingChatSegundoPlano';

  /// Revisa los avisos apenas se guarda la sesión y deja programada la cadena.
  static Future<void> iniciar() async {
    if (!_esAndroid()) return;

    try {
      await Workmanager().initialize(notificacionSegundoPlanoDispatcher);
    } catch (_) {}

    try {
      await Workmanager().registerPeriodicTask(
        _nombrePeriodico,
        _tarea,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 20),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {}

    await encolar(const Duration(seconds: 10));
  }

  /// Se llama al pasar la app a segundo plano: fuerza una revisión inmediata.
  static Future<void> encenderAhora() async {
    if (!_esAndroid()) return;

    final prefs = await SharedPreferences.getInstance();

    if ((prefs.getString(claveToken) ?? '').isEmpty) return;

    await encolar(const Duration(seconds: 5));
  }

  static Future<void> detener() async {
    if (!_esAndroid()) return;

    try {
      await Workmanager().cancelByUniqueName(_nombrePeriodico);
      await Workmanager().cancelByUniqueName(_nombreCadena);
    } catch (_) {}
  }

  /// Programa la siguiente revisión; al encadenarse repite el ciclo cada minuto.
  static Future<void> encolar(Duration retardo) async {
    if (!_esAndroid()) return;

    try {
      await Workmanager().registerOneOffTask(
        _nombreCadena,
        _tarea,
        initialDelay: retardo,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (_) {}
  }

  static bool _esAndroid() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

@pragma('vm:entry-point')
void notificacionSegundoPlanoDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    await _revisarAvisos();
    await _avisarCitasCercanas();

    return true;
  });
}
