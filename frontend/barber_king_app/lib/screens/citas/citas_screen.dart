import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../widgets/common/app_ui.dart';
import '../chat/chat_conversacion_screen.dart';
import 'crear_cita_screen.dart';

part '../../widgets/citas/citas_screen_logic.dart';
part '../../widgets/citas/citas_screen_filtros.dart';
part '../../widgets/citas/citas_screen_card.dart';
part '../../widgets/citas/citas_screen_acciones.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService _service = CitaService();
  final BarberoService _barberos = BarberoService();
  final AuthService _auth = AuthService();

  List<Map<String, dynamic>> _citas = [];
  Map<int, String> _nombresBarberos = {};

  int _rol = 3;
  String _filtro = 'Todas';
  bool _cargando = true;

  bool get _esAdmin => _rol == 1;
  bool get _esBarbero => _rol == 2;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final usuario = await _auth.obtenerUsuario();
    final rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;

    final data = await _service.obtenerCitas();
    final perfiles = rol == 3 ? await _barberos.obtenerBarberos() : [];

    if (!mounted) return;

    final mapa = <int, String>{};

    for (final item in perfiles.whereType<Map>()) {
      final id = int.tryParse('${item['id']}');
      final usuarioBarbero = item['usuarios'];

      if (id == null || usuarioBarbero is! Map) continue;

      mapa[id] =
          '${usuarioBarbero['nombres'] ?? ''} '
          '${usuarioBarbero['apellidos'] ?? ''}'.trim();
    }

    setState(() {
      _rol = rol;
      _citas = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _nombresBarberos = mapa;
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> get _filtradas {
    if (_filtro == 'Todas') return _citas;

    return _citas.where((cita) {
      return '${cita['estado'] ?? ''}'.toLowerCase() ==
          _filtro.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _esBarbero
              ? 'Agenda profesional'
              : _esAdmin
              ? 'Todas las citas'
              : 'Mis citas',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _esBarbero
          ? null
          : FloatingActionButton.extended(
              onPressed: _nuevaCita,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva cita'),
            ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando citas...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    _CitasScreenFiltros(
                      filtro: _filtro,
                      onSeleccionar: (estado) =>
                          setState(() => _filtro = estado),
                    ),
                    const SizedBox(height: 16),
                    if (filtradas.isEmpty)
                      _CitasScreenEmpty(
                        esBarbero: _esBarbero,
                        onNuevaCita: _nuevaCita,
                      )
                    else
                      ...filtradas.map(
                        (cita) => _CitasScreenCard(
                          cita: cita,
                          esBarbero: _esBarbero,
                          esAdmin: _esAdmin,
                          nombresBarberos: _nombresBarberos,
                          onCambiarEstado: _cambiarEstado,
                          onCancelar: _cancelar,
                          onChatCliente: _chatCliente,
                          onChatBarbero: _chatBarbero,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
