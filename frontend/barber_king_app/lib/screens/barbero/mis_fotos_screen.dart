import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/portafolio_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/barbero/mis_fotos_cuadricula.dart';
part '../../widgets/barbero/mis_fotos_logica.dart';
part '../../widgets/barbero/mis_fotos_piezas.dart';

/// Copia los topes que impone el backend en /barberos/portafolio/mis.
const int _limiteTotal = 24;
const int _limitePorEnvio = 6;

class MisFotosScreen extends StatefulWidget {
  const MisFotosScreen({super.key});

  @override
  State<MisFotosScreen> createState() => _MisFotosScreenState();
}

class _MisFotosScreenState extends State<MisFotosScreen> {
  final PortafolioService _portafolio = PortafolioService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _fotos = [];
  List<XFile> _pendientes = [];

  bool _cargando = true;
  bool _subiendo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  int get _espacioRestante => max(0, _limiteTotal - _fotos.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis fotos'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const LoadingView(message: 'Cargando tu portafolio...')
          : RefreshIndicator(
              onRefresh: _cargar,
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                children: [
                  PageHeading(
                    title: 'Tu trabajo, a la vista',
                    subtitle:
                        'El cliente reserva por lo que ve. Muestra cortes '
                        'reales: barba, degradados, barba y diseño.',
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    EmptyState(
                      icon: Icons.broken_image_outlined,
                      title: 'No pudimos cargar tus fotos',
                      message: _error!,
                      actionLabel: 'Reintentar',
                      onAction: _cargar,
                    )
                  else ...[
                    _CuadroContador(
                      publicadas: _fotos.length,
                      limite: _limiteTotal,
                    ),
                    const SizedBox(height: 14),
                    _Cuadricula(
                      fotos: _fotos,
                      pendientes: _pendientes,
                      onBorrar: _borrar,
                      onQuitar: _quitarPendiente,
                      onAmpliar: _ampliar,
                    ),
                    const SizedBox(height: 22),
                    PrimaryGradientButton(
                      label: _pendientes.isEmpty
                          ? 'AGREGAR FOTOS'
                          : 'PUBLICAR ${_pendientes.length} '
                                '${_pendientes.length == 1 ? 'FOTO' : 'FOTOS'}',
                      icon: _pendientes.isEmpty
                          ? Icons.add_a_photo_outlined
                          : Icons.cloud_upload_outlined,
                      loading: _subiendo,
                      onPressed: _subiendo
                          ? null
                          : (_pendientes.isEmpty ? _elegir : _publicar),
                    ),
                    if (_pendientes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _subiendo ? null : _descartar,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Descartar la selección'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.subtitle,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
