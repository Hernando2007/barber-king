import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  const ChatMessageBubble({super.key, required this.message});
  bool get isUser => message['tipo'] == 'usuario';
  @override
  Widget build(BuildContext context) {
    final imagePath = message['imagenPath']?.toString();
    final imageUrl = message['imagenUrl']?.toString();
    final text = message['texto']?.toString() ?? '';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              _LocalImage(path: imagePath),
            if (imageUrl != null && imageUrl.isNotEmpty)
              _RemoteImage(url: imageUrl),
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                  height: 1.35,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocalImage extends StatelessWidget {
  final String path;
  const _LocalImage({required this.path});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(path),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _RemoteImage extends StatelessWidget {
  final String url;
  const _RemoteImage({required this.url});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            height: 80,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.subtitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool loading;
  final VoidCallback onCamera;
  final VoidCallback onSend;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.loading,
    required this.onCamera,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppColors.primary),
              onPressed: enabled && !loading ? onCamera : null,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled && !loading,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Escribe un mensaje...'
                      : 'Cargando autenticación...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: enabled ? AppColors.primary : Colors.grey,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: enabled && !loading ? onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatLoadingIndicator extends StatelessWidget {
  const ChatLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
