import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/cita_service.dart';
import 'crear_cita_screen.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService service = CitaService();

  List<dynamic> citas = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  Future<void> cargarCitas() async {
    final data = await service.obtenerCitas();

    if (!mounted) return;

    setState(() {
      citas = data;
      cargando = false;
    });
  }

  Future<void> eliminar(int id) async {
    final respuesta = await service.eliminarCita(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(respuesta["message"])));

    if (respuesta["success"] == true) {
      cargarCitas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Citas")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearCitaScreen()),
          ).then((_) => cargarCitas());
        },
        child: const Icon(Icons.add),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: citas.length,

              itemBuilder: (context, index) {
                final cita = citas[index];

                final cliente = cita["usuarios"];

                final servicio = cita["servicios"];

                return Card(
                  color: AppColors.surface,

                  margin: const EdgeInsets.all(10),

                  child: ListTile(
                    title: Text(
                      cliente == null
                          ? "Cliente"
                          : "${cliente["nombres"]} ${cliente["apellidos"]}",
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          servicio?["nombre"] ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        Text(
                          "${cita["fecha"]} ${cita["hora"]}",
                          style: const TextStyle(color: AppColors.primary),
                        ),

                        Text(
                          cita["estado"] ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        eliminar(cita["id"]);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
