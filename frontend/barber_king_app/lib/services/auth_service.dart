import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _api.dio.post(
        "/auth/login",
        data: {
          "correo": correo.trim(),
          "password": contrasena,
        },
      );

      final data =
          Map<String, dynamic>.from(
        response.data,
      );

      if (data["success"] == true) {
        await _storage.write(
          key: "token",
          value: data["token"],
        );

        await _storage.write(
          key: "usuario",
          value: jsonEncode(
            data["usuario"],
          ),
        );
      }

      return data;
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            _obtenerMensajeError(e),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // RECUPERAR CONTRASEÑA (ENVÍA OTP)
  Future<Map<String, dynamic>>
      recuperarPassword(
    String correo,
  ) async {
    try {
      final response = await _api.dio.post(
        "/auth/forgot-password",
        data: {
          "correo": correo.trim(),
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            _obtenerMensajeError(e),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // RESTABLECER CONTRASEÑA CON OTP
  Future<Map<String, dynamic>>
      restablecerPassword({
    required String correo,
    required String codigo,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        "/auth/reset-password",
        data: {
          "correo": correo.trim(),
          "codigo": codigo.trim(),
          "password": password,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            _obtenerMensajeError(e),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // OBTENER TOKEN
  Future<String?> obtenerToken() async {
    return await _storage.read(
      key: "token",
    );
  }

  // OBTENER USUARIO
  Future<Map<String, dynamic>?>
      obtenerUsuario() async {
    final usuario =
        await _storage.read(
      key: "usuario",
    );

    if (usuario == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(usuario),
    );
  }

  // VALIDAR SESIÓN
  Future<bool>
      estaAutenticado() async {
    final token =
        await obtenerToken();

    return token != null &&
        token.isNotEmpty;
  }

  // CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }

  String _obtenerMensajeError(
    DioException error,
  ) {
    try {
      final data =
          error.response?.data;

      if (data is Map &&
          data["message"] != null) {
        return data["message"]
            .toString();
      }
    } catch (_) {}

    return "Error de conexión con el servidor.";
  }
}