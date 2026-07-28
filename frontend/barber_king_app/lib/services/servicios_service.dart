import 'api_service.dart';

class ServiciosService {
  final ApiService api = ApiService();

  Future<List<dynamic>> obtenerServicios() async {
    final response = await api.dio.get("/servicios");

    if (response.data["success"] == true) {
      return response.data["data"];
    }

    return [];
  }
}