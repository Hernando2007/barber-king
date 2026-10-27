import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/chat_notificacion_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common/app_ui.dart';
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

  Map<String, dynamic>? _data;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _dashboard.obtenerAdmin();

    if (!mounted) return;

    setState(() {
      _data = data;
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
                  padding: const EdgeInsets.all(20),
                  children: [
                    PageHeading(
                      title: 'Hola, $nombre',
                      subtitle: 'Control total de Barber King',
                      actions: [
                        IconButton(
                          tooltip: 'Mi perfil',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.perfil),
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: _salir,
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _AdminHomeHero(resumen: _resumen, citas: _citas),
                    const SizedBox(height: 22),
                    _AdminHomeStatsGrid(resumen: _resumen),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Accesos rápidos',
                      subtitle: 'Gestiona la operación del negocio',
                    ),
                    const SizedBox(height: 14),
                    _AdminHomeAccesos(onRefresh: _cargar),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Estado de las citas',
                      subtitle: 'Resumen general',
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
                    SectionHeader(
                      title: 'Últimos usuarios',
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
                    ..._ultimosUsuarios(this),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Últimas reservas',
                      actionLabel: 'Ver agenda',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
                    ),
                    const SizedBox(height: 14),
                    ..._ultimasCitas(this),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
