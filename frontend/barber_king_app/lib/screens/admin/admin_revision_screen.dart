import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';
import '../../services/admin_revision_service.dart';
import '../../widgets/common/app_field.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/admin/admin_revision_card.dart';
part '../../widgets/admin/admin_revision_detalle.dart';
part '../../widgets/admin/admin_revision_logica.dart';
part '../../widgets/admin/admin_revision_piezas.dart';

class AdminRevisionScreen extends StatefulWidget {
  const AdminRevisionScreen({super.key});

  @override
  State<AdminRevisionScreen> createState() => _AdminRevisionScreenState();
}

class _AdminRevisionScreenState extends State<AdminRevisionScreen> {
  final AdminRevisionService _revision = AdminRevisionService();

  List<Map<String, dynamic>> _pendientes = [];
  bool _cargando = true;
  int? _ocupado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verificación de barberos'),
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
            ? const LoadingView(message: 'Cargando la bandeja...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                  children: [
                    PageHeading(
                      title: 'Bandeja de verificación',
                      subtitle: 'Tú decides quién lleva el sello.',
                      actions: [
                        StatusPill(
                          label: '${_pendientes.length} pendientes',
                          color: _pendientes.isEmpty
                              ? AppColors.success
                              : AppColors.primary,
                          icon: Icons.workspace_premium_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_pendientes.isEmpty)
                      const EmptyState(
                        icon: Icons.verified_outlined,
                        title: 'Nadie espera revisión',
                        message:
                            'Cuando un barbero se registre sin diploma o la IA '
                            'no lo reconozca, aparecerá aquí.',
                      )
                    else
                      ..._pendientes.map(
                        (barbero) => _AdminRevisionCard(
                          barbero: barbero,
                          ocupado: _ocupado == barbero['barbero_id'],
                          onAprobar: () => _aprobar(barbero),
                          onRechazar: () => _rechazar(barbero),
                          onDocumento: () => _abrirDocumento(barbero),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
