import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../../services/chat_ia_service.dart';
import '../../widgets/chat/image_source_sheet.dart';
import '../../widgets/common/app_ui.dart';

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

  Future<void> _adjuntar() async {
    if (_enviando) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => ImageSourceSheet(
        onSelected: (value) => Navigator.pop(context, value),
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    if (!mounted) return;

    setState(() {
      _items.add(_ChatItem.userImage(bytes));
      _enviando = true;
    });
    _bajar();

    final respuesta = await _chat.recomendarCorte(
      bytes,
      filename: file.name.isNotEmpty ? file.name : 'corte.jpg',
      sesionId: _sesionId,
    );

    if (!mounted) return;

    setState(() {
      _enviando = false;
      _sesionId = respuesta['sesionId']?.toString() ?? _sesionId;

      if (respuesta['success'] == true) {
        final rec = respuesta['recomendacion'];
        _items.add(
          _ChatItem.botRecommendation(
            recommendation: rec is Map
                ? Map<String, dynamic>.from(rec)
                : <String, dynamic>{},
            imagenUrl: respuesta['imagenUrl']?.toString(),
          ),
        );
      } else {
        _items.add(
          _ChatItem.botText(
            respuesta['message']?.toString() ??
                'No se pudo analizar la imagen.',
            error: true,
          ),
        );
      }
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
                    _items.clear();
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
              child: _items.isEmpty
                  ? _bienvenida()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _items.length,
                      itemBuilder: (_, index) => _buildItem(_items[index]),
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
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _bienvenida() {
    final sugerencias = [
      '¿Qué corte me recomiendas para cabello rizado?',
      '¿Qué servicios ofrece Barber King?',
      '¿Cómo puedo reservar una cita?',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 18),
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.black,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tu asesor de estilo personal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pregunta lo que quieras o sube una foto y la IA te recomendará '
          'el corte que mejor va contigo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 26),
        ...sugerencias.map(
          (texto) => AppCard(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            radius: 15,
            onTap: _enviando ? null : () => _enviarTexto(texto),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(_ChatItem item) {
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
      return _recomendacion(item);
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

  Widget _recomendacion(_ChatItem item) {
    final rec = item.recommendation ?? {};
    final corte = rec['corte_principal']?.toString() ?? 'Corte personalizado';
    final explicacion = rec['explicacion']?.toString() ?? '';
    final alternativas = rec['alternativas'] is List
        ? (rec['alternativas'] as List)
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList()
        : <String>[];
    final consejo = rec['recomendacion_barbero']?.toString() ?? '';
    final imagen = ApiConfig.resolveMedia(item.imagenUrl);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .88,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagen != null)
              Image.network(
                imagen,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'RECOMENDACIÓN IA',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    corte,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (explicacion.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      explicacion,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (alternativas.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Alternativas',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: alternativas
                          .map(
                            (value) => Chip(
                              label: Text(value),
                              labelStyle: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.primary,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (consejo.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Consejo del barbero: $consejo',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer() {
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
            onPressed: _enviando ? null : _adjuntar,
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Analizar una foto',
          ),
          Expanded(
            child: TextField(
              controller: _mensaje,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _enviarTexto(),
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
                onTap: _enviando ? null : () => _enviarTexto(),
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
