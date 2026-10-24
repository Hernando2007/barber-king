import 'package:dio/dio.dart';

import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> obtenerDashboard() async {
    try {
      final response = await _api.dio.get('/dashboard');
      final data = response.data['data'];

      if (data is Map) {
        return {
          'success': true,
          'data': Map<String, dynamic>.from(data),
        };
      }

      return {
        'success': false,
        'message': 'No se pudo cargar el panel.',
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudo cargar el panel.');
    }
  }

  Future<Map<String, dynamic>> listarUsuarios() async {
    try {
      final response = await _api.dio.get('/usuarios/obtener');

      return {
        'success': true,
        'data': List<dynamic>.from(response.data['data'] ?? []),
      };
    } on DioException catch (error) {
      return _error(error, 'No se pudieron cargar los usuarios.');
    }
  }

  Future<Map<String, dynamic>> crearUsuario(
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await _api.dio.post('/usuarios/crear', data: datos);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      return _error(error, 'No se pudo crear el usuario.');
    }
  }

  Future<Map<String, dynamic>> actualizarUsuario(
    int id,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await _api.dio.put('/usuarios/$id', data: datos);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      return _error(error, 'No se pudo actualizar el usuario.');
    }
  }

  Future<Map<String, dynamic>> eliminarUsuario(
    int id, {
    bool forzar = false,
  }) async {
    try {
      final response = await _api.dio.delete(
        '/usuarios/$id',
        queryParameters: forzar ? {'forzar': 'true'} : null,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      return _error(error, 'No se pudo eliminar el usuario.');
    }
  }

  Map<String, dynamic> _error(DioException error, String fallback) {
    final data = error.response?.data;

    if (data is Map) {
      return {
        'success': false,
        'message': data['message']?.toString() ?? fallback,
        'detalles': data['detalles'] ?? data['detalle'],
        'statusCode': error.response?.statusCode,
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
