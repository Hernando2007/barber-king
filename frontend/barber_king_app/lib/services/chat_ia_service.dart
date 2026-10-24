import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_service.dart';

class ChatIaService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> enviarMensaje({
    required String mensaje,
    String? sesionId,
  }) async {
    try {
      final response = await _api.dio.post(
        '/chat/chatear',
        data: {
          'mensaje': mensaje,
          if (sesionId != null && sesionId.isNotEmpty) 'sesionId': sesionId,
        },
      );

      return {
        'success': true,
        'respuesta': response.data['respuesta']?.toString() ?? '',
        'sesionId': response.data['sesionId']?.toString(),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo obtener una respuesta del asistente.');
    }
  }

  Future<Map<String, dynamic>> recomendarCorte(
    Uint8List bytes, {
    String filename = 'corte.jpg',
    String? sesionId,
  }) async {
    try {
      final form = FormData.fromMap({
        'imagen': MultipartFile.fromBytes(bytes, filename: filename),
        if (sesionId != null && sesionId.isNotEmpty) 'sesionId': sesionId,
      });

      final response = await _api.dio.post(
        '/chat/recomendar-corte',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      return {
        'success': true,
        'sesionId': response.data['sesionId']?.toString(),
        'imagenUrl': response.data['imagenUrl']?.toString(),
        'recomendacion': response.data['recomendacion'],
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo analizar la imagen.');
    }
  }

  Future<Map<String, dynamic>> obtenerHistorial(String sesionId) async {
    try {
      final response = await _api.dio.get('/chat/historial/$sesionId');

      return {
        'success': true,
        'data': List<dynamic>.from(response.data['historial'] ?? []),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo cargar el historial.');
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

    if (error.type == DioExceptionType.receiveTimeout) {
      return {
        'success': false,
        'message': 'El asistente tardó demasiado en responder. Intenta de nuevo.',
      };
    }

    return {'success': false, 'message': fallback};
  }
}
