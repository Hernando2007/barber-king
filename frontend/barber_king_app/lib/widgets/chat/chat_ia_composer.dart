part of '../../screens/chat/chat_ia_screen.dart';

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool disabled;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ChatComposer({
    required this.controller,
    required this.disabled,
    required this.onAttach,
    required this.onSend,
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
            onPressed: disabled ? null : onAttach,
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Analizar una foto',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Pregunta o sube una foto...',
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
                onTap: disabled ? null : () => onSend(),
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
