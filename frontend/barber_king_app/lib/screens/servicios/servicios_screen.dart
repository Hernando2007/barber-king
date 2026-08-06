import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../models/servicio.dart';
import '../../services/servicios_service.dart';
import '../../widgets/servicios/buscador_servicios.dart';
import '../../widgets/servicios/servicio_card.dart';
import '../../routes/app_routes.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {

  final ServiciosService service = ServiciosService();

  final TextEditingController buscarController =
      TextEditingController();

  List<Servicio> servicios = [];
  List<Servicio> filtrados = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarServicios();
  }

  Future<void> cargarServicios() async {

    setState(() {
      cargando = true;
    });

    try {

      servicios = await service.obtenerServicios();

      filtrados = List.from(servicios);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

  }

  void buscar(String texto) {

    setState(() {

      filtrados = servicios.where((servicio) {

        return servicio.nombre
            .toLowerCase()
            .contains(texto.toLowerCase());

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Servicios"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {

  final actualizado =
      await Navigator.pushNamed(
    context,
    AppRoutes.crearServicio,
  );

  if (actualizado == true) {
    cargarServicios();
  }

},
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),

      body: RefreshIndicator(

        onRefresh: cargarServicios,

        child: Column(

          children: [

            Padding(

              padding: const EdgeInsets.all(15),

              child: BuscadorServicios(

                controller: buscarController,

                onChanged: buscar,

              ),

            ),

            Expanded(

              child: cargando

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : filtrados.isEmpty

                      ? const Center(

                          child: Text(
                            "No hay servicios.",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                        )

                      : ListView.builder(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),

                          itemCount: filtrados.length,

                          itemBuilder: (context, index) {

                            final servicio =
                                filtrados[index];

                            return ServicioCard(

                              servicio: servicio,

                              onEditar: () {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(

                                  SnackBar(

                                    content: Text(
                                      "Editar ${servicio.nombre}",
                                    ),

                                  ),

                                );

                              },

                              onEliminar: () {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(

                                  SnackBar(

                                    content: Text(
                                      "Eliminar ${servicio.nombre}",
                                    ),

                                  ),

                                );

                              },

                            );

                          },

                        ),

            ),

          ],

        ),

      ),

    );

  }

}