import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Ajusta la IP según tu entorno:
  // - Emulador Android: http://10.0.2.2:3000
  // - Celular Físico: http://TU_IP_LOCAL:3000 (ej: http://192.168.1.15:3000)
  // - Producción: https://tu-dominio.com
  static const String baseUrl = 'http://10.0.2.2:3000/api/chat';

  static Future<Map<String, dynamic>> enviarMensaje({
    required String mensaje,
    required String tokenJWT,
    String? sesionId,
  }) async {
    // Validación previa para asegurar que el token realmente se le está pasando a la función
    if (tokenJWT.isEmpty) {
      throw Exception('Error local: El token de autenticación JWT está vacío.');
    }

    final url = Uri.parse('$baseUrl/chatear');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJWT', // Inyecta el token en la cabecera
      },
      body: jsonEncode({
        'mensaje': mensaje,
        if (sesionId != null) 'sesionId': sesionId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? errorData['error'] ?? 'Error en la petición',
        );
      } catch (_) {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    }
  }
}
