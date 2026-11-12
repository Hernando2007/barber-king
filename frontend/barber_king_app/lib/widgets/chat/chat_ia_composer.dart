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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSoft,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: disabled ? null : onAttach,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Pregunta o sube una foto...',
                  hintStyle: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Opacity(
            opacity: disabled ? .55 : 1,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
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
          ),
        ],
      ),
    );
  }
}
