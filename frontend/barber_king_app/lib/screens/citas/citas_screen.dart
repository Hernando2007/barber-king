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
    setState(() {
      cargando = true;
    });

    final data = await service.obtenerCitas();

    if (!mounted) return;

    setState(() {
      citas = data;
      cargando = false;
    });
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Eliminar cita"),
          content: const Text("¿Deseas eliminar esta cita?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final respuesta = await service.eliminarCita(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(respuesta["message"])));

    if (respuesta["success"] == true) {
      cargarCitas();
    }
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case "confirmada":
        return AppColors.success;

      case "cancelada":
        return AppColors.error;

      default:
        return AppColors.primary;
    }
  }

  Widget citaCard(Map<String, dynamic> cita) {
    final cliente = cita["usuarios"];

    final servicio = cita["servicios"];

    final nombreCliente = cliente == null
        ? "Cliente"
        : "${cliente["nombres"]} ${cliente["apellidos"]}";

    final nombreServicio = servicio?["nombre"] ?? "Servicio";

    final estado = cita["estado"] ?? "Pendiente";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreCliente,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        nombreServicio,
                        style: const TextStyle(color: AppColors.subtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "FECHA",
                          style: TextStyle(
                            color: AppColors.subtitle,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          cita["fecha"]?.toString() ?? "",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "HORA",
                          style: TextStyle(
                            color: AppColors.subtitle,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          cita["hora"]?.toString() ?? "",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado(estado).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: colorEstado(estado),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          estado,
                          style: TextStyle(
                            color: colorEstado(estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                IconButton(
                  onPressed: () {
                    eliminar(cita["id"]);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearCitaScreen()),
          );

          cargarCitas();
        },
        icon: const Icon(Icons.add),
        label: const Text("Nueva cita"),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: cargarCitas,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primary,
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            "Mis Citas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Administra todas tus reservas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtitle),
                    ),

                    const SizedBox(height: 30),

                    if (citas.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 70,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "No tienes citas registradas",
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ...citas.map((cita) => citaCard(cita)),
                  ],
                ),
              ),
            ),
    );
  }
}
