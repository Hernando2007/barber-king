import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _override = String.fromEnvironment('API_URL');
  static String get baseUrl {
    // 1. Si pasas una URL por variables de entorno, tiene prioridad máxima
    if (_override.isNotEmpty) return _override;

    // 2. Si se ejecuta en el Navegador Web (Flutter Web)
    if (kIsWeb) return 'http://localhost:3000/api';

    // 3. Entorno Android (Físico o Emulador)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final bool isEmulator =
          const String.fromEnvironment('dart.vm.product') == 'false' &&
          !const bool.fromEnvironment(
            'IS_PHYSICAL_DEVICE',
            defaultValue: false,
          );

      return isEmulator
          ? 'http://10.0.2' // IP del puente para Emulador Android
          : 'http://192.168.1.119:3000/api'; // IP de tu PC para Celular Android Físico
    }

    // 4. Simulador iOS, Celular iOS Físico o Escritorio
    return 'http://192.168.1.119:3000/api';
  }
}
