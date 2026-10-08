import 'package:dio/dio.dart';

import 'api_service.dart';

class UsuarioService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> obtenerPerfilActual() async {
    try {
      final response = await _api.dio.get('/usuarios/me');
      final data = response.data;

      if (data is! Map || data['data'] is! Map) {
        return null;
      }

      return Map<String, dynamic>.from(data['data']);
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> obtenerUsuario(int id) async {
    try {
      final response = await _api.dio.get('/usuarios/$id');
      return Map<String, dynamic>.from(
        response.data['data'],
      );
    } catch (_) {
      return null;
    }
  }

  String nombreCompleto(Map<String, dynamic> usuario) {
    return '${usuario['nombres'] ?? ''} '
        '${usuario['apellidos'] ?? ''}'.trim();
  }

  String rolUsuario(Map<String, dynamic> usuario) {
    final rol = usuario['rol_nombre'] ?? usuario['rol'];

    if (rol != null && rol.toString().isNotEmpty) {
      return rol.toString();
    }

    switch (usuario['rol_id']) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Barbero';
      case 3:
        return 'Cliente';
      default:
        return 'Sin rol';
    }
  }
}
