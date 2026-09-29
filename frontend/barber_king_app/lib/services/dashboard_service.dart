import 'package:dio/dio.dart';

import 'api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> obtenerBarbero() async {
    try {
      final response = await _api.dio.get('/dashboard/barbero');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }
    } on DioException {
      return null;
    }
    return null;
  }
}
