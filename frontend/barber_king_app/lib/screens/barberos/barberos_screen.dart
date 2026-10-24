import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../widgets/barberos/barberos_screen_card.dart';
import '../../widgets/common/app_ui.dart';
import '../chat/chat_conversacion_screen.dart';
import '../citas/crear_cita_screen.dart';

class BarberosScreen extends StatefulWidget {
  const BarberosScreen({super.key});

  @override
  State<BarberosScreen> createState() => _BarberosScreenState();
}

class _BarberosScreenState extends State<BarberosScreen> {
  final BarberoService _service = BarberoService();
  final TextEditingController _busqueda = TextEditingController();

  List<Map<String, dynamic>> _barberos = [];
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
    final data = await _service.obtenerBarberos();

    if (!mounted) return;

    setState(() {
      _rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
      _barberos = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _barberos;

    return _barberos.where((barbero) {
      final usuario = barbero['usuarios'];
      final nombre = usuario is Map
          ? '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
          : '';
      final especialidad = '${barbero['especialidad'] ?? ''}';
      return nombre.toLowerCase().contains(texto) ||
          especialidad.toLowerCase().contains(texto);
    }).toList();
  }

  Map<String, dynamic> _usuario(Map<String, dynamic> barbero) {
    final value = barbero['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  Future<void> _abrirChat(Map<String, dynamic> barbero) async {
    final usuario = _usuario(barbero);

    if (usuario['id'] == null) {
      showAppSnack(context, 'No se pudo abrir el chat.', error: true);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversacionScreen(
          contacto: {
            'usuario_id': usuario['id'],
            'nombres': usuario['nombres'],
            'apellidos': usuario['apellidos'],
            'foto': usuario['foto'],
            'rol_id': 2,
            'especialidad': barbero['especialidad'],
          },
        ),
      ),
    );
  }

  Future<void> _reservar(Map<String, dynamic> barbero) async {
    final guardada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearCitaScreen(
          barberoInicial: int.tryParse('${barbero['id']}'),
        ),
      ),
    );

    if (guardada == true && mounted) {
      showAppSnack(context, 'Tu cita fue registrada correctamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuestros barberos'),
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
            ? const LoadingView(message: 'Cargando equipo...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Profesionales especializados para brindarte la mejor experiencia.',
                      style: TextStyle(
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
                        hintText: 'Buscar por nombre o especialidad',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (filtrados.isEmpty)
                      const EmptyState(
                        icon: Icons.people_alt_outlined,
                        title: 'Sin barberos disponibles',
                        message:
                            'El equipo se está actualizando. Vuelve a intentarlo pronto.',
                      )
                    else
                      ...filtrados.map(
                        (barbero) => BarberosScreenCard(
                          barbero: barbero,
                          puedeChatear: _rol != 1,
                          puedeReservar: _rol != 1,
                          onChat: () => _abrirChat(barbero),
                          onReservar: () => _reservar(barbero),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
