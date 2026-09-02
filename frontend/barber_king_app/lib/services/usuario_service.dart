import 'package:dio/dio.dart';

import 'api_service.dart';

class UsuarioService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> obtenerUsuarios() async {
    try {
      final response = await _api.dio.get("/usuarios");

      return response.data["data"] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerUsuario(int id) async {
    try {
      final response = await _api.dio.get("/usuarios/$id");

      return Map<String, dynamic>.from(response.data["data"]);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> obtenerPerfilActual() async {
    try {
      final usuarios = await obtenerUsuarios();

      if (usuarios.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(usuarios.first);
    } catch (_) {
      return null;
    }
  }

  String nombreCompleto(Map<String, dynamic> usuario) {
    return "${usuario["nombres"] ?? ""} ${usuario["apellidos"] ?? ""}";
  }

  String rolUsuario(Map<String, dynamic> usuario) {
    try {
      if (usuario["roles"] != null) {
        return usuario["roles"]["nombre"];
      }

      final rolId = usuario["rol_id"];

      switch (rolId) {
        case 1:
          return "Administrador";

        case 2:
          return "Barbero";

        case 3:
          return "Cliente";

        default:
          return "Sin rol";
      }
    } catch (_) {
      return "Sin rol";
    }
  }
}
