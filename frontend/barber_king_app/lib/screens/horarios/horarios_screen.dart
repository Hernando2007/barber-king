import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/horario_service.dart';
import '../../services/usuario_service.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final _usuarios = UsuarioService();
  final _horariosService = HorarioService();

  final _dias = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  List<Map<String, dynamic>> horarios = [];
  int? barberoId;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final perfil = await _usuarios.obtenerPerfilActual();
    final barbero = perfil?['barbero'];
    final id = barbero is Map ? barbero['id'] : null;

    if (id == null) {
      if (!mounted) return;
      setState(() => cargando = false);
      return;
    }

    final data = await _horariosService.obtenerHorarios(
      int.parse(id.toString()),
    );

    if (!mounted) return;

    setState(() {
      barberoId = int.parse(id.toString());
      horarios = data;
      cargando = false;
    });
  }

  Future<void> _agregar() async {
    if (barberoId == null) return;

    var dia = 1;
    var inicio = const TimeOfDay(hour: 8, minute: 0);
    var fin = const TimeOfDay(hour: 18, minute: 0);

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              title: const Text('Nuevo horario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: dia,
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_dias[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setDialog(() => dia = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Día de trabajo',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Hora de inicio'),
                    subtitle: Text(inicio.format(context)),
                    onTap: () async {
                      final value = await showTimePicker(
                        context: context,
                        initialTime: inicio,
                      );
                      if (value != null) {
                        setDialog(() => inicio = value);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora de fin'),
                    subtitle: Text(fin.format(context)),
                    onTap: () async {
                      final value = await showTimePicker(
                        context: context,
                        initialTime: fin,
                      );
                      if (value != null) {
                        setDialog(() => fin = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _horariosService.crearHorario(
                        diaSemana: dia,
                        horaInicio: _hora(inicio),
                        horaFin: _hora(fin),
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (guardar == true) {
      setState(() => cargando = true);
      await _cargar();
    }
  }

  String _hora(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}: '
        '${time.minute.toString().padLeft(2, '0')}:00'
        .replaceAll(': ', ':');
  }

  String _dia(dynamic value) {
    final index = int.tryParse('$value') ?? 1;
    if (index < 1 || index > 7) return 'Día';
    return _dias[index - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis horarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregar,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : horarios.isEmpty
              ? const Center(
                  child: Text(
                    'Todavía no tienes horarios configurados.',
                    style: TextStyle(color: AppColors.subtitle),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: horarios.length,
                  itemBuilder: (_, index) {
                    final item = horarios[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dia(item['dia_semana']),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['hora_inicio']} - ${item['hora_fin']}',
                                  style: const TextStyle(
                                    color: AppColors.subtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _horariosService.eliminarHorario(
                                int.parse('${item['id']}'),
                              );
                              await _cargar();
                            },
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
