import 'package:flutter/material.dart';

import '../../core/colors.dart';

class BarberosScreen extends StatelessWidget {
  const BarberosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Barberos"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: const [

          BarberoCard(
            nombre: "Carlos Pérez",
            especialidad: "Fade • Barba",
          ),

          BarberoCard(
            nombre: "Juan Gómez",
            especialidad: "Corte Clásico",
          ),

        ],
      ),
    );
  }
}

class BarberoCard extends StatelessWidget {

  final String nombre;
  final String especialidad;

  const BarberoCard({
    super.key,
    required this.nombre,
    required this.especialidad,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      color: AppColors.surface,

      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(

        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),

        title: Text(
          nombre,
          style: const TextStyle(color: AppColors.white),
        ),

        subtitle: Text(
          especialidad,
          style: const TextStyle(color: Colors.white70),
        ),

      ),

    );
  }
}