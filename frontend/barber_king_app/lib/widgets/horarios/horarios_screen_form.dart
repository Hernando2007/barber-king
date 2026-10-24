part of '../../screens/horarios/horarios_screen.dart';

class _HorarioFormSheet extends StatefulWidget {
  final int diaInicial;
  final List<String> dias;
  final Map<String, dynamic>? horario;

  const _HorarioFormSheet({
    required this.diaInicial,
    required this.dias,
    this.horario,
  });

  @override
  State<_HorarioFormSheet> createState() => _HorarioFormSheetState();
}

class _HorarioFormSheetState extends State<_HorarioFormSheet> {
  final _service = HorarioService();

  late int _dia;
  late TimeOfDay _inicio;
  late TimeOfDay _fin;
  late bool _activo;

  bool _guardando = false;
  String? _error;

  bool get _editando => widget.horario != null;

  @override
  void initState() {
    super.initState();
    _dia = widget.diaInicial;
    _inicio = _parseHora(
      widget.horario?['hora_inicio'],
      const TimeOfDay(hour: 8, minute: 0),
    );
    _fin = _parseHora(
      widget.horario?['hora_fin'],
      const TimeOfDay(hour: 18, minute: 0),
    );
    _activo = widget.horario == null
        ? true
        : (widget.horario!['activo'] == true ||
            '${widget.horario!['activo']}' == 'true');
  }

  TimeOfDay _parseHora(dynamic value, TimeOfDay fallback) {
    final parts = '${value ?? ''}'.split(':');

    if (parts.length < 2) return fallback;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return fallback;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _apiHora(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  int _minutos(TimeOfDay value) => value.hour * 60 + value.minute;

  Future<void> _seleccionarHora({
    required bool inicio,
  }) async {
    final value = await showTimePicker(
      context: context,
      initialTime: inicio ? _inicio : _fin,
      helpText: inicio ? 'HORA DE INICIO' : 'HORA DE FIN',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (value == null) return;

    setState(() {
      if (inicio) {
        _inicio = value;
      } else {
        _fin = value;
      }
    });
  }

  Future<void> _guardar() async {
    if (_minutos(_inicio) >= _minutos(_fin)) {
      setState(() {
        _error = 'La hora de inicio debe ser menor que la hora de fin.';
      });
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      if (_editando) {
        await _service.actualizarHorario(
          id: int.parse('${widget.horario!['id']}'),
          datos: {
            'dia_semana': _dia,
            'hora_inicio': _apiHora(_inicio),
            'hora_fin': _apiHora(_fin),
            'activo': _activo,
          },
        );
      } else {
        await _service.crearHorario(
          diaSemana: _dia,
          horaInicio: _apiHora(_inicio),
          horaFin: _apiHora(_fin),
          activo: _activo,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * .9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: _HorarioFormView(
              editando: _editando,
              dia: _dia,
              dias: widget.dias,
              inicio: _inicio,
              fin: _fin,
              activo: _activo,
              error: _error,
              guardando: _guardando,
              onDiaChanged: (value) => setState(() => _dia = value),
              onSeleccionarHora: _seleccionarHora,
              onActivoChanged: (value) => setState(() => _activo = value),
              onGuardar: _guardar,
              onCancelar: () => Navigator.pop(context, false),
            ),
          ),
        ),
      ),
    );
  }
}
