import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/cita_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/barbero/agenda_logica.dart';
part '../../widgets/barbero/agenda_semana.dart';
part '../../widgets/barbero/agenda_resumen.dart';
part '../../widgets/barbero/agenda_timeline.dart';
part '../../widgets/barbero/agenda_detalle.dart';

/// La agenda del barbero se lee por día, no como una lista plana: una semana
/// navegable, el resumen de la jornada y una línea de tiempo con la hora real
/// de cada corte.
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final CitaService _service = CitaService();

  List<Map<String, dynamic>> _citas = [];
  DateTime _dia = DateTime.now();
  DateTime _inicioSemana = _lunesDe(DateTime.now());
  bool _ocultarCerradas = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final delDia = _citasDelDia(_dia);
    final visibles = _ocultarCerradas
        ? delDia.where((cita) => !_estaCerrada(cita)).toList()
        : delDia;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi agenda'),
        actions: [
          IconButton(
            tooltip: 'Elegir fecha',
            onPressed: _elegirFecha,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando tu agenda...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    _AgendaSemana(
                      inicioSemana: _inicioSemana,
                      dia: _dia,
                      cargaPorDia: _cargaPorDia,
                      onDia: (fecha) => setState(() => _dia = fecha),
                      onSemana: _moverSemana,
                      onHoy: _irHoy,
                    ),
                    const SizedBox(height: 16),
                    _AgendaResumen(dia: _dia, citas: delDia),
                    const SizedBox(height: 22),
                    SectionHeader(
                      title: 'Línea de tiempo',
                      subtitle: visibles.isEmpty
                          ? 'Sin reservas que mostrar'
                          : '${visibles.length} '
                                '${visibles.length == 1 ? 'reserva' : 'reservas'}',
                      actionLabel: _ocultarCerradas
                          ? 'Ver cerradas'
                          : 'Ocultar cerradas',
                      onAction: () =>
                          setState(() => _ocultarCerradas = !_ocultarCerradas),
                    ),
                    const SizedBox(height: 14),
                    if (visibles.isEmpty)
                      EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: delDia.isEmpty ? 'Día libre' : 'Jornada cerrada',
                        message: delDia.isEmpty
                            ? 'No tienes reservas para este día. Revisa tus '
                                  'jornadas o espera nuevas reservas.'
                            : 'Todas las citas de este día ya están completadas '
                                  'o canceladas.',
                        actionLabel: delDia.isEmpty
                            ? 'Ver mis horarios'
                            : 'Ver cerradas',
                        onAction: delDia.isEmpty
                            ? () => Navigator.pushNamed(
                                context,
                                AppRoutes.horarios,
                              )
                            : () => setState(() => _ocultarCerradas = false),
                      )
                    else
                      _AgendaTimeline(
                        dia: _dia,
                        citas: visibles,
                        onEstado: _cambiarEstado,
                        onCancelar: _cancelar,
                        onDetalle: _verDetalle,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}