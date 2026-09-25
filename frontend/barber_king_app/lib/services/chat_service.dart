import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart'; 
class ChatMimosService {
  // Concatena directamente con tu baseUrl existente ('.../api/chat-mimos')
  static String get _chatUrl => '${ApiConfig.baseUrl}/chat-BarberKing';

  static Future<String> enviarMensaje(String mensaje, {String? sesionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId ?? 'mimos_cliente_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['respuesta'] ?? 'No se recibio respuesta.';
      } else {
        return 'En este momento no pudimos procesar tu solicitud.';
      }
    } catch (e) {
      return 'Error de conexion con la heladeria. Revisa tu servidor.';
    }
  }
}