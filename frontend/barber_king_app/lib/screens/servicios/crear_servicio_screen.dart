import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';

class CrearServicioScreen extends StatefulWidget {
  const CrearServicioScreen({super.key});

  @override
  State<CrearServicioScreen> createState() => _CrearServicioScreenState();
}

class _CrearServicioScreenState extends State<CrearServicioScreen> {
  final nombreController = TextEditingController();

  final descripcionController = TextEditingController();

  final precioController = TextEditingController();

  final duracionController = TextEditingController();

  final descansoController = TextEditingController();

  final ServicioService service = ServicioService();

  bool cargando = false;

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    duracionController.dispose();
    descansoController.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (nombreController.text.trim().isEmpty ||
        precioController.text.trim().isEmpty ||
        duracionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete los campos obligatorios.")),
      );

      return;
    }

    final precio = double.tryParse(precioController.text);

    final duracion = int.tryParse(duracionController.text);

    final descanso = descansoController.text.trim().isEmpty
        ? 0
        : int.tryParse(descansoController.text);

    if (precio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Precio inválido.")));

      return;
    }

    if (duracion == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Duración inválida.")));

      return;
    }

    if (descanso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiempo de descanso inválido.")),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    final respuesta = await service.crearServicio(
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim(),
      precio: precio,
      duracion: duracion,
      tiempoDescanso: descanso,
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta["message"] ?? "Operación realizada.")),
    );

    if (respuesta["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Crear Servicio")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Card(
          color: AppColors.card,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    prefixIcon: Icon(Icons.content_cut),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    prefixIcon: Icon(Icons.description),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Precio",
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: duracionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Duración (min)",
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: descansoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Tiempo descanso",
                    prefixIcon: Icon(Icons.free_breakfast),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: cargando ? null : guardar,

                    child: cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("GUARDAR SERVICIO"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
