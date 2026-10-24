import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/cita_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';

class ClienteHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const ClienteHomeScreen({super.key, required this.usuario});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final CitaService _citas = CitaService();
  final ServicioService _servicios = ServicioService();

  List<Map<String, dynamic>> _citasCliente = [];
  int _totalServicios = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final citas = await _citas.obtenerCitas();
    final servicios = await _servicios.obtenerServicios(soloActivos: true);

    if (!mounted) return;

    setState(() {
      _citasCliente = citas
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _totalServicios = servicios.length;
      _cargando = false;
    });
  }

  Future<void> _ir(String ruta) async {
    await Navigator.pushNamed(context, ruta);
    _cargar();
  }

  Map<String, dynamic>? get _proximaCita {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);

    final pendientes = _citasCliente.where((cita) {
      final estado = '${cita['estado'] ?? ''}'.toLowerCase();
      final fecha = AppFormat.toDate(cita['fecha']);
      if (fecha == null) return false;
      return estado != 'cancelada' &&
          estado != 'completada' &&
          !fecha.isBefore(inicio);
    }).toList();

    pendientes.sort((a, b) {
      final fechaA = AppFormat.toDate(a['fecha']) ?? DateTime(2100);
      final fechaB = AppFormat.toDate(b['fecha']) ?? DateTime(2100);
      return fechaA.compareTo(fechaB);
    });

    return pendientes.isEmpty ? null : pendientes.first;
  }

  int get _completadas => _citasCliente
      .where((cita) => '${cita['estado']}'.toLowerCase() == 'completada')
      .length;

  Future<void> _cerrarSesion() async {
    await AuthService().cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.usuario['nombres']?.toString() ?? 'Cliente';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
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
                        Text(
                          AppFormat.greeting().toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
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
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
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
                    onPressed: _cerrarSesion,
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _heroProximaCita(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.event_note_outlined,
                      label: 'Mis citas',
                      value: '${_citasCliente.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Completadas',
                      value: '$_completadas',
                      accent: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      icon: Icons.design_services_outlined,
                      label: 'Servicios',
                      value: '$_totalServicios',
                      accent: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                title: '¿Qué necesitas hoy?',
                subtitle: 'Todo a un toque de distancia',
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
                    'Reservar cita',
                    Icons.calendar_month_outlined,
                    AppRoutes.citas,
                  ),
                  _acceso(
                    'Nuestros barberos',
                    Icons.content_cut_rounded,
                    AppRoutes.barberos,
                  ),
                  _acceso(
                    'Servicios',
                    Icons.design_services_outlined,
                    AppRoutes.servicios,
                  ),
                  _acceso(
                    'Mis citas',
                    Icons.event_available_outlined,
                    AppRoutes.citas,
                  ),
                  _acceso(
                    'Chat con barbero',
                    Icons.forum_outlined,
                    AppRoutes.chatContactos,
                  ),
                  _acceso(
                    'Mi perfil',
                    Icons.person_outline_rounded,
                    AppRoutes.perfil,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AppCard(
                gradient: AppColors.heroGradient,
                borderColor: AppColors.primary.withValues(alpha: .35),
                onTap: () => _ir(AppRoutes.chatIA),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asesor de estilo con IA',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Toma una foto y descubre qué corte te favorece.',
                            style: TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.primary.withValues(alpha: .9),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Text(
                        'Chatea directamente con tu barbero para resolver dudas '
                        'antes de tu cita.',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _ir(AppRoutes.chatContactos),
                      child: const Text('Abrir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ir(AppRoutes.citas),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Reservar'),
      ),
    );
  }

  Widget _heroProximaCita() {
    final cita = _proximaCita;

    if (_cargando) {
      return const AppCard(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cita == null) {
      return AppCard(
        gradient: AppColors.heroGradient,
        borderColor: AppColors.primary.withValues(alpha: .3),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.content_cut_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu próximo look comienza aquí',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Reserva con los mejores barberos y disfruta de una experiencia premium.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _ir(AppRoutes.barberos),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('BUSCAR BARBERO'),
              ),
            ),
          ],
        ),
      );
    }

    final servicio = cita['servicios'];
    final estado = cita['estado']?.toString() ?? 'Pendiente';

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
                Icons.event_available_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'TU PRÓXIMA CITA',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusPill(
                label: estado,
                color: AppFormat.statusColor(estado),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            servicio is Map
                ? servicio['nombre']?.toString() ?? 'Servicio'
                : 'Servicio',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormat.dateLong(cita['fecha'])} · '
            '${AppFormat.time(cita['hora'])}',
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () => _ir(AppRoutes.citas),
            icon: const Icon(Icons.event_note_outlined, size: 17),
            label: const Text('Ver mis citas'),
          ),
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
