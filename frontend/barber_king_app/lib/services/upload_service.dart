import 'package:dio/dio.dart';

import 'api_service.dart';

class UploadService {
  final ApiService _api = ApiService();

  Future<String?> subirImagen(String path) async {
    try {
      final form = FormData.fromMap({
        'imagen': await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        ),
      });

      final response = await _api.dio.post(
        '/uploads/subir',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      return data is Map
          ? data['imageUrl']?.toString()
          : null;
    } catch (_) {
      return null;
    }
  }
}
