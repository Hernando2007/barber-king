import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/chat_notificacion_service.dart';
import '../barbero/barbero_home_screen.dart';
import '../barberos/barberos_screen.dart';
import '../chat/chat_contactos_screen.dart';
import '../citas/citas_screen.dart';
import '../cliente/cliente_home_screen.dart';
import '../horarios/horarios_screen.dart';
import 'pestana_scope.dart';

/// Un destino fijo de la barra inferior.
class Pestana {
  const Pestana({
    required this.etiqueta,
    required this.icono,
    required this.construir,
    this.ruta = '',
    this.iconoActivo,
    this.contarNoLeidos = false,
  });

  /// Ruta de la pestaña; vacía en el panel, que no se navega por nombre.
  final String ruta;
  final String etiqueta;
  final IconData icono;
  final IconData? iconoActivo;

  /// Se llama solo la primera vez que la pestaña se abre.
  final WidgetBuilder construir;

  /// Muestra sobre el icono los mensajes sin leer del chat.
  final bool contarNoLeidos;
}

/// Pestañas del cliente: el panel de inicio manda, los cuatro destinos
/// frecuentes quedan a un toque sin salir a ningún lado.
List<Pestana> pestanasCliente(Map<String, dynamic> usuario) => [
  Pestana(
    etiqueta: 'Inicio',
    icono: Icons.home_outlined,
    iconoActivo: Icons.home,
    construir: (_) => ClienteHomeScreen(usuario: usuario),
  ),
  const Pestana(
    etiqueta: 'Citas',
    ruta: AppRoutes.citas,
    icono: Icons.event_available_outlined,
    iconoActivo: Icons.event_available,
    construir: _conCitas,
  ),
  const Pestana(
    etiqueta: 'Barberos',
    ruta: AppRoutes.barberos,
    icono: Icons.content_cut_outlined,
    iconoActivo: Icons.content_cut,
    construir: _conBarberos,
  ),
  const Pestana(
    etiqueta: 'Chats',
    ruta: AppRoutes.chatContactos,
    icono: Icons.chat_outlined,
    iconoActivo: Icons.chat,
    contarNoLeidos: true,
    construir: _conChats,
  ),
];

/// Pestañas del barbero: la agenda y los chats son su día a día.
List<Pestana> pestanasBarbero(Map<String, dynamic> usuario) => [
  Pestana(
    etiqueta: 'Inicio',
    icono: Icons.home_outlined,
    iconoActivo: Icons.home,
    construir: (_) => BarberoHomeScreen(usuario: usuario),
  ),
  const Pestana(
    etiqueta: 'Agenda',
    ruta: AppRoutes.citas,
    icono: Icons.event_available_outlined,
    iconoActivo: Icons.event_available,
    construir: _conCitas,
  ),
  const Pestana(
    etiqueta: 'Chats',
    ruta: AppRoutes.chatContactos,
    icono: Icons.chat_outlined,
    iconoActivo: Icons.chat,
    contarNoLeidos: true,
    construir: _conChats,
  ),
  const Pestana(
    etiqueta: 'Horarios',
    ruta: AppRoutes.horarios,
    icono: Icons.schedule_outlined,
    iconoActivo: Icons.schedule,
    construir: _conHorarios,
  ),
];

Widget _conCitas(_) => const CitasScreen();
Widget _conBarberos(_) => const BarberosScreen();
Widget _conChats(_) => const ChatContactosScreen();
Widget _conHorarios(_) => const HorariosScreen();

/// Contenedor con barra inferior fija. Cada destino conserva su propio
/// `Scaffold` (AppBar, pulir para actualizar y botón flotante), así que la
/// barra solo decide cuál se muestra: los estados y el scroll no se pierden.
class TabsHomeScreen extends StatefulWidget {
  const TabsHomeScreen({super.key, required this.pestanas});

  final List<Pestana> pestanas;

  @override
  State<TabsHomeScreen> createState() => _TabsHomeScreenState();
}

class _TabsHomeScreenState extends State<TabsHomeScreen> {
  int _indice = 0;

  /// IndexedStack construye todo de una sola vez si lo dejamos, y eso haría
  /// las peticiones de las cuatro pestañas en el arranque. La primera visita
  /// es la que carga cada una.
  final Set<int> _abiertas = {0};

  bool _irARuta(String ruta) {
    final indice = widget.pestanas.indexWhere((pestan) => pestan.ruta == ruta);

    if (indice < 0) return false;

    setState(() {
      _abiertas.add(indice);
      _indice = indice;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Atrás lleva al panel; solo desde el panel la app se cierra.
      canPop: _indice == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irARuta(widget.pestanas.first.ruta);
      },
      child: PestanaScope(
        irARuta: _irARuta,
        child: Scaffold(
          backgroundColor: AppColors.background,
          // El Scaffold de cada pestaña ya se rearma con el teclado; si este
          // también lo hace, la barra se sale de la pantalla.
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _indice,
            children: [
              for (var i = 0; i < widget.pestanas.length; i++)
                if (_abiertas.contains(i))
                  Builder(builder: widget.pestanas[i].construir)
                else
                  const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indice,
            onDestinationSelected: (indice) => setState(() {
              _abiertas.add(indice);
              _indice = indice;
            }),
            destinations: [
              for (var i = 0; i < widget.pestanas.length; i++)
                NavigationDestination(
                  label: widget.pestanas[i].etiqueta,
                  icon: _IconoPestana(
                    pestana: widget.pestanas[i],
                    activa: i == _indice,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icono de la barra, con la pastilla de mensajes sin leer encima.
class _IconoPestana extends StatelessWidget {
  const _IconoPestana({required this.pestana, required this.activa});

  final Pestana pestana;
  final bool activa;

  @override
  Widget build(BuildContext context) {
    final icono = Icon(
      activa && pestana.iconoActivo != null ? pestana.iconoActivo : pestana.icono,
    );

    if (!pestana.contarNoLeidos) return icono;

    return ValueListenableBuilder<int>(
      valueListenable: ChatNotificacionService.instance.noLeidos,
      builder: (context, pendientes, _) {
        if (pendientes <= 0) return icono;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            icono,
            Positioned(
              right: -6,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  pendientes > 9 ? '9+' : '$pendientes',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
