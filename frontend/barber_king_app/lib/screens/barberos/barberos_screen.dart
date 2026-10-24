import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
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

  String _nombre(Map<String, dynamic> barbero) {
    final usuario = _usuario(barbero);
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
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
                      ...filtrados.map(_barberoCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _barberoCard(Map<String, dynamic> barbero) {
    final usuario = _usuario(barbero);
    final nombre = _nombre(barbero);
    final especialidad = barbero['especialidad']?.toString().isNotEmpty == true
        ? barbero['especialidad'].toString()
        : 'Barbero profesional';
    final descripcion = barbero['descripcion']?.toString();
    final experiencia = int.tryParse('${barbero['experiencia'] ?? 0}') ?? 0;
    final disponible = barbero['disponible'] != false;
    final foto = usuario['foto']?.toString() ?? barbero['foto_trabajo']?.toString();
    final puedeReservar = _rol != 1;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    name: nombre,
                    photoUrl: foto,
                    radius: 29,
                    fallbackIcon: Icons.content_cut_rounded,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: disponible
                            ? AppColors.success
                            : AppColors.muted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.card,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      especialidad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    if (experiencia > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        '$experiencia año${experiencia == 1 ? '' : 's'} de experiencia',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StatusPill(
                label: disponible ? 'Disponible' : 'Ocupado',
                color: disponible ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          if (descripcion != null && descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              descripcion,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (foto != null && ApiConfig.resolveMedia(foto) != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                ApiConfig.resolveMedia(foto)!,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _rol == 1 ? null : () => _abrirChat(barbero),
                  icon: const Icon(Icons.forum_outlined, size: 17),
                  label: const Text('Chatear'),
                ),
              ),
              if (puedeReservar) ...[
                const SizedBox(width: 9),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: disponible ? () => _reservar(barbero) : null,
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      size: 17,
                    ),
                    label: const Text('Reservar'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
