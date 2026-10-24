part of '../../screens/admin/admin_usuarios_screen.dart';

class _AdminUsuariosBuscador extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AdminUsuariosBuscador({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o correo',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _AdminUsuariosFiltros extends StatelessWidget {
  final int filtro;
  final ValueChanged<int> onFiltro;

  const _AdminUsuariosFiltros({
    required this.filtro,
    required this.onFiltro,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('Todos', 0),
        _chip('Clientes', 3),
        _chip('Barberos', 2),
        _chip('Admins', 1),
      ],
    );
  }

  Widget _chip(String label, int valor) {
    final activo = filtro == valor;

    return ChoiceChip(
      label: Text(label),
      selected: activo,
      onSelected: (_) => onFiltro(valor),
      labelStyle: TextStyle(
        color: activo ? AppColors.primary : AppColors.subtitle,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

class _AdminUsuariosContador extends StatelessWidget {
  final int filtrados;
  final int total;

  const _AdminUsuariosContador({
    required this.filtrados,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$filtrados usuario${filtrados == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 12.5,
            ),
          ),
        ),
        Text(
          'Total: $total',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
