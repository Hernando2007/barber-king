import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';

class CrearServicioScreen extends StatefulWidget {
  const CrearServicioScreen({super.key});

  @override
  State<CrearServicioScreen> createState() =>
      _CrearServicioScreenState();
}

class _CrearServicioScreenState
    extends State<CrearServicioScreen> {

  final ServiciosService service = ServiciosService();

  final nombreController = TextEditingController();
  final descripcionController =
      TextEditingController();
  final precioController = TextEditingController();
  final duracionController =
      TextEditingController();
  final descansoController =
      TextEditingController();

  bool cargando = false;

  Future<void> guardar() async {

    if (nombreController.text.isEmpty ||
        precioController.text.isEmpty ||
        duracionController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Complete los campos obligatorios.",
          ),
        ),
      );

      return;

    }

    setState(() {
      cargando = true;
    });

    final ok = await service.crearServicio(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      precio: double.parse(precioController.text),
      duracion: int.parse(duracionController.text),
      tiempoDescanso: descansoController.text.isEmpty
          ? 0
          : int.parse(descansoController.text),
    );

    setState(() {
      cargando = false;
    });

    if (!mounted) return;

    if (ok) {

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No fue posible guardar.",
          ),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Nuevo Servicio"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: "Descripción",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: precioController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Precio",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: duracionController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duración (min)",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descansoController,
              keyboardType:
                  TextInputType.number,
              decoration: const InputDecoration(
                labelText:
                    "Tiempo descanso",
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                onPressed:
                    cargando ? null : guardar,

                child: cargando

                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )

                    : const Text(
                        "GUARDAR",
                      ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}