import 'package:dio/dio.dart';
import 'api_service.dart';

class ResenaService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> crear({required int citaId, required int barberoId, required int calificacion, String? comentario}) async {
    try {
      final r = await _api.dio.post('/resenas', data: {
        'cita_id': citaId,
        'barbero_id': barberoId,
        'calificacion': calificacion,
        'comentario': comentario?.trim(),
      });
      return Map<String, dynamic>.from(r.data);
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'No se pudo publicar la reseña.'};
    }
  }

  Future<List<dynamic>> porBarbero(int barberoId) async {
    try {
      final r = await _api.dio.get('/resenas/barbero/$barberoId');
      return List<dynamic>.from(r.data['data'] ?? []);
    } catch (_) { return []; }
  }
}
