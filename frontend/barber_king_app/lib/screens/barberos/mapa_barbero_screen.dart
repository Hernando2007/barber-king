import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/colors.dart';
import '../../services/barbero_service.dart';
import '../../services/ubicacion_service.dart';
import '../../widgets/barberos/mapa_barbero_panel.dart';
import '../../widgets/common/app_ui.dart';

class MapaBarberoScreen extends StatefulWidget {
  final Map<String, dynamic> barbero;

  const MapaBarberoScreen({super.key, required this.barbero});

  @override
  State<MapaBarberoScreen> createState() => _MapaBarberoScreenState();
}

class _MapaBarberoScreenState extends State<MapaBarberoScreen> {
  static const _refresco = Duration(seconds: 45);

  final BarberoService _barberos = BarberoService();
  final UbicacionService _ubicacion = UbicacionService();

  Timer? _timer;
  Map<String, dynamic>? _datos;
  PosicionUsuario? _cliente;
  double? _distancia;
  String? _error;
  bool _cargando = true;
  bool _actualizando = false;
  bool _consultando = false;
  bool _clienteConsultado = false;

  Map<String, dynamic> get _usuario {
    final value = widget.barbero['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String get _nombre {
    final usuario = _usuario;
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
  }

  @override
  void initState() {
    super.initState();
    _cargar(inicial: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargar({bool inicial = false}) async {
    if (_consultando) return;

    _consultando = true;
    setState(() {
      if (inicial) {
        _cargando = true;
        _error = null;
      } else {
        _actualizando = true;
      }
    });

    try {
      final id = int.tryParse('${widget.barbero['id']}');

      if (id == null) {
        setState(() {
          _error = 'No se pudo identificar al barbero.';
          _cargando = false;
          _actualizando = false;
        });
        return;
      }

      final respuesta = await _barberos.obtenerUbicacion(id);

      if (!mounted) return;

      if (respuesta['success'] != true) {
        final mensaje = respuesta['message']?.toString() ??
            'No fue posible obtener la ubicación.';

        if (_datos == null) {
          setState(() {
            _error = mensaje;
            _cargando = false;
            _actualizando = false;
          });
        } else {
          setState(() => _actualizando = false);
          showAppSnack(context, mensaje, error: true);
        }
        return;
      }

      final datos = Map<String, dynamic>.from(respuesta['data'] as Map);
      var cliente = _cliente;

      if (cliente == null && !_clienteConsultado) {
        cliente = await _posicionCliente();
        _clienteConsultado = true;
      }

      final punto = LatLng(
        (datos['latitud'] as num).toDouble(),
        (datos['longitud'] as num).toDouble(),
      );

      if (!mounted) return;

      setState(() {
        _datos = datos;
        _cliente = cliente;
        _distancia = cliente == null
            ? null
            : const Distance().as(
                LengthUnit.Kilometer,
                LatLng(cliente.latitud, cliente.longitud),
                punto,
              );
        _error = null;
        _cargando = false;
        _actualizando = false;
      });

      _reiniciarTimer();
    } finally {
      _consultando = false;
    }
  }

  Future<PosicionUsuario?> _posicionCliente() async {
    try {
      return await _ubicacion.obtenerPosicion();
    } on UbicacionException {
      return null;
    }
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_refresco, (_) => _cargar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ubicación del barbero'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizando ? null : () => _cargar(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _contenido()),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const LoadingView(message: 'Buscando la ubicación del barbero...');
    }

    final error = _error;

    if (error != null) {
      return MapaBarberoError(
        mensaje: error,
        onReintentar: () => _cargar(inicial: true),
      );
    }

    return MapaBarberoPanel(
      datos: _datos!,
      cliente: _cliente,
      nombre: _nombre,
      foto: _usuario['foto']?.toString(),
      especialidad: widget.barbero['especialidad']?.toString(),
      distanciaKm: _distancia,
      actualizando: _actualizando,
      onActualizar: () => _cargar(),
    );
  }
}
