part of '../../screens/solicitudes/solicitudes_screen.dart';

/// El barbero elige la respuesta y, si quiere, añade una línea de 140
/// caracteres antes de enviar.
class _DialogoNota extends StatefulWidget {
  final Map<String, dynamic> solicitud;

  const _DialogoNota({required this.solicitud});

  @override
  State<_DialogoNota> createState() => _DialogoNotaState();
}

class _DialogoNotaState extends State<_DialogoNota> {
  final TextEditingController _nota = TextEditingController();

  String? _clave;

  List<Map<String, dynamic>> get _opciones {
    final valor = widget.solicitud['opciones'];

    if (valor is! List) {
      return [];
    }

    return valor.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  void _enviar() {
    final texto = _nota.text.trim();

    if (_clave == null) {
      showAppSnack(context, 'Elige una respuesta.', error: true);

      return;
    }

    if (texto.length > 140) {
      showAppSnack(context, 'Máximo 140 caracteres en la nota.', error: true);

      return;
    }

    Navigator.pop(context, {
      'clave': _clave,
      'nota': texto.isEmpty ? null : texto,
    });
  }

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text(
        'Responder con una línea',
        style: TextStyle(color: AppColors.white, fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<String>(
              groupValue: _clave,
              onChanged: (valor) => setState(() => _clave = valor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final opcion in _opciones)
                    RadioListTile<String>(
                      value: '${opcion['clave']}',
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        opcion['texto']?.toString() ?? '',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppField(
              label: 'Tu línea (opcional)',
              hint: 'Ej: te dejo el sábado a las 3',
              icon: Icons.edit_note_rounded,
              controller: _nota,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          onPressed: _enviar,
          child: const Text(
            'ENVIAR',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
