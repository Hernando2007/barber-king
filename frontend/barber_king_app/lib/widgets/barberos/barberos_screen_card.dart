import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../common/app_ui.dart';
import 'barberos_calificacion.dart';
import 'barberos_screen_acciones.dart';

class BarberosScreenCard extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final bool puedeChatear;
  final bool puedeReservar;
  final VoidCallback onChat;
  final VoidCallback onReservar;
  final VoidCallback onMapa;

  const BarberosScreenCard({
    super.key,
    required this.barbero,
    required this.puedeChatear,
    required this.puedeReservar,
    required this.onChat,
    required this.onReservar,
    required this.onMapa,
  });

  Map<String, dynamic> _usuario(Map<String, dynamic> barbero) {
    final value = barbero['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String _nombre(Map<String, dynamic> barbero) {
    final usuario = _usuario(barbero);
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario(barbero);
    final nombre = _nombre(barbero);
    final especialidad = barbero['especialidad']?.toString().isNotEmpty == true
        ? barbero['especialidad'].toString()
        : 'Barbero profesional';
    final descripcion = barbero['descripcion']?.toString();
    final experiencia = int.tryParse('${barbero['experiencia'] ?? 0}') ?? 0;
    final disponible = barbero['disponible'] != false;
    final foto = usuario['foto']?.toString() ?? barbero['foto_trabajo']?.toString();
    final promedio =
        (barbero['calificacion_promedio'] as num?)?.toDouble() ?? 0;
    final totalResenas =
        int.tryParse('${barbero['total_resenas'] ?? 0}') ?? 0;
    final distancia = double.tryParse('${barbero['distancia_km'] ?? ''}');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    name: nombre,
                    photoUrl: foto,
                    radius: 29,
                    fallbackIcon: Icons.content_cut_rounded,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: disponible
                            ? AppColors.success
                            : AppColors.muted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.card,
                          width: 2,
                        ),
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
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      especialidad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BarberosCalificacion(
                      promedio: promedio,
                      total: totalResenas,
                      compacto: true,
                    ),
                    BarberosUbicacionLine(
                      ciudad: barbero['ciudad']?.toString(),
                      zona: barbero['zona']?.toString(),
                      distanciaKm: distancia,
                    ),
                    if (experiencia > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$experiencia año${experiencia == 1 ? '' : 's'} de experiencia',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusPill(
                label: disponible ? 'Disponible' : 'Ocupado',
                color: disponible ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          if (descripcion != null && descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (foto != null && ApiConfig.resolveMedia(foto) != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                ApiConfig.resolveMedia(foto)!,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          BarberosScreenAcciones(
            ubicacionVigente: barbero['tiene_ubicacion'] == true &&
                barbero['ubicacion_vigente'] == true,
            puedeChatear: puedeChatear,
            puedeReservar: puedeReservar,
            disponible: disponible,
            onChat: onChat,
            onReservar: onReservar,
            onMapa: onMapa,
          ),
        ],
      ),
    );
  }
}
