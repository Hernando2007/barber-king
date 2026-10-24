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

  Future<void> _chatCliente(Map<String, dynamic> cita) async {
    final cliente = cita['usuarios'];

    if (cliente is! Map) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversacionScreen(
          contacto: {
            'usuario_id': cliente['id'],
            'nombres': cliente['nombres'],
            'apellidos': cliente['apellidos'],
            'rol_id': 3,
          },
        ),
      ),
    );
  }

  Future<void> _chatBarbero(Map<String, dynamic> cita) async {
    final barbero = cita['barberos'];

    if (barbero is! Map) return;

    final barberoId = int.tryParse('${barbero['id']}');
    final usuarioId = int.tryParse('${barbero['usuario_id']}');

    if (usuarioId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversacionScreen(
          contacto: {
            'usuario_id': usuarioId,
            'nombres': _nombresBarberos[barberoId] ?? 'Barbero',
            'rol_id': 2,
            'especialidad': barbero['especialidad'],
          },
        ),
      ),
    );
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
