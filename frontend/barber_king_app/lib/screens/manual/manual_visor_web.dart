import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// En web el manual se muestra en un iframe que apunta al HTML empaquetado.
/// Las rutas relativas de las imágenes quedan resueltas por el propio asset.
abstract class VisorManualEstado extends State<VisorManual> {
  void recargar();
}

class VisorManual extends StatefulWidget {
  const VisorManual({super.key});

  @override
  VisorManualEstado createState() => _VisorManualEstado();
}

class _VisorManualEstado extends VisorManualEstado {
  String _vista = '';

  @override
  void initState() {
    super.initState();
    _registrarVista();
  }

  void _registrarVista() {
    final tipo = 'manual-usuario-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(tipo, (int _) {
      return web.HTMLIFrameElement()
        ..src = 'assets/assets/manual/manual-usuario.html'
        ..style.cssText = 'border:none;width:100%;height:100%;';
    });

    _vista = tipo;
  }

  @override
  void recargar() => setState(_registrarVista);

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(key: ValueKey(_vista), viewType: _vista);
  }
}
