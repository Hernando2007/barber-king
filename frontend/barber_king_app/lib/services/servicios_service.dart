import 'package:dio/dio.dart';

import 'api_service.dart';

class ServicioService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerMisServicios() async {
    try {
      final response = await _api.dio.get('/servicios/mis');
      return response.data['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> obtenerServicios() async {
    try {
      final response = await _api.dio.get(
        "/servicios/obtener",
      );

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerServicio(
    int id,
  ) async {
    try {
      final response = await _api.dio.get(
        "/servicios/obtener/$id",
      );

      return Map<String, dynamic>.from(
        response.data["data"],
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> crearServicio({
    required String nombre,
    required String descripcion,
    required double precio,
    required int duracion,
    int tiempoDescanso = 0,
    String? imagen,
    bool estado = true,
  }) async {
    try {
      final response = await _api.dio.post(
        "/servicios/crear",
        data: {
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
          "duracion": duracion,
          "tiempo_descanso": tiempoDescanso,
          "imagen": imagen,
          "estado": estado,
        },
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al crear servicio."
      };
    }
  }

  Future<Map<String, dynamic>> actualizarServicio({
    required int id,
    required Map<String, dynamic> datos,
  }) async {
    try {
      final response = await _api.dio.put(
        "/servicios/actualizar/$id",
        data: datos,
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al actualizar."
      };
    }
  }

  Future<Map<String, dynamic>> eliminarServicio(
    int id,
  ) async {
    try {
      final response = await _api.dio.delete(
        "/servicios/eliminar/$id",
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
            "Error al eliminar."
      };
    }
  }
}