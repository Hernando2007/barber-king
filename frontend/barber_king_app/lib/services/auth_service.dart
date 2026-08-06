import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _api.dio.post(
        "/auth/login",
        data: {
          "correo": correo,
          "password": contrasena,
        },
      );

      final data = response.data;

      if (data["success"] == true) {
        await _storage.write(
          key: "token",
          value: data["token"],
        );

        await _storage.write(
          key: "usuario",
          value: jsonEncode(data["usuario"]),
        );
      }

      return data;
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error de conexión con el servidor.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>?> obtenerUsuario() async {
    final usuario = await _storage.read(key: "usuario");

    if (usuario == null) return null;

    return jsonDecode(usuario);
  }

  Future<String?> obtenerToken() async {
    return await _storage.read(key: "token");
  }

  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }
}