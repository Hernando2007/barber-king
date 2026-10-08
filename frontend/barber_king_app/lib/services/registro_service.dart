import 'package:dio/dio.dart';

import 'api_service.dart';

/// Registro de cliente (rol 3) y barbero (rol 2) -> POST /api/auth/registro
class RegistroService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> registrar({
    required int rolId,
    required String nombres,
    required String apellidos,
    required String correo,
    required String password,
    String telefono = '',
    String fechaNacimiento = '',
    String? especialidad,
    int? experiencia,
    String? direccion,
    List<String> portafolio = const [],
  }) async {
    try {
      final form = FormData.fromMap({
        'rol_id': rolId.toString(),
        'nombres': nombres.trim(),
        'apellidos': apellidos.trim(),
        'correo': correo.trim(),
        'password': password,
        if (telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
        if (fechaNacimiento.isNotEmpty) 'fecha_nacimiento': fechaNacimiento,
        if (especialidad != null) 'especialidad': especialidad,
        if (experiencia != null) 'experiencia': experiencia.toString(),
        if (direccion != null && direccion.trim().isNotEmpty)
          'direccion': direccion.trim(),
      });

      for (final ruta in portafolio) {
        form.files.add(
          MapEntry(
            'portafolio',
            await MultipartFile.fromFile(
              ruta,
              filename: ruta.split(RegExp(r'[\\/]')).last,
            ),
          ),
        );
      }

      final response = await _api.dio.post(
        '/auth/registro',
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      return {
        'success': false,
        'message': data is Map && data['message'] != null
            ? data['message'].toString()
            : 'No se pudo completar el registro. Revisa tu conexión.',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
