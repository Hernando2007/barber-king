import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../../services/chat_ia_service.dart';
import '../../widgets/chat/image_source_sheet.dart';

part '../../widgets/chat/chat_ia_item.dart';
part '../../widgets/chat/chat_ia_actions.dart';
part '../../widgets/chat/chat_ia_message.dart';
part '../../widgets/chat/chat_ia_recommendation.dart';
part '../../widgets/chat/chat_ia_composer.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final ChatIaService _chat = ChatIaService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _mensaje = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatItem> _items = [];

  String? _sesionId;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _items.add(_ChatItem.botText('Hola'));
  }

  @override
  void dispose() {
    _mensaje.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviarTexto([String? sugerencia]) async {
    final texto = (sugerencia ?? _mensaje.text).trim();

    if (texto.isEmpty || _enviando) return;

    _mensaje.clear();

    setState(() {
      _items.add(_ChatItem.userText(texto));
      _enviando = true;
    });
    _bajar();

    final respuesta = await _chat.enviarMensaje(
      mensaje: texto,
      sesionId: _sesionId,
    );

    if (!mounted) return;

    setState(() {
      _enviando = false;
      _sesionId = respuesta['sesionId']?.toString() ?? _sesionId;
      _items.add(
        respuesta['success'] == true
            ? _ChatItem.botText(
                respuesta['respuesta']?.toString().isNotEmpty == true
                    ? respuesta['respuesta'].toString()
                    : 'No obtuve una respuesta. Intenta de nuevo.',
              )
            : _ChatItem.botText(
                respuesta['message']?.toString() ??
                    'No se pudo contactar al asistente.',
                error: true,
              ),
      );
    });
    _bajar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Asistente Barber King'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Nueva conversación',
            onPressed: _enviando
                ? null
                : () => setState(() {
                    _items
                      ..clear()
                      ..add(_ChatItem.botText('Hola'));
                    _sesionId = null;
                  }),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _items.length,
                itemBuilder: (_, index) =>
                    _ChatMessageItem(item: _items[index]),
              ),
            ),
            if (_enviando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'El asistente está pensando...',
                      style: TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            _ChatComposer(
              controller: _mensaje,
              disabled: _enviando,
              onAttach: () => _adjuntar(this),
              onSend: _enviarTexto,
            ),
          ],
        ),
      ),
    );
  }
}
