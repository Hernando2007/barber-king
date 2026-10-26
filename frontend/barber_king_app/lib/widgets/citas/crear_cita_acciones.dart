part of '../../screens/citas/crear_cita_screen.dart';

extension _CrearCitaAcciones on _CrearCitaScreenState {
  Future<void> _consultarDisponibilidad() async {
    final servicioId = _servicioId;
    final barberoId = _barberoId;

    if (servicioId == null || barberoId == null) {
      // ignore: invalid_use_of_protected_member
      setState(() {
        _horarios = [];
        _hora = null;
      });
      return;
    }

    // ignore: invalid_use_of_protected_member
    setState(() {
      _consultando = true;
      _hora = null;
    });

    final data = await _disponibilidad.consultarDisponibilidad(
      barberoId: barberoId,
      servicioId: servicioId,
      fecha: _fechaIso,
    );

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() {
      _horarios = data
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
      _consultando = false;
    });
  }

  Future<void> _elegirFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (value == null) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _fecha = value);
    await _consultarDisponibilidad();
  }

  Future<void> _reservar() async {
    if (_servicioId == null || _barberoId == null) {
      showAppSnack(context, 'Selecciona servicio y barbero.', error: true);
      return;
    }

    if (_hora == null) {
      showAppSnack(context, 'Selecciona un horario disponible.', error: true);
      return;
    }

    // ignore: invalid_use_of_protected_member
    setState(() => _creando = true);

    final respuesta = await _citas.crearCita(
      barberoId: _barberoId!,
      servicioId: _servicioId!,
      fecha: _fechaIso,
      hora: _hora!,
    );

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _creando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Reserva procesada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }
}
