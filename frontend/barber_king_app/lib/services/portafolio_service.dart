import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_service.dart';

/// Las fotos de trabajo del barbero, guardadas en Cloudinary.
class PortafolioService {
  final ApiService _api = ApiService();

  /// Null cuando la petición falló, lista vacía cuando no tiene fotos.
  Future<List<Map<String, dynamic>>?> obtenerMis() =>
      _lista('/barberos/portafolio/mis');

  Future<List<Map<String, dynamic>>> obtenerDeBarbero(int barberoId) async =>
      await _lista('/barberos/portafolio/barbero/$barberoId') ?? [];

  /// Publica de una vez hasta 6 fotos tomadas de la galería o la cámara.
  Future<Map<String, dynamic>> subirMis(
    List<Uint8List> fotos, {
    List<String> nombres = const [],
  }) async {
    final partes = <MultipartFile>[
      for (var i = 0; i < fotos.length; i++)
        MultipartFile.fromBytes(
          fotos[i],
          filename: i < nombres.length ? nombres[i] : 'trabajo-${i + 1}.jpg',
        ),
    ];

    try {
      final response = await _api.dio.post(
        '/barberos/portafolio/mis',
        data: FormData.fromMap({'fotos': partes}),
        options: Options(contentType: 'multipart/form-data'),
      );

      return _mapa(response.data, 'No se pudieron subir las fotos.');
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  Future<Map<String, dynamic>> borrarMiFoto(int fotoId) async {
    try {
      final response = await _api.dio.delete(
        '/barberos/portafolio/mis/$fotoId',
      );

      return _mapa(response.data, 'No se pudo borrar la foto.');
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  Future<List<Map<String, dynamic>>?> _lista(String ruta) async {
    try {
      final response = await _api.dio.get(ruta);
      final datos = response.data['data'];

      if (datos is! List) {
        return [];
      }

      return datos.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _mapa(dynamic data, String porDefecto) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {'success': false, 'message': porDefecto};
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'No se pudo hablar con el servidor.';
  }
}
