import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';

class BarberosScreen extends StatefulWidget {
  const BarberosScreen({
    super.key,
  });

  @override
  State<BarberosScreen> createState() =>
      _BarberosScreenState();
}

class _BarberosScreenState
    extends State<BarberosScreen> {

  final BarberoService service =
      BarberoService();

  List<dynamic> barberos = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarBarberos();
  }

  Future<void> cargarBarberos() async {

    setState(() {
      cargando = true;
    });

    final data =
        await service.obtenerBarberos();

    if (!mounted) return;

    setState(() {
      barberos = data;
      cargando = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Barberos",
        ),
      ),

      body: cargando

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : RefreshIndicator(
              onRefresh:
                  cargarBarberos,

              child: ListView.builder(
                itemCount:
                    barberos.length,

                itemBuilder:
                    (context, index) {

                  final barbero =
                      barberos[index];

                  final usuario =
                      barbero["usuarios"];

                  return Card(
                    color:
                        AppColors.surface,

                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),

                    child: ListTile(

                      leading:
                          CircleAvatar(

                        backgroundColor:
                            AppColors.primary,

                        child: Text(
                          usuario["nombres"]
                              .toString()
                              .substring(
                                0,
                                1,
                              ),
                        ),
                      ),

                      title: Text(
                        "${usuario["nombres"]} ${usuario["apellidos"]}",
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
                            usuario["correo"]
                                .toString(),
                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            barbero["especialidad"] ??
                                "Sin especialidad",
                            style:
                                const TextStyle(
                              color:
                                  AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}