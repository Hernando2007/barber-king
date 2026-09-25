import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    //1. evaluar web primero para evitar que platform.isx genere un error en json
    if (kIsWeb) {
      return 'http://localhost:3000/chatbot';
    }

    //2. Evaluaciones para dispositivos moviles / desktop
    if (Platform.isAndroid) {
      //emulador de android
      return 'http://10.0.2.2:3000/chatbot';
    } else if (Platform.isIOS) {
      //simulador de iOS
      return 'http://localhost:3000/chatbot';
    }

    //Fallback para macOS, Windows, Linux, etc.
    return 'http://localhost:3000/chatbot';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}