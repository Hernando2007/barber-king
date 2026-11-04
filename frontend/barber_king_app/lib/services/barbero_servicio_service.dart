import 'package:dio/dio.dart';

import 'api_service.dart';

/// Los servicios que atiende cada barbero y lo que cobra por ellos.
class BarberoServicioService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerMis() => _lista('/barberos/servicios/mis');

  Future<List<dynamic>> obtenerDeBarbero(int barberoId) =>
      _lista('/barberos/servicios/barbero/$barberoId');

  /// Lista completa: lo que no se envía deja de prestarse.
  Future<Map<String, dynamic>> guardarMis(
    List<Map<String, dynamic>> servicios,
  ) async {
    try {
      final response = await _api.dio.put(
        '/barberos/servicios/mis',
        data: {'servicios': servicios},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  Future<List<dynamic>> _lista(String ruta) async {
    try {
      final response = await _api.dio.get(ruta);
      return response.data['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'No se pudieron guardar los servicios.';
  }
}
