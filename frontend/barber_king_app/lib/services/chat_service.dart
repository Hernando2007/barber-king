import 'package:dio/dio.dart';

import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> enviarMensaje({
    required String mensaje,
    String? sesionId,
  }) async {
    final response = await _api.dio.post(
      '/chat/chatear',
      data: {'mensaje': mensaje, if (sesionId != null) 'sesionId': sesionId},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Respuesta inválida del asistente.');
  }

  /// Envía una foto del rostro a POST /api/chat/recomendar-corte.
  /// Devuelve {success, sesionId, imagenUrl, recomendacion: {...}}.
  Future<Map<String, dynamic>> recomendarCorte({
    required String rutaFoto,
    String? sesionId,
  }) async {
    try {
      final form = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(
          rutaFoto,
          filename: rutaFoto.split(RegExp(r'[\\/]')).last,
        ),
        if (sesionId != null) 'sesionId': sesionId,
      });

      final response = await _api.dio.post(
        '/chat/recomendar-corte',
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      throw Exception(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : 'No se pudo analizar la foto. Revisa tu conexión.',
      );
    }
  }
}
