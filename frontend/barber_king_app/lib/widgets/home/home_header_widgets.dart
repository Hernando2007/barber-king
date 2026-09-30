import 'package:flutter/material.dart';

import '../../core/colors.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onLogout;

  const HomeHeader({
    super.key,
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BARBER KING',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Hola, ${name.isEmpty ? 'Usuario' : name}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                style: const TextStyle(
                  color: AppColors.subtitle,
                ),
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
            onPressed: onLogout,
            tooltip: 'Cerrar sesión',
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class MembershipCard extends StatelessWidget {
  final String role;

  const MembershipCard({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'MEMBRESÍA PREMIUM',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            role.isEmpty ? 'Cliente' : role,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reserva tus citas, administra tus servicios y '
            'disfruta de la experiencia Barber King.',
            style: TextStyle(
              color: AppColors.subtitle,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  final String title;

  const HomeSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class PremiumMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PremiumMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 35,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
