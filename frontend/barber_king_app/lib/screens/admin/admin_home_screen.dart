import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_revision_service.dart';
import '../../services/auth_service.dart';
import '../../services/cita_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/common/filtros_pildora.dart';
import '../../widgets/common/home_encabezado.dart';
import '../../widgets/common/tarjeta_cita_home.dart';
import 'admin_revision_screen.dart';
import 'admin_usuarios_screen.dart';

part '../../widgets/admin/admin_home_hero.dart';
part '../../widgets/admin/admin_home_stats.dart';
part '../../widgets/admin/admin_home_accesos.dart';
part '../../widgets/admin/admin_home_estado_citas.dart';
part '../../widgets/admin/admin_home_tiles.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AdminHomeScreen({super.key, required this.usuario});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final DashboardService _dashboard = DashboardService();
  final AuthService _auth = AuthService();
  final AdminRevisionService _revision = AdminRevisionService();
  final CitaService _citasService = CitaService();

  static const _filtrosAdmin = [
    'Todas',
    'Confirmada',
    'Completada',
    'Cancelada',
  ];

  Map<String, dynamic>? _data;
  List<Map<String, dynamic>> _citasLista = [];
  int _revisionPendiente = 0;
  String _filtro = _filtrosAdmin.first;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _dashboard.obtenerAdmin();
    final pendientes = await _revision.pendientes();
    final citas = await _citasService.obtenerCitas();

    if (!mounted) return;

    setState(() {
      _data = data;
      _revisionPendiente = pendientes?.length ?? 0;
      _citasLista = citas
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _cargando = false;
    });
  }

  Future<void> _salir() async {
    await _auth.cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Map<String, dynamic> get _resumen {
    final value = _data?['resumen'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  Map<String, dynamic> get _citas {
    final value = _data?['citas'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
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
      return [..._citasLista]
        ..sort((a, b) => _claveOrden(b).compareTo(_claveOrden(a)));
    }

    return _citasLista
        .where((cita) => _estadoDe(cita) == filtro.toLowerCase())
        .toList()
      ..sort((a, b) => _claveOrden(b).compareTo(_claveOrden(a)));
  }

  int get _citasDeHoy {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);

    return _citasLista.where((cita) {
      final fecha = AppFormat.toDate(cita['fecha']);
      final estado = _estadoDe(cita);

      if (fecha == null || estado == 'cancelada') return false;

      return fecha.year == inicio.year &&
          fecha.month == inicio.month &&
          fecha.day == inicio.day;
    }).length;
  }

  int get _pendientesLista =>
      _citasLista.where((cita) => _estadoDe(cita) == 'pendiente').length;

  String _nombreCliente(Map<String, dynamic> cita) {
    final cliente = cita['usuarios'];

    if (cliente is! Map) return 'Cliente';

    final nombre =
        '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();

    return nombre.isEmpty ? 'Cliente' : nombre;
  }

  String _nombreServicio(Map<String, dynamic> cita) {
    final servicio = cita['servicios'];

    return servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';
  }

  Future<void> _abrirCitas() async {
    await Navigator.pushNamed(context, AppRoutes.citas);
    _cargar();
  }

  Future<void> _abrirUsuarios() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUsuariosScreen()),
    );
    _cargar();
  }

  Future<void> _abrirRevision() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminRevisionScreen()),
    );
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario['nombres']?.toString() ?? 'Administrador';
    final fecha = AppFormat.dateLong(DateTime.now());
    final filtradas = _filtrar(_filtro);
    final conteos = {
      for (final filtro in _filtrosAdmin) filtro: _filtrar(filtro).length,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando panel administrativo...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  children: [
                    HomeEncabezado(
                      eyebrow: 'Panel de control',
                      nombre: nombre,
                      detalle:
                          '${fecha[0].toUpperCase()}${fecha.substring(1)} · '
                          'Administrador',
                      fotoUrl: widget.usuario['foto']?.toString(),
                      onPerfil: () =>
                          Navigator.pushNamed(context, AppRoutes.perfil),
                      onSalir: _salir,
                    ),
                    const SizedBox(height: 20),
                    _AdminHomeHero(
                      citasHoy: _citasDeHoy,
                      pendientes: _pendientesLista,
                      total: _citasLista.length,
                      onVerAgenda: _abrirCitas,
                    ),
                    const SizedBox(height: 22),
                    FilaPildorasFiltro(
                      opciones: _filtrosAdmin,
                      seleccionada: _filtro,
                      conteos: conteos,
                      onSeleccionar: (valor) =>
                          setState(() => _filtro = valor),
                    ),
                    const SizedBox(height: 16),
                    if (filtradas.isEmpty)
                      const EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: 'Sin citas en esta sección',
                        message: 'Prueba con otro estado o revisa todas '
                            'las citas de la agenda.',
                      )
                    else ...[
                      SectionHeader(
                        title: 'Citas recientes',
                        subtitle: filtradas.length == 1
                            ? '1 cita'
                            : '${filtradas.length} citas',
                        actionLabel: 'Ver todas',
                        onAction: _abrirCitas,
                      ),
                      const SizedBox(height: 12),
                      ...filtradas.take(4).map(
                        (cita) => TarjetaCitaHome(
                          cita: cita,
                          titulo: _nombreCliente(cita),
                          subtitulo: _nombreServicio(cita),
                          onTap: _abrirCitas,
                        ),
                      ),
                      if (filtradas.length > 4)
                        TextButton.icon(
                          onPressed: _abrirCitas,
                          icon: const Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                          ),
                          label: Text('Ver las ${filtradas.length} citas'),
                        ),
                    ],
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Resumen general',
                      subtitle: 'Los números del negocio',
                      icon: Icons.insights_outlined,
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeKpis(
                      resumen: _resumen,
                      citas: _citas,
                      onUsuarios: _abrirUsuarios,
                      onBarberos: () =>
                          Navigator.pushNamed(context, AppRoutes.barberos),
                      onServicios: () =>
                          Navigator.pushNamed(context, AppRoutes.servicios),
                      onCitas: _abrirCitas,
                    ),
                    const SizedBox(height: 16),
                    _AdminHomeVerificacion(
                      pendientes: _revisionPendiente,
                      onRevisar: _abrirRevision,
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Operación de citas',
                      subtitle: 'Distribución por estado',
                      actionLabel: 'Ver todas',
                      onAction: _abrirCitas,
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeEstadoCitas(
                      citas: _citas,
                      totalCitas: _resumen['totalCitas'],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Gestión del negocio',
                      subtitle: 'Todo lo que administras en un solo lugar',
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeAccesos(
                      onRefresh: _cargar,
                      revisionPendiente: _revisionPendiente,
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Últimos usuarios',
                      subtitle: 'Altas recientes en la plataforma',
                      actionLabel: 'Gestionar',
                      onAction: _abrirUsuarios,
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeUltimosUsuarios(data: _data),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
