import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/admin_service.dart';
import '../../widgets/common/app_ui.dart';

class AdminUsuarioFormScreen extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const AdminUsuarioFormScreen({super.key, this.usuario});

  @override
  State<AdminUsuarioFormScreen> createState() => _AdminUsuarioFormScreenState();
}

class _AdminUsuarioFormScreenState extends State<AdminUsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _admin = AdminService();

  late final TextEditingController _nombres;
  late final TextEditingController _apellidos;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
  late final TextEditingController _fecha;
  late final TextEditingController _password;
  late final TextEditingController _especialidad;
  late final TextEditingController _experiencia;
  late final TextEditingController _descripcion;
  late final TextEditingController _direccion;

  late int _rol;
  late bool _activo;
  late bool _disponible;
  bool _cargando = false;

  bool get _esEdicion => widget.usuario != null;

  Map<String, dynamic> get _barbero {
    final value = widget.usuario?['barbero'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  @override
  void initState() {
    super.initState();

    final usuario = widget.usuario ?? const <String, dynamic>{};
    final barbero = _barbero;

    _nombres = TextEditingController(text: usuario['nombres']?.toString());
    _apellidos = TextEditingController(text: usuario['apellidos']?.toString());
    _correo = TextEditingController(text: usuario['correo']?.toString());
    _telefono = TextEditingController(text: usuario['telefono']?.toString());
    _fecha = TextEditingController(
      text: usuario['fecha_nacimiento']?.toString().split('T').first,
    );
    _password = TextEditingController();
    _especialidad = TextEditingController(
      text: barbero['especialidad']?.toString(),
    );
    _experiencia = TextEditingController(
      text: barbero['experiencia']?.toString(),
    );
    _descripcion = TextEditingController(
      text: barbero['descripcion']?.toString(),
    );
    _direccion = TextEditingController(text: barbero['direccion']?.toString());

    _rol = int.tryParse('${usuario['rol_id'] ?? 3}') ?? 3;
    _activo = usuario['estado'] != false;
    _disponible = barbero['disponible'] != false;
  }

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _correo,
      _telefono,
      _fecha,
      _password,
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

  Map<String, dynamic> _datos({bool forzar = false}) {
    final datos = <String, dynamic>{
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'correo': _correo.text.trim(),
      'telefono': _telefono.text.trim(),
      'fecha_nacimiento': _fecha.text.trim(),
      'rol_id': _rol,
      'estado': _activo,
    };

    if (_password.text.trim().isNotEmpty) {
      datos['password'] = _password.text;
    }

    if (_rol == 2) {
      datos.addAll({
        'especialidad': _especialidad.text.trim(),
        'experiencia': int.tryParse(_experiencia.text.trim()) ?? 0,
        'descripcion': _descripcion.text.trim(),
        'direccion': _direccion.text.trim(),
        'disponible': _disponible,
      });
    }

    if (forzar) {
      datos['forzar'] = true;
    }

    return datos;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_esEdicion && _password.text.trim().length < 6) {
      showAppSnack(context, 'La contraseña debe tener mínimo 6 caracteres.',
          error: true);
      return;
    }

    setState(() => _cargando = true);

    final id = int.tryParse('${widget.usuario?['id']}');
    var respuesta = _esEdicion
        ? await _admin.actualizarUsuario(id ?? 0, _datos())
        : await _admin.crearUsuario(_datos());

    if (!mounted) return;

    if (_esEdicion && respuesta['statusCode'] == 409) {
      final mensaje = respuesta['message']?.toString() ?? '';
      final esRol = mensaje.toLowerCase().contains('barbero');

      if (esRol) {
        final forzar = await showConfirmDialog(
          context,
          title: 'Cambio de rol con registros asociados',
          message:
              '$mensaje\n\nSi cambias el rol, se eliminarán las citas, '
              'reseñas y horarios del perfil de barbero.',
          confirmLabel: 'Cambiar de todas formas',
          destructive: true,
        );

        if (forzar) {
          respuesta = await _admin.actualizarUsuario(
            id ?? 0,
            _datos(forzar: true),
          );
        }
      }
    }

    if (!mounted) return;

    setState(() => _cargando = false);

    showAppSnack(
      context,
      respuesta['message']?.toString() ??
          (_esEdicion ? 'Usuario actualizado.' : 'Usuario creado.'),
      error: respuesta['success'] != true,
    );

    if (respuesta['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                gradient: AppColors.heroGradient,
                borderColor: AppColors.primary.withValues(alpha: .3),
                child: Row(
                  children: [
                    AppAvatar(
                      name: '${_nombres.text} ${_apellidos.text}',
                      photoUrl: widget.usuario?['foto']?.toString(),
                      radius: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esEdicion
                                ? '${_nombres.text} ${_apellidos.text}'.trim()
                                : 'Crear nueva cuenta',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${AppFormat.role(_rol)} · '
                            '${_activo ? 'Activa' : 'Desactivada'}',
                            style: const TextStyle(
                              color: AppColors.subtitle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Datos de la cuenta',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _rol,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('Cliente')),
                  DropdownMenuItem(value: 2, child: Text('Barbero')),
                  DropdownMenuItem(value: 1, child: Text('Administrador')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _rol = value);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nombres,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: _requerido,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _apellidos,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: _requerido,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.isEmpty) return 'Ingresa el correo.';
                  if (!texto.contains('@') || !texto.contains('.')) {
                    return 'Ingresa un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _fecha,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _esEdicion
                      ? 'Nueva contraseña (opcional)'
                      : 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  helperText: _esEdicion
                      ? 'Déjala vacía para conservar la actual.'
                      : 'Mínimo 6 caracteres.',
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  title: const Text(
                    'Cuenta activa',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Los usuarios desactivados no pueden iniciar sesión.',
                    style: TextStyle(color: AppColors.subtitle, fontSize: 11.5),
                  ),
                ),
              ),
              if (_rol == 2) ...[
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Perfil profesional',
                  subtitle: 'Información visible para los clientes',
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _especialidad,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad *',
                    hintText: 'Ej. Fade, barbería clásica',
                    prefixIcon: Icon(Icons.content_cut_outlined),
                  ),
                  validator: (value) {
                    if (_rol != 2) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'La especialidad es obligatoria.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _experiencia,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Años de experiencia',
                    prefixIcon: Icon(Icons.timeline_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final years = int.tryParse(value.trim());
                    if (years == null || years < 0 || years > 70) {
                      return 'Ingresa un valor entre 0 y 70.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descripcion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción profesional',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _direccion,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _disponible,
                    onChanged: (value) => setState(() => _disponible = value),
                    title: const Text(
                      'Disponible para reservas',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              PrimaryGradientButton(
                label: _esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR USUARIO',
                icon: _esEdicion
                    ? Icons.save_outlined
                    : Icons.person_add_alt_1_rounded,
                loading: _cargando,
                onPressed: _cargando ? null : _guardar,
              ),
              const SizedBox(height: 12),
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
