import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // Flutter Web
    if (kIsWeb) return 'http://localhost:3000/api';

    // Emulador Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    // Simulador iOS / escritorio
    return 'http://localhost:3000/api';
  }
}