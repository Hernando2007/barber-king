import 'package:flutter/material.dart';

import '../../core/colors.dart';

class CitasScreen extends StatelessWidget {
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Reservar Cita"),
      ),

      body: const Center(

        child: Text(

          "Aquí podrás reservar una cita.",

          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
          ),

        ),

      ),

    );
  }
}