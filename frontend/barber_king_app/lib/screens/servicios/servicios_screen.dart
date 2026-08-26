import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import 'crear_servicio_screen.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({
    super.key,
  });

  @override
  State<ServiciosScreen> createState() =>
      _ServiciosScreenState();
}

class _ServiciosScreenState
    extends State<ServiciosScreen> {

  final ServicioService service =
      ServicioService();

  List<dynamic> servicios = [];

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

    final data =
        await service.obtenerServicios();

    if (!mounted) return;

    setState(() {
      servicios = data;
      cargando = false;
    });
  }

  Future<void> eliminar(
    int id,
  ) async {

    final respuesta =
        await service.eliminarServicio(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          respuesta["message"],
        ),
      ),
    );

    if (respuesta["success"] == true) {
      cargarServicios();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Servicios",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CrearServicioScreen(),
            ),
          );

          cargarServicios();
        },
        child: const Icon(Icons.add),
      ),

      body: cargando

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : RefreshIndicator(
              onRefresh:
                  cargarServicios,

              child: ListView.builder(
                itemCount:
                    servicios.length,

                itemBuilder:
                    (context, index) {

                  final servicio =
                      servicios[index];

                  return Card(
                    color:
                        AppColors.surface,

                    margin:
                        const EdgeInsets.all(
                      10,
                    ),

                    child: ListTile(

                      title: Text(
                        servicio["nombre"],
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            servicio["descripcion"] ??
                                "",
                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            "\$${servicio["precio"]}",
                            style:
                                const TextStyle(
                              color:
                                  AppColors.primary,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            "${servicio["duracion"]} min",
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      trailing:
                          IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            eliminar(
                          servicio["id"],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}