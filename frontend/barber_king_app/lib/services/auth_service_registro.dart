part of 'auth_service.dart';

extension AuthServiceRegistro on AuthService {
  /// Crea la cuenta y, si el registro trae fotos de trabajo, las publica
  /// apenas exista sesión. La sesión queda guardada: la app entra directo.
  Future<Map<String, dynamic>> registrar({
    required int rolId,
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String fechaNacimiento,
    required String password,
    String? especialidad,
    int? experiencia,
    String? descripcion,
    String? direccion,
    Uint8List? diplomaBytes,
    String? diplomaNombre,
    List<Uint8List> fotosTrabajo = const [],
    List<String> nombresFoto = const [],
  }) async {
    try {
      final mapData = <String, dynamic>{
        'rol_id': rolId.toString(),
        'nombres': nombres.trim(),
        'apellidos': apellidos.trim(),
        'correo': correo.trim(),
        'telefono': telefono.trim(),
        'fecha_nacimiento': fechaNacimiento.trim(),
        'password': password,
        if (especialidad != null && especialidad.trim().isNotEmpty)
          'especialidad': especialidad.trim(),
        if (experiencia != null) 'experiencia': experiencia.toString(),
        if (descripcion != null && descripcion.trim().isNotEmpty)
          'descripcion': descripcion.trim(),
        if (direccion != null && direccion.trim().isNotEmpty)
          'direccion': direccion.trim(),
      };

      if (diplomaBytes != null && diplomaBytes.isNotEmpty) {
        mapData['diploma'] = MultipartFile.fromBytes(
          diplomaBytes,
          filename: diplomaNombre ?? 'diploma.pdf',
        );
      }

      final response = await _api.dio.post(
        '/auth/registro',
        data: FormData.fromMap(mapData),
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] != true) {
        return data;
      }

      await _guardarSesion(data);

      return {
        ...data,
        ...await _publicarFotosInicial(rolId, fotosTrabajo, nombresFoto),
      };
    } on DioException catch (e) {
      return {'success': false, 'message': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Nunca reversible: si las fotos fallan la cuenta ya existe y el
  /// barbero puede subirlas después desde Mis fotos.
  Future<Map<String, dynamic>> _publicarFotosInicial(
    int rolId,
    List<Uint8List> fotos,
    List<String> nombres,
  ) async {
    if (rolId != 2 || fotos.isEmpty) {
      return {};
    }

    final resultado = await PortafolioService().subirMis(
      fotos,
      nombres: nombres,
    );
    final total = (resultado['data'] as List?)?.length ?? 0;

    if (resultado['success'] == true) {
      return {'fotosPublicadas': total};
    }

    return {
      'fotosMensaje':
          '${resultado['message'] ?? 'No se pudieron subir tus fotos.'} '
          'Puedes intentar de nuevo en Mis fotos.',
    };
  }
}
