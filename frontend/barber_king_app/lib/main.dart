import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const BarberKingApp());
}

class BarberKingApp extends StatelessWidget {
  const BarberKingApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Barber King",

      theme: AppTheme.darkTheme,

      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,

    );

  }

}