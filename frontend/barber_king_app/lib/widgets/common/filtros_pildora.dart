import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Píldora de filtro con el mismo estilo de la pestaña Reservas: dorada
/// cuando está activa, oscura cuando no, con contador opcional.
class PildoraFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final int? conteo;
  final VoidCallback onTap;

  const PildoraFiltro({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.conteo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: seleccionado ? AppColors.goldGradient : null,
            color: seleccionado ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: seleccionado ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: seleccionado ? AppColors.black : AppColors.subtitle,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (conteo != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.black.withValues(alpha: .16)
                        : AppColors.backgroundSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$conteo',
                    style: TextStyle(
                      color: seleccionado ? AppColors.black : AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila horizontal de píldoras. Se desplaza de lado cuando no caben.
class FilaPildorasFiltro extends StatelessWidget {
  final List<String> opciones;
  final String seleccionada;
  final Map<String, int>? conteos;
  final ValueChanged<String> onSeleccionar;

  const FilaPildorasFiltro({
    super.key,
    required this.opciones,
    required this.seleccionada,
    required this.onSeleccionar,
    this.conteos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opcion in opciones)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PildoraFiltro(
                label: opcion,
                seleccionado: seleccionada == opcion,
                conteo: conteos?[opcion],
                onTap: () => onSeleccionar(opcion),
              ),
            ),
        ],
      ),
    );
  }
}
