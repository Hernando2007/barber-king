import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/horario_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final _usuarios = UsuarioService();
  final _horariosService = HorarioService();

  final _dias = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  List<Map<String, dynamic>> _horarios = [];
  int? _barberoId;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!_cargando && mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final perfil = await _usuarios.obtenerPerfilActual();
      final barbero = perfil?['barbero'];
      final id = barbero is Map ? barbero['id'] : null;

      if (id == null) {
        if (!mounted) return;
        setState(() {
          _cargando = false;
          _error = 'No encontramos tu perfil de barbero. '
              'Actualiza tus datos desde Mi perfil.';
        });
        return;
      }

      final data = await _horariosService.obtenerHorarios(
        int.parse(id.toString()),
      );

      if (!mounted) return;

      setState(() {
        _barberoId = int.parse(id.toString());
        _horarios = data;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = _mensaje(e);
      });
    }
  }

  List<Map<String, dynamic>> _delDia(int dia) {
    return _horarios
        .where((item) => int.tryParse('${item['dia_semana']}') == dia)
        .toList()
      ..sort((a, b) => '${a['hora_inicio']}'.compareTo('${b['hora_inicio']}'));
  }

  bool _activo(dynamic value) {
    return value == true || value == 1 || '$value' == 'true';
  }

  int get _diasActivos {
    final dias = <int>{};

    for (final item in _horarios) {
      if (!_activo(item['activo'])) continue;
      final dia = int.tryParse('${item['dia_semana']}');
      if (dia != null) dias.add(dia);
    }

    return dias.length;
  }

  int get _jornadasActivas {
    return _horarios.where((item) => _activo(item['activo'])).length;
  }

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

  String _mensaje(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis horarios'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: _barberoId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _agregar(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.black,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar jornada'),
            ),
      body: _cargando
          ? const LoadingView(message: 'Cargando tus horarios...')
          : RefreshIndicator(
              onRefresh: _cargar,
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                children: [
                  PageHeading(
                    title: 'Tu semana de trabajo',
                    subtitle: 'Define los días y horas en que tus clientes '
                        'pueden reservar.',
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    EmptyState(
                      icon: Icons.schedule_rounded,
                      title: 'No pudimos cargar tus horarios',
                      message: _error!,
                      actionLabel: 'Reintentar',
                      onAction: _cargar,
                    ),
                  ] else ...[
                    _resumen(),
                    const SizedBox(height: 22),
                    const SectionHeader(
                      title: 'Disponibilidad semanal',
                      subtitle: 'Puedes tener varias jornadas por día.',
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(7, (index) {
                      return _diaCard(index + 1);
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _resumen() {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .16),
          AppColors.card,
        ],
      ),
      borderColor: AppColors.primary.withValues(alpha: .26),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jornadasActivas == 0
                      ? 'Sin jornadas activas'
                      : '$_diasActivos ${_diasActivos == 1 ? 'día activo' : 'días activos'}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _jornadasActivas == 0
                      ? 'Agrega tu primera jornada para recibir reservas.'
                      : '$_jornadasActivas '
                          '${_jornadasActivas == 1 ? 'jornada configurada' : 'jornadas configuradas'}',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _agregar(),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
            tooltip: 'Nueva jornada',
          ),
        ],
      ),
    );
  }

  Widget _diaCard(int dia) {
    final items = _delDia(dia);
    final esHoy = DateTime.now().weekday == dia;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      radius: 17,
      borderColor: esHoy
          ? AppColors.primary.withValues(alpha: .34)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: esHoy
                      ? AppColors.primary.withValues(alpha: .16)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${dia}',
                  style: TextStyle(
                    color: esHoy ? AppColors.primary : AppColors.subtitle,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _dias[dia - 1],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    if (esHoy) ...[
                      const SizedBox(width: 8),
                      const StatusPill(
                        label: 'Hoy',
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _agregar(dia),
                icon: const Icon(Icons.add_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Agregar jornada',
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 47, top: 2, bottom: 4),
              child: Text(
                'Día libre',
                style: TextStyle(
                  color: AppColors.muted.withValues(alpha: .9),
                  fontSize: 12,
                ),
              ),
            )
          else
            ...items.map(_jornadaRow),
        ],
      ),
    );
  }

  Widget _jornadaRow(Map<String, dynamic> item) {
    final activo = _activo(item['activo']);

    return Padding(
      padding: const EdgeInsets.only(left: 47, top: 6, bottom: 2),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: activo ? AppColors.primary : AppColors.muted,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_hora(item['hora_inicio'])} - ${_hora(item['hora_fin'])}',
                  style: TextStyle(
                    color: activo ? AppColors.white : AppColors.subtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StatusPill(
                  label: activo ? 'Activo' : 'Inactivo',
                  color: activo ? AppColors.success : AppColors.muted,
                  icon: activo
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.subtitle,
              size: 19,
            ),
            color: AppColors.card,
            tooltip: 'Opciones',
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  _editar(item);
                  break;
                case 'estado':
                  _alternar(item);
                  break;
                case 'eliminar':
                  _eliminar(item);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'estado',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    activo
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  title: Text(
                    activo ? 'Desactivar' : 'Activar',
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 19,
                  ),
                  title: Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hora(dynamic value) {
    final parts = '${value ?? ''}'.split(':');

    if (parts.length < 2) return '--:--';

    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editando ? 'Editar jornada' : 'Nueva jornada',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Elige el día y el rango de atención.',
                            style: TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                DropdownButtonFormField<int>(
                  initialValue: _dia,
                  dropdownColor: AppColors.card,
                  decoration: const InputDecoration(
                    labelText: 'Día de trabajo',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  items: List.generate(widget.dias.length, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(widget.dias[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _dia = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _timeBox(
                        label: 'Hora de inicio',
                        value: _inicio,
                        onTap: () => _seleccionarHora(inicio: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _timeBox(
                        label: 'Hora de fin',
                        value: _fin,
                        onTap: () => _seleccionarHora(inicio: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _activo,
                    onChanged: (value) => setState(() => _activo = value),
                    title: const Text(
                      'Jornada activa',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Los clientes solo pueden reservar en jornadas activas.',
                      style: TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11,
                      ),
                    ),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryGradientButton(
                  label: _editando ? 'Guardar cambios' : 'Crear jornada',
                  icon: Icons.check_rounded,
                  loading: _guardando,
                  onPressed: _guardar,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _guardando
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeBox({
    required String label,
    required TimeOfDay value,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      radius: 15,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                value.format(context),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
