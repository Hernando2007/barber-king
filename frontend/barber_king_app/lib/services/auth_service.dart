import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _api.dio.post(
        '/auth/login',
        data: {
          'correo': correo.trim(),
          'password': contrasena,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] == true) {
        await _guardarSesion(data);
      }

      return data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensajeError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> registrar({
    required int rolId,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String fechaNacimiento,
    required String password,
    String? especialidad,
    String? diplomaPath,
  }) async {
    try {
      final form = FormData.fromMap({
        'rol_id': rolId.toString(),
        'nombres': nombres.trim(),
        'apellidos': apellidos.trim(),
        'correo': correo.trim(),
        'telefono': telefono.trim(),
        'fecha_nacimiento': fechaNacimiento.trim(),
        'password': password,
        if (especialidad != null)
          'especialidad': especialidad.trim(),
        if (diplomaPath != null && diplomaPath.isNotEmpty)
          'diploma': await MultipartFile.fromFile(
            diplomaPath,
            filename: diplomaPath.split('/').last,
          ),
      });

      final response = await _api.dio.post(
        '/auth/registro',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _mensajeError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> recuperarPassword(
    String correo,
  ) async {
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

  Future<String?> obtenerToken() {
    return _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> obtenerUsuario() async {
    final raw = await _storage.read(key: 'usuario');

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return Map<String, dynamic>.from(
        jsonDecode(raw),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> estaAutenticado() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> cerrarSesion() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'usuario');
  }

  Future<void> _guardarSesion(
    Map<String, dynamic> data,
  ) async {
    final token = data['token']?.toString();
    final usuario = data['usuario'];

    if (token == null || usuario is! Map) {
      return;
    }

    await _storage.write(
      key: 'token',
      value: token,
    );

    await _storage.write(
      key: 'usuario',
      value: jsonEncode(usuario),
    );
  }

  String _mensajeError(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado.';
    }

    return 'Ocurrió un error al comunicarse con el servidor.';
  }
}
