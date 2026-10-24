part of '../../screens/cliente/cliente_home_screen.dart';

class _ClienteHomePromoIA extends StatelessWidget {
  final VoidCallback onAbrir;

  const _ClienteHomePromoIA({required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .35),
      onTap: onAbrir,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asesor de estilo con IA',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Toma una foto y descubre qué corte te favorece.',
                  style: TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ClienteHomeSoporte extends StatelessWidget {
  final VoidCallback onAbrir;

  const _ClienteHomeSoporte({required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.support_agent_rounded,
            color: AppColors.primary.withValues(alpha: .9),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Chatea directamente con tu barbero para resolver dudas '
              'antes de tu cita.',
              style: TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
          TextButton(
            onPressed: onAbrir,
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }
}
