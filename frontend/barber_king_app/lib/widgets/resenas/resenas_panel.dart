import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/resena_service.dart';
import 'resena_card.dart';

class ResenasBarberoPanel extends StatefulWidget {
  final int barberoId;
  final int limite;

  const ResenasBarberoPanel({
    super.key,
    required this.barberoId,
    this.limite = 3,
  });

  @override
  State<ResenasBarberoPanel> createState() => _ResenasBarberoPanelState();
}

class _ResenasBarberoPanelState extends State<ResenasBarberoPanel> {
  final ResenaService _resenas = ResenaService();

  List<Map<String, dynamic>> _lista = [];
  bool _cargando = true;
  bool _expandida = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final data = await _resenas.obtenerPorBarbero(widget.barberoId);

    if (!mounted) return;

    setState(() {
      _lista = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: AppColors.surface,
        ),
      );
    }

    if (_lista.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Aún no hay reseñas. En cuanto un cliente califique su cita, '
            'aparecerán aquí.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      );
    }

    final visibles = _expandida
        ? _lista
        : _lista.take(widget.limite).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibles.map((resena) => ResenaCard(resena: resena)),
        if (_lista.length > widget.limite)
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expandida = !_expandida),
              icon: Icon(
                _expandida
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 18,
              ),
              label: Text(
                _expandida
                    ? 'Ver menos'
                    : 'Ver las ${_lista.length} reseñas',
              ),
            ),
          ),
      ],
    );
  }
}
