part of '../../screens/splash/splash_screen.dart';

extension _SplashLayout on _SplashScreenState {
  Widget _buildSplash() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -90,
              child: _glow(280, AppColors.primary.withValues(alpha: .14)),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _glow(320, AppColors.info.withValues(alpha: .06)),
            ),
            SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Center(
                        child: Opacity(
                          opacity: _opacity.value,
                          child: Transform.scale(
                            scale: _scale.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: const _SplashBrand(),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: _SplashFooter(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .3),
                  blurRadius: 36,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              color: AppColors.black,
              size: 48,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'BARBER KING',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: 5.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CORTE  •  ESTILO  •  EXPERIENCIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.subtitle,
              fontSize: 10.5,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          height: 2.4,
          child: LinearProgressIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.border,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        SizedBox(height: 22),
        Text(
          'GESTIÓN PROFESIONAL PARA TU BARBERÍA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}
