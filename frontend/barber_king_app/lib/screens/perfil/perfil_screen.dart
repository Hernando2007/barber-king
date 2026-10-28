import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/barbero_service.dart';
import '../../services/ubicacion_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/perfil/perfil_screen_acciones.dart';
part '../../widgets/perfil/perfil_screen_password.dart';
part '../../widgets/perfil/perfil_screen_header.dart';
part '../../widgets/perfil/perfil_screen_info.dart';
part '../../widgets/perfil/perfil_screen_ubicacion.dart';
part '../../widgets/perfil/perfil_screen_edit.dart';
part '../../widgets/perfil/perfil_screen_edit_view.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _auth = AuthService();
  final UsuarioService _usuarios = UsuarioService();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _usuario;
  bool _cargando = true;
  bool _subiendoFoto = false;
  bool _actualizandoUbicacion = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final remoto = await _usuarios.obtenerPerfilActual();
    final local = await _auth.obtenerUsuario();

    if (!mounted) return;

    setState(() {
      _usuario = remoto ?? local;
      _cargando = false;
    });
  }

  int get _rolId => int.tryParse('${_usuario?['rol_id'] ?? 3}') ?? 3;
  bool get _esBarbero => _rolId == 2;

  Map<String, dynamic> get _barbero {
    final value = _usuario?['barbero'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String get _nombre =>
      '${_usuario?['nombres'] ?? ''} ${_usuario?['apellidos'] ?? ''}'.trim();

  Future<void> _compartirUbicacion() async {
    setState(() => _actualizandoUbicacion = true);
    try {
      final posicion = await UbicacionService().obtenerPosicion();
      final barbero = _barbero;
      final respuesta = await BarberoService().actualizarUbicacion(
        latitud: posicion.latitud,
        longitud: posicion.longitud,
        ciudad: barbero['ciudad']?.toString(),
        zona: barbero['zona']?.toString(),
      );

      if (!mounted) return;
      showAppSnack(
        context,
        respuesta['success'] == true
            ? 'Ubicación compartida. Los clientes ya pueden encontrarte.'
            : respuesta['message']?.toString() ??
                'No fue posible compartir tu ubicación.',
        error: respuesta['success'] != true,
      );

      if (respuesta['success'] == true) {
        final remoto = await _usuarios.obtenerPerfilActual();

        if (remoto != null && mounted) {
          setState(() => _usuario = remoto);
        }
      }
    } on UbicacionException catch (e) {
      if (mounted) {
        showAppSnack(context, e.mensaje, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _actualizandoUbicacion = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingView(message: 'Cargando perfil...'),
      );
    }

    final barbero = _barbero;
    final diplomaUrl = barbero['diploma_url']?.toString();
    final diplomaNombre = barbero['diploma_nombre']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esBarbero ? 'Perfil profesional' : 'Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editarPerfil,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _PerfilHeaderCard(
                nombre: _nombre,
                fotoUrl: _usuario?['foto']?.toString(),
                esBarbero: _esBarbero,
                rolLabel: AppFormat.role(_rolId),
                especialidad: barbero['especialidad']?.toString(),
                subiendoFoto: _subiendoFoto,
                onCambiarFoto: _subiendoFoto ? null : _cambiarFoto,
                onEditar: _editarPerfil,
                onCambiarPassword: _cambiarPassword,
              ),
              const SizedBox(height: 22),
              _PerfilInfoPersonal(usuario: _usuario),
              if (_esBarbero) ...[
                const SizedBox(height: 22),
                _PerfilInfoProfesional(barbero: barbero),
                const SizedBox(height: 22),
                _PerfilUbicacionCard(
                  barbero: barbero,
                  cargando: _actualizandoUbicacion,
                  onCompartir: _compartirUbicacion,
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'Documento profesional',
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: 12),
                _DiplomaCard(
                  url: diplomaUrl,
                  nombre: diplomaNombre,
                  onSubir: _subirDiploma,
                ),
              ],
              const SizedBox(height: 26),
              OutlinedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout_outlined),
                label: const Text('CERRAR SESIÓN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: .5),
                  ),
                  minimumSize: const Size(48, 52),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

String? _requerido(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obligatorio.';
  }
  return null;
}
