import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/gold_widgets.dart';

typedef _Mapa = Map<String, dynamic>;

/// Panel del administrador: resumen + listados con eliminación (barberos, servicios, reseñas).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _secciones = [
    'Resumen',
    'Usuarios',
    'Barberos',
    'Citas',
    'Servicios',
    'Reseñas',
  ];
  static const _eliminables = {2, 4, 5};
  final _admin = AdminService();
  int _sec = 0;
  _Mapa _datos = {};
  List<_Mapa> _items = [];
  bool _cargando = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (_sec == 0) {
        _datos = await _admin.dashboard();
      } else {
        final lista = await [
          _admin.usuarios,
          _admin.barberos,
          _admin.citas,
          _admin.servicios,
          _admin.resenas,
        ][_sec - 1]();
        _items = lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {
      _error = 'No se pudo cargar la información.';
    }
    if (mounted) setState(() => _cargando = false);
  }

  (String, String) _texto(_Mapa m) {
    final servicio = m['servicios'] is Map
        ? '${(m['servicios'] as Map)['nombre']}'
        : 'Servicio';
    switch (_sec) {
      case 1:
        return (
          '${m['nombres'] ?? ''} ${m['apellidos'] ?? ''}'.trim(),
          '${m['correo'] ?? ''}',
        );
      case 2:
        return (
          nombreBarbero(m),
          '${m['especialidad'] ?? ''} · ${m['experiencia'] ?? 0} años',
        );
      case 3:
        return (servicio, '${m['fecha']} ${m['hora']} · ${m['estado']}');
      case 4:
        return (
          '${m['nombre']}',
          precioCOP(num.tryParse('${m['precio']}') ?? 0),
        );
      default:
        return ('★ ${m['calificacion']}', '${m['comentario'] ?? ''}');
    }
  }

  Future<void> _eliminar(_Mapa m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('Esta acción no se puede deshacer.'),
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
    try {
      final borrar = {
        2: _admin.eliminarBarbero,
        4: _admin.eliminarServicio,
        5: _admin.eliminarResena,
      };
      await borrar[_sec]!(m['id']);
      _cargar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el registro.')),
        );
      }
    }
  }

  Widget _resumen() {
    final r = Map<String, dynamic>.from(_datos['resumen'] ?? {});
    final c = Map<String, dynamic>.from(_datos['citas'] ?? {});
    final tarjetas = [
      ('Usuarios', r['totalUsuarios'], Icons.people_outline),
      ('Barberos', r['totalBarberos'], Icons.content_cut),
      ('Servicios', r['totalServicios'], Icons.design_services_outlined),
      ('Citas', r['totalCitas'], Icons.calendar_month),
      ('Reseñas', r['totalResenas'], Icons.star_outline),
      ('Pendientes', c['pendientes'], Icons.pending_actions),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        for (final t in tarjetas)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(t.$3, color: AppColors.primary),
                Text(
                  '${t.$2 ?? 0}',
                  style: tituloSerif(size: 26, color: Colors.white),
                ),
                Text(
                  t.$1.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _fila(_Mapa m) {
    final (titulo, detalle) = _texto(m);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  detalle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_eliminables.contains(_sec))
            IconButton(
              onPressed: () => _eliminar(m),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BARBER KING', style: tituloSerif(size: 22)),
                        const Text(
                          'Administrador',
                          style: TextStyle(
                            color: AppColors.subtitle,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout, color: AppColors.primary),
                    onPressed: () async {
                      await AuthService().cerrarSesion();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (_) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: _secciones.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(_secciones[i].toUpperCase()),
                  selected: _sec == i,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _sec == i ? AppColors.black : Colors.white,
                  ),
                  onSelected: (_) {
                    _sec = i;
                    _cargar();
                  },
                ),
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: _error != null
                            ? [
                                const SizedBox(height: 60),
                                Center(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: AppColors.subtitle,
                                    ),
                                  ),
                                ),
                              ]
                            : _sec == 0
                            ? [_resumen()]
                            : _items.isEmpty
                            ? [
                                const SizedBox(height: 60),
                                const Center(
                                  child: Text(
                                    'Sin registros.',
                                    style: TextStyle(color: AppColors.subtitle),
                                  ),
                                ),
                              ]
                            : _items.map(_fila).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
