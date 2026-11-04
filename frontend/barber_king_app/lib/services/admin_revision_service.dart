import 'package:dio/dio.dart';

import 'api_service.dart';

/// Barberos que esperan el sello de verificado y la decisión del admin.
class AdminRevisionService {
  final ApiService _api = ApiService();

  /// Null cuando la petición falló; lista vacía si nadie está pendiente.
  Future<List<Map<String, dynamic>>?> pendientes() async {
    try {
      final response = await _api.dio.get('/barberos/revision');
      final datos = response.data['data'];

      if (datos is! List) {
        return [];
      }

      return datos.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> decidir(
    int barberoId,
    String estado, {
    String? nota,
  }) async {
    try {
      final response = await _api.dio.post(
        '/barberos/revision/$barberoId',
        data: {
          'estado': estado,
          if (nota != null && nota.trim().isNotEmpty) 'nota': nota.trim(),
        },
      );

      final data = response.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return {'success': false, 'message': 'No se pudo registrar la decisión.'};
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'No se pudo hablar con el servidor.';
  }
}
