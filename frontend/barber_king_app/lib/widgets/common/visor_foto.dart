import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Foto a pantalla completa, con deslizar lateral si hay más de una.
class VisorFoto extends StatefulWidget {
  final List<String> urls;
  final int inicial;

  const VisorFoto({super.key, required this.urls, this.inicial = 0});

  @override
  State<VisorFoto> createState() => _VisorFotoState();
}

class _VisorFotoState extends State<VisorFoto> {
  late final PageController _controlador = PageController(
    initialPage: widget.inicial.clamp(0, widget.urls.length - 1),
  );

  int _pagina = 0;

  @override
  void initState() {
    super.initState();
    _pagina = widget.inicial.clamp(0, widget.urls.length - 1);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: widget.urls.length > 1
            ? Text(
                '${_pagina + 1} / ${widget.urls.length}',
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 13.5,
                ),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _controlador,
        itemCount: widget.urls.length,
        onPageChanged: (indice) => setState(() => _pagina = indice),
        itemBuilder: (_, indice) => Center(
          child: InteractiveViewer(
            maxScale: 4,
            child: Image.network(
              widget.urls[indice],
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
