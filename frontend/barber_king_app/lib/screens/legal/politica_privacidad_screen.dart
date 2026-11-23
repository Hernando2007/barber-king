import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/colors.dart';
import '../../core/urls.dart';

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

  Future<void> _abrirEnLinea() async {
    final abierto = await Urls.abrir(Urls.politicaPrivacidad);
    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la versión publicada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Política de privacidad'),
        actions: [
          IconButton(
            tooltip: 'Abrir versión publicada',
            onPressed: _abrirEnLinea,
            icon: const Icon(Icons.open_in_new),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _controlador.reload(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: SafeArea(child: WebViewWidget(controller: _controlador)),
      bottomNavigationBar: SafeArea(
        child: TextButton(
          onPressed: _abrirEnLinea,
          child: const Text('Abrir versión publicada en el navegador'),
        ),
      ),
    );
  }
}
