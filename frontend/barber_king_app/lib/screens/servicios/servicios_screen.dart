import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServiciosService service = ServiciosService();

  List servicios = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarServicios();
  }

  Future<void> cargarServicios() async {
    servicios = await service.obtenerServicios();

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Servicios"),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: servicios.length,

              itemBuilder: (context, index) {
                final servicio = servicios[index];

                return Card(
                  color: AppColors.surface,

                  margin: const EdgeInsets.all(10),

                  child: ListTile(
                    leading: const Icon(
                      Icons.content_cut,
                      color: AppColors.primary,
                    ),

                    title: Text(
                      servicio["nombre"],
                      style: const TextStyle(
                        color: AppColors.white,
                      ),
                    ),

                    subtitle: Text(
                      "${servicio["duracion"]} minutos",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    trailing: Text(
                      "\$ ${servicio["precio"]}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}