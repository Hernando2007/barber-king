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

part '../../widgets/chat/chat_conversacion_sync.dart';
part '../../widgets/chat/chat_conversacion_envio.dart';
part '../../widgets/chat/chat_conversacion_lista.dart';
part '../../widgets/chat/chat_conversacion_composer.dart';

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
                    child: _ChatConversacionLista(
                      mensajes: _mensajes,
                      controller: _scroll,
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
                  _ChatConversacionComposer(
                    controller: _composer,
                    enviando: _enviando,
                    onEnviar: _enviar,
                    onAdjuntar: _adjuntarImagen,
                  ),
                ],
              ),
      ),
    );
  }
}
