import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Errores de la app en Sentry.
///
/// Cableado pero apagado: mientras [dsn] esté vacío, nada se envía y la app
/// se comporta exactamente como antes. Para encenderlo:
///
///   1. Crear el proyecto "barber-king-app" (plataforma Flutter) en sentry.io.
///   2. Pegar aquí el DSN que da ese proyecto (empieza con `https://`).
///
/// El DSN no es un secreto: Sentry lo define como dato público, porque solo
/// sirve para enviar eventos desde el cliente. No confundirlo con el Auth
/// Token, que sí es privado y no va en el código.
class SentryConfig {
  SentryConfig._();

  static const String dsn = '';

  /// ¿Ya pegaron el DSN? Si no, Sentry queda fuera del arranque.
  static bool get habilitado => dsn.isNotEmpty;

  /// Inicializa Sentry y toma el control de los errores no capturados
  /// (excepciones de widgets, errores de plataforma y errores de zonas).
  ///
  /// [appRunner] es donde va el arranque normal de la app; si Sentry está
  /// deshabilitado se ejecuta tal cual, sin SDK de por medio.
  static Future<void> iniciar(Future<void> Function() appRunner) async {
    if (!habilitado) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        // Sin trazas: solo se quieren los errores, no el costo de medir
        // cada frame. Subir a 1.0 si algún día se quieren métricas.
        options.tracesSampleRate = 0;
        options.environment = kReleaseMode ? 'produccion' : 'desarrollo';
      },
      appRunner: () => appRunner(),
    );
  }

  /// Guarda un error que la app ya manejó y mostró al usuario (por ejemplo,
  /// una llamada al backend que falló). Así queda en el panel aunque la
  /// pantalla lo haya traducido a un mensaje amable.
  static Future<void> capturarExcepcion(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? datos,
  }) async {
    if (!habilitado) {
      return;
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: datos == null ? null : Hint.withMap(datos),
    );
  }
}
