import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/chat_notificacion_service.dart';
import '../../services/cita_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/barbero/barbero_home_header.dart';
part '../../widgets/barbero/barbero_home_info.dart';
part '../../widgets/barbero/barbero_home_herramientas.dart';

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

  Map<String, dynamic>? _perfil;
  Map<String, dynamic>? _resumen;
  List<Map<String, dynamic>> _citasBarbero = [];
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

  Map<String, dynamic>? get _citaHoy {
    final hoy = DateTime.now();
    final citas = _citasBarbero.where((cita) {
      final fecha = AppFormat.toDate(cita['fecha']);
      final estado = '${cita['estado'] ?? ''}'.toLowerCase();
      if (fecha == null) return false;
      return fecha.year == hoy.year &&
          fecha.month == hoy.month &&
          fecha.day == hoy.day &&
          estado != 'cancelada' &&
          estado != 'completada';
    }).toList();

    if (citas.isEmpty) return null;

    citas.sort(
      (a, b) => '${a['hora']}'.compareTo('${b['hora']}'),
    );

    return citas.first;
  }

  Future<void> _ir(String ruta) async {
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
                    _BarberoHomeHeader(
                      nombre: nombre,
                      especialidad: especialidad,
                      onPerfil: () => _ir(AppRoutes.perfil),
                      onSalir: _salir,
                    ),
                    const SizedBox(height: 20),
                    _BarberoHomeHero(
                      cita: _citaHoy,
                      onVerCitas: () => _ir(AppRoutes.citas),
                    ),
                    const SizedBox(height: 20),
                    _BarberoStatsGrid(resumen: _resumen),
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
}
