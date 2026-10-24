part of '../../screens/servicios/servicios_screen.dart';

class _ServiciosHeaderCard extends StatelessWidget {
  final bool esAdmin;

  const _ServiciosHeaderCard({required this.esAdmin});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.heroGradient,
      borderColor: AppColors.primary.withValues(alpha: .3),
      child: Row(
        children: [
          const Icon(
            Icons.design_services_outlined,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esAdmin
                      ? 'Catálogo de servicios'
                      : 'Servicios premium',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  esAdmin
                      ? 'Crea, edita y elimina los servicios del negocio.'
                      : 'Elige el servicio ideal para tu próximo look.',
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiciosBuscador extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ServiciosBuscador({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Buscar servicio',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}
