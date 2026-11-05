part of 'nueva_solicitud_sheet.dart';

/// Piezas pequeñas de la hoja: arrastre, cabecera, fecha y servicio.
/// El motivo tiene su propio archivo porque trae las respuestas-preview.
class _Arrastre extends StatelessWidget {
  const _Arrastre();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String nombre;

  const _Cabecera({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solicitar a $nombre',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Elige el motivo. Él responde con un toque.',
          style: TextStyle(color: AppColors.subtitle, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _ChipFecha extends StatelessWidget {
  final DateTime? fecha;
  final VoidCallback onTap;

  const _ChipFecha({required this.fecha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final elegida = fecha != null;
    final hora = fecha == null
        ? ''
        : ' · ${fecha!.hour.toString().padLeft(2, '0')}:'
              '${fecha!.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          side: BorderSide(
            color: elegida ? AppColors.primary : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        icon: const Icon(Icons.schedule_rounded, size: 18),
        label: Text(
          elegida ? AppFormat.dateLong(fecha) + hora : 'Elegir fecha y hora',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _DropdownServicio extends StatelessWidget {
  final List<dynamic> servicios;
  final int? seleccionado;
  final ValueChanged<int?> onCambiar;

  const _DropdownServicio({
    required this.servicios,
    required this.seleccionado,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<int>(
        initialValue:
            servicios.any(
              (s) => int.tryParse('${s['servicio_id']}') == seleccionado,
            )
            ? seleccionado
            : null,
        isExpanded: true,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'SERVICIO',
          labelStyle: const TextStyle(
            color: AppColors.subtitle,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
          prefixIcon: const Icon(
            Icons.content_cut_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        items: [
          for (final servicio in servicios)
            DropdownMenuItem<int>(
              value: int.tryParse('${servicio['servicio_id']}'),
              child: Text(
                '${servicio['nombre']} · ${AppFormat.money(servicio['precio'])}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onCambiar,
      ),
    );
  }
}
