import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/usuario_service.dart';

class BarberoHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const BarberoHomeScreen({
    super.key,
    required this.usuario,
  });

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
      estadisticas = panel?['resumen'] is Map
          ? Map<String, dynamic>.from(panel!['resumen'])
          : null;
      cargando = false;
    });
  }

  Future<void> _salir() async {
    await AuthService().cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final barbero = perfil?['barbero'];
    final especialidad = barbero is Map
        ? barbero['especialidad']?.toString() ?? 'Sin especialidad'
        : 'Sin especialidad';
    final verificacion = barbero is Map
        ? barbero['verificacion_estado']?.toString() ?? 'pendiente'
        : 'pendiente';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
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
                        const Text(
                          'BARBER KING / BARBERO',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hola, ${widget.usuario['nombres'] ?? 'Barbero'}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          especialidad,
                          style: const TextStyle(
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.perfil,
                    ),
                    icon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: _salir,
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _verificationCard(verificacion),
              const SizedBox(height: 26),
              _statsCard(),
              const SizedBox(height: 26),
              const Text(
                'Panel profesional',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _actions(context),
              const SizedBox(height: 26),
              _professionalCard(barbero),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsCard() {
    final data = estadisticas ?? {};
    final items = [
      ('Citas', '${data['totalCitas'] ?? 0}', Icons.event_outlined),
      ('Pendientes', '${data['pendientes'] ?? 0}', Icons.pending_actions),
      ('Completadas', '${data['completadas'] ?? 0}', Icons.check_circle_outline),
      ('Calificación', '${data['promedioCalificacion'] ?? 0}', Icons.star_outline),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(item.$3, color: AppColors.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$1, style: const TextStyle(color: AppColors.subtitle, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(item.$2, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _verificationCard(String estado) {
    final pendiente = estado.toLowerCase() == 'pendiente';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pendiente
            ? const Color(0xFF2A2411)
            : AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            pendiente
                ? Icons.pending_actions_outlined
                : Icons.verified_outlined,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado profesional',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pendiente
                      ? 'Perfil creado. El documento queda pendiente de revisión.'
                      : 'Perfil profesional verificado.',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final actions = [
      _BarberAction(
        'Mis citas',
        Icons.calendar_month_outlined,
        AppRoutes.citas,
      ),
      _BarberAction(
        'Mis horarios',
        Icons.schedule_outlined,
        AppRoutes.horarios,
      ),
      _BarberAction(
        'Servicios',
        Icons.content_cut_outlined,
        AppRoutes.servicios,
      ),
      _BarberAction(
        'Mi perfil',
        Icons.badge_outlined,
        AppRoutes.perfil,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (_, index) {
        final action = actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(
            context,
            action.route,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action.icon,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 10),
                Text(
                  action.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _professionalCard(dynamic barbero) {
    final hasDiploma = barbero is Map &&
        barbero['diploma_url'] != null &&
        barbero['diploma_url'].toString().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos profesionales',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _row(
            Icons.workspace_premium_outlined,
            'Especialidad',
            barbero is Map
                ? barbero['especialidad']?.toString() ?? '-'
                : '-',
          ),
          const SizedBox(height: 10),
          _row(
            Icons.description_outlined,
            'Diploma/certificado',
            hasDiploma ? 'Adjuntado' : 'No adjuntado',
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$title: $value',
            style: const TextStyle(color: AppColors.subtitle),
          ),
        ),
      ],
    );
  }
}

class _BarberAction {
  final String title;
  final IconData icon;
  final String route;

  const _BarberAction(this.title, this.icon, this.route);
}
