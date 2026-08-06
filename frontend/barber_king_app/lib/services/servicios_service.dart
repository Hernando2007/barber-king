import 'package:dio/dio.dart';

import '../models/servicio.dart';
import 'api_service.dart';

class ServiciosService {
  final ApiService _api = ApiService();

  Future<List<Servicio>> obtenerServicios() async {
    try {
      final response = await _api.dio.get("/servicios");

      final List lista = response.data["data"];

      return lista
          .map((e) => Servicio.fromJson(e))
          .toList();
    } on DioException {
      rethrow;
    }
  }

  Future<bool> eliminarServicio(int id) async {
    try {
      await _api.dio.delete("/servicios/$id");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> crearServicio({
    required String nombre,
    required String descripcion,
    required double precio,
    required int duracion,
    required int tiempoDescanso,
  }) async {
    try {
      await _api.dio.post(
        "/servicios",
        data: {
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
          "duracion": duracion,
          "tiempo_descanso": tiempoDescanso,
          "estado": true,
        },
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}