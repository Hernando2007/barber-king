import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/disponibilidad_service.dart';
import '../../services/servicios_service.dart';

class CrearCitaScreen extends StatefulWidget {
  const CrearCitaScreen({super.key});

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final ServicioService servicioService = ServicioService();

  final BarberoService barberoService = BarberoService();

  final CitaService citaService = CitaService();

  final DisponibilidadService disponibilidadService =
      DisponibilidadService();

  List servicios = [];

  List barberos = [];

  List horarios = [];

  dynamic servicioSeleccionado;

  dynamic barberoSeleccionado;

  String? horaSeleccionada;

  DateTime fecha = DateTime.now();

  bool cargando = true;

  bool creando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final s = await servicioService.obtenerServicios();

    final b = await barberoService.obtenerBarberos();

    if (!mounted) return;

    setState(() {
      servicios = s;
      barberos = b;
      cargando = false;
    });
  }

  Future<void> consultarDisponibilidad() async {
    if (barberoSeleccionado == null ||
        servicioSeleccionado == null) {
      return;
    }

    final data =
        await disponibilidadService.consultarDisponibilidad(
      barberoId: barberoSeleccionado["id"],
      servicioId: servicioSeleccionado["id"],
      fecha: fecha.toIso8601String().split("T").first,
    );

    if (!mounted) return;

    setState(() {
      horarios = data;
      horaSeleccionada = null;
    });
  }

  Future<void> crearCita() async {
    if (horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione un horario."),
        ),
      );
      return;
    }

    setState(() {
      creando = true;
    });

    final respuesta = await citaService.crearCita(
      clienteId: 1,
      barberoId: barberoSeleccionado["id"],
      servicioId: servicioSeleccionado["id"],
      fecha: fecha.toIso8601String().split("T").first,
      hora: horaSeleccionada!,
    );

    if (!mounted) return;

    setState(() {
      creando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(respuesta["message"]),
      ),
    );

    if (respuesta["success"] == true) {
      Navigator.pop(context);
    }
  }

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Reservar Cita"),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: AppColors.primary,
                          size: 45,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            "Agenda tu cita con los mejores barberos",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  sectionTitle("Servicio"),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    value: servicioSeleccionado,

                    dropdownColor: AppColors.surface,

                    decoration: const InputDecoration(
                      hintText: "Seleccione un servicio",
                    ),

                    items: servicios.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s["nombre"],
                        ),
                      );
                    }).toList(),

                    onChanged: (v) async {
                      setState(() {
                        servicioSeleccionado = v;
                      });

                      await consultarDisponibilidad();
                    },
                  ),

                  const SizedBox(height: 25),

                  sectionTitle("Barbero"),

                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    value: barberoSeleccionado,

                    dropdownColor: AppColors.surface,

                    decoration: const InputDecoration(
                      hintText: "Seleccione un barbero",
                    ),

                    items: barberos.map((b) {
                      final usuario = b["usuarios"];

                      return DropdownMenuItem(
                        value: b,
                        child: Text(
                          "${usuario["nombres"]} ${usuario["apellidos"]}",
                        ),
                      );
                    }).toList(),

                    onChanged: (v) async {
                      setState(() {
                        barberoSeleccionado = v;
                      });

                      await consultarDisponibilidad();
                    },
                  ),

                  const SizedBox(height: 25),

                  sectionTitle("Fecha"),

                  const SizedBox(height: 10),

                  InkWell(
                    borderRadius: BorderRadius.circular(18),

                    onTap: () async {
                      final picked =
                          await showDatePicker(
                        context: context,
                        initialDate: fecha,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 90),
                        ),
                      );

                      if (picked != null) {
                        setState(() {
                          fecha = picked;
                        });

                        await consultarDisponibilidad();
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.event,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            fecha
                                .toIso8601String()
                                .split("T")
                                .first,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  sectionTitle("Horarios Disponibles"),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children: horarios.map<Widget>((h) {
                      final hora = h.toString();

                      final seleccionado =
                          horaSeleccionada == hora;

                      return ChoiceChip(
                        label: Text(hora),

                        selected: seleccionado,

                        selectedColor:
                            AppColors.primary,

                        backgroundColor:
                            AppColors.surface,

                        labelStyle: TextStyle(
                          color: seleccionado
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),

                        onSelected: (_) {
                          setState(() {
                            horaSeleccionada = hora;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed:
                          creando ? null : crearCita,

                      child: creando
                          ? const CircularProgressIndicator()
                          : const Text(
                              "CONFIRMAR RESERVA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}