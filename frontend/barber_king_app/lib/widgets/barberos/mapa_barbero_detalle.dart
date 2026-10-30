import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';

class MapaBarberoDetalle extends StatelessWidget {
  final String nombre;
  final String? foto;
  final String? ciudad;
  final String? zona;
  final String? especialidad;
  final double? distanciaKm;
  final String? actualizadaEn;
  final bool cargando;
  final VoidCallback onActualizar;

  const MapaBarberoDetalle({
    super.key,
    required this.nombre,
    required this.foto,
    required this.ciudad,
    required this.zona,
    required this.especialidad,
    required this.distanciaKm,
    required this.actualizadaEn,
    required this.cargando,
    required this.onActualizar,
  });

  String get _lugar {
    final partes = [ciudad, zona]
        .where((parte) => parte != null && parte.trim().isNotEmpty)
        .map((parte) => parte!.trim())
        .toList();

    return partes.isEmpty ? 'Ubicación compartida' : partes.join(' · ');
  }

  String get _ultima {
    final fecha = DateTime.tryParse(actualizadaEn ?? '')?.toLocal();

    if (fecha == null) return 'Actualizada hace instantes';

    final minutos = DateTime.now().difference(fecha).inMinutes;

    if (minutos < 1) return 'Actualizada ahora mismo';
    if (minutos == 1) return 'Actualizada hace 1 min';

    return 'Actualizada hace $minutos min';
  }

  @override
  Widget build(BuildContext context) {
    final distancia = distanciaKm;

    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: nombre,
                photoUrl: foto,
                radius: 25,
                fallbackIcon: Icons.content_cut_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      especialidad?.trim().isNotEmpty == true
                          ? especialidad!.trim()
                          : _lugar,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: distancia == null
                    ? 'En vivo'
                    : '${distancia.toStringAsFixed(1)} km',
                color: distancia == null ? AppColors.success : AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                color: AppColors.subtitle,
                size: 15,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _lugar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _ultima,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: cargando ? null : onActualizar,
                  icon: cargando
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Actualizar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'El barbero comparte su ubicación desde su app mientras está activa. '
            'Mapa © OpenStreetMap.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
