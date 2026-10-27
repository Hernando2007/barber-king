import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ApiConfig {
  ApiConfig._();

  static const bool useRemote = true; // Cambia a false para usar la URL local

  static const String _remoteUrl = 'https://barber-king.onrender.com';
  static String get baseUrl {
    if (useRemote) {
      return '$_remoteUrl/api';
    } else {
      return '$origin/api';
    }
  }

  static const String _webUrl = 'http://localhost:3000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String _deviceUrl =
      'https://aowak-138-117-87-182.run.pinggy-free.link'; // IP de tu PC
  static const String _override = String.fromEnvironment('API_URL');

  static String _cachedOrigin = '';

  /// Inicializa la URL base detectando si es emulador o celular físico
  static Future<void> initialize() async {
    if (_override.isNotEmpty) {
      _cachedOrigin = _override;
      return;
    }

    if (kIsWeb) {
      _cachedOrigin = _webUrl;
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // Si es un celular físico usa la IP local, si es emulador usa 10.0.2.2
      if (androidInfo.isPhysicalDevice) {
        _cachedOrigin = _deviceUrl;
      } else {
        _cachedOrigin = _androidEmulatorUrl;
      }
      return;
    }

    _cachedOrigin = _deviceUrl;
  }

  /// Devuelve la raíz del servidor (ej: http://192.168.1.110:3000)
  static String get origin {
    if (useRemote) {
      return _remoteUrl;
    }

    return _cachedOrigin.isNotEmpty ? _cachedOrigin : _deviceUrl;
  }

  /// Resuelve la URL completa para imágenes o archivos
  static String? resolveMedia(String? path) {
    if (path == null) return null;
    final value = path.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$origin$value';
    }

    return '$origin/$value';
  }
}
