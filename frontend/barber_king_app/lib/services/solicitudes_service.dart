import 'package:dio/dio.dart';

import 'api_service.dart';

/// Solicitudes de un toque: el cliente pregunta con un motivo fijo y el
/// barbero responde con uno de los botones que manda el servidor.
class SolicitudesService {
  final ApiService _api = ApiService();

  /// Catálogo de motivos con sus respuestas. Null si falla la petición.
  Future<List<Map<String, dynamic>>?> motivos() async {
    final datos = await _lectura('/solicitudes/motivos');

    if (datos == null) {
      return null;
    }

    return _lista(datos['motivos']);
  }

  /// Bandeja del barbero o solicitudes del cliente. Null si falla.
  Future<Map<String, dynamic>?> mis() => _lectura('/solicitudes/mis');

  /// Solo el contador, para el badge.
  Future<int> pendientes() async {
    final datos = await _lectura('/solicitudes/resumen');

    if (datos == null) {
      return 0;
    }

    return int.tryParse('${datos['pendientes']}') ?? 0;
  }

  Future<Map<String, dynamic>> crear({
    required int barberoId,
    required String motivo,
    int? citaId,
    int? servicioId,
    DateTime? fecha,
    String? nota,
  }) async {
    try {
      final response = await _api.dio.post(
        '/solicitudes/crear',
        data: {
          'barbero_id': barberoId,
          'motivo': motivo,
          if (citaId != null) 'cita_id': citaId,
          if (servicioId != null) 'servicio_id': servicioId,
          if (fecha != null) 'fecha_propuesta': fecha.toIso8601String(),
          if (nota != null && nota.trim().isNotEmpty) 'nota': nota.trim(),
        },
      );

      return _mapa(response.data, 'Solicitud enviada.');
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  Future<Map<String, dynamic>> responder(
    int solicitudId,
    String respuesta, {
    String? nota,
  }) async {
    try {
      final response = await _api.dio.post(
        '/solicitudes/responder/$solicitudId',
        data: {
          'respuesta': respuesta,
          if (nota != null && nota.trim().isNotEmpty) 'nota': nota.trim(),
        },
      );

      return _mapa(response.data, 'Respuesta enviada.');
    } on DioException catch (error) {
      return {'success': false, 'message': _mensaje(error)};
    }
  }

  Future<Map<String, dynamic>?> _lectura(String ruta) async {
    try {
      final response = await _api.dio.get(ruta);
      final data = response.data;

      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }

      return null;
    } on DioException {
      return null;
    }
  }

  Map<String, dynamic> _mapa(dynamic data, String porDefecto) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {'success': false, 'message': porDefecto};
  }

  List<Map<String, dynamic>> _lista(dynamic valor) {
    if (valor is! List) {
      return [];
    }

    return valor.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'No se pudo hablar con el servidor.';
  }
}
