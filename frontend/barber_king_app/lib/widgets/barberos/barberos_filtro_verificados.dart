import 'package:flutter/material.dart';

import '../../core/colors.dart';
import 'barberos_pildora.dart';

/// Filtro rápido por sello de verificación, con contadores para saber de un
/// vistazo cuántos barberos del equipo están verificados.
class BarberosFiltroVerificados extends StatelessWidget {
  final bool soloVerificados;
  final int total;
  final int verificados;
  final ValueChanged<bool> onCambiar;

  const BarberosFiltroVerificados({
    super.key,
    required this.soloVerificados,
    required this.total,
    required this.verificados,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VERIFICACIÓN',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              BarberosPildora(
                label: 'Todos',
                seleccionado: !soloVerificados,
                conteo: total,
                onTap: () => onCambiar(false),
              ),
              BarberosPildora(
                label: 'Verificados',
                seleccionado: soloVerificados,
                conteo: verificados,
                icono: Icons.verified_rounded,
                onTap: () => onCambiar(true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
