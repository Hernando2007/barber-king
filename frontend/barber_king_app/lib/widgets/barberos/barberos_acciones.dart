import 'package:flutter/material.dart';

import '../../screens/barberos/mapa_barbero_screen.dart';
import '../../screens/barberos/perfil_barbero_screen.dart';
import '../../screens/chat/chat_conversacion_screen.dart';
import '../../screens/citas/crear_cita_screen.dart';
import '../common/app_ui.dart';
import '../solicitudes/nueva_solicitud_sheet.dart';

class BarberosAcciones {
  BarberosAcciones._();

  static Map<String, dynamic> _usuario(Map<String, dynamic> barbero) {
    final value = barbero['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  static String _nombre(Map<String, dynamic> barbero) {
    final usuario = _usuario(barbero);

    return '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
  }

  static Future<void> solicitar(
    BuildContext context,
    Map<String, dynamic> barbero,
  ) async {
    final barberoId = int.tryParse('${barbero['id']}');

    if (barberoId == null) {
      showAppSnack(context, 'No se pudo abrir la solicitud.', error: true);

      return;
    }

    final nombre = _nombre(barbero);
    final enviada = await NuevaSolicitudSheet.mostrar(
      context,
      barberoId: barberoId,
      barberoNombre: nombre.isEmpty ? 'el barbero' : nombre,
    );

    if (!context.mounted) return;

    if (enviada?['success'] == true) {
      showAppSnack(context, 'Solicitud enviada. Te avisamos cuando responda.');
    }
  }

  static Future<void> abrirChat(
    BuildContext context,
    Map<String, dynamic> barbero,
  ) async {
    final usuario = _usuario(barbero);

    if (usuario['id'] == null) {
      showAppSnack(context, 'No se pudo abrir el chat.', error: true);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversacionScreen(
          contacto: {
            'usuario_id': usuario['id'],
            'nombres': usuario['nombres'],
            'apellidos': usuario['apellidos'],
            'foto': usuario['foto'],
            'rol_id': 2,
            'especialidad': barbero['especialidad'],
          },
        ),
      ),
    );
  }

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
      showAppSnack(context, 'Tu cita fue registrada correctamente.');
    }
  }
}
