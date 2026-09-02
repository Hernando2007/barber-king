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
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Eliminar servicio",
          ),
          content: const Text(
            "¿Deseas eliminar este servicio?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancelar",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Eliminar",
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

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

  Widget servicioCard(
    Map<String, dynamic> servicio,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color:
                        AppColors.primary,
                    size: 30,
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        servicio["nombre"] ??
                            "",
                        style:
                            const TextStyle(
                          color:
                              AppColors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        servicio["descripcion"] ??
                            "Servicio profesional Barber King",
                        style:
                            const TextStyle(
                          color: AppColors
                              .subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.surface,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "PRECIO",
                          style:
                              TextStyle(
                            color: AppColors
                                .subtitle,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "\$${servicio["precio"]}",
                          style:
                              const TextStyle(
                            color: AppColors
                                .primary,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.surface,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "DURACIÓN",
                          style:
                              TextStyle(
                            color: AppColors
                                .subtitle,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${servicio["duracion"]} min",
                          style:
                              const TextStyle(
                            color: AppColors
                                .white,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  eliminar(
                    servicio["id"],
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  "ELIMINAR SERVICIO",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            AppColors.black,
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
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          "Nuevo",
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: cargarServicios,
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      "Servicios",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            AppColors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Explora nuestros servicios premium disponibles.",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AppColors.subtitle,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              if (servicios.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.all(
                    30,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.card,
                    borderRadius:
                        BorderRadius
                            .circular(
                      22,
                    ),
                    border: Border.all(
                      color: AppColors
                          .border,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.content_cut,
                        size: 70,
                        color: AppColors
                            .primary,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "No hay servicios registrados",
                        style:
                            TextStyle(
                          color:
                              AppColors
                                  .white,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ...servicios.map(
                (servicio) =>
                    servicioCard(
                  servicio,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}