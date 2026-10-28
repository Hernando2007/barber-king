import 'package:flutter/material.dart';

import '../../services/barbero_service.dart';
import '../../services/ubicacion_service.dart';
import '../common/app_ui.dart';

class BarberosCercaBoton extends StatefulWidget {
  final bool activo;
  final ValueChanged<List<Map<String, dynamic>>> onCerca;
  final Future<void> Function() onTodos;

  const BarberosCercaBoton({
    super.key,
    required this.activo,
    required this.onCerca,
    required this.onTodos,
  });

  @override
  State<BarberosCercaBoton> createState() => _BarberosCercaBotonState();
}

class _BarberosCercaBotonState extends State<BarberosCercaBoton> {
  final BarberoService _barberos = BarberoService();
  final UbicacionService _ubicacion = UbicacionService();

  bool _cargando = false;

  Future<void> _alternar() async {
    if (widget.activo) {
      await widget.onTodos();
      return;
    }

    setState(() => _cargando = true);

    try {
      final posicion = await _ubicacion.obtenerPosicion();
      final data = await _barberos.obtenerCercanos(
        latitud: posicion.latitud,
        longitud: posicion.longitud,
      );

      if (!mounted) return;

      final lista = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      widget.onCerca(lista);

      if (lista.isEmpty) {
        showAppSnack(
          context,
          'Ningún barbero ha compartido su ubicación en tu zona.',
        );
      }
    } on UbicacionException catch (e) {
      if (mounted) {
        showAppSnack(context, e.mensaje, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: widget.activo ? 'Ver todos' : 'Barberos cerca de mí',
      onPressed: _cargando ? null : _alternar,
      icon: _cargando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              widget.activo
                  ? Icons.people_alt_outlined
                  : Icons.my_location_rounded,
            ),
    );
  }
}
