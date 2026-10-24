import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/register_account_type.dart';
import '../../widgets/auth/register_barber_fields.dart';
import '../../widgets/auth/register_fields_sections.dart';
import '../../widgets/auth/register_header.dart';
import '../../widgets/auth/register_submit_buttons.dart';
import '../../widgets/common/app_ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _fecha = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  final _especialidad = TextEditingController();
  final _experiencia = TextEditingController();
  final _descripcion = TextEditingController();

  int _rol = 3;
  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  XFile? _diploma;

  @override
  void dispose() {
    for (final controller in [
      _nombres,
      _apellidos,
      _correo,
      _telefono,
      _fecha,
      _password,
      _confirmar,
      _especialidad,
      _experiencia,
      _descripcion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_password.text != _confirmar.text) {
      showAppSnack(context, 'Las contraseñas no coinciden.', error: true);
      return;
    }

    setState(() => _cargando = true);

    Uint8List? diplomaBytes;
    if (_rol == 2 && _diploma != null) {
      diplomaBytes = await _diploma!.readAsBytes();
    }

    final respuesta = await _auth.registrar(
      rolId: _rol,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      telefono: _telefono.text,
      fechaNacimiento: _fecha.text,
      password: _password.text,
      especialidad: _rol == 2 ? _especialidad.text : null,
      experiencia:
          _rol == 2 ? int.tryParse(_experiencia.text.trim()) : null,
      descripcion: _rol == 2 ? _descripcion.text : null,
      diplomaBytes: diplomaBytes,
      diplomaNombre: _diploma?.name,
    );

    if (!mounted) return;

    setState(() => _cargando = false);

    if (respuesta['success'] == true) {
      showAppSnack(
        context,
        'Cuenta creada correctamente. Ya puedes iniciar sesión.',
      );
      Navigator.pop(context);
    } else {
      showAppSnack(
        context,
        respuesta['message'] ?? 'No se pudo crear la cuenta.',
        error: true,
      );
    }
  }

  void _onChangedRol(int value) {
    setState(() {
      _rol = value;
      if (_rol != 2) {
        _diploma = null;
        _especialidad.clear();
        _experiencia.clear();
        _descripcion.clear();
      }
    });
  }

  void _togglePassword() =>
      setState(() => _ocultarPassword = !_ocultarPassword);
  void _toggleConfirmar() =>
      setState(() => _ocultarConfirmar = !_ocultarConfirmar);
  void _onDiplomaChanged(XFile? file) => setState(() => _diploma = file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RegisterAccountType(
                            value: _rol,
                            onChanged: _onChangedRol,
                          ),
                          const SizedBox(height: 24),
                          RegisterFieldsSections(
                            nombres: _nombres,
                            apellidos: _apellidos,
                            correo: _correo,
                            telefono: _telefono,
                            fecha: _fecha,
                            password: _password,
                            confirmar: _confirmar,
                            ocultarPassword: _ocultarPassword,
                            ocultarConfirmar: _ocultarConfirmar,
                            onTogglePassword: _togglePassword,
                            onToggleConfirmar: _toggleConfirmar,
                          ),
                          RegisterBarberFields(
                            visible: _rol == 2,
                            especialidad: _especialidad,
                            experiencia: _experiencia,
                            descripcion: _descripcion,
                            diplomaName: _diploma?.name,
                            onDiplomaChanged: _onDiplomaChanged,
                          ),
                          const SizedBox(height: 26),
                          RegisterSubmitButtons(
                            esBarbero: _rol == 2,
                            cargando: _cargando,
                            onRegister: _registrar,
                            onCancel: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
