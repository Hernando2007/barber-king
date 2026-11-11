import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/colors.dart';

class PoliticaPrivacidadScreen extends StatefulWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  State<PoliticaPrivacidadScreen> createState() =>
      _PoliticaPrivacidadScreenState();
}

class _PoliticaPrivacidadScreenState extends State<PoliticaPrivacidadScreen> {
  late final WebViewController _controlador;

  @override
  void initState() {
    super.initState();

    _controlador = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/legal/politica-privacidad.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Política de privacidad'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _controlador.reload(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: SafeArea(child: WebViewWidget(controller: _controlador)),
    );
  }
}
