part of '../../screens/admin/admin_revision_screen.dart';

/// Hoja de rechazo: la nota es opcional, pero queda en la auditoría.
Future<void> _mostrarRechazo(
  BuildContext context,
  String nombre,
  void Function(String? nota) onConfirmar,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
      ),
      child: _RechazoHoja(
        nombre: nombre,
        onConfirmar: (nota) {
          Navigator.pop(sheetContext);
          onConfirmar(nota);
        },
      ),
    ),
  );
}

class _RechazoHoja extends StatefulWidget {
  final String nombre;
  final ValueChanged<String?> onConfirmar;

  const _RechazoHoja({required this.nombre, required this.onConfirmar});

  @override
  State<_RechazoHoja> createState() => _RechazoHojaState();
}

class _RechazoHojaState extends State<_RechazoHoja> {
  final TextEditingController _nota = TextEditingController();

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.block_outlined, color: AppColors.error, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Rechazar a ${widget.nombre}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'El barbero no recibe el sello de verificado y puede volver a '
          'intentarlo subiendo otro documento.',
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        AppField(
          label: 'Nota para el barbero',
          hint: 'Ej. El diploma se ve borroso',
          icon: Icons.edit_note_rounded,
          controller: _nota,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => widget.onConfirmar(_nota.text.trim()),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            minimumSize: const Size(0, 48),
          ),
          icon: const Icon(Icons.block_outlined, size: 18),
          label: const Text('CONFIRMAR RECHAZO'),
        ),
      ],
    );
  }
}
