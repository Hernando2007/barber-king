import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';
import 'barberos_calificacion.dart';
import 'sello_verificado.dart';

/// La tarjeta grande del perfil: quién es y dónde trabaja.
class PerfilBarberoHero extends StatelessWidget {
  final String nombre;
  final String? foto;
  final String especialidad;
  final double promedio;
  final int totalResenas;
  final bool disponible;
  final bool verificado;
  final String lugar;
  final int experiencia;
  final double? distancia;
  final String? descripcion;

  const PerfilBarberoHero({
    super.key,
    required this.nombre,
    required this.foto,
    required this.especialidad,
    required this.promedio,
    required this.totalResenas,
    required this.disponible,
    required this.verificado,
    required this.lugar,
    required this.experiencia,
    required this.distancia,
    required this.descripcion,
  });

  String get _distanciaTexto {
    final km = distancia;
    if (km == null) return '';
    return km < 1
        ? 'a ${(km * 1000).round()} m'
        : 'a ${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final zona = [
      if (lugar.isNotEmpty) lugar,
      if (distancia != null) _distanciaTexto,
    ].join(' · ');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppAvatar(
                    name: nombre,
                    photoUrl: foto,
                    radius: 33,
                    fallbackIcon: Icons.content_cut_rounded,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: disponible ? AppColors.success : AppColors.muted,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SelloVerificado(visible: verificado, size: 20),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      especialidad,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BarberosCalificacion(
                      promedio: promedio,
                      total: totalResenas,
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: disponible ? 'Disponible' : 'Ocupado',
                color: disponible ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          if (zona.isNotEmpty || experiencia > 0) ...[
            const SizedBox(height: 16),
            if (zona.isNotEmpty)
              InfoRow(icon: Icons.place_outlined, label: 'Zona', value: zona),
            if (experiencia > 0)
              InfoRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Experiencia',
                value: '$experiencia año${experiencia == 1 ? '' : 's'}',
              ),
          ],
          if (descripcion != null && descripcion!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              descripcion!,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
