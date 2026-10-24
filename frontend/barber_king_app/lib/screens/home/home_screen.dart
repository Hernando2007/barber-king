import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../admin/admin_home_screen.dart';
import '../barbero/barbero_home_screen.dart';
import '../cliente/cliente_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  Map<String, dynamic>? usuario;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final data = await _auth.obtenerUsuario();

    if (!mounted) return;

    if (data == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
      return;
    }

    setState(() {
      usuario = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final rolId = int.tryParse(
          '${usuario?['rol_id'] ?? 3}',
        ) ??
        3;

    if (rolId == 1) {
      return AdminHomeScreen(usuario: usuario!);
    }

    if (rolId == 2) {
      return BarberoHomeScreen(usuario: usuario!);
    }

    return ClienteHomeScreen(usuario: usuario!);
  }
}
