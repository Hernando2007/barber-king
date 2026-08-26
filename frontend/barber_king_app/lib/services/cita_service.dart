import 'package:dio/dio.dart';

import 'api_service.dart';

class CitaService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerCitas() async {
    try {
      final response = await _api.dio.get(
        "/citas/obtenerTodas",
      );

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerCita(
    int id,
  ) async {
    try {
      final response = await _api.dio.get(
        "/citas/obtenerPorId/$id",
      );

      return Map<String, dynamic>.from(
        response.data["data"],
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> crearCita({
    required int clienteId,
    required int barberoId,
    required int servicioId,
    required String fecha,
    required String hora,
    String estado = "Pendiente",
    String? observaciones,
  }) async {
    try {
      final response = await _api.dio.post(
        "/citas/crear",
        data: {
          "cliente_id": clienteId,
          "barbero_id": barberoId,
          "servicio_id": servicioId,
          "fecha": fecha,
          "hora": hora,
          "estado": estado,
          "observaciones": observaciones,
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
            "Error al crear la cita.",
      };
    }
  }

  Future<Map<String, dynamic>> actualizarCita({
    required int id,
    required Map<String, dynamic> datos,
  }) async {
    try {
      final response = await _api.dio.put(
        "/citas/actualizar/$id",
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

  Future<Map<String, dynamic>> eliminarCita(
    int id,
  ) async {
    try {
      final response = await _api.dio.delete(
        "/citas/delete/$id",
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