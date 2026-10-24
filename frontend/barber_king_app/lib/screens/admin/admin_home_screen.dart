import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common/app_ui.dart';
import 'admin_usuarios_screen.dart';

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
                    _heroCard(),
                    const SizedBox(height: 22),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        StatTile(
                          icon: Icons.people_alt_outlined,
                          label: 'Usuarios',
                          value: '${_resumen['totalUsuarios'] ?? 0}',
                        ),
                        StatTile(
                          icon: Icons.content_cut_outlined,
                          label: 'Barberos',
                          value: '${_resumen['totalBarberos'] ?? 0}',
                          accent: AppColors.info,
                        ),
                        StatTile(
                          icon: Icons.design_services_outlined,
                          label: 'Servicios',
                          value: '${_resumen['totalServicios'] ?? 0}',
                          accent: AppColors.success,
                        ),
                        StatTile(
                          icon: Icons.calendar_month_outlined,
                          label: 'Citas',
                          value: '${_resumen['totalCitas'] ?? 0}',
                          accent: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Accesos rápidos',
                      subtitle: 'Gestiona la operación del negocio',
                    ),
                    const SizedBox(height: 14),
                    _accesos(context),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Estado de las citas',
                      subtitle: 'Resumen general',
                      actionLabel: 'Ver todas',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
                    ),
                    const SizedBox(height: 14),
                    _estadoCitas(),
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
                    ..._ultimosUsuarios(),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Últimas reservas',
                      actionLabel: 'Ver agenda',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.citas),
                    ),
                    const SizedBox(height: 14),
                    ..._ultimasCitas(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _heroCard() {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Panel de administración',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Administra usuarios, barberos, servicios y citas desde un solo lugar.',
            style: TextStyle(
              color: AppColors.subtitle,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStat(
                '${_resumen['totalResenas'] ?? 0}',
                'Reseñas',
              ),
              const SizedBox(width: 26),
              _heroStat('${_citas['pendientes'] ?? 0}', 'Pendientes'),
              const SizedBox(width: 26),
              _heroStat('${_citas['completadas'] ?? 0}', 'Completadas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.subtitle, fontSize: 11.5),
        ),
      ],
    );
  }

  Widget _accesos(BuildContext context) {
    final items = [
      (
        'Usuarios',
        'Clientes, barberos y admins',
        Icons.group_outlined,
        () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUsuariosScreen()),
          );
          _cargar();
        },
      ),
      (
        'Servicios',
        'Catálogo y precios',
        Icons.design_services_outlined,
        () => Navigator.pushNamed(context, AppRoutes.servicios),
      ),
      (
        'Citas',
        'Agenda general',
        Icons.event_note_outlined,
        () => Navigator.pushNamed(context, AppRoutes.citas),
      ),
      (
        'Barberos',
        'Equipo profesional',
        Icons.content_cut_outlined,
        () => Navigator.pushNamed(context, AppRoutes.barberos),
      ),
    ];

    return Column(
      children: [
        for (final item in items)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            radius: 16,
            onTap: item.$4,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$3, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _estadoCitas() {
    final pendientes = _citas['pendientes'] ?? 0;
    final completadas = _citas['completadas'] ?? 0;
    final canceladas = _citas['canceladas'] ?? 0;

    return AppCard(
      child: Column(
        children: [
          _barra(
            'Pendientes',
            pendientes,
            AppColors.warning,
          ),
          const SizedBox(height: 14),
          _barra(
            'Completadas',
            completadas,
            AppColors.success,
          ),
          const SizedBox(height: 14),
          _barra(
            'Canceladas',
            canceladas,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _barra(String label, dynamic value, Color color) {
    final total = (int.tryParse('${_resumen['totalCitas'] ?? 0}') ?? 0);
    final numero = int.tryParse('$value') ?? 0;
    final ratio = total == 0 ? 0.0 : numero / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12.5,
                ),
              ),
            ),
            Text(
              '$numero',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 6,
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  List<Widget> _ultimosUsuarios() {
    final lista = _data?['ultimosUsuarios'];

    if (lista is! List || lista.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.people_outline,
          title: 'Sin usuarios registrados',
          message: 'Los nuevos usuarios aparecerán aquí.',
        ),
      ];
    }

    return lista.take(4).map((item) {
      final usuario = Map<String, dynamic>.from(item as Map);
      final nombre =
          '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();

      return AppCard(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        radius: 15,
        child: Row(
          children: [
            AppAvatar(name: nombre, radius: 18),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre.isEmpty ? 'Usuario' : nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    usuario['correo']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppFormat.date(usuario['created_at']),
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _ultimasCitas() {
    final lista = _data?['ultimasCitas'];

    if (lista is! List || lista.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Aún no hay reservas',
          message: 'Las citas recientes se mostrarán aquí.',
        ),
      ];
    }

    return lista.take(4).map((item) {
      final cita = Map<String, dynamic>.from(item as Map);
      final cliente = cita['usuarios'];
      final servicio = cita['servicios'];
      final nombre = cliente is Map
          ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
          : 'Cliente';
      final estado = cita['estado']?.toString() ?? 'Pendiente';

      return AppCard(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        radius: 15,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre.isEmpty ? 'Cliente' : nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${servicio is Map ? servicio['nombre'] ?? 'Servicio' : 'Servicio'} · '
                    '${AppFormat.date(cita['fecha'])} ${AppFormat.time(cita['hora'])}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            StatusPill(
              label: estado,
              color: AppFormat.statusColor(estado),
            ),
          ],
        ),
      );
    }).toList();
  }
}
