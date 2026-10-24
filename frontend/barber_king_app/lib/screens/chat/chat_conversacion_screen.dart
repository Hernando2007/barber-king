import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../../core/formatters.dart';
import '../../services/chat_directo_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/chat/image_source_sheet.dart';
import '../../widgets/common/app_ui.dart';

class ChatConversacionScreen extends StatefulWidget {
  final Map<String, dynamic> contacto;

  const ChatConversacionScreen({super.key, required this.contacto});

  @override
  State<ChatConversacionScreen> createState() => _ChatConversacionScreenState();
}

class _ChatConversacionScreenState extends State<ChatConversacionScreen> {
  final ChatDirectoService _chat = ChatDirectoService();
  final UploadService _upload = UploadService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<Map<String, dynamic>> _mensajes = [];
  Timer? _timer;

  int _ultimoId = 0;
  bool _cargando = true;
  bool _enviando = false;

  int get _contactoId =>
      int.tryParse('${widget.contacto['usuario_id']}') ?? 0;

  String get _nombre {
    final nombre =
        '${widget.contacto['nombres'] ?? ''} '
        '${widget.contacto['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Conversación' : nombre;
  }

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _sincronizar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final respuesta = await _chat.obtenerMensajes(_contactoId);

    if (!mounted) return;

    if (respuesta['success'] == true) {
      final data = respuesta['data'] as Map<String, dynamic>;
      final lista = (data['mensajes'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      setState(() {
        _mensajes
          ..clear()
          ..addAll(lista);
        _ultimoId = _maxId(lista);
        _cargando = false;
      });

      _bajar();
    } else {
      setState(() => _cargando = false);
      if (mounted) {
        showAppSnack(
          context,
          respuesta['message']?.toString() ?? 'No se pudo cargar el chat.',
          error: true,
        );
      }
    }
  }

  int _maxId(List<Map<String, dynamic>> lista) {
    var max = 0;
    for (final item in lista) {
      final id = int.tryParse('${item['id']}') ?? 0;
      if (id > max) max = id;
    }
    return max;
  }

  Future<void> _sincronizar() async {
    if (!mounted || _enviando) return;

    final respuesta = await _chat.obtenerMensajes(
      _contactoId,
      ultimoId: _ultimoId,
    );

    if (!mounted || respuesta['success'] != true) return;

    final data = respuesta['data'] as Map<String, dynamic>;
    final nuevas = (data['mensajes'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    if (nuevas.isEmpty) return;

    setState(() {
      for (final mensaje in nuevas) {
        final id = int.tryParse('${mensaje['id']}') ?? 0;
        if (_mensajes.any((item) => item['id'] == mensaje['id'])) continue;
        _mensajes.add(mensaje);
        if (id > _ultimoId) _ultimoId = id;
      }
    });

    _bajar();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar() async {
    final texto = _composer.text.trim();

    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);

    final respuesta = await _chat.enviarMensaje(
      destinatarioId: _contactoId,
      mensaje: texto,
    );

    if (!mounted) return;

    setState(() => _enviando = false);

    if (respuesta['success'] == true) {
      _composer.clear();
      final enviado = Map<String, dynamic>.from(
        respuesta['data'] as Map,
      );
      setState(() {
        _mensajes.add({...enviado, 'esMio': true});
        final id = int.tryParse('${enviado['id']}') ?? 0;
        if (id > _ultimoId) _ultimoId = id;
      });
      _bajar();
    } else {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo enviar el mensaje.',
        error: true,
      );
    }
  }

  Future<void> _adjuntarImagen() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => ImageSourceSheet(onSelected: (value) {
        Navigator.pop(context, value);
      }),
    );

    if (source == null) return;

    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    setState(() => _enviando = true);

    final bytes = await file.readAsBytes();
    final subida = await _upload.subirImagen(bytes, filename: file.name);

    if (!mounted) return;

    if (subida == null || subida.isEmpty) {
      setState(() => _enviando = false);
      showAppSnack(
        context,
        'No se pudo subir la imagen.',
        error: true,
      );
      return;
    }

    final respuesta = await _chat.enviarMensaje(
      destinatarioId: _contactoId,
      mensaje: '',
      imagenUrl: subida,
    );

    if (!mounted) return;

    setState(() => _enviando = false);

    if (respuesta['success'] == true) {
      final enviado = Map<String, dynamic>.from(respuesta['data'] as Map);
      setState(() {
        _mensajes.add({...enviado, 'esMio': true});
        final id = int.tryParse('${enviado['id']}') ?? 0;
        if (id > _ultimoId) _ultimoId = id;
      });
      _bajar();
    } else {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo enviar la imagen.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final especialidad = widget.contacto['especialidad']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(
              name: _nombre,
              photoUrl: widget.contacto['foto']?.toString(),
              radius: 18,
              fallbackIcon: Icons.person_rounded,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (especialidad != null && especialidad.isNotEmpty)
                    Text(
                      especialidad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 10.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando conversación...')
            : Column(
                children: [
                  Expanded(
                    child: _mensajes.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 90),
                              const EmptyState(
                                icon: Icons.waving_hand_outlined,
                                title: 'Inicia la conversación',
                                message:
                                    'Envía un saludo para comenzar a coordinar tu próxima cita.',
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _mensajes.length,
                            itemBuilder: (_, index) =>
                                _burbuja(_mensajes[index]),
                          ),
                  ),
                  if (_enviando)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ),
                  _composerBar(),
                ],
              ),
      ),
    );
  }

  Widget _burbuja(Map<String, dynamic> mensaje) {
    final esMio = mensaje['esMio'] == true;
    final texto = mensaje['mensaje']?.toString() ?? '';
    final imagen = ApiConfig.resolveMedia(
      mensaje['imagen_url']?.toString(),
    );
    final hora = mensaje['created_at'] == null
        ? ''
        : AppFormat.time(
            AppFormat.toDate(mensaje['created_at'])
                ?.toLocal()
                .toIso8601String()
                .split('T')
                .last,
          );

    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          color: esMio ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 16),
          ),
          border: esMio ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagen != null && imagen.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagen,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.subtitle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
            ],
            if (texto.isNotEmpty)
              Text(
                texto,
                style: TextStyle(
                  color: esMio ? AppColors.black : AppColors.white,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            if (hora.isNotEmpty) ...[
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  hora,
                  style: TextStyle(
                    color: esMio
                        ? AppColors.black.withValues(alpha: .55)
                        : AppColors.muted,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _composerBar() {
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
            onPressed: _enviando ? null : _adjuntarImagen,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Adjuntar imagen',
          ),
          Expanded(
            child: TextField(
              controller: _composer,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _enviar(),
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
                onTap: _enviando ? null : _enviar,
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
