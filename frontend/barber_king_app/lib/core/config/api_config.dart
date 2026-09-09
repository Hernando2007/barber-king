import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }

    // Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:3000/api";
    }

    // Celular físico
    return "http://192.168.1.103:3000/api";
  }
}
