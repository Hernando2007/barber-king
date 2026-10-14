import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_widgets.dart';
import 'crear_servicio_screen.dart';

typedef _Mapa = Map<String, dynamic>;

/// Servicios. Barbero: los suyos. Admin: todos. Cliente: solo lectura.
class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final _servicios = ServicioService();
  List<_Mapa> _lista = [];
  int _rol = 3;
  bool _cargando = true;

  bool get _puedeEditar => _rol == 1 || _rol == 2;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _cargar() async {
    final usuario = await AuthService().obtenerUsuario();
    final rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
    final data = rol == 2
        ? await _servicios.obtenerMisServicios()
        : await _servicios.obtenerServicios();
    if (!mounted) return;
    setState(() {
      _rol = rol;
      _lista = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _cargando = false;
    });
  }

  Future<void> _abrir([_Mapa? servicio]) async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearServicioScreen(servicio: servicio),
      ),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _eliminar(_Mapa s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Deseas eliminar "${s['nombre']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final r = await _servicios.eliminarServicio(s['id'] as int);
    if (!mounted) return;
    _aviso(
      r['success'] == true
          ? 'Servicio eliminado.'
          : '${r['message'] ?? 'No se pudo eliminar.'}',
    );
    if (r['success'] == true) _cargar();
  }

  Widget _tarjeta(_Mapa s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          FotoRed(url: s['imagen']?.toString(), ancho: 72, alto: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s['nombre']}',
                  style: tituloSerif(size: 15, color: Colors.white),
                ),
                if ('${s['descripcion'] ?? ''}'.isNotEmpty)
                  Text(
                    '${s['descripcion']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${precioCOP(num.tryParse('${s['precio']}') ?? 0)} · ${s['duracion']} min',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (_puedeEditar)
            Column(
              children: [
                IconButton(
                  onPressed: () => _abrir(s),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminar(s),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _puedeEditar
          ? FloatingActionButton.extended(
              onPressed: _abrir,
              icon: const Icon(Icons.add),
              label: const Text('NUEVO SERVICIO'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: Text('SERVICIOS', style: tituloSerif(size: 22)),
                ),
              ],
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        children: _lista.isEmpty
                            ? [
                                const SizedBox(height: 60),
                                const Center(
                                  child: Text(
                                    'Aún no hay servicios.',
                                    style: TextStyle(color: AppColors.subtitle),
                                  ),
                                ),
                              ]
                            : _lista.map(_tarjeta).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
