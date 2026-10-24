part of '../../screens/chat/chat_ia_screen.dart';

enum _ChatType { userText, botText, userImage, botRecommendation }

class _ChatItem {
  final _ChatType type;
  final String? text;
  final Uint8List? bytes;
  final Map<String, dynamic>? recommendation;
  final String? imagenUrl;
  final bool error;

  _ChatItem._({
    required this.type,
    this.text,
    this.bytes,
    this.recommendation,
    this.imagenUrl,
    this.error = false,
  });

  factory _ChatItem.userText(String text) =>
      _ChatItem._(type: _ChatType.userText, text: text);

  factory _ChatItem.botText(String text, {bool error = false}) =>
      _ChatItem._(type: _ChatType.botText, text: text, error: error);

  factory _ChatItem.userImage(Uint8List bytes) =>
      _ChatItem._(type: _ChatType.userImage, bytes: bytes);

  factory _ChatItem.botRecommendation({
    required Map<String, dynamic> recommendation,
    String? imagenUrl,
  }) => _ChatItem._(
    type: _ChatType.botRecommendation,
    recommendation: recommendation,
    imagenUrl: imagenUrl,
  );
}
