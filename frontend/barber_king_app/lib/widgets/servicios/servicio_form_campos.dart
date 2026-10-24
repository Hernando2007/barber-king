import 'package:flutter/material.dart';

class ServicioFormCampos extends StatelessWidget {
  final TextEditingController precio;
  final TextEditingController duracion;
  final TextEditingController descanso;

  const ServicioFormCampos({
    super.key,
    required this.precio,
    required this.duracion,
    required this.descanso,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: precio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final precio =
                      double.tryParse((value ?? '').replaceAll(',', '.'));
                  if (precio == null || precio <= 0) {
                    return 'Precio inválido.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: duracion,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  suffixText: 'min',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  final duracion = int.tryParse(value?.trim() ?? '');
                  if (duracion == null || duracion <= 0) {
                    return 'Duración inválida.';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descanso,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Tiempo de descanso',
            suffixText: 'min',
            prefixIcon: Icon(Icons.coffee_outlined),
            helperText: 'Tiempo entre citas. Opcional.',
          ),
        ),
      ],
    );
  }
}
