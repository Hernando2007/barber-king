import 'package:barber_king_app/core/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/sentry_config.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart'; // Ajusta la ruta según la ubicación exacta de tu ApiConfig

void main() async {
  // Asegura la inicialización de los bindings de Flutter antes de llamadas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Detecta si la app corre en dispositivo físico o emulador antes de cargar la interfaz
  await ApiConfig.initialize();

  // Sentry toma los errores no capturados solo si se pegó un DSN; si no,
  // arranca la app normal (ver core/sentry_config.dart).
  await SentryConfig.iniciar(() async {
    runApp(const BarberKingApp());
  });
}

class BarberKingApp extends StatelessWidget {
  const BarberKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Barber King",
      theme: AppTheme.darkTheme,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
