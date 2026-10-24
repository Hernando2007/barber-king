import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/disponibilidad_service.dart';
import '../../services/servicios_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/citas/crear_cita_campos.dart';
part '../../widgets/citas/crear_cita_agenda.dart';
part '../../widgets/citas/crear_cita_acciones.dart';

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

  String get _fechaIso => _fecha.toIso8601String().split('T').first;

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

  void _onServicioChanged(int? value) {
    setState(() => _servicioId = value);
    _consultarDisponibilidad();
  }

  void _onBarberoChanged(int? value) {
    setState(() => _barberoId = value);
    _consultarDisponibilidad();
  }

  void _onSeleccionarHora(String hora) {
    setState(() => _hora = hora);
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
                  const _CrearCitaHero(),
                  const SizedBox(height: 22),
                  _CrearCitaServicioField(
                    servicios: _listaServicios,
                    servicioId: _servicioId,
                    onChanged: _onServicioChanged,
                  ),
                  const SizedBox(height: 20),
                  _CrearCitaBarberoField(
                    barberos: _listaBarberos,
                    barberoId: _barberoId,
                    onChanged: _onBarberoChanged,
                  ),
                  const SizedBox(height: 20),
                  _CrearCitaFechaCard(
                    fecha: _fecha,
                    servicio: servicio,
                    onElegirFecha: _elegirFecha,
                  ),
                  const SizedBox(height: 22),
                  _CrearCitaHorariosSection(
                    seleccionIncompleta:
                        _barberoId == null || _servicioId == null,
                    consultando: _consultando,
                    horarios: _horarios,
                    horaSeleccionada: _hora,
                    onSeleccionarHora: _onSeleccionarHora,
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
