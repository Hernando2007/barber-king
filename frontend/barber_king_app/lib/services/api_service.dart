import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import 'notificacion_segundo_plano.dart';

class ApiService {
  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiService() {
    dio = Dio(
      BaseOptions(
        // Garantiza evaluar ApiConfig.baseUrl actualizado al instanciar
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 60),
        headers: {"Accept": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Asegura que baseUrl siempre refleje el estado actual de ApiConfig
          if (options.baseUrl.isEmpty || options.baseUrl != ApiConfig.baseUrl) {
            options.baseUrl = ApiConfig.baseUrl;
          }

          final token = await storage.read(key: "token");

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await storage.delete(key: "token");
            await storage.delete(key: "usuario");
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(NotificacionSegundoPlano.claveToken);
            await prefs.remove(NotificacionSegundoPlano.claveUsuarioId);
          }

          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }
}
