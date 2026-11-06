import 'package:flutter/material.dart';

import '../../screens/barberos/mapa_barbero_screen.dart';
import '../../screens/barberos/perfil_barbero_screen.dart';
import '../../screens/citas/crear_cita_screen.dart';
import '../common/app_ui.dart';

class BarberosAcciones {
  BarberosAcciones._();

  static Future<void> abrirPerfil(
    BuildContext context,
    Map<String, dynamic> barbero,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PerfilBarberoScreen(barbero: barbero)),
    );
  }

  static Future<void> abrirMapa(
    BuildContext context,
    Map<String, dynamic> barbero,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapaBarberoScreen(barbero: barbero)),
    );
  }

  static Future<void> reservar(
    BuildContext context,
    Map<String, dynamic> barbero,
  ) async {
    final guardada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CrearCitaScreen(barberoInicial: int.tryParse('${barbero['id']}')),
      ),
    );

    if (guardada == true && context.mounted) {
      showAppSnack(context, 'Tu cita quedó confirmada. ¡Te esperamos!');
    }
  }
}
