import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/cita_service.dart';
import '../../services/resena_service.dart';
import '../../widgets/barberos/barberos_acciones.dart';
import '../../widgets/barberos/barberos_calificacion.dart';
import '../../widgets/common/app_ui.dart';
import '../../widgets/resenas/resena_sheet.dart';
import '../../widgets/resenas/resenas_panel.dart';

class PerfilBarberoScreen extends StatefulWidget {
  final Map<String, dynamic> barbero;

  const PerfilBarberoScreen({super.key, required this.barbero});

  @override
  State<PerfilBarberoScreen> createState() => _PerfilBarberoScreenState();
}

class _PerfilBarberoScreenState extends State<PerfilBarberoScreen> {
  final BarberoService _barberos = BarberoService();
  final CitaService _citas = CitaService();
  final ResenaService _resenas = ResenaService();
  final AuthService _auth = AuthService();

  late Map<String, dynamic> _datos;
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
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    return nombre.isEmpty ? 'Barbero profesional' : nombre;
  }

  Future<void> _cargar() async {
    final id = int.tryParse('${widget.barbero['id']}');

    if (id == null) {
      setState(() => _cargando = false);
      return;
    }

    final futuraDetalle = _barberos.obtenerBarbero(id);
    final futuraUsuario = _auth.obtenerUsuario();
    final futuraResenas = _resenas.obtenerMias();
    final futuraCitas = _citas.obtenerCitas();

    final detalle = await futuraDetalle;
    final usuario = await futuraUsuario;
    final propias = (await futuraResenas).whereType<Map>();
    final citas = (await futuraCitas).whereType<Map>();

    if (!mounted) return;

    final calificadas = propias
        .map((resena) => int.tryParse('${resena['cita_id']}'))
        .whereType<int>()
        .toSet();

    int? pendiente;

    for (final cita in citas) {
      final barbero = cita['barberos'];
      final citaId = int.tryParse('${cita['id']}');
      final barberoId = barbero is Map ? int.tryParse('${barbero['id']}') : null;
      final completada = '${cita['estado'] ?? ''}'.toLowerCase() == 'completada';

      if (citaId == null || barberoId != id || !completada) continue;
      if (calificadas.contains(citaId)) continue;

      pendiente = citaId;
      break;
    }

    setState(() {
      if (detalle != null) {
        _datos = detalle;
      }
      _miPerfil =
          usuario != null && detalle != null && detalle['usuario_id'] == usuario['id'];
      _rol = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
      _citaPendiente = pendiente;
      _cargando = false;
    });
  }

  Future<void> _calificar() async {
    final citaId = _citaPendiente;
    final barberoId = _barberoId;

    if (citaId == null || barberoId == null) return;

    final publicada = await mostrarHojaResena(
      context,
      nombreBarbero: _nombre,
      citaId: citaId,
      barberoId: barberoId,
    );

    if (publicada) {
      await _cargar();
    }
  }

  Future<void> _reservar() async {
    await BarberosAcciones.reservar(context, _datos);
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

    final usuario = _usuario;
    final especialidad = _datos['especialidad']?.toString().isNotEmpty == true
        ? _datos['especialidad'].toString()
        : 'Barbero profesional';
    final descripcion = _datos['descripcion']?.toString().trim();
    final experiencia = int.tryParse('${_datos['experiencia'] ?? 0}') ?? 0;
    final disponible = _datos['disponible'] != false;
    final promedio = (_datos['calificacion_promedio'] as num?)?.toDouble() ?? 0;
    final totalResenas = int.tryParse('${_datos['total_resenas'] ?? 0}') ?? 0;
    final distancia = double.tryParse('${_datos['distancia_km'] ?? ''}') ??
        double.tryParse('${widget.barbero['distancia_km'] ?? ''}');
    final lugar = [
      _datos['ciudad']?.toString(),
      _datos['zona']?.toString(),
    ].where((valor) => valor != null && valor.trim().isNotEmpty).join(' · ');
    final barberoId = _barberoId;
    final puedeChatear = _rol != 1 && !_miPerfil;
    final puedeReservar = _rol != 1 && !_miPerfil;

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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            AppAvatar(
                              name: _nombre,
                              photoUrl: usuario['foto']?.toString(),
                              radius: 33,
                              fallbackIcon: Icons.content_cut_rounded,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: disponible
                                      ? AppColors.success
                                      : AppColors.muted,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.card,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nombre,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                especialidad,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              BarberosCalificacion(
                                promedio: promedio,
                                total: totalResenas,
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: disponible ? 'Disponible' : 'Ocupado',
                          color: disponible
                              ? AppColors.success
                              : AppColors.muted,
                        ),
                      ],
                    ),
                    if (lugar.isNotEmpty ||
                        experiencia > 0 ||
                        distancia != null) ...[
                      const SizedBox(height: 16),
                      if (lugar.isNotEmpty || distancia != null)
                        InfoRow(
                          icon: Icons.place_outlined,
                          label: 'Zona',
                          value: [
                            if (lugar.isNotEmpty) lugar,
                            if (distancia != null)
                              distancia < 1
                                  ? 'a ${(distancia * 1000).round()} m'
                                  : 'a ${distancia.toStringAsFixed(1)} km',
                          ].join(' · '),
                        ),
                      if (experiencia > 0)
                        InfoRow(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Experiencia',
                          value:
                              '$experiencia año${experiencia == 1 ? '' : 's'}',
                        ),
                    ],
                    if (descripcion != null && descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (puedeReservar) ...[
                PrimaryGradientButton(
                  label: 'Reservar cita',
                  icon: Icons.calendar_month_outlined,
                  onPressed: disponible ? _reservar : null,
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  if (puedeChatear) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            BarberosAcciones.abrirChat(context, _datos),
                        icon: const Icon(Icons.forum_outlined, size: 17),
                        label: const Text('Chatear'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          BarberosAcciones.abrirMapa(context, _datos),
                      icon: const Icon(Icons.map_outlined, size: 17),
                      label: const Text('Ubicación'),
                    ),
                  ),
                ],
              ),
              if (_rol == 3 && _citaPendiente != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _calificar,
                    icon: const Icon(Icons.star_outline_rounded, size: 17),
                    label: const Text('Calificar mi cita'),
                  ),
                ),
              ],
              if (barberoId != null) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Reseñas',
                  subtitle: totalResenas > 0
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
