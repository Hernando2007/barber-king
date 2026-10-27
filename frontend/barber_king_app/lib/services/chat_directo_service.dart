import 'package:dio/dio.dart';

import 'api_service.dart';

class ChatDirectoService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> obtenerContactos() async {
    try {
      final response = await _api.dio.get('/chat/directo/contactos');

      return {
        'success': true,
        'data': List<dynamic>.from(response.data['data'] ?? []),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudieron cargar los contactos.');
    }
  }

  Future<Map<String, dynamic>> obtenerMensajes(
    int contactoId, {
    int ultimoId = 0,
  }) async {
    try {
      final response = await _api.dio.get(
        '/chat/directo/mensajes/$contactoId',
        queryParameters: ultimoId > 0 ? {'ultimo_id': ultimoId} : null,
      );

      return {
        'success': true,
        'data': Map<String, dynamic>.from(response.data['data']),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo cargar la conversación.');
    }
  }

  Future<Map<String, dynamic>> obtenerNovedades({int desdeId = 0}) async {
    try {
      final response = await _api.dio.get(
        '/chat/directo/novedades',
        queryParameters: {'desde_id': desdeId},
      );

      return {
        'success': true,
        'data': Map<String, dynamic>.from(response.data['data']),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudieron consultar los mensajes nuevos.');
    }
  }

  Future<Map<String, dynamic>> enviarMensaje({
    required int destinatarioId,
    required String mensaje,
    String? imagenUrl,
  }) async {
    try {
      final response = await _api.dio.post(
        '/chat/directo/mensajes',
        data: {
          'destinatario_id': destinatarioId,
          'mensaje': mensaje,
          if (imagenUrl != null && imagenUrl.isNotEmpty)
            'imagen_url': imagenUrl,
        },
      );

      return {
        'success': true,
        'data': Map<String, dynamic>.from(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo enviar el mensaje.');
    }
  }

  Map<String, dynamic> _error(DioException error, String fallback) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return {
        'success': false,
        'message': data['message'].toString(),
      };
    }

    if (error.type == DioExceptionType.connectionError) {
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
      };
    }

    return {'success': false, 'message': fallback};
  }
}
