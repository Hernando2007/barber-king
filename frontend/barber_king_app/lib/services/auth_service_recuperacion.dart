part of 'auth_service.dart';

extension AuthServiceRecuperacion on AuthService {
  Future<Map<String, dynamic>> recuperarPassword(String correo) async {
    try {
      final response = await _api.dio.post(
        '/auth/forgot-password',
        data: {'correo': correo.trim()},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensajeError(e),
      };
    }
  }

  Future<Map<String, dynamic>> restablecerPassword({
    required String correo,
    required String codigo,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        '/auth/reset-password',
        data: {
          'correo': correo.trim(),
          'codigo': codigo.trim(),
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensajeError(e),
      };
    }
  }
}
