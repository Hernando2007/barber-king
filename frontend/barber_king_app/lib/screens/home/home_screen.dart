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

              // CORRECCIÓN: Ahora son 4 elementos en la cuadrícula, dejando el espacio libre
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
            ],
          ),
        ),
      ),

      // AGREGADO: Botón Flotante con estilo Premium acorde al diseño de Barber King
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.black),
        label: const Text(
          "Asistente IA",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // El token se resolverá de forma independiente dentro del ChatIAScreen (Opción B del paso anterior)
          Navigator.pushNamed(context, AppRoutes.chatIA);
        },
      ),
    );
  }
}

// Clases auxiliares para que no marque error el código al compilar
class SectionTitle extends StatelessWidget {
  final String titulo;
  const SectionTitle({super.key, required this.titulo});
  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 18,
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
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: AppColors.primary, size: 35),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
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
  build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.primary),
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
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
