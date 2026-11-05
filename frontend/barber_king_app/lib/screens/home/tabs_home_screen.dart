import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/avisos_notificacion_service.dart';
import 'pestana_scope.dart';
import 'tabs_home_pestanas.dart';

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

/// Icono de la barra, con la pastilla de solicitudes sin respuesta encima.
class _IconoPestana extends StatelessWidget {
  const _IconoPestana({required this.pestana, required this.activa});

  final Pestana pestana;
  final bool activa;

  @override
  Widget build(BuildContext context) {
    final icono = Icon(
      activa && pestana.iconoActivo != null
          ? pestana.iconoActivo
          : pestana.icono,
    );

    if (!pestana.conPendientes) return icono;

    return ValueListenableBuilder<int>(
      valueListenable: AvisosNotificacionService.instance.solicitudesPendientes,
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
