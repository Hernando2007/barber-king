import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/colors.dart';

class MapaBarberoVista extends StatelessWidget {
  static const String _teselas = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  final LatLng barbero;
  final LatLng? cliente;
  final String nombre;

  const MapaBarberoVista({
    super.key,
    required this.barbero,
    required this.cliente,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    final coordenadas = [barbero, ?cliente];

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: coordenadas,
          padding: const EdgeInsets.fromLTRB(60, 90, 60, 240),
          maxZoom: 17,
        ),
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _teselas,
          userAgentPackageName: 'com.example.barber_king_app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            if (cliente != null)
              Marker(
                point: cliente!,
                width: 26,
                height: 26,
                child: const _PuntoCliente(),
              ),
            Marker(
              point: barbero,
              width: 120,
              height: 78,
              alignment: Marker.computePixelAlignment(
                width: 120,
                height: 78,
                left: 60,
                top: 22,
              ),
              child: _PinBarbero(nombre: nombre),
            ),
          ],
        ),
      ],
    );
  }
}

class _PuntoCliente extends StatelessWidget {
  const _PuntoCliente();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, spreadRadius: 1),
        ],
      ),
    );
  }
}

class _PinBarbero extends StatelessWidget {
  final String nombre;

  const _PinBarbero({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 1),
            ],
          ),
          child: const Icon(
            Icons.content_cut_rounded,
            color: AppColors.black,
            size: 21,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .85),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
