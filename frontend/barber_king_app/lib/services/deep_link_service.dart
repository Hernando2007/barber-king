import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:barber_king_app/screens/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';


class DeepLinkService {

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  // INICIAR

  Future<void> iniciar(
    BuildContext context,
  ) async {
    // ENLACE CUANDO LA APP ESTÁ CERRADA
    try {

      final Uri? uri =
          await _appLinks.getInitialLink();

      if (uri != null) {

        _procesarEnlace(
          context,
          uri,
        );
      }

    } catch (e) {

      debugPrint(
        "Error al obtener el enlace inicial: $e",
      );
    }

    // ENLACE CUANDO LA APP YA ESTÁ ABIERTA
    _subscription =
        _appLinks.uriLinkStream.listen(
      (Uri uri) {

        _procesarEnlace(
          context,
          uri,
        );

      },
      onError: (error) {

        debugPrint(
          "Error en Deep Link: $error",
        );

      },
    );
  }


  // PROCESAR ENLACE

  void _procesarEnlace(
    BuildContext context,
    Uri uri,
  ) {

    debugPrint(
      "================================",
    );

    debugPrint(
      "DEEP LINK RECIBIDO",
    );

    debugPrint(
      "URI: $uri",
    );

    debugPrint(
      "SCHEME: ${uri.scheme}",
    );

    debugPrint(
      "HOST: ${uri.host}",
    );

    debugPrint(
      "TOKEN: ${uri.queryParameters["token"]}",
    );

    debugPrint(
      "================================",
    );


    // Verificar nuestro enlace
    if (uri.scheme != "barberking") {
      return;
    }

    if (uri.host != "reset-password") {
      return;
    }


    // Obtener token
    final String? token =
        uri.queryParameters["token"];


    if (token == null ||
        token.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "El enlace de recuperación no contiene un token válido.",
          ),
        ),
      );

      return;
    }


    // Abrir pantalla para cambiar contraseña
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ResetPasswordScreen(
          token: token,
        ),
      ),
    );
  }


  // CERRAR

  void dispose() {

    _subscription?.cancel();

    _subscription = null;
  }
}