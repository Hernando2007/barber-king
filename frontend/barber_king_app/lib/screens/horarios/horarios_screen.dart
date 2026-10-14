import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/horario_service.dart';
import '../../widgets/common/gold_widgets.dart';

typedef _Mapa = Map<String, dynamic>;

/// Horario de trabajo del barbero (1 = lunes ... 7 = domingo, como el backend).
class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  static const _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final _servicio = HorarioService();
  List<_Mapa> _horarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _aviso(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  // El backend compara "HH:mm" como texto, por eso siempre con ceros a la izquierda.
  String _hh(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _corta(dynamic hora) =>
      '$hora'.length >= 5 ? '$hora'.substring(0, 5) : '$hora';

  Future<void> _cargar() async {
    final lista = await _servicio.obtenerHorarios();
    lista.sort((a, b) {
      final c = (a['dia_semana'] as num).compareTo(b['dia_semana'] as num);
      return c != 0
          ? c
          : '${a['hora_inicio']}'.compareTo('${b['hora_inicio']}');
    });
    if (!mounted) return;
    setState(() {
      _horarios = lista;
      _cargando = false;
    });
  }

  Future<void> _agregar() async {
    var dia = 1;
    var inicio = const TimeOfDay(hour: 9, minute: 0);
    var fin = const TimeOfDay(hour: 18, minute: 0);

    final guardar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> elegir(bool esInicio) async {
            final t = await showTimePicker(
              context: ctx,
              initialTime: esInicio ? inicio : fin,
            );
            if (t != null) setSheet(() => esInicio ? inicio = t : fin = t);
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NUEVO HORARIO', style: tituloSerif(size: 16)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 7; i++)
                      ChoiceChip(
                        label: Text(_dias[i]),
                        selected: dia == i + 1,
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: dia == i + 1 ? AppColors.black : Colors.white,
                        ),
                        onSelected: (_) => setSheet(() => dia = i + 1),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => elegir(true),
                        child: Text('Desde ${_hh(inicio)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => elegir(false),
                        child: Text('Hasta ${_hh(fin)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('GUARDAR HORARIO'),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (guardar != true) return;

    try {
      await _servicio.crearHorario(
        diaSemana: dia,
        horaInicio: _hh(inicio),
        horaFin: _hh(fin),
      );
      _cargar();
    } catch (e) {
      if (mounted) _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _eliminar(_Mapa h) async {
    try {
      await _servicio.eliminarHorario(h['id'] as int);
      _cargar();
    } catch (e) {
      if (mounted) _aviso(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        icon: const Icon(Icons.add),
        label: const Text('AGREGAR HORARIO'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: Text('MIS HORARIOS', style: tituloSerif(size: 22)),
                ),
              ],
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _cargar,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        children: _horarios.isEmpty
                            ? [
                                const SizedBox(height: 60),
                                const Center(
                                  child: Text(
                                    'Aún no tienes horarios. Agrega uno para recibir citas.',
                                    style: TextStyle(color: AppColors.subtitle),
                                  ),
                                ),
                              ]
                            : [
                                for (final h in _horarios)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      8,
                                      8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _dias[((h['dia_semana'] as num)
                                                                .toInt() -
                                                            1)
                                                        .clamp(0, 6)]
                                                    .toUpperCase(),
                                                style: tituloSerif(size: 13),
                                              ),
                                              Text(
                                                '${_corta(h['hora_inicio'])} - ${_corta(h['hora_fin'])}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _eliminar(h),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
