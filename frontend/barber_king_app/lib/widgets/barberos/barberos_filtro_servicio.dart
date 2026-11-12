import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/servicios_service.dart';
import 'barberos_pildora.dart';

/// Filtro por servicio de la lista de barberos, con el mismo lenguaje visual
/// de las pestañas de Reservas: píldoras doradas sobre fondo oscuro.
class BarberosFiltroServicio extends StatefulWidget {
  final ValueChanged<int?> onSeleccionar;

  const BarberosFiltroServicio({super.key, required this.onSeleccionar});

  @override
  State<BarberosFiltroServicio> createState() => _BarberosFiltroServicioState();
}

class _BarberosFiltroServicioState extends State<BarberosFiltroServicio> {
  final ServicioService _servicioService = ServicioService();

  List<Map<String, dynamic>>? _servicios;
  int? _seleccionado;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await _servicioService.obtenerServicios(soloActivos: true);

    if (!mounted) return;

    final lista = <Map<String, dynamic>>[];

    for (final item in datos) {
      if (item is Map) {
        lista.add(Map<String, dynamic>.from(item));
      }
    }

    setState(() {
      _servicios = lista;
      _cargando = false;
    });
  }

  void _elegir(int? servicioId) {
    if (_seleccionado == servicioId) return;

    setState(() => _seleccionado = servicioId);
    widget.onSeleccionar(servicioId);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 38,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final servicios = _servicios ?? const <Map<String, dynamic>>[];

    if (servicios.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FILTRAR POR SERVICIO',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              BarberosPildora(
                label: 'Todos',
                seleccionado: _seleccionado == null,
                onTap: () => _elegir(null),
              ),
              for (final servicio in servicios)
                if (int.tryParse('${servicio['id']}') case final int id)
                  BarberosPildora(
                    label: '${servicio['nombre']}',
                    seleccionado: _seleccionado == id,
                    onTap: () => _elegir(id),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
