import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/cita_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/cliente/cliente_home_hero.dart';
part '../../widgets/cliente/cliente_home_encabezado.dart';
part '../../widgets/cliente/cliente_home_accesos.dart';
part '../../widgets/cliente/cliente_home_tarjetas.dart';

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
              _ClienteHomeEncabezado(
                nombre: nombre,
                onPerfil: () => _ir(AppRoutes.perfil),
                onCerrarSesion: _cerrarSesion,
              ),
              const SizedBox(height: 20),
              _ClienteHomeHeroCita(
                cargando: _cargando,
                cita: _proximaCita,
                onBuscarBarbero: () => _ir(AppRoutes.barberos),
                onVerCitas: () => _ir(AppRoutes.citas),
              ),
              const SizedBox(height: 20),
              _ClienteHomeStats(
                totalCitas: _citasCliente.length,
                completadas: _completadas,
                totalServicios: _totalServicios,
              ),
              const SizedBox(height: 26),
              const SectionHeader(
                title: '¿Qué necesitas hoy?',
                subtitle: 'Todo a un toque de distancia',
              ),
              const SizedBox(height: 14),
              _ClienteHomeAccesos(onIr: _ir),
              const SizedBox(height: 22),
              _ClienteHomePromoIA(onAbrir: () => _ir(AppRoutes.chatIA)),
              const SizedBox(height: 22),
              _ClienteHomeSoporte(
                onAbrir: () => _ir(AppRoutes.chatContactos),
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
}
