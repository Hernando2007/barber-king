import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/colors.dart';
import '../../routes/app_routes.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/disponibilidad_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/gold_cajas.dart';
import '../../widgets/common/gold_widgets.dart';

typedef _Mapa = Map<String, dynamic>;

class CrearCitaScreen extends StatefulWidget {
  final int? barberoInicialId;
  // ignore: library_private_types_in_public_api
  final _Mapa? servicioInicial;
  final String? observaciones;

  const CrearCitaScreen({
    super.key,
    this.barberoInicialId,
    this.servicioInicial,
    this.observaciones,
  });

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  List<_Mapa> _barberos = [];
  List<_Mapa> _servicios = [];
  int? _barberoId;
  int? _servicioId;
  DateTime? _fecha;
  String? _hora;
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _barberoId = widget.barberoInicialId;
    _servicioId = int.tryParse('${widget.servicioInicial?['id']}');
    _cargar();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  // Al cambiar servicio o barbero, la hora elegida deja de ser válida.
  void _cambiar({int? barbero, int? servicio}) {
    setState(() {
      _barberoId = barbero ?? _barberoId;
      _servicioId = servicio ?? _servicioId;
      _fecha = null;
      _hora = null;
    });
  }

  Future<void> _cargar() async {
    final r = await Future.wait([
      BarberoService().obtenerBarberos(),
      ServicioService().obtenerServicios(),
    ]);
    if (!mounted) return;
    _Mapa mapa(e) => Map<String, dynamic>.from(e as Map);
    setState(() {
      _barberos = r[0].map(mapa).toList();
      _servicios = r[1].map(mapa).where((s) => s['estado'] != false).toList();
      _cargando = false;
    });
  }

  _Mapa? get _barbero =>
      _barberos.where((b) => b['id'] == _barberoId).firstOrNull;

  Future<void> _elegirHorario() async {
    if (_barberoId == null || _servicioId == null) {
      _aviso('Primero elige el servicio y el barbero.');
      return;
    }

    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 60)),
    );
    if (f == null) return;
    final slots = await DisponibilidadService().consultarDisponibilidad(
      barberoId: _barberoId!,
      servicioId: _servicioId!,
      fecha: DateFormat('yyyy-MM-dd').format(f),
    );
    if (!mounted) return;
    // Si es hoy, se ocultan las horas que ya pasaron.
    final libres = slots.map((e) => '$e').where((h) {
      final p = h.split(':');
      return !DateUtils.isSameDay(f, hoy) ||
          int.parse(p[0]) * 60 + int.parse(p[1]) > hoy.hour * 60 + hoy.minute;
    }).toList();

    if (libres.isEmpty) {
      _aviso('No hay horarios disponibles ese día.');
      return;
    }

    final hora = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in libres)
              ActionChip(
                label: Text(h),
                onPressed: () => Navigator.pop(ctx, h),
              ),
          ],
        ),
      ),
    );
    if (hora != null) {
      setState(() {
        _fecha = f;
        _hora = hora;
      });
    }
  }

  Future<void> _confirmar() async {
    if (_servicioId == null ||
        _barberoId == null ||
        _fecha == null ||
        _hora == null) {
      _aviso('Completa servicio, barbero, fecha y hora.');
      return;
    }
    setState(() => _enviando = true);
    final r = await CitaService().crearCita(
      barberoId: _barberoId!,
      servicioId: _servicioId!,
      fecha: DateFormat('yyyy-MM-dd').format(_fecha!),
      hora: _hora!,
      observaciones: widget.observaciones,
    );
    if (!mounted) return;
    setState(() => _enviando = false);

    if (r['success'] == true) {
      _aviso('Cita reservada correctamente.');
      Navigator.pushReplacementNamed(context, AppRoutes.citas);
    } else {
      _aviso(r['message']?.toString() ?? 'No se pudo reservar la cita.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotos = ((_barbero?['portafolio'] as List?) ?? [])
        .map((e) => '$e')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      Expanded(
                        child: Text(
                          'RESERVAR CITA',
                          style: tituloSerif(size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: IconoCirculo(Icons.edit_calendar_outlined, tam: 66),
                  ),
                  const SizedBox(height: 16),
                  CajaSeccion(
                    'TRABAJOS DEL BARBERO',
                    fotos.isEmpty
                        ? const Text(
                            'Elige un barbero para ver su portafolio.',
                            style: TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12,
                            ),
                          )
                        : FotosHorizontal(fotos),
                  ),
                  CajaSeccion(
                    'TIPO DE SERVICIO',
                    ServiciosSelector(
                      servicios: _servicios,
                      seleccionado: _servicioId,
                      onSeleccion: (s) => _cambiar(servicio: s['id'] as int?),
                    ),
                  ),
                  const EtiquetaCampo('Seleccionar barbero'),
                  DropdownButtonFormField<int>(
                    initialValue: _barbero == null ? null : _barberoId,
                    isExpanded: true,
                    hint: const Text('Barberos disponibles'),
                    dropdownColor: AppColors.card,
                    iconEnabledColor: AppColors.primary,
                    items: [
                      for (final b in _barberos)
                        DropdownMenuItem(
                          value: b['id'] as int,
                          child: Text(
                            nombreBarbero(b),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => _cambiar(barbero: v),
                  ),
                  const SizedBox(height: 14),
                  const EtiquetaCampo('Seleccionar fecha y hora'),
                  GestureDetector(
                    onTap: _elegirHorario,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.expand_more,
                          color: AppColors.primary,
                        ),
                      ),
                      child: Text(
                        _hora == null
                            ? 'Elegir fecha y hora'
                            : '${DateFormat('dd/MM/yyyy').format(_fecha!)} · $_hora',
                        style: TextStyle(
                          fontSize: 14,
                          color: _hora == null ? Colors.white54 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _enviando ? null : _confirmar,
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Text('CONFIRMAR RESERVA'),
                  ),
                ],
              ),
      ),
    );
  }
}
