import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final mensaje = TextEditingController();
  final mensajes = <Map<String, dynamic>>[];
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  String _tokenUsuario = "";
  String? _sesionId;
  bool _cargando = true;

  // URL corregida y exacta según la estructura de tu app.js
  static const String _baseUrl = 'http://10.0.2.2';

  @override
  void initState() {
    super.initState();
    _cargarTokenDeSeguridad();
  }

  Future<void> _cargarTokenDeSeguridad() async {
    try {
      final tokenEncontrado = await _authService.obtenerToken();

      if (tokenEncontrado != null && tokenEncontrado.isNotEmpty) {
        setState(() {
          _tokenUsuario = tokenEncontrado;
          _cargando = false;
        });
      } else {
        _mostrarErrorAutenticacion("No se encontró una sesión activa.");
      }
    } catch (e) {
      _mostrarErrorAutenticacion("Error al leer el almacenamiento seguro.");
    }
  }

  void _mostrarErrorAutenticacion(String error) {
    setState(() {
      _cargando = false;
      mensajes.add({
        'tipo': 'bot',
        'texto': '🚨 Error: $error\n\nPor favor, vuelve a iniciar sesión.',
      });
    });
  }

  // 1. Enviar mensaje de texto normal
  Future<void> enviar() async {
    final texto = mensaje.text.trim();
    if (texto.isEmpty || _cargando || _tokenUsuario.isEmpty) return;

    setState(() {
      mensajes.add({'tipo': 'usuario', 'texto': texto});
      _cargando = true;
    });

    mensaje.clear();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chatear'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_tokenUsuario',
        },
        body: jsonEncode({
          'mensaje': texto,
          if (_sesionId != null) 'sesionId': _sesionId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _sesionId = data['sesionId'];
          mensajes.add({
            'tipo': 'bot',
            'texto': data['respuesta'] ?? 'Sin respuesta.',
          });
        });
      } else {
        setState(() {
          mensajes.add({
            'tipo': 'bot',
            'texto':
                data['message'] ??
                'Ocurrió un inconveniente al procesar el mensaje.',
          });
        });
      }
    } catch (e) {
      setState(() {
        mensajes.add({
          'tipo': 'bot',
          'texto': 'No se pudo establecer comunicación con el asistente.',
        });
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // 2. Seleccionar y enviar imagen para recomendar corte
  Future<void> _seleccionarYEnviarImagen(ImageSource source) async {
    if (_tokenUsuario.isEmpty) return;

    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (imagenSeleccionada == null) return;

      setState(() {
        mensajes.add({
          'tipo': 'usuario',
          'texto': '📷 Imagen enviada para recomendación',
          'imagenPath': imagenSeleccionada.path,
        });
        _cargando = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/recomendar-corte'),
      );

      request.headers['Authorization'] = 'Bearer $_tokenUsuario';

      if (_sesionId != null) {
        request.fields['sesionId'] = _sesionId!;
      }

      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagenSeleccionada.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final rec = data['recomendacion'];
        _sesionId = data['sesionId'];

        final String respuestaFormateada =
            '''
✂️ Corte recomendado: ${rec['corte_principal']}

📝 Explicación: ${rec['explicacion']}

💈 Alternativas:
${(rec['alternativas'] as List).map((a) => '• $a').join('\n')}

💡 Consejo del barbero:
${rec['recomendacion_barbero']}
''';

        setState(() {
          mensajes.add({
            'tipo': 'bot',
            'texto': respuestaFormateada,
            'imagenUrl': data['imagenUrl'],
          });
        });
      } else {
        setState(() {
          mensajes.add({
            'tipo': 'bot',
            'texto': data['message'] ?? 'No se pudo procesar la imagen.',
          });
        });
      }
    } catch (e) {
      setState(() {
        mensajes.add({'tipo': 'bot', 'texto': 'Error al subir la imagen: $e'});
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarYEnviarImagen(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Elegir de la galería',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarYEnviarImagen(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    mensaje.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Asistente Barber King"),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: mensajes.length,
              itemBuilder: (_, i) {
                final msg = mensajes[i];
                final esUsuario = msg['tipo'] == 'usuario';

                return Align(
                  alignment: esUsuario
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: esUsuario ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg['imagenPath'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(msg['imagenPath']),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (msg['imagenUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                msg['imagenUrl'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Text(
                          msg['texto'] ?? '',
                          style: TextStyle(
                            color: esUsuario ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_cargando && _tokenUsuario.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                  onPressed: _tokenUsuario.isEmpty
                      ? null
                      : _mostrarOpcionesImagen,
                ),
                Expanded(
                  child: TextField(
                    controller: mensaje,
                    enabled: _tokenUsuario.isNotEmpty,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _tokenUsuario.isEmpty
                          ? "Cargando autenticación..."
                          : "Escribe o sube una foto...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _tokenUsuario.isEmpty
                      ? Colors.grey
                      : AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _tokenUsuario.isEmpty ? null : enviar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
