import 'package:flutter/material.dart';

import '../../core/colors.dart';

class CitaCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final VoidCallback? onDelete;
  final VoidCallback? onRate;

  const CitaCard({
    super.key,
    required this.cita,
    this.onDelete,
    this.onRate,
  });

  String _texto(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Widget _dato(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = cita['usuarios'];
    final servicio = cita['servicios'];
    final nombreCliente = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : 'Cliente';
    final nombreServicio = servicio is Map
        ? _texto(servicio['nombre'], 'Servicio')
        : 'Servicio';
    final estado = _texto(cita['estado'], 'Pendiente');
    final color = _estadoColor(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primary.withValues(alpha: .15),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCliente.isEmpty
                          ? 'Cliente'
                          : nombreCliente,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nombreServicio,
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
          Row(
            children: [
              _dato(
                'FECHA',
                _texto(cita['fecha'], '-'),
              ),
              const SizedBox(width: 12),
              _dato(
                'HORA',
                _texto(cita['hora'], '-'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        estado,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onRate != null) ...[
                IconButton(onPressed: onRate, tooltip: 'Calificar', icon: const Icon(Icons.star_border, color: AppColors.primary)),
                const SizedBox(width: 4),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Eliminar cita',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
