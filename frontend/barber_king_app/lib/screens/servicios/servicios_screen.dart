import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/auth_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';
import '../citas/crear_cita_screen.dart';
import 'servicio_form_screen.dart';

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

  Future<void> _abrirFormulario([Map<String, dynamic>? servicio]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioFormScreen(servicio: servicio),
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(Map<String, dynamic> servicio) async {
    final id = int.tryParse('${servicio['id']}') ?? 0;
    if (id == 0) return;

    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar servicio',
      message:
          '¿Deseas eliminar "${servicio['nombre'] ?? 'este servicio'}"? '
          'Si tiene citas asociadas se pedirá una confirmación adicional.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar) return;

    var respuesta = await _service.eliminarServicio(id);

    if (!mounted) return;

    if (respuesta['statusCode'] == 409) {
      final detalles = respuesta['detalles'];
      final citas = detalles is Map ? int.tryParse('${detalles['citas']}') : null;

      final forzar = await showConfirmDialog(
        context,
        title: 'Servicio con citas asociadas',
        message:
            '${respuesta['message'] ?? 'No se puede eliminar el servicio.'}\n\n'
            '${citas != null && citas > 0 ? 'Tiene $citas cita(s) asociada(s).' : ''} '
            'Si continúas, se eliminarán también esas citas.',
        confirmLabel: 'Eliminar todo',
        destructive: true,
      );

      if (!forzar) return;

      respuesta = await _service.eliminarServicio(id, forzar: true);

      if (!mounted) return;
    }

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Operación completada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
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
                    AppCard(
                      gradient: AppColors.heroGradient,
                      borderColor: AppColors.primary.withValues(alpha: .3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.design_services_outlined,
                            color: AppColors.primary,
                            size: 34,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _esAdmin
                                      ? 'Catálogo de servicios'
                                      : 'Servicios premium',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _esAdmin
                                      ? 'Crea, edita y elimina los servicios del negocio.'
                                      : 'Elige el servicio ideal para tu próximo look.',
                                  style: const TextStyle(
                                    color: AppColors.subtitle,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Buscar servicio',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
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
                      ...filtrados.map(_servicioCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _servicioCard(Map<String, dynamic> servicio) {
    final activo = servicio['estado'] != false;
    final precio = AppFormat.money(servicio['precio']);
    final duracion = servicio['duracion'] ?? 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: AppColors.black,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio['nombre']?.toString() ?? 'Servicio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      servicio['descripcion']?.toString().isNotEmpty == true
                          ? servicio['descripcion'].toString()
                          : 'Servicio profesional Barber King',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (_esAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.subtitle,
                  ),
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      _abrirFormulario(servicio);
                    } else if (accion == 'eliminar') {
                      _eliminar(servicio);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined, size: 19),
                        title: Text('Editar'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.error,
                        ),
                        title: Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                precio,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.schedule_rounded,
                color: AppColors.muted,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '$duracion min',
                style: const TextStyle(
                  color: AppColors.subtitle,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              StatusPill(
                label: activo ? 'Activo' : 'Inactivo',
                color: activo ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          if (!_esAdmin) ...[
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CrearCitaScreen(
                        servicioInicial: int.tryParse('${servicio['id']}'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Reservar este servicio'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
