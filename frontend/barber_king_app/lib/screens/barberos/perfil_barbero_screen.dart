import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_servicio_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/resena_service.dart';
import '../../widgets/barberos/barbero_servicios_panel.dart';
import '../../widgets/barberos/barberos_acciones.dart';
import '../../widgets/barberos/perfil_barbero_acciones.dart';
import '../../widgets/barberos/perfil_barbero_hero.dart';
import '../../widgets/barberos/portafolio_galeria.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/resenas/resena_sheet.dart';
import '../../widgets/resenas/resenas_panel.dart';

part '../../widgets/barberos/perfil_barbero_datos.dart';

class PerfilBarberoScreen extends StatefulWidget {
  final Map<String, dynamic> barbero;

  const PerfilBarberoScreen({super.key, required this.barbero});

  @override
  State<PerfilBarberoScreen> createState() => _PerfilBarberoScreenState();
}

class _PerfilBarberoScreenState extends State<PerfilBarberoScreen> {
  final BarberoService _barberos = BarberoService();
  final BarberoServicioService _serviciosBarbero = BarberoServicioService();
  final CitaService _citas = CitaService();
  final ResenaService _resenas = ResenaService();
  final AuthService _auth = AuthService();

  late Map<String, dynamic> _datos;
  List<Map<String, dynamic>> _servicios = [];
  int _rol = 3;
  int? _citaPendiente;
  bool _miPerfil = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _datos = Map<String, dynamic>.from(widget.barbero);
    _cargar();
  }

  int? get _barberoId => int.tryParse('${_datos['id']}');

  Map<String, dynamic> get _usuario {
    final value = _datos['usuarios'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String get _nombre {
    final usuario = _usuario;
    final nombre = '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
        .trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Perfil del barbero')),
        body: const LoadingView(message: 'Cargando perfil...'),
      );
    }

    final barberoId = _barberoId;
    final puedeComprarCita = _rol != 1 && !_miPerfil;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil del barbero'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              PerfilBarberoHero(
                nombre: _nombre,
                foto: _foto,
                especialidad: _especialidad,
                promedio: _promedio,
                totalResenas: _totalResenas,
                disponible: _disponible,
                verificado: _verificado,
                lugar: _lugar,
                experiencia: _experiencia,
                distancia: _distancia,
                descripcion: _descripcion,
              ),
              const SizedBox(height: 16),
              PerfilBarberoAcciones(
                barbero: _datos,
                puedeReservar: puedeComprarCita,
                puedeSolicitar: puedeComprarCita,
                disponible: _disponible,
                puedeCalificar: _rol == 3 && _citaPendiente != null,
                onReservar: _reservar,
                onCalificar: _calificar,
              ),
              if (_servicios.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Qué hace',
                  subtitle: 'Sus servicios y lo que cobra por ellos.',
                  icon: Icons.content_cut_outlined,
                ),
                const SizedBox(height: 12),
                BarberoServiciosPanel(servicios: _servicios),
              ],
              if (barberoId != null) ...[
                const SizedBox(height: 22),
                BarberoPortafolioPanel(barberoId: barberoId),
              ],
              if (barberoId != null) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Reseñas',
                  subtitle: _totalResenas > 0
                      ? 'Lo que dicen los clientes'
                      : 'Sin opiniones todavía',
                  icon: Icons.reviews_outlined,
                ),
                const SizedBox(height: 12),
                ResenasBarberoPanel(barberoId: barberoId),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
