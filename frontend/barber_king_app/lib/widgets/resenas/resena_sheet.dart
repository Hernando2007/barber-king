import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/resena_service.dart';
import '../common/app_ui.dart';
import 'estrellas.dart';

Future<bool> mostrarHojaResena(
  BuildContext context, {
  required String nombreBarbero,
  required int citaId,
  required int barberoId,
}) async {
  final publicada = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    builder: (_) => _ResenaSheet(
      nombreBarbero: nombreBarbero,
      citaId: citaId,
      barberoId: barberoId,
    ),
  );

  return publicada == true;
}

class _ResenaSheet extends StatefulWidget {
  final String nombreBarbero;
  final int citaId;
  final int barberoId;

  const _ResenaSheet({
    required this.nombreBarbero,
    required this.citaId,
    required this.barberoId,
  });

  @override
  State<_ResenaSheet> createState() => _ResenaSheetState();
}

class _ResenaSheetState extends State<_ResenaSheet> {
  static const _etiquetas = ['Muy mal', 'Mal', 'Regular', 'Bien', 'Excelente'];

  final ResenaService _resenas = ResenaService();
  final TextEditingController _comentario = TextEditingController();

  int _calificacion = 0;
  bool _publicando = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (_calificacion == 0) {
      showAppSnack(
        context,
        'Toca las estrellas para elegir tu calificación.',
        error: true,
      );
      return;
    }

    setState(() => _publicando = true);

    final texto = _comentario.text.trim();

    final respuesta = await _resenas.crear(
      citaId: widget.citaId,
      barberoId: widget.barberoId,
      calificacion: _calificacion,
      comentario: texto.isEmpty ? null : texto,
    );

    if (!mounted) return;

    setState(() => _publicando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Reseña publicada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Deja tu reseña',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¿Cómo te fue con ${widget.nombreBarbero}?',
            style: const TextStyle(color: AppColors.subtitle, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                EstrellasInput(
                  valor: _calificacion,
                  onChanged: (valor) => setState(() => _calificacion = valor),
                ),
                const SizedBox(height: 6),
                Text(
                  _calificacion == 0
                      ? 'Elige de 1 a 5 estrellas'
                      : _etiquetas[_calificacion - 1],
                  style: TextStyle(
                    color: _calificacion == 0
                        ? AppColors.muted
                        : AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _comentario,
            maxLines: 4,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Cuéntanos cómo fue (opcional)',
              hintText: 'Atención, puntualidad, resultado del corte...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryGradientButton(
            label: 'Publicar reseña',
            icon: Icons.check_rounded,
            loading: _publicando,
            onPressed: _publicando ? null : _publicar,
          ),
        ],
      ),
    );
  }
}
