import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../widgets/barberos/barberos_acciones.dart';
import '../../widgets/barberos/barberos_cerca_boton.dart';
import '../../widgets/barberos/barberos_destacados_panel.dart';
import '../../widgets/barberos/barberos_screen_lista.dart';
import '../../widgets/common/app_ui.dart';

class BarberosScreen extends StatefulWidget {
  const BarberosScreen({super.key});

  @override
  State<BarberosScreen> createState() => _BarberosScreenState();
}

class _BarberosScreenState extends State<BarberosScreen> {
  final BarberoService _service = BarberoService();
  final TextEditingController _busqueda = TextEditingController();

  List<Map<String, dynamic>> _barberos = [];
  List<Map<String, dynamic>> _destacados = [];
  int _rol = 3;
  bool _cargando = true;
  bool _cercaDeMi = false;

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

  List<Map<String, dynamic>> _mapa(List<dynamic> data) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final usuario = await AuthService().obtenerUsuario();
    final resultados = await Future.wait([
      _service.obtenerBarberos(),
      _service.obtenerDestacados(),
    ]);

    if (!mounted) return;

    setState(() {
      _rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
      _barberos = _mapa(resultados[0]);
      _destacados = _mapa(resultados[1]);
      _cercaDeMi = false;
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
      final lugar = '${barbero['ciudad'] ?? ''} ${barbero['zona'] ?? ''}';

      return nombre.toLowerCase().contains(texto) ||
          especialidad.toLowerCase().contains(texto) ||
          lugar.toLowerCase().contains(texto);
    }).toList();
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
                    BarberosDestacadosPanel(barberos: _destacados),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _busqueda,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: _cercaDeMi
                                  ? 'Buscar en barberos cercanos'
                                  : 'Buscar por nombre, especialidad o zona',
                              prefixIcon: const Icon(Icons.search_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        BarberosCercaBoton(
                          activo: _cercaDeMi,
                          onCerca: (lista) => setState(() {
                            _barberos = lista;
                            _cercaDeMi = true;
                          }),
                          onTodos: _cargar,
                        ),
                      ],
                    ),
                    if (_cercaDeMi) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Barberos a menos de 15 km de tu ubicación.',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    BarberosLista(
                      barberos: filtrados,
                      puedeChatear: _rol != 1,
                      puedeReservar: _rol != 1,
                      cercaActiva: _cercaDeMi,
                      onChat: (barbero) =>
                          BarberosAcciones.abrirChat(context, barbero),
                      onReservar: (barbero) =>
                          BarberosAcciones.reservar(context, barbero),
                      onMapa: (barbero) =>
                          BarberosAcciones.abrirMapa(context, barbero),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
