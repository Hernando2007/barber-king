import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/horario_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/horarios/horarios_screen_acciones.dart';
part '../../widgets/horarios/horarios_screen_resumen.dart';
part '../../widgets/horarios/horarios_screen_dia_card.dart';
part '../../widgets/horarios/horarios_screen_jornada.dart';
part '../../widgets/horarios/horarios_screen_form.dart';
part '../../widgets/horarios/horarios_screen_form_view.dart';
part '../../widgets/horarios/horarios_screen_timebox.dart';

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
                    _ResumenCard(
                      diasActivos: _diasActivos,
                      jornadasActivas: _jornadasActivas,
                      onAgregar: () => _agregar(),
                    ),
                    const SizedBox(height: 22),
                    const SectionHeader(
                      title: 'Disponibilidad semanal',
                      subtitle: 'Puedes tener varias jornadas por día.',
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(7, (index) {
                      return _DiaCardView(
                        dia: index + 1,
                        nombre: _dias[index],
                        items: _delDia(index + 1),
                        onAgregar: _agregar,
                        onEditar: _editar,
                        onAlternar: _alternar,
                        onEliminar: _eliminar,
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}
