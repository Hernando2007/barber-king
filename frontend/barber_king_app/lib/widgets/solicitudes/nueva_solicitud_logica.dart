// ignore_for_file: invalid_use_of_protected_member

part of 'nueva_solicitud_sheet.dart';

/// Carga del catálogo, selección de opciones y envío, aparte para que la
/// hoja siga siendo legible.
extension _NuevaSolicitudHoja on _NuevaSolicitudSheetState {
  Future<void> _cargar() async {
    final motivos = await _solicitudes.motivos();
    final servicios = await _servicios.obtenerDeBarbero(widget.barberoId);

    if (!mounted) return;

    setState(() {
      _motivos = motivos ?? [];
      _serviciosBarbero = servicios;
      _elegido =
          widget.motivoInicial ??
          (_motivos.isEmpty ? null : _motivos[0]['clave']?.toString());
      _cargando = false;
    });
  }

  Map<String, dynamic>? get _motivoActual {
    for (final motivo in _motivos) {
      if (motivo['clave']?.toString() == _elegido) {
        return motivo;
      }
    }

    return null;
  }

  void _seleccionar(String clave) {
    setState(() => _elegido = clave);
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final propuesta = _fecha ?? hoy;
    final seleccion = await showDatePicker(
      context: context,
      initialDate: propuesta.isAfter(hoy) ? propuesta : hoy,
      firstDate: hoy.subtract(const Duration(days: 1)),
      lastDate: hoy.add(const Duration(days: 90)),
      helpText: '¿Para cuándo?',
    );

    if (seleccion == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
      helpText: '¿A qué hora?',
    );

    if (!mounted) return;

    setState(() {
      _fecha = DateTime(
        seleccion.year,
        seleccion.month,
        seleccion.day,
        hora?.hour ?? 10,
        hora?.minute ?? 0,
      );
    });
  }

  Future<void> _enviar() async {
    final motivo = _elegido;

    if (motivo == null) {
      showAppSnack(context, 'Elige un motivo antes de enviar.', error: true);

      return;
    }

    setState(() => _enviando = true);

    final respuesta = await _solicitudes.crear(
      barberoId: widget.barberoId,
      motivo: motivo,
      citaId: widget.citaId,
      servicioId: _servicioId,
      fecha: _fecha,
      nota: _nota.text,
    );

    if (!mounted) return;

    if (respuesta['success'] != true) {
      setState(() => _enviando = false);
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo enviar.',
        error: true,
      );

      return;
    }

    Navigator.pop(context, respuesta);
  }
}
