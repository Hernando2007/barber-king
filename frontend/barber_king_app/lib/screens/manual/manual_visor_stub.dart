import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/colors.dart';
import '../../widgets/common/app_card.dart';

/// El manual se dibuja con el WebView nativo de Android, iOS y macOS. En el
/// resto de plataformas se avisa en lugar de romper la pantalla.
abstract class VisorManualEstado extends State<VisorManual> {
  void recargar();
}

class VisorManual extends StatefulWidget {
  const VisorManual({super.key});

  @override
  VisorManualEstado createState() => _VisorManualEstado();
}

class _VisorManualEstado extends VisorManualEstado {
  WebViewController? _controlador;

  static bool get _soportado =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();

    if (!_soportado) return;

    _controlador = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/manual/manual-usuario.html');
  }

  @override
  void recargar() => _controlador?.reload();

  @override
  Widget build(BuildContext context) {
    final controlador = _controlador;

    if (controlador == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Manual disponible en el celular',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Abre la app en Android o iPhone para leer la guía con sus '
                  'imágenes. En este equipo el visor todavía no está disponible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WebViewWidget(controller: controlador);
  }
}
