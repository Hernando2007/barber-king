part of '../../screens/citas/citas_screen.dart';

extension _CitasScreenLogic on _CitasScreenState {
  Future<void> _cambiarEstado(Map<String, dynamic> cita, String estado) async {
    final respuesta = await _service.actualizarCita(
      id: int.tryParse('${cita['id']}') ?? 0,
      datos: {'estado': estado},
    );

    if (!mounted) return;

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Cita actualizada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  Future<void> _cancelar(Map<String, dynamic> cita) async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Cancelar cita',
      message:
          '¿Deseas cancelar la cita de ${AppFormat.date(cita['fecha'])} '
          'a las ${AppFormat.time(cita['hora'])}?',
      confirmLabel: 'Sí, cancelar',
      destructive: true,
    );

    if (!confirmar) return;

    final respuesta = await _service.eliminarCita(
      int.tryParse('${cita['id']}') ?? 0,
    );

    if (!mounted) return;

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Cita cancelada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  /// Reprogramar es reservar otra vez con el mismo barbero y servicio: la
  /// nueva cita nace confirmada y la anterior solo se cancela si la nueva
  /// quedó guardada y seguía vigente.
  Future<void> _reprogramar(Map<String, dynamic> cita) async {
    final barbero = cita['barberos'];
    final barberoId = barbero is Map ? int.tryParse('${barbero['id']}') : null;

    if (barberoId == null) return;

    final creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearCitaScreen(
          barberoInicial: barberoId,
          servicioInicial: int.tryParse('${cita['servicio_id']}'),
        ),
      ),
    );

    if (!mounted || creada != true) return;

    final estado = '${cita['estado'] ?? ''}'.toLowerCase();

    if (estado != 'cancelada' && estado != 'completada') {
      final respuesta = await _service.eliminarCita(
        int.tryParse('${cita['id']}') ?? 0,
      );

      if (!mounted) return;

      showAppSnack(
        context,
        respuesta['success'] == true
            ? 'Cita reprogramada: la anterior quedó cancelada.'
            : 'Nueva cita confirmada, pero la anterior no se pudo cancelar. '
                  'Cancélala desde Mis citas.',
        error: respuesta['success'] != true,
      );
    } else {
      showAppSnack(context, 'Nueva cita confirmada. ¡Te esperamos!');
    }

    await _cargar();
  }

  Future<void> _calificar(Map<String, dynamic> cita) async {
    final citaId = int.tryParse('${cita['id']}') ?? 0;
    final barbero = cita['barberos'];
    final barberoId = barbero is Map
        ? int.tryParse('${barbero['id']}') ?? 0
        : 0;

    final publicada = await mostrarHojaResena(
      context,
      nombreBarbero: _nombresBarberos[barberoId] ?? 'tu barbero',
      citaId: citaId,
      barberoId: barberoId,
    );

    if (publicada) {
      await _cargar();
    }
  }

  Future<void> _nuevaCita() async {
    final creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CrearCitaScreen()),
    );

    if (creada == true) {
      await _cargar();
    }
  }
}
