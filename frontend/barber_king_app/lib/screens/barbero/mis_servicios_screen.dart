import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/barbero_servicio_service.dart';
import '../../services/servicios_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_field.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/barbero/mis_servicios_card.dart';
part '../../widgets/barbero/mis_servicios_logic.dart';

class MisServiciosScreen extends StatefulWidget {
  const MisServiciosScreen({super.key});

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> {
  final ServicioService _servicios = ServicioService();
  final BarberoServicioService _mios = BarberoServicioService();
  final UsuarioService _usuarios = UsuarioService();

  List<Map<String, dynamic>> _catalogo = [];
  final Map<int, bool> _atiendo = {};
  final Map<int, TextEditingController> _precios = {};
  final Map<int, TextEditingController> _duraciones = {};

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    for (final controller in [..._precios.values, ..._duraciones.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  int get _seleccionados => _atiendo.values.where((valor) => valor).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Servicios que atiendo'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const LoadingView(message: 'Cargando el catálogo...')
          : RefreshIndicator(
              onRefresh: _cargar,
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                children: [
                  PageHeading(
                    title: 'Tu carta de servicios',
                    subtitle:
                        'Marca los cortes que dominas. Solo te llegan '
                        'reservas de lo que atiendas, y puedes cobrarlos a tu '
                        'propio precio.',
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    EmptyState(
                      icon: Icons.design_services_outlined,
                      title: 'No pudimos cargar tus servicios',
                      message: _error!,
                      actionLabel: 'Reintentar',
                      onAction: _cargar,
                    )
                  else ...[
                    _CantidadPill(
                      cantidad: _seleccionados,
                      total: _catalogo.length,
                    ),
                    const SizedBox(height: 14),
                    ..._catalogo.map(_cardDelServicio),
                    const SizedBox(height: 22),
                    PrimaryGradientButton(
                      label: 'GUARDAR SERVICIOS',
                      icon: Icons.save_outlined,
                      loading: _guardando,
                      onPressed: _guardando ? null : _guardar,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
