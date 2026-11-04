part of '../../screens/barbero/barbero_home_screen.dart';

class _BarberoHomeResenas extends StatelessWidget {
  final int barberoId;
  final Map<String, dynamic>? resumen;

  const _BarberoHomeResenas({required this.barberoId, this.resumen});

  @override
  Widget build(BuildContext context) {
    final promedio =
        double.tryParse('${resumen?['promedioCalificacion'] ?? 0}') ?? 0;
    final total = int.tryParse('${resumen?['totalResenas'] ?? 0}') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Reseñas recibidas',
          subtitle: total == 0 ? 'Aún no tienes opiniones' : null,
          icon: Icons.reviews_outlined,
          actionLabel: 'Ver',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PerfilBarberoScreen(barbero: {'id': barberoId}),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BarberosCalificacion(promedio: promedio, total: total),
                  const Spacer(),
                  Text(
                    '$total reseña${total == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ResenasBarberoPanel(barberoId: barberoId, limite: 3),
            ],
          ),
        ),
      ],
    );
  }
}
