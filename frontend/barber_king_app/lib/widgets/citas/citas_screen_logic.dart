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

  /// Proponer otra hora sin escribir: manda una solicitud 'reprogramar' con
  /// la cita ya puesta.
  Future<void> _reprogramar(Map<String, dynamic> cita) async {
    final barbero = cita['barberos'];

    if (barbero is! Map) return;

    final barberoId = int.tryParse('${barbero['id']}');

    if (barberoId == null) return;

    final enviada = await NuevaSolicitudSheet.mostrar(
      context,
      barberoId: barberoId,
      barberoNombre: _nombresBarberos[barberoId] ?? 'tu barbero',
      citaId: int.tryParse('${cita['id']}'),
      motivoInicial: 'reprogramar',
    );

    if (!mounted) return;

    if (enviada?['success'] == true) {
      showAppSnack(
        context,
        'Propuesta enviada. La cita sigue en pie hasta que responda.',
      );
    }
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
