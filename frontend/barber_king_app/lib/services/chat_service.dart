import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> enviarMensaje({
    required String mensaje,
    String? sesionId,
  }) async {
    final response = await _api.dio.post(
      '/chat/chatear',
      data: {
        'mensaje': mensaje,
        if (sesionId != null) 'sesionId': sesionId,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;

    throw Exception('Respuesta inválida del asistente.');
  }
}
