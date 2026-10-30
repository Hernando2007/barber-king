import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../services/ubicacion_service.dart';
import '../common/app_ui.dart';
import 'mapa_barbero_detalle.dart';
import 'mapa_barbero_vista.dart';

class MapaBarberoPanel extends StatelessWidget {
  final Map<String, dynamic> datos;
  final PosicionUsuario? cliente;
  final String nombre;
  final String? foto;
  final String? especialidad;
  final double? distanciaKm;
  final bool actualizando;
  final VoidCallback onActualizar;

  const MapaBarberoPanel({
    super.key,
    required this.datos,
    required this.cliente,
    required this.nombre,
    required this.foto,
    required this.especialidad,
    required this.distanciaKm,
    required this.actualizando,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    final posicion = cliente;

    return Stack(
      children: [
        Positioned.fill(
          child: MapaBarberoVista(
            barbero: LatLng(
              (datos['latitud'] as num).toDouble(),
              (datos['longitud'] as num).toDouble(),
            ),
            cliente: posicion == null
                ? null
                : LatLng(posicion.latitud, posicion.longitud),
            nombre: nombre,
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: MapaBarberoDetalle(
            nombre: nombre,
            foto: foto,
            ciudad: datos['ciudad']?.toString(),
            zona: datos['zona']?.toString(),
            especialidad: especialidad,
            distanciaKm: distanciaKm,
            actualizadaEn: datos['actualizada_en']?.toString(),
            cargando: actualizando,
            onActualizar: onActualizar,
          ),
        ),
      ],
    );
  }
}

class MapaBarberoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const MapaBarberoError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        EmptyState(
          icon: Icons.location_off_outlined,
          title: 'Ubicación no disponible',
          message: mensaje,
          actionLabel: 'Reintentar',
          onAction: onReintentar,
        ),
      ],
    );
  }
}
