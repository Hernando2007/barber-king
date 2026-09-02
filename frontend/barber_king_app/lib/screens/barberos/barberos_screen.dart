import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';

class BarberosScreen extends StatefulWidget {
  const BarberosScreen({super.key});

  @override
  State<BarberosScreen> createState() => _BarberosScreenState();
}

class _BarberosScreenState extends State<BarberosScreen> {
  final BarberoService service = BarberoService();

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

    final data = await service.obtenerBarberos();

    if (!mounted) return;

    setState(() {
      barberos = data;
      cargando = false;
    });
  }

  Widget barberCard(
    Map<String, dynamic> usuario,
    Map<String, dynamic> barbero,
  ) {
    final nombre = "${usuario["nombres"] ?? ""} ${usuario["apellidos"] ?? ""}";

    final correo = usuario["correo"] ?? "";

    final especialidad = barbero["especialidad"] ?? "Barbero profesional";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      nombre.isNotEmpty ? nombre[0] : "B",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        correo,
                        style: const TextStyle(color: AppColors.subtitle),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: AppColors.primary),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      especialidad,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("RESERVAR CITA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: cargarBarberos,
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
                      "Nuestros Barberos",
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
                "Profesionales especializados para brindarte la mejor experiencia.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtitle),
              ),

              const SizedBox(height: 30),

              if (barberos.isEmpty)
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
                        Icons.people_alt,
                        size: 70,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "No hay barberos disponibles",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ...barberos.map((barbero) {
                final usuario = barbero["usuarios"];

                return barberCard(usuario, barbero);
              }),
            ],
          ),
        ),
      ),
    );
  }
}