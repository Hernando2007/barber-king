import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/resena_service.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/resenas/resena_sheet.dart';
import 'crear_cita_screen.dart';

part '../../widgets/citas/citas_screen_logic.dart';
part '../../widgets/citas/citas_screen_filtros.dart';
part '../../widgets/citas/citas_screen_card.dart';
part '../../widgets/citas/citas_screen_acciones.dart';
part '../../widgets/citas/citas_screen_cliente.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService _service = CitaService();
  final BarberoService _barberos = BarberoService();
  final AuthService _auth = AuthService();
  final ResenaService _resenas = ResenaService();

  List<Map<String, dynamic>> _citas = [];
  Map<int, String> _nombresBarberos = {};
  Set<int> _citasCalificadas = {};

  int _rol = 3;
  String _filtro = '';
  bool _cargando = true;

  bool get _esAdmin => _rol == 1;
  bool get _esCliente => _rol == 3;

  static const _filtrosCliente = [
    'Próximas',
    'Completadas',
    'Canceladas',
    'Todas',
  ];

  static const _filtrosAdmin = [
    'Todas',
    'Confirmada',
    'Completada',
    'Cancelada',
  ];

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

    List<dynamic> perfiles = [];
    List<dynamic> propias = [];

    if (rol == 3) {
      final resultados = await Future.wait([
        _barberos.obtenerBarberos(),
        _resenas.obtenerMias(),
      ]);

      perfiles = resultados[0];
      propias = resultados[1];
    }

    if (!mounted) return;

    final mapa = <int, String>{};

    for (final item in perfiles.whereType<Map>()) {
      final id = int.tryParse('${item['id']}');
      final usuarioBarbero = item['usuarios'];

      if (id == null || usuarioBarbero is! Map) continue;

      mapa[id] =
          '${usuarioBarbero['nombres'] ?? ''} '
                  '${usuarioBarbero['apellidos'] ?? ''}'
              .trim();
    }

    final calificadas = <int>{};

    for (final item in propias.whereType<Map>()) {
      final citaId = int.tryParse('${item['cita_id']}');

      if (citaId != null) {
        calificadas.add(citaId);
      }
    }

    setState(() {
      _rol = rol;
      _citas = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _nombresBarberos = mapa;
      _citasCalificadas = calificadas;
      _cargando = false;

      if (_filtro.isEmpty) {
        _filtro = rol == 3 ? _filtrosCliente.first : _filtrosAdmin.first;
      }
    });
  }

  String _estadoDe(Map<String, dynamic> cita) =>
      '${cita['estado'] ?? 'Confirmada'}'.toLowerCase();

  int _claveOrden(Map<String, dynamic> cita) {
    final fecha = AppFormat.toDate(cita['fecha']) ?? DateTime(2100);
    final partes = '${cita['hora'] ?? ''}'.split(':');
    final hora = int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 0;
    final minuto = int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0;

    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora,
      minuto,
    ).millisecondsSinceEpoch;
  }

  List<Map<String, dynamic>> _filtrar(String filtro) {
    if (filtro == 'Todas') {
      return [..._citas]
        ..sort((a, b) => _claveOrden(b).compareTo(_claveOrden(a)));
    }

    if (_esCliente) {
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);

      bool coincide(Map<String, dynamic> cita) {
        final estado = _estadoDe(cita);

        switch (filtro) {
          case 'Próximas':
            final fecha = AppFormat.toDate(cita['fecha']);

            return (estado == 'confirmada' || estado == 'pendiente') &&
                fecha != null &&
                !fecha.isBefore(inicio);
          case 'Completadas':
            return estado == 'completada';
          case 'Canceladas':
            return estado == 'cancelada';
          default:
            return true;
        }
      }

      final lista = _citas.where(coincide).toList();

      lista.sort((a, b) {
        final claveA = _claveOrden(a);
        final claveB = _claveOrden(b);

        return filtro == 'Próximas'
            ? claveA.compareTo(claveB)
            : claveB.compareTo(claveA);
      });

      return lista;
    }

    return _citas
        .where((cita) => _estadoDe(cita) == filtro.toLowerCase())
        .toList()
      ..sort((a, b) => _claveOrden(b).compareTo(_claveOrden(a)));
  }

  List<Map<String, dynamic>> get _filtradas => _filtrar(_filtro);

  Map<String, dynamic>? get _proximaReserva {
    final proximas = _filtrar('Próximas');
    return proximas.isEmpty ? null : proximas.first;
  }

  String _nombreBarbero(Map<String, dynamic> cita) {
    final barbero = cita['barberos'];
    final barberoId = barbero is Map ? int.tryParse('${barbero['id']}') : null;

    return barberoId == null ? '' : _nombresBarberos[barberoId] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esAdmin ? 'Todas las citas' : 'Mis reservas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevaCita,
        icon: const Icon(Icons.add_rounded),
        label: Text(_esAdmin ? 'Nueva cita' : 'Reservar'),
      ),
      body: SafeArea(
        child: _cargando
            ? LoadingView(
                message: _esAdmin
                    ? 'Cargando citas...'
                    : 'Cargando reservas...',
              )
            : RefreshIndicator(
                onRefresh: _cargar,
                child: _esAdmin ? _listaAdmin() : _listaCliente(),
              ),
      ),
    );
  }

  Widget _listaAdmin() {
    final filtradas = _filtradas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        _CitasScreenFiltros(
          filtro: _filtro,
          estados: _filtrosAdmin,
          onSeleccionar: (estado) => setState(() => _filtro = estado),
        ),
        const SizedBox(height: 16),
        if (filtradas.isEmpty)
          const _CitasScreenEmpty(
            title: 'Sin citas',
            message: 'No hay citas que coincidan con este filtro.',
          )
        else
          ...filtradas.map(
            (cita) => _CitasScreenCard(
              cita: cita,
              esAdmin: true,
              nombresBarberos: _nombresBarberos,
              citasCalificadas: _citasCalificadas,
              onCambiarEstado: _cambiarEstado,
              onCancelar: _cancelar,
              onReprogramar: _reprogramar,
              onCalificar: _calificar,
            ),
          ),
      ],
    );
  }

  Widget _listaCliente() {
    final filtradas = _filtradas;
    final proxima = _proximaReserva;
    final conteos = {
      for (final filtro in _filtrosCliente) filtro: _filtrar(filtro).length,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        _ClienteReservasHero(
          cita: proxima,
          nombreBarbero: proxima == null ? '' : _nombreBarbero(proxima),
          onReservar: _nuevaCita,
        ),
        const SizedBox(height: 22),
        _CitasScreenFiltros(
          filtro: _filtro,
          estados: _filtrosCliente,
          conteos: conteos,
          onSeleccionar: (estado) => setState(() => _filtro = estado),
        ),
        const SizedBox(height: 18),
        if (filtradas.isEmpty)
          _CitasScreenEmpty(
            title: _citas.isEmpty
                ? 'Aún no tienes reservas'
                : 'Sin reservas en esta sección',
            message: _citas.isEmpty
                ? 'Elige a tu barbero y reserva tu primer corte. '
                      'Aquí verás el estado de cada reserva.'
                : 'Prueba con otro filtro o revisa todas tus reservas.',
            actionLabel: _citas.isEmpty ? 'Reservar ahora' : 'Ver todas',
            onAction: _citas.isEmpty
                ? _nuevaCita
                : () => setState(() => _filtro = 'Todas'),
          )
        else ...[
          SectionHeader(
            title: 'Tus reservas',
            subtitle: filtradas.length == 1
                ? '1 reserva'
                : '${filtradas.length} reservas',
          ),
          const SizedBox(height: 12),
          ...filtradas.map(
            (cita) => _ClienteReservaCard(
              cita: cita,
              nombreBarbero: _nombreBarbero(cita),
              calificada: _citasCalificadas.contains(
                int.tryParse('${cita['id']}'),
              ),
              onCancelar: _cancelar,
              onReprogramar: _reprogramar,
              onCalificar: _calificar,
            ),
          ),
        ],
      ],
    );
  }
}
