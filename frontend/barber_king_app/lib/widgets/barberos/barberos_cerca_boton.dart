import 'package:flutter/material.dart';

import '../../core/colors.dart';
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
    final color = widget.activo ? AppColors.primary : AppColors.primaryLight;

    return Tooltip(
      message: widget.activo ? 'Ver todos' : 'Barberos cerca de mí',
      child: Material(
        color: AppColors.primary.withValues(alpha: widget.activo ? .28 : .13),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _cargando ? null : _alternar,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      widget.activo
                          ? Icons.people_alt_outlined
                          : Icons.location_on_rounded,
                      color: color,
                      size: 23,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
