import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/solicitudes_service.dart';
import '../../widgets/common/app_field.dart';
import '../../widgets/common/app_ui.dart';
import '../barberos/perfil_barbero_screen.dart';
import '../home/pestana_scope.dart';

part '../../widgets/solicitudes/solicitud_card.dart';
part '../../widgets/solicitudes/solicitud_nota_dialogo.dart';
part '../../widgets/solicitudes/solicitud_piezas.dart';
part '../../widgets/solicitudes/solicitud_respuesta.dart';
part '../../widgets/solicitudes/solicitudes_logica.dart';

/// Bandeja del barbero y historial del cliente. Aquí se resuelve todo con un
/// toque; ya no hace falta chatear para saber si hay hueco.
class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final SolicitudesService _solicitudes = SolicitudesService();
  final AuthService _auth = AuthService();

  List<Map<String, dynamic>> _lista = [];
  int _rol = 3;
  int _pendientes = 0;
  String _filtro = 'pendiente';
  bool _cargando = true;
  int? _ocupada;

  bool get _esBarbero => _rol == 2;

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
        title: Text(_esBarbero ? 'Solicitudes' : 'Mis solicitudes'),
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
              onPressed: _elegirBarbero,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva solicitud'),
            ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando solicitudes...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  children: [
                    PageHeading(
                      title: _esBarbero ? 'Bandeja' : 'Lo que has pedido',
                      subtitle: _esBarbero
                          ? 'Responde con un toque y listo.'
                          : 'El barbero responde con un toque.',
                      actions: [
                        StatusPill(
                          label: '$_pendientes pendientes',
                          color: _pendientes == 0
                              ? AppColors.success
                              : AppColors.primary,
                          icon: Icons.forum_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SolicitudesFiltros(
                      filtro: _filtro,
                      onSeleccionar: (estado) =>
                          setState(() => _filtro = estado),
                    ),
                    const SizedBox(height: 14),
                    ..._filtradas.map(
                      (solicitud) => _SolicitudesCard(
                        solicitud: solicitud,
                        esBarbero: _esBarbero,
                        ocupada: _ocupada == solicitud['id'],
                        onResponder: (clave) => _responder(solicitud, clave),
                        onConNota: () => _conNota(solicitud),
                        onVerBarbero: _esBarbero
                            ? null
                            : () => _abrirBarbero(solicitud),
                      ),
                    ),
                    if (_filtradas.isEmpty)
                      _SolicitudesVacio(esBarbero: _esBarbero),
                  ],
                ),
              ),
      ),
    );
  }
}
