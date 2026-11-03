part of 'chat_notificacion_service.dart';

/// Marca si la app está visible; el proceso de fondo lo lee para no duplicar.
extension ChatNotificacionEstado on ChatNotificacionService {
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
