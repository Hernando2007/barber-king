import 'package:flutter/material.dart';

import '../../core/colors.dart';

import '../../services/barbero_service.dart';
import '../../services/servicios_service.dart';
import '../../services/cita_service.dart';
import '../../services/disponibilidad_service.dart';

class CrearCitaScreen extends StatefulWidget {
  const CrearCitaScreen({super.key});

  @override
  State<CrearCitaScreen> createState() =>
      _CrearCitaScreenState();
}

class _CrearCitaScreenState
    extends State<CrearCitaScreen> {
  final ServicioService servicioService =
      ServicioService();

  final BarberoService barberoService =
      BarberoService();

  final CitaService citaService =
      CitaService();

  final DisponibilidadService
      disponibilidadService =
      DisponibilidadService();

  List servicios = [];

  List barberos = [];

  List horarios = [];

  dynamic servicioSeleccionado;

  dynamic barberoSeleccionado;

  String? horaSeleccionada;

  DateTime fecha =
      DateTime.now();

  bool cargando = true;

  bool creando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final s =
        await servicioService.obtenerServicios();

    final b =
        await barberoService.obtenerBarberos();

    if (!mounted) return;

    setState(() {
      servicios = s;
      barberos = b;
      cargando = false;
    });
  }

  Future<void> consultarDisponibilidad()
  async {
    if (barberoSeleccionado == null ||
        servicioSeleccionado == null) {
      return;
    }

    final data =
        await disponibilidadService
            .consultarDisponibilidad(
      barberoId:
          barberoSeleccionado["id"],
      servicioId:
          servicioSeleccionado["id"],
      fecha:
          fecha
              .toIso8601String()
              .split("T")
              .first,
    );

    if (!mounted) return;

    setState(() {
      horarios = data;
      horaSeleccionada = null;
    });
  }

  Future<void> crearCita() async {
    if (horaSeleccionada == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Seleccione un horario",
          ),
        ),
      );

      return;
    }

    setState(() {
      creando = true;
    });

    final respuesta =
        await citaService.crearCita(
      clienteId: 1,
      barberoId:
          barberoSeleccionado["id"],
      servicioId:
          servicioSeleccionado["id"],
      fecha:
          fecha
              .toIso8601String()
              .split("T")
              .first,
      hora: horaSeleccionada!,
    );

    if (!mounted) return;

    setState(() {
      creando = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          respuesta["message"],
        ),
      ),
    );

    if (respuesta["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title:
            const Text("Nueva cita"),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [

                  DropdownButtonFormField(
                    value:
                        servicioSeleccionado,
                    items: servicios.map(
                      (s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s["nombre"],
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (v) async {
                      setState(() {
                        servicioSeleccionado =
                            v;
                      });

                      await consultarDisponibilidad();
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Servicio",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  DropdownButtonFormField(
                    value:
                        barberoSeleccionado,
                    items: barberos.map(
                      (b) {
                        final usuario =
                            b["usuarios"];

                        return DropdownMenuItem(
                          value: b,
                          child: Text(
                            "${usuario["nombres"]} ${usuario["apellidos"]}",
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (v) async {
                      setState(() {
                        barberoSeleccionado =
                            v;
                      });

                      await consultarDisponibilidad();
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Barbero",
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ListTile(
                    title: Text(
                      fecha
                          .toIso8601String()
                          .split("T")
                          .first,
                    ),
                    trailing: const Icon(
                      Icons.calendar_month,
                    ),
                    onTap: () async {
                      final picked =
                          await showDatePicker(
                        context: context,
                        initialDate:
                            fecha,
                        firstDate:
                            DateTime.now(),
                        lastDate:
                            DateTime.now()
                                .add(
                          const Duration(
                            days: 90,
                          ),
                        ),
                      );

                      if (picked != null) {
                        setState(() {
                          fecha = picked;
                        });

                        await consultarDisponibilidad();
                      }
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      "Horarios disponibles",
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        horarios.map<Widget>(
                      (h) {
                        final hora =
                            h.toString();

                        return ChoiceChip(
                          label:
                              Text(hora),
                          selected:
                              horaSeleccionada ==
                                  hora,
                          onSelected: (_) {
                            setState(() {
                              horaSeleccionada =
                                  hora;
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed:
                          creando
                              ? null
                              : crearCita,
                      child:
                          creando
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "Reservar cita",
                                ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}