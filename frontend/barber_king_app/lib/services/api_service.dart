import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config/api_config.dart';

class ApiService {

  late final Dio dio;

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  ApiService() {

    dio = Dio(

      BaseOptions(

        baseUrl:
            ApiConfig.baseUrl,

        connectTimeout:
            const Duration(
          seconds: 15,
        ),

        receiveTimeout:
            const Duration(
          seconds: 15,
        ),

        sendTimeout:
            const Duration(
          seconds: 15,
        ),

        headers: {
          "Content-Type":
              "application/json",
          "Accept":
              "application/json",
        },

      ),
    );

    dio.interceptors.add(

      InterceptorsWrapper(

        onRequest: (
          options,
          handler,
        ) async {

          final token =
              await storage.read(
            key: "token",
          );

          if (
              token != null &&
              token.isNotEmpty
          ) {

            options.headers[
                "Authorization"] =
                "Bearer $token";

          }

          handler.next(
            options,
          );
        },

        onError: (
          error,
          handler,
        ) async {

          if (
              error.response?.statusCode ==
                  401
          ) {

            await storage.delete(
              key: "token",
            );

            await storage.delete(
              key: "usuario",
            );

          }

          handler.next(
            error,
          );
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