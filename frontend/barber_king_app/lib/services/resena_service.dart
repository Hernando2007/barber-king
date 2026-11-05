import 'package:dio/dio.dart';

import 'api_service.dart';

class ResenaService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerPorBarbero(int barberoId) async {
    try {
      final response = await _api.dio.get("/resenas/barbero/$barberoId");

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> obtenerMias() async {
    try {
      final response = await _api.dio.get("/resenas/mias");

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> crear({
    required int citaId,
    required int barberoId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      final response = await _api.dio.post(
        "/resenas",
        data: {
          "cita_id": citaId,
          "barbero_id": barberoId,
          "calificacion": calificacion,
          "comentario": comentario,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      return {
        "success": false,
        "message": data is Map && data["message"] != null
            ? data["message"].toString()
            : "No fue posible publicar la reseña.",
      };
    }
  }
}
