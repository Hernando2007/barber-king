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
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
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
      context: context,
      texto: item.text ?? '',
      esUsuario: item.type == _ChatType.userText,
      error: item.error,
    );
  }

  Widget _burbuja({
    required BuildContext context,
    required String texto,
    required bool esUsuario,
    bool error = false,
  }) {
    final radio = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(esUsuario ? 18 : 5),
      bottomRight: Radius.circular(esUsuario ? 5 : 18),
    );

    final contenido = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * .78,
      ),
      decoration: BoxDecoration(
        gradient: esUsuario && !error ? AppColors.goldGradient : null,
        color: esUsuario && !error
            ? null
            : error
            ? AppColors.error.withValues(alpha: .12)
            : AppColors.card,
        borderRadius: radio,
        border: esUsuario && !error
            ? null
            : Border.all(
                color: error
                    ? AppColors.error.withValues(alpha: .4)
                    : AppColors.border,
              ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: esUsuario && !error
              ? AppColors.black
              : error
              ? AppColors.error
              : AppColors.white,
          fontSize: 13.5,
          height: 1.45,
          fontWeight: esUsuario && !error ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );

    if (esUsuario) {
      return Align(alignment: Alignment.centerRight, child: contenido);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 10),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.black,
              size: 14,
            ),
          ),
          Flexible(child: contenido),
        ],
      ),
    );
  }
}
