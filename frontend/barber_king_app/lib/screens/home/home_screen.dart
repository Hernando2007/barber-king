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
      builder: (_) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Deseas cerrar tu sesión actual?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Salir"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await authService.cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
          onRefresh: cargarUsuario,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BARBER KING",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Hola, ${usuario?["nombres"] ?? ""}",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          usuario?["correo"] ?? "",
                          style: const TextStyle(color: AppColors.subtitle),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      onPressed: cerrarSesion,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MEMBRESÍA PREMIUM",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      usuario?["rol"] ?? "Cliente",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Reserva tus citas, administra tus servicios y disfruta de la experiencia Barber King.",
                      style: TextStyle(color: AppColors.subtitle),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const SectionTitle(titulo: "Acceso rápido"),

              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.05,
                children: [
                  PremiumMenuCard(
                    titulo: "Servicios",
                    icono: Icons.content_cut_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.servicios);
                    },
                  ),
                  PremiumMenuCard(
                    titulo: "Barberos",
                    icono: Icons.people_alt_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.barberos);
                    },
                  ),
                  PremiumMenuCard(
                    titulo: "Reservar",
                    icono: Icons.calendar_month_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.citas);
                    },
                  ),
                  PremiumMenuCard(
                    titulo: "Mi Perfil",
                    icono: Icons.person_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.perfil);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const SectionTitle(titulo: "Servicios destacados"),

              const SizedBox(height: 15),

              const HighlightCard(
                titulo: "Corte Premium",
                descripcion: "Estilo moderno con acabado profesional.",
                icono: Icons.content_cut,
              ),

              const SizedBox(height: 12),

              const HighlightCard(
                titulo: "Barba & Perfilado",
                descripcion: "Diseño preciso para una apariencia impecable.",
                icono: Icons.face_retouching_natural,
              ),

              const SizedBox(height: 12),

              const HighlightCard(
                titulo: "Experiencia VIP",
                descripcion: "Atención personalizada y servicios exclusivos.",
                icono: Icons.workspace_premium,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String titulo;

  const SectionTitle({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class PremiumMenuCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;

  const PremiumMenuCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 45, color: AppColors.primary),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HighlightCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;

  const HighlightCard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  style: const TextStyle(color: AppColors.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
