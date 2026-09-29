import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/cita_service.dart';
import 'crear_cita_screen.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final _service = CitaService();
  final _auth = AuthService();

  List<dynamic> citas = [];
  int rolId = 3;
  bool cargando = true;

  bool get esBarbero => rolId == 2;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final usuario = await _auth.obtenerUsuario();
    final id = int.tryParse('${usuario?['rol_id'] ?? 3}') ?? 3;
    final data = await _service.obtenerCitas();

    if (!mounted) return;

    setState(() {
      rolId = id;
      citas = data;
      cargando = false;
    });
  }

  Future<void> _estado(int id, String estado) async {
    final respuesta = await _service.actualizarCita(
      id: id,
      datos: {'estado': estado},
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          respuesta['message'] ?? 'Cita actualizada',
        ),
      ),
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: const Text(
          '¿Deseas cancelar esta cita?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final respuesta = await _service.eliminarCita(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          respuesta['message'] ?? 'Cita cancelada',
        ),
      ),
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completada':
        return AppColors.success;
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(esBarbero ? 'Agenda profesional' : 'Mis citas'),
      ),
      floatingActionButton: esBarbero
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.black,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrearCitaScreen(),
                  ),
                );
                await _cargar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva cita'),
            ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: citas.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 170),
                        Icon(
                          Icons.event_busy_outlined,
                          size: 70,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'No hay citas registradas.',
                            style: TextStyle(color: AppColors.subtitle),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(18),
                      itemCount: citas.length,
                      itemBuilder: (_, index) => _citaCard(citas[index]),
                    ),
            ),
    );
  }

  Widget _citaCard(Map<String, dynamic> cita) {
    final cliente = cita['usuarios'];
    final servicio = cita['servicios'];
    final nombre = cliente is Map
        ? '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'.trim()
        : 'Cliente';
    final servicioNombre = servicio is Map
        ? servicio['nombre']?.toString() ?? 'Servicio'
        : 'Servicio';
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final color = _estadoColor(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.isEmpty ? 'Cliente' : nombre,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      servicioNombre,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              _estadoChip(estado, color),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dato(
                  'FECHA',
                  cita['fecha']?.toString() ?? '-',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dato(
                  'HORA',
                  cita['hora']?.toString() ?? '-',
                ),
              ),
            ],
          ),
          if (esBarbero && estado.toLowerCase() != 'cancelada') ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _estado(
                      int.parse('${cita['id']}'),
                      'Confirmada',
                    ),
                    child: const Text('CONFIRMAR'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _estado(
                      int.parse('${cita['id']}'),
                      'Completada',
                    ),
                    child: const Text('COMPLETAR'),
                  ),
                ),
              ],
            ),
          ] else if (!esBarbero &&
              estado.toLowerCase() != 'cancelada' &&
              estado.toLowerCase() != 'completada') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _eliminar(
                  int.parse('${cita['id']}'),
                ),
                icon: const Icon(Icons.cancel_outlined),
                color: AppColors.error,
                tooltip: 'Cancelar cita',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _estadoChip(String estado, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _dato(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
