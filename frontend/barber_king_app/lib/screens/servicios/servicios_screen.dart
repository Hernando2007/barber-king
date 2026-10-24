import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';
import '../citas/crear_cita_screen.dart';
import 'servicio_form_screen.dart';

part '../../widgets/servicios/servicios_screen_header.dart';
part '../../widgets/servicios/servicios_screen_card.dart';
part '../../widgets/servicios/servicios_screen_acciones.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServicioService _service = ServicioService();
  final TextEditingController _busqueda = TextEditingController();

  List<Map<String, dynamic>> _servicios = [];
  int _rol = 3;
  bool _cargando = true;

  bool get _esAdmin => _rol == 1;

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
    final rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;

    final data = rol == 1
        ? await _service.obtenerServicios()
        : await _service.obtenerServicios(soloActivos: true);

    if (!mounted) return;

    setState(() {
      _rol = rol;
      _servicios = data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();

    if (texto.isEmpty) return _servicios;

    return _servicios.where((servicio) {
      return '${servicio['nombre'] ?? ''}'.toLowerCase().contains(texto) ||
          '${servicio['descripcion'] ?? ''}'.toLowerCase().contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo servicio'),
            )
          : null,
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando catálogo...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    _ServiciosHeaderCard(esAdmin: _esAdmin),
                    const SizedBox(height: 18),
                    _ServiciosBuscador(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    if (filtrados.isEmpty)
                      const EmptyState(
                        icon: Icons.content_cut_outlined,
                        title: 'Sin servicios',
                        message:
                            'No hay servicios disponibles en este momento.',
                      )
                    else
                      ...filtrados.map(
                        (servicio) => _ServiciosCard(
                          servicio: servicio,
                          esAdmin: _esAdmin,
                          onEditar: () => _abrirFormulario(servicio),
                          onEliminar: () => _eliminar(servicio),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
