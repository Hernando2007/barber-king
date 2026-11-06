import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'avisos_service.dart';
import 'notificacion_segundo_plano.dart';

part 'avisos_notificacion_piezas.dart';

/// Avisos con la app abierta: notifica lo que manda el servidor.
class AvisosNotificacionService with WidgetsBindingObserver {
  AvisosNotificacionService._();

  static final AvisosNotificacionService instance =
      AvisosNotificacionService._();

  static const _intervalo = Duration(seconds: 15);

  final AvisosService _avisos = AvisosService();
  final AuthService _auth = AuthService();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<int> noLeidos = ValueNotifier<int>(0);

  Timer? _timer;
  int _usuarioId = 0;
  int _ultimoId = 0;
  int _ultimoLatido = 0;
  bool _primeraConsulta = true;
  bool _activo = false;
  bool _consultando = false;
  bool _listo = false;

  /// Marcador propio por usuario: el último id de aviso ya notificado.
  String get _clave => '${NotificacionSegundoPlano.claveUltimo}$_usuarioId';

  Future<void> iniciar() async {
    final usuario = await _auth.obtenerUsuario();
    final id = int.tryParse('${usuario?['id']}') ?? 0;

    if (id <= 0) return;

    if (_activo && id == _usuarioId) {
      await _consultar();
      return;
    }

    await detener();

    _usuarioId = id;
    _activo = true;

    await _prepararPlugin();

    final prefs = await SharedPreferences.getInstance();
    await _marcarAppAbierta(true);
    final guardado = prefs.getInt(_clave);

    _ultimoId = guardado ?? 0;
    _primeraConsulta = guardado == null;

    WidgetsBinding.instance.addObserver(this);
    _reiniciarTimer();
    await _consultar();
  }

  Future<void> detener() async {
    _timer?.cancel();
    _timer = null;

    if (_activo) {
      WidgetsBinding.instance.removeObserver(this);
    }

    _activo = false;
    _usuarioId = 0;
    _ultimoId = 0;
    _primeraConsulta = true;
    _consultando = false;
    noLeidos.value = 0;
    await _marcarAppAbierta(false);
  }

  /// El badge de la bandeja manda: ya se vieron los avisos acumulados.
  void marcarLeidos() {
    noLeidos.value = 0;
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_intervalo, (_) => _consultar());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_activo) return;

    _alCambiarCiclo(state);
  }

  Future<void> _consultar() async {
    if (!_activo || _consultando) return;

    _consultando = true;

    try {
      final usuario = await _auth.obtenerUsuario();

      if (usuario == null) {
        await detener();

        return;
      }

      await _latir();

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final guardado = prefs.getInt(_clave);

      if (guardado != null && guardado > _ultimoId) {
        _ultimoId = guardado;
        _primeraConsulta = false;
      }

      final data = await _avisos.novedades(desdeId: _ultimoId);

      if (!_activo || data == null) return;

      final esPrimera = _primeraConsulta;
      _primeraConsulta = false;

      await _avisarNuevos(data, primera: esPrimera);

      final nuevoUltimo = int.tryParse('${data['ultimo_id']}') ?? _ultimoId;

      if (nuevoUltimo != _ultimoId || esPrimera) {
        _ultimoId = nuevoUltimo;
        await prefs.setInt(_clave, _ultimoId);
      }
    } finally {
      _consultando = false;
    }
  }
}
