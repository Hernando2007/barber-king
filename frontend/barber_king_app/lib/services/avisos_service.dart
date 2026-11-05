import 'package:dio/dio.dart';

import 'api_service.dart';

/// Avisos del servidor: lo que pasó desde el último id que ya vimos.
class AvisosService {
  final ApiService _api = ApiService();

  /// Null si la petición falló; el polling simplemente vuelve más tarde.
  Future<Map<String, dynamic>?> novedades({required int desdeId}) async {
    try {
      final response = await _api.dio.get(
        '/avisos/novedades',
        queryParameters: {'desde_id': desdeId},
      );

      final data = response.data;

      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }

      return null;
    } on DioException {
      return null;
    }
  }
}
