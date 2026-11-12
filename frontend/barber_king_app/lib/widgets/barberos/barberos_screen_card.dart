import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';
import 'barberos_calificacion.dart';
import 'barberos_screen_acciones.dart';
import 'sello_verificado.dart';

class BarberosScreenCard extends StatelessWidget {
  final Map<String, dynamic> barbero;
  final bool puedeReservar;
  final VoidCallback onAbrirPerfil;
  final VoidCallback onReservar;

  const BarberosScreenCard({
    super.key,
    required this.barbero,
    required this.puedeReservar,
    required this.onAbrirPerfil,
    required this.onReservar,
  });

  Map<String, dynamic> _usuario(Map<String, dynamic> barbero) {
    final value = barbero['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String _nombre(Map<String, dynamic> barbero) {
    final usuario = _usuario(barbero);
    final nombre = '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
        .trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
  }

  String _distancia(double? km) {
    if (km == null) return '';

    if (km < 1) {
      return '${(km * 1000).round()} m';
    }

    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario(barbero);
    final nombre = _nombre(barbero);
    final especialidad = barbero['especialidad']?.toString().isNotEmpty == true
        ? barbero['especialidad'].toString()
        : 'Barbero profesional';
    final descripcion = barbero['descripcion']?.toString().trim();
    final experiencia = int.tryParse('${barbero['experiencia'] ?? 0}') ?? 0;
    final disponible = barbero['disponible'] != false;
    final verificado = barbero['verificacion_estado'] == 'aprobado';
    final promedio =
        (barbero['calificacion_promedio'] as num?)?.toDouble() ?? 0;
    final totalResenas = int.tryParse('${barbero['total_resenas'] ?? 0}') ?? 0;
    final distancia = double.tryParse('${barbero['distancia_km'] ?? ''}');
    final lugar = [barbero['ciudad'], barbero['zona']]
        .where((valor) => valor != null && valor.toString().trim().isNotEmpty)
        .join(', ');
    final km = _distancia(distancia);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onAbrirPerfil,
      borderColor: verificado
          ? AppColors.primary.withValues(alpha: .28)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: verificado ? AppColors.goldGradient : null,
                      color: verificado ? null : AppColors.surface,
                      border: verificado
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: AppAvatar(
                      name: nombre,
                      photoUrl: usuario['foto']?.toString(),
                      radius: 27,
                      fallbackIcon: Icons.content_cut_rounded,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: disponible ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SelloVerificado(visible: verificado),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      especialidad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    BarberosCalificacion(
                      promedio: promedio,
                      total: totalResenas,
                      compacto: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: disponible ? 'Activo' : 'Inactivo',
                color: disponible ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (lugar.isNotEmpty)
                _BarberoDato(icon: Icons.place_outlined, texto: lugar),
              if (km.isNotEmpty)
                _BarberoDato(icon: Icons.near_me_outlined, texto: km),
              if (experiencia > 0)
                _BarberoDato(
                  icon: Icons.workspace_premium_outlined,
                  texto: '$experiencia año${experiencia == 1 ? '' : 's'}',
                ),
              if (verificado)
                const _BarberoDato(
                  icon: Icons.verified_rounded,
                  texto: 'Verificado',
                  color: AppColors.primary,
                ),
            ],
          ),
          if (descripcion != null && descripcion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (puedeReservar) ...[
            const SizedBox(height: 13),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 9),
            BarberosScreenAcciones(
              disponible: disponible,
              onReservar: onReservar,
              onVerPerfil: onAbrirPerfil,
            ),
          ],
        ],
      ),
    );
  }
}

class _BarberoDato extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? color;

  const _BarberoDato({required this.icon, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    final tono = color ?? AppColors.subtitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: tono, size: 12),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: tono,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
