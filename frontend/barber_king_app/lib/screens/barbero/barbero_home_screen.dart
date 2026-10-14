import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/usuario_service.dart';

class BarberoHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const BarberoHomeScreen({super.key, required this.usuario});

  @override
  State<BarberoHomeScreen> createState() => _BarberoHomeScreenState();
}

class _BarberoHomeScreenState extends State<BarberoHomeScreen> {
  final UsuarioService _usuarios = UsuarioService();
  final DashboardService _dashboard = DashboardService();
  Map<String, dynamic>? perfil;
  Map<String, dynamic>? estadisticas;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await _usuarios.obtenerPerfilActual();
    final panel = await _dashboard.obtenerBarbero();
    if (!mounted) return;
    setState(() {
      perfil = data;
      estadisticas = panel?['resumen'] is Map ? Map<String, dynamic>.from(panel!['resumen']) : null;
      cargando = false;
    });
  }

  Future<void> _salir() async {
    await AuthService().cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final barbero = perfil?['barbero'];
    final especialidad = barbero is Map ? barbero['especialidad']?.toString() ?? 'Sin especialidad' : 'Sin especialidad';
    final estado = barbero is Map ? barbero['verificacion_estado']?.toString() ?? 'pendiente' : 'pendiente';
    final pendiente = estado.toLowerCase() == 'pendiente';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _cargarPerfil,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BARBER KING / BARBERO', style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Hola, ${widget.usuario['nombres'] ?? 'Barbero'}', style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(especialidad, style: const TextStyle(color: AppColors.subtitle)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil), icon: const Icon(Icons.person_outline, color: AppColors.primary)),
                  IconButton(onPressed: _salir, icon: const Icon(Icons.logout_outlined, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: pendiente ? const Color(0xFFFFFBEB) : AppColors.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: pendiente ? Colors.amber.shade300 : AppColors.border)),
                child: Row(
                  children: [
                    Icon(pendiente ? Icons.pending_actions_outlined : Icons.verified_outlined, color: pendiente ? Colors.amber.shade800 : AppColors.primary, size: 34),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado profesional', style: TextStyle(color: pendiente ? Colors.amber.shade900 : AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(pendiente ? 'Perfil creado. El documento queda pendiente de revisión.' : 'Perfil profesional verificado.', style: const TextStyle(color: AppColors.subtitle, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: [
                  _statItem('Citas', '${estadisticas?['totalCitas'] ?? 0}', Icons.event_outlined),
                  _statItem('Pendientes', '${estadisticas?['pendientes'] ?? 0}', Icons.pending_actions),
                  _statItem('Completadas', '${estadisticas?['completadas'] ?? 0}', Icons.check_circle_outline),
                  _statItem('Calificación', '${estadisticas?['promedioCalificacion'] ?? 0}', Icons.star_outline),
                ],
              ),
              const SizedBox(height: 26),
              const Text('Panel profesional', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.12,
                children: [
                  _actionCard(context, 'Mis citas', Icons.calendar_month_outlined, AppRoutes.citas),
                  _actionCard(context, 'Mis horarios', Icons.schedule_outlined, AppRoutes.horarios),
                  _actionCard(context, 'Servicios', Icons.content_cut_outlined, AppRoutes.servicios),
                  _actionCard(context, 'Mi perfil', Icons.badge_outlined, AppRoutes.perfil),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: const TextStyle(color: AppColors.subtitle, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
        ]),
      );

  Widget _actionCard(BuildContext context, String title, IconData icon, String route) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.primary, size: 34),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}