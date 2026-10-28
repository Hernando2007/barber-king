import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BarberosCalificacion extends StatelessWidget {
  final double promedio;
  final int total;
  final bool compacto;

  const BarberosCalificacion({
    super.key,
    required this.promedio,
    required this.total,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final tieneResenas = total > 0;
    final tamano = compacto ? 13.0 : 15.0;
    final fontSize = compacto ? 11.0 : 12.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: tamano,
          color: tieneResenas ? AppColors.primary : AppColors.muted,
        ),
        const SizedBox(width: 3),
        Text(
          tieneResenas ? promedio.toStringAsFixed(1) : 'Sin reseñas',
          style: TextStyle(
            color: tieneResenas ? AppColors.primaryLight : AppColors.muted,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tieneResenas) ...[
          const SizedBox(width: 4),
          Text(
            '($total)',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: fontSize - 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class BarberosUbicacionLine extends StatelessWidget {
  final String? ciudad;
  final String? zona;
  final double? distanciaKm;

  const BarberosUbicacionLine({
    super.key,
    this.ciudad,
    this.zona,
    this.distanciaKm,
  });

  String get _distancia {
    final km = distanciaKm;
    if (km == null) return '';

    if (km < 1) {
      return 'a ${(km * 1000).round()} m';
    }

    return 'a ${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final lugar = [ciudad, zona]
        .where((valor) => valor != null && valor.trim().isNotEmpty)
        .join(', ');

    final texto = [
      if (lugar.isNotEmpty) lugar,
      if (_distancia.isNotEmpty) _distancia,
    ].join(' · ');

    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 12,
            color: AppColors.muted,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
