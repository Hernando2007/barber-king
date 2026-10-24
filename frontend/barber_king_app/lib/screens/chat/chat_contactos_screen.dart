import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/chat_directo_service.dart';
import '../../widgets/common/app_ui.dart';
import 'chat_conversacion_screen.dart';

class ChatContactosScreen extends StatefulWidget {
  const ChatContactosScreen({super.key});

  @override
  State<ChatContactosScreen> createState() => _ChatContactosScreenState();
}

class _ChatContactosScreenState extends State<ChatContactosScreen> {
  final ChatDirectoService _chat = ChatDirectoService();
  final TextEditingController _busqueda = TextEditingController();

  List<Map<String, dynamic>> _contactos = [];
  int _rol = 3;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final usuario = await AuthService().obtenerUsuario();
    final respuesta = await _chat.obtenerContactos();

    if (!mounted) return;

    setState(() {
      _rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
      _contactos = respuesta['success'] == true
          ? (respuesta['data'] as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList()
          : [];
      _cargando = false;
    });

    if (respuesta['success'] != true && mounted) {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudieron cargar los chats.',
        error: true,
      );
    }
  }

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _contactos;

    return _contactos.where((contacto) {
      final nombre =
          '${contacto['nombres'] ?? ''} ${contacto['apellidos'] ?? ''}'
              .toLowerCase();
      return nombre.contains(texto);
    }).toList();
  }

  Future<void> _abrir(Map<String, dynamic> contacto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversacionScreen(contacto: contacto),
      ),
    );

    _cargar();
  }

  String get _titulo {
    if (_rol == 2) return 'Mensajes de clientes';
    if (_rol == 1) return 'Conversaciones';
    return 'Chatea con tu barbero';
  }

  String get _subtitulo {
    if (_rol == 2) return 'Responde a las consultas de tus clientes.';
    if (_rol == 1) return 'Supervisa las conversaciones de la plataforma.';
    return 'Resuelve dudas y agenda tu próxima cita por chat.';
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_titulo),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando contactos...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  children: [
                    Text(
                      _subtitulo,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar contacto',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (filtrados.isEmpty)
                      EmptyState(
                        icon: Icons.forum_outlined,
                        title: 'Sin conversaciones',
                        message: _rol == 2
                            ? 'Cuando un cliente reserve contigo podrás chatear con él.'
                            : 'Aún no hay barberos disponibles para chatear.',
                        actionLabel: 'Actualizar',
                        onAction: _cargar,
                      )
                    else
                      ...filtrados.map(_contactoCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _contactoCard(Map<String, dynamic> contacto) {
    final nombre =
        '${contacto['nombres'] ?? ''} ${contacto['apellidos'] ?? ''}'.trim();
    final ultimo = contacto['ultimo_mensaje'];
    final ultimoMap = ultimo is Map ? Map<String, dynamic>.from(ultimo) : null;
    final mensaje = ultimoMap == null
        ? 'Inicia la conversación'
        : (ultimoMap['mensaje']?.toString().isNotEmpty == true
              ? ultimoMap['mensaje'].toString()
              : 'Imagen enviada');
    final fecha = ultimoMap?['created_at'];
    final especialidad = contacto['especialidad']?.toString();
    final esBarbero = int.tryParse('${contacto['rol_id']}') == 2;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () => _abrir(contacto),
      child: Row(
        children: [
          AppAvatar(
            name: nombre.isEmpty ? 'Usuario' : nombre,
            photoUrl: contacto['foto']?.toString(),
            radius: 24,
            fallbackIcon:
                esBarbero ? Icons.content_cut_rounded : Icons.person_rounded,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombre.isEmpty ? 'Usuario' : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (fecha != null)
                      Text(
                        AppFormat.date(fecha),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  especialidad != null && especialidad.isNotEmpty
                      ? especialidad
                      : '${contacto['rol'] ?? (esBarbero ? 'Barbero' : 'Cliente')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mensaje,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ultimoMap == null
                        ? AppColors.muted
                        : AppColors.subtitle,
                    fontSize: 11.5,
                    fontStyle: ultimoMap == null
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
