import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../widgets/common/app_ui.dart';
import '../chat/chat_conversacion_screen.dart';
import 'crear_cita_screen.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService _service = CitaService();
  final BarberoService _barberos = BarberoService();
  final AuthService _auth = AuthService();

  List<Map<String, dynamic>> _citas = [];
  Map<int, String> _nombresBarberos = {};

  int _rol = 3;
  String _filtro = 'Todas';
  bool _cargando = true;

  bool get _esAdmin => _rol == 1;
  bool get _esBarbero => _rol == 2;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final usuario = await _auth.obtenerUsuario();
    final rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;

    final data = await _service.obtenerCitas();
    final perfiles = rol == 3 ? await _barberos.obtenerBarberos() : [];

    if (!mounted) return;

    final mapa = <int, String>{};

    for (final item in perfiles.whereType<Map>()) {
      final id = int.tryParse('${item['id']}');
      final usuarioBarbero = item['usuarios'];

      if (id == null || usuarioBarbero is! Map) continue;

      mapa[id] =
          '${usuarioBarbero['nombres'] ?? ''} '
          '${usuarioBarbero['apellidos'] ?? ''}'.trim();
    }

    setState(() {
      _rol = rol;
      _citas = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _nombresBarberos = mapa;
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'Todas') return _citas;

    return _citas.where((cita) {
      return '${cita['estado'] ?? ''}'.toLowerCase() ==
          _filtro.toLowerCase();
    }).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _esBarbero
              ? 'Agenda profesional'
              : _esAdmin
              ? 'Todas las citas'
              : 'Mis citas',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _esBarbero
          ? null
          : FloatingActionButton.extended(
              onPressed: _nuevaCita,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva cita'),
            ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando citas...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final estado in const [
                            'Todas',
                            'Pendiente',
                            'Confirmada',
                            'Completada',
                            'Cancelada',
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(estado),
                                selected: _filtro == estado,
                                onSelected: (_) =>
                                    setState(() => _filtro = estado),
                                labelStyle: TextStyle(
                                  color: _filtro == estado
                                      ? AppColors.primary
                                      : AppColors.subtitle,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filtradas.isEmpty)
                      EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: 'Sin citas',
                        message: _esBarbero
                            ? 'Aún no tienes reservas registradas.'
                            : 'No hay citas que coincidan con este filtro.',
                        actionLabel: _esBarbero ? null : 'Reservar ahora',
                        onAction: _esBarbero ? null : _nuevaCita,
                      )
                    else
                      ...filtradas.map(_citaCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _citaCard(Map<String, dynamic> cita) {
    final cliente = cita['usuarios'];
    final servicio = cita['servicios'];
    final barbero = cita['barberos'];
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final color = AppFormat.statusColor(estado);
    final barberoId = barbero is Map
        ? int.tryParse('${barbero['id']}')
        : null;

    final titulo = _esBarbero || _esAdmin
        ? cliente is Map
              ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
              : 'Cliente'
        : (_nombresBarberos[barberoId]?.isNotEmpty == true
              ? _nombresBarberos[barberoId]!
              : 'Barbero');

    final subtitulo = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';

    final puedeCancelar =
        !_esBarbero &&
        estado.toLowerCase() != 'cancelada' &&
        estado.toLowerCase() != 'completada';

    final puedeGestionar =
        (_esBarbero || _esAdmin) &&
        estado.toLowerCase() != 'cancelada' &&
        estado.toLowerCase() != 'completada';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.isEmpty ? 'Cliente' : titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(label: estado, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dato(
                  Icons.calendar_today_outlined,
                  'Fecha',
                  AppFormat.date(cita['fecha']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.schedule_rounded,
                  'Hora',
                  AppFormat.time(cita['hora']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.payments_outlined,
                  'Precio',
                  servicio is Map
                      ? AppFormat.money(servicio['precio'])
                      : '-',
                ),
              ),
            ],
          ),
          if (puedeGestionar || puedeCancelar) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_esBarbero &&
                    estado.toLowerCase() == 'pendiente')
                  OutlinedButton(
                    onPressed: () => _cambiarEstado(cita, 'Confirmada'),
                    child: const Text('Confirmar'),
                  ),
                if (_esBarbero || _esAdmin)
                  ElevatedButton(
                    onPressed: () => _cambiarEstado(cita, 'Completada'),
                    child: const Text('Completar'),
                  ),
                if (_esBarbero)
                  TextButton.icon(
                    onPressed: () => _chatCliente(cita),
                    icon: const Icon(Icons.forum_outlined, size: 17),
                    label: const Text('Chatear'),
                  ),
                if (!_esBarbero &&
                    estado.toLowerCase() != 'cancelada')
                  TextButton.icon(
                    onPressed: () => _chatBarbero(cita),
                    icon: const Icon(Icons.forum_outlined, size: 17),
                    label: const Text('Barbero'),
                  ),
                if (puedeCancelar)
                  TextButton.icon(
                    onPressed: () => _cancelar(cita),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 17,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.muted, size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
