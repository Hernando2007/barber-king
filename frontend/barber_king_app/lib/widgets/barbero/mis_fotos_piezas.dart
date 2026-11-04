part of '../../screens/barbero/mis_fotos_screen.dart';

/// Cuántas fotos hay publicadas del máximo permitido.
class _CuadroContador extends StatelessWidget {
  const _CuadroContador({required this.publicadas, required this.limite});

  final int publicadas;
  final int limite;

  @override
  Widget build(BuildContext context) {
    final lleno = publicadas >= limite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lleno
                  ? 'Portafolio lleno: borra una foto para subir otra.'
                  : 'El cliente elige barbero por lo que ve aquí.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.subtitle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          StatusPill(
            label: '$publicadas de $limite',
            color: lleno ? AppColors.error : AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _Marco extends StatelessWidget {
  const _Marco({required this.hijo, this.onPresionar, this.borde});

  final Widget hijo;
  final VoidCallback? onPresionar;
  final Color? borde;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: AppColors.card,
        child: InkWell(
          onTap: onPresionar,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: borde ?? AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: hijo,
          ),
        ),
      ),
    );
  }
}

class _BotonEsquina extends StatelessWidget {
  const _BotonEsquina({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: .62),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: .6,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _CargandoCuadro extends StatelessWidget {
  const _CargandoCuadro();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
