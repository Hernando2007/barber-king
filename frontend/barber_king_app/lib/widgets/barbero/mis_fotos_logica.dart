part of '../../screens/barbero/mis_fotos_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _MisFotosLogica on _MisFotosScreenState {
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final fotos = await _portafolio.obtenerMis();

    if (!mounted) return;

    setState(() {
      _fotos = fotos ?? [];
      _cargando = false;
      _error = fotos == null ? 'Revisa tu conexión e intenta de nuevo.' : null;
    });
  }

  Future<void> _elegir() async {
    if (_espacioRestante == 0) {
      showAppSnack(
        context,
        'Tu portafolio llegó al máximo de $_limiteTotal fotos.',
        error: true,
      );
      return;
    }

    if (_pendientes.length >= _limitePorEnvio) {
      showAppSnack(
        context,
        'Publica primero las $_limitePorEnvio fotos seleccionadas.',
        error: true,
      );
      return;
    }

    final elegidas = await _picker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 1400,
      maxHeight: 1400,
    );

    if (elegidas.isEmpty || !mounted) return;

    final disponibles = _limitePorEnvio - _pendientes.length;

    setState(() {
      _pendientes = [..._pendientes, ...elegidas.take(disponibles)];
    });

    if (elegidas.length > disponibles) {
      showAppSnack(
        context,
        'Dejamos las otras ${elegidas.length - disponibles} fuera: '
        'suben en el siguiente envío.',
      );
    }
  }

  Future<void> _publicar() async {
    if (_pendientes.isEmpty || _subiendo) return;

    setState(() => _subiendo = true);

    final fotos = <Uint8List>[];
    final nombres = <String>[];

    for (final archivo in _pendientes) {
      fotos.add(await archivo.readAsBytes());
      nombres.add(archivo.name);
    }

    final resultado = await _portafolio.subirMis(fotos, nombres: nombres);
    final exito = resultado['success'] == true;

    await _recargar();

    if (!mounted) return;

    setState(() {
      _subiendo = false;

      if (exito) {
        _pendientes = [];
      }
    });

    showAppSnack(
      context,
      (resultado['message'] ??
              (exito
                  ? 'Fotos publicadas en tu portafolio.'
                  : 'No se pudieron subir las fotos.'))
          .toString(),
      error: !exito,
    );
  }

  Future<void> _recargar() async {
    _fotos = await _portafolio.obtenerMis() ?? _fotos;
  }

  void _descartar() {
    setState(() => _pendientes = []);
  }

  void _quitarPendiente(XFile archivo) {
    setState(() {
      _pendientes.removeWhere((elegida) => elegida.path == archivo.path);
    });
  }

  Future<void> _borrar(Map<String, dynamic> foto) async {
    final id = int.tryParse('${foto['id']}');

    if (id == null) return;

    final confirmado = await showConfirmDialog(
      context,
      title: '¿Borrar esta foto?',
      message: 'Deja de verse en tu perfil y la quitamos también del servidor.',
      confirmLabel: 'Borrar',
      destructive: true,
    );

    if (!confirmado || !mounted) return;

    final resultado = await _portafolio.borrarMiFoto(id);

    if (!mounted) return;

    if (resultado['success'] == true) {
      setState(() {
        _fotos.removeWhere((f) => '${f['id']}' == '${foto['id']}');
      });
      showAppSnack(context, 'Foto borrada.');
      return;
    }

    showAppSnack(
      context,
      (resultado['message'] ?? 'No se pudo borrar la foto.').toString(),
      error: true,
    );
  }

  void _ampliar(int indice) {
    final urls = _fotos
        .map((foto) => '${foto['url'] ?? ''}')
        .where((url) => url.isNotEmpty)
        .toList();

    if (urls.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            VisorFoto(urls: urls, inicial: indice.clamp(0, urls.length - 1)),
      ),
    );
  }
}
