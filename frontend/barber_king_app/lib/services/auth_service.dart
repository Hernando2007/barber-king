import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'notificacion_segundo_plano.dart';
import 'portafolio_service.dart';

part 'auth_service_google.dart';
part 'auth_service_recuperacion.dart';
part 'auth_service_registro.dart';

bool _googleInicializado = false;

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _api.dio.post(
        '/auth/login',
        data: {'correo': correo.trim(), 'password': contrasena},
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] == true) {
        await _guardarSesion(data);
      }

      return data;
    } on DioException catch (e) {
      return {'success': false, 'message': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<bool> estaAutenticado() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> actualizarUsuarioLocal(Map<String, dynamic> usuario) async {
    final actual = await obtenerUsuario();
    final combinado = {...?actual, ...usuario};

    await _storage.write(key: 'usuario', value: jsonEncode(combinado));
  }

  Future<void> cerrarSesion() async {
    await NotificacionSegundoPlano.detener();
    await _limpiarSesionLocal();
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'usuario');
  }

  Future<void> _guardarSesion(Map<String, dynamic> data) async {
    final token = data['token']?.toString();
    final usuario = data['usuario'];

    if (token == null || usuario is! Map) {
      return;
    }

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'usuario', value: jsonEncode(usuario));

    // Copia en SharedPreferences: el proceso de fondo no siempre abre el almacén seguro.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(NotificacionSegundoPlano.claveToken, token);
    await prefs.setInt(
      NotificacionSegundoPlano.claveUsuarioId,
      int.tryParse('${usuario['id']}') ?? 0,
    );
  }

  Future<void> _limpiarSesionLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(NotificacionSegundoPlano.claveToken);
    await prefs.remove(NotificacionSegundoPlano.claveUsuarioId);
  }

  String _mensajeError(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor. Revisa tu conexión a la red local.';
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado al intentar alcanzar el servidor.';
    }

    return 'Ocurrió un error al comunicarse con el servidor.';
  }
}
