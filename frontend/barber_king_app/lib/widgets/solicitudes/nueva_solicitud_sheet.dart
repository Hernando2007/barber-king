import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/barbero_servicio_service.dart';
import '../../services/solicitudes_service.dart';
import '../../widgets/common/app_field.dart';
import '../../widgets/common/app_ui.dart';

part 'nueva_solicitud_logica.dart';
part 'nueva_solicitud_motivo.dart';
part 'nueva_solicitud_piezas.dart';

/// La hoja con la que un cliente abre una solicitud: motivo fijo, fecha y
/// servicio opcionales, y una línea de contexto. No es un chat.
class NuevaSolicitudSheet extends StatefulWidget {
  final int barberoId;
  final String barberoNombre;
  final int? citaId;
  final String? motivoInicial;

  const NuevaSolicitudSheet({
    super.key,
    required this.barberoId,
    required this.barberoNombre,
    this.citaId,
    this.motivoInicial,
  });

  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context, {
    required int barberoId,
    String barberoNombre = 'el barbero',
    int? citaId,
    String? motivoInicial,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NuevaSolicitudSheet(
        barberoId: barberoId,
        barberoNombre: barberoNombre,
        citaId: citaId,
        motivoInicial: motivoInicial,
      ),
    );
  }

  @override
  State<NuevaSolicitudSheet> createState() => _NuevaSolicitudSheetState();
}

class _NuevaSolicitudSheetState extends State<NuevaSolicitudSheet> {
  final SolicitudesService _solicitudes = SolicitudesService();
  final BarberoServicioService _servicios = BarberoServicioService();
  final TextEditingController _nota = TextEditingController();

  List<Map<String, dynamic>> _motivos = [];
  List<dynamic> _serviciosBarbero = [];
  String? _elegido;
  DateTime? _fecha;
  int? _servicioId;
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivo = _motivoActual;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        child: _cargando
            ? const SizedBox(height: 220, child: LoadingView())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Arrastre(),
                  _Cabecera(nombre: widget.barberoNombre),
                  const SizedBox(height: 6),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._motivos.map(
                            (item) => _MotivoTile(
                              motivo: item,
                              activo: item['clave'] == _elegido,
                              onTap: () => _seleccionar('${item['clave']}'),
                            ),
                          ),
                          if (motivo != null && motivo['pide_fecha'] == true)
                            _ChipFecha(fecha: _fecha, onTap: _elegirFecha),
                          if (motivo != null &&
                              motivo['pide_servicio'] == true &&
                              _serviciosBarbero.isNotEmpty)
                            _DropdownServicio(
                              servicios: _serviciosBarbero,
                              seleccionado: _servicioId,
                              onCambiar: (id) =>
                                  setState(() => _servicioId = id),
                            ),
                          const SizedBox(height: 12),
                          AppField(
                            label: 'Una línea de contexto (opcional)',
                            hint: 'Ej: busco Fade con barba este sábado',
                            icon: Icons.edit_note_rounded,
                            controller: _nota,
                          ),
                          const SizedBox(height: 18),
                          PrimaryGradientButton(
                            label: 'ENVIAR SOLICITUD',
                            icon: Icons.send_rounded,
                            loading: _enviando,
                            onPressed: _enviando ? null : _enviar,
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
