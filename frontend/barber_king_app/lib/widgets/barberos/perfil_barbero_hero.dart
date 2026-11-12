import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';
import 'barberos_calificacion.dart';
import 'sello_verificado.dart';

/// La tarjeta grande del perfil: quién es, dónde trabaja y sus números.
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
    final chips = [
      if (lugar.isNotEmpty)
        (Icons.place_outlined, lugar, AppColors.primary),
      if (_distanciaTexto.isNotEmpty)
        (Icons.near_me_outlined, _distanciaTexto, AppColors.info),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      radius: 24,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              height: 92,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -16,
                    top: -28,
                    child: Icon(
                      Icons.content_cut_rounded,
                      size: 140,
                      color: AppColors.primary.withValues(alpha: .06),
                    ),
                  ),
                  const Positioned(
                    left: 18,
                    top: 16,
                    child: Text(
                      'BARBERO PROFESIONAL',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 14,
                    child: StatusPill(
                      label: disponible ? 'Disponible' : 'No disponible',
                      color: disponible
                          ? AppColors.success
                          : AppColors.muted,
                      icon: disponible
                          ? Icons.storefront
                          : Icons.storefront_outlined,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -34),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.card,
                              width: 2,
                            ),
                          ),
                          child: AppAvatar(
                            name: nombre,
                            photoUrl: foto,
                            radius: 36,
                            fallbackIcon: Icons.content_cut_rounded,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nombre,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                    SelloVerificado(
                                      visible: verificado,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  especialidad,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                BarberosCalificacion(
                                  promedio: promedio,
                                  total: totalResenas,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          for (final chip in chips)
                            _HeroChip(
                              icon: chip.$1,
                              texto: chip.$2,
                              color: chip.$3,
                            ),
                        ],
                      ),
                    ],
                    if (descripcion != null &&
                        descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        descripcion!,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: .8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _HeroStat(
                              valor: totalResenas == 0
                                  ? '0.0'
                                  : promedio.toStringAsFixed(1),
                              label: 'Calificación',
                            ),
                          ),
                          const _HeroDivisor(),
                          Expanded(
                            child: _HeroStat(
                              valor: '$totalResenas',
                              label: totalResenas == 1
                                  ? 'Reseña'
                                  : 'Reseñas',
                            ),
                          ),
                          const _HeroDivisor(),
                          Expanded(
                            child: _HeroStat(
                              valor: '$experiencia',
                              label: experiencia == 1
                                  ? 'Año'
                                  : 'Años',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color color;

  const _HeroChip({
    required this.icon,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String valor;
  final String label;

  const _HeroStat({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9.5,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }
}

class _HeroDivisor extends StatelessWidget {
  const _HeroDivisor();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border,
    );
  }
}
