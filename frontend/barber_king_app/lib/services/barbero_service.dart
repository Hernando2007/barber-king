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

  Future<List<dynamic>> obtenerDestacados({int limite = 5}) async {
    try {
      final response = await _api.dio.get(
        "/barberos/destacados",
        queryParameters: {"limite": limite},
      );

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> obtenerCercanos({
    required double latitud,
    required double longitud,
    double radioKm = 15,
  }) async {
    try {
      final response = await _api.dio.get(
        "/barberos/cercanos",
        queryParameters: {
          "latitud": latitud,
          "longitud": longitud,
          "radio_km": radioKm,
        },
      );

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> actualizarUbicacion({
    required double latitud,
    required double longitud,
    String? ciudad,
    String? zona,
  }) async {
    try {
      final response = await _api.dio.put(
        "/barberos/ubicacion",
        data: {
          "latitud": latitud,
          "longitud": longitud,
          "ciudad": ?ciudad,
          "zona": ?zona,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "No fue posible actualizar la ubicación.",
      };
    }
  }
}