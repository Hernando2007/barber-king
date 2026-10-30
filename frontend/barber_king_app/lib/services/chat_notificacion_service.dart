import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'chat_directo_service.dart';

part 'chat_notificacion_plugin.dart';

class ChatNotificacionService with WidgetsBindingObserver {
  ChatNotificacionService._();

  static final ChatNotificacionService instance =
      ChatNotificacionService._();

  static const _canalId = 'chat_mensajes';
  static const _intervalo = Duration(seconds: 15);

  final ChatDirectoService _chat = ChatDirectoService();
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

  String get _clave => 'chat_aviso_ultimo_$_usuarioId';

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
    await prefs.setBool('chat_app_abierta', true);
    _ultimoLatido = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('chat_app_abierta_en', _ultimoLatido);
    final guardado = prefs.getInt(_clave);

    if (guardado == null) {
      _ultimoId = 0;
      _primeraConsulta = true;
    } else {
      _ultimoId = guardado;
      _primeraConsulta = false;
    }

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

  Future<void> _marcarAppAbierta(bool abierta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_app_abierta', abierta);

    if (!abierta) return;

    _ultimoLatido = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('chat_app_abierta_en', _ultimoLatido);
  }

  Future<void> _latir() async {
    final ahora = DateTime.now().millisecondsSinceEpoch;

    if (ahora - _ultimoLatido < 60000) return;

    _ultimoLatido = ahora;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chat_app_abierta_en', ahora);
  }

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

    if (state == AppLifecycleState.resumed) {
      _marcarAppAbierta(true);
      _reiniciarTimer();
      _consultar();
      return;
    }

    if (state == AppLifecycleState.paused) {
      _marcarAppAbierta(false);
    }
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

      final respuesta = await _chat.obtenerNovedades(desdeId: _ultimoId);
      if (!_activo || respuesta['success'] != true) return;

      final raw = respuesta['data'];
      if (raw is! Map) return;

      final data = Map<String, dynamic>.from(raw);
      final lista = (data['mensajes'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      final esPrimera = _primeraConsulta;
      _primeraConsulta = false;

      if (lista.isNotEmpty && !esPrimera) {
        final visibles = lista.length > 3
            ? lista.sublist(lista.length - 3)
            : lista;

        for (final mensaje in visibles) {
          await _mostrar(mensaje);
        }

        noLeidos.value += lista.length;
      }

      final nuevoUltimo =
          int.tryParse('${data['ultimo_id']}') ?? _ultimoId;

      if (nuevoUltimo != _ultimoId || esPrimera) {
        _ultimoId = nuevoUltimo;
        await prefs.setInt(_clave, _ultimoId);
      }
    } finally {
      _consultando = false;
    }
  }
}
