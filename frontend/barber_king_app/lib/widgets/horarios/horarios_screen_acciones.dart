part of '../../screens/horarios/horarios_screen.dart';

extension _HorariosAcciones on _HorariosScreenState {
  Future<void> _agregar([int? dia]) async {
    if (_barberoId == null) return;

    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HorarioFormSheet(
        diaInicial: dia ?? 1,
        dias: _dias,
      ),
    );

    if (guardado == true) {
      await _cargar();
      if (!mounted) return;
      showAppSnack(context, 'Horario guardado correctamente.');
    }
  }

  Future<void> _editar(Map<String, dynamic> horario) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HorarioFormSheet(
        diaInicial: int.tryParse('${horario['dia_semana']}') ?? 1,
        dias: _dias,
        horario: horario,
      ),
    );

    if (guardado == true) {
      await _cargar();
      if (!mounted) return;
      showAppSnack(context, 'Horario actualizado.');
    }
  }

  Future<void> _alternar(Map<String, dynamic> horario) async {
    final nuevo = !_activo(horario['activo']);

    try {
      await _horariosService.actualizarHorario(
        id: int.parse('${horario['id']}'),
        datos: {'activo': nuevo},
      );

      await _cargar();

      if (!mounted) return;
      showAppSnack(
        context,
        nuevo ? 'Jornada activada.' : 'Jornada desactivada.',
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, _mensaje(e), error: true);
    }
  }

  Future<void> _eliminar(Map<String, dynamic> horario) async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar horario',
      message: 'Se eliminará la jornada del '
          '${_dias[(int.tryParse('${horario['dia_semana']}') ?? 1) - 1]}. '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar) return;

    try {
      await _horariosService.eliminarHorario(
        int.parse('${horario['id']}'),
      );

      await _cargar();

      if (!mounted) return;
      showAppSnack(context, 'Horario eliminado.');
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, _mensaje(e), error: true);
    }
  }
}
