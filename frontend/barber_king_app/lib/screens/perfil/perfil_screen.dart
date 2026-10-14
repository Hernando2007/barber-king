import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/colors.dart';
import '../../services/cita_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/gold_cajas.dart';
import '../../widgets/common/gold_widgets.dart';
import '../citas/citas_screen.dart';
import '../citas/crear_cita_screen.dart';
import 'ajustes_screen.dart';

typedef _Mapa = Map<String, dynamic>;

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  _Mapa? _perfil;
  List<_Mapa> _citas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final r = await Future.wait<Object?>([
      UsuarioService().obtenerPerfilActual(),
      CitaService().obtenerCitas(),
    ]);
    if (!mounted) return;
    setState(() {
      _perfil = r[0] as _Mapa?;
      _citas = (r[1] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _cargando = false;
    });
  }

  String _estado(_Mapa c) => '${c['estado']}'.toLowerCase();

  DateTime? _momento(_Mapa c) {
    final hora = '${c['hora']}';
    return DateTime.tryParse(
      '${c['fecha']}T${hora.length >= 5 ? hora.substring(0, 5) : hora}',
    );
  }

  String _resumen(_Mapa c) {
    final f = _momento(c);
    final cuando = f == null
        ? '${c['fecha']}'
        : DateFormat('dd/MM/yyyy · HH:mm').format(f);
    final servicio = c['servicios'] is Map
        ? (c['servicios'] as Map)['nombre']
        : null;
    return '$cuando — ${servicio ?? 'Servicio'}';
  }

  void _ir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    final p = _perfil ?? {};
    final ahora = DateTime.now();
    final proximas = _citas.where((c) {
      final f = _momento(c);
      return _estado(c) != 'completada' &&
          _estado(c) != 'cancelada' &&
          f != null &&
          f.isAfter(ahora);
    }).toList();
    final hechas = _citas
        .where((c) => _estado(c) == 'completada')
        .toList()
        .reversed
        .take(3)
        .toList();
    final anio = DateTime.tryParse('${p['created_at']}')?.year;

    return SafeArea(
      child: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      Expanded(
                        child: Text('PERFIL', style: tituloSerif(size: 24)),
                      ),
                      IconButton(
                        onPressed: () => _ir(AjustesScreen(perfil: p)),
                        icon: const Icon(Icons.menu, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: FotoRed(
                        url: p['foto']?.toString(),
                        ancho: 104,
                        alto: 104,
                        circular: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      UsuarioService().nombreCompleto(p).toUpperCase(),
                      style: tituloSerif(size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '${p['correo'] ?? ''}',
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (anio != null)
                    Center(
                      child: Text(
                        'Miembro desde $anio',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  CajaSeccion(
                    'MIS CITAS',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            proximas.isEmpty
                                ? 'No tienes citas próximas.'
                                : 'Próxima: ${_resumen(proximas.first)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _ir(const CitasScreen()),
                          child: const Text('Ver todas mis citas'),
                        ),
                      ],
                    ),
                  ),
                  CajaSeccion(
                    'ÚLTIMOS SERVICIOS',
                    hechas.isEmpty
                        ? const Text(
                            'Aún no tienes servicios completados.',
                            style: TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12,
                            ),
                          )
                        : Column(
                            children: [
                              for (final c in hechas)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.content_cut,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _resumen(c),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () => _ir(const CrearCitaScreen(servicioInicial: {},)),
                    child: const Text('RESERVAR UNA CITA'),
                  ),
                ],
              ),
            ),
    );
  }
}
