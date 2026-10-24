import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/usuario_service.dart';
import '../../widgets/common/app_ui.dart';

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

  Future<void> _cambiarFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (file == null) return;

    setState(() => _subiendoFoto = true);

    final bytes = await file.readAsBytes();
    final respuesta = await _usuarios.subirFoto(bytes, filename: file.name);

    if (!mounted) return;

    setState(() => _subiendoFoto = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Foto actualizada.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      final data = respuesta['data'];
      final foto = data is Map
          ? data['foto']?.toString()
          : data?.toString();

      if (foto != null) {
        await _auth.actualizarUsuarioLocal({'foto': foto});
      }

      await _cargar();
    }
  }

  Future<void> _subirDiploma() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    if (!mounted) return;

    final respuesta = await _usuarios.subirDiploma(
      bytes,
      filename: file.name,
    );

    if (!mounted) return;

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Documento actualizado.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _cargar();
    }
  }

  Future<void> _editarPerfil() async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (_) => _PerfilEditSheet(
        usuario: _usuario ?? {},
        esBarbero: _esBarbero,
      ),
    );

    if (guardado == true) {
      await _cargar();
    }
  }

  Future<void> _cambiarPassword() async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmar = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var procesando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> guardar() async {
            if (!formKey.currentState!.validate()) return;

            if (nueva.text != confirmar.text) {
              showAppSnack(
                context,
                'Las contraseñas nuevas no coinciden.',
                error: true,
              );
              return;
            }

            setSheetState(() => procesando = true);

            final respuesta = await _usuarios.actualizarPerfil({
              'password_actual': actual.text,
              'password_nueva': nueva.text,
            });

            if (!sheetContext.mounted) return;

            setSheetState(() => procesando = false);

            showAppSnack(
              sheetContext,
              respuesta['message']?.toString() ??
                  'Contraseña actualizada.',
              error: respuesta['success'] != true,
            );

            if (respuesta['success'] == true) {
              Navigator.pop(sheetContext);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: actual,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: _requerido,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nueva,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mínimo 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmar,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: _requerido,
                  ),
                  const SizedBox(height: 22),
                  PrimaryGradientButton(
                    label: 'ACTUALIZAR CONTRASEÑA',
                    icon: Icons.save_outlined,
                    loading: procesando,
                    onPressed: procesando ? null : guardar,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Deseas salir de tu cuenta?',
      confirmLabel: 'Salir',
      destructive: true,
    );

    if (!confirmar) return;

    await _auth.cerrarSesion();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
              AppCard(
                gradient: AppColors.heroGradient,
                borderColor: AppColors.primary.withValues(alpha: .3),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AppAvatar(
                          name: _nombre.isEmpty ? 'Usuario' : _nombre,
                          photoUrl: _usuario?['foto']?.toString(),
                          radius: 46,
                          fallbackIcon: _esBarbero
                              ? Icons.content_cut_rounded
                              : Icons.person_rounded,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _subiendoFoto ? null : _cambiarFoto,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.card,
                                  width: 2,
                                ),
                              ),
                              child: _subiendoFoto
                                  ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.black,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_rounded,
                                      color: AppColors.black,
                                      size: 15,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _nombre.isEmpty ? 'Usuario' : _nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    StatusPill(
                      label: AppFormat.role(_rolId),
                      color: AppColors.primary,
                    ),
                    if (_esBarbero &&
                        barbero['especialidad']?.toString().isNotEmpty ==
                            true) ...[
                      const SizedBox(height: 7),
                      Text(
                        barbero['especialidad'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _editarPerfil,
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('Editar'),
                        ),
                        const SizedBox(width: 9),
                        OutlinedButton.icon(
                          onPressed: _cambiarPassword,
                          icon: const Icon(Icons.key_outlined, size: 17),
                          label: const Text('Contraseña'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Información personal',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              InfoRow(
                icon: Icons.email_outlined,
                label: 'Correo electrónico',
                value: _usuario?['correo']?.toString() ?? '-',
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: _usuario?['telefono']?.toString() ?? '-',
              ),
              InfoRow(
                icon: Icons.cake_outlined,
                label: 'Fecha de nacimiento',
                value: AppFormat.date(_usuario?['fecha_nacimiento']),
              ),
              InfoRow(
                icon: Icons.verified_user_outlined,
                label: 'Estado de la cuenta',
                value: _usuario?['estado'] == false ? 'Desactivada' : 'Activa',
              ),
              if (_esBarbero) ...[
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'Información profesional',
                  icon: Icons.workspace_premium_outlined,
                  subtitle: 'Visible para los clientes',
                ),
                const SizedBox(height: 12),
                InfoRow(
                  icon: Icons.content_cut_outlined,
                  label: 'Especialidad',
                  value: barbero['especialidad']?.toString() ?? '-',
                ),
                InfoRow(
                  icon: Icons.timeline_outlined,
                  label: 'Experiencia',
                  value: '${barbero['experiencia'] ?? 0} años',
                ),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  value: barbero['direccion']?.toString() ?? '-',
                ),
                InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Descripción',
                  value: barbero['descripcion']?.toString() ?? '-',
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'Documento profesional',
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          diplomaUrl == null
                              ? Icons.upload_file_outlined
                              : Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diplomaUrl == null
                                  ? 'Sin documento adjunto'
                                  : (diplomaNombre ??
                                        'Diploma o certificado'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              diplomaUrl == null
                                  ? 'Sube una foto o captura de tu certificado.'
                                  : 'Documento cargado correctamente.',
                              style: const TextStyle(
                                color: AppColors.subtitle,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _subirDiploma,
                        icon: const Icon(
                          Icons.file_upload_outlined,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Subir documento',
                      ),
                    ],
                  ),
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

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }
}

class _PerfilEditSheet extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final bool esBarbero;

  const _PerfilEditSheet({
    required this.usuario,
    required this.esBarbero,
  });

  @override
  State<_PerfilEditSheet> createState() => _PerfilEditSheetState();
}

class _PerfilEditSheetState extends State<_PerfilEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usuarios = UsuarioService();
  final _auth = AuthService();

  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _telefono;
  late final TextEditingController _fecha;
  late final TextEditingController _especialidad;
  late final TextEditingController _experiencia;
  late final TextEditingController _descripcion;
  late final TextEditingController _direccion;

  bool _guardando = false;

  Map<String, dynamic> get _barbero {
    final value = widget.usuario['barbero'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  @override
  void initState() {
    super.initState();
    final barbero = _barbero;

    _nombres = TextEditingController(
      text: widget.usuario['nombres']?.toString(),
    );
    _apellidos = TextEditingController(
      text: widget.usuario['apellidos']?.toString(),
    );
    _telefono = TextEditingController(
      text: widget.usuario['telefono']?.toString(),
    );
    _fecha = TextEditingController(
      text: widget.usuario['fecha_nacimiento']?.toString().split('T').first,
    );
    _especialidad = TextEditingController(
      text: barbero['especialidad']?.toString(),
    );
    _experiencia = TextEditingController(
      text: barbero['experiencia']?.toString(),
    );
    _descripcion = TextEditingController(
      text: barbero['descripcion']?.toString(),
    );
    _direccion = TextEditingController(
      text: barbero['direccion']?.toString(),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _telefono,
      _fecha,
      _especialidad,
      _experiencia,
      _descripcion,
      _direccion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final value = await showDatePicker(
      context: context,
      initialDate: AppFormat.toDate(_fecha.text) ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (value == null) return;

    _fecha.text =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final datos = <String, dynamic>{
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'telefono': _telefono.text.trim(),
      'fecha_nacimiento': _fecha.text.trim(),
    };

    if (widget.esBarbero) {
      datos.addAll({
        'especialidad': _especialidad.text.trim(),
        'experiencia': int.tryParse(_experiencia.text.trim()) ?? 0,
        'descripcion': _descripcion.text.trim(),
        'direccion': _direccion.text.trim(),
      });
    }

    final respuesta = await _usuarios.actualizarPerfil(datos);

    if (!mounted) return;

    setState(() => _guardando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ?? 'Perfil actualizado.',
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      await _auth.actualizarUsuarioLocal({
        'nombres': datos['nombres'],
        'apellidos': datos['apellidos'],
        'telefono': datos['telefono'],
      });

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
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
              'Editar perfil',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nombres,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombres',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: _requerido,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apellidos,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Apellidos',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: _requerido,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fecha,
              readOnly: true,
              onTap: _seleccionarFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
            ),
            if (widget.esBarbero) ...[
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Perfil profesional',
                icon: Icons.workspace_premium_outlined,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _especialidad,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  prefixIcon: Icon(Icons.content_cut_outlined),
                ),
                validator: _requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experiencia,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Años de experiencia',
                  prefixIcon: Icon(Icons.timeline_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción profesional',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryGradientButton(
              label: 'GUARDAR CAMBIOS',
              icon: Icons.save_outlined,
              loading: _guardando,
              onPressed: _guardando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }

  String? _requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }
}

String? _requerido(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obligatorio.';
  }
  return null;
}
