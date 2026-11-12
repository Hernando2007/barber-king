part of '../../screens/chat/chat_ia_screen.dart';

class _ChatIaWelcome extends StatelessWidget {
  final bool disabled;
  final VoidCallback onAttach;
  final void Function(String sugerencia) onSuggestion;

  const _ChatIaWelcome({
    required this.disabled,
    required this.onAttach,
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        AppCard(
          gradient: AppColors.heroGradient,
          borderColor: AppColors.primary.withValues(alpha: .3),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(22),
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
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tu asesor de estilo personal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Pregunta lo que quieras o sube una foto y la IA te '
                'recomendará el corte que mejor va contigo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              PrimaryGradientButton(
                label: 'ANALIZAR UNA FOTO',
                icon: Icons.camera_alt_outlined,
                onPressed: disabled ? null : onAttach,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader(
          title: 'Preguntas rápidas',
          subtitle: 'Empieza con una idea y la IA la desarrolla',
          icon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 12),
        ...sugerencias.map(
          (texto) => AppCard(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            radius: 15,
            onTap: disabled ? null : () => onSuggestion(texto),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .25),
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      height: 1.4,
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
