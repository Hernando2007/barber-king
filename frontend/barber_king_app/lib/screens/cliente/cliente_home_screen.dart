import 'package:flutter/material.dart';

import '../../widgets/common/app_bottom_nav.dart';
import '../barberos/barberos_screen.dart';
import '../chat/chat_ia_screen.dart';
import '../perfil/perfil_screen.dart';
import 'catalogo_estilos_screen.dart';
import 'inicio_tab.dart';

/// Contenedor del cliente: barra inferior + 5 pestañas.
/// 0 Inicio · 1 Buscar (barberos) · 2 Perfil · 3 Cámara IA · 4 Reservar (catálogo)
class ClienteHomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const ClienteHomeScreen({super.key, required this.usuario});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  int _tab = 0;
  final Set<int> _abiertas = {0}; // las pestañas se crean al visitarlas

  void _ir(int i) => setState(() {
        _tab = i;
        _abiertas.add(i);
      });

  Widget _pagina(int i) {
    switch (i) {
      case 0:
        return InicioTab(onIrATab: _ir);
      case 1:
        return const BarberosScreen();
      case 2:
        return const PerfilScreen();
      case 3:
        return const ChatIAScreen();
      default:
        return const CatalogoEstilosScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [for (var i = 0; i < 5; i++) _abiertas.contains(i) ? _pagina(i) : const SizedBox.shrink()],
      ),
      bottomNavigationBar: AppBottomNav(actual: _tab, onTap: _ir),
    );
  }
}
