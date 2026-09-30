import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class ClienteHomeScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const ClienteHomeScreen({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = usuario['nombres']?.toString() ?? 'Cliente';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(context, nombre),
            const SizedBox(height: 22),
            _welcomeCard(),
            const SizedBox(height: 28),
            const _SectionTitle('Encuentra tu próximo estilo'),
            const SizedBox(height: 14),
            _grid(context),
            const SizedBox(height: 28),
            const _SectionTitle('Funciones de Barber King'),
            const SizedBox(height: 14),
            const _InfoCard(
              icon: Icons.location_on_outlined,
              title: 'Busca por ubicación',
              text: 'Explora profesionales disponibles cerca de ti.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.star_outline,
              title: 'Reseñas verificadas',
              text: 'Consulta calificaciones antes de reservar.',
            ),
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.auto_awesome,
              title: 'Recomendación por IA',
              text: 'Sube una foto y explora ideas de cortes.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.chatIA,
        ),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Asistente IA'),
      ),
    );
  }

  Widget _header(BuildContext context, String nombre) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BARBER KING / CLIENTE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hola, $nombre',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Encuentra un barbero que se adapte a ti.',
                style: TextStyle(color: AppColors.subtitle),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.perfil);
          },
          icon: const Icon(
            Icons.person_outline,
            color: AppColors.primary,
          ),
        ),
        IconButton(
          onPressed: () async {
            await AuthService().cerrarSesion();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          },
          icon: const Icon(
            Icons.logout_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2411),
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.content_cut,
            color: AppColors.primary,
            size: 42,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Reserva tu cita, conoce profesionales y revisa sus especialidades antes de elegir.',
              style: TextStyle(
                color: AppColors.white,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    final items = [
      _ActionItem(
        'Buscar barberos',
        Icons.people_alt_outlined,
        AppRoutes.barberos,
      ),
      _ActionItem(
        'Reservar cita',
        Icons.calendar_month_outlined,
        AppRoutes.citas,
      ),
      _ActionItem(
        'Mis citas',
        Icons.event_note_outlined,
        AppRoutes.citas,
      ),
      _ActionItem(
        'Mi perfil',
        Icons.person_outline,
        AppRoutes.perfil,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(
            context,
            item.route,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final String route;

  const _ActionItem(this.title, this.icon, this.route);
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 13,
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
