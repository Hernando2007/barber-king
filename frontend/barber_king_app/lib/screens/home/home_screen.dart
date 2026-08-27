import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();

  Map<String, dynamic>? usuario;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final data = await authService.obtenerUsuario();

    if (!mounted) return;

    if (data == null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);

      return;
    }

    setState(() {
      usuario = data;
      cargando = false;
    });
  }

  Future<void> cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),

          content: const Text("¿Desea cerrar sesión?"),

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
              child: const Text("Salir"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await authService.cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    final columnas = ancho > 900
        ? 4
        : ancho > 600
        ? 3
        : 2;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Barber King"),

        centerTitle: true,

        actions: [
          IconButton(onPressed: cerrarSesion, icon: const Icon(Icons.logout)),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Hola, ${usuario!["nombres"]} 👋",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    usuario!["correo"] ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    usuario!["rol"] ?? "",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: columnas,

                      crossAxisSpacing: 20,

                      mainAxisSpacing: 20,

                      children: [
                        MenuCard(
                          titulo: "Servicios",
                          icono: Icons.content_cut,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.servicios);
                          },
                        ),

                        MenuCard(
                          titulo: "Barberos",
                          icono: Icons.people,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.barberos);
                          },
                        ),

                        MenuCard(
                          titulo: "Reservar",
                          icono: Icons.calendar_month,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.citas);
                          },
                        ),

                        MenuCard(
                          titulo: "Mi Perfil",
                          icono: Icons.person,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.perfil);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,

      elevation: 8,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: onTap,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icono, size: 60, color: AppColors.primary),

            const SizedBox(height: 15),

            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
