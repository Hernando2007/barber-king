part of '../../screens/chat/chat_ia_screen.dart';

class _ChatRecommendationCard extends StatelessWidget {
  final _ChatItem item;

  const _ChatRecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rec = item.recommendation ?? {};
    final corte = rec['corte_principal']?.toString() ?? 'Corte personalizado';
    final explicacion = rec['explicacion']?.toString() ?? '';
    final alternativas = rec['alternativas'] is List
        ? (rec['alternativas'] as List)
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList()
        : <String>[];
    final consejo = rec['recomendacion_barbero']?.toString() ?? '';
    final imagen = ApiConfig.resolveMedia(item.imagenUrl);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .88,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagen != null)
              Image.network(
                imagen,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'RECOMENDACIÓN IA',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    corte,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (explicacion.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      explicacion,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (alternativas.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Alternativas',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: alternativas
                          .map(
                            (value) => Chip(
                              label: Text(value),
                              labelStyle: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.primary,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (consejo.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Consejo del barbero: $consejo',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
