import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_revision_service.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common/app_ui.dart';
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

  Map<String, dynamic>? _data;
  int _revisionPendiente = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _dashboard.obtenerAdmin();
    final pendientes = await _revision.pendientes();

    if (!mounted) return;

    setState(() {
      _data = data;
      _revisionPendiente = pendientes?.length ?? 0;
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

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario['nombres']?.toString() ?? 'Administrador';

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
                    _AdminHomeCabecera(
                      nombre: nombre,
                      onPerfil: () =>
                          Navigator.pushNamed(context, AppRoutes.perfil),
                      onSalir: _salir,
                    ),
                    const SizedBox(height: 20),
                    _AdminHomeKpis(
                      resumen: _resumen,
                      citas: _citas,
                      onUsuarios: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUsuariosScreen(),
                          ),
                        );
                        _cargar();
                      },
                      onBarberos: () =>
                          Navigator.pushNamed(context, AppRoutes.barberos),
                      onServicios: () =>
                          Navigator.pushNamed(context, AppRoutes.servicios),
                      onCitas: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
                    ),
                    const SizedBox(height: 16),
                    _AdminHomeVerificacion(
                      pendientes: _revisionPendiente,
                      onRevisar: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminRevisionScreen(),
                          ),
                        );
                        _cargar();
                      },
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Operación de citas',
                      subtitle: 'Distribución por estado',
                      actionLabel: 'Ver todas',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
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
                      onAction: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUsuariosScreen(),
                          ),
                        );
                        _cargar();
                      },
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeUltimosUsuarios(data: _data),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Últimas reservas',
                      subtitle: 'Movimiento reciente de la agenda',
                      actionLabel: 'Ver agenda',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeUltimasCitas(data: _data),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
