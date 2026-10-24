part of '../../screens/chat/chat_ia_screen.dart';

class _ChatIaWelcome extends StatelessWidget {
  final bool disabled;
  final void Function(String sugerencia) onSuggestion;

  const _ChatIaWelcome({
    required this.disabled,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final sugerencias = [
      '¿Qué corte me recomiendas para cabello rizado?',
      '¿Qué servicios ofrece Barber King?',
      '¿Cómo puedo reservar una cita?',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 18),
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.black,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tu asesor de estilo personal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pregunta lo que quieras o sube una foto y la IA te recomendará '
          'el corte que mejor va contigo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 26),
        ...sugerencias.map(
          (texto) => AppCard(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            radius: 15,
            onTap: disabled ? null : () => onSuggestion(texto),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
