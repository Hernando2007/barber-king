import 'package:dio/dio.dart';

import 'api_service.dart';

class HorarioService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> obtenerHorarios(
    int barberoId,
  ) async {
    try {
      final response = await _api.dio.get(
        '/horarios/barbero/$barberoId',
      );

      final data = response.data;
      final lista = data is Map ? data['data'] : null;

      if (lista is! List) return [];

      return lista
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_mensaje(e));
    }
  }

  Future<Map<String, dynamic>> crearHorario({
    required int diaSemana,
    required String horaInicio,
    required String horaFin,
    bool disponible = true,
  }) async {
    try {
      final response = await _api.dio.post(
        '/horarios/crear',
        data: {
          'dia_semana': diaSemana,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
          'disponible': disponible,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_mensaje(e));
    }
  }

  Future<void> eliminarHorario(int id) async {
    try {
      await _api.dio.delete('/horarios/eliminar/$id');
    } on DioException catch (e) {
      throw Exception(_mensaje(e));
    }
  }

  String _mensaje(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'No se pudo completar la operación de horarios.';
  }
}
