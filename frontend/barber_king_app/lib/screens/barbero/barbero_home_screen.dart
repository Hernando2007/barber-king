import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/ubicacion_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/barberos/barberos_calificacion.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/common/filtros_pildora.dart';
import '../../widgets/common/home_encabezado.dart';
import '../../widgets/common/tarjeta_cita_home.dart';
import '../../widgets/resenas/resenas_panel.dart';
import '../barberos/perfil_barbero_screen.dart';
import '../home/pestana_scope.dart';

part '../../widgets/barbero/barbero_home_header.dart';
part '../../widgets/barbero/barbero_home_info.dart';
part '../../widgets/barbero/barbero_home_herramientas.dart';
part '../../widgets/barbero/barbero_home_resenas.dart';
part '../../widgets/barbero/barbero_home_ubicacion.dart';

class BarberoHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const BarberoHomeScreen({super.key, required this.usuario});

  @override
  State<BarberoHomeScreen> createState() => _BarberoHomeScreenState();
}

class _BarberoHomeScreenState extends State<BarberoHomeScreen> {
  final UsuarioService _usuarios = UsuarioService();
  final DashboardService _dashboard = DashboardService();
  final CitaService _citas = CitaService();

  static const _filtrosBarbero = [
    'Hoy',
    'Pendientes',
    'Completadas',
    'Todas',
  ];

  Map<String, dynamic>? _perfil;
  Map<String, dynamic>? _resumen;
  List<Map<String, dynamic>> _citasBarbero = [];
  String _filtro = _filtrosBarbero.first;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final perfil = await _usuarios.obtenerPerfilActual();
    final panel = await _dashboard.obtenerBarbero();
    final citas = await _citas.obtenerCitas();

    if (!mounted) return;

    setState(() {
      _perfil = perfil;
      _resumen = panel?['resumen'] is Map
          ? Map<String, dynamic>.from(panel!['resumen'])
          : null;
      _citasBarbero = citas
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _cargando = false;
    });
  }

  String _estadoDe(Map<String, dynamic> cita) =>
      '${cita['estado'] ?? ''}'.toLowerCase();

  bool _esHoy(Map<String, dynamic> cita) {
    final hoy = DateTime.now();
    final fecha = AppFormat.toDate(cita['fecha']);

    if (fecha == null) return false;

    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

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
    bool coincide(Map<String, dynamic> cita) {
      switch (filtro) {
        case 'Hoy':
          return _esHoy(cita) && _estadoDe(cita) != 'cancelada';
        case 'Pendientes':
          return _estadoDe(cita) == 'pendiente';
        case 'Completadas':
          return _estadoDe(cita) == 'completada';
        default:
          return true;
      }
    }

    final lista = _citasBarbero.where(coincide).toList();

    lista.sort((a, b) {
      final claveA = _claveOrden(a);
      final claveB = _claveOrden(b);

      return filtro == 'Hoy' || filtro == 'Pendientes'
          ? claveA.compareTo(claveB)
          : claveB.compareTo(claveA);
    });

    return lista;
  }

  Map<String, dynamic>? get _citaHoy {
    final hoy = _filtrar('Hoy');
    return hoy.isEmpty ? null : hoy.first;
  }

  int get _citasDeHoy => _filtrar('Hoy').length;

  int get _pendientesLista => _filtrar('Pendientes').length;

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

  Future<void> _ir(String ruta) async {
    // Es una pestaña: cambiar de pestaña en lugar de apilar otra copia.
    final barra = PestanaScope.maybeOf(context);
    if (barra != null && barra.irARuta(ruta)) return;

    await Navigator.pushNamed(context, ruta);
    _cargar();
  }

  Future<void> _salir() async {
    await AuthService().cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final barbero = _perfil?['barbero'];
    final barberoMap = barbero is Map
        ? Map<String, dynamic>.from(barbero)
        : <String, dynamic>{};
    final especialidad = barberoMap['especialidad']?.toString() ?? 'Barbero';
    final nombre = widget.usuario['nombres']?.toString() ?? 'Barbero';
    final verificado = barberoMap['verificacion_estado'] == 'aprobado';
    final filtradas = _filtrar(_filtro);
    final conteos = {
      for (final filtro in _filtrosBarbero) filtro: _filtrar(filtro).length,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando tu panel...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                  children: [
                    HomeEncabezado(
                      eyebrow: 'Panel profesional',
                      nombre: nombre,
                      detalle: verificado
                          ? '$especialidad · Verificado'
                          : especialidad,
                      fotoUrl: widget.usuario['foto']?.toString(),
                      onPerfil: () => _ir(AppRoutes.perfil),
                      onSalir: _salir,
                    ),
                    const SizedBox(height: 20),
                    _BarberoHomeHero(
                      cita: _citaHoy,
                      citasHoy: _citasDeHoy,
                      pendientes: _pendientesLista,
                      onVerCitas: () => _ir(AppRoutes.agenda),
                    ),
                    const SizedBox(height: 22),
                    FilaPildorasFiltro(
                      opciones: _filtrosBarbero,
                      seleccionada: _filtro,
                      conteos: conteos,
                      onSeleccionar: (valor) =>
                          setState(() => _filtro = valor),
                    ),
                    const SizedBox(height: 16),
                    if (filtradas.isEmpty)
                      EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: _tituloVacio,
                        message: _filtro == 'Hoy'
                            ? 'Revisa tu agenda completa o comparte tu '
                                  'ubicación para recibir más reservas.'
                            : 'Prueba con otro filtro para ver tu agenda.',
                        actionLabel: _filtro == 'Todas' ? null : 'Ver todas',
                        onAction: _filtro == 'Todas'
                            ? null
                            : () => setState(() => _filtro = 'Todas'),
                      )
                    else ...[
                      SectionHeader(
                        title: _tituloLista,
                        subtitle: filtradas.length == 1
                            ? '1 cita'
                            : '${filtradas.length} citas',
                        actionLabel: 'Ver agenda',
                        onAction: () => _ir(AppRoutes.agenda),
                      ),
                      const SizedBox(height: 12),
                      ...filtradas.take(4).map(
                        (cita) => TarjetaCitaHome(
                          cita: cita,
                          titulo: _nombreCliente(cita),
                          subtitulo: _nombreServicio(cita),
                          onTap: () => _ir(AppRoutes.agenda),
                        ),
                      ),
                      if (filtradas.length > 4)
                        TextButton.icon(
                          onPressed: () => _ir(AppRoutes.agenda),
                          icon: const Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                          ),
                          label: Text('Ver las ${filtradas.length} citas'),
                        ),
                    ],
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Tu jornada',
                      subtitle: 'Ubicación y números del día a día',
                      icon: Icons.place_outlined,
                    ),
                    const SizedBox(height: 12),
                    const _BarberoUbicacionCard(),
                    const SizedBox(height: 20),
                    _BarberoStatsGrid(resumen: _resumen),
                    if (int.tryParse('${barberoMap['id']}') != null)
                      _BarberoHomeResenas(
                        barberoId: int.parse('${barberoMap['id']}'),
                        resumen: _resumen,
                      ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Herramientas',
                      subtitle: 'Gestiona tu día a día',
                    ),
                    const SizedBox(height: 14),
                    _BarberoHerramientasGrid(onAcceso: _ir),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Datos profesionales',
                      icon: Icons.workspace_premium_outlined,
                    ),
                    const SizedBox(height: 12),
                    _BarberoDatosProfesionales(barbero: barberoMap),
                  ],
                ),
              ),
      ),
    );
  }

  String get _tituloLista {
    switch (_filtro) {
      case 'Hoy':
        return 'Tu agenda de hoy';
      case 'Pendientes':
        return 'Citas pendientes';
      case 'Completadas':
        return 'Citas completadas';
      default:
        return 'Toda tu agenda';
    }
  }

  String get _tituloVacio {
    switch (_filtro) {
      case 'Hoy':
        return 'Sin citas para hoy';
      case 'Pendientes':
        return 'Sin citas pendientes';
      case 'Completadas':
        return 'Sin citas completadas';
      default:
        return 'Aún no tienes citas';
    }
  }
}
