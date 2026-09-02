import 'package:dio/dio.dart';

import 'api_service.dart';

class BarberoService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerBarberos() async {
    try {
      final response = await _api.dio.get(
        "/barberos/obtener",
      );

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerBarbero(
    int id,
  ) async {
    try {
      final response = await _api.dio.get(
        "/barberos/obtener/$id",
      );

      return Map<String, dynamic>.from(
        response.data["data"],
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> crearBarbero({
    required int usuarioId,
    required String especialidad,
    String? foto,
    bool activo = true,
  }) async {
    try {
      final response = await _api.dio.post(
        "/barberos/crear",
        data: {
          "usuario_id": usuarioId,
          "especialidad": especialidad,
          "foto": foto,
          "activo": activo,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al crear barbero.",
      };
    }
  }

  Future<Map<String, dynamic>> actualizarBarbero({
    required int id,
    required Map<String, dynamic> datos,
  }) async {
    try {
      final response = await _api.dio.put(
        "/barberos/actualizar/$id",
        data: datos,
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al actualizar.",
      };
    }
  }

  Future<Map<String, dynamic>> eliminarBarbero(
    int id,
  ) async {
    try {
      final response = await _api.dio.delete(
        "/barberos/eliminar/$id",
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al eliminar.",
      };
    }
  }
}