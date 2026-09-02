import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'routes/app_routes.dart';
import 'services/deep_link_service.dart';

void main() {
  runApp(
    const BarberKingApp(),
  );
}

class BarberKingApp extends StatefulWidget {
  const BarberKingApp({
    super.key,
  });

  @override
  State<BarberKingApp> createState() =>
      _BarberKingAppState();
}

class _BarberKingAppState
    extends State<BarberKingApp> {

  final DeepLinkService deepLinkService =
      DeepLinkService();

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {

        deepLinkService.iniciar(
          context,
        );

      },
    );
  }

  @override
  void dispose() {

    deepLinkService.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title:
          "Barber King",

      theme:
          AppTheme.darkTheme,

      initialRoute:
          AppRoutes.perfil,

      routes:
          AppRoutes.routes,
    );
  }
}