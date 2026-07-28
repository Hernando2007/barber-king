import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {

  final ApiService api = ApiService();

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  Future<bool> login(

      String correo,
      String password

      ) async {

    try {

      final response = await api.dio.post(

        "/auth/login",

        data: {

          "correo": correo,

          "password": password

        },

      );

      if (response.data["success"] == true) {

        await storage.write(

          key: "token",

          value: response.data["token"],

        );

        return true;

      }

      return false;

    } catch (e) {

      return false;

    }

  }

}