import 'package:flutter_test/flutter_test.dart';

import 'package:barber_king_app/core/sentry_config.dart';

void main() {
  test('habilitado refleja exactamente si hay DSN', () {
    // No se exige el DSN vacío: cuando se pegue uno, la app empieza a
    // enviar errores a propósito y esto debe seguir teniendo sentido.
    expect(SentryConfig.habilitado, SentryConfig.dsn.isNotEmpty);
    expect(
      SentryConfig.dsn.isEmpty || SentryConfig.dsn.startsWith('https://'),
      isTrue,
      reason: 'Un DSN de Sentry siempre empieza con https://',
    );
  });

  test('capturarExcepcion no explota con Sentry apagado', () async {
    // Con el DSN vacío debe devolver sin hacer nada: si lanzara, cada call
    // site tendría que envolver la captura en un try/catch.
    await expectLater(
      SentryConfig.capturarExcepcion(
        Exception('fallo simulado'),
        stackTrace: StackTrace.current,
        datos: {'ruta': '/api/prueba'},
      ),
      completes,
    );
  });
}
