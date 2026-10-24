import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _webUrl = 'http://localhost:3000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String _deviceUrl = 'http://192.168.1.100:3000';
  static const String _override = String.fromEnvironment('API_URL');

  static String get origin {
    if (_override.isNotEmpty) {
      return _override;
    }

    if (kIsWeb) {
      return _webUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorUrl;
    }

    return _deviceUrl;
  }

  static String get baseUrl => '$origin/api';

  static String? resolveMedia(String? path) {
    if (path == null) {
      return null;
    }

    final value = path.trim();

    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$origin$value';
    }

    return '$origin/$value';
  }
}
