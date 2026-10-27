part of '../../screens/chat/chat_conversacion_screen.dart';

extension _ChatConversacionEnvio on _ChatConversacionScreenState {
  Future<void> _enviar() async {
    final texto = _composer.text.trim();

    if (texto.isEmpty || _enviando) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _enviando = true);

    final respuesta = await _chat.enviarMensaje(
      destinatarioId: _contactoId,
      mensaje: texto,
    );

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _enviando = false);

    if (respuesta['success'] == true) {
      _composer.clear();
      final data = Map<String, dynamic>.from(respuesta['data'] as Map);
      final enviado = Map<String, dynamic>.from(data['mensaje'] as Map);
      // ignore: invalid_use_of_protected_member
      setState(() {
        _mensajes.add({...enviado, 'esMio': true});
        final id = int.tryParse('${enviado['id']}') ?? 0;
        if (id > _ultimoId) _ultimoId = id;
      });
      _bajar();
    } else {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo enviar el mensaje.',
        error: true,
      );
    }
  }

  Future<void> _adjuntarImagen() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => ImageSourceSheet(onSelected: (value) {
        Navigator.pop(context, value);
      }),
    );

    if (source == null) return;

    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _enviando = true);

    final bytes = await file.readAsBytes();
    final subida = await _upload.subirImagen(bytes, filename: file.name);

    if (!mounted) return;

    if (subida == null || subida.isEmpty) {
      // ignore: invalid_use_of_protected_member
      setState(() => _enviando = false);
      showAppSnack(
        context,
        'No se pudo subir la imagen.',
        error: true,
      );
      return;
    }

    final respuesta = await _chat.enviarMensaje(
      destinatarioId: _contactoId,
      mensaje: '',
      imagenUrl: subida,
    );

    if (!mounted) return;

    // ignore: invalid_use_of_protected_member
    setState(() => _enviando = false);

    if (respuesta['success'] == true) {
      final data = Map<String, dynamic>.from(respuesta['data'] as Map);
      final enviado = Map<String, dynamic>.from(data['mensaje'] as Map);
      // ignore: invalid_use_of_protected_member
      setState(() {
        _mensajes.add({...enviado, 'esMio': true});
        final id = int.tryParse('${enviado['id']}') ?? 0;
        if (id > _ultimoId) _ultimoId = id;
      });
      _bajar();
    } else {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo enviar la imagen.',
        error: true,
      );
    }
  }
}
