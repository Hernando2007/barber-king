import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/admin_service.dart';
import '../../widgets/common/app_ui.dart';
import 'admin_usuario_form_screen.dart';

part '../../widgets/admin/admin_usuarios_acciones.dart';
part '../../widgets/admin/admin_usuarios_busqueda.dart';
part '../../widgets/admin/admin_usuarios_card.dart';

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
                    _AdminUsuariosBuscador(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _AdminUsuariosFiltros(
                      filtro: _filtro,
                      onFiltro: (valor) => setState(() => _filtro = valor),
                    ),
                    const SizedBox(height: 18),
                    _AdminUsuariosContador(
                      filtrados: filtrados.length,
                      total: _usuarios.length,
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
                      ...filtrados.map(
                        (usuario) => _AdminUsuariosCard(
                          usuario: usuario,
                          onEditar: () => _abrirFormulario(usuario),
                          onEliminar: () => _eliminar(usuario),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
