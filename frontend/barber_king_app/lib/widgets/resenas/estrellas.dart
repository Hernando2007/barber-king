import 'package:flutter/material.dart';

import '../../core/colors.dart';

class Estrellas extends StatelessWidget {
  final double valor;
  final double tamano;

  const Estrellas({super.key, required this.valor, this.tamano = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (indice) {
        final llena = indice + 1 <= valor.round();

        return Icon(
          llena ? Icons.star_rounded : Icons.star_outline_rounded,
          size: tamano,
          color: llena ? AppColors.primary : AppColors.borderStrong,
        );
      }),
    );
  }
}

class EstrellasInput extends StatelessWidget {
  final int valor;
  final ValueChanged<int>? onChanged;
  final double tamano;

  const EstrellasInput({
    super.key,
    required this.valor,
    this.onChanged,
    this.tamano = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (indice) {
        final posicion = indice + 1;
        final activa = posicion <= valor;

        return InkWell(
          onTap: onChanged == null ? null : () => onChanged!(posicion),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: Icon(
              activa ? Icons.star_rounded : Icons.star_outline_rounded,
              size: tamano,
              color: activa ? AppColors.primary : AppColors.borderStrong,
            ),
          ),
        );
      }),
    );
  }
}
