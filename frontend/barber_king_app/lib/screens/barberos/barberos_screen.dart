import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../widgets/barberos/barberos_acciones.dart';
import '../../widgets/barberos/barberos_cerca_boton.dart';
import '../../widgets/barberos/barberos_destacados_panel.dart';
import '../../widgets/barberos/barberos_encabezado.dart';
import '../../widgets/barberos/barberos_filtro_servicio.dart';
import '../../widgets/barberos/barberos_filtro_verificados.dart';
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
  bool _soloVerificados = false;

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

  Future<void> _filtrarPorServicio(int? servicioId) async {
    if (servicioId == null) {
      await _cargar();
      return;
    }

    final barberos = await _service.obtenerBarberos(servicioId: servicioId);

    if (!mounted) return;

    setState(() {
      _barberos = _mapa(barberos);
      _cercaDeMi = false;
    });
  }

  int get _verificados => _barberos
      .where((barbero) => barbero['verificacion_estado'] == 'aprobado')
      .length;

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();

    return _barberos.where((barbero) {
      if (_soloVerificados && barbero['verificacion_estado'] != 'aprobado') {
        return false;
      }

      if (texto.isEmpty) return true;

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
    final lista = BarberosLista(
      barberos: filtrados,
      puedeReservar: _rol != 1,
      cercaActiva: _cercaDeMi,
      soloVerificados: _soloVerificados,
      onReservar: (barbero) => BarberosAcciones.reservar(context, barbero),
      onAbrirPerfil: (barbero) => BarberosAcciones.abrirPerfil(context, barbero),
    );

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    BarberosEncabezado(
                      total: _barberos.length,
                      verificados: _verificados,
                    ),
                    const SizedBox(height: 18),
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
                                  : 'Buscar barbero o zona',
                              prefixIcon: const Icon(Icons.search_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 16),
                    BarberosFiltroVerificados(
                      soloVerificados: _soloVerificados,
                      total: _barberos.length,
                      verificados: _verificados,
                      onCambiar: (valor) =>
                          setState(() => _soloVerificados = valor),
                    ),
                    const SizedBox(height: 16),
                    BarberosFiltroServicio(
                      onSeleccionar: _filtrarPorServicio,
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
                    if (filtrados.isEmpty)
                      lista
                    else ...[
                      SectionHeader(
                        title: 'Equipo',
                        subtitle: _soloVerificados
                            ? '${filtrados.length} verificado${filtrados.length == 1 ? '' : 's'}'
                            : '${filtrados.length} barbero${filtrados.length == 1 ? '' : 's'}',
                        icon: Icons.people_alt_outlined,
                      ),
                      const SizedBox(height: 12),
                      lista,
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
