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
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagen != null)
              Stack(
                children: [
                  Image.network(
                    imagen,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: .7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'RECOMENDACIÓN IA',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 9.5,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imagen == null)
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.black,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 9),
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
                  if (imagen == null) const SizedBox(height: 12),
                  Text(
                    corte,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
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
                      'ALTERNATIVAS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: alternativas
                          .map(
                            (value) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSoft,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: .8),
                                ),
                              ),
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (consejo.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: AppColors.primary.withValues(alpha: .7),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONSEJO DEL BARBERO',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 9.5,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            consejo,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ],
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
