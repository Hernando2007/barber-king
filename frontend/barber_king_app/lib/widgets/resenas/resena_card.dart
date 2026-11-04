import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../common/app_ui.dart';
import 'estrellas.dart';

class ResenaCard extends StatelessWidget {
  final Map<String, dynamic> resena;

  const ResenaCard({super.key, required this.resena});

  @override
  Widget build(BuildContext context) {
    final cliente = resena['usuarios'] is Map
        ? Map<String, dynamic>.from(resena['usuarios'] as Map)
        : <String, dynamic>{};
    final nombre =
        '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim();
    final foto = cliente['foto']?.toString();
    final calificacion = int.tryParse('${resena['calificacion'] ?? 0}') ?? 0;
    final comentario = resena['comentario']?.toString().trim();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: nombre.isEmpty ? 'Cliente' : nombre,
                photoUrl: foto,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.isEmpty ? 'Cliente' : nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormat.date(resena['created_at']),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Estrellas(valor: calificacion.toDouble()),
            ],
          ),
          if (comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comentario,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
