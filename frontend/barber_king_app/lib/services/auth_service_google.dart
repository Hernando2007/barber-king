part of 'auth_service.dart';

extension AuthServiceGoogle on AuthService {
  Future<Map<String, dynamic>> loginConGoogle() async {
    try {
      final idToken = await _obtenerIdTokenGoogle();

      final response = await _api.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final data = Map<String, dynamic>.from(response.data);

      if (data['success'] == true) {
        await _guardarSesion(data);
      }

      return data;
    } on _GoogleCancelado {
      return {'success': false, 'cancelado': true};
    } on _GoogleNoConfigurado catch (e) {
      return {'success': false, 'message': e.message};
    } on GoogleSignInException catch (e) {
      return {'success': false, 'message': _mensajeGoogle(e)};
    } on DioException catch (e) {
      return {'success': false, 'message': _mensajeError(e)};
    } catch (_) {
      return {
        'success': false,
        'message': 'No fue posible iniciar sesión con Google.',
      };
    }
  }

  Future<String> _obtenerIdTokenGoogle() async {
    final google = GoogleSignIn.instance;

    if (!_googleInicializado) {
      final clientId = await _obtenerClientIdGoogle();
      await google.initialize(serverClientId: clientId);
      _googleInicializado = true;
    }

    final GoogleSignInAccount cuenta;

    try {
      cuenta = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const _GoogleCancelado();
      }
      rethrow;
    }

    final idToken = cuenta.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const _GoogleNoConfigurado(
        'Google no devolvió un token válido. Revisa el cliente OAuth configurado.',
      );
    }

    return idToken;
  }

  Future<String> _obtenerClientIdGoogle() async {
    try {
      final response = await _api.dio.get('/auth/google/config');
      final data = response.data is Map ? response.data['data'] : null;
      final clientId = data is Map ? data['clientId']?.toString() : null;

      if (clientId != null && clientId.isNotEmpty) {
        return clientId;
      }
    } on DioException {
      // El mensaje de configuración se muestra abajo.
    }

    throw const _GoogleNoConfigurado(
      'El inicio de sesión con Google no está configurado en el servidor.',
    );
  }

  String _mensajeGoogle(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google no está configurado para esta app. Revisa el cliente OAuth y la huella SHA-1.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google rechazó la solicitud de inicio de sesión. Intenta de nuevo.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'No se pudo abrir la ventana de Google. Intenta de nuevo.';
      default:
        return 'No fue posible iniciar sesión con Google (${error.code.name}).';
    }
  }
}

class _GoogleCancelado implements Exception {
  const _GoogleCancelado();
}

class _GoogleNoConfigurado implements Exception {
  final String message;

  const _GoogleNoConfigurado(this.message);
}
