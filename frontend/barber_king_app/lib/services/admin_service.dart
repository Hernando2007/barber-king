import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> dashboard() async {
    final r = await _api.dio.get('/dashboard');
    return Map<String, dynamic>.from(r.data['data'] ?? {});
  }

  Future<List<dynamic>> usuarios() async {
    final r = await _api.dio.get('/usuarios/obtener');
    return List<dynamic>.from(r.data['data'] ?? []);
  }

  Future<List<dynamic>> barberos() async {
    final r = await _api.dio.get('/barberos/obtener');
    return List<dynamic>.from(r.data['data'] ?? []);
  }

  Future<List<dynamic>> citas() async {
    final r = await _api.dio.get('/citas/obtenerTodas');
    return List<dynamic>.from(r.data['data'] ?? []);
  }

  Future<List<dynamic>> servicios() async {
    final r = await _api.dio.get('/servicios/obtener');
    return List<dynamic>.from(r.data['data'] ?? []);
  }

  Future<List<dynamic>> resenas() async {
    final r = await _api.dio.get('/resenas');
    return List<dynamic>.from(r.data['data'] ?? []);
  }

  Future<void> eliminarBarbero(dynamic id) async {
    await _api.dio.delete('/barberos/eliminar/$id');
  }

  Future<void> eliminarServicio(dynamic id) async {
    await _api.dio.delete('/servicios/eliminar/$id');
  }

  Future<void> eliminarResena(dynamic id) async {
    await _api.dio.delete('/resenas/$id');
  }
}
