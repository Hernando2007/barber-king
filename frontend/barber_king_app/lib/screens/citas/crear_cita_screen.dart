import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/disponibilidad_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';

class CrearCitaScreen extends StatefulWidget {
  final int? servicioInicial;
  final int? barberoInicial;

  const CrearCitaScreen({
    super.key,
    this.servicioInicial,
    this.barberoInicial,
  });

  @override
  State<CrearCitaScreen> createState() => _CrearCitaScreenState();
}

class _CrearCitaScreenState extends State<CrearCitaScreen> {
  final ServicioService _servicios = ServicioService();
  final BarberoService _barberos = BarberoService();
  final CitaService _citas = CitaService();
  final DisponibilidadService _disponibilidad = DisponibilidadService();

  List<Map<String, dynamic>> _listaServicios = [];
  List<Map<String, dynamic>> _listaBarberos = [];
  List<String> _horarios = [];

  int? _servicioId;
  int? _barberoId;
  String? _hora;

  DateTime _fecha = DateTime.now();
  bool _cargando = true;
  bool _consultando = false;
  bool _creando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final servicios = await _servicios.obtenerServicios(soloActivos: true);
    final barberos = await _barberos.obtenerBarberos();

    if (!mounted) return;

    final listaServicios = servicios
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final listaBarberos = barberos
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['disponible'] != false)
        .toList();

    setState(() {
      _listaServicios = listaServicios;
      _listaBarberos = listaBarberos;

      if (listaServicios.any((item) => item['id'] == widget.servicioInicial)) {
        _servicioId = widget.servicioInicial;
      }

      if (listaBarberos.any((item) => item['id'] == widget.barberoInicial)) {
        _barberoId = widget.barberoInicial;
      }

      _cargando = false;
    });

    if (_servicioId != null && _barberoId != null) {
      await _consultarDisponibilidad();
    }
  }

  Future<void> _consultarDisponibilidad() async {
    final servicioId = _servicioId;
    final barberoId = _barberoId;

    if (servicioId == null || barberoId == null) {
      setState(() {
        _horarios = [];
        _hora = null;
      });
      return;
    }

    setState(() {
      _consultando = true;
      _hora = null;
    });

    final data = await _disponibilidad.consultarDisponibilidad(
      barberoId: barberoId,
      servicioId: servicioId,
      fecha: _fechaIso,
    );

    if (!mounted) return;

    setState(() {
      _horarios = data
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
      _consultando = false;
    });
  }

  String get _fechaIso => _fecha.toIso8601String().split('T').first;

  Future<void> _elegirFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (value == null) return;

    setState(() => _fecha = value);
    await _consultarDisponibilidad();
  }

  Future<void> _reservar() async {
    if (_servicioId == null || _barberoId == null) {
      showAppSnack(context, 'Selecciona servicio y barbero.', error: true);
      return;
    }

    if (_hora == null) {
      showAppSnack(context, 'Selecciona un horario disponible.', error: true);
      return;
    }

    setState(() => _creando = true);

    final respuesta = await _citas.crearCita(
      barberoId: _barberoId!,
      servicioId: _servicioId!,
      fecha: _fechaIso,
      hora: _hora!,
    );

    if (!mounted) return;

    setState(() => _creando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Reserva procesada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  Map<String, dynamic>? get _servicioSeleccionado {
    for (final servicio in _listaServicios) {
      if (servicio['id'] == _servicioId) return servicio;
    }
    return null;
  }

  Map<String, dynamic>? get _barberoSeleccionado {
    for (final barbero in _listaBarberos) {
      if (barbero['id'] == _barberoId) return barbero;
    }
    return null;
  }

  String _nombreBarbero(Map<String, dynamic> barbero) {
    final usuario = barbero['usuarios'];
    if (usuario is Map) {
      final nombre =
          '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
      if (nombre.isNotEmpty) return nombre;
    }
    return 'Barbero';
  }

  @override
  Widget build(BuildContext context) {
    final servicio = _servicioSeleccionado;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reservar cita')),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando agenda...')
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppCard(
                    gradient: AppColors.heroGradient,
                    borderColor: AppColors.primary.withValues(alpha: .3),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Agenda tu cita con los mejores barberos de la ciudad.',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(
                    title: 'Servicio',
                    icon: Icons.design_services_outlined,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _servicioId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Selecciona un servicio',
                    ),
                    items: _listaServicios
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: int.tryParse('${item['id']}'),
                            child: Text(
                              '${item['nombre']} · ${AppFormat.money(item['precio'])}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _servicioId = value);
                      _consultarDisponibilidad();
                    },
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    title: 'Barbero',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _barberoId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Selecciona un barbero',
                    ),
                    items: _listaBarberos
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: int.tryParse('${item['id']}'),
                            child: Text(
                              _nombreBarbero(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _barberoId = value);
                      _consultarDisponibilidad();
                    },
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    title: 'Fecha',
                    icon: Icons.event_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    onTap: _elegirFecha,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    radius: 14,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppFormat.dateLong(_fecha),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                  if (servicio != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${AppFormat.money(servicio['precio'])} · '
                      '${servicio['duracion'] ?? 0} min',
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'Horarios disponibles',
                    subtitle: _barberoId == null || _servicioId == null
                        ? 'Selecciona barbero y servicio para ver la disponibilidad.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  if (_consultando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      ),
                    )
                  else if (_horarios.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 22,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.event_busy_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _barberoId == null || _servicioId == null
                                ? 'Completa los datos para consultar horarios.'
                                : 'No hay horarios disponibles para esta fecha.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: _horarios.map((hora) {
                        final seleccionado = _hora == hora;

                        return ChoiceChip(
                          label: Text(hora),
                          selected: seleccionado,
                          onSelected: (_) => setState(() => _hora = hora),
                          labelStyle: TextStyle(
                            color: seleccionado
                                ? AppColors.black
                                : AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 30),
                  PrimaryGradientButton(
                    label: 'CONFIRMAR RESERVA',
                    icon: Icons.check_circle_outline_rounded,
                    loading: _creando,
                    onPressed: _creando ? null : _reservar,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }
}
