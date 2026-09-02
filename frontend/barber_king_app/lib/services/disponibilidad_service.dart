import 'package:dio/dio.dart';

import 'api_service.dart';

class DisponibilidadService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> consultarDisponibilidad({
    required int barberoId,
    required int servicioId,
    required String fecha,
  }) async {
    try {
      final response = await _api.dio.get(
        "/disponibilidad/consultarDisponibilidad",
        queryParameters: {
          "barbero_id": barberoId,
          "servicio_id": servicioId,
          "fecha": fecha,
        },
      );

      final data =
          Map<String, dynamic>.from(
        response.data,
      );

      if (data["success"] == true) {
        return List<dynamic>.from(
          data["data"] ?? [],
        );
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}