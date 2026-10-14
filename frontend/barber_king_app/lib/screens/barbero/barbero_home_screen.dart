import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common/gold_widgets.dart';

/// Panel del barbero: estadísticas (/dashboard/barbero) y accesos rápidos.
class BarberoHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const BarberoHomeScreen({super.key, required this.usuario});

  @override
  State<BarberoHomeScreen> createState() => _BarberoHomeScreenState();
}

class _BarberoHomeScreenState extends State<BarberoHomeScreen> {
  Map<String, dynamic> _resumen = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final panel = await DashboardService().obtenerBarbero();
    if (!mounted) return;
    setState(() {
      _resumen = panel?['resumen'] is Map
          ? Map<String, dynamic>.from(panel!['resumen'])
          : {};
      _cargando = false;
    });
  }

  Future<void> _salir() async {
    await AuthService().cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Widget _estadistica(IconData icono, String etiqueta, String valor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icono, color: AppColors.primary),
          Text(valor, style: tituloSerif(size: 26, color: Colors.white)),
          Text(
            etiqueta.toUpperCase(),
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _acceso(IconData icono, String titulo, String detalle, String ruta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(context, ruta),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      detalle,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calificacion = '${_resumen['promedioCalificacion'] ?? 0}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BARBER KING', style: tituloSerif(size: 13)),
                              Text(
                                'Hola, ${widget.usuario['nombres'] ?? 'Barbero'}',
                                style: tituloSerif(
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Panel del barbero',
                                style: TextStyle(
                                  color: AppColors.subtitle,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: _salir,
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _estadistica(
                          Icons.event_outlined,
                          'Citas',
                          '${_resumen['totalCitas'] ?? 0}',
                        ),
                        _estadistica(
                          Icons.pending_actions,
                          'Pendientes',
                          '${_resumen['pendientes'] ?? 0}',
                        ),
                        _estadistica(
                          Icons.check_circle_outline,
                          'Completadas',
                          '${_resumen['completadas'] ?? 0}',
                        ),
                        _estadistica(
                          Icons.star_outline,
                          'Calificación',
                          calificacion,
                        ),
                      ],
                    ),
                    const TituloSeccion('ACCESOS'),
                    _acceso(
                      Icons.calendar_month,
                      'Mis citas',
                      'Revisa y completa tus citas',
                      AppRoutes.citas,
                    ),
                    _acceso(
                      Icons.schedule,
                      'Horarios',
                      'Días y horas en que trabajas',
                      AppRoutes.horarios,
                    ),
                    _acceso(
                      Icons.content_cut,
                      'Servicios',
                      'Crea y edita tus servicios',
                      AppRoutes.servicios,
                    ),
                    _acceso(
                      Icons.person_outline,
                      'Mi perfil',
                      'Tus datos y ajustes',
                      AppRoutes.perfil,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
