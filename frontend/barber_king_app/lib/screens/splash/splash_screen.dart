import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> scaleAnimation;

  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1020), Color(0xFF131B2E), Color(0xFF0B1020)],
          ),
        ),

        child: AnimatedBuilder(
          animation: controller,

          builder: (context, child) {
            return Opacity(
              opacity: opacityAnimation.value,

              child: Transform.scale(scale: scaleAnimation.value, child: child),
            );
          },

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 150,
                height: 150,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,

                  border: Border.all(color: AppColors.primary, width: 3),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.content_cut,
                  color: AppColors.primary,
                  size: 75,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "BARBER KING",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Premium Barber Experience",
                style: TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
