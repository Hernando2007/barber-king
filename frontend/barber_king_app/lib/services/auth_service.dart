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
          value: data["usuario"].toString(),
        );
      }

      return data;
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _obtenerMensajeError(e),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // RECUPERAR CONTRASEÑA

  Future<Map<String, dynamic>> recuperarPassword(
    String correo,
  ) async {
    try {
      final response = await _api.dio.post(
        "/auth/forgot-password",
        data: {
          "correo": correo,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _obtenerMensajeError(e),
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // CAMBIAR CONTRASEÑA

  Future<Map<String, dynamic>> cambiarPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        "/auth/reset-password",
        data: {
          "token": token,
          "password": password,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message": _obtenerMensajeError(e),
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

  // CERRAR SESIÓN

  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }

  // MANEJO DE ERRORES

  String _obtenerMensajeError(
    DioException error,
  ) {
    try {
      final data = error.response?.data;

      if (data is Map &&
          data["message"] != null) {
        return data["message"].toString();
      }
    } catch (_) {}

    return "Error de conexión con el servidor.";
  }

  Future<Object?> obtenerUsuario() async {}
}
