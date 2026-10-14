import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../barbero/barbero_home_screen.dart';
import '../cliente/cliente_home_screen.dart';

// Punto de entrada tras el login: según el rol muestra
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _usuario;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final data = await _auth.obtenerUsuario();
    if (!mounted) return;

    // Sin sesión guardada: de vuelta al login.
    if (data == null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      return;
    }

    setState(() {
      _usuario = data;
      _cargando = false;
    });
  }

  Future<void> _salir() async {
    await _auth.cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final usuario = _usuario!;
    final rolId = int.tryParse('${usuario['rol_id'] ?? 3}') ?? 3;

    switch (rolId) {
      case 1:
        return const AdminDashboardScreen();
      case 2:
        return BarberoHomeScreen(usuario: usuario);
      case 3:
        return ClienteHomeScreen(usuario: usuario);
      default:
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rol no soportado.',
                  style: TextStyle(color: AppColors.subtitle),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _salir,
                  child: const Text('CERRAR SESIÓN'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
