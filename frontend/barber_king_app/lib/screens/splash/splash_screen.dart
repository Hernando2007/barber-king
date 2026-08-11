import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.content_cut, size: 100, color: AppColors.primary),

            SizedBox(height: 20),

            Text(
              "BARBER KING",

              style: TextStyle(
                color: AppColors.white,

                fontSize: 34,

                fontWeight: FontWeight.bold,

                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
