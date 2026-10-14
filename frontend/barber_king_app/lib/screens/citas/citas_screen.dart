import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/resena_service.dart';
import '../../widgets/common/gold_widgets.dart';
import '../../widgets/resenas/calificar_dialog.dart';
import 'crear_cita_screen.dart';

typedef _Mapa = Map<String, dynamic>;

/// Mis citas. Cliente: cancelar y calificar. Barbero/Admin: marcar como completada.
class CitasScreen extends StatefulWidget {
  final bool historial;

  const CitasScreen({super.key, this.historial = false});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  List<_Mapa> _citas = [];
  final Map<int, String> _barberos = {};
  int _rol = 3;
  late bool _historial = widget.historial;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _cargar() async {
    final r = await Future.wait<Object?>([
      CitaService().obtenerCitas(),
      BarberoService().obtenerBarberos(),
      AuthService().obtenerUsuario(),
    ]);
    if (!mounted) return;
    for (final b in r[1] as List) {
      final m = Map<String, dynamic>.from(b as Map);
      _barberos[int.tryParse('${m['id']}') ?? 0] = nombreBarbero(m);
    }
    setState(() {
      _citas = (r[0] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _rol = int.tryParse('${(r[2] as Map?)?['rol_id']}') ?? 3;
      _cargando = false;
    });
  }

  String _estado(_Mapa c) => '${c['estado']}'.toLowerCase();

  bool _abierta(_Mapa c) =>
      _estado(c) != 'completada' && _estado(c) != 'cancelada';

  Future<void> _ejecutar(Future<_Mapa> Function() accion, String exito) async {
    final r = await accion();
    if (!mounted) return;
    _aviso(
      r['success'] == true
          ? exito
          : '${r['message'] ?? 'No se pudo completar la acción.'}',
    );
    if (r['success'] == true) _cargar();
  }

  Future<void> _cancelar(_Mapa c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: const Text('¿Seguro que quieres cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (ok == true)
      _ejecutar(
        () => CitaService().eliminarCita(c['id'] as int),
        'Cita cancelada.',
      );
  }

  Future<void> _calificar(_Mapa c) async {
    final r = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CalificarDialog(),
    );
    if (r == null) return;
    _ejecutar(
      () => ResenaService().crear(
        citaId: c['id'] as int,
        barberoId: int.tryParse('${c['barbero_id']}') ?? 0,
        calificacion: (r['calificacion'] as num).toInt(),
        comentario: '${r['comentario'] ?? ''}',
      ),
      'Gracias por tu reseña.',
    );
  }

  Widget _boton(String texto, VoidCallback onTap) => Expanded(
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 11)),
    ),
  );

  Widget _tarjeta(_Mapa c) {
    final f = DateTime.tryParse('${c['fecha']}');
    final hora = '${c['hora']}'.length >= 5
        ? '${c['hora']}'.substring(0, 5)
        : '${c['hora']}';
    final servicio = c['servicios'] is Map
        ? (c['servicios'] as Map)['nombre']
        : 'Servicio';
    final cliente = c['usuarios'] is Map
        ? '${(c['usuarios'] as Map)['nombres']} ${(c['usuarios'] as Map)['apellidos']}'
        : 'Cliente';
    final persona = _rol == 3
        ? (_barberos[int.tryParse('${c['barbero_id']}')] ?? 'Barbero')
        : cliente;
    final estado = _estado(c);
    final color = estado == 'completada'
        ? AppColors.success
        : estado == 'cancelada'
        ? AppColors.error
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$servicio',
                  style: tituloSerif(size: 15, color: Colors.white),
                ),
              ),
              Text(
                '${c['estado']}'.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${f == null ? c['fecha'] : DateFormat('dd/MM/yyyy').format(f)} · $hora',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            persona,
            style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
          ),
          if ('${c['observaciones'] ?? ''}'.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${c['observaciones']}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          if (_rol == 3 && _abierta(c))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [_boton('CANCELAR CITA', () => _cancelar(c))],
              ),
            ),
          if (_rol == 3 && estado == 'completada')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [_boton('CALIFICAR', () => _calificar(c))]),
            ),
          if (_rol != 3 && _abierta(c))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  _boton(
                    'MARCAR COMPLETADA',
                    () => _ejecutar(
                      () => CitaService().actualizarCita(
                        id: c['id'] as int,
                        datos: {'estado': 'Completada'},
                      ),
                      'Cita completada.',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _citas.where((c) => _abierta(c) != _historial).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: Text(
                    _historial ? 'HISTORIAL' : 'MIS CITAS',
                    style: tituloSerif(size: 22),
                  ),
                ),
                if (_rol == 3)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrearCitaScreen(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('PRÓXIMAS')),
                  ButtonSegment(value: true, label: Text('HISTORIAL')),
                ],
                selected: {_historial},
                onSelectionChanged: (s) => setState(() => _historial = s.first),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: lista.isEmpty
                            ? [
                                const SizedBox(height: 60),
                                Center(
                                  child: Text(
                                    _historial
                                        ? 'Aún no tienes citas en el historial.'
                                        : 'No tienes citas próximas.',
                                    style: const TextStyle(
                                      color: AppColors.subtitle,
                                    ),
                                  ),
                                ),
                              ]
                            : lista.map(_tarjeta).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
