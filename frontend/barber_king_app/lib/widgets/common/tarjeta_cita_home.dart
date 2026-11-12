import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import 'app_card.dart';
import 'status_pill.dart';

/// Tarjeta compacta de cita con el diseño de Reservas: bloque de fecha a la
/// izquierda, estado, datos rápidos y una zona opcional para acciones.
class TarjetaCitaHome extends StatelessWidget {
  final Map<String, dynamic> cita;
  final String titulo;
  final String? subtitulo;
  final Widget? pie;
  final VoidCallback? onTap;
  final bool mostrarPrecio;

  const TarjetaCitaHome({
    super.key,
    required this.cita,
    required this.titulo,
    this.subtitulo,
    this.pie,
    this.onTap,
    this.mostrarPrecio = true,
  });

  @override
  Widget build(BuildContext context) {
    final servicio = cita['servicios'];
    final estado = '${cita['estado'] ?? 'Confirmada'}';
    final estadoLower = estado.toLowerCase();
    final activa = estadoLower == 'confirmada' || estadoLower == 'pendiente';
    final relativo = AppFormat.relativeDay(cita['fecha']);
    final precio = servicio is Map ? AppFormat.money(servicio['precio']) : '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      borderColor: activa
          ? AppColors.primary.withValues(alpha: .28)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FechaCita(
                dia: AppFormat.dayNumber(cita['fecha']),
                mes: AppFormat.monthShort(cita['fecha']),
                activa: activa,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo.isEmpty ? 'Reserva' : titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          label: estado,
                          color: AppFormat.statusColor(estado),
                        ),
                      ],
                    ),
                    if (subtitulo != null && subtitulo!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Dato(
                          icon: Icons.schedule_rounded,
                          texto: AppFormat.time(cita['hora']),
                        ),
                        if (mostrarPrecio && precio.isNotEmpty)
                          _Dato(
                            icon: Icons.payments_outlined,
                            texto: precio,
                          ),
                        if (relativo.isNotEmpty)
                          _Dato(
                            icon: Icons.today_rounded,
                            texto: relativo,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pie != null) ...[
            const SizedBox(height: 13),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            pie!,
          ],
        ],
      ),
    );
  }
}

class _FechaCita extends StatelessWidget {
  final String dia;
  final String mes;
  final bool activa;

  const _FechaCita({
    required this.dia,
    required this.mes,
    required this.activa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: activa
            ? AppColors.primary.withValues(alpha: .1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activa
              ? AppColors.primary.withValues(alpha: .3)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            dia,
            style: TextStyle(
              color: activa ? AppColors.primary : AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            mes,
            style: TextStyle(
              color: activa ? AppColors.primary : AppColors.muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? color;

  const _Dato({required this.icon, required this.texto, this.color});

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
