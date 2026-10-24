import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/admin_service.dart';
import '../../widgets/common/app_ui.dart';
import 'admin_usuario_form_screen.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final AdminService _admin = AdminService();
  final TextEditingController _busqueda = TextEditingController();

  List<Map<String, dynamic>> _usuarios = [];
  bool _cargando = true;
  int _filtro = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);

    final respuesta = await _admin.listarUsuarios();

    if (!mounted) return;

    setState(() {
      _usuarios = respuesta['success'] == true
          ? (respuesta['data'] as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList()
          : [];
      _cargando = false;
    });

    if (respuesta['success'] != true && mounted) {
      showAppSnack(
        context,
        respuesta['message']?.toString() ?? 'No se pudo cargar la lista.',
        error: true,
      );
    }
  }

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();

    return _usuarios.where((usuario) {
      final rol = int.tryParse('${usuario['rol_id']}') ?? 0;

      if (_filtro != 0 && rol != _filtro) {
        return false;
      }

      if (texto.isEmpty) {
        return true;
      }

      final nombre =
          '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'
              .toLowerCase();
      final correo = '${usuario['correo'] ?? ''}'.toLowerCase();

      return nombre.contains(texto) || correo.contains(texto);
    }).toList();
  }

  Future<void> _abrirFormulario([Map<String, dynamic>? usuario]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUsuarioFormScreen(usuario: usuario),
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _eliminar(Map<String, dynamic> usuario) async {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    final id = int.tryParse('${usuario['id']}') ?? 0;

    if (id == 0) return;

    final confirmar = await showConfirmDialog(
      context,
      title: 'Eliminar usuario',
      message:
          '¿Seguro que deseas eliminar a ${nombre.isEmpty ? 'este usuario' : nombre}? '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );

    if (!confirmar) return;

    var respuesta = await _admin.eliminarUsuario(id);

    if (!mounted) return;

    if (respuesta['statusCode'] == 409) {
      final detalles = respuesta['detalles'];
      var resumen = '';

      if (detalles is Map) {
        final partes = <String>[];
        void agregar(String etiqueta, dynamic valor) {
          final cantidad = int.tryParse('$valor') ?? 0;
          if (cantidad > 0) partes.add('$cantidad $etiqueta');
        }

        agregar('citas', detalles['citas']);
        agregar('reseñas', detalles['resenas']);
        agregar('mensajes', detalles['mensajes']);
        agregar('horarios', detalles['horarios']);
        resumen = partes.join(', ');
      }

      final forzar = await showConfirmDialog(
        context,
        title: 'El usuario tiene información asociada',
        message: resumen.isEmpty
            ? '${respuesta['message'] ?? 'No se puede eliminar el usuario.'}\n\n'
                  '¿Deseas eliminarlo junto con todos sus registros?'
            : '${respuesta['message'] ?? 'No se puede eliminar el usuario.'}\n\n'
                  'Registros asociados: $resumen.\n\n'
                  'Si continúas, se eliminarán también esas citas, reseñas, '
                  'mensajes y horarios.',
        confirmLabel: 'Eliminar todo',
        destructive: true,
      );

      if (!forzar) return;

      respuesta = await _admin.eliminarUsuario(id, forzar: true);

      if (!mounted) return;
    }

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Operación completada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo usuario'),
      ),
      body: SafeArea(
        child: _cargando
            ? const LoadingView(message: 'Cargando usuarios...')
            : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o correo',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _busqueda.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _busqueda.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Todos', 0),
                        _chip('Clientes', 3),
                        _chip('Barberos', 2),
                        _chip('Admins', 1),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${filtrados.length} usuario${filtrados.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        Text(
                          'Total: ${_usuarios.length}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (filtrados.isEmpty)
                      const EmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'Sin resultados',
                        message:
                            'No hay usuarios que coincidan con la búsqueda.',
                      )
                    else
                      ...filtrados.map(_usuarioCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _chip(String label, int valor) {
    final activo = _filtro == valor;

    return ChoiceChip(
      label: Text(label),
      selected: activo,
      onSelected: (_) => setState(() => _filtro = valor),
      labelStyle: TextStyle(
        color: activo ? AppColors.primary : AppColors.subtitle,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _usuarioCard(Map<String, dynamic> usuario) {
    final nombre =
        '${usuario['nombres'] ?? ''} ${usuario['apellidos'] ?? ''}'.trim();
    final rolId = int.tryParse('${usuario['rol_id']}') ?? 0;
    final rol = usuario['rol']?.toString() ?? AppFormat.role(rolId);
    final activo = usuario['estado'] != false;
    final barbero = usuario['barbero'];
    final especialidad = barbero is Map
        ? barbero['especialidad']?.toString()
        : null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      onTap: () => _abrirFormulario(usuario),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                name: nombre.isEmpty ? 'Usuario' : nombre,
                photoUrl: usuario['foto']?.toString(),
                radius: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nombre.isEmpty ? 'Usuario' : nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        StatusPill(
                          label: rol,
                          color: rolId == 1
                              ? AppColors.primary
                              : rolId == 2
                              ? AppColors.info
                              : AppColors.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      usuario['correo']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 12,
                      ),
                    ),
                    if (especialidad != null && especialidad.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        especialidad,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.subtitle,
                ),
                onSelected: (accion) {
                  if (accion == 'editar') {
                    _abrirFormulario(usuario);
                  } else {
                    _eliminar(usuario);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined, size: 19),
                      title: Text('Editar'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: AppColors.error,
                      ),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                activo
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_outlined,
                size: 15,
                color: activo ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 5),
              Text(
                activo ? 'Cuenta activa' : 'Cuenta desactivada',
                style: TextStyle(
                  color: activo ? AppColors.success : AppColors.error,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                usuario['telefono']?.toString() ?? 'Sin teléfono',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
