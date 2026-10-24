part of '../../screens/chat/chat_ia_screen.dart';

Future<void> _adjuntar(_ChatIAScreenState state) async {
  if (state._enviando) return;

  final source = await showModalBottomSheet<ImageSource>(
    context: state.context,
    builder: (_) => ImageSourceSheet(
      onSelected: (value) => Navigator.pop(state.context, value),
    ),
  );

  if (source == null) return;

  final file = await state._picker.pickImage(
    source: source,
    imageQuality: 80,
    maxWidth: 1600,
  );

  if (file == null) return;

  final bytes = await file.readAsBytes();

  if (!state.mounted) return;

  state.setState(() {
    state._items.add(_ChatItem.userImage(bytes));
    state._enviando = true;
  });
  state._bajar();

  final respuesta = await state._chat.recomendarCorte(
    bytes,
    filename: file.name.isNotEmpty ? file.name : 'corte.jpg',
    sesionId: state._sesionId,
  );

  if (!state.mounted) return;

  state.setState(() {
    state._enviando = false;
    state._sesionId = respuesta['sesionId']?.toString() ?? state._sesionId;

    if (respuesta['success'] == true) {
      final rec = respuesta['recomendacion'];
      state._items.add(
        _ChatItem.botRecommendation(
          recommendation: rec is Map
              ? Map<String, dynamic>.from(rec)
              : <String, dynamic>{},
          imagenUrl: respuesta['imagenUrl']?.toString(),
        ),
      );
    } else {
      state._items.add(
        _ChatItem.botText(
          respuesta['message']?.toString() ??
              'No se pudo analizar la imagen.',
          error: true,
        ),
      );
    }
  });
  state._bajar();
}
