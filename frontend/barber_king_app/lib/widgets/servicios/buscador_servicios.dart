import 'package:flutter/material.dart';

class BuscadorServicios extends StatelessWidget {

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const BuscadorServicios({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(

      controller: controller,

      onChanged: onChanged,

      decoration: InputDecoration(

        hintText: "Buscar servicio...",

        prefixIcon: const Icon(Icons.search),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),

      ),

    );

  }

}