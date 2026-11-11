part of '../../screens/barbero/agenda_screen.dart';

DateTime _lunesDe(DateTime fecha) => DateTime(
  fecha.year,
  fecha.month,
  fecha.day,
).subtract(Duration(days: fecha.weekday - 1));

bool _mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _minutosDe(dynamic hora) {
  final partes = '$hora'.split(':');
  final horas = int.tryParse(partes.first) ?? 0;
  final minutos = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;

  return horas * 60 + minutos;
}

String _horaTexto(int minutos) =>
    '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutos % 60).toString().padLeft(2, '0')}';

int _duracionDe(Map<String, dynamic> cita) {
  final servicio = cita['servicios'];

  return servicio is Map ? int.tryParse('${servicio['duracion']}') ?? 0 : 0;
}

bool _estaCerrada(Map<String, dynamic> cita) {
  final estado = '${cita['estado'] ?? ''}'.toLowerCase();

  return estado == 'completada' || estado == 'cancelada';
}

String _nombreCliente(Map<String, dynamic> cita) {
  final cliente = cita['usuarios'];

  if (cliente is! Map) return 'Cliente';

  return '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
}

String _capital(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

extension _AgendaLogica on _AgendaScreenState {
  Future<void> _cargar() async {
    final data = await _service.obtenerCitas();

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() {
      _citas = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> _citasDelDia(DateTime dia) {
    final citas = _citas.where((cita) {
      final fecha = AppFormat.toDate(cita['fecha']);

      return fecha != null && _mismoDia(fecha, dia);
    }).toList();

    citas.sort(
      (a, b) => _minutosDe(a['hora']).compareTo(_minutosDe(b['hora'])),
    );

    return citas;
  }

  /// Cuántas reservas vivas tiene cada día: pinta el punto bajo cada fecha.
  Map<DateTime, int> get _cargaPorDia {
    final carga = <DateTime, int>{};

    for (final cita in _citas) {
      final fecha = AppFormat.toDate(cita['fecha']);

      if (fecha == null || _estaCerrada(cita)) continue;

      final dia = DateTime(fecha.year, fecha.month, fecha.day);
      carga[dia] = (carga[dia] ?? 0) + 1;
    }

    return carga;
  }

  void _moverSemana(int semanas) {
    // ignore: invalid_use_of_protected_member
    setState(
      () => _inicioSemana = _inicioSemana.add(Duration(days: 7 * semanas)),
    );
  }

  void _irHoy() {
    final hoy = DateTime.now();

    // ignore: invalid_use_of_protected_member
    setState(() {
      _dia = DateTime(hoy.year, hoy.month, hoy.day);
      _inicioSemana = _lunesDe(hoy);
    });
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (elegida == null || !mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() {
      _dia = DateTime(elegida.year, elegida.month, elegida.day);
      _inicioSemana = _lunesDe(elegida);
    });
  }

  Future<void> _cambiarEstado(
    Map<String, dynamic> cita,
    String estado,
  ) async {
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

  /// El barbero no borra citas: las cierra como canceladas para que el cliente
  /// vea el cambio en su propia lista.
  Future<void> _cancelar(Map<String, dynamic> cita) async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Cancelar cita',
      message:
          'La cita de ${_nombreCliente(cita)} a las '
          '${AppFormat.time(cita['hora'])} quedará cancelada y el cliente '
          'lo verá en su lista.',
      confirmLabel: 'Sí, cancelar',
      destructive: true,
    );

    if (!confirmar || !mounted) return;

    await _cambiarEstado(cita, 'Cancelada');
  }

  Future<void> _verDetalle(Map<String, dynamic> cita) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _AgendaDetalle(
        cita: cita,
        onEstado: _cambiarEstado,
        onCancelar: _cancelar,
      ),
    );
  }
}