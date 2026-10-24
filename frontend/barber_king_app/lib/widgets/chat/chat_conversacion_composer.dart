part of '../../screens/chat/chat_conversacion_screen.dart';

class _ChatConversacionComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;
  final VoidCallback onAdjuntar;

  const _ChatConversacionComposer({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
    required this.onAdjuntar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSoft,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: enviando ? null : onAdjuntar,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Adjuntar imagen',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onEnviar(),
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 46,
            height: 46,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: enviando ? null : onEnviar,
                borderRadius: BorderRadius.circular(14),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
