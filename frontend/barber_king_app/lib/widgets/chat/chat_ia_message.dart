part of '../../screens/chat/chat_ia_screen.dart';

class _ChatMessageItem extends StatelessWidget {
  final _ChatItem item;

  const _ChatMessageItem({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.type == _ChatType.userImage) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              item.bytes!,
              width: 200,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (item.type == _ChatType.botRecommendation) {
      return _ChatRecommendationCard(item: item);
    }

    return _burbuja(
      texto: item.text ?? '',
      esUsuario: item.type == _ChatType.userText,
      error: item.error,
    );
  }

  Widget _burbuja({
    required String texto,
    required bool esUsuario,
    bool error = false,
  }) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .8,
        ),
        decoration: BoxDecoration(
          color: error
              ? AppColors.error.withValues(alpha: .12)
              : esUsuario
              ? AppColors.primary
              : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
          ),
          border: esUsuario
              ? null
              : Border.all(
                  color: error ? AppColors.error.withValues(alpha: .4) : AppColors.border,
                ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: esUsuario
                ? AppColors.black
                : error
                ? AppColors.error
                : AppColors.white,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
