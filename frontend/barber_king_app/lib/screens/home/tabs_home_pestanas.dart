import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../barbero/barbero_home_screen.dart';
import '../barberos/barberos_screen.dart';
import '../citas/citas_screen.dart';
import '../cliente/cliente_home_screen.dart';
import '../horarios/horarios_screen.dart';
import '../solicitudes/solicitudes_screen.dart';

/// Un destino fijo de la barra inferior.
class Pestana {
  const Pestana({
    required this.etiqueta,
    required this.icono,
    required this.construir,
    this.ruta = '',
    this.iconoActivo,
    this.conPendientes = false,
  });

  /// Ruta de la pestaña; vacía en el panel, que no se navega por nombre.
  final String ruta;
  final String etiqueta;
  final IconData icono;
  final IconData? iconoActivo;

  /// Se llama solo la primera vez que la pestaña se abre.
  final WidgetBuilder construir;

  /// Muestra sobre el icono las solicitudes que siguen sin respuesta.
  final bool conPendientes;
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
    etiqueta: 'Solicitudes',
    ruta: AppRoutes.solicitudes,
    icono: Icons.assignment_outlined,
    iconoActivo: Icons.assignment,
    conPendientes: true,
    construir: _conSolicitudes,
  ),
];

/// Pestañas del barbero: la agenda y las solicitudes son su día a día.
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
    etiqueta: 'Solicitudes',
    ruta: AppRoutes.solicitudes,
    icono: Icons.assignment_outlined,
    iconoActivo: Icons.assignment,
    conPendientes: true,
    construir: _conSolicitudes,
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
Widget _conSolicitudes(_) => const SolicitudesScreen();
Widget _conHorarios(_) => const HorariosScreen();
