import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../common/app_ui.dart';
import 'barberos_calificacion.dart';

class BarberosDestacadosPanel extends StatelessWidget {
  final List<Map<String, dynamic>> barberos;

  const BarberosDestacadosPanel({super.key, required this.barberos});

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

  String _lugar(Map<String, dynamic> barbero) {
    return [barbero['ciudad'], barbero['zona']]
        .where((valor) => valor != null && valor.toString().trim().isNotEmpty)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (barberos.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibles = barberos.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mejor calificados',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Elegidos por los clientes',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...visibles.asMap().entries.map((entry) {
              final posicion = entry.key + 1;
              final barbero = entry.value;
              final usuario = _usuario(barbero);
              final promedio =
                  (barbero['calificacion_promedio'] as num?)?.toDouble() ?? 0;
              final total =
                  int.tryParse('${barbero['total_resenas'] ?? 0}') ?? 0;
              final lugar = _lugar(barbero);

              return Padding(
                padding: EdgeInsets.only(top: posicion == 1 ? 0 : 12),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: posicion == 1
                            ? AppColors.primary
                            : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$posicion',
                        style: TextStyle(
                          color: posicion == 1
                              ? AppColors.black
                              : AppColors.subtitle,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    AppAvatar(
                      name: _nombre(barbero),
                      photoUrl: usuario['foto']?.toString() ??
                          barbero['foto_trabajo']?.toString(),
                      radius: 18,
                      fallbackIcon: Icons.content_cut_rounded,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nombre(barbero),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (lugar.isNotEmpty)
                            Text(
                              lugar,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    BarberosCalificacion(
                      promedio: promedio,
                      total: total,
                      compacto: true,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
