import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/common/filtros_pildora.dart';
import '../../widgets/common/home_encabezado.dart';
import '../../widgets/common/tarjeta_cita_home.dart';
import '../citas/crear_cita_screen.dart';
import '../home/pestana_scope.dart';

part '../../widgets/cliente/cliente_home_hero.dart';
part '../../widgets/cliente/cliente_home_encabezado.dart';
part '../../widgets/cliente/cliente_home_accesos.dart';
part '../../widgets/cliente/cliente_home_tarjetas.dart';

class ClienteHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const ClienteHomeScreen({super.key, required this.usuario});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final CitaService _citas = CitaService();
  final ServicioService _servicios = ServicioService();
  final BarberoService _barberos = BarberoService();

  static const _filtrosCliente = [
    'Próximas',
    'Completadas',
    'Canceladas',
    'Todas',
  ];

  List<Map<String, dynamic>> _citasCliente = [];
  Map<int, String> _nombresBarberos = {};
  int _totalServicios = 0;
  String _filtro = _filtrosCliente.first;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final resultados = await Future.wait([
      _citas.obtenerCitas(),
      _servicios.obtenerServicios(soloActivos: true),
      _barberos.obtenerBarberos(),
    ]);

    if (!mounted) return;

    final mapa = <int, String>{};

    for (final item in resultados[2].whereType<Map>()) {
      final id = int.tryParse('${item['id']}');
      final usuarioBarbero = item['usuarios'];

      if (id == null || usuarioBarbero is! Map) continue;

      mapa[id] =
          '${usuarioBarbero['nombres'] ?? ''} '
                  '${usuarioBarbero['apellidos'] ?? ''}'
              .trim();
    }

    setState(() {
      _citasCliente = resultados[0]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _totalServicios = resultados[1].length;
      _nombresBarberos = mapa;
      _cargando = false;
    });
  }

  Future<void> _ir(String ruta) async {
    // Si la ruta es una pestaña, cambiar de pestaña: apilarla produciría una
    // copia de esta misma pantalla encima de la barra.
    final barra = PestanaScope.maybeOf(context);
    if (barra != null && barra.irARuta(ruta)) return;

    await Navigator.pushNamed(context, ruta);
    _cargar();
  }

  Future<void> _reservar() async {
    final creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CrearCitaScreen()),
    );

    if (creada == true) await _cargar();
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

    final lista = _citasCliente.where(coincide).toList();

    lista.sort((a, b) {
      final claveA = _claveOrden(a);
      final claveB = _claveOrden(b);

      return filtro == 'Próximas'
          ? claveA.compareTo(claveB)
          : claveB.compareTo(claveA);
    });

    return lista;
  }

  Map<String, dynamic>? get _proximaCita {
    final proximas = _filtrar('Próximas');
    return proximas.isEmpty ? null : proximas.first;
  }

  String _nombreBarbero(Map<String, dynamic> cita) {
    final barbero = cita['barberos'];
    final barberoId = barbero is Map ? int.tryParse('${barbero['id']}') : null;

    return barberoId == null ? '' : _nombresBarberos[barberoId] ?? '';
  }

  int get _completadas => _citasCliente
      .where((cita) => _estadoDe(cita) == 'completada')
      .length;

  Future<void> _cerrarSesion() async {
    await AuthService().cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario['nombres']?.toString() ?? 'Cliente';
    final filtradas = _filtrar(_filtro);
    final conteos = {
      for (final filtro in _filtrosCliente) filtro: _filtrar(filtro).length,
    };
    final proxima = _proximaCita;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
            children: [
              HomeEncabezado(
                eyebrow: AppFormat.greeting(),
                nombre: nombre,
                detalle: _citasCliente.isEmpty
                    ? 'Cliente · Tu primera reserva te espera'
                    : 'Cliente · ${_citasCliente.length} '
                          '${_citasCliente.length == 1 ? 'reserva' : 'reservas'}',
                fotoUrl: widget.usuario['foto']?.toString(),
                onPerfil: () => _ir(AppRoutes.perfil),
                onSalir: _cerrarSesion,
              ),
              const SizedBox(height: 20),
              _ClienteHomeHeroCita(
                cargando: _cargando,
                cita: proxima,
                nombreBarbero: proxima == null ? '' : _nombreBarbero(proxima),
                onBuscarBarbero: () => _ir(AppRoutes.barberos),
                onVerCitas: () => _ir(AppRoutes.citas),
              ),
              const SizedBox(height: 22),
              FilaPildorasFiltro(
                opciones: _filtrosCliente,
                seleccionada: _filtro,
                conteos: conteos,
                onSeleccionar: (valor) => setState(() => _filtro = valor),
              ),
              const SizedBox(height: 16),
              if (_cargando)
                const AppCard(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filtradas.isEmpty)
                EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: _citasCliente.isEmpty
                      ? 'Aún no tienes reservas'
                      : 'Sin reservas en esta sección',
                  message: _citasCliente.isEmpty
                      ? 'Elige a tu barbero y reserva tu primer corte. '
                            'Aquí verás el estado de cada reserva.'
                      : 'Prueba con otro filtro o revisa todas tus reservas.',
                  actionLabel: _citasCliente.isEmpty
                      ? 'Reservar ahora'
                      : 'Ver todas',
                  onAction: _citasCliente.isEmpty
                      ? _reservar
                      : () => setState(() => _filtro = 'Todas'),
                )
              else ...[
                SectionHeader(
                  title: _tituloLista,
                  subtitle: filtradas.length == 1
                      ? '1 reserva'
                      : '${filtradas.length} reservas',
                  actionLabel: 'Ver todas',
                  onAction: () => _ir(AppRoutes.citas),
                ),
                const SizedBox(height: 12),
                ...filtradas.take(3).map(
                  (cita) => TarjetaCitaHome(
                    cita: cita,
                    titulo: _nombreServicio(cita),
                    subtitulo: _nombreBarbero(cita),
                    onTap: () => _ir(AppRoutes.citas),
                  ),
                ),
                if (filtradas.length > 3)
                  TextButton.icon(
                    onPressed: () => _ir(AppRoutes.citas),
                    icon: const Icon(Icons.expand_more_rounded, size: 18),
                    label: Text(
                      'Ver las ${filtradas.length} reservas',
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Tu actividad',
                subtitle: 'Un vistazo rápido a tu cuenta',
                icon: Icons.insights_outlined,
              ),
              const SizedBox(height: 12),
              _ClienteHomeStats(
                totalCitas: _citasCliente.length,
                completadas: _completadas,
                totalServicios: _totalServicios,
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                title: '¿Qué necesitas hoy?',
                subtitle: 'Todo a un toque de distancia',
              ),
              const SizedBox(height: 14),
              _ClienteHomeAccesos(onIr: _ir),
              const SizedBox(height: 22),
              _ClienteHomePromoIA(onAbrir: () => _ir(AppRoutes.chatIA)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reservar,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Reservar'),
      ),
    );
  }

  String get _tituloLista {
    switch (_filtro) {
      case 'Próximas':
        return 'Tus próximas reservas';
      case 'Completadas':
        return 'Reservas completadas';
      case 'Canceladas':
        return 'Reservas canceladas';
      default:
        return 'Todas tus reservas';
    }
  }

  String _nombreServicio(Map<String, dynamic> cita) {
    final servicio = cita['servicios'];

    return servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';
  }
}
