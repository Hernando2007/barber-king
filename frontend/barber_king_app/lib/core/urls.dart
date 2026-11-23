import 'package:url_launcher/url_launcher.dart';

/// Enlaces públicos que también aparecen en la ficha de Play Store.
class Urls {
  static const politicaPrivacidad =
      'https://barber-king.onrender.com/public/politica-privacidad.html';
  static const eliminarCuenta =
      'https://barber-king.onrender.com/public/eliminar-cuenta.html';

  static Future<bool> abrir(String enlace) =>
      launchUrl(Uri.parse(enlace), mode: LaunchMode.externalApplication);
}
