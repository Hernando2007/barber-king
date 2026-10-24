part of '../../screens/citas/crear_cita_screen.dart';

class _CrearCitaHero extends StatelessWidget {
  const _CrearCitaHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Agenda tu cita con los mejores barberos de la ciudad.',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrearCitaServicioField extends StatelessWidget {
  final List<Map<String, dynamic>> servicios;
  final int? servicioId;
  final ValueChanged<int?> onChanged;

  const _CrearCitaServicioField({
    required this.servicios,
    required this.servicioId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          title: 'Servicio',
          icon: Icons.design_services_outlined,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: servicioId,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Selecciona un servicio',
          ),
          items: servicios
              .map(
                (item) => DropdownMenuItem<int>(
                  value: int.tryParse('${item['id']}'),
                  child: Text(
                    '${item['nombre']} · ${AppFormat.money(item['precio'])}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CrearCitaBarberoField extends StatelessWidget {
  final List<Map<String, dynamic>> barberos;
  final int? barberoId;
  final ValueChanged<int?> onChanged;

  const _CrearCitaBarberoField({
    required this.barberos,
    required this.barberoId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          title: 'Barbero',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: barberoId,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Selecciona un barbero',
          ),
          items: barberos
              .map(
                (item) => DropdownMenuItem<int>(
                  value: int.tryParse('${item['id']}'),
                  child: Text(
                    _nombreBarbero(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

String _nombreBarbero(Map<String, dynamic> barbero) {
  final usuario = barbero['usuarios'];
  if (usuario is Map) {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    if (nombre.isNotEmpty) return nombre;
  }
  return 'Barbero';
}
