import 'dart:typed_data';

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
      return Map<String, dynamic>.from(response.data['data']);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> actualizarPerfil(
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await _api.dio.put('/usuarios/me', data: datos);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensaje(e) ?? 'No se pudo actualizar el perfil.',
      };
    }
  }

  Future<Map<String, dynamic>> subirFoto(
    Uint8List bytes, {
    String filename = 'perfil.jpg',
  }) async {
    try {
      final form = FormData.fromMap({
        'imagen': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _api.dio.put(
        '/usuarios/me/foto',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensaje(e) ?? 'No se pudo actualizar la foto.',
      };
    }
  }

  Future<Map<String, dynamic>> subirDiploma(
    Uint8List bytes, {
    String filename = 'diploma.pdf',
  }) async {
    try {
      final form = FormData.fromMap({
        'diploma': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _api.dio.put(
        '/usuarios/me/diploma',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensaje(e) ?? 'No se pudo subir el documento.',
      };
    }
  }

  String nombreCompleto(Map<String, dynamic> usuario) {
    return '${usuario['nombres'] ?? ''} '
            '${usuario['apellidos'] ?? ''}'
        .trim();
  }

  String rolUsuario(Map<String, dynamic> usuario) {
    final rol = usuario['rol'] ?? usuario['rol_nombre'];

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

  int rolId(Map<String, dynamic>? usuario) {
    return int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
  }

  String? _mensaje(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return null;
  }
}
