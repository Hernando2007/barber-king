part of '../../screens/chat/chat_conversacion_screen.dart';

extension _ChatConversacionSync on _ChatConversacionScreenState {
  Future<void> _cargar() async {
    final respuesta = await _chat.obtenerMensajes(_contactoId);

    if (!mounted) return;

    if (respuesta['success'] == true) {
      final data = respuesta['data'] as Map<String, dynamic>;
      final lista = (data['mensajes'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      setState(() {
        _mensajes
          ..clear()
          ..addAll(lista);
        _ultimoId = _maxId(lista);
        _cargando = false;
      });

      _bajar();
    } else {
      setState(() => _cargando = false);
      if (mounted) {
        showAppSnack(
          context,
          respuesta['message']?.toString() ?? 'No se pudo cargar el chat.',
          error: true,
        );
      }
    }
  }

  int _maxId(List<Map<String, dynamic>> lista) {
    var max = 0;
    for (final item in lista) {
      final id = int.tryParse('${item['id']}') ?? 0;
      if (id > max) max = id;
    }
    return max;
  }

  Future<void> _sincronizar() async {
    if (!mounted || _enviando) return;

    final respuesta = await _chat.obtenerMensajes(
      _contactoId,
      ultimoId: _ultimoId,
    );

    if (!mounted || respuesta['success'] != true) return;

    final data = respuesta['data'] as Map<String, dynamic>;
    final nuevas = (data['mensajes'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    if (nuevas.isEmpty) return;

    setState(() {
      for (final mensaje in nuevas) {
        final id = int.tryParse('${mensaje['id']}') ?? 0;
        if (_mensajes.any((item) => item['id'] == mensaje['id'])) continue;
        _mensajes.add(mensaje);
        if (id > _ultimoId) _ultimoId = id;
      }
    });

    _bajar();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}
