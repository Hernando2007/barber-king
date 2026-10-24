import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/formatters.dart';
import '../../services/admin_service.dart';
import '../../widgets/common/app_ui.dart';

part '../../widgets/admin/admin_usuario_form_logic.dart';
part '../../widgets/admin/admin_usuario_form_cabecera.dart';
part '../../widgets/admin/admin_usuario_form_cuenta.dart';
part '../../widgets/admin/admin_usuario_form_barbero.dart';

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
              _AdminUsuarioFormCabecera(
                nombreCompleto: '${_nombres.text} ${_apellidos.text}',
                foto: widget.usuario?['foto']?.toString(),
                esEdicion: _esEdicion,
                rol: _rol,
                activo: _activo,
              ),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Datos de la cuenta',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _AdminUsuarioFormCuenta(
                nombres: _nombres,
                apellidos: _apellidos,
                correo: _correo,
                telefono: _telefono,
                fecha: _fecha,
                password: _password,
                esEdicion: _esEdicion,
                rol: _rol,
                requerido: _requerido,
                onRolChanged: (value) => setState(() => _rol = value),
                onFechaTap: _seleccionarFecha,
                onCampoCambiado: () => setState(() {}),
              ),
              const SizedBox(height: 18),
              _AdminUsuarioFormSwitchActiva(
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
              ),
              if (_rol == 2) ...[
                const SizedBox(height: 24),
                _AdminUsuarioFormBarbero(
                  especialidad: _especialidad,
                  experiencia: _experiencia,
                  descripcion: _descripcion,
                  direccion: _direccion,
                  rol: _rol,
                  disponible: _disponible,
                  onDisponibleChanged: (value) =>
                      setState(() => _disponible = value),
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
