import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../common/app_ui.dart';

class ChatContactosCard extends StatelessWidget {
  final Map<String, dynamic> contacto;
  final VoidCallback onTap;

  const ChatContactosCard({
    super.key,
    required this.contacto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nombre =
        '${contacto['nombres'] ?? ''} ${contacto['apellidos'] ?? ''}'.trim();
    final ultimo = contacto['ultimo_mensaje'];
    final ultimoMap = ultimo is Map ? Map<String, dynamic>.from(ultimo) : null;
    final mensaje = ultimoMap == null
        ? 'Inicia la conversación'
        : (ultimoMap['mensaje']?.toString().isNotEmpty == true
              ? ultimoMap['mensaje'].toString()
              : 'Imagen enviada');
    final fecha = ultimoMap?['created_at'];
    final especialidad = contacto['especialidad']?.toString();
    final esBarbero = int.tryParse('${contacto['rol_id']}') == 2;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(
            name: nombre.isEmpty ? 'Usuario' : nombre,
            photoUrl: contacto['foto']?.toString(),
            radius: 24,
            fallbackIcon:
                esBarbero ? Icons.content_cut_rounded : Icons.person_rounded,
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
                        nombre.isEmpty ? 'Usuario' : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (fecha != null)
                      Text(
                        AppFormat.date(fecha),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  especialidad != null && especialidad.isNotEmpty
                      ? especialidad
                      : '${contacto['rol'] ?? (esBarbero ? 'Barbero' : 'Cliente')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mensaje,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ultimoMap == null
                        ? AppColors.muted
                        : AppColors.subtitle,
                    fontSize: 11.5,
                    fontStyle: ultimoMap == null
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
