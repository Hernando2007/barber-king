import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/cita_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PANEL PROFESIONAL',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10.5,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hola, $nombre',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                especialidad,
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
                        IconButton(
                          tooltip: 'Mi perfil',
                          onPressed: () => _ir(AppRoutes.perfil),
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
                    _heroAgenda(),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                      children: [
                        StatTile(
                          icon: Icons.event_outlined,
                          label: 'Citas totales',
                          value: '${_resumen?['totalCitas'] ?? 0}',
                        ),
                        StatTile(
                          icon: Icons.pending_actions_outlined,
                          label: 'Pendientes',
                          value: '${_resumen?['pendientes'] ?? 0}',
                          accent: AppColors.warning,
                        ),
                        StatTile(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Completadas',
                          value: '${_resumen?['completadas'] ?? 0}',
                          accent: AppColors.success,
                        ),
                        StatTile(
                          icon: Icons.star_outline_rounded,
                          label: 'Calificación',
                          value:
                              '${_resumen?['promedioCalificacion'] ?? '0.0'}',
                          accent: AppColors.primaryLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Herramientas',
                      subtitle: 'Gestiona tu día a día',
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 11,
                      mainAxisSpacing: 11,
                      childAspectRatio: 1.55,
                      children: [
                        _acceso(
                          'Mis citas',
                          Icons.calendar_month_outlined,
                          AppRoutes.citas,
                        ),
                        _acceso(
                          'Chats de clientes',
                          Icons.forum_outlined,
                          AppRoutes.chatContactos,
                        ),
                        _acceso(
                          'Mis horarios',
                          Icons.schedule_outlined,
                          AppRoutes.horarios,
                        ),
                        _acceso(
                          'Servicios',
                          Icons.content_cut_outlined,
                          AppRoutes.servicios,
                        ),
                        _acceso(
                          'Mi perfil',
                          Icons.badge_outlined,
                          AppRoutes.perfil,
                        ),
                        _acceso(
                          'Asesor IA',
                          Icons.auto_awesome_outlined,
                          AppRoutes.chatIA,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Datos profesionales',
                      icon: Icons.workspace_premium_outlined,
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.workspace_premium_outlined,
                            label: 'Especialidad',
                            value:
                                barberoMap['especialidad']?.toString() ?? '-',
                          ),
                          InfoRow(
                            icon: Icons.timeline_outlined,
                            label: 'Experiencia',
                            value: '${barberoMap['experiencia'] ?? 0} años',
                          ),
                          InfoRow(
                            icon: Icons.verified_outlined,
                            label: 'Documento profesional',
                            value:
                                barberoMap['diploma_url'] == null
                                ? 'No adjuntado'
                                : 'Adjuntado y registrado',
                          ),
                          InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Dirección',
                            value:
                                barberoMap['direccion']?.toString() ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _heroAgenda() {
    final cita = _citaHoy;

    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'AGENDA DE HOY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _ir(AppRoutes.citas),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          if (cita == null) ...[
            const SizedBox(height: 8),
            const Text(
              'No tienes citas pendientes para hoy',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Aprovecha para revisar tu disponibilidad y mantener tu perfil al día.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              AppFormat.time(cita['hora']),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              () {
                final cliente = cita['usuarios'];
                final servicio = cita['servicios'];
                final nombreCliente = cliente is Map
                    ? '${cliente['nombres'] ?? ''} '
                          '${cliente['apellidos'] ?? ''}'.trim()
                    : 'Cliente';
                final nombreServicio = servicio is Map
                    ? servicio['nombre']?.toString() ?? 'Servicio'
                    : 'Servicio';
                return '$nombreCliente · $nombreServicio';
              }(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StatusPill(
                  label: cita['estado']?.toString() ?? 'Pendiente',
                  color: AppFormat.statusColor(
                    cita['estado']?.toString(),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _ir(AppRoutes.citas),
                  child: const Text('Gestionar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _acceso(String titulo, IconData icon, String ruta) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 17,
      onTap: () => _ir(ruta),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 23),
          const SizedBox(height: 9),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
