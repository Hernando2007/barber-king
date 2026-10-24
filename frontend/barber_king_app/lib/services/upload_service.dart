import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_service.dart';

class UploadService {
  final ApiService _api = ApiService();

  Future<String?> subirImagen(
    Uint8List bytes, {
    String filename = 'imagen.jpg',
  }) async {
    try {
      final form = FormData.fromMap({
        'imagen': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _api.dio.post(
        '/uploads/subir',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;

      if (data is! Map) {
        return null;
      }

      final payload = data['data'];

      if (payload is Map) {
        return payload['url']?.toString() ?? payload['ruta']?.toString();
      }

      return data['imageUrl']?.toString();
    } on DioException {
      return null;
    }
  }
}
