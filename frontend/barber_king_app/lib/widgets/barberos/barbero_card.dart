import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BarberCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onReserve;

  const BarberCard({
    super.key,
    required this.data,
    this.onReserve,
  });

  Map<String, dynamic> get usuario {
    final value = data['usuarios'];
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  String get nombre {
    final nombres = usuario['nombres']?.toString().trim() ?? '';
    final apellidos = usuario['apellidos']?.toString().trim() ?? '';
    final value = '$nombres $apellidos'.trim();
    return value.isEmpty ? 'Barbero profesional' : value;
  }

  String get correo => usuario['correo']?.toString() ?? '';

  double get promedio => double.tryParse('${data['calificacion_promedio'] ?? 0}') ?? 0;

  int get totalResenas => int.tryParse('${data['total_resenas'] ?? 0}') ?? 0;

  String get especialidad =>
      data['especialidad']?.toString().trim().isNotEmpty == true
          ? data['especialidad'].toString()
          : 'Barbero profesional';

  String get inicial {
    final value = nombre.trim();
    return value.isEmpty ? 'B' : value.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(initial: inicial),
                const SizedBox(width: 15),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        correo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Specialty(value: especialidad),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.star, color: AppColors.primary, size: 20), const SizedBox(width: 6), Text(promedio == 0 ? 'Sin calificaciones' : promedio.toStringAsFixed(1), style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)), const SizedBox(width: 6), Text('($totalResenas reseñas)', style: const TextStyle(color: AppColors.subtitle))]),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onReserve ?? () => Navigator.pop(context),
                icon: const Icon(Icons.calendar_month),
                label: const Text('RESERVAR CITA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Specialty extends StatelessWidget {
  final String value;

  const _Specialty({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
